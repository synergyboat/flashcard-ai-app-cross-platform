
import 'package:flashcard/presentation/components/cards/deck_card.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/deck.dart';

class DeckCollectionGrid extends StatelessWidget {
  final List<Deck> decks;
  final Function(Deck) onDeckSelected;

  const DeckCollectionGrid({
    super.key,
    required this.decks,
    required this.onDeckSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:2,
            childAspectRatio: 0.85,
          ),
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final Deck deck = decks[index];
            return DeckCard(deck: deck, onDeckSelected: onDeckSelected);
          },
        ),
       Column(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Container(
              height: 60.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xfffdf7fe).withValues(alpha: 1),
                  Color(0xfffdf7fe).withValues(alpha: 0.5),
                  Color(0xfffdf7fe).withValues(alpha: 0.0),
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              )),
           Container(
               height: 60.0,
               decoration: BoxDecoration(
                   gradient: LinearGradient(colors: [
                     Color(0xfffdf7fe).withValues(alpha: 1),
                     Color(0xfffdf7fe).withValues(alpha: 0.5),
                     Color(0xfffdf7fe).withValues(alpha: 0.0),
                   ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
               )),
         ],
       )
      ],
    );
  }
}