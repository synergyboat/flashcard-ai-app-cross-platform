import 'package:flutter/material.dart';

class FlashcardBottomActionBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? center;
  final double height;

  const FlashcardBottomActionBar({
    super.key,
    this.leading,
    this.trailing,
    this.center,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading!,
          if (center != null) center!,
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}