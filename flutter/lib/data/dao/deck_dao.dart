import 'package:flashcard/core/benchmark/log_exec_duration.dart';
import 'package:flashcard/data/entities/deck_db_entity.dart';
import 'package:floor/floor.dart';

import '../entities/deck_with_flashcard.dart';
import '../entities/flashcard_db_entity.dart';

@dao
abstract class DeckDao {
  @Query('SELECT * FROM deck where id = :deckId')
  Future<DeckDbEntity?> getDeckById(int deckId);

  @insert
  Future<int> createDeck(DeckDbEntity deck);

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

  @insert
  Future<void> addMultipleFlashcardsToDeck(List<FlashcardDbEntity> flashcards);

  @transaction
  Future<int> createDeckWithFlashcards(
      DeckDbEntity deck,
      List<FlashcardDbEntity> flashcards,
      ) async {
    final int deckId = await createDeck(deck);

    final flashcardsWithDeckId = flashcards
        .map((fc) => fc.copyWith(deckId: deckId))
        .toList();

    await addMultipleFlashcardsToDeck(flashcardsWithDeckId);
    return deckId;
  }

  Future<List<DeckWithFlashcardsDbEntity>> getAllDeckWithFlashcards() async {
    final decks = await logExecDuration(getAllDecks, name: 'Fetching all decks from DB',
        tag: 'db_read');
    final List<DeckWithFlashcardsDbEntity> decksWithFlashcards = [];

    for (final deck in decks) {
      final flashcards = await getFlashcardsByDeckId(deck.id!);
      if (flashcards.isNotEmpty) {
        decksWithFlashcards.add(DeckWithFlashcardsDbEntity(deck, flashcards));
      }
    }
    return decksWithFlashcards;
  }
}