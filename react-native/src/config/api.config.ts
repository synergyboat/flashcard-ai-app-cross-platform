export const API_CONFIG = {
  OPENAI: {
    BASE_URL: 'https://api.openai.com/v1',
    CHAT_COMPLETIONS: 'https://api.openai.com/v1/chat/completions',
    MODEL: 'gpt-3.5-turbo',
    TEMPERATURE: 0.3,
    MAX_TOKENS: 1000,
    SEED: 6,
  },
  TIMEOUTS: {
    DEFAULT: 30000, 
    UPLOAD: 60000, 
  },
} as const;
