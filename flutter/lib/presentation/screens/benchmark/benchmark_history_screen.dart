import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'list_render_benchmark_screen.dart';

class BenchmarkHistoryScreen extends StatelessWidget {
  final List<BenchmarkResult> results;

  const BenchmarkHistoryScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benchmark History'),
      ),
      body: results.isEmpty
          ? const Center(child: Text("No benchmark data available"))
          : ListView.separated(
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final result = results[index];
          return ExpansionTile(
            title: Text(
              'Iteration ${index + 1} - ${result.timestamp.toIso8601String().split('T').first}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Avg Frame: ${result.averageFrameTimeMs.toStringAsFixed(2)}ms '
                  '| FPS: ${result.actualFps.toStringAsFixed(1)} '
                  '| Mem Δ: ${result.memoryDeltaMB.toStringAsFixed(2)}MB '
                  '| Frames: ${result.frameTimesMs.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statRow("⏱️ Time to First Frame",
                        '${result.timeToFirstFrame.inMilliseconds} ms'),
                    _statRow("📊 Avg Frame Time",
                        '${result.averageFrameTimeMs.toStringAsFixed(2)} ms'),
                    _statRow("🎯 P95 Frame Time",
                        '${result.p95FrameTimeMs.toStringAsFixed(2)} ms'),
                    _statRow("⚠️ Dropped Frames",
                        '${result.droppedFramesPercentStrict.toStringAsFixed(2)}%'),
                    _statRow("🧠 Memory Delta",
                        '${result.memoryDeltaMB.toStringAsFixed(2)} MB'),
                    _statRow("💡 Performance Grade",
                        result.performanceGrade),
                    const SizedBox(height: 8),
                    const Text('Frame Durations (ms):',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: _buildWindowedFrameChips(result, windowSize: 5),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }


  List<Widget> _buildWindowedFrameChips(BenchmarkResult result, {int windowSize = 5}) {
    final frames = result.frameTimesMs;
    final windowedAverages = <double>[];

    for (int i = 0; i < frames.length; i += windowSize) {
      final window = frames.sublist(i, math.min(i + windowSize, frames.length));
      final avg = window.reduce((a, b) => a + b) / window.length;
      windowedAverages.add(avg);
    }

    return windowedAverages.map((avg) {
      return Chip(
        label: Text(avg.toStringAsFixed(1)),
        backgroundColor: avg > result.targetFrameTimeMs * 1.5
            ? Colors.red[200]
            : Colors.green[200],
      );
    }).toList();
  }

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value),
      ],
    ),
  );
}