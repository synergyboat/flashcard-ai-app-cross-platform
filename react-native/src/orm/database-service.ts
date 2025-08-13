import * as SQLite from 'expo-sqlite';
import { DeckEntity } from './entities/deck-entity';
import { FlashcardEntity } from './entities/flashcard-entity';
import { DeckDao } from './dao/deck-dao';
import { FlashcardDao } from './dao/flashcard-dao';
import { DATABASE_CONFIG } from '../config';

export class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;
  private deckDao: DeckDao | null = null;
  private flashcardDao: FlashcardDao | null = null;

  async init(): Promise<void> {
    this.db = await SQLite.openDatabaseAsync(DATABASE_CONFIG.NAME);

    // Create tables if they don't exist
    await this.createTables();
    
    this.deckDao = new DeckDao(this.db);
    this.flashcardDao = new FlashcardDao(this.db);
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    try {
      // Create deck table
      const deckTableSQL = DeckEntity.generateCreateTableSQL();
      console.log('Creating deck table:', deckTableSQL);
      await this.db.runAsync(deckTableSQL);

      // Create flashcard table
      const flashcardTableSQL = FlashcardEntity.generateCreateTableSQL();
      console.log('Creating flashcard table:', flashcardTableSQL);
      await this.db.runAsync(flashcardTableSQL);

      console.log('Database tables created successfully');
    } catch (error) {
      console.error('Error creating database tables:', error);
      throw error;
    }
  }

  // Deck operations
  get decks(): DeckDao {
    if (!this.deckDao) {
      throw new Error('Database not initialized');
    }
    return this.deckDao;
  }

  // Flashcard operations
  get flashcards(): FlashcardDao {
    if (!this.flashcardDao) {
      throw new Error('Database not initialized');
    }
    return this.flashcardDao;
  }

  // Clear all data (useful for testing)
  async clearAllData(): Promise<void> {
    if (!this.db) return;

    await this.db.runAsync('DELETE FROM flashcard');
    await this.db.runAsync('DELETE FROM deck');
  }
}

// Export singleton instance
export const databaseService = new DatabaseService();