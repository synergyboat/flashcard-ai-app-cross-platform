import Foundation
import SQLite3

// SQLITE_TRANSIENT constant for safe string binding
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()
    
    private var db: OpaquePointer?
    private var isInitialized = false
    private let dbQueue = DispatchQueue(label: "com.flashcardai.database", qos: .userInitiated)
    
    private init() {}
    
    func initialize() async -> Bool {
        if isInitialized { return true }
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                self.performInitialization()
                continuation.resume(returning: self.isInitialized)
            }
        }
    }
    
    private func performInitialization() {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        
        let dbPath = (documentsPath as NSString).appendingPathComponent("flashcard_app.db")
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            // Enable foreign key constraints
            sqlite3_exec(db, "PRAGMA foreign_keys = ON", nil, nil, nil)
            
            createTablesSync()
            isInitialized = true
        } else {
            if db != nil {
                sqlite3_close(db)
                db = nil
            }
        }
    }
    
    private func createTablesSync() {
        let createDeckTable = """
            CREATE TABLE IF NOT EXISTS deck (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL
            );
        """
        
        let createFlashcardTable = """
            CREATE TABLE IF NOT EXISTS flashcard (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                deckId INTEGER NOT NULL,
                question TEXT NOT NULL,
                answer TEXT NOT NULL,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL,
                lastReviewed TEXT,
                FOREIGN KEY (deckId) REFERENCES deck (id) ON DELETE CASCADE
            );
        """
        
        sqlite3_exec(db, createDeckTable, nil, nil, nil)
        sqlite3_exec(db, createFlashcardTable, nil, nil, nil)
    }
    
    func getDecks() async -> [Deck] {
        guard await initialize() else {
            return []
        }
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let decks = self.getDecksSync()
                continuation.resume(returning: decks)
            }
        }
    }
    
    private func getDecksSync() -> [Deck] {
        let query = """
            SELECT d.*, COUNT(f.id) as flashcardCount 
            FROM deck d 
            LEFT JOIN flashcard f ON d.id = f.deckId 
            GROUP BY d.id 
            ORDER BY d.updatedAt DESC
        """
        
        var decks: [Deck] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let description = String(cString: sqlite3_column_text(statement, 2))
                let createdAt = String(cString: sqlite3_column_text(statement, 3))
                let updatedAt = String(cString: sqlite3_column_text(statement, 4))
                let flashcardCount = Int(sqlite3_column_int(statement, 5))
                
                let dateFormatter = ISO8601DateFormatter()
                let deck = Deck(
                    id: id,
                    name: name,
                    description: description,
                    createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
                    flashcardCount: flashcardCount
                )
                decks.append(deck)
            }
        }
        
        sqlite3_finalize(statement)
        return decks
    }
    
    func getDeck(id: Int) async -> Deck? {
        guard await initialize() else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let deck = self.getDeckSync(id: id)
                continuation.resume(returning: deck)
            }
        }
    }
    
    private func getDeckSync(id: Int) -> Deck? {
        let query = """
            SELECT d.id, d.name, d.description, d.createdAt, d.updatedAt, COUNT(f.id) as flashcardCount 
            FROM deck d 
            LEFT JOIN flashcard f ON d.id = f.deckId 
            WHERE d.id = ? 
            GROUP BY d.id
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let deckId = Int(sqlite3_column_int(statement, 0))
                
                // Use sqlite3_column_bytes to get the actual length and handle encoding properly
                let nameLength = sqlite3_column_bytes(statement, 1)
                let namePtr = sqlite3_column_text(statement, 1)
                let name: String
                if let namePtr = namePtr, nameLength > 0 {
                    name = String(data: Data(bytes: namePtr, count: Int(nameLength)), encoding: .utf8) ?? ""
                } else {
                    name = ""
                }
                
                let descLength = sqlite3_column_bytes(statement, 2)
                let descPtr = sqlite3_column_text(statement, 2)
                let description: String
                if let descPtr = descPtr, descLength > 0 {
                    description = String(data: Data(bytes: descPtr, count: Int(descLength)), encoding: .utf8) ?? ""
                } else {
                    description = ""
                }
                
                let createdAt = String(cString: sqlite3_column_text(statement, 3))
                let updatedAt = String(cString: sqlite3_column_text(statement, 4))
                let flashcardCount = Int(sqlite3_column_int(statement, 5))
                
                let dateFormatter = ISO8601DateFormatter()
                let deck = Deck(
                    id: deckId,
                    name: name,
                    description: description,
                    createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
                    flashcardCount: flashcardCount
                )
                
                sqlite3_finalize(statement)
                return deck
            }
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    func createDeck(name: String, description: String) async -> Int {
        guard await initialize() else {
            return -1
        }
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let id = self.createDeckSync(name: name, description: description)
                continuation.resume(returning: id)
            }
        }
    }
    
    private func createDeckSync(name: String, description: String?) -> Int {
        let now = ISO8601DateFormatter().string(from: Date())
        let query = "INSERT INTO deck (name, description, createdAt, updatedAt) VALUES (?, ?, ?, ?)"
        let desc = description ?? ""
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, desc, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, now, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let id = Int(sqlite3_last_insert_rowid(db))
                sqlite3_finalize(statement)
                return id
            }
        }
        
        sqlite3_finalize(statement)
        return -1
    }
    
    func updateDeck(_ deck: Deck) async {
        guard await initialize(), let deckId = deck.id else {
            return
        }
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.updateDeckSync(id: deckId, name: deck.name, description: deck.description)
                continuation.resume()
            }
        }
    }
    
    private func updateDeckSync(id: Int, name: String, description: String) {
        let now = ISO8601DateFormatter().string(from: Date())
        let query = "UPDATE deck SET name = ?, description = ?, updatedAt = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, description, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 4, Int32(id))
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteDeck(id: Int) async {
        guard await initialize() else {
            return
        }
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.deleteDeckSync(id: id)
                continuation.resume()
            }
        }
    }
    
    private func deleteDeckSync(id: Int) {
        let query = "DELETE FROM deck WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getFlashcards(deckId: Int) async -> [Flashcard] {
        guard await initialize() else {
            return []
        }
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let flashcards = self.getFlashcardsSync(deckId: deckId)
                continuation.resume(returning: flashcards)
            }
        }
    }
    
    private func getFlashcardsSync(deckId: Int) -> [Flashcard] {
        let query = "SELECT * FROM flashcard WHERE deckId = ? ORDER BY createdAt ASC"
        var flashcards: [Flashcard] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(deckId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let flashcardDeckId = Int(sqlite3_column_int(statement, 1))
                let question = String(cString: sqlite3_column_text(statement, 2))
                let answer = String(cString: sqlite3_column_text(statement, 3))
                let createdAt = String(cString: sqlite3_column_text(statement, 4))
                let updatedAt = String(cString: sqlite3_column_text(statement, 5))
                let lastReviewed: String?
                if let lastReviewedPtr = sqlite3_column_text(statement, 6) {
                    lastReviewed = String(cString: lastReviewedPtr)
                } else {
                    lastReviewed = nil
                }
                
                let dateFormatter = ISO8601DateFormatter()
                let flashcard = Flashcard(
                    id: id,
                    deckId: flashcardDeckId,
                    question: question,
                    answer: answer,
                    createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
                    lastReviewed: lastReviewed.flatMap { dateFormatter.date(from: $0) }
                )
                flashcards.append(flashcard)
            }
        }
        
        sqlite3_finalize(statement)
        return flashcards
    }
    
    func createFlashcards(_ flashcards: [Flashcard]) async {
        guard await initialize() else {
            return
        }
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.createFlashcardsSync(flashcards)
                continuation.resume()
            }
        }
    }
    
    private func createFlashcardsSync(_ flashcards: [Flashcard]) {
        let dateFormatter = ISO8601DateFormatter()
        let query = "INSERT INTO flashcard (deckId, question, answer, createdAt, updatedAt, lastReviewed) VALUES (?, ?, ?, ?, ?, ?)"
        
        for flashcard in flashcards {
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                let createdAtStr = dateFormatter.string(from: flashcard.createdAt)
                let updatedAtStr = dateFormatter.string(from: flashcard.updatedAt)
                let lastReviewedStr: String?
                if let lastReviewed = flashcard.lastReviewed {
                    lastReviewedStr = dateFormatter.string(from: lastReviewed)
                } else {
                    lastReviewedStr = nil
                }
                
                sqlite3_bind_int(statement, 1, Int32(flashcard.deckId))
                sqlite3_bind_text(statement, 2, flashcard.question, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 3, flashcard.answer, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 4, createdAtStr, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 5, updatedAtStr, -1, SQLITE_TRANSIENT)
                if let lastReviewedStr = lastReviewedStr {
                    sqlite3_bind_text(statement, 6, lastReviewedStr, -1, SQLITE_TRANSIENT)
                } else {
                    sqlite3_bind_null(statement, 6)
                }
                
                sqlite3_step(statement)
            }
            
            sqlite3_finalize(statement)
        }
    }
    
    func updateFlashcardReview(id: Int) async {
        guard await initialize() else {
            return
        }
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.updateFlashcardReviewSync(id: id)
                continuation.resume()
            }
        }
    }
    
    private func updateFlashcardReviewSync(id: Int) {
        let now = ISO8601DateFormatter().string(from: Date())
        let query = "UPDATE flashcard SET lastReviewed = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 2, Int32(id))
            
            sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
        
    func updateFlashcard(id: Int, question: String, answer: String) async {
        guard await initialize() else { return }
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.updateFlashcardSync(id: id, question: question, answer: answer)
                continuation.resume()
            }
        }
    }
    
    private func updateFlashcardSync(id: Int, question: String, answer: String) {
        let now = ISO8601DateFormatter().string(from: Date())
        let query = "UPDATE flashcard SET question = ?, answer = ?, updatedAt = ? WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, question, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, answer, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, now, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 4, Int32(id))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    func deleteFlashcard(id: Int) async {
        guard await initialize() else { return }
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.deleteFlashcardSync(id: id)
                continuation.resume()
            }
        }
    }
    
    private func deleteFlashcardSync(id: Int) {
        let query = "DELETE FROM flashcard WHERE id = ?"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
}