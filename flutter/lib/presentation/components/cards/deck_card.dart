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
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 0.90,
                child: Transform(
                    transform: Matrix4.translationValues(15.0, 0.0, 0.0)..rotateZ(0.2),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.grey.shade400, // Border color
                              width: 0.5,         // Border width
                            ),
                            borderRadius: BorderRadius.circular(32.0)),
                        elevation: 0,
                        color: Colors.white,
                        child: Container()
                    )
                ),
              ),
              Transform.scale(
                  scale: 0.95,
                  child: Transform(
                    transform: Matrix4.translationValues(-18.0, 10.0, 0.0)..rotateZ(-0.2),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey.shade400, // Border color
                            width: 0.5,         // Border width
                          ),
                          borderRadius: BorderRadius.circular(32.0)),
                        elevation: 8,
                        color: Colors.white,
                        child: Container()
                    ),
                  )
              ),
              Card(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.shade400, // Border color
                      width: 0.5,         // Border width
                    ),
                    borderRadius: BorderRadius.circular(32.0)),
                color: Colors.white,
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text("\"${deck.name}\"", textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}