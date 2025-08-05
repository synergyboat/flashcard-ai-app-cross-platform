import 'package:flashcard/domain/use_case/deck/delete_deck_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/config/di/config_di.dart';
import '../../../domain/entities/deck.dart';

class DeckCard extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onDeckSelected;
  final VoidCallback onLongPress;
  final bool isShaking;
  final DeleteDeckUseCase deleteDeckUseCase;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onDeckSelected,
    required this.onLongPress,
    required this.isShaking,
    required this.deleteDeckUseCase,
  });

  @override
  State<DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant DeckCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isShaking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isShaking && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onDeckSelected(widget.deck),
      onLongPress: widget.onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Transform.rotate(
                    angle: widget.isShaking ? _rotationAnimation.value : 0.0,
                    child: _buildCardStack(),
                  ),
                  if (widget.isShaking)
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              onPressed: (){},
                              icon: Icon(CupertinoIcons.pencil_circle_fill),
                              color: Colors.black.withValues(alpha: 1),
                              iconSize: 42,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 42,
                                  height: 42),
                              tooltip: "Delete Deck"),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: (){
                                _showDeleteAlertDialog(context, widget.deck);
                              },
                              icon: Icon(CupertinoIcons.xmark_circle_fill),
                              color: Colors.redAccent.withValues(alpha: 1),
                              iconSize: 42,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 42,
                                  height: 42),
                              tooltip: "Delete Deck"),
                        )
                      ],
                    )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: 0.90,
          child: Transform(
            transform: Matrix4.translationValues(15.0, 0.0, 0.0)..rotateZ(0.2),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                borderRadius: BorderRadius.circular(32.0),
              ),
              elevation: 0,
              color: Colors.white,
              child: Container(),
            ),
          ),
        ),
        Transform.scale(
          scale: 0.95,
          child: Transform(
            transform: Matrix4.translationValues(-18.0, 10.0, 0.0)..rotateZ(-0.2),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400, width: 0.5),
                borderRadius: BorderRadius.circular(32.0),
              ),
              elevation: 8,
              color: Colors.white,
              child: Container(),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade400, width: 0.5),
            borderRadius: BorderRadius.circular(32.0),
          ),
          color: Colors.white,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "\"${widget.deck.name}\"",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAlertDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Deletion', style: TextStyle(color: Colors.black)),
          content: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.redAccent.withValues(alpha: 0.1)
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.redAccent),
                      const SizedBox(width: 8.0),
                      const Text('This action cannot be undone.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12.0)
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                    'Are you sure you want to delete this Deck?',
                    style: TextStyle(color: Colors.black54)
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('Confirm'),
              onPressed: () async {
                await widget.deleteDeckUseCase(deck);
                if (mounted) {
                  setState(() async {
                    if (mounted){
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}