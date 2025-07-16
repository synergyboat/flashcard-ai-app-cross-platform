import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flashcard/domain/repository/flashcard_repository.dart';

import '../../sources/database/local/local_database_service.dart';

class FlashcardRepositoryImpl implements FlashcardRepository{

  final LocalAppDatabase _localDatabaseService;

  const FlashcardRepositoryImpl(
      this._localDatabaseService
      );

  @override
  Future<void> addFlashcardToDeck(int deckId, Flashcard flashcard) {
    final flashcardWithDeck = flashcard.copyWith(deckId: deckId);
    return _localDatabaseService.flashcardDao.createFlashcard(
      FlashcardDbEntity.fromFlashcard(
        flashcardWithDeck,
      ),
    );
  }

  @override
  Future<void> addMultipleFlashcardsToDeck(int deckId, List<Flashcard> flashcards) async {
     List<FlashcardDbEntity> flashcardEntities = flashcards.map((flashcard) {
      return FlashcardDbEntity.fromFlashcard(flashcard.copyWith(deckId: deckId));
    }).toList();

     for (final flashcardDbEntity in flashcardEntities) {
       if (flashcardDbEntity.deckId == null) {
         throw Exception("Deck ID is null for flashcard: ${flashcardDbEntity.question}");
       }
       await _localDatabaseService.flashcardDao.createFlashcard(flashcardDbEntity);
     }
  }

  @override
  Future<void> deleteFlashcard(Flashcard flashcard) {
    return _localDatabaseService.flashcardDao.deleteFlashcard(
      FlashcardDbEntity.fromFlashcard(flashcard),
    );
  }

  @override
  Future<void> deleteFlashcardById(int flashcardId) {
    return _localDatabaseService.flashcardDao.deleteFlashcardById(flashcardId);
  }

  @override
  Future<void> deleteFlashcardsByDeckId(int deckId) {
    return _localDatabaseService.flashcardDao.deleteFlashcardById(deckId);
  }

  @override
  Future<List<Flashcard>> getAllFlashcards() {
    // TODO: implement getAllFlashcards
    throw UnimplementedError();
  }

  @override
  Future<Flashcard> getFlashcardById(int flashcardId) {
    // TODO: implement getFlashcardById
    throw UnimplementedError();
  }

  @override
  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId) {
    return _localDatabaseService.flashcardDao.getAllFlashcardsFromDeckId(deckId).then((flashcardEntities) {
      return flashcardEntities.map((flashcardEntity) => flashcardEntity.toFlashcard()).toList();
    });
  }

  @override
  Future<void> updateFlashcard(Flashcard updatedFlashcard) {
    return _localDatabaseService.flashcardDao.updateFlashcard(
      FlashcardDbEntity.fromFlashcard(updatedFlashcard),
    );
  }

}