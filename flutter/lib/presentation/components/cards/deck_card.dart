import 'package:flashcard/domain/use_case/deck/delete_deck_use_case.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/use_case/deck/update_deck_use_case.dart';
import '../buttons/gradient_button.dart';
import '../inputs/text_input_field.dart';

class DeckCard extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onDeckSelected;
  final VoidCallback onLongPress;
  final bool isShaking;
  final DeleteDeckUseCase deleteDeckUseCase;
  final UpdateDeckUseCase updateDeckUseCase;
  final VoidCallback? refreshDecks;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onDeckSelected,
    required this.onLongPress,
    required this.isShaking,
    required this.deleteDeckUseCase,
    required this.updateDeckUseCase,
    this.refreshDecks,
  });

  @override
  State<DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  String? nameEditValue = "";
  String? descriptionEditValue = "";

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
                          alignment: Alignment.topRight.add(
                              Alignment(0.3, -0.15)),
                          child: Container(
                            padding: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                                Colors.white,
                                Colors.white.withAlpha(0)
                              ]),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  spreadRadius: 0.4,
                                  offset: Offset(-2, 2),
                                ),
                              ],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                                onPressed: (){
                                  _showEditDeckDialog(context, widget.deck);
                                },
                                icon: Icon(CupertinoIcons.pencil_circle_fill),
                                color: Colors.black.withValues(alpha: 0.7),
                                iconSize: 42,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                    width: 42,
                                    height: 42),
                                tooltip: "Edit Deck"),
                          ),
                        ),
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
                widget.refreshDecks?.call();
                if (context.mounted){
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDeckDialog(BuildContext context, Deck deck) {
    setState(() {
      nameEditValue = deck.name;
      descriptionEditValue = deck.description;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final halfScreenHeight = MediaQuery.of(context).size.height * 0.5;

        return SizedBox(
          height: halfScreenHeight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: const Text(
                                'Edit Deck',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  _showDeleteAlertDialog(context, deck);
                                },
                                child: Text("Delete",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w400,
                                    )
                                ),
                              ),
                            )
                          ]
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Question',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      TextInputField(
                        hint: "Name",
                        value: nameEditValue??"",
                        onValueChanged: (value) {
                          setState(() {
                            nameEditValue = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Answer',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      TextInputField(
                        hint: "Description",
                        value: descriptionEditValue??"",
                        onValueChanged: (value) {
                          setState(() {
                            descriptionEditValue = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                      GradientButton(
                        text: "Save changes",
                        onPressed: () async {
                          setState(() {
                            deck = deck.copyWith(name: nameEditValue, description: descriptionEditValue);
                          });
                          await widget.updateDeckUseCase(deck);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        shadowColor: Colors.blueAccent.withValues(alpha: 0.8),
                        icon: const Icon(Icons.check, color: Colors.white, size: 20.0),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}