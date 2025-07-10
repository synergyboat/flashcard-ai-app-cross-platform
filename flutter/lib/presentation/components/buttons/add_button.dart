import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback? onPressed;
  void _onAddButtonPressed(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      // Default action if no callback is provided
      if (kDebugMode) {
        print("Add button pressed");
      }
    }
  }

  const AddButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: "Add new deck",
      style: IconButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        backgroundColor: Colors.black.withValues(alpha: 0.05),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
      icon: Icon(CupertinoIcons.add, color: Colors.black, size: 24.0),
      onPressed: () {  },
    );
    throw UnimplementedError();
  }

}