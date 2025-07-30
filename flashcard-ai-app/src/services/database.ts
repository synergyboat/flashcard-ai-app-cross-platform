import * as SQLite from 'expo-sqlite';
import { Deck, Flashcard } from '../types';
import { logDbRowSize, logTotalDbRowSize, logExecDuration } from '../utils/benchmarkUtils';

class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;

  async init() {
    this.db = await SQLite.openDatabaseAsync('flashcard_ai.db');
    await this.createTables();
    // Removed sample data insertion - database starts empty
  }

  private async createTables() {
    if (!this.db) return;

    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS decks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      );
    `);

    await this.db.execAsync(`
      CREATE TABLE IF NOT EXISTS flashcards (
        id TEXT PRIMARY KEY,
        deckId TEXT NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        lastReviewed TEXT,
        FOREIGN KEY (deckId) REFERENCES decks (id) ON DELETE CASCADE
      );
    `);
  }



  async getDecks(): Promise<Deck[]> {
    if (!this.db) return [];

    const decks = await this.db.getAllAsync(`
      SELECT d.*, COUNT(f.id) as flashcardCount 
      FROM decks d 
      LEFT JOIN flashcards f ON d.id = f.deckId 
      GROUP BY d.id 
      ORDER BY d.updatedAt DESC
    `);

    return decks.map((deck: any) => ({
      id: deck.id,
      name: deck.name,
      description: deck.description,
      createdAt: new Date(deck.createdAt),
      updatedAt: new Date(deck.updatedAt),
      flashcardCount: deck.flashcardCount || 0,
    }));
  }

  async getDeck(id: string): Promise<Deck | null> {
    if (!this.db) return null;

    const decks = await this.db.getAllAsync('SELECT * FROM decks WHERE id = ?', [id]);
    if (decks.length === 0) return null;

    const deck = decks[0] as any;
    return {
      id: deck.id,
      name: deck.name,
      description: deck.description,
      createdAt: new Date(deck.createdAt),
      updatedAt: new Date(deck.updatedAt),
    };
  }

  async getFlashcards(deckId: string): Promise<Flashcard[]> {
    if (!this.db) return [];

    const flashcards = await this.db.getAllAsync(
      'SELECT * FROM flashcards WHERE deckId = ? ORDER BY createdAt ASC',
      [deckId]
    );

    return flashcards.map((card: any) => ({
      id: card.id,
      deckId: card.deckId,
      question: card.question,
      answer: card.answer,
      createdAt: new Date(card.createdAt),
      updatedAt: new Date(card.updatedAt),
      lastReviewed: card.lastReviewed ? new Date(card.lastReviewed) : undefined,
    }));
  }

  async createDeck(deck: Omit<Deck, 'id' | 'createdAt' | 'updatedAt'>): Promise<string> {
    if (!this.db) throw new Error('Database not initialized');

    const id = Date.now().toString();
    const now = new Date().toISOString();

    await this.db.runAsync(
      'INSERT INTO decks (id, name, description, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?)',
      [id, deck.name, deck.description || '', now, now]
    );

    return id;
  }

  async createFlashcards(flashcards: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>[]): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    const now = new Date().toISOString();

    for (const card of flashcards) {
      const id = Date.now().toString() + Math.random().toString(36).substr(2, 9);
      await this.db.runAsync(
        'INSERT INTO flashcards (id, deckId, question, answer, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?)',
        [id, card.deckId, card.question, card.answer, now, now]
      );
    }
  }

  async updateFlashcardReview(id: string): Promise<void> {
    if (!this.db) return;

    const now = new Date().toISOString();
    await this.db.runAsync(
      'UPDATE flashcards SET lastReviewed = ? WHERE id = ?',
      [now, id]
    );
  }

  async deleteDeck(id: string): Promise<void> {
    if (!this.db) return;

    await this.db.runAsync('DELETE FROM decks WHERE id = ?', [id]);
  }

  // Method to clear all data (useful for testing)
  async clearAllData(): Promise<void> {
    if (!this.db) return;

    await this.db.runAsync('DELETE FROM flashcards');
    await this.db.runAsync('DELETE FROM decks');
  }

  // Benchmark database operations
  async benchmarkDatabase(): Promise<void> {
    const demoDeck = {
      name: 'Benchmark Deck',
      description: 'A deck for benchmarking purposes',
    };

    // Log the size of the deck entity
    logDbRowSize(demoDeck, {
      name: 'Demo Deck',
      tag: 'db_row_size_add_demo_Deck'
    });

    const deckId = await logExecDuration(
      () => this.createDeck(demoDeck),
      {
        name: 'Adding demo deck to DB',
        tag: 'db_write_add_demo_deck'
      }
    );

    const demoFlashcard = {
      deckId,
      question: 'What is the capital of Germany?',
      answer: 'Berlin',
    };

    // Log the size of the flashcard entity
    logDbRowSize(demoFlashcard, {
      name: 'Demo Flashcard',
      tag: 'db_row_size_add_demo_flashcard'
    });

    await logExecDuration(
      () => this.createFlashcards([demoFlashcard]),
      {
        name: 'Adding demo flashcard to DB',
        tag: 'db_write_add_demo_flashcard'
      }
    );

    const demoDeckFetched = await logExecDuration(
      () => this.getDeck(deckId),
      {
        name: 'Fetching demo deck from DB',
        tag: 'db_read_fetch_demo_deck'
      }
    );

    if (demoDeckFetched) {
      logDbRowSize(demoDeckFetched, {
        name: 'Fetched Demo Deck',
        tag: 'db_row_size_fetched_demo_deck'
      });
    }

    const demoFlashcards = await logExecDuration(
      () => this.getFlashcards(deckId),
      {
        name: 'Fetching flashcards for demo deck',
        tag: 'db_read_fetch_demo_flashcards'
      }
    );

    logTotalDbRowSize(
      demoFlashcards,
      {
        name: 'Fetched Demo Flashcards',
        tag: 'db_row_size_fetched_demo_flashcards'
      }
    );
  }
}

export const databaseService = new DatabaseService(); 