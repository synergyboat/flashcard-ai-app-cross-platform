import 'package:flashcard/core/benchmark/get_db_row_size.dart';
import 'package:flashcard/core/benchmark/log_exec_duration.dart';
import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flashcard/domain/repository/flashcard_repository.dart';
import 'package:logger/logger.dart';

import '../../../core/benchmark/log_db_row_size.dart';
import '../../../core/config/di/config_di.dart';
import '../../sources/database/local/local_database_service.dart';

class FlashcardRepositoryImpl implements FlashcardRepository{

  final LocalAppDatabase _localDatabaseService;
  final Logger _logger;

  const FlashcardRepositoryImpl(
      this._localDatabaseService,
      this._logger,
      );

  @override
  Future<void> addFlashcardToDeck(int deckId, Flashcard flashcard) {
    final flashcardWithDeck = flashcard.copyWith(deckId: deckId);
    // Log the size of the flashcard being added to the deck
    // Only for benchmarking purposes
    logDbRowSize(
      FlashcardDbEntity.fromFlashcard(flashcardWithDeck).toMap(),
      name: 'Flashcard',
      tag: 'db_row_size',
      logger: _logger,
    );

    return logExecDuration(()=>_localDatabaseService.flashcardDao.createFlashcard(
      FlashcardDbEntity.fromFlashcard(
        flashcardWithDeck,
      ),
    ),
      name: 'Adding flashcard to deck $deckId',
      tag: 'db_write',
      logger: _logger,
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
    return logExecDuration(()=>_localDatabaseService.flashcardDao.getAllFlashcardsFromDeckId(deckId)).then((flashcardEntities) {
      // Log the size of the flashcards being fetched
      logTotalDbRowSize(
        flashcardEntities.map((e) => e.toMap()).toList(),
        name: 'Flashcards from deck $deckId',
        tag: 'db_row_size',
        logger: _logger,
      );
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