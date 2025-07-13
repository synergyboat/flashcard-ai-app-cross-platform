import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:flutter/foundation.dart';

import '../../entities/deck_db_entity.dart';
import '../../entities/flashcard_db_entity.dart';

class DatabaseInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize the database
      final database = await LocalDatabaseService.database;

      if (kDebugMode) {
        print('Database initialized successfully');

        // Optional: Add sample data in debug mode
        await _addSampleData(database);
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }

  static Future<void> _addSampleData(LocalAppDatabase database) async {
    try {
      // Check if we already have data
      final existingDecks = await database.deckDao.getAllDecks();

      if (existingDecks.isEmpty) {
        // Create sample deck
        final sampleDeck = DeckDbEntity(
          name: 'Sample Deck',
          description: 'A sample deck with basic flashcards',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await database.deckDao.createDeck(sampleDeck);

        // Get the created deck to get its ID
        final createdDecks = await database.deckDao.getAllDecks();
        final deckId = createdDecks.first.id!;

        // Create sample flashcards
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