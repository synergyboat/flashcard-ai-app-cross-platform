import 'package:flashcard/core/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlashcardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leadingWidget;
  final String? title;
  final Widget? actions;
  final double height;
  const FlashcardAppBar({super.key, this.leadingWidget, this.title, this.actions, this.height=kToolbarHeight});

  String _setDefaultTitle(String route){
    switch (route) {
      case '/':
        return 'Home';
      case '/deck':
        return 'Your Decks';
      case '/settings':
        return 'Settings';
      default:
        return 'Flashcard AI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = title??_setDefaultTitle(getCurrentRouteName(context));
    final double topPadding = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: preferredSize.height + topPadding + 24,
      child: Padding(padding: EdgeInsets.only(top: topPadding) ,
          child: Stack(
            children: [
              Center(child: Text(titleText, style: TextStyle(color: Colors.black87),)),
              SizedBox(
                height: height,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (leadingWidget == null)? (context.canPop())?
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () {
                            // Navigate back to the previous screen
                            context.pop();
                          },
                        )
                          : const SizedBox(width: 16.0, height: 16.0,)
                    : leadingWidget!,
                    actions != null? leadingWidget!
                        : const SizedBox(width: 16.0, height: 16.0,)
                  ],
                ),
              ),
            ],
          )),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);


}