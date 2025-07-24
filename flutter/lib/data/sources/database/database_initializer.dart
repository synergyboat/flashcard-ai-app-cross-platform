import 'package:flashcard/core/benchmark/log_exec_duration.dart';
import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../core/benchmark/log_db_row_size.dart';
import '../../../domain/entities/deck.dart';
import '../../entities/deck_db_entity.dart';
import '../../entities/flashcard_db_entity.dart';

class DatabaseInitializer {
  static Future<void> initialize() async {
    try {
      final database = await LocalDatabaseService.database;

      if (kDebugMode) {
        print('Database initialized successfully');

        //TODO: Remove this in production
       // await _addSampleData(database);
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }

  static Future<void> benchmarkDatabase(LocalAppDatabase database, Logger logger) async {
    final Deck demoDeck = Deck(
      name: 'Benchmark Deck',
      description: 'A deck for benchmarking purposes',
    );

    final DeckDbEntity demoDeckEntity = DeckDbEntity.fromDeck(demoDeck);

    // Log the size of the deck entity
    logDbRowSize(demoDeckEntity.toMap(), name: 'Demo Deck', tag: 'db_row_size_add_demo_Deck', logger: logger);

    final int deckId = await logExecDuration(
            ()=>database.deckDao.createDeck(demoDeckEntity),
            name: 'Adding demo deck to DB',
            tag: 'db_write_add_demo_deck',
    );

    final Flashcard demoFlashcard = Flashcard(
      question: 'What is the capital of Germany?',
      answer: 'Berlin',
    );

    final FlashcardDbEntity demoFlashcardEntity = FlashcardDbEntity.fromFlashcard(demoFlashcard);

    // Log the size of the flashcard entity
    logDbRowSize(demoFlashcardEntity.toMap(), name: 'Demo Flashcard', tag: 'db_row_size_add_demo_flashcard', logger: logger);

    await logExecDuration(
            ()=> database.flashcardDao.createFlashcard(demoFlashcardEntity.copyWith(deckId: deckId)),
            name: 'Adding demo flashcard to DB',
            tag: 'db_write_add_demo_flashcard',
    );

    final DeckDbEntity demoDeckFetched = await logExecDuration(
            ()=> database.deckDao.getDeckById(deckId),
            name: 'Fetching demo deck from DB',
            tag: 'db_read_fetch_demo_deck',
    ) ?? DeckDbEntity(name: 'Not Found', description: 'Not Found');

    logDbRowSize(demoDeckFetched.toMap(), name: 'Fetched Demo Deck', tag: 'db_row_size_fetched_demo_deck', logger: logger);

    final List<FlashcardDbEntity> demoFlashcards = await logExecDuration(
            ()=> database.deckDao.getFlashcardsByDeckId(deckId),
            name: 'Fetching flashcards for demo deck',
            tag: 'db_read_fetch_demo_flashcards',
    );

    logTotalDbRowSize(
      demoFlashcards.map((fc) => fc.toMap()).toList(),
      name: 'Fetched Demo Flashcards',
      tag: 'db_row_size_fetched_demo_flashcards',
      logger: logger,
    );

  }

  // TODO: Remove this method in production
  static Future<void> _addSampleData(LocalAppDatabase database) async {
    try {
      final existingDecks = await database.deckDao.getAllDecks();

      if (existingDecks.isEmpty) {
        final sampleDeck = DeckDbEntity(
          name: 'Sample Deck',
          description: 'A sample deck with basic flashcards',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await database.deckDao.createDeck(sampleDeck);
        final createdDecks = await database.deckDao.getAllDecks();
        final deckId = createdDecks.first.id!;
        final sampleFlashcards = [
          FlashcardDbEntity(
            deckId: deckId,
            question: 'What is the capital of France?',
            answer: 'Paris',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          FlashcardDbEntity(
            deckId: deckId,
            question: 'What is 2 + 2?',
            answer: '4',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (final flashcard in sampleFlashcards) {
          await database.flashcardDao.createFlashcard(flashcard);
        }
        if (kDebugMode) {
          print('Sample data added successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding sample data: $e');
      }
    }
  }
}