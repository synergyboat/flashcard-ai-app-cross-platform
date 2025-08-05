export const DATABASE_CONFIG = {
  NAME: 'flashcard_app.db', 
  
  TABLES: {
    DECK: 'deck', 
    FLASHCARD: 'flashcard', 
  },
  
  COLUMNS: {
    DECK: {
      ID: 'id',
      NAME: 'name', 
      DESCRIPTION: 'description',
      CREATED_AT: 'createdAt',
      UPDATED_AT: 'updatedAt',
    },
    FLASHCARD: {
      ID: 'id',
      DECK_ID: 'deckId', 
      QUESTION: 'question',
      ANSWER: 'answer',
      CREATED_AT: 'createdAt',
      UPDATED_AT: 'updatedAt',
      LAST_REVIEWED: 'lastReviewed',
    },
  },
} as const;
