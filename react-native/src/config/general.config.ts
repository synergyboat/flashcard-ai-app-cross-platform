export const SCREEN_NAMES = {
  HOME: 'Home',
  AI_GENERATE: 'AIGenerate',
  DECK_DETAILS: 'DeckDetails',
  STUDY: 'Study',
} as const;

export const SCREEN_TITLES = {
  HOME: 'Flashcard AI',
  AI_GENERATE: 'AI Generate Deck',
  DECK_DETAILS: 'Deck Details',
  STUDY: 'Study',
} as const;

export const APP_CONFIG = {
  NAME: 'Flashcard AI',
  VERSION: '1.0.0',
  CARD_LIMITS: {
    MIN: 1,
    MAX: 20,
    DEFAULT: 5,
  },
  ANIMATIONS: {
    SWIPE_THRESHOLD_FACTOR: 0.25, 
    CARD_HEIGHT_FACTOR: 0.9, 
    FLIP_TENSION: 10,
    FLIP_FRICTION: 8,
    SWIPE_DURATION: 250,
  },
  TIMEOUTS: {
    SPLASH_DURATION: 5000, 
  },
} as const;

export const UI_CONFIG = {
  DIMENSIONS: {
    FAB_SIZE: 56,
    CLOSE_BUTTON_SIZE: 40,
    CARD_NUMBER_SIZE: 32,
  },
  SPACING: {
    CONTAINER_PADDING: 20,
    CARD_MARGIN: 16,
    SECTION_MARGIN: 32,
    BUTTON_MARGIN: 24,
  },
  BORDER_RADIUS: {
    SMALL: 12,
    MEDIUM: 20,
    LARGE: 32,
    CIRCLE: 100,
  },
} as const;
