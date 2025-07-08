import 'package:flashcard/domain/entities/flashcard.dart';

abstract class FlashcardRepository {
  Future<void> addFlashcard(String deckId, String question, String answer);
  Future<void> updateFlashcard(String flashcardId, String question, String answer);
  Future<void> deleteFlashcard(String flashcardId);
  Future<void> deleteFlashcardsByDeck(String deckId);

  Future<List<Map<String, Flashcard>>> getFlashcardsByDeck(String deckId);
  Future<Map<String, Flashcard>> getFlashcardById(String flashcardId);
  Future<List<Map<String, Flashcard>>> getAllFlashcards();
}