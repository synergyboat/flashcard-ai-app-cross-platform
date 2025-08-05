import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/use_case/deck/delete_deck_use_case.dart';
import '../cards/deck_card.dart';

class DeckCollectionGrid extends StatefulWidget {
  final List<Deck> decks;
  final Function(Deck) onDeckSelected;
  final DeleteDeckUseCase deleteDeckUseCase;

  const DeckCollectionGrid({
    super.key,
    required this.decks,
    required this.onDeckSelected,
    required this.deleteDeckUseCase,
  });

  @override
  State<DeckCollectionGrid> createState() => _DeckCollectionGridState();
}

class _DeckCollectionGridState extends State<DeckCollectionGrid> {
  bool isShaking = false;

  void startShaking() {
    setState(() {
      isShaking = true;
    });
  }

  void stopShaking() {
    if (isShaking) {
      setState(() {
        isShaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: stopShaking,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (Platform.isMacOS) ? 6 : 2,
              childAspectRatio: 0.85,
            ),
            itemCount: widget.decks.length,
            itemBuilder: (context, index) {
              final deck = widget.decks[index];
              return DeckCard(
                deck: deck,
                isShaking: isShaking,
                deleteDeckUseCase: widget.deleteDeckUseCase,
                onDeckSelected: (deck){
                  if (isShaking) {
                    stopShaking();
                  } else {
                    widget.onDeckSelected(deck);
                  }
                },
                onLongPress: startShaking,
              );
            },
          ),
          // Top and bottom fade gradient overlays
          IgnorePointer(
            ignoring: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xfffdf7fe).withValues(alpha: 1),
                        const Color(0xfffdf7fe).withValues(alpha: 0.5),
                        const Color(0xfffdf7fe).withValues(alpha: 0.0),
                        const Color(0xfffdf7fe).withValues(alpha: 0.0),
                        const Color(0xfffdf7fe).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xfffdf7fe).withValues(alpha: 1),
                        const Color(0xfffdf7fe).withValues(alpha: 0.5),
                        const Color(0xfffdf7fe).withValues(alpha: 0.0),
                        const Color(0xfffdf7fe).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}