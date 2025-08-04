import Foundation

struct Deck: Codable {
    let id: Int?
    let name: String
    let description: String
    let createdAt: Date
    let updatedAt: Date
    var flashcardCount: Int?
    
    init(id: Int? = nil, name: String, description: String = "", createdAt: Date = Date(), updatedAt: Date = Date(), flashcardCount: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.flashcardCount = flashcardCount
    }
} 