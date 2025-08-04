import Foundation
import SQLite3

class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()
    
    private var db: OpaquePointer?
    private var isInitialized = false
    private let dbQueue = DispatchQueue(label: "com.flashcardai.database", qos: .userInitiated)
    
    private init() {}
    
    func initialize() async {
        if isInitialized { return }
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.performInitialization()
                continuation.resume()
            }
        }
    }
    
    private func performInitialization() {
        print("🗄️ DatabaseService: Starting SQLite initialization...")
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            fatalError("Could not find documents directory")
        }
        
        let dbPath = (documentsPath as NSString).appendingPathComponent("flashcard_app.db")
        print("📂 Database path: \(dbPath)")
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ DatabaseService: SQLite database opened successfully")
            
            // Enable foreign key constraints
            sqlite3_exec(db, "PRAGMA foreign_keys = ON", nil, nil, nil)
            
            createTablesSync()
            isInitialized = true
        } else {
            print("❌ Unable to open database")
            fatalError("Unable to open database")
        }
    }
    
    private func createTablesSync() {
        let createDeckTable = """
            CREATE TABLE IF NOT EXISTS deck (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT,
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
        
        if sqlite3_exec(db, createDeckTable, nil, nil, nil) == SQLITE_OK {
            print("✅ Deck table created successfully")
        } else {
            print("❌ Failed to create deck table")
        }
        
        if sqlite3_exec(db, createFlashcardTable, nil, nil, nil) == SQLITE_OK {
            print("✅ Flashcard table created successfully")
        } else {
            print("❌ Failed to create flashcard table")
        }
    }
    
    // MARK: - Deck Operations
    
    func getDecks() async -> [Deck] {
        await initialize()
        
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
                let description = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
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
        } else {
            print("❌ Failed to prepare getDecks query")
        }
        
        sqlite3_finalize(statement)
        return decks
    }
    
    func getDeck(id: Int) async -> Deck? {
        await initialize()
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let deck = self.getDeckSync(id: id)
                continuation.resume(returning: deck)
            }
        }
    }
    
    private func getDeckSync(id: Int) -> Deck? {
        let query = "SELECT id, name, description, createdAt, updatedAt FROM deck WHERE id = ?"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let deckId = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let description = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
                let createdAt = String(cString: sqlite3_column_text(statement, 3))
                let updatedAt = String(cString: sqlite3_column_text(statement, 4))
                
                let dateFormatter = ISO8601DateFormatter()
                let deck = Deck(
                    id: deckId,
                    name: name,
                    description: description,
                    createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: updatedAt) ?? Date()
                )
                
                sqlite3_finalize(statement)
                return deck
            }
        } else {
            print("❌ Failed to prepare getDeck query")
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    func createDeck(name: String, description: String?) async -> Int {
        await initialize()
        
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
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, name, -1, nil)
            sqlite3_bind_text(statement, 2, description, -1, nil)
            sqlite3_bind_text(statement, 3, now, -1, nil)
            sqlite3_bind_text(statement, 4, now, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let id = Int(sqlite3_last_insert_rowid(db))
                print("✅ Created deck with ID: \(id)")
                sqlite3_finalize(statement)
                return id
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("❌ Failed to create deck: \(errorMessage)")
            }
        } else {
            print("❌ Failed to prepare createDeck query")
        }
        
        sqlite3_finalize(statement)
        return -1
    }
    
    func deleteDeck(id: Int) async {
        await initialize()
        
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
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("🗑️ Deleted deck with ID: \(id)")
            } else {
                print("❌ Failed to delete deck")
            }
        } else {
            print("❌ Failed to prepare deleteDeck query")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - Flashcard Operations
    
    func getFlashcards(deckId: Int) async -> [Flashcard] {
        await initialize()
        
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
                let lastReviewed = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)!) : nil
                
                let dateFormatter = ISO8601DateFormatter()
                let flashcard = Flashcard(
                    id: id,
                    deckId: flashcardDeckId,
                    question: question,
                    answer: answer,
                    createdAt: dateFormatter.date(from: createdAt) ?? Date(),
                    updatedAt: dateFormatter.date(from: updatedAt) ?? Date(),
                    lastReviewed: lastReviewed != nil ? dateFormatter.date(from: lastReviewed!) : nil
                )
                flashcards.append(flashcard)
            }
        } else {
            print("❌ Failed to prepare getFlashcards query")
        }
        
        sqlite3_finalize(statement)
        return flashcards
    }
    
    func createFlashcards(_ flashcards: [Flashcard]) async {
        await initialize()
        
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
                let lastReviewedStr = flashcard.lastReviewed != nil ? dateFormatter.string(from: flashcard.lastReviewed!) : nil
                
                sqlite3_bind_int(statement, 1, Int32(flashcard.deckId))
                sqlite3_bind_text(statement, 2, flashcard.question, -1, nil)
                sqlite3_bind_text(statement, 3, flashcard.answer, -1, nil)
                sqlite3_bind_text(statement, 4, createdAtStr, -1, nil)
                sqlite3_bind_text(statement, 5, updatedAtStr, -1, nil)
                sqlite3_bind_text(statement, 6, lastReviewedStr, -1, nil)
                
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("✅ Successfully created flashcard for deck \(flashcard.deckId)")
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("❌ Failed to create flashcard: \(errorMessage)")
                }
            }
            
            sqlite3_finalize(statement)
        }
    }
    
    func updateFlashcardReview(id: Int) async {
        await initialize()
        
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
            sqlite3_bind_text(statement, 1, now, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("✅ Updated review for flashcard \(id)")
            } else {
                print("❌ Failed to update flashcard review")
            }
        } else {
            print("❌ Failed to prepare updateFlashcardReview query")
        }
        
        sqlite3_finalize(statement)
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
}