import { Deck, Flashcard } from '../types';
import { databaseService, DeckRepository, FlashcardRepository } from '../orm';

/**
 * Database service that uses ORM for type-safe database operations
 * This replaces the old direct SQL database service
 */
class DatabaseORMService {
  private deckRepository = new DeckRepository();
  private flashcardRepository = new FlashcardRepository();
  private initialized = false;

  async init(): Promise<void> {
    if (this.initialized) return;
    
    await databaseService.init();
    this.initialized = true;
  }

  private ensureInitialized(): void {
    if (!this.initialized) {
      throw new Error('Database service not initialized. Call init() first.');
    }
  }

  // === DECK OPERATIONS ===

  async getDecks(): Promise<Deck[]> {
    this.ensureInitialized();
    return await this.deckRepository.getAll();
  }

  async getDeck(id: number): Promise<Deck | null> {
    this.ensureInitialized();
    return await this.deckRepository.getById(id);
  }

  async createDeck(deck: Omit<Deck, 'id' | 'createdAt' | 'updatedAt'>): Promise<number> {
    this.ensureInitialized();
    return await this.deckRepository.create(deck);
  }

  async updateDeck(deck: Deck): Promise<void> {
    this.ensureInitialized();
    await this.deckRepository.update(deck);
  }

  async deleteDeck(id: number): Promise<void> {
    this.ensureInitialized();
    await this.deckRepository.delete(id);
  }

  async getDeckWithFlashcards(id: number): Promise<(Deck & { flashcards: Flashcard[] }) | null> {
    this.ensureInitialized();
    return await this.deckRepository.getWithFlashcards(id);
  }

  // === FLASHCARD OPERATIONS ===

  async getFlashcards(deckId: number): Promise<Flashcard[]> {
    this.ensureInitialized();
    return await this.flashcardRepository.getByDeckId(deckId);
  }

  async getFlashcard(id: number): Promise<Flashcard | null> {
    this.ensureInitialized();
    return await this.flashcardRepository.getById(id);
  }

  async createFlashcard(flashcard: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>): Promise<void> {
    this.ensureInitialized();
    await this.flashcardRepository.create(flashcard);
  }

  async createFlashcards(flashcards: Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>[]): Promise<void> {
    this.ensureInitialized();
    await this.flashcardRepository.createMultiple(flashcards);
  }

  async updateFlashcard(flashcard: Flashcard): Promise<void> {
    this.ensureInitialized();
    await this.flashcardRepository.update(flashcard);
  }

  async updateFlashcardReview(id: number): Promise<void> {
    this.ensureInitialized();
    await this.flashcardRepository.markAsReviewed(id);
  }

  async deleteFlashcard(id: number): Promise<void> {
    this.ensureInitialized();
    await this.flashcardRepository.delete(id);
  }



  // === UTILITY OPERATIONS ===

  async clearAllData(): Promise<void> {
    this.ensureInitialized();
    await databaseService.clearAllData();
  }
}

// Export singleton instance
export const databaseORMService = new DatabaseORMService();