import { AIGenerationRequest, AIGenerationResponse } from '../types';

class AIService {
  private apiKey: string | null = null;

  constructor() {
    this.loadApiKey();
  }

  private loadApiKey() {
    // First try to get from environment variable
    if (true) {
      this.apiKey = process.env.OPENAI_API_KEY;
      return;
    }


    try {
      
    } catch (error) {
      console.log('No API key found, using mock mode');
    }
  }

  setApiKey(key: string) {
    this.apiKey = key;
    console.log('OpenAI API key set successfully');
  }

  async generateFlashcards(request: AIGenerationRequest): Promise<AIGenerationResponse> {
    if (!this.apiKey) {
      throw new Error('OpenAI API key not set');
    }

    const prompt = this.buildPrompt(request.topic, request.cardCount);

    try {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
        },
        body: JSON.stringify({
          model: 'gpt-3.5-turbo',
          messages: [
            {
              role: 'system',
              content: 'You are an educational content generator that creates flashcards in JSON format. Always respond with valid JSON only.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: 0.3,
          max_tokens: 1000,
          seed: 6,
        }),
      });

      if (!response.ok) {
        throw new Error(`OpenAI API error: ${response.status}`);
      }

      const data = await response.json();
      const content = data.choices[0].message.content;
      
      // Try to parse the JSON response
      try {
        const parsed = JSON.parse(content);
        return this.validateAndTransformResponse(parsed, request.topic);
      } catch (parseError) {
        // If JSON parsing fails, try to extract JSON from the response
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const parsed = JSON.parse(jsonMatch[0]);
          return this.validateAndTransformResponse(parsed, request.topic);
        }
        throw new Error('Failed to parse AI response');
      }
    } catch (error) {
      console.error('AI generation error:', error);
      throw error;
    }
  }

  private buildPrompt(topic: string, cardCount: number): string {
    return `Generate ${cardCount} educational flashcards about "${topic}". 

Respond with ONLY a JSON object in this exact format:
{
  "deck": {
    "name": "Deck name here",
    "description": "Brief description of the deck"
  },
  "flashcards": [
    {
      "question": "Question text here",
      "answer": "Answer text here"
    }
  ]
}

Make the questions and answers educational, clear, and concise. The deck name should be related to the topic.`;
  }

  private validateAndTransformResponse(response: any, topic: string): AIGenerationResponse {
    // Validate the response structure
    if (!response.deck || !response.flashcards || !Array.isArray(response.flashcards)) {
      throw new Error('Invalid response format from AI');
    }

    // Ensure we have the required fields
    const deck = {
      name: response.deck.name || `${topic} Flashcards`,
      description: response.deck.description || `Flashcards about ${topic}`,
    };

    const flashcards = response.flashcards.map((card: any, index: number) => ({
      question: card.question || `Question ${index + 1}`,
      answer: card.answer || `Answer ${index + 1}`,
    }));

    return { deck, flashcards };
  }

  // Mock method for development/testing without API key
  async generateMockFlashcards(request: AIGenerationRequest): Promise<AIGenerationResponse> {
    const mockFlashcards = [];
    
    // Generate more realistic mock content based on the topic
    const topic = request.topic.toLowerCase();
    
    let questions = [];
    
    if (topic.includes('javascript') || topic.includes('programming') || topic.includes('coding')) {
      questions = [
        { question: `What is the difference between '==' and '===' in ${request.topic}?`, answer: '== checks for value equality with type coercion, while === checks for both value and type equality (strict equality).' },
        { question: `What is a closure in ${request.topic}?`, answer: 'A closure is a function that has access to variables in its outer (enclosing) scope even after the outer function has returned.' },
        { question: `What is the purpose of 'use strict' in ${request.topic}?`, answer: 'It enables strict mode, which catches common coding mistakes and prevents certain unsafe actions.' },
        { question: `What is hoisting in ${request.topic}?`, answer: 'Hoisting is JavaScript\'s default behavior of moving declarations to the top of their scope during compilation.' },
        { question: `What is the difference between let, const, and var in ${request.topic}?`, answer: 'var is function-scoped and hoisted, let is block-scoped and not hoisted, const is block-scoped, not hoisted, and cannot be reassigned.' },
      ];
    } else if (topic.includes('history') || topic.includes('war')) {
      questions = [
        { question: `When did ${request.topic} begin?`, answer: 'This would depend on the specific historical event or period being referenced.' },
        { question: `What were the main causes of ${request.topic}?`, answer: 'Multiple factors typically contribute to major historical events, including political, economic, and social conditions.' },
        { question: `Who were the key figures involved in ${request.topic}?`, answer: 'Important leaders, politicians, and influential individuals played significant roles.' },
        { question: `What were the major outcomes of ${request.topic}?`, answer: 'Historical events often lead to significant changes in society, politics, and international relations.' },
        { question: `How did ${request.topic} impact the world?`, answer: 'Major historical events typically have lasting effects on global politics, economics, and society.' },
      ];
    } else if (topic.includes('anatomy') || topic.includes('biology') || topic.includes('science')) {
      questions = [
        { question: `What is the main function of the ${request.topic}?`, answer: 'Each body system or organ has specific functions essential for maintaining life and health.' },
        { question: `How does ${request.topic} work?`, answer: 'Biological systems operate through complex interactions between cells, tissues, and organs.' },
        { question: `What are the key components of ${request.topic}?`, answer: 'Anatomical structures are made up of various tissues, cells, and specialized components.' },
        { question: `What happens when ${request.topic} malfunctions?`, answer: 'Dysfunction in biological systems can lead to various health conditions and diseases.' },
        { question: `How is ${request.topic} studied?`, answer: 'Scientific research uses various methods including observation, experimentation, and advanced imaging techniques.' },
      ];
    } else {
      // Generic questions for any topic
      questions = [
        { question: `What is the main concept of ${request.topic}?`, answer: 'This covers the fundamental principles and core ideas of the topic.' },
        { question: `How does ${request.topic} work?`, answer: 'This explains the mechanisms and processes involved in the topic.' },
        { question: `What are the key benefits of ${request.topic}?`, answer: 'This highlights the advantages and positive aspects of the topic.' },
        { question: `What are common applications of ${request.topic}?`, answer: 'This shows how the topic is used in real-world situations.' },
        { question: `What challenges are associated with ${request.topic}?`, answer: 'This addresses potential difficulties and limitations of the topic.' },
        { question: `What are the main types of ${request.topic}?`, answer: 'This categorizes different variations or classifications within the topic.' },
        { question: `How has ${request.topic} evolved over time?`, answer: 'This covers the historical development and changes in the topic.' },
        { question: `What skills are needed for ${request.topic}?`, answer: 'This identifies the abilities and knowledge required to work with the topic.' },
      ];
    }

    // Take the requested number of cards
    for (let i = 0; i < Math.min(request.cardCount, questions.length); i++) {
      mockFlashcards.push(questions[i]);
    }

    return {
      deck: {
        name: `${request.topic} Flashcards`,
        description: `Generated flashcards about ${request.topic} - ${mockFlashcards.length} cards covering key concepts and fundamentals.`,
      },
      flashcards: mockFlashcards,
    };
  }

  // Method to check if real AI is available
  isRealAIEnabled(): boolean {
    return this.apiKey !== null;
  }

  // Method to get AI status
  getAIStatus(): string {
    return this.apiKey ? 'Real AI (OpenAI)' : 'Mock AI (Demo Mode)';
  }
}

export const aiService = new AIService(); 