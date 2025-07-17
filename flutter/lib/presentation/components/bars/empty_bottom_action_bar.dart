import 'package:flutter/material.dart';

class EmptyBottomActionBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? child;
  final double height;

  const EmptyBottomActionBar({
    super.key,
    this.child,
    this.height = kBottomNavigationBarHeight + 24,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    return Padding(
      padding: EdgeInsets.only(
          bottom: padding.bottom + 12,
          left: padding.left + 16,
          right: padding.right + 16,
          top: padding.top + 8),
      child: Container(
        height: height,
        alignment: Alignment.center,
        child: child ?? const SizedBox.shrink(), // Show an empty space if no child is provided
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}