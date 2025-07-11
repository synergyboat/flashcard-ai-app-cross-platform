import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:floor/floor.dart';

@dao
abstract class FlashcardDao {
  @insert
  Future<void> createFlashcard(String question, String answer);

  @Query('SELECT * FROM flashcard WHERE deckId = :deckId')
  Future<List<FlashcardDbEntity>> getAllFlashcardsFromDeckId(String deckId);
}