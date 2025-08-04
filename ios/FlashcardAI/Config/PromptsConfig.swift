import Foundation

struct PromptsConfig {
    static let systemMessage = "You are an educational content generator that creates flashcards in JSON format. Always respond with valid JSON only."
    
    static let userPromptTemplate = """
        Generate {cardCount} educational flashcards about "{topic}".
        
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
        
        Make the questions and answers educational, clear, and concise. The deck name should be related to the topic.
        """
    
    struct FallbackNames {
        static let deckName = "Generated Flashcards"
        static let deckDescription = "AI-generated flashcards"
        static let questionFallback = "Sample Question"
        static let answerFallback = "Sample Answer"
    }
}