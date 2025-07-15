import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:flutter/foundation.dart';

import '../../entities/deck_db_entity.dart';
import '../../entities/flashcard_db_entity.dart';

class DatabaseInitializer {
  static Future<void> initialize() async {
    try {
      final database = await LocalDatabaseService.database;

      if (kDebugMode) {
        print('Database initialized successfully');

        //TODO: Remove this in production
        await _addSampleData(database);
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
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