import { AIGenerationRequest, AIGenerationResponse } from '../types';
import { API_CONFIG, AI_PROMPTS } from '../config';


class AIService {
  private apiKey: string | null = null;

  constructor() {
    this.loadApiKey();
  }

  private loadApiKey() {
    this.apiKey = process.env.EXPO_PUBLIC_OPENAI_API_KEY || null;
  }

  setApiKey(key: string) {
    this.apiKey = key;
  }

  async generateFlashcards(request: AIGenerationRequest): Promise<AIGenerationResponse> {
    if (!this.apiKey) {
      throw new Error('OpenAI API key not set');
    }

    const prompt = this.buildPrompt(request.topic, request.cardCount);

    try {
      const response = await fetch(API_CONFIG.OPENAI.CHAT_COMPLETIONS, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify({
          model: API_CONFIG.OPENAI.MODEL,
          messages: [
            {
              role: 'system',
              content: AI_PROMPTS.SYSTEM_MESSAGE
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: API_CONFIG.OPENAI.TEMPERATURE,
          max_tokens: API_CONFIG.OPENAI.MAX_TOKENS,
          seed: API_CONFIG.OPENAI.SEED,
        }),
      });

      if (!response.ok) {
        throw new Error(`OpenAI API error: ${response.status}`);
      }

      const data = await response.json();
      const content = data.choices[0].message.content;
      
      try {
        const parsed = JSON.parse(content);
        return this.validateAndTransformResponse(parsed, request.topic);
      } catch (parseError) {
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0]);
          return this.validateAndTransformResponse(parsed, request.topic);
        }
        throw new Error('Failed to parse AI response');
      }
    } catch (error) {
      throw new Error(`AI generation failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  private buildPrompt(topic: string, cardCount: number): string {
    return AI_PROMPTS.USER_PROMPT_TEMPLATE(topic, cardCount);
  }

  private validateAndTransformResponse(response: any, topic: string): AIGenerationResponse {
    // Check for Flutter format first (name, description, flashcards at root level)
    if (response.name && response.description && response.flashcards && Array.isArray(response.flashcards)) {
      const deck = {
        name: response.name || AI_PROMPTS.FALLBACK_NAMES.DECK(topic),
        description: response.description || AI_PROMPTS.FALLBACK_NAMES.DESCRIPTION(topic),
      };

      const flashcards = response.flashcards.map((card: any, index: number) => ({
        question: card.question || AI_PROMPTS.FALLBACK_NAMES.QUESTION(index),
        answer: card.answer || AI_PROMPTS.FALLBACK_NAMES.ANSWER(index),
      }));

      return { deck, flashcards };
    }
    
    // Fall back to nested format (deck object)
    if (!response.deck || !response.flashcards || !Array.isArray(response.flashcards)) {
      throw new Error('Invalid response format from AI');
    }

    const deck = {
      name: response.deck.name || AI_PROMPTS.FALLBACK_NAMES.DECK(topic),
      description: response.deck.description || AI_PROMPTS.FALLBACK_NAMES.DESCRIPTION(topic),
    };

    const flashcards = response.flashcards.map((card: any, index: number) => ({
      question: card.question || AI_PROMPTS.FALLBACK_NAMES.QUESTION(index),
      answer: card.answer || AI_PROMPTS.FALLBACK_NAMES.ANSWER(index),
    }));

    return { deck, flashcards };
  }


}

export const aiService = new AIService(); 