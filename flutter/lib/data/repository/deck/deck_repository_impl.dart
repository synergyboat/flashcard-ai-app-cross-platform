import 'package:flashcard/core/benchmark/log_db_row_size.dart';
import 'package:flashcard/core/benchmark/log_exec_duration.dart';
import 'package:flashcard/data/entities/deck_db_entity.dart';
import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:logger/logger.dart';

import '../../../core/benchmark/get_db_row_size.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/repository/deck_repository.dart';

class DeckRepositoryImpl implements DeckRepository {
  final LocalAppDatabase _localDatabaseService;
  final Logger _logger;

  DeckRepositoryImpl(
      this._localDatabaseService,
      this._logger
      );

  @override
  Future<int> addDeck(Deck deck) async {
    logDbRowSize(DeckDbEntity.fromDeck(deck).toMap(), name: 'Deck', tag: 'db_row_size_addDeck', logger: _logger);
    if (deck.flashcards.isEmpty) {
      return await logExecDuration(()=>_localDatabaseService.deckDao.createDeck(DeckDbEntity.fromDeck(deck)),
          name: 'Adding deck without flashcards to DB',
          tag: 'db_write_addDeckWithoutFlashcards',
          logger: _logger
      );
    }
    List<FlashcardDbEntity> deckWithFlashcards = deck.flashcards.map((flashcard) {
      return FlashcardDbEntity.fromFlashcard(flashcard);
    }).toList();

    return await logExecDuration(()=>_localDatabaseService.deckDao.createDeckWithFlashcards(
        DeckDbEntity.fromDeck(deck),
        deckWithFlashcards),
        name: 'Adding deck with flashcards to DB',
        tag: 'db_write_addDeckWithFlashcards',
        logger: _logger);
  }

  @override
  Future<void> deleteAllDecks() {
    // TODO: implement deleteAllDecks
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(Deck deck) async {
    await _localDatabaseService.deckDao.deleteDeckEntity(DeckDbEntity.fromDeck(deck));
  }

  @override
  Future<void> deleteDeckById(Deck deck) async {
    await _localDatabaseService.deckDao.deleteDeck(deck.id!);
  }

  @override
  Future<List<Deck>> getAllDecks() {
    return _localDatabaseService.deckDao.getAllDecks().then((deckEntities) {
      return deckEntities.map((deckEntity) => deckEntity.toDeck()).toList();
    });
  }

  @override
  Future<List<Deck>> getAllDecksWithFlashcards() {
    return logExecDuration(()=>_localDatabaseService.deckDao.getAllDeckWithFlashcards(),
        name: 'Fetching all decks with flashcards from DB', tag: 'db_read_getAllDecksWithFlashcards')
        .then((deckEntities) {
          // Log the size of the fetched decks
      logTotalDbRowSize(
          deckEntities.map((e) => e.deck.toMap()).toList(),
          name: 'Decks with flashcards',
          tag: 'db_row_size_getAllDecksWithFlashcards',
          logger: _logger,
      );
          return deckEntities.map(
              (deckEntity) => deckEntity.deck
                  .toDeck()
                  .copyWith(flashcards: deckEntity.flashcards.map(
                      (flashcardEntity) => flashcardEntity.toFlashcard()).toList()
              )).toList();
    });
  }

  @override
  Future<Deck> getDeckById(int deckId) {
    return _localDatabaseService.deckDao.getDeckById(deckId).then((deckEntity) {
      if (deckEntity == null) {
        throw Exception('Deck not found');
      }
      return deckEntity.toDeck();
    });
  }

  @override
  Future<void> updateDeck(Deck updatedDeck) {
    return _localDatabaseService.deckDao.updateDeck(DeckDbEntity.fromDeck(updatedDeck));
  }
}