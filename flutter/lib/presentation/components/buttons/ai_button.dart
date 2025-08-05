import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'liquid_gradient_button.dart';
import 'liquid_gradient_text_button.dart';

class AIButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showText;

  const AIButton({
    super.key,
    this.onPressed,
    this.showText = false,
  });

  void _onAddButtonPressed() {
    if (onPressed != null) {
      onPressed!();
    } else if (kDebugMode) {
      print("Add button pressed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 56,
        child: LiquidGradientTextButton(
          onPressed: _onAddButtonPressed,
          tooltip: "Generate using AI",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.sparkles,
                color: Colors.white,
                size: 24.0,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  );
                },
                child: showText
                    ? const Padding(
                  key: ValueKey('text'),
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Generate with AI",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}