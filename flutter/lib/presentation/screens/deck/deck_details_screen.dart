import 'package:flashcard/core/utils/random_gradient_generator.dart';
import 'package:flashcard/domain/use_case/deck/create_new_deck_use_case.dart';
import 'package:flashcard/domain/use_case/deck/delete_deck_use_case.dart';
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

class DeckDetailsScreen extends StatefulWidget {
  final Deck deck;
  const DeckDetailsScreen({super.key, required this.deck});

  @override
  State<DeckDetailsScreen> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> with TickerProviderStateMixin {
  late final Deck deck = widget.deck;
  final DeleteDeckUseCase _deleteDeckUseCase = getIt<DeleteDeckUseCase>();
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
      appBar: FlashcardAppBar(title: deck.name,
      actions: IconButton(
        highlightColor: Colors.redAccent.withValues(alpha: 0.1),
          onPressed: (){_showDeleteAlertDialog(context, deck);},
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 24.0)
      ),),
      bottomNavigationBar: EmptyBottomActionBar(
        child: GradientButton(
          text: "Close",
          onPressed: () => context.go("/home"),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Description at top
              if (deck.description != null && deck.description!.isNotEmpty)
                Text(
                  deck.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),

              // Card stack - use Expanded to take remaining space
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
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

                        Widget card = Stack(
                          children: [
                            Container(
                              height: constraints.maxHeight * 0.8,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(48.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 18,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: constraints.maxHeight * 0.8,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: RandomGradientGenerator.getRandomColors(2) +
                                      [
                                        Colors.white.withValues(alpha: 0.1),
                                        Colors.white.withValues(alpha: 0.4),
                                        Colors.white.withValues(alpha: 0.4),
                                      ],
                                  center: Alignment.topRight,
                                  radius: 2,
                                  //focal: Alignment.topCenter,
                                  //focalRadius: 0.2
                                ),
                                borderRadius: BorderRadius.circular(48.0),
                              ),
                            ),
                            Container(
                              height: constraints.maxHeight * 0.8,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.0,
                                ),
                                gradient: RadialGradient(
                                    colors: RandomGradientGenerator.getRandomColors(3) +
                                        [
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.1),
                                        ],
                                  radius: 1.2,
                                  center: Alignment.topLeft,
                                ),
                                borderRadius: BorderRadius.circular(48.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            flashcard.question,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            flashcard.answer,
                                            style: const TextStyle(fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                    );
                  },
                ),
              ),

              // Card counter at bottom
              const SizedBox(height: 16),
              Text(
                'Card ${currentIndex + 1} of ${_flashcards.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
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
                    'Are you sure you want to delete this deck?',
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
                await _deleteDeckUseCase(deck);
                Navigator.of(context).pop();
                context.go("/home");
              },
            ),
          ],
        );
      },
    );
  }
}