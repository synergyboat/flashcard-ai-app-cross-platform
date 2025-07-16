import 'package:flashcard/domain/entities/flashcard.dart';

abstract class FlashcardRepository {
  Future<void> addFlashcardToDeck(int deckId, Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard updatedFlashcard);

  Future<void> deleteFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcardById(int flashcardId);
  Future<void> deleteFlashcardsByDeckId(int deckId);

  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId);
  Future<Flashcard> getFlashcardById(int flashcardId);
  Future<void> addMultipleFlashcardsToDeck(int deckId, List<Flashcard> flashcards);

  Future<List<Flashcard>> getAllFlashcards();
}