import { Deck } from '../../types';
import { DeckEntity } from '../entities/deck-entity';
import { FlashcardEntity } from '../entities/flashcard-entity';
import { databaseService } from '../database-service';

export class DeckRepository {
  // Get all decks
  async getAll(): Promise<Deck[]> {
    const deckEntities = await databaseService.decks.getAllDecks();
    return deckEntities.map(entity => entity.toDeck());
  }

  // Get deck by ID
  async getById(id: number): Promise<Deck | null> {
    const deckEntity = await databaseService.decks.getDeckById(id);
    return deckEntity ? deckEntity.toDeck() : null;
  }

  // Create new deck
  async create(deck: Omit<Deck, 'id' | 'createdAt' | 'updatedAt'>): Promise<number> {
    const deckEntity = DeckEntity.fromDeck(deck as Deck);
    return await databaseService.decks.createDeck(deckEntity);
  }

  // Update existing deck
  async update(deck: Deck): Promise<void> {
    if (!deck.id) {
      throw new Error('Cannot update deck without ID');
    }
    
    const deckEntity = DeckEntity.fromDeck(deck);
    await databaseService.decks.updateDeck(deckEntity);
  }

  // Delete deck
  async delete(id: number): Promise<void> {
    await databaseService.decks.deleteDeck(id);
  }

  // Get deck with flashcards
  async getWithFlashcards(id: number): Promise<(Deck & { flashcards: any[] }) | null> {
    const deckEntity = await databaseService.decks.getDeckById(id);
    if (!deckEntity) return null;

    const flashcardEntities = await databaseService.decks.getFlashcardsByDeckId(id);
    const deck = deckEntity.toDeck();
    
    return {
      ...deck,
      flashcards: flashcardEntities.map(entity => entity.toFlashcard()),
    };
  }




}