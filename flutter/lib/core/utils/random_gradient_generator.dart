import 'dart:math';
import 'package:flutter/material.dart';

class RandomGradientGenerator {
  static final Random _random = Random();

  // Material colors for gradients
  static final List<Color> _colors = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
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
}