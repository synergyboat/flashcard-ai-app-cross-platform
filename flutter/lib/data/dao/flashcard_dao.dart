import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class FlashcardDao {
  @insert
  Future<void> createFlashcard(FlashcardDbEntity flashcard);

  @Query('SELECT * FROM flashcard WHERE deckId = :deckId')
  Future<List<FlashcardDbEntity>> getAllFlashcardsFromDeckId(int deckId);

  @update
  Future<void> updateFlashcard(FlashcardDbEntity flashcard);

  @delete
  Future<void> deleteFlashcard(FlashcardDbEntity flashcard);

  @Query('DELETE FROM flashcard WHERE id = :flashcardId')
  Future<void> deleteFlashcardById(int flashcardId);
}