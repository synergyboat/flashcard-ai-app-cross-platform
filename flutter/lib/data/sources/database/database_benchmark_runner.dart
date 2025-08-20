import 'dart:ffi';

import 'package:flashcard/core/benchmark/log_exec_duration.dart';
import 'package:flashcard/data/entities/deck_with_flashcard.dart';
import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../../core/benchmark/log_db_row_size.dart';
import '../../../domain/entities/deck.dart';
import '../../entities/deck_db_entity.dart';
import '../../entities/flashcard_db_entity.dart';
import 'dart:convert';
import 'dart:typed_data';

class DatabaseBenchmarkRow {
  final int iteration;
  final int dbRowSizeAddDemoDeck;
  final double dbWriteAddDemoDeck;
  final int dbRowSizeAddDemoFlashcard;
  final double dbWriteAddDemoFlashcard;
  final double dbReadFetchDemoDeck;
  final int dbRowSizeFetchedDemoDeck;
  final double dbReadFetchDemoFlashcards;
  final int dbRowSizeFetchedDemoFlashcards;
  final double dbRead;
  final double dbReadGetAllDecksWithFlashcards;
  final int dbRowSizeGetAllDecksWithFlashcards;

  DatabaseBenchmarkRow({
    required this.iteration,
    required this.dbRowSizeAddDemoDeck,
    required this.dbWriteAddDemoDeck,
    required this.dbRowSizeAddDemoFlashcard,
    required this.dbWriteAddDemoFlashcard,
    required this.dbReadFetchDemoDeck,
    required this.dbRowSizeFetchedDemoDeck,
    required this.dbReadFetchDemoFlashcards,
    required this.dbRowSizeFetchedDemoFlashcards,
    required this.dbRead,
    required this.dbReadGetAllDecksWithFlashcards,
    required this.dbRowSizeGetAllDecksWithFlashcards,
  });

  String toCsv() {
    return [
      iteration,
      dbRowSizeAddDemoDeck,
      dbWriteAddDemoDeck.toStringAsFixed(2),
      dbRowSizeAddDemoFlashcard,
      dbWriteAddDemoFlashcard.toStringAsFixed(2),
      dbReadFetchDemoDeck.toStringAsFixed(2),
      dbRowSizeFetchedDemoDeck,
      dbReadFetchDemoFlashcards.toStringAsFixed(2),
      dbRowSizeFetchedDemoFlashcards,
      dbRead.toStringAsFixed(2),
      dbReadGetAllDecksWithFlashcards.toStringAsFixed(2),
      dbRowSizeGetAllDecksWithFlashcards,
    ].join(',');
  }

  static String csvHeader() {
    return [
      'Iteration',
      'db_row_size_add_demo_Deck (B)',
      'db_write_add_demo_deck (ms)',
      'db_row_size_add_demo_flashcard (B)',
      'db_write_add_demo_flashcard (ms)',
      'db_read_fetch_demo_deck (ms)',
      'db_row_size_fetched_demo_deck (B)',
      'db_read_fetch_demo_flashcards (ms)',
      'db_row_size_fetched_demo_flashcards (B)',
      'db_read (ms)',
      'db_read_getAllDecksWithFlashcards (ms)',
      'db_row_size_getAllDecksWithFlashcards (B)'
    ].join(',');
  }
}

class DatabaseBenchmarkRunner {

  static void logInChunks(String message, Logger logger, {int chunkSize = 80, String tag = 'db_benchmark'}) {
    // Split and print the string in chunks to avoid console truncation
    for (var i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length) ? i + chunkSize : message.length;
      logger.i('$tag [${i ~/ chunkSize}] ${message.substring(i, end)}');
    }
  }

  static Future<void> run({
    required LocalAppDatabase database,
    required Logger logger,
    int iterations = 1,
  }) async {
    final results = <DatabaseBenchmarkRow>[];

    for (int i = 0; i < iterations; i++) {
      final row = await _benchmarkOnce(database, logger, i + 1);
      results.add(row);
    }

    logInChunks('FLUTTER_DB: ${DatabaseBenchmarkRow.csvHeader()}\n', logger);
    for (final row in results) {

      logInChunks(row.toCsv(), logger);
    }
  }

  static int sizeBytes(Map<String, dynamic> obj) {
    final json = jsonEncode(obj);
    return Uint8List.fromList(utf8.encode(json)).lengthInBytes;
  }

  static Future<DatabaseBenchmarkRow> _benchmarkOnce(
      LocalAppDatabase database, Logger logger, int iteration) async {
    // --- 1. Add Deck ---
    final Deck demoDeck = Deck(
      name: 'Benchmark Deck',
      description: 'A deck for benchmarking purposes',
    );
    final DeckDbEntity demoDeckEntity = DeckDbEntity.fromDeck(demoDeck);

    logDbRowSize(
      demoDeckEntity.toMap(),
      name: 'Demo Deck',
      tag: 'db_row_size_add_demo_Deck',
      logger: logger,
    );
    final int dbRowSizeAddDemoDeck = sizeBytes(demoDeckEntity.toMap());
     // Use actual byte logic if available

    final swDeck = Stopwatch()..start();
    final int deckId = await logExecDuration(
          () => database.deckDao.createDeck(demoDeckEntity),
      name: 'Adding demo deck to DB',
      tag: 'db_write_add_demo_deck',
    );
    final double dbWriteAddDemoDeck = swDeck.elapsedMicroseconds / 1000.0;

    // --- 2. Add Flashcard ---
    final Flashcard demoFlashcard = Flashcard(
      question: 'What is the capital of Germany?',
      answer: 'Berlin',
    );
    final FlashcardDbEntity demoFlashcardEntity =
    FlashcardDbEntity.fromFlashcard(demoFlashcard);

    logDbRowSize(
      demoFlashcardEntity.toMap(),
      name: 'Demo Flashcard',
      tag: 'db_row_size_add_demo_flashcard',
      logger: logger,
    );
    final int dbRowSizeAddDemoFlashcard = sizeBytes(demoFlashcardEntity.toMap());

    final swFlashcard = Stopwatch()..start();
    await logExecDuration(
          () => database.flashcardDao
          .createFlashcard(demoFlashcardEntity.copyWith(deckId: deckId)),
      name: 'Adding demo flashcard to DB',
      tag: 'db_write_add_demo_flashcard',
    );
    final double dbWriteAddDemoFlashcard =
        swFlashcard.elapsedMicroseconds / 1000.0;

    // --- 3. Fetch Deck by ID ---
    final swFetchDeck = Stopwatch()..start();
    final DeckDbEntity demoDeckFetched = await logExecDuration(
          () => database.deckDao.getDeckById(deckId),
      name: 'Fetching demo deck from DB',
      tag: 'db_read_fetch_demo_deck',
    ) ??
        DeckDbEntity(name: 'Not Found', description: 'Not Found');
    final double dbReadFetchDemoDeck = swFetchDeck.elapsedMicroseconds / 1000.0;

    logDbRowSize(
      demoDeckFetched.toMap(),
      name: 'Fetched Demo Deck',
      tag: 'db_row_size_fetched_demo_deck',
      logger: logger,
    );
    final int dbRowSizeFetchedDemoDeck = sizeBytes(demoDeckFetched.toMap());

    // --- 4. Fetch Flashcards by DeckId ---
    final swFetchFlashcards = Stopwatch()..start();
    final List<FlashcardDbEntity> demoFlashcards = await logExecDuration(
          () => database.deckDao.getFlashcardsByDeckId(deckId),
      name: 'Fetching flashcards for demo deck',
      tag: 'db_read_fetch_demo_flashcards',
    );
    final double dbReadFetchDemoFlashcards =
        swFetchFlashcards.elapsedMicroseconds / 1000.0;

    logTotalDbRowSize(
      demoFlashcards.map((fc) => fc.toMap()).toList(),
      name: 'Fetched Demo Flashcards',
      tag: 'db_row_size_fetched_demo_flashcards',
      logger: logger,
    );
    final int dbRowSizeFetchedDemoFlashcards =
    sizeBytes({'flashcards': demoFlashcards.map((fc) => fc.toMap()).toList()});

    // --- 5. Read all Decks (db_read) ---
    final swReadAll = Stopwatch()..start();
    await logExecDuration(
          () => database.deckDao.getAllDecks(),
      name: 'General read (all decks)',
      tag: 'db_read',
    );
    final double dbRead = swReadAll.elapsedMicroseconds / 1000.0;

    // --- 6. Read all Decks with Flashcards ---
    final swAllWF = Stopwatch()..start();
    // Fetch all decks with their associated flashcards
    // This operation retrieves all decks and their flashcards in a single query.
    final List<DeckWithFlashcardsDbEntity> allDecksWithFlashcards =
    await logExecDuration<List<DeckWithFlashcardsDbEntity>>(() => database.deckDao.getAllDeckWithFlashcards.call(),
      name: 'Fetching all decks with flashcards',
      tag: 'db_read_getAllDecksWithFlashcards',
    );

    // Convert the list of DeckWithFlashcardsDbEntity to a list of Map<String, dynamic>
    // This is necessary for logging the size of the data retrieved from the database.
    final List<Map<String, dynamic>> allDecksWithFlashcardsMaps = allDecksWithFlashcards
        .map((e) => e.toMap())
        .toList();

    // Log the total size of all decks with flashcards
    logTotalDbRowSize(
      allDecksWithFlashcardsMaps,
      name: 'All Decks With Flashcards',
      tag: 'db_row_size_getAllDecksWithFlashcards',
      logger: logger,
    );

    // Calculate the size of the data retrieved from the database
    final int dbRowSizeGetAllDecksWithFlashcards = sizeBytes({'decks': allDecksWithFlashcardsMaps});
    // Log the size of each deck and its flashcards
    final double dbReadGetAllDecksWithFlashcards =
        swAllWF.elapsedMicroseconds / 1000.0;

    // --- 7. Cleanup: Delete Deck (cascade deletes flashcards if schema is setup) ---
    try {
      await database.deckDao.deleteDeck(deckId);
    } catch (e) {
      logger.w('Cleanup deleteDeck failed: $e');
    }

    return DatabaseBenchmarkRow(
      iteration: iteration,
      dbRowSizeAddDemoDeck: dbRowSizeAddDemoDeck,
      dbWriteAddDemoDeck: dbWriteAddDemoDeck,
      dbRowSizeAddDemoFlashcard: dbRowSizeAddDemoFlashcard,
      dbWriteAddDemoFlashcard: dbWriteAddDemoFlashcard,
      dbReadFetchDemoDeck: dbReadFetchDemoDeck,
      dbRowSizeFetchedDemoDeck: dbRowSizeFetchedDemoDeck,
      dbReadFetchDemoFlashcards: dbReadFetchDemoFlashcards,
      dbRowSizeFetchedDemoFlashcards: dbRowSizeFetchedDemoFlashcards,
      dbRead: dbRead,
      dbReadGetAllDecksWithFlashcards: dbReadGetAllDecksWithFlashcards,
      dbRowSizeGetAllDecksWithFlashcards: dbRowSizeGetAllDecksWithFlashcards,
    );
  }
}