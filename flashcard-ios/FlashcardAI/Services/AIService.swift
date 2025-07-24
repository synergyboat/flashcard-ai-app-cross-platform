import Foundation

class AIService {
    static let shared = AIService()
    
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    
    private init() {}
    
    func generateFlashcards(request: AIGenerationRequest) async throws -> AIGenerationResponse {
        print("🔧 AI Service: Starting generation for \(request.topic)")
        
        // Temporarily force mock data for debugging
        print("🔧 Forcing mock data for debugging")
        return generateMockFlashcards(request: request)
        
        guard !apiKey.isEmpty else {
            print("⚠️ No API key found, using mock data")
            return generateMockFlashcards(request: request)
        }
        
        print("🌐 Using real OpenAI API")
        let prompt = buildPrompt(topic: request.topic, cardCount: request.cardCount)
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are an educational content generator that creates flashcards in JSON format. Always respond with valid JSON only."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.3,
            "max_tokens": 1000,
            "seed": 6
        ]
        
        do {
            print("📡 Making API request to OpenAI...")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw AIError.apiError
            }
            
            print("📈 API Response status: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ API Error - Status: \(httpResponse.statusCode)")
                if let errorData = String(data: data, encoding: .utf8) {
                    print("Error response: \(errorData)")
                }
                throw AIError.apiError
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let choices = json?["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ Invalid API response structure")
                throw AIError.invalidResponse
            }
            
            print("✅ Got API response, parsing content...")
            // Parse the JSON response
            return try parseAIResponse(content: content, topic: request.topic)
            
        } catch {
            print("❌ AI generation error: \(error)")
            print("🔄 Falling back to mock generation")
            // Fall back to mock generation
            return generateMockFlashcards(request: request)
        }
    }
    
    private func buildPrompt(topic: String, cardCount: Int) -> String {
        return """
        Generate \(cardCount) educational flashcards about "\(topic)".
        
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
            
            let deck = AIGenerationResponse.DeckInfo(
                name: deckInfo["name"] as? String ?? "\(topic) Flashcards",
                description: deckInfo["description"] as? String ?? "Flashcards about \(topic)"
            )
            
            let flashcards = flashcardsArray.enumerated().map { index, card in
                AIGenerationResponse.FlashcardInfo(
                    question: card["question"] as? String ?? "Question \(index + 1)",
                    answer: card["answer"] as? String ?? "Answer \(index + 1)"
                )
            }
            
            return AIGenerationResponse(deck: deck, flashcards: flashcards)
            
        } catch {
            throw AIError.invalidResponse
        }
    }
    
    func generateMockFlashcards(request: AIGenerationRequest) -> AIGenerationResponse {
        print("🎭 Generating mock flashcards for: \(request.topic)")
        let topic = request.topic.lowercased()
        var questions: [(String, String)] = []
        
        if topic.contains("javascript") || topic.contains("programming") || topic.contains("coding") {
            questions = [
                ("What is the difference between '==' and '===' in \(request.topic)?", "== checks for value equality with type coercion, while === checks for both value and type equality (strict equality)."),
                ("What is a closure in \(request.topic)?", "A closure is a function that has access to variables in its outer (enclosing) scope even after the outer function has returned."),
                ("What is the purpose of 'use strict' in \(request.topic)?", "It enables strict mode, which catches common coding mistakes and prevents certain unsafe actions."),
                ("What is hoisting in \(request.topic)?", "Hoisting is JavaScript's default behavior of moving declarations to the top of their scope during compilation."),
                ("What is the difference between let, const, and var in \(request.topic)?", "var is function-scoped and hoisted, let is block-scoped and not hoisted, const is block-scoped, not hoisted, and cannot be reassigned.")
            ]
        } else if topic.contains("history") || topic.contains("war") {
            questions = [
                ("When did \(request.topic) begin?", "This would depend on the specific historical event or period being referenced."),
                ("What were the main causes of \(request.topic)?", "Multiple factors typically contribute to major historical events, including political, economic, and social conditions."),
                ("Who were the key figures involved in \(request.topic)?", "Important leaders, politicians, and influential individuals played significant roles."),
                ("What were the major outcomes of \(request.topic)?", "Historical events often lead to significant changes in society, politics, and international relations."),
                ("How did \(request.topic) impact the world?", "Major historical events typically have lasting effects on global politics, economics, and society.")
            ]
        } else if topic.contains("anatomy") || topic.contains("biology") || topic.contains("science") {
            questions = [
                ("What is the main function of the \(request.topic)?", "Each body system or organ has specific functions essential for maintaining life and health."),
                ("How does \(request.topic) work?", "Biological systems operate through complex interactions between cells, tissues, and organs."),
                ("What are the key components of \(request.topic)?", "Anatomical structures are made up of various tissues, cells, and specialized components."),
                ("What happens when \(request.topic) malfunctions?", "Dysfunction in biological systems can lead to various health conditions and diseases."),
                ("How is \(request.topic) studied?", "Scientific research uses various methods including observation, experimentation, and advanced imaging techniques.")
            ]
        } else {
            questions = [
                ("What is the main concept of \(request.topic)?", "This covers the fundamental principles and core ideas of the topic."),
                ("How does \(request.topic) work?", "This explains the mechanisms and processes involved in the topic."),
                ("What are the key benefits of \(request.topic)?", "This highlights the advantages and positive aspects of the topic."),
                ("What are common applications of \(request.topic)?", "This shows how the topic is used in real-world situations."),
                ("What challenges are associated with \(request.topic)?", "This addresses potential difficulties and limitations of the topic."),
                ("What are the main types of \(request.topic)?", "This categorizes different variations or classifications within the topic."),
                ("How has \(request.topic) evolved over time?", "This covers the historical development and changes in the topic."),
                ("What skills are needed for \(request.topic)?", "This identifies the abilities and knowledge required to work with the topic.")
            ]
        }
        
        let selectedQuestions = Array(questions.prefix(min(request.cardCount, questions.count)))
        let flashcards = selectedQuestions.map { 
            AIGenerationResponse.FlashcardInfo(question: $0.0, answer: $0.1)
        }
        
        let deck = AIGenerationResponse.DeckInfo(
            name: "\(request.topic) Flashcards",
            description: "Generated flashcards about \(request.topic) - \(flashcards.count) cards covering key concepts and fundamentals."
        )
        
        print("✅ Mock generation completed: \(flashcards.count) cards")
        return AIGenerationResponse(deck: deck, flashcards: flashcards)
    }
    
    func isRealAIEnabled() -> Bool {
        return !apiKey.isEmpty
    }
    
    func getAIStatus() -> String {
        return isRealAIEnabled() ? "Real AI (OpenAI)" : "Mock AI (Demo Mode)"
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