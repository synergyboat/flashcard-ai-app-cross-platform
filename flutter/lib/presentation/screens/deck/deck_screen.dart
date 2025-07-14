import 'package:flashcard/presentation/components/bars/flashcard_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/deck.dart';

class DeckScreen extends StatefulWidget {
  final Deck deck;
  const DeckScreen({super.key, required this.deck});

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  Deck get deck => widget.deck;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlashcardAppBar(
        title: "Deck Details",
      ),
      body: SafeArea(
          child: Center(
            child:Text("Deck: ${deck.name} \n"
                "Description: ${deck.description} \n"
                "Created At: ${deck.createdAt?.toIso8601String()} \n"
                "Updated At: ${deck.updatedAt?.toIso8601String()} \n"
                "Flashcards Count: ${deck.flashcards.length} \n"
                "Flashcards: ${deck.flashcards.toString()}"),
          )),
    );
  }
}