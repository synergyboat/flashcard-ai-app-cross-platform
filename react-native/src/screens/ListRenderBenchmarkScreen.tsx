// ListRenderBenchmarkScreen.tsx
import React, { memo, useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  Platform,
  InteractionManager,
  ListRenderItem,
  NativeSyntheticEvent,
  NativeScrollEvent,
  Animated,
  Easing,
  NativeModules,
  Alert,
} from 'react-native';

declare const __DEV__: boolean;

/* ============================
 * Constants
 * ============================ */

// Single source of truth for row height (used in layout + styles)
const ROW_HEIGHT = 80;

/* ============================
 * Benchmark Types & Interfaces
 * ============================ */

enum BenchmarkType {
  STATIC_RENDER = 'staticRender',
  SCROLL_PERFORMANCE = 'scrollPerformance',
  MEMORY_USAGE = 'memoryUsage',
}

interface BenchmarkProps {
  itemCount?: number;
  iterations?: number;
  benchmarkType?: BenchmarkType;
  onComplete?: (results: BenchmarkResult[]) => void;
}

interface ListItem {
  key: number;
  index: number;
}

interface FrameMetrics {
  frameStartTime: number;
  frameDuration: number;
  jsFrameDuration: number;
  uiFrameDuration: number;
}

/* ===== Native module types (graceful, typed) ===== */

interface MemoryInfo {
  totalPSS: number;           // in bytes
  residentSize?: number;      // bytes
  virtualSize?: number;       // bytes
  timestamp: number;          // epoch ms
}

interface DisplayInfo {
  refreshRate: number;        // Hz
  targetFrameTime: number;    // ms
  maxRefreshRate?: number;    // Hz
  supportsHighRefreshRate?: boolean;
}

interface PerformanceDataNative {
  timeToFirstFrame: number;   // ms
  frameTimings: number[];     // ms per frame
  profilingMethod?: 'native' | 'javascript';
}

interface MemoryProfilerModule {
  getCurrentMemoryUsage(): Promise<MemoryInfo>;
  getDetailedMemoryInfo?(): Promise<MemoryInfo>;
}

interface FrameProfilerModule {
  startProfiling(): Promise<void>;
  stopProfiling(): Promise<number[]>; // returns frame durations in ms
  getDisplayRefreshRate?(): Promise<DisplayInfo>;
  getDisplayCapabilities?(): Promise<DisplayInfo>;
}

const { MemoryProfiler, FrameProfiler, BenchmarkLogger: _BenchmarkLogger }: {
  MemoryProfiler?: MemoryProfilerModule;
  FrameProfiler?: FrameProfilerModule;
  BenchmarkLogger?: { log(level: 'info' | 'warn' | 'error', message: string): void };
} = NativeModules as any;

/* ============================
 * Release-safe Logger (monkey-patches console in release)
 * ============================ */

type TLogLevel = 'info' | 'warn' | 'error';
const LOG_TAG = 'Benchmark';

// <<< fixed: ASCII-only sanitizer to prevent mojibake in syslog
const toAscii = (s: string) => s.replace(/[^\x20-\x7E]/g, ''); // strip non-ASCII

function _stringify(args: unknown[]) {
  return args
    .map((a) => {
      try {
        if (typeof a === 'string') return a;
        return JSON.stringify(a);
      } catch {
        return String(a);
      }
    })
    .join(' ');
}

// Optional file sink via RNFS (if present)
let fileSink: { append: (s: string) => Promise<void>; path: string } | null = null;
(async () => {
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const RNFS = require('react-native-fs');
    const path = `${RNFS.DocumentDirectoryPath}/benchmark.log`;
    fileSink = {
      path,
      append: (s: string) => RNFS.appendFile(path, s, 'utf8'),
    };
  } catch {
    // RNFS not installed; silently ignore
  }
})();

async function emit(level: TLogLevel, ...args: unknown[]) {
  const msg = `[${LOG_TAG}] ${_stringify(args)}`;

  // Always forward to JS console (Android release still surfaces via logcat)
  // <<< fixed: Console gets ASCII-only to avoid mojibake in device logs
  const ascii = toAscii(msg);
  switch (level) {
    case 'info': console.info ? console.info(ascii) : console.log(ascii); break;
    case 'warn': console.warn(ascii); break;
    case 'error': console.error(ascii); break;
  }
  // Native OS log (survives iOS release)
  try { _BenchmarkLogger?.log(level, ascii); } catch {}
  // Optional file sink (keep full UTF-8 prettiness here)
  try { await fileSink?.append(`${new Date().toISOString()} ${level.toUpperCase()} ${msg}\n`); } catch {}
}

// In release, mirror console.* to native + file
if (!__DEV__) {
  const _origLog = console.log;
  const _origWarn = console.warn;
  const _origErr = console.error;
  console.log = (...a) => { emit('info', ...a); _origLog(...a); };
  console.warn = (...a) => { emit('warn', ...a); _origWarn(...a); };
  console.error = (...a) => { emit('error', ...a); _origErr(...a); };
}

// Export helper for the file path (if RNFS available)
export const getBenchmarkLogFilePath = () => fileSink?.path ?? null;

/* ============================
 * Platform Info (Updated)
 * ============================ */

class PlatformInfo {
  static get platformName(): string {
    switch (Platform.OS) {
      case 'ios': return 'iOS';
      case 'android': return 'Android';
      case 'web': return 'Web';
      case 'windows': return 'Windows';
      case 'macos': return 'macOS';
      default: return 'Unknown';
    }
  }

  static get isMobile(): boolean { return Platform.OS === 'ios' || Platform.OS === 'android'; }
  static get isWeb(): boolean { return Platform.OS === 'web'; }

  static get hasNativeMemoryProfiler(): boolean {
    return Platform.OS !== 'web' && !!MemoryProfiler;
  }

  static get hasNativeFrameProfiler(): boolean {
    return Platform.OS !== 'web' && !!FrameProfiler;
  }

  static get supportsWebMemory(): boolean {
    return !!(global as any).performance?.memory;
  }

  static get supportsMemoryProfiling(): boolean {
    // Prefer native; fallback to web’s JS heap
    return this.hasNativeMemoryProfiler || this.supportsWebMemory;
  }

  static get performanceProfile(): string {
    if (this.isWeb) return 'Web (JS + Browser rendering)';
    if (Platform.OS === 'ios') return 'iOS (Metal rendering, Bridge + Native)';
    if (Platform.OS === 'android') return 'Android (Vulkan/OpenGL, Bridge + Native)';
    return 'Unknown platform';
  }
}

/* ============================
 * Enhanced Benchmark Result
 * ============================ */

class BenchmarkResult {
  public timeToFirstFrame: number;         // ms
  public frameMetrics: FrameMetrics[];
  public memoryDeltaMB: number;
  public timestamp: Date;
  public itemCount: number;
  public platform: string;
  public targetFrameTimeMs: number;
  public scrollDistance: number;           // Total pixels scrolled
  public scrollDuration: number;           // Actual scroll time
  public refreshRateHz: number;            // <<< fixed: store detected Hz

  constructor({
    timeToFirstFrame,
    frameMetrics = [],
    memoryDeltaMB = 0,
    timestamp,
    itemCount,
    platform,
    targetFrameTimeMs,
    scrollDistance = 0,
    scrollDuration = 0,
    refreshRateHz,
  }: {
    timeToFirstFrame: number;
    frameMetrics?: FrameMetrics[];
    memoryDeltaMB?: number;
    timestamp: Date;
    itemCount: number;
    platform: string;
    targetFrameTimeMs: number;
    scrollDistance?: number;
    scrollDuration?: number;
    refreshRateHz: number;
  }) {
    this.timeToFirstFrame = timeToFirstFrame;
    this.frameMetrics = frameMetrics;
    this.memoryDeltaMB = memoryDeltaMB;
    this.timestamp = timestamp;
    this.itemCount = itemCount;
    this.platform = platform;
    this.targetFrameTimeMs = targetFrameTimeMs;
    this.scrollDistance = scrollDistance;
    this.scrollDuration = scrollDuration;
    this.refreshRateHz = refreshRateHz;
  }

  get averageFrameTimeMs(): number {
    const frameTimes = this.frameMetrics.map(f => f.frameDuration);
    return frameTimes.length ? frameTimes.reduce((a, b) => a + b, 0) / frameTimes.length : 0;
  }

  // Clamped actual FPS from average frame time (panel ceiling)
  get clampedFpsFromFrameTime(): number {                          // <<< fixed
    const ft = this.averageFrameTimeMs;
    if (!ft) return 0;
    return Math.min(1000 / ft, this.refreshRateHz || 60);
  }

  get actualFps(): number {
    if (this.frameMetrics.length === 0) return 0;
    
    // Sum actual frame durations (like Flutter does)
    const totalRenderTimeMs = this.frameMetrics.reduce((sum, frame) => sum + frame.frameDuration, 0);
    const totalRenderTimeSeconds = totalRenderTimeMs / 1000;
    
    return totalRenderTimeSeconds > 0 ? this.frameMetrics.length / totalRenderTimeSeconds : 0;
}

  get p95FrameTimeMs(): number {
    const frameTimes = this.frameMetrics.map(f => f.frameDuration);
    if (frameTimes.length === 0) return 0;
    const sorted = [...frameTimes].sort((a, b) => a - b);
    const idx = Math.ceil(sorted.length * 0.95) - 1;
    return sorted[Math.max(0, idx)];
  }

  // Retained for backwards compatibility
  get actualFpsTheoretical(): number {
    const mean = this.averageFrameTimeMs;
    return mean > 0 ? 1000 / mean : 0;
  }

  get droppedFramesPercent(): number {
    const budget = this.targetFrameTimeMs * 1.5; // Use Flutter's threshold for consistency
    const dropped = this.frameMetrics.filter(f => f.frameDuration > budget).length;
    return this.frameMetrics.length ? (dropped / this.frameMetrics.length) * 100 : 0;
  }

  get performanceGrade(): string {
    if (this.averageFrameTimeMs <= this.targetFrameTimeMs) return 'A (Excellent)';
    if (this.averageFrameTimeMs <= this.targetFrameTimeMs * 1.5) return 'B (Good)';
    if (this.averageFrameTimeMs <= this.targetFrameTimeMs * 2.0) return 'C (Fair)';
    return 'D (Poor)';
  }
}

/* ============================
 * Fixed Performance Monitor (now native-aware)
 * ============================ */

class PerformanceMonitor {
  private frameMetrics: FrameMetrics[] = [];
  private isMonitoring = false;
  private rafId: number | null = null;
  private lastFrameStart: number = 0;

  // Track scroll events for actual rendering measurement
  private scrollEventTimes: number[] = [];
  private lastScrollTime: number = 0;

  // Native mode state
  private useNativeProfiler = false;
  private monitorStartTime = 0; // baseline ms for synthesizing start times

  private getPerformanceTime(): number {
    return (typeof performance !== 'undefined' && performance.now)
      ? performance.now()
      : Date.now();
  }

  private measureFrame = (_timestamp: number): void => {
    if (!this.isMonitoring) return;

    const now = this.getPerformanceTime();

    if (this.lastFrameStart > 0) {
      // Calculate actual frame duration
      const frameDuration = now - this.lastFrameStart;

      // Heuristic partition for JS/UI work
      const jsWork = Math.min(frameDuration * 0.3, 5);
      const uiWork = Math.max(0, frameDuration - jsWork);

      this.frameMetrics.push({
        frameStartTime: this.lastFrameStart,
        frameDuration,
        jsFrameDuration: jsWork,
        uiFrameDuration: uiWork,
      });
    }

    this.lastFrameStart = now;
    this.rafId = requestAnimationFrame(this.measureFrame);
  };

  onScrollEvent = (_offsetY: number): void => {
    if (!this.isMonitoring) return;
    const now = this.getPerformanceTime();
    this.scrollEventTimes.push(now);
    this.lastScrollTime = now;
  };

  async startMonitoring(): Promise<void> {
    if (this.isMonitoring) return;
    this.isMonitoring = true;
    this.frameMetrics = [];
    this.scrollEventTimes = [];
    this.lastFrameStart = 0;
    this.lastScrollTime = 0;
    this.monitorStartTime = this.getPerformanceTime();

    this.useNativeProfiler = PlatformInfo.hasNativeFrameProfiler;

    if (this.useNativeProfiler && FrameProfiler) {
      try {
        await FrameProfiler.startProfiling();
      } catch (err) {
        // Fall back to JS profiling
        this.useNativeProfiler = false;
        this.rafId = requestAnimationFrame(this.measureFrame);
      }
    } else {
      // Pure JS path
      this.rafId = requestAnimationFrame(this.measureFrame);
    }
  }

  async stopMonitoring(): Promise<void> {
    if (!this.isMonitoring) return;
    this.isMonitoring = false;

    if (this.useNativeProfiler && FrameProfiler) {
      try {
        const nativeDurations = await FrameProfiler.stopProfiling(); // ms per frame
        // Synthesize frame metrics with monotonically increasing start times
        let t = this.monitorStartTime;
        for (const d of nativeDurations) {
          const frameDuration = Math.max(0, d);
          const jsWork = Math.min(frameDuration * 0.3, 5);
          const uiWork = Math.max(0, frameDuration - jsWork);
          this.frameMetrics.push({
            frameStartTime: t,
            frameDuration,
            jsFrameDuration: jsWork,
            uiFrameDuration: uiWork,
          });
          t += frameDuration;
        }
      } catch (err) {
        // If native stop failed, keep any RAF data we already collected
      }
    }

    // Stop RAF if running
    if (this.rafId && typeof cancelAnimationFrame !== 'undefined') {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
  }

  getResults(): { frameMetrics: FrameMetrics[]; scrollEventCount: number } {
    return {
      frameMetrics: [...this.frameMetrics],
      scrollEventCount: this.scrollEventTimes.length,
    };
  }

  getScrollFrameMetrics(): FrameMetrics[] {
    if (this.scrollEventTimes.length === 0) return this.frameMetrics;
    const scrollStart = Math.min(...this.scrollEventTimes);
    const scrollEnd = Math.max(...this.scrollEventTimes);
    return this.frameMetrics.filter(frame =>
      frame.frameStartTime >= scrollStart - 100 &&
      frame.frameStartTime <= scrollEnd + 100
    );
  }
}

/* ============================
 * Memory Monitor (native-first, graceful fallback)
 * ============================ */

class MemoryMonitor {
  private baselineMemoryMB = 0;

  async recordBaseline(): Promise<void> {
    try {
      if (PlatformInfo.hasNativeMemoryProfiler && MemoryProfiler) {
        const info = await MemoryProfiler.getCurrentMemoryUsage();
        this.baselineMemoryMB = info.totalPSS / (1024 * 1024);
        emit('info', `Platform: ${PlatformInfo.platformName} - Baseline (native PSS): ${this.baselineMemoryMB.toFixed(2)}MB`);
      } else if (PlatformInfo.supportsWebMemory) {
        this.baselineMemoryMB = (global as any).performance.memory.usedJSHeapSize / (1024 * 1024);
        emit('info', `Platform: ${PlatformInfo.platformName} - Baseline (web JS heap): ${this.baselineMemoryMB.toFixed(2)}MB`);
      } else {
        emit('info', `Platform: ${PlatformInfo.platformName} - Memory profiling not available`);
      }
    } catch (e) {
      emit('warn', 'Memory baseline capture failed:', String(e));
    }
  }

  async getCurrentDeltaMB(): Promise<number> {
    try {
      if (PlatformInfo.hasNativeMemoryProfiler && MemoryProfiler) {
        const info = await MemoryProfiler.getCurrentMemoryUsage();
        const currentMB = info.totalPSS / (1024 * 1024);
        return currentMB - this.baselineMemoryMB;
      }
      if (PlatformInfo.supportsWebMemory) {
        const currentMB = (global as any).performance.memory.usedJSHeapSize / (1024 * 1024);
        return currentMB - this.baselineMemoryMB;
      }
    } catch (e) {
      emit('warn', 'Memory delta capture failed:', String(e));
    }
    return 0;
  }
}

/* ============================
 * Stats Utils
 * ============================ */

const calculateMean = (values: number[]): number =>
  values.length ? values.reduce((a, b) => a + b, 0) / values.length : 0;

const calculateStdDev = (values: number[]): number => {
  if (values.length < 2) return 0;
  const mean = calculateMean(values);
  const variance = values.reduce((sum, v) => sum + Math.pow(v - mean, 2), 0) / values.length;
  return Math.sqrt(variance);
};

// <<< fixed: percentage formatter with higher precision default
const fmtPct = (value: number, decimals = 3) => `${value.toFixed(decimals)}%`;

/* ============================
 * Android-optimized props
 * ============================ */

const ANDROID_LIST_PROPS = Platform.select({
  android: {
    windowSize: 7,
    maxToRenderPerBatch: 12,
    updateCellsBatchingPeriod: 16, // ~1 frame @60Hz
    initialNumToRender: 10,
  },
  default: {
    windowSize: 10,
    maxToRenderPerBatch: 20,
    updateCellsBatchingPeriod: 50,
    initialNumToRender: 15,
  },
});

/* ============================
 * Memoized Row Component
 * ============================ */

const ListItemRow: React.FC<{ item: ListItem; iteration: number; iterations: number }> = memo(
  ({ item, iteration, iterations }) => {
    return (
      <View style={styles.itemContainer}>
        <View
          style={[
            styles.avatar,
            {
              backgroundColor: `rgb(${(item.index * 50) % 256}, ${(item.index * 80) % 256}, ${
                (item.index * 120) % 256
              })`,
            },
          ]}
        >
          <Text style={styles.avatarText}>{item.index % 100}</Text>
        </View>
        <View style={styles.itemContent}>
          <Text style={styles.itemTitle}>Benchmark Item {item.index}</Text>
          <Text style={styles.itemSubtitle}>
            Iteration {Math.min(iteration + 1, iterations)}/{iterations}
          </Text>
        </View>
      </View>
    );
  }
);

/* Lightweight cell renderer (helps on Android) */
const CellRendererComponent = memo((props: any) => {
  const { children, style, ...rest } = props;
  return (
    <View {...rest} style={style} collapsable>
      {children}
    </View>
  );
});

/* ============================
 * Main Component (old logic + native grace + release logs)
 * ============================ */

const ListRenderBenchmarkScreen: React.FC<BenchmarkProps> = ({
  itemCount = 100,
  iterations = 3,
  benchmarkType = BenchmarkType.SCROLL_PERFORMANCE,
  onComplete = () => {},
}) => {
  const [currentIteration, setCurrentIteration] = useState<number>(0);
  const [benchmarkComplete, setBenchmarkComplete] = useState<boolean>(false);
  const [results, setResults] = useState<BenchmarkResult[]>([]);

  const flatListRef = useRef<FlatList<ListItem>>(null);
  const performanceMonitor = useRef<PerformanceMonitor>(new PerformanceMonitor()).current;
  const memoryMonitor = useRef<MemoryMonitor>(new MemoryMonitor()).current;

  // Animation and control refs
  const scrollAnimationRef = useRef<Animated.Value>(new Animated.Value(0)).current;
  const runningRef = useRef(false);
  const completedRef = useRef(false);
  const cancelledRef = useRef(false);
  const timeoutsRef = useRef<Set<number>>(new Set());

  // Layout and scroll tracking
  const listHeightRef = useRef(0);
  const maxScrollOffsetRef = useRef(0);
  const scrollStartTimeRef = useRef(0);
  const scrollEndTimeRef = useRef(0);

  // <<< fixed: display detection
  const displayInfoRef = useRef<DisplayInfo>({
    refreshRate: 60,
    targetFrameTime: 1000 / 60,
    maxRefreshRate: 60,
    supportsHighRefreshRate: false,
  });

  const addTimeout = (ms: number, fn: () => void) => {
    const id = setTimeout(() => {
      timeoutsRef.current.delete(id as any);
      fn();
    }, ms) as unknown as number;
    timeoutsRef.current.add(id);
    return id;
  };

  const getPerformanceTime = () =>
    (typeof performance !== 'undefined' && performance.now)
      ? performance.now()
      : Date.now();

  // <<< fixed: detect refresh rate if native provides it
  const detectDisplayInfo = useCallback(async () => {
    try {
      if (FrameProfiler?.getDisplayRefreshRate) {
        const info = await FrameProfiler.getDisplayRefreshRate();
        if (info?.refreshRate) {
          displayInfoRef.current = {
            ...displayInfoRef.current,
            refreshRate: info.refreshRate,
            targetFrameTime: 1000 / info.refreshRate,
          };
        }
      } else if (FrameProfiler?.getDisplayCapabilities) {
        const info = await FrameProfiler.getDisplayCapabilities();
        if (info?.refreshRate) {
          displayInfoRef.current = {
            ...displayInfoRef.current,
            refreshRate: info.refreshRate,
            targetFrameTime: 1000 / info.refreshRate,
          };
        }
      }
    } catch (e) {
      // ignore and keep defaults
    }
  }, []);

  /* ============================
   * Smooth Animation Scroll (Match Flutter)
   * ============================ */

  const performSmoothScroll = useCallback(async (): Promise<number> => {
    if (!flatListRef.current) return 0;

    const totalScrollDistance = (itemCount - 1) * ROW_HEIGHT;
    maxScrollOffsetRef.current = totalScrollDistance;

    // Match Flutter's scroll behavior exactly
    const scrollSpeed = PlatformInfo.isMobile ? 500.0 : 800.0; // px/s
    const scrollDurationMs = (totalScrollDistance / scrollSpeed) * 1000;

    return new Promise<number>((resolve) => {
      const scrollStart = getPerformanceTime();
      scrollStartTimeRef.current = scrollStart;

      const animation = Animated.timing(scrollAnimationRef, {
        toValue: totalScrollDistance,
        duration: scrollDurationMs,
        easing: Easing.linear,
        useNativeDriver: false,
      });

      const listenerId = scrollAnimationRef.addListener(({ value }) => {
        flatListRef.current?.scrollToOffset({ offset: value, animated: false });
        performanceMonitor.onScrollEvent(value);
      });

      animation.start(({ finished }) => {
        scrollAnimationRef.removeListener(listenerId);
        scrollEndTimeRef.current = getPerformanceTime();

        if (finished) {
          const returnAnimation = Animated.timing(scrollAnimationRef, {
            toValue: 0,
            duration: 500,
            easing: Easing.out(Easing.ease),
            useNativeDriver: false,
          });

          const returnListenerId = scrollAnimationRef.addListener(({ value }) => {
            flatListRef.current?.scrollToOffset({ offset: value, animated: false });
          });

          returnAnimation.start(() => {
            scrollAnimationRef.removeListener(returnListenerId);
            const actualScrollDuration = scrollEndTimeRef.current - scrollStartTimeRef.current;
            resolve(actualScrollDuration);
          });
        } else {
          const actualScrollDuration = scrollEndTimeRef.current - scrollStartTimeRef.current;
          resolve(actualScrollDuration);
        }
      });
    });
  }, [itemCount, scrollAnimationRef, performanceMonitor]);

  /* ============================
   * Proper TTFP Measurement
   * ============================ */

  const measureTimeToFirstFrame = useCallback((): Promise<number> => {
    const startTime = getPerformanceTime();
    return new Promise((resolve) => {
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          const ttfp = getPerformanceTime() - startTime;
          resolve(ttfp);
        });
      });
    });
  }, []);

  /* ============================
   * Lifecycle and Iteration Control
   * ============================ */

  useEffect(() => {
    if (runningRef.current) return;
    runningRef.current = true;
    cancelledRef.current = false;

    detectDisplayInfo().finally(() => {
      // Native-first baseline; graceful fallback
      memoryMonitor.recordBaseline().finally(() => {
        addTimeout(100, () => runIteration(0));
      });
    });

    return () => {
      cancelledRef.current = true;
      performanceMonitor.stopMonitoring();
      timeoutsRef.current.forEach(id => clearTimeout(id as any));
      timeoutsRef.current.clear();
      runningRef.current = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const runIteration = useCallback((iterationNumber: number): void => {
    if (cancelledRef.current) return;
    if (iterationNumber >= iterations) {
      completeBenchmark();
      return;
    }

    emit('info', `Starting iteration ${iterationNumber + 1}/${iterations}`);

    // Reset scroll position
    scrollAnimationRef.setValue(0);
    flatListRef.current?.scrollToOffset({ offset: 0, animated: false });

    // Start performance monitoring (native if available)
    performanceMonitor.stopMonitoring();
    performanceMonitor.startMonitoring().then(() => {
      // Measure TTFP
      const ttfpPromise = measureTimeToFirstFrame();

      InteractionManager.runAfterInteractions(() => {
        if (cancelledRef.current) return;

        switch (benchmarkType) {
          case BenchmarkType.STATIC_RENDER:
          case BenchmarkType.MEMORY_USAGE:
            addTimeout(1000, () => {
              if (cancelledRef.current) return;
              ttfpPromise.then(ttfp => {
                recordIteration(ttfp, 0, iterationNumber);
                nextIteration(iterationNumber);
              });
            });
            break;

          case BenchmarkType.SCROLL_PERFORMANCE:
            addTimeout(300, async () => {
              if (cancelledRef.current) return;

              try {
                const scrollDuration = await performSmoothScroll();
                addTimeout(200, () => {
                  ttfpPromise.then(ttfp => {
                    recordIteration(ttfp, scrollDuration, iterationNumber);
                    nextIteration(iterationNumber);
                  });
                });
              } catch (error) {
                emit('warn', 'Scroll benchmark error:', String(error));
                ttfpPromise.then(ttfp => {
                  recordIteration(ttfp, 0, iterationNumber);
                  nextIteration(iterationNumber);
                });
              }
            });
            break;
        }
      });
    });
  }, [iterations, benchmarkType, measureTimeToFirstFrame, performSmoothScroll]);

  const recordIteration = (
    timeToFirstFrame: number,
    scrollDuration: number,
    iterationNumber: number
  ): void => {
    if (cancelledRef.current) return;

    performanceMonitor.stopMonitoring().then(async () => {
      const { frameMetrics } = performanceMonitor.getResults();

      const relevantFrames = benchmarkType === BenchmarkType.SCROLL_PERFORMANCE
        ? performanceMonitor.getScrollFrameMetrics()
        : frameMetrics;

      const memoryDelta = await memoryMonitor.getCurrentDeltaMB();

      const refresh = displayInfoRef.current.refreshRate || 60;
      const budgetMs = 1000 / refresh;

      const result = new BenchmarkResult({
        timeToFirstFrame,
        frameMetrics: relevantFrames,
        memoryDeltaMB: memoryDelta,
        timestamp: new Date(),
        itemCount,
        platform: PlatformInfo.platformName,
        targetFrameTimeMs: budgetMs,
        scrollDistance: maxScrollOffsetRef.current,
        scrollDuration,
        refreshRateHz: refresh, // <<< fixed
      });

      setResults(prev => {
        const newResults = [...prev, result];
        emit('info', `Iteration ${iterationNumber + 1} complete: ${result.averageFrameTimeMs.toFixed(2)}ms avg frame time, ${result.frameMetrics.length} frames analyzed`);
        return newResults;
      });

      setCurrentIteration(iterationNumber + 1);
    });
  };

  const nextIteration = (iterationNumber: number): void => {
    if (cancelledRef.current) return;
    addTimeout(500, () => {
      const next = iterationNumber + 1;
      if (next < iterations) runIteration(next);
      else completeBenchmark();
    });
  };

  const completeBenchmark = (): void => {
    if (completedRef.current || cancelledRef.current) return;
    completedRef.current = true;
    emit('info', 'Benchmark completed! Generating report...');
    setBenchmarkComplete(true);
    addTimeout(100, () => generateScientificReport());
  };

  /* ============================
   * Scientific Report Generation
   * ============================ */

  // <<< fixed: ASCII-safe and pretty (UTF-8) variants
  const makeAsciiReport = (
    avgAll: number,
    p95All: number,
    avgFPSClamped: number,
    theoreticalFps: number,
    droppedPercent: number,
    perfGrade: string,
    meanTTFP: number,
    stdTTFP: number,
    meanMemMB: number | null,
    stdMemMB: number | null,
    memPerItemKB1000: number | null,
    covFrameTimePct: number,
    totalFrames: number,
    avgScrollMs: number,
    scrollDistancePx: number,
    refresh: number,
  ) => {
    return [
      '[Benchmark] REACT NATIVE SCIENTIFIC BENCHMARK (NATIVE-AWARE)',
      `Timestamp: ${new Date().toISOString()}`,
      `Platform: ${PlatformInfo.platformName} (${PlatformInfo.performanceProfile})`,
      `Config: items=${itemCount}, iterations=${iterations}, type=${benchmarkType}`,
      `Target: ${theoreticalFps.toFixed(0)} FPS (${(1000 / theoreticalFps).toFixed(2)} ms)`,
      '',
      'FRAME PERFORMANCE (aggregated)',
      `- Avg Frame Time: ${avgAll.toFixed(2)} ms`,
      `- P95 Frame Time: ${p95All.toFixed(2)} ms`,
      `- Actual FPS (clamped): ${avgFPSClamped.toFixed(2)}`,
      `- Theoretical FPS (panel): ${theoreticalFps.toFixed(0)}`,
      `- Dropped Frames: ${fmtPct(droppedPercent)}`,
      `- Performance Grade: ${perfGrade}`,
      '',
      'INITIAL RENDER',
      `- Time to First Frame: ${meanTTFP.toFixed(2)} ± ${stdTTFP.toFixed(2)} ms`,
      '',
      'MEMORY',
      meanMemMB !== null
        ? `- Memory Delta: ${meanMemMB.toFixed(2)} ± ${stdMemMB!.toFixed(2)} MB`
        : `- Memory Delta: Not available on ${PlatformInfo.platformName}`,
      meanMemMB !== null
        ? `- Memory per Item: ${memPerItemKB1000!.toFixed(2)} KB/item (1000 B/KB)`
        : `- Memory per Item: N/A`,
      '',
      'RELIABILITY',
      `- CoV (Frame Time): ${covFrameTimePct.toFixed(3)}%`,
      `- Total Frames Analyzed: ${totalFrames}`,
      `- Scroll Distance: ${scrollDistancePx.toFixed(0)} px`,
      `- Avg Scroll Duration: ${avgScrollMs.toFixed(0)} ms`,
      `- Panel Refresh: ${refresh} Hz`,
      '',
      'NOTES',
      '- Console/syslog output is ASCII-only to avoid mojibake.',
      '- A UTF-8 pretty report is written to file if RNFS is available.',
      ''
    ].join('\n');
  };

  const makePrettyReport = (
    avgAll: number,
    p95All: number,
    avgFPSClamped: number,
    theoreticalFps: number,
    droppedPercent: number,
    perfGrade: string,
    meanTTFP: number,
    stdTTFP: number,
    meanMemMB: number | null,
    stdMemMB: number | null,
    memPerItemKB1000: number | null,
    covFrameTimePct: number,
    totalFrames: number,
    avgScrollMs: number,
    scrollDistancePx: number,
    refresh: number,
    budgetMs: number,
    interpretation: string,
    platformNotes: string,
  ) => `\
🔬 REACT NATIVE SCIENTIFIC BENCHMARK REPORT (NATIVE-AWARE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Timestamp: ${new Date().toISOString()}
🔧 Platform: ${PlatformInfo.platformName} (${PlatformInfo.performanceProfile})
📊 Configuration: ${itemCount} items, ${iterations} iterations
🎯 Benchmark Type: ${benchmarkType}
⚡ Target Frame Time: ${budgetMs.toFixed(2)}ms (${theoreticalFps.toFixed(0)} FPS)

📈 FRAME PERFORMANCE (aggregated across all frames):
• Avg Frame Time: ${avgAll.toFixed(2)} ms
• P95 Frame Time: ${p95All.toFixed(2)} ms
• Actual FPS (clamped): ${avgFPSClamped.toFixed(2)}
• Theoretical FPS (panel): ${theoreticalFps.toFixed(0)}
• Dropped Frames: ${fmtPct(droppedPercent)}
• Performance Grade: ${perfGrade}

⏱️ INITIAL RENDER (per-iteration):
• Time to First Frame: ${meanTTFP.toFixed(2)} ± ${stdTTFP.toFixed(2)} ms

🧠 MEMORY IMPACT:
• ${meanMemMB !== null
  ? `Memory Delta: ${meanMemMB.toFixed(2)} ± ${stdMemMB!.toFixed(2)} MB`
  : `Memory Delta: Not available on ${PlatformInfo.platformName}`}
• ${meanMemMB !== null
  ? `Memory per Item: ${memPerItemKB1000!.toFixed(2)} KB/item (1000 B/KB)`
  : 'Memory per Item: N/A'}

📊 RELIABILITY:
• Coefficient of Variation (Frame Time): ${covFrameTimePct.toFixed(3)}%
• Total Frames Analyzed: ${totalFrames}
• Scroll Distance: ${scrollDistancePx.toFixed(0)} px
• Avg Scroll Duration: ${avgScrollMs.toFixed(0)} ms
• Panel Refresh: ${refresh} Hz

💡 INTERPRETATION:
${interpretation}

🔍 PLATFORM-SPECIFIC NOTES:
${platformNotes}

🔧 MEASUREMENT IMPROVEMENTS:
• Native frame profiler used when available; JS RAF fallback otherwise
• Memory profiling prefers native PSS; falls back to web JS heap
• Smooth animation scroll matching Flutter behavior
• Consistent dropped frame calculation (1.5× budget threshold)
• FPS is clamped to panel refresh to avoid >Hz illusions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`;

  const generateScientificReport = (): void => {
    setResults(currentResults => {
      if (!currentResults.length) return currentResults;

      const refresh = displayInfoRef.current.refreshRate || 60;
      const budget = 1000 / refresh; // <<< fixed: budget from detected panel

      const allFrames = currentResults.flatMap(r => r.frameMetrics.map(f => f.frameDuration));
      const avgAll = calculateMean(allFrames);
      const p95All = (() => {
        const sorted = [...allFrames].sort((a, b) => a - b);
        return sorted.length ? sorted[Math.max(0, Math.ceil(sorted.length * 0.95) - 1)] : 0;
      })();

      const totalScrollTime = currentResults.reduce((sum, r) => sum + r.scrollDuration, 0);
      const totalFrames = allFrames.length;
      const fpsFromDuration = totalScrollTime > 0 ? (totalFrames / (totalScrollTime / 1000)) : 0;
      const avgFPSClamped = Math.min(fpsFromDuration || (avgAll ? 1000 / avgAll : 0), refresh);  // <<< fixed clamp

      const droppedFrames = allFrames.filter(duration => duration > budget * 1.5).length;
      const droppedPercent = allFrames.length ? (droppedFrames / allFrames.length) * 100 : 0;

      const ttfpList = currentResults.map(r => r.timeToFirstFrame);
      const memList = currentResults.map(r => r.memoryDeltaMB);

      const meanTTFP = calculateMean(ttfpList);
      const stdTTFP = calculateStdDev(ttfpList);

      const meanMemMB = PlatformInfo.supportsMemoryProfiling ? calculateMean(memList) : null;
      const stdMemMB = PlatformInfo.supportsMemoryProfiling ? calculateStdDev(memList) : null;
      const memPerItemKB1000 =
        PlatformInfo.supportsMemoryProfiling && meanMemMB !== null
          ? (meanMemMB / itemCount) * 1000 // KB (1000)
          : null;

      // CoV across per-iteration average frame times (not across all frames)
      const perIterAverages = currentResults.map(r => r.averageFrameTimeMs);
      const covFrameTimePct =
        (calculateStdDev(perIterAverages) / Math.max(1e-6, calculateMean(perIterAverages))) * 100;

      const perfGrade = (() => {
        if (avgAll <= budget) return 'A (Excellent)';
        if (avgAll <= budget * 1.5) return 'B (Good)';
        if (avgAll <= budget * 2.0) return 'C (Fair)';
        return 'D (Poor)';
      })();

      const interpretation = generateInterpretation(avgAll, benchmarkType, budget);
      const platformNotes = generatePlatformNotes();

      // ASCII-safe console/syslog report
      const asciiReport = makeAsciiReport(
        avgAll, p95All, avgFPSClamped, refresh,
        droppedPercent, perfGrade, meanTTFP, stdTTFP,
        meanMemMB, stdMemMB, memPerItemKB1000,
        covFrameTimePct, totalFrames,
        calculateMean(currentResults.map(r => r.scrollDuration)),
        maxScrollOffsetRef.current,
        refresh
      );

      emit('info', asciiReport);

      // Pretty UTF-8 file report
      const prettyReport = makePrettyReport(
        avgAll, p95All, avgFPSClamped, refresh,
        droppedPercent, perfGrade, meanTTFP, stdTTFP,
        meanMemMB, stdMemMB, memPerItemKB1000,
        covFrameTimePct, totalFrames,
        calculateMean(currentResults.map(r => r.scrollDuration)),
        maxScrollOffsetRef.current,
        refresh, budget,
        interpretation, platformNotes
      );

      const path = getBenchmarkLogFilePath?.();
      if (path) {
        // write a header so users can find it
        emit('info', `Benchmark log file (UTF-8): ${path}`);
        fileSink?.append(`\n${prettyReport}\n`).catch(() => {});
      }

      try {
        Alert.alert('Benchmark Complete', 'ASCII report in console, UTF-8 report saved to file (if available).');
      } catch {}
      onComplete(currentResults);
      return currentResults;
    });
  };

  const generateInterpretation = (avgFrameTimeAll: number, type: BenchmarkType, budgetMs: number): string => {
    let base: string;
    if (avgFrameTimeAll <= budgetMs) base = `✅ Excellent performance – meeting ${(1000 / budgetMs).toFixed(0)} FPS target`;
    else if (avgFrameTimeAll <= budgetMs * 1.5) base = '⚠️ Good performance – occasional frame drops below target';
    else if (avgFrameTimeAll <= budgetMs * 2.0) base = '⚠️ Fair performance – noticeable frame drops';
    else base = '❌ Poor performance – significant frame drops detected';

    let note: string;
    switch (type) {
      case BenchmarkType.STATIC_RENDER:
        note = 'Static rendering performance with proper frame measurement.';
        break;
      case BenchmarkType.SCROLL_PERFORMANCE:
        note = 'Scroll performance with smooth animation matching Flutter behavior. Measures actual rendering work during scrolling.';
        break;
      case BenchmarkType.MEMORY_USAGE:
        note = PlatformInfo.supportsMemoryProfiling
          ? 'Memory delta uses native PSS on mobile or JS heap on web.'
          : `Memory profiling unavailable on this platform.`;
        break;
    }
    return `${base}\n${note}`;
  };

  const generatePlatformNotes = (): string => {
    const notes: string[] = [];
    if (Platform.OS === 'android') {
      notes.push('• Android: Bridge overhead and ART VM may impact results');
      notes.push('• Consider testing on different API levels and hardware tiers');
    } else if (Platform.OS === 'ios') {
      notes.push('• iOS: Optimized for Metal rendering and ARC memory management');
      notes.push('• Results should be consistent across iOS device generations');
    } else if (PlatformInfo.isWeb) {
      notes.push('• Web: Results vary by browser and JS engine');
    }
    notes.push('• Native profilers are used when available; otherwise JS RAF timing is used');
    notes.push('• Scroll behavior matches Flutter implementation for fair comparison');
    notes.push('• Frame measurements focus on rendering work during scrolling');
    return notes.join('\n');
  };

  /* ============================
   * UI Rendering
   * ============================ */

  const handleScroll = useCallback((event: NativeSyntheticEvent<NativeScrollEvent>) => {
    const offsetY = event.nativeEvent.contentOffset.y;
    performanceMonitor.onScrollEvent(offsetY);
  }, [performanceMonitor]);

  const handleLayout = useCallback((event: any) => {
    listHeightRef.current = event.nativeEvent.layout.height;
  }, []);

  // Stable data & renderer so FlatList can efficiently recycle
  const data: ListItem[] = React.useMemo(
    () => Array.from({ length: itemCount }, (_, index) => ({ key: index, index })),
    [itemCount]
  );

  const renderItem = React.useCallback<ListRenderItem<ListItem>>(
    ({ item }) => <ListItemRow item={item} iteration={currentIteration} iterations={iterations} />,
    [currentIteration, iterations]
  );

  return (
    <View style={styles.container}>
      <View style={[styles.header, { backgroundColor: benchmarkComplete ? '#4CAF50' : '#2196F3' }]}>
        <Text style={styles.headerTitle}>Scientific List Benchmark (Native-aware)</Text>
        <Text style={styles.headerSubtitle}>
          React Native – {PlatformInfo.platformName} • Target: {(displayInfoRef.current.targetFrameTime).toFixed(1)} ms
        </Text>
      </View>

      {!benchmarkComplete && (
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { width: `${iterations > 0 ? (currentIteration / iterations) * 100 : 0}%` }]} />
        </View>
      )}

      {!benchmarkComplete && (
        <View style={styles.statusContainer}>
          <Text style={styles.statusText}>
            Running iteration {Math.min(currentIteration + 1, iterations)} of {iterations}...
          </Text>
          <Text style={styles.configText}>
            {itemCount} items • {benchmarkType} • Native-first measurement
          </Text>
        </View>
      )}

      <FlatList<ListItem>
        ref={flatListRef}
        data={data}
        renderItem={renderItem}
        keyExtractor={(item) => item.key.toString()}
        style={styles.list}

        // Android-optimized virtualization
        removeClippedSubviews={Platform.OS === 'android'}
        windowSize={(ANDROID_LIST_PROPS?.windowSize as number) ?? 10}
        maxToRenderPerBatch={(ANDROID_LIST_PROPS?.maxToRenderPerBatch as number) ?? 20}
        updateCellsBatchingPeriod={(ANDROID_LIST_PROPS?.updateCellsBatchingPeriod as number) ?? 50}
        initialNumToRender={(ANDROID_LIST_PROPS?.initialNumToRender as number) ?? 15}

        // Consistent layout for measurement
        getItemLayout={(_, index) => ({
          length: ROW_HEIGHT,
          offset: ROW_HEIGHT * index,
          index
        })}

        // Lightweight cell renderer (helps reduce Android overhead)
        CellRendererComponent={CellRendererComponent}

        onLayout={handleLayout}
        onScroll={handleScroll}
        scrollEventThrottle={16}

        // Disable scroll indicators for consistent behavior
        showsVerticalScrollIndicator={false}
        showsHorizontalScrollIndicator={false}
      />

      {benchmarkComplete && (
        <View style={styles.completeContainer}>
          <Text style={styles.completeText}>
            ✅ Benchmark Complete! Check console/logs for ASCII report; pretty UTF‑8 report saved to file (if RNFS installed).
          </Text>
          <Text style={styles.fixedText}>
            🔧 Native profilers used when available; JS fallback retained. FPS clamped to panel refresh.
          </Text>
        </View>
      )}
    </View>
  );
};

/* ============================
 * Styles
 * ============================ */

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5'
  },
  header: {
    paddingTop: Platform.OS === 'ios' ? 50 : 25,
    paddingBottom: 15,
    paddingHorizontal: 16,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white'
  },
  headerSubtitle: {
    fontSize: 13,
    color: 'rgba(255, 255, 255, 0.9)',
    marginTop: 4,
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  progressContainer: {
    height: 3,
    backgroundColor: 'rgba(0, 0, 0, 0.1)'
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#4CAF50',
  },
  statusContainer: {
    padding: 16,
    backgroundColor: 'white',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0, 0, 0, 0.08)',
    elevation: 1,
  },
  statusText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333'
  },
  configText: {
    fontSize: 13,
    color: '#666',
    marginTop: 4,
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  list: {
    flex: 1
  },
  itemContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    marginHorizontal: 8,
    marginVertical: 4,
    padding: 12,
    borderRadius: 8,

    // Android: flatter cards (avoid borders & heavy shadows)
    borderWidth: Platform.OS === 'android' ? 0 : 1,
    borderColor: Platform.OS === 'android' ? 'transparent' : 'rgba(33, 150, 243, 0.2)',

    // Shadow on iOS, light elevation on Android
    elevation: Platform.OS === 'android' ? 1 : 2,
    shadowColor: Platform.OS === 'ios' ? '#000' : undefined,
    shadowOffset: Platform.OS === 'ios' ? { width: 0, height: 1 } : undefined,
    shadowOpacity: Platform.OS === 'ios' ? 0.08 : undefined,
    shadowRadius: Platform.OS === 'ios' ? 3 : undefined,

    // Ensure consistent height
    minHeight: ROW_HEIGHT - 8, // account for margins
  },
  avatar: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',

    // Flat on Android, subtle shadow on iOS
    elevation: Platform.OS === 'android' ? 0 : 3,
    shadowColor: Platform.OS === 'ios' ? '#000' : undefined,
    shadowOffset: Platform.OS === 'ios' ? { width: 0, height: 2 } : undefined,
    shadowOpacity: Platform.OS === 'ios' ? 0.15 : undefined,
    shadowRadius: Platform.OS === 'ios' ? 2 : undefined,
  },
  avatarText: {
    color: 'white',
    fontWeight: 'bold',
    fontSize: 14,
    textShadowColor: Platform.OS === 'ios' ? 'rgba(0, 0, 0, 0.3)' : 'transparent',
    textShadowOffset: Platform.OS === 'ios' ? { width: 0, height: 1 } : { width: 0, height: 0 },
    textShadowRadius: Platform.OS === 'ios' ? 1 : 0,
  },
  itemContent: {
    flex: 1,
    marginLeft: 12,
    justifyContent: 'center',
  },
  itemTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#333',
    marginBottom: 2,
  },
  itemSubtitle: {
    fontSize: 12,
    color: '#666',
    fontFamily: Platform.OS === 'ios' ? 'Menlo' : 'monospace',
  },
  completeContainer: {
    padding: 16,
    backgroundColor: 'rgba(76, 175, 80, 0.05)',
    borderTopWidth: 2,
    borderTopColor: '#4CAF50',
  },
  completeText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#4CAF50',
    textAlign: 'center',
    marginBottom: 4,
  },
  fixedText: {
    fontSize: 12,
    color: '#2E7D32',
    textAlign: 'center',
    fontStyle: 'italic',
  },
});

export default ListRenderBenchmarkScreen;
export { BenchmarkType, BenchmarkResult }