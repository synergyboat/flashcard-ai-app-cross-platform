import 'package:flashcard/domain/use_case/deck/create_new_deck_use_case.dart';
import 'package:flashcard/domain/use_case/deck/get_flashcards_from_deck_use_case.dart';
import 'package:flashcard/presentation/components/bars/empty_bottom_action_bar.dart';
import 'package:flashcard/presentation/components/bars/flashcard_app_bar.dart';
import 'package:flashcard/presentation/components/buttons/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../core/config/di/config_di.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/entities/flashcard.dart';
import 'dart:math';

class DeckPreviewScreen extends StatefulWidget {
  final Deck deck;
  const DeckPreviewScreen({super.key, required this.deck});

  @override
  State<DeckPreviewScreen> createState() => _DeckPreviewScreenState();
}

class _DeckPreviewScreenState extends State<DeckPreviewScreen> with TickerProviderStateMixin {
  late final Deck deck = widget.deck;
  final CreateNewDeckUseCase _createNewDeckUseCase = getIt<CreateNewDeckUseCase>();
  final Logger _logger = getIt<Logger>();
  late final List<Flashcard> _flashcards = deck.flashcards;

  int currentIndex = 0;

  late AnimationController _swipeController;
  double _dragOffset = 0.0;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    // _flashcards = deck.flashcards;
    _logger.i("The deck is: ${deck.toString()}");
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _opacity = pow((1.0 - (_dragOffset.abs() / 200)), 2).clamp(0.0, 1.0).toDouble();
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const swipeThreshold = 100;
    final isForward = _dragOffset < -swipeThreshold;
    final isBackward = _dragOffset > swipeThreshold;

    if (isForward && currentIndex < _flashcards.length - 1) {
      _animateSwipe(() {
        setState(() => currentIndex++);
      });
    } else if (isBackward && currentIndex > 0) {
      _animateSwipe(() {
        setState(() => currentIndex--);
      });
    } else {
      _resetDrag();
    }
  }

  void _animateSwipe(VoidCallback onComplete) {
    _swipeController.forward(from: 0).whenComplete(() {
      _swipeController.reset();
      _dragOffset = 0;
      _opacity = 1.0;
      onComplete();
    });
  }

  void _resetDrag() {
    setState(() {
      _dragOffset = 0;
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlashcardAppBar(title: "Deck Details"),
      bottomNavigationBar: EmptyBottomActionBar(
        child:  GradientButton(
            text: "Save Deck",
            onPressed: ()=>{
              _createNewDeckUseCase(deck)
              .then((value){
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Flashcard added successfully!"),
                        duration: Duration(seconds: 2),
                      )
                  );
                  context.go("/home");
                }
              })
            }
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (i) {
                      int index = currentIndex + i;
                      if (index >= _flashcards.length) return const SizedBox.shrink();

                      final flashcard = _flashcards[index];
                      bool isTopCard = i == 0;
                      bool isSecondCard = i == 1;
                      double topOffset = i * -12.0;
                      double baseScale = 1.0 - (i * 0.05);

                      double adjustedScale = baseScale;

                      if (isSecondCard) {
                        double progress = (_dragOffset.abs() / 150).clamp(0.0, 1.0);
                        adjustedScale = baseScale + (1.0 - baseScale - 0.05) * progress;
                      }

                      Widget card = Container(
                        height: constraints.maxHeight - 100,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                flashcard.question,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                flashcard.answer,
                                style: const TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              Text(
                                'Card ${index + 1} of ${_flashcards.length}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (isTopCard) {
                        return GestureDetector(
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: _onHorizontalDragEnd,
                          child: AnimatedBuilder(
                            animation: _swipeController,
                            builder: (context, child) {
                              final slideAmount = _swipeController.value *
                                  (_dragOffset.sign * constraints.maxWidth);
                              return Transform.translate(
                                offset: Offset(_dragOffset + slideAmount, 0),
                                child: Opacity(
                                  opacity: _opacity,
                                  child: child,
                                ),
                              );
                            },
                            child: card,
                          ),
                        );
                      } else {
                        return Transform.translate(
                          offset: Offset(0, -topOffset + (i * 12.0)),
                          child: Transform.scale(
                            scale: adjustedScale,
                            child: card,
                          ),
                        );
                      }
                    }).reversed.toList(),
                  ),
                  const SizedBox(height: 64.0),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
