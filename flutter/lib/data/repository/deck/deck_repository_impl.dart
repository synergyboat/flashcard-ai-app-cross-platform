import 'package:flashcard/data/entities/deck_db_entity.dart';
import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:flashcard/data/sources/database/local/local_database_service.dart';

import '../../../domain/entities/deck.dart';
import '../../../domain/repository/deck_repository.dart';

class DeckRepositoryImpl implements DeckRepository {
  final LocalAppDatabase _localDatabaseService;

  DeckRepositoryImpl(
      this._localDatabaseService
      );

  @override
  Future<int> addDeck(Deck deck) async {
    if (deck.flashcards.isEmpty) {
      return await _localDatabaseService.deckDao.createDeck(DeckDbEntity.fromDeck(deck));
    }
    List<FlashcardDbEntity> deckWithFlashcards = deck.flashcards.map((flashcard) {
      return FlashcardDbEntity.fromFlashcard(flashcard);
    }).toList();

    return await _localDatabaseService.deckDao.createDeckWithFlashcards(
        DeckDbEntity.fromDeck(deck),
        deckWithFlashcards);
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
    return _localDatabaseService.deckDao.getAllDeckWithFlashcards().then((deckEntities) {
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