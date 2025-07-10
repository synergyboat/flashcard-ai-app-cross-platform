import 'package:flutter/material.dart';

class LiquidGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> colors;
  final String? tooltip;

  const LiquidGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [
      Color(0xff0c7fff),
      Color(0xffcbfcff),
    ],
    this.tooltip,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip??'', // Change this to your desired tooltip text
      preferBelow: false, // Optional: change tooltip position
      child: InkWell(
        splashColor: Colors.blueAccent,
        highlightColor: Colors.cyan,
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: colors,
              center: const Alignment(0, -0.8),
              focal: const Alignment(0, -0.8),
              radius: 0.95,
              focalRadius: 0.3,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.6), // fix for withValues issue
                offset: const Offset(0, 5),
                spreadRadius: 3,
                blurRadius: 18,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                color: Colors.blueAccent.withOpacity(0), // fix for withValues issue
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}