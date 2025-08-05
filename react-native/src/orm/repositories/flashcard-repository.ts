import { Flashcard } from '../../types';
import { FlashcardEntity } from '../entities/flashcard-entity';
import { databaseService } from '../database-service';

export class FlashcardRepository {
  // Get all flashcards for a deck
  async getByDeckId(deckId: number): Promise<Flashcard[]> {
    const flashcardEntities = await databaseService.flashcards.getAllFlashcardsFromDeckId(deckId);
    return flashcardEntities.map(entity => entity.toFlashcard());
  }

  // Get flashcard by ID
  async getById(id: number): Promise<Flashcard | null> {
    const flashcardEntity = await databaseService.flashcards.findById(id);
    return flashcardEntity ? flashcardEntity.toFlashcard() : null;
  }

  // Create new flashcard
  async create(flashcard: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>): Promise<void> {
    const flashcardEntity = FlashcardEntity.fromFlashcard(flashcard as Flashcard);
    await databaseService.flashcards.createFlashcard(flashcardEntity);
  }

  // Create multiple flashcards
  async createMultiple(flashcards: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>[]): Promise<void> {
    for (const flashcard of flashcards) {
      await this.create(flashcard);
    }
  }

  // Update flashcard
  async update(flashcard: Flashcard): Promise<void> {
    if (!flashcard.id) {
      throw new Error('Cannot update flashcard without ID');
    }
    
    const flashcardEntity = FlashcardEntity.fromFlashcard(flashcard);
    await databaseService.flashcards.updateFlashcard(flashcardEntity);
  }

  // Delete flashcard
  async delete(id: number): Promise<void> {
    await databaseService.flashcards.deleteFlashcardById(id);
  }

  // Mark flashcard as reviewed
  async markAsReviewed(id: number): Promise<void> {
    await databaseService.flashcards.markAsReviewed(id);
  }




}