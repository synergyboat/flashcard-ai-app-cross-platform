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
    if (this.initialized) {
      console.log('Database ORM service already initialized');
      return;
    }
    
    try {
      console.log('Initializing database ORM service...');
      await databaseService.init();
      this.initialized = true;
      console.log('Database ORM service initialized successfully');
    } catch (error) {
      console.error('Failed to initialize database ORM service:', error);
      this.initialized = false;
      throw error;
    }
  }

  private ensureInitialized(): void {
    if (!this.initialized) {
      console.error('Database service not initialized. Current state:', {
        initialized: this.initialized,
        deckRepository: !!this.deckRepository,
        flashcardRepository: !!this.flashcardRepository,
      });
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

  async updateDeck(id: number, updates: Partial<Omit<Deck, 'id' | 'createdAt' | 'updatedAt' | 'flashcards'>>): Promise<void> {
    this.ensureInitialized();
    const existingDeck = await this.deckRepository.getById(id);
    if (!existingDeck) throw new Error('Deck not found');
    
    const updatedDeck = { ...existingDeck, ...updates, updatedAt: new Date() };
    await this.deckRepository.update(updatedDeck);
  }

  async deleteDeck(id: number): Promise<void> {
    this.ensureInitialized();
    await this.deckRepository.delete(id);
  }

  async getDeckWithFlashcards(id: number): Promise<(Deck & { flashcards: Flashcard[] }) | null> {
    this.ensureInitialized();
    return await this.deckRepository.getWithFlashcards(id);
  }

  async createDeckWithFlashcards(
    deckData: Omit<Deck, 'id' | 'createdAt' | 'updatedAt' | 'flashcards'>,
    flashcards: Omit<Flashcard, 'id' | 'deckId' | 'createdAt' | 'updatedAt'>[]
  ): Promise<number> {
    console.log('createDeckWithFlashcards called with:', {
      deckData,
      flashcardCount: flashcards.length
    });
    
    this.ensureInitialized();
    
    console.log('Database is initialized, creating deck...');
    const deckToCreate: Omit<Deck, 'id' | 'createdAt' | 'updatedAt'> = {
      name: deckData.name || '',
      description: deckData.description || '',
      flashcards: [],
    };
    
    const deckId = await this.deckRepository.create(deckToCreate);
    console.log('Deck created with ID:', deckId);
    
    const flashcardsWithDeckId = flashcards.map(flashcard => ({
      ...flashcard,
      deckId,
    }));
    
    console.log('Creating flashcards:', flashcardsWithDeckId);
    await this.flashcardRepository.createMultiple(flashcardsWithDeckId);
    console.log('Flashcards created successfully');
    
    return deckId;
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

  async updateFlashcard(id: number, updates: Partial<Omit<Flashcard, 'id' | 'createdAt' | 'updatedAt'>>): Promise<void> {
    this.ensureInitialized();
    const existingFlashcard = await this.flashcardRepository.getById(id);
    if (!existingFlashcard) throw new Error('Flashcard not found');
    
    const updatedFlashcard = { ...existingFlashcard, ...updates, updatedAt: new Date() };
    await this.flashcardRepository.update(updatedFlashcard);
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

  async seedSampleData(): Promise<void> {
    this.ensureInitialized();
    
    try {
      // Check if data already exists
      const existingDecks = await this.getDecks();
      if (existingDecks.length > 0) {
        console.log('Sample data already exists');
        return;
      }

      // Create sample deck
      const deckData = {
        name: 'Sample Deck',
        description: 'A sample deck with basic flashcards',
      };

      const flashcardData = [
        {
          question: 'What is the capital of France?',
          answer: 'Paris',
        },
        {
          question: 'What is 2 + 2?',
          answer: '4',
        },
      ];

      const deckId = await this.createDeckWithFlashcards(deckData, flashcardData);
      console.log('Sample data created successfully with deck ID:', deckId);
    } catch (error) {
      console.error('Error creating sample data:', error);
    }
  }
}

// Export singleton instance
export const databaseORMService = new DatabaseORMService();