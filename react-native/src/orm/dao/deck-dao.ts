import * as SQLite from 'expo-sqlite';
import { BaseRepository } from '../base-repository';
import { DeckEntity } from '../entities/deck-entity';
import { FlashcardEntity } from '../entities/flashcard-entity';

export class DeckDao extends BaseRepository<DeckEntity> {
  constructor(db: SQLite.SQLiteDatabase) {
    super(db, DeckEntity);
  }

  async getAllDecks(): Promise<DeckEntity[]> {
    const sql = `
      SELECT d.*, COUNT(f.id) as flashcardCount 
      FROM deck d 
      LEFT JOIN flashcard f ON d.id = f.deckId 
      GROUP BY d.id 
      ORDER BY d.updatedAt DESC
    `;
    
    const rows = await this.executeQuery(sql);
    return rows.map(row => {
      const deck = DeckEntity.fromRow(row);
      (deck as any).flashcardCount = row.flashcardCount || 0;
      return deck;
    });
  }

  async getDeckById(deckId: number): Promise<DeckEntity | null> {
    return await this.findById(deckId);
  }

  async createDeck(deck: DeckEntity): Promise<number> {
    deck.setTimestamps();
    const savedDeck = await this.insert(deck);
    return savedDeck.id!;
  }

  async updateDeck(deck: DeckEntity): Promise<void> {
    deck.setTimestamps();
    await this.update(deck);
  }

  async deleteDeck(deckId: number): Promise<void> {
    await this.deleteById(deckId);
  }

  async deleteDeckEntity(deck: DeckEntity): Promise<void> {
    await this.delete(deck);
  }

  async getFlashcardsByDeckId(deckId: number): Promise<FlashcardEntity[]> {
    const sql = 'SELECT * FROM flashcard WHERE deckId = ? ORDER BY createdAt ASC';
    const rows = await this.executeQuery(sql, [deckId]);
    return rows.map(row => FlashcardEntity.fromRow(row));
  }


}