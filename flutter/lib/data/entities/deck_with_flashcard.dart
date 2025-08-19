import 'deck_db_entity.dart';
import 'flashcard_db_entity.dart';

// Represents a deck along with its associated flashcards in the database.

class DeckWithFlashcardsDbEntity {
  final DeckDbEntity deck;
  final List<FlashcardDbEntity> flashcards;

  DeckWithFlashcardsDbEntity(this.deck, this.flashcards);

  Map<String, dynamic> toMap() => {
    ...deck.toMap(),
    'flashcards': flashcards.map((fc) => fc.toMap()).toList(),
  };
}