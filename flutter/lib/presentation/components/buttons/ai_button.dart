import 'package:flashcard/presentation/components/buttons/liquid_gradient_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AIButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AIButton({super.key, this.onPressed});

  void _onAddButtonPressed() {
    if (onPressed != null) {
      onPressed!();
    } else {
      if (kDebugMode) {
        print("Add button pressed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGradientButton(
      onPressed: _onAddButtonPressed,
      tooltip: "Generate using AI",
      child: Icon(
      CupertinoIcons.sparkles,
      color: Colors.white,
      size: 24.0,
    ),
    );
  }
}