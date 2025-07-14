import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../dao/deck_dao.dart';
import '../../../dao/flashcard_dao.dart';
import '../../../entities/deck_db_entity.dart';
import '../../../entities/flashcard_db_entity.dart';
import '../../../../core/utils/date_time_converter.dart';

part 'local_database_service.g.dart';

@TypeConverters([DateTimeConverter])
@Database(
  version: 1,
  entities: [
    DeckDbEntity,
    FlashcardDbEntity,
  ],
)
abstract class LocalAppDatabase extends FloorDatabase {
  DeckDao get deckDao;
  FlashcardDao get flashcardDao;
}

class LocalDatabaseService {
  static LocalAppDatabase? _database;

  static Future<LocalAppDatabase> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<LocalAppDatabase> _initDatabase() async {
    return await $FloorLocalAppDatabase
        .databaseBuilder('flashcard_app.db')
        .addMigrations([])
        .build();
  }

  static Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  static Future<void> deleteDatabase() async {
    await closeDatabase();
    final databasesPath = await sqflite.getDatabasesPath();
    final path = '$databasesPath/flashcard_app.db';
    await sqflite.deleteDatabase(path);
  }
}