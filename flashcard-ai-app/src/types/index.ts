export interface Deck {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
  flashcardCount?: number;
}

export interface Flashcard {
  id: string;
  deckId: string;
  question: string;
  answer: string;
  createdAt: Date;
  updatedAt: Date;
  lastReviewed?: Date;
}

export interface AIGenerationRequest {
  topic: string;
  cardCount: number;
}

export interface AIGenerationResponse {
  deck: {
    name: string;
    description: string;
  };
  flashcards: Array<{
    question: string;
    answer: string;
  }>;
} 