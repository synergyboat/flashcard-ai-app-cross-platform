import 'package:flashcard/data/entities/deck_db_entity.dart';
import 'package:floor/floor.dart';

abstract class DeckDao {
  @Query('SELECT * FROM deck where id = :deckId')
  Future<DeckDbEntity?> getDeckById(String deckId);

  @insert
  Future<void> createDEck(DeckDbEntity deck);

  @Query('SELECT * FROM deck')
  Future<List<DeckDbEntity>> getAllDecks();

  @update
  Future<void> updateDeck(DeckDbEntity deck);

  @Query('DELETE FROM deck WHERE id = :deckId')
  Future<void> deleteDeck(String deckId);
}