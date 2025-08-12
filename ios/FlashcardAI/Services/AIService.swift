import Foundation
import UIKit

// Configuration structs (temporary inline until Xcode project includes them)
struct APIConfig {
    struct OpenAI {
        static let chatCompletionsURL = "https://api.openai.com/v1/chat/completions"
        static let model = "gpt-3.5-turbo"
        static let temperature: Double = 0.3
        static let maxTokens = 1000
        static let seed = 6
    }
}

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

class AIService {
    static let shared = AIService()
    
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    
    private init() {}
    
    func generateFlashcards(request: AIGenerationRequest) async throws -> AIGenerationResponse {
        guard !apiKey.isEmpty else {
            throw AIError.noAPIKey
        }
        let prompt = buildPrompt(topic: request.topic, cardCount: request.cardCount)
        
        guard let url = URL(string: APIConfig.OpenAI.chatCompletionsURL) else {
            throw AIError.apiError
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": APIConfig.OpenAI.model,
            "messages": [
                [
                    "role": "system",
                    "content": PromptsConfig.systemMessage
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": APIConfig.OpenAI.temperature,
            "max_tokens": APIConfig.OpenAI.maxTokens,
            "seed": APIConfig.OpenAI.seed
        ]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.apiError
            }
            
            guard httpResponse.statusCode == 200 else {
                throw AIError.apiError
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw AIError.invalidResponse
            }
            // Parse the JSON response
            return try parseAIResponse(content: content, topic: request.topic)
            
        } catch {
            throw error
        }
    }
    
    private func buildPrompt(topic: String, cardCount: Int) -> String {
        return PromptsConfig.userPromptTemplate
            .replacingOccurrences(of: "{cardCount}", with: "\(cardCount)")
            .replacingOccurrences(of: "{topic}", with: topic)
    }
    
    private func parseAIResponse(content: String, topic: String) throws -> AIGenerationResponse {
        // Try to parse the JSON response
        var jsonData: Data
        
        if let data = content.data(using: .utf8) {
            jsonData = data
        } else {
            // Try to extract JSON from the response
            let pattern = #"\{[\s\S]*\}"#
            if let range = content.range(of: pattern, options: .regularExpression),
               let data = String(content[range]).data(using: .utf8) {
                jsonData = data
            } else {
                throw AIError.invalidResponse
            }
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

            guard let deckInfo = json?["deck"] as? [String: Any],
                  let flashcardsArray = json?["flashcards"] as? [[String: Any]] else {
                throw AIError.invalidResponse
            }
            
            guard let deckName = deckInfo["name"] as? String, !deckName.isEmpty,
                  let deckDescription = deckInfo["description"] as? String else {
                throw AIError.invalidResponse
            }

            let deck = AIGenerationResponse.DeckInfo(
                name: deckName,
                description: deckDescription
            )

            let flashcards: [AIGenerationResponse.FlashcardInfo] = flashcardsArray.compactMap { card in
                guard let question = card["question"] as? String, !question.isEmpty,
                      let answer = card["answer"] as? String, !answer.isEmpty else {
                    return nil
                }
                return AIGenerationResponse.FlashcardInfo(question: question, answer: answer)
            }

            guard !flashcards.isEmpty else { throw AIError.invalidResponse }
            
            return AIGenerationResponse(deck: deck, flashcards: flashcards)
            
        } catch {
            throw AIError.invalidResponse
        }
    }
    
    func isRealAIEnabled() -> Bool {
        return !apiKey.isEmpty
    }
    
    func getAIStatus() -> String {
        return isRealAIEnabled() ? "Real AI (OpenAI)" : "AI Disabled"
    }
}

enum AIError: Error {
    case noAPIKey
    case apiError
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .noAPIKey:
            return "OpenAI API key not set"
        case .apiError:
            return "OpenAI API error"
        case .invalidResponse:
            return "Invalid response format from AI"
        }
    }
} 