import 'dart:math';

import 'package:flashcard/core/utils/random_gradient_generator.dart';
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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:2,
        childAspectRatio: 0.9,
      ),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final Deck deck = decks[index];
        return DeckCard(deck: deck, onDeckSelected: onDeckSelected);
      },
    );
  }
}