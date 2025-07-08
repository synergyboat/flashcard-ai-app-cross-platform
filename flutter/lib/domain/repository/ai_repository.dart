import '../entities/flashcard.dart';

abstract class AIRepository {
  Future<Map<String, Flashcard>> generateFlashcard(String deckId, String prompt);
  Future<Map<String, Flashcard>> generateMultipleFlashcards(String deckId, String prompt);
}