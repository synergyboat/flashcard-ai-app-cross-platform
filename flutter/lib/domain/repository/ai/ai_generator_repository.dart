
abstract class AIGeneratorRepository {
  /// Generates a flashcard based on the provided prompt and adds it to the specified deck.
  // Future<Map<String, Flashcard>> generateFlashcard(
  //     String deckId,
  //     String prompt);

  /// Generates a deck of flashcards based on the provided prompt and count.
  Future<String?> generateDeck(
      String? deckId,
      int count,
      String prompt
      );
}