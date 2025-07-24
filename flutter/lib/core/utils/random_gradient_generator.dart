import 'dart:math';
import 'package:flutter/material.dart';

class RandomGradientGenerator {
  static final Random _random = Random();

  // Material colors for gradients
  static final List<Color> _colors = [
    Colors.red.shade100.withValues(alpha: 0.22), Colors.pink.shade100.withValues(alpha: 0.22), Colors.purple.shade100.withValues(alpha: 0.22), Colors.deepPurple.shade100.withValues(alpha: 0.22),
    Colors.indigo.shade100.withValues(alpha: 0.22), Colors.blue.shade100.withValues(alpha: 0.22), Colors.lightBlue.shade100.withValues(alpha: 0.22), Colors.cyan.shade100.withValues(alpha: 0.22),
    Colors.teal.shade100.withValues(alpha: 0.22), Colors.green.shade100.withValues(alpha: 0.22), Colors.lightGreen.shade100.withValues(alpha: 0.22), Colors.lime.shade100.withValues(alpha: 0.22),
    Colors.yellow.shade100.withValues(alpha: 0.22), Colors.amber.shade100.withValues(alpha: 0.22), Colors.orange.shade100.withValues(alpha: 0.22), Colors.deepOrange.shade100.withValues(alpha: 0.22),
  ];

  static LinearGradient getRandomLinearGradient() {
    final color1 = _colors[_random.nextInt(_colors.length)];
    final color2 = _colors[_random.nextInt(_colors.length)];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
    );
  }

  // Linear gradient with random alignment
  static LinearGradient getRandomLinearGradientWithAlignment() {
    final color1 = _colors[_random.nextInt(_colors.length)];
    final color2 = _colors[_random.nextInt(_colors.length)];

    final alignments = [
      [Alignment.topLeft, Alignment.bottomRight],
      [Alignment.topRight, Alignment.bottomLeft],
      [Alignment.topCenter, Alignment.bottomCenter],
      [Alignment.centerLeft, Alignment.centerRight],
      [Alignment.center, Alignment.bottomCenter],
    ];

    final alignment = alignments[_random.nextInt(alignments.length)];

    return LinearGradient(
      begin: alignment[0],
      end: alignment[1],
      colors: [color1, color2],
    );
  }

  static List<Color> getRandomColors(int count) {
    List<Color> randomColors = [];
    for (int i = 0; i < count; i++) {
      randomColors.add(_colors[_random.nextInt(_colors.length)]);
    }
    return randomColors;
  }
}