import 'package:flutter/material.dart';

class LiquidGradientTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> colors;
  final String? tooltip;

  const LiquidGradientTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [
      Color(0xff0c7fff),
      Color(0xff2794e5),
    ],
    this.tooltip,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '', // Change this to your desired tooltip text
      preferBelow: false, // Optional: change tooltip position
      child: InkWell(
        splashColor: Colors.blueAccent,
        highlightColor: Color(0xff2e68f6),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(100),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent
                    .withValues(alpha: 0.6),
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
                color: Colors.blueAccent
                    .withValues(alpha: 0),
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
