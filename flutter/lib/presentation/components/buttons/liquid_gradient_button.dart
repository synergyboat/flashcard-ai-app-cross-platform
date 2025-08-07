import 'package:flutter/material.dart';

class LiquidGradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> colors;
  final String? tooltip;
  final Color shadowColor;
  final Color rippleColor;
  final Color highlightColor;

  const LiquidGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [
      Color(0xff0c7fff),
      Color(0xff2e68f6),
    ],
    this.tooltip,
    this.shadowColor = Colors.blueAccent,
    this.rippleColor = Colors.blueAccent,
    this.highlightColor = Colors.cyan
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      preferBelow: false,
      child: InkWell(
        splashColor: rippleColor,
        highlightColor: highlightColor,
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
                color: shadowColor.withValues(alpha: 0.6),
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
                color: Colors.blueAccent.withValues(alpha: 0),
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