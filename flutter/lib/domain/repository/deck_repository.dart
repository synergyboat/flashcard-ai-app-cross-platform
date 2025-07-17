import '../entities/deck.dart';

abstract class DeckRepository {
  Future<int> addDeck(Deck deck);
  Future<void> updateDeck(Deck updatedDeck);

  Future<void> deleteDeckById(Deck deck);
  Future<void> deleteDeck(Deck deck);
  Future<void> deleteAllDecks();

  Future<List<Deck>> getAllDecks();
  Future<List<Deck>> getAllDecksWithFlashcards();
  Future<Deck> getDeckById(int deckId);
}