import 'deck_db_entity.dart';
import 'flashcard_db_entity.dart';

class DeckWithFlashcardsDbEntity {
  final DeckDbEntity deck;
  final List<FlashcardDbEntity> flashcards;

  DeckWithFlashcardsDbEntity(this.deck, this.flashcards);
}