import '../entities/deck.dart';

abstract class DeckRepository {
  Future<void> addDeck(String name);
  Future<void> updateDeck(String deckId, Deck updatedDeck);
  Future<void> deleteDeck(String deckId);

  Future<List<Map<String, Deck>>> getAllDecks();
  Future<Map<String, Deck>> getDeckById(String deckId);
  Future<void> deleteAllDecks();
}