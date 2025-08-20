// (Your imports remain unchanged)
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'benchmark_history_screen.dart';

// ⬇️ Helpers
String _toAscii(String s) => s.replaceAll(RegExp(r'[^\x20-\x7E]'), '');

String _typeLabel(BenchmarkType t) {
  switch (t) {
    case BenchmarkType.staticRender:
      return 'Static Render';
    case BenchmarkType.scrollPerformance:
      return 'Scroll Performance';
    case BenchmarkType.memoryUsage:
      return 'Memory Usage';
  }
}

void releaseLog(String message, {String level = 'INFO'}) {
  // ASCII for stdout (so CI/log collectors won't choke on emojis)
  final ascii = _toAscii(message);
  // ignore: avoid_print
  print(ascii);
  // Full Unicode for developer log (nice in IDE / Xcode / Android Studio)
  log(message, name: 'Benchmark/$level');
}

class ListRenderBenchmarkScreen extends StatefulWidget {
  final int itemCount;
  final int iterations;
  final BenchmarkType benchmarkType;

  const ListRenderBenchmarkScreen({
    super.key,
    required this.itemCount,
    this.iterations = 3,
    this.benchmarkType = BenchmarkType.staticRender,
  });

  @override
  State<ListRenderBenchmarkScreen> createState() =>
      _ListRenderBenchmarkScreenState();
}

enum BenchmarkType {
  staticRender, // Just measure list building and initial render
  scrollPerformance, // Measure scroll performance separately
  memoryUsage, // Focus on memory consumption
}

class PlatformInfo {
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get supportsMemoryProfiling => isMobile && !kIsWeb;

  static double get expectedRefreshRate {
    // Platform-specific refresh rate expectations
    if (kIsWeb) return 60.0; // Most browsers cap at 60fps
    if (Platform.isAndroid) return 60.0; // 90/120Hz exist but 60 is baseline
    if (Platform.isIOS) return 60.0; // iPhone: 60Hz, iPad Pro: 120Hz
    return 60.0; // Desktop default
  }

  static double get targetFrameTimeMs => 1000.0 / expectedRefreshRate;

  static String get performanceProfile {
    if (kIsWeb) return 'Web (JS Engine + Browser rendering)';
    if (Platform.isIOS) return 'iOS (Metal rendering, ARC memory)';
    if (Platform.isAndroid) return 'Android (Vulkan/OpenGL, ART VM)';
    if (isDesktop) return 'Desktop (Native performance)';
    return 'Unknown platform';
  }
}

class BenchmarkResult {
  final Duration timeToFirstFrame;
  final List<double> frameTimesMs;
  final double memoryDeltaMB;
  final DateTime timestamp;
  final int itemCount;
  final String platform;
  final double targetFrameTimeMs;

  final int scrollDurationMs; // actual measured scroll time for this run
  final double scrollDistancePx; // total distance scrolled (logical px)
  final double panelRefreshHz; // e.g., 60

  BenchmarkResult({
    required this.timeToFirstFrame,
    required this.frameTimesMs,
    required this.memoryDeltaMB,
    required this.timestamp,
    required this.itemCount,
    required this.platform,
    required this.targetFrameTimeMs,
    this.scrollDurationMs = 0,
    this.scrollDistancePx = 0.0,
    this.panelRefreshHz = 60.0,
  });

  double get actualFpsUnclamped {
    if (frameTimesMs.isEmpty) return 0;
    final totalMs = frameTimesMs.reduce((a, b) => a + b);
    if (totalMs <= 0) return 0;
    return frameTimesMs.length / (totalMs / 1000.0);
  }

  double get actualFps => actualFpsUnclamped;
  double get actualFpsClamped => math.min(actualFpsUnclamped, panelRefreshHz);

  double get averageFrameTimeMs =>
      frameTimesMs.isEmpty ? 0 : frameTimesMs.reduce((a, b) => a + b) / frameTimesMs.length;

  double get p95FrameTimeMs {
    if (frameTimesMs.isEmpty) return 0;
    final sorted = List<double>.from(frameTimesMs)..sort();
    final index = (sorted.length * 0.95).ceil() - 1;
    return sorted[math.max(0, index)];
  }

  // Per-result jank stats (kept for possible UI/CSV)
  double get droppedFramesPercentStrict {
    final dropped = frameTimesMs.where((t) => t > targetFrameTimeMs).length;
    return frameTimesMs.isEmpty ? 0 : (dropped / frameTimesMs.length) * 100;
  }

  double get jankyFramesPercent15x {
    final janky = frameTimesMs.where((t) => t > targetFrameTimeMs * 1.5).length;
    return frameTimesMs.isEmpty ? 0 : (janky / frameTimesMs.length) * 100;
  }

  String get performanceGrade {
    if (averageFrameTimeMs <= targetFrameTimeMs) return 'A (Excellent)';
    if (averageFrameTimeMs <= targetFrameTimeMs * 1.5) return 'B (Good)';
    if (averageFrameTimeMs <= targetFrameTimeMs * 2.0) return 'C (Fair)';
    return 'D (Poor)';
  }
}

class _ListRenderBenchmarkScreenState extends State<ListRenderBenchmarkScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<FrameTiming> _frameTimings = [];
  final List<BenchmarkResult> _results = [];

  int _currentIteration = 0;
  int _baselineMemoryMB = 0;
  Stopwatch? _renderStopwatch;
  bool _benchmarkComplete = false;
  bool _timingsActive = false;

  @override
  void initState() {
    super.initState();
    _recordBaselineMemory();
    _startBenchmark();
  }

  void _recordBaselineMemory() {
    if (PlatformInfo.supportsMemoryProfiling) {
      _baselineMemoryMB = (ProcessInfo.currentRss / (1024 * 1024)).round();
      releaseLog('📊 Platform: ${PlatformInfo.platformName} - Baseline memory: ${_baselineMemoryMB}MB');
    } else {
      releaseLog('📊 Platform: ${PlatformInfo.platformName} - Memory profiling not available');
    }
  }

  void _startBenchmark() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _runIteration();
  }

  void _runIteration() {
    if (_currentIteration >= widget.iterations) {
      _completeBenchmark();
      return;
    }

    _frameTimings.clear();
    _renderStopwatch = Stopwatch()..start();

    if (!_timingsActive) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      _timingsActive = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final timeToFirstFrame = _renderStopwatch!.elapsed;
        _renderStopwatch!.stop();

        switch (widget.benchmarkType) {
          case BenchmarkType.staticRender:
          case BenchmarkType.memoryUsage:
            await Future.delayed(const Duration(milliseconds: 1000));
            _recordIteration(timeToFirstFrame);
            _nextIteration();
            break;

          case BenchmarkType.scrollPerformance:
            await Future.delayed(const Duration(milliseconds: 300));
            _performScrollBenchmark(timeToFirstFrame);
            break;
        }
      } catch (e, st) {
        releaseLog('Iteration error: $e\n$st', level: 'ERROR');
        // Safety: ensure we don't leave the timing callback active forever
        if (_timingsActive) {
          SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
          _timingsActive = false;
        }
        // Attempt to continue to next iteration
        _nextIteration();
      }
    });

    setState(() {});
  }

  void _nextIteration() {
    _currentIteration++;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _runIteration();
    });
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    _frameTimings.addAll(timings);
  }

  Future<void> _performScrollBenchmark(Duration timeToFirstFrame) async {
    if (!mounted || !_scrollController.hasClients) {
      _recordIteration(timeToFirstFrame);
      _nextIteration();
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll == 0) {
      _recordIteration(timeToFirstFrame);
      _nextIteration();
      return;
    }

    // Choose speed similar to other platforms
    final double scrollSpeed = kIsWeb
        ? 300.0
        : (PlatformInfo.isMobile ? 500.0 : 800.0); // px/s

    // One-way forward duration
    final forwardDuration =
    Duration(milliseconds: (maxScroll / scrollSpeed * 1000).toInt());

    // 🔧 Ensure frame timings reflect ONLY the down-scroll window
    _frameTimings.clear();

    // Start measuring down-scroll only
    _renderStopwatch = Stopwatch()..start();
    try {
      await _scrollController.animateTo(
        maxScroll,
        duration: forwardDuration,
        curve: Curves.linear,
      );
    } catch (e, st) {
      releaseLog('Scroll benchmark error (down): $e\n$st', level: 'ERROR');
    }
    _renderStopwatch!.stop();

    // ✅ Record ONE-WAY distance/time and the frames captured during the down leg
    final oneWayDurationMs = _renderStopwatch!.elapsedMilliseconds;
    _recordIteration(
      timeToFirstFrame,
      scrollDurationMs: oneWayDurationMs,
      scrollDistancePx: maxScroll, // ONE-WAY ONLY
    );

    // Return to top for next iteration, but DO NOT measure or capture frames
    try {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e, st) {
      releaseLog('Scroll benchmark error (return): $e\n$st', level: 'ERROR');
    }

    // Proceed to next iteration
    _nextIteration();
  }

  void _recordIteration(
      Duration timeToFirstFrame, {
        int scrollDurationMs = 0,
        double scrollDistancePx = 0.0,
      }) {
    if (_timingsActive) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      _timingsActive = false;
    }

    final frameTimesMs =
    _frameTimings.map((t) => t.totalSpan.inMicroseconds / 1000.0).toList();

    final currentMemoryMB = PlatformInfo.supportsMemoryProfiling
        ? (ProcessInfo.currentRss / (1024 * 1024)).round()
        : _baselineMemoryMB;

    final memoryDelta = (currentMemoryMB - _baselineMemoryMB).toDouble();

    final result = BenchmarkResult(
      timeToFirstFrame: timeToFirstFrame,
      frameTimesMs: frameTimesMs,
      memoryDeltaMB: memoryDelta,
      timestamp: DateTime.now(),
      itemCount: widget.itemCount,
      platform: PlatformInfo.platformName,
      targetFrameTimeMs: PlatformInfo.targetFrameTimeMs,
      scrollDurationMs: scrollDurationMs,
      scrollDistancePx: scrollDistancePx,
      panelRefreshHz: PlatformInfo.expectedRefreshRate,
    );

    _results.add(result);
    releaseLog(
        'Iteration ${_currentIteration + 1} complete: '
            '${result.averageFrameTimeMs.toStringAsFixed(2)}ms avg, '
            '${result.frameTimesMs.length} frames');
  }

  void _completeBenchmark() {
    setState(() {
      _benchmarkComplete = true;
    });
    _generateScientificReport();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BenchmarkHistoryScreen(results: _results),
        ),
      );
    });
  }

  void _generateScientificReport() {
    if (_results.isEmpty) return;

    final avgFrameTimes =
    _results.map((r) => r.averageFrameTimeMs).toList(growable: false);
    final firstFrameTimes = _results
        .map((r) => r.timeToFirstFrame.inMilliseconds.toDouble())
        .toList(growable: false);
    final memoryUsages =
    _results.map((r) => r.memoryDeltaMB).toList(growable: false);

    // Aggregate across all recorded frames (for the down leg only in scroll benchmark)
    final allFrames = _results.expand((r) => r.frameTimesMs).toList();
    final totalFrames = allFrames.length;
    final meanFrameMsAll = _calculateMean(allFrames);

    // Scroll window timing (now one-way only)
    final totalScrollMs =
    _results.fold<int>(0, (s, r) => s + r.scrollDurationMs);
    final avgScrollMs =
    _calculateMean(_results.map((r) => r.scrollDurationMs.toDouble()).toList());
    final scrollDistancePx =
    _results.isNotEmpty ? _results.first.scrollDistancePx : 0.0;

    final panelHz = PlatformInfo.expectedRefreshRate;
    final budgetMs = PlatformInfo.targetFrameTimeMs;

    // FPS (prefer time-window based when scroll present; fallback preserved for non-scroll)
    final fpsUnclamped = totalScrollMs > 0
        ? (totalFrames / (totalScrollMs / 1000.0))
        : (meanFrameMsAll > 0 ? 1000.0 / meanFrameMsAll : 0.0);
    final fpsClamped = math.min(fpsUnclamped, panelHz);

    // Strict vs janky drops
    final droppedStrict =
        allFrames.where((t) => t > budgetMs).length; // missed vsync
    final janky15x = allFrames.where((t) => t > budgetMs * 1.5).length;
    final droppedPctStrict =
    totalFrames > 0 ? (droppedStrict / totalFrames) * 100.0 : 0.0;
    final jankyPct =
    totalFrames > 0 ? (janky15x / totalFrames) * 100.0 : 0.0;

    // P95 across all frames
    final p95All = () {
      if (allFrames.isEmpty) return 0.0;
      final sorted = List<double>.from(allFrames)..sort();
      final idx = (sorted.length * 0.95).ceil() - 1;
      return sorted[math.max(0, idx)];
    }();

    // Performance grade based on global mean frame time
    final perfGrade = () {
      if (meanFrameMsAll <= budgetMs) return 'A (Excellent)';
      if (meanFrameMsAll <= budgetMs * 1.5) return 'B (Good)';
      if (meanFrameMsAll <= budgetMs * 2.0) return 'C (Fair)';
      return 'D (Poor)';
    }();

    // CHANGED: label memory metric type explicitly (RSS)
    final memoryLineDelta = PlatformInfo.supportsMemoryProfiling
        ? 'Memory Delta (RSS): ${_calculateMean(memoryUsages).toStringAsFixed(2)} ± ${_calculateStdDev(memoryUsages).toStringAsFixed(2)} MB'
        : 'Memory Delta: Not available on ${PlatformInfo.platformName}';
    final memoryLinePerItem = PlatformInfo.supportsMemoryProfiling
        ? 'Memory per Item: ${(_calculateMean(memoryUsages) / (widget.itemCount == 0 ? 1 : widget.itemCount) * 1000).toStringAsFixed(2)} KB/item'
        : 'Memory per Item: N/A';

    final report = '''
🔬 SCIENTIFIC BENCHMARK REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Timestamp: ${DateTime.now()}
🔧 Platform: ${PlatformInfo.platformName} (${PlatformInfo.performanceProfile})
📊 Configuration: ${widget.itemCount} items, ${widget.iterations} iterations
🎯 Benchmark Type: ${_typeLabel(widget.benchmarkType)}
⚡ Target Frame Time: ${budgetMs.toStringAsFixed(2)}ms (${panelHz.toStringAsFixed(0)} FPS)

📈 FRAME PERFORMANCE (aggregate):
• Avg Frame Time: ${meanFrameMsAll.toStringAsFixed(2)} ms
• P95 Frame Time: ${p95All.toStringAsFixed(2)} ms
• Actual FPS (unclamped): ${fpsUnclamped.toStringAsFixed(2)}
• Actual FPS (clamped):   ${fpsClamped.toStringAsFixed(2)}
• Panel Refresh: ${panelHz.toStringAsFixed(0)} Hz
• Dropped Frames (strict > budget): ${droppedPctStrict.toStringAsFixed(2)}%
• Janky Frames ( > 1.5× budget): ${jankyPct.toStringAsFixed(2)}%
• Performance Grade: $perfGrade

⏱️ INITIAL RENDER (per-iteration):
• Time to First Frame: ${_calculateMean(firstFrameTimes).toStringAsFixed(2)} ± ${_calculateStdDev(firstFrameTimes).toStringAsFixed(2)} ms

🧠 MEMORY IMPACT (basis: RSS):
• $memoryLineDelta
• $memoryLinePerItem

📊 RELIABILITY:
• Coefficient of Variation (Frame Time): ${(_calculateStdDev(avgFrameTimes) / (_calculateMean(avgFrameTimes) == 0 ? 1 : _calculateMean(avgFrameTimes)) * 100).toStringAsFixed(2)}%
• Total Frames Analyzed: $totalFrames
• Scroll Distance: ${scrollDistancePx.toStringAsFixed(0)} px
• Avg Scroll Duration: ${avgScrollMs.toStringAsFixed(0)} ms

💡 INTERPRETATION:
${_generateInterpretation()}

🔍 PLATFORM-SPECIFIC NOTES:
${_generatePlatformNotes()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    releaseLog(report);
  }

  double _calculateMean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateStdDev(List<double> values) {
    if (values.length < 2) return 0;
    final mean = _calculateMean(values);
    final variance = values
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }

  String _generateInterpretation() {
    final avgFrameTime =
    _calculateMean(_results.map((r) => r.averageFrameTimeMs).toList());
    final benchmarkType = widget.benchmarkType;
    final targetFrameTime = PlatformInfo.targetFrameTimeMs;

    String baseInterpretation;
    if (avgFrameTime <= targetFrameTime) {
      baseInterpretation =
      "✅ Excellent performance - meeting ${PlatformInfo.expectedRefreshRate.toStringAsFixed(0)} FPS target";
    } else if (avgFrameTime <= targetFrameTime * 1.5) {
      baseInterpretation =
      "⚠️ Good performance - occasional frame drops below target";
    } else if (avgFrameTime <= targetFrameTime * 2.0) {
      baseInterpretation = "⚠️ Fair performance - noticeable frame drops";
    } else {
      baseInterpretation = "❌ Poor performance - significant frame drops detected";
    }

    String contextualNote;
    switch (benchmarkType) {
      case BenchmarkType.staticRender:
        contextualNote =
        "Static rendering should maintain consistent frame times across all platforms.";
        break;
      case BenchmarkType.scrollPerformance:
        contextualNote =
        "Scroll performance includes animation overhead. ${kIsWeb ? 'Web performance may vary by browser.' : PlatformInfo.isMobile ? 'Mobile performance can vary by device specifications.' : 'Desktop should show optimal performance.'}";
        break;
      case BenchmarkType.memoryUsage:
        if (PlatformInfo.supportsMemoryProfiling) {
          final avgMemory =
          _calculateMean(_results.map((r) => r.memoryDeltaMB).toList());
          contextualNote =
          "Memory delta of ${avgMemory.toStringAsFixed(1)}MB for ${widget.itemCount} items. ${Platform.isIOS ? 'iOS uses ARC for automatic memory management.' : 'Android may show higher memory usage due to VM overhead.'}";
        } else {
          contextualNote =
          "Memory profiling not available on ${PlatformInfo.platformName}.";
        }
        break;
    }

    return "$baseInterpretation\n$contextualNote";
  }

  String _generatePlatformNotes() {
    final notes = <String>[];

    if (kIsWeb) {
      notes.add("• Web performance depends on browser engine and JavaScript optimization");
      notes.add("• Consider testing across different browsers for comprehensive results");
    } else if (Platform.isAndroid) {
      notes.add("• Android performance varies significantly by device and API level");
      notes.add("• Consider testing on different Android versions and hardware tiers");
    } else if (Platform.isIOS) {
      notes.add("• iOS provides more consistent performance across devices");
      notes.add("• ProMotion displays (iPad Pro) may show different refresh rates");
    } else if (PlatformInfo.isDesktop) {
      notes.add("• Desktop platforms typically show optimal Flutter performance");
      notes.add("• GPU acceleration and high refresh rate monitors may affect results");
    }

    if (!PlatformInfo.supportsMemoryProfiling) {
      notes.add("• Memory profiling requires mobile platform or specific desktop setup");
    }

    notes.add("• Results should be compared only within the same platform category");

    return notes.join('\n');
  }

  Widget _buildLightweightItem(int index) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                (index * 50) % 256,
                (index * 80) % 256,
                (index * 120) % 256,
                1.0,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                '${index % 100}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Benchmark Item $index',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Iteration ${_currentIteration + 1}/${widget.iterations}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.iterations > 0
        ? (_currentIteration.clamp(0, widget.iterations)) / widget.iterations
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific List Benchmark'),
        backgroundColor: _benchmarkComplete ? Colors.green : Colors.blue,
      ),
      body: Column(
        children: [
          if (!_benchmarkComplete)
            LinearProgressIndicator(value: progress),
          if (!_benchmarkComplete)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Running iteration ${_currentIteration + 1} of ${widget.iterations}...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.itemCount,
              itemBuilder: (_, index) => _buildLightweightItem(index),
            ),
          ),
          if (_benchmarkComplete)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withOpacity(0.1),
              child: const Text(
                '✅ Benchmark Complete! Check console/logs for detailed results.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_timingsActive) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      _timingsActive = false;
    }
    _scrollController.dispose();
    super.dispose();
  }
}