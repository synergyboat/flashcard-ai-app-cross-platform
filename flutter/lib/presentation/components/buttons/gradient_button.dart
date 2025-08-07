import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Icon? icon;
  final List<Color> colors;
  final Color shadowColor;
  final Color? rippleColor; // <-- New parameter

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 200.0,
    this.height = 50.0,
    this.icon,
    this.colors = const [Colors.blue, Colors.blueAccent],
    this.shadowColor = Colors.blueAccent,
    this.rippleColor = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            spreadRadius: 5,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          overlayColor: rippleColor != null
              ? WidgetStateProperty.all(rippleColor)
              : null,
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) icon!,
              if (icon != null) const SizedBox(width: 8.0),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}