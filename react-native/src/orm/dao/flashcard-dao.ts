import * as SQLite from 'expo-sqlite';
import { BaseRepository } from '../base-repository';
import { FlashcardEntity } from '../entities/flashcard-entity';

export class FlashcardDao extends BaseRepository<FlashcardEntity> {
  constructor(db: SQLite.SQLiteDatabase) {
    super(db, FlashcardEntity);
  }

  async createFlashcard(flashcard: FlashcardEntity): Promise<void> {
    flashcard.setTimestamps();
    await this.insert(flashcard);
  }

  async getAllFlashcardsFromDeckId(deckId: number): Promise<FlashcardEntity[]> {
    const sql = 'SELECT * FROM flashcard WHERE deckId = ? ORDER BY createdAt ASC';
    const rows = await this.executeQuery(sql, [deckId]);
    return rows.map(row => FlashcardEntity.fromRow(row));
  }

  async updateFlashcard(flashcard: FlashcardEntity): Promise<void> {
    flashcard.setTimestamps();
    await this.update(flashcard);
  }

  async deleteFlashcard(flashcard: FlashcardEntity): Promise<void> {
    await this.delete(flashcard);
  }

  async deleteFlashcardById(flashcardId: number): Promise<void> {
    await this.deleteById(flashcardId);
  }

  async markAsReviewed(flashcardId: number): Promise<void> {
    const flashcard = await this.findById(flashcardId);
    if (flashcard) {
      flashcard.markAsReviewed();
      await this.update(flashcard);
    }
  }


}