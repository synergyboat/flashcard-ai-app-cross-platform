import '../entities/deck.dart';

abstract class DeckRepository {
  Future<void> addDeck(Deck deck);
  Future<void> updateDeck(Deck updatedDeck);

  Future<void> deleteDeckById(Deck deck);
  Future<void> deleteDeck(Deck deck);
  Future<void> deleteAllDecks();

  Future<List<Deck>> getAllDecks();
  Future<Deck> getDeckById(int deckId);
}