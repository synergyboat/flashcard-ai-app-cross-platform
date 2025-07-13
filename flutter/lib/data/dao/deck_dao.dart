import 'package:flashcard/data/entities/deck_db_entity.dart';
import 'package:floor/floor.dart';

import '../entities/deck_with_flashcard.dart';
import '../entities/flashcard_db_entity.dart';

@dao
abstract class DeckDao {
  @Query('SELECT * FROM deck where id = :deckId')
  Future<DeckDbEntity?> getDeckById(int deckId);

  @insert
  Future<void> createDeck(DeckDbEntity deck);

  @Query('SELECT * FROM deck')
  Future<List<DeckDbEntity>> getAllDecks();

  @Query('SELECT * FROM flashcard WHERE deckId = :deckId')
  Future<List<FlashcardDbEntity>> getFlashcardsByDeckId(int deckId);

  @update
  Future<void> updateDeck(DeckDbEntity deck);

  @Query('DELETE FROM deck WHERE id = :deckId')
  Future<void> deleteDeck(int deckId);

  @delete
  Future<void> deleteDeckEntity(DeckDbEntity deck);

  Future<DeckWithFlashcardsDbEntity?> getDeckWithFlashcards(int deckId) async {
    final deck = await getDeckById(deckId);
    if (deck == null) return null;

    final flashcards = await getFlashcardsByDeckId(deckId);
    return DeckWithFlashcardsDbEntity(deck, flashcards);
  }
}