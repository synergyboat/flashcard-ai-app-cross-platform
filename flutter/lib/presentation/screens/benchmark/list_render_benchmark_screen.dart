import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'benchmark_history_screen.dart';

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
  State<ListRenderBenchmarkScreen> createState() => _ListRenderBenchmarkScreenState();
}

enum BenchmarkType {
  staticRender,    // Just measure list building and initial render
  scrollPerformance, // Measure scroll performance separately
  memoryUsage,     // Focus on memory consumption
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
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get supportsMemoryProfiling => isMobile && !kIsWeb;

  static double get expectedRefreshRate {
    // Platform-specific refresh rate expectations
    if (kIsWeb) return 60.0; // Most browsers cap at 60fps
    if (Platform.isAndroid) return 60.0; // Can be 90/120Hz but 60 is baseline
    if (Platform.isIOS) return 60.0; // iPhone: 60Hz, iPad Pro: 120Hz ProMotion
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

  BenchmarkResult({
    required this.timeToFirstFrame,
    required this.frameTimesMs,
    required this.memoryDeltaMB,
    required this.timestamp,
    required this.itemCount,
    required this.platform,
    required this.targetFrameTimeMs,
  });

  double get averageFrameTimeMs => frameTimesMs.isEmpty ? 0 :
  frameTimesMs.reduce((a, b) => a + b) / frameTimesMs.length;

  double get actualFps => frameTimesMs.isEmpty ? 0 :
  frameTimesMs.length / (frameTimesMs.reduce((a, b) => a + b) / 1000);

  double get p95FrameTimeMs {
    if (frameTimesMs.isEmpty) return 0;
    final sorted = List<double>.from(frameTimesMs)..sort();
    final index = (sorted.length * 0.95).ceil() - 1;
    return sorted[math.max(0, index)];
  }

  double get droppedFramesPercent {
    final droppedCount = frameTimesMs.where((time) => time > targetFrameTimeMs * 1.5).length;
    return frameTimesMs.isEmpty ? 0 : (droppedCount / frameTimesMs.length) * 100;
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

  @override
  void initState() {
    super.initState();
    _recordBaselineMemory();
    _startBenchmark();
  }

  void _recordBaselineMemory() {
    if (PlatformInfo.supportsMemoryProfiling) {
      _baselineMemoryMB = (ProcessInfo.currentRss / (1024 * 1024)).round();
      log('📊 Platform: ${PlatformInfo.platformName} - Baseline memory: ${_baselineMemoryMB}MB');
    } else {
      log('📊 Platform: ${PlatformInfo.platformName} - Memory profiling not available');
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

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeToFirstFrame = _renderStopwatch!.elapsed;
      _renderStopwatch!.stop();

      switch (widget.benchmarkType) {
        case BenchmarkType.staticRender:
        case BenchmarkType.memoryUsage:
          Future.delayed(const Duration(milliseconds: 1000), () {
            _recordIteration(timeToFirstFrame);
            _nextIteration();
          });
          break;

        case BenchmarkType.scrollPerformance:
          Future.delayed(const Duration(milliseconds: 300), () {
            _performScrollBenchmark(timeToFirstFrame);
          });
          break;
      }
    });

    setState(() {});
  }

  void _performScrollBenchmark(Duration timeToFirstFrame) async {
    if (!mounted || _scrollController.position.maxScrollExtent == 0) {
      _recordIteration(timeToFirstFrame);
      _nextIteration();
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;

    double scrollSpeed;
    if (kIsWeb) {
      scrollSpeed = 300.0;
    } else if (PlatformInfo.isMobile) {
      scrollSpeed = 500.0;
    } else {
      scrollSpeed = 800.0;
    }

    final scrollDuration = Duration(milliseconds: (maxScroll / scrollSpeed * 1000).toInt());

    _renderStopwatch = Stopwatch()..start();

    try {
      await _scrollController.animateTo(
        maxScroll,
        duration: scrollDuration,
        curve: Curves.linear,
      );

      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } catch (e) {
      log('Scroll benchmark error: $e');
    }

    _renderStopwatch!.stop();

    Future.delayed(const Duration(milliseconds: 200), () {
      _recordIteration(timeToFirstFrame);
      _nextIteration();
    });
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

  void _recordIteration(Duration timeToFirstFrame) {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);

    final frameTimesMs = _frameTimings
        .map((timing) => timing.totalSpan.inMicroseconds / 1000.0)
        .toList();

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
    );

    _results.add(result);
    log('Iteration ${_currentIteration + 1} complete: ${result.averageFrameTimeMs.toStringAsFixed(2)}ms avg');
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

    final avgFrameTimes = _results.map((r) => r.averageFrameTimeMs).toList();
    final firstFrameTimes = _results.map((r) => r.timeToFirstFrame.inMilliseconds).toList();
    final memoryUsages = _results.map((r) => r.memoryDeltaMB).toList();

    final report = '''
🔬 SCIENTIFIC BENCHMARK REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Timestamp: ${DateTime.now()}
🔧 Platform: ${PlatformInfo.platformName} (${PlatformInfo.performanceProfile})
📊 Configuration: ${widget.itemCount} items, ${widget.iterations} iterations
🎯 Benchmark Type: ${widget.benchmarkType}
⚡ Target Frame Time: ${PlatformInfo.targetFrameTimeMs.toStringAsFixed(2)}ms (${PlatformInfo.expectedRefreshRate.toStringAsFixed(0)} FPS)

📈 FRAME PERFORMANCE (averaged across ${widget.iterations} runs):
• Avg Frame Time: ${_calculateMean(avgFrameTimes).toStringAsFixed(2)} ± ${_calculateStdDev(avgFrameTimes).toStringAsFixed(2)} ms
• P95 Frame Time: ${_results.map((r) => r.p95FrameTimeMs).reduce(math.max).toStringAsFixed(2)} ms
• Actual FPS: ${_calculateMean(_results.map((r) => r.actualFps).toList()).toStringAsFixed(2)}
• Dropped Frames: ${_calculateMean(_results.map((r) => r.droppedFramesPercent).toList()).toStringAsFixed(2)}%
• Performance Grade: ${_results.isNotEmpty ? _results.first.performanceGrade : 'N/A'}

⏱️ INITIAL RENDER:
• Time to First Frame: ${_calculateMean(firstFrameTimes.map((t) => t.toDouble()).toList()).toStringAsFixed(2)} ± ${_calculateStdDev(firstFrameTimes.map((t) => t.toDouble()).toList()).toStringAsFixed(2)} ms

🧠 MEMORY IMPACT:
• Memory Delta: ${PlatformInfo.supportsMemoryProfiling ? '${_calculateMean(memoryUsages).toStringAsFixed(2)} ± ${_calculateStdDev(memoryUsages).toStringAsFixed(2)} MB' : 'Not available on ${PlatformInfo.platformName}'}
• Memory per Item: ${PlatformInfo.supportsMemoryProfiling ? '${(_calculateMean(memoryUsages) / widget.itemCount * 1000).toStringAsFixed(2)} KB/item' : 'N/A'}

📊 RELIABILITY:
• Coefficient of Variation (Frame Time): ${(_calculateStdDev(avgFrameTimes) / _calculateMean(avgFrameTimes) * 100).toStringAsFixed(2)}%
• Total Frames Analyzed: ${_results.fold(0, (sum, r) => sum + r.frameTimesMs.length)}

💡 INTERPRETATION:
${_generateInterpretation()}

🔍 PLATFORM-SPECIFIC NOTES:
${_generatePlatformNotes()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    print(report);
    log(report);
  }

  double _calculateMean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateStdDev(List<double> values) {
    if (values.length < 2) return 0;
    final mean = _calculateMean(values);
    final variance = values.map((v) => math.pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }

  String _generateInterpretation() {
    final avgFrameTime = _calculateMean(_results.map((r) => r.averageFrameTimeMs).toList());
    final benchmarkType = widget.benchmarkType;
    final targetFrameTime = PlatformInfo.targetFrameTimeMs;

    String baseInterpretation;
    if (avgFrameTime <= targetFrameTime) {
      baseInterpretation = "✅ Excellent performance - meeting ${PlatformInfo.expectedRefreshRate.toStringAsFixed(0)} FPS target";
    } else if (avgFrameTime <= targetFrameTime * 1.5) {
      baseInterpretation = "⚠️ Good performance - occasional frame drops below target";
    } else if (avgFrameTime <= targetFrameTime * 2.0) {
      baseInterpretation = "⚠️ Fair performance - noticeable frame drops";
    } else {
      baseInterpretation = "❌ Poor performance - significant frame drops detected";
    }

    String contextualNote;
    switch (benchmarkType) {
      case BenchmarkType.staticRender:
        contextualNote = "Static rendering should maintain consistent frame times across all platforms.";
        break;
      case BenchmarkType.scrollPerformance:
        contextualNote = "Scroll performance includes animation overhead. ${kIsWeb ? 'Web performance may vary by browser.' : PlatformInfo.isMobile ? 'Mobile performance can vary by device specifications.' : 'Desktop should show optimal performance.'}";
        break;
      case BenchmarkType.memoryUsage:
        if (PlatformInfo.supportsMemoryProfiling) {
          final avgMemory = _calculateMean(_results.map((r) => r.memoryDeltaMB).toList());
          contextualNote = "Memory delta of ${avgMemory.toStringAsFixed(1)}MB for ${widget.itemCount} items. ${Platform.isIOS ? 'iOS uses ARC for automatic memory management.' : 'Android may show higher memory usage due to VM overhead.'}";
        } else {
          contextualNote = "Memory profiling not available on ${PlatformInfo.platformName}.";
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific List Benchmark'),
        backgroundColor: _benchmarkComplete ? Colors.green : Colors.blue,
      ),
      body: Column(
        children: [
          if (!_benchmarkComplete)
            LinearProgressIndicator(
              value: widget.iterations > 0 ? _currentIteration / widget.iterations : 0,
            ),
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
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _scrollController.dispose();
    super.dispose();
  }
}