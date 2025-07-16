import 'package:flutter/material.dart';

import '../../../domain/entities/deck.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final Function(Deck) onDeckSelected;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onDeckSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onDeckSelected(deck),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 0.90,
              child: Transform(
                  transform: Matrix4.translationValues(0.0, 20.0, 0.0)..rotateZ(0.05),
                  child: Card(
                      elevation: 1,
                      color: Colors.white,
                      child: Container()
                  )
              ),
            ),
            Transform.scale(
                scale: 0.95,
                child: Transform(
                  transform: Matrix4.translationValues(0.0, 10.0, 0.0)..rotateZ(-0.1),
                  child: Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Container()
                  ),
                )
            ),
            Card(
              color: Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text("\"${deck.name}\"", textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}