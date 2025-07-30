import Foundation

struct Flashcard: Codable {
    let id: String
    let deckId: String
    let question: String
    let answer: String
    let createdAt: Date
    let updatedAt: Date
    var lastReviewed: Date?
    
    init(id: String = UUID().uuidString, deckId: String, question: String, answer: String, createdAt: Date = Date(), updatedAt: Date = Date(), lastReviewed: Date? = nil) {
        self.id = id
        self.deckId = deckId
        self.question = question
        self.answer = answer
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastReviewed = lastReviewed
    }
}

struct AIGenerationRequest {
    let topic: String
    let cardCount: Int
}

struct AIGenerationResponse {
    struct DeckInfo {
        let name: String
        let description: String
    }
    
    struct FlashcardInfo {
        let question: String
        let answer: String
    }
    
    let deck: DeckInfo
    let flashcards: [FlashcardInfo]
} 