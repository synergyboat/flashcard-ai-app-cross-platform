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
        
        let dbPath = (documentsPath as NSString).appendingPathComponent("flashcard_ai.db")
        print("📂 Database path: \(dbPath)")
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("✅ DatabaseService: SQLite database opened successfully")
            
            // Enable foreign key constraints
            sqlite3_exec(db, "PRAGMA foreign_keys = ON", nil, nil, nil)
            
            // Check database integrity
            let integrityCheck = sqlite3_exec(db, "PRAGMA integrity_check", nil, nil, nil)
            if integrityCheck == SQLITE_OK {
                print("✅ Database integrity check passed")
            } else {
                print("⚠️ Database integrity check failed")
            }
            
            createTablesSync()
            isInitialized = true
        } else {
            print("❌ Unable to open database")
            fatalError("Unable to open database")
        }
    }
    
    private func createTablesSync() {
        let createDecksTable = """
            CREATE TABLE IF NOT EXISTS decks (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL
            );
        """
        
        let createFlashcardsTable = """
            CREATE TABLE IF NOT EXISTS flashcards (
                id TEXT PRIMARY KEY,
                deckId TEXT NOT NULL,
                question TEXT NOT NULL,
                answer TEXT NOT NULL,
                createdAt TEXT NOT NULL,
                updatedAt TEXT NOT NULL,
                lastReviewed TEXT,
                FOREIGN KEY (deckId) REFERENCES decks (id) ON DELETE CASCADE
            );
        """
        
        if sqlite3_exec(db, createDecksTable, nil, nil, nil) == SQLITE_OK {
            print("✅ Decks table created successfully")
        } else {
            print("❌ Failed to create decks table")
        }
        
        if sqlite3_exec(db, createFlashcardsTable, nil, nil, nil) == SQLITE_OK {
            print("✅ Flashcards table created successfully")
        } else {
            print("❌ Failed to create flashcards table")
        }
        
        // Clean up any corrupted data
        cleanupCorruptedDataSync()
    }
    
    private func cleanupCorruptedDataSync() {
        print("🧹 Cleaning up corrupted data...")
        
        // Delete decks with empty or NULL id/name
        let cleanupDecksQuery = "DELETE FROM decks WHERE id IS NULL OR id = '' OR name IS NULL OR name = ''"
        if sqlite3_exec(db, cleanupDecksQuery, nil, nil, nil) == SQLITE_OK {
            print("✅ Cleaned up corrupted decks")
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to clean up corrupted decks: \(errorMessage)")
        }
        
        // Delete flashcards that reference non-existent decks or have empty IDs
        let cleanupFlashcardsQuery = """
            DELETE FROM flashcards 
            WHERE id IS NULL OR id = '' 
            OR deckId IS NULL OR deckId = '' 
            OR deckId NOT IN (SELECT id FROM decks WHERE id IS NOT NULL AND id != '')
        """
        if sqlite3_exec(db, cleanupFlashcardsQuery, nil, nil, nil) == SQLITE_OK {
            print("✅ Cleaned up corrupted flashcards")
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to clean up corrupted flashcards: \(errorMessage)")
        }
    }
    
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
            FROM decks d 
            LEFT JOIN flashcards f ON d.id = f.deckId 
            GROUP BY d.id 
            ORDER BY d.updatedAt DESC
        """
        
        var decks: [Deck] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
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
        print("📖 Fetched \(decks.count) decks")
        return decks
    }
    
    func getDeck(id: String) async -> Deck? {
        await initialize()
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let deck = self.getDeckSync(id: id)
                continuation.resume(returning: deck)
            }
        }
    }
    
    private func getDeckSync(id: String) -> Deck? {
        print("🔍 getDeckSync called with id: '\(id)'")
        
        // Use direct SQL query instead of prepared statement
        let query = "SELECT id, name, description, createdAt, updatedAt FROM decks WHERE id = '\(id)'"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                let idPtr = sqlite3_column_text(statement, 0)
                let namePtr = sqlite3_column_text(statement, 1)
                let descPtr = sqlite3_column_text(statement, 2)
                let createdAtPtr = sqlite3_column_text(statement, 3)
                let updatedAtPtr = sqlite3_column_text(statement, 4)
                
                print("🔍 Raw column data: id=\(idPtr != nil ? "NOT NULL" : "NULL"), name=\(namePtr != nil ? "NOT NULL" : "NULL")")
                
                guard let idPtr = idPtr, let namePtr = namePtr, 
                      let createdAtPtr = createdAtPtr, let updatedAtPtr = updatedAtPtr else {
                    print("❌ Deck found but has NULL required fields")
                    sqlite3_finalize(statement)
                    return nil
                }
                
                let deckId = String(cString: idPtr)
                let name = String(cString: namePtr)
                let description = descPtr != nil ? String(cString: descPtr!) : nil
                let createdAt = String(cString: createdAtPtr)
                let updatedAt = String(cString: updatedAtPtr)
                
                print("🔧 Retrieved strings: id='\(deckId)', name='\(name)', createdAt='\(createdAt)', updatedAt='\(updatedAt)'")
                
                guard !deckId.isEmpty, !name.isEmpty, !createdAt.isEmpty, !updatedAt.isEmpty else {
                    print("❌ Deck found but has empty required fields: id='\(deckId)', name='\(name)'")
                    sqlite3_finalize(statement)
                    return nil
                }
                
                print("🔍 Found deck in database: id='\(deckId)', name='\(name)'")
                
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
            } else {
                print("❌ No deck found with id: '\(id)'")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to prepare getDeck query: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    func createDeck(name: String, description: String?) async -> String {
        print("🔍 createDeck: Starting - name: \(name)")
        await initialize()
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let id = self.createDeckSync(name: name, description: description)
                continuation.resume(returning: id)
            }
        }
    }
    
    private func createDeckSync(name: String, description: String?) -> String {
        let id = UUID().uuidString
        let now = ISO8601DateFormatter().string(from: Date())
        
        print("💾 createDeckSync: Creating deck with id='\(id)', name='\(name)'")
        
        // Use a simpler approach with direct SQL
        let query = "INSERT INTO decks (id, name, description, createdAt, updatedAt) VALUES ('\(id)', '\(name)', \(description != nil ? "'\(description!)'" : "NULL"), '\(now)', '\(now)')"
        
        print("🔧 Executing query: \(query)")
        
        if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
            print("✅ Created deck with ID: \(id)")
            
            // Verify the deck was created
            let verifyQuery = "SELECT COUNT(*) FROM decks WHERE id = '\(id)'"
            var verifyStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, verifyQuery, -1, &verifyStatement, nil) == SQLITE_OK {
                if sqlite3_step(verifyStatement) == SQLITE_ROW {
                    let count = sqlite3_column_int(verifyStatement, 0)
                    print("✅ Verification: Found \(count) deck(s) with id: \(id)")
                }
                sqlite3_finalize(verifyStatement)
            }
            
            return id
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to create deck: \(errorMessage)")
            return id
        }
    }
    
    
    func deleteDeck(id: String) async {
        await initialize()
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.deleteDeckSync(id: id)
                continuation.resume()
            }
        }
    }
    
    private func deleteDeckSync(id: String) {
        let query = "DELETE FROM decks WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, id, -1, nil)
            
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
    
    func getFlashcards(deckId: String) async -> [Flashcard] {
        await initialize()
        
        return await withCheckedContinuation { continuation in
            dbQueue.async {
                let flashcards = self.getFlashcardsSync(deckId: deckId)
                continuation.resume(returning: flashcards)
            }
        }
    }
    
    private func getFlashcardsSync(deckId: String) -> [Flashcard] {
        print("🔍 getFlashcardsSync called with deckId: '\(deckId)'")
        
        // Use direct SQL query instead of prepared statement
        let query = "SELECT * FROM flashcards WHERE deckId = '\(deckId)' ORDER BY createdAt ASC"
        var flashcards: [Flashcard] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let idPtr = sqlite3_column_text(statement, 0)
                let deckIdPtr = sqlite3_column_text(statement, 1)
                let questionPtr = sqlite3_column_text(statement, 2)
                let answerPtr = sqlite3_column_text(statement, 3)
                let createdAtPtr = sqlite3_column_text(statement, 4)
                let updatedAtPtr = sqlite3_column_text(statement, 5)
                let lastReviewedPtr = sqlite3_column_text(statement, 6)
                
                guard let idPtr = idPtr, let deckIdPtr = deckIdPtr, 
                      let questionPtr = questionPtr, let answerPtr = answerPtr,
                      let createdAtPtr = createdAtPtr, let updatedAtPtr = updatedAtPtr else {
                    print("❌ Flashcard found but has NULL required fields")
                    continue
                }
                
                let id = String(cString: idPtr)
                let flashcardDeckId = String(cString: deckIdPtr)
                let question = String(cString: questionPtr)
                let answer = String(cString: answerPtr)
                let createdAt = String(cString: createdAtPtr)
                let updatedAt = String(cString: updatedAtPtr)
                let lastReviewed = lastReviewedPtr != nil ? String(cString: lastReviewedPtr!) : nil
                
                print("🔍 Found flashcard: id=\(id), deckId=\(flashcardDeckId)")
                
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
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("❌ Failed to prepare getFlashcards query: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        print("📖 Fetched \(flashcards.count) flashcards for deck '\(deckId)'")
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
        print("💾 createFlashcardsSync called with \(flashcards.count) flashcards")
        
        let dateFormatter = ISO8601DateFormatter()
        var successCount = 0
        
        for flashcard in flashcards {
            print("💾 Creating flashcard: id=\(flashcard.id), deckId='\(flashcard.deckId)'")
            
            // Use direct SQL instead of prepared statements
            let createdAtStr = dateFormatter.string(from: flashcard.createdAt)
            let updatedAtStr = dateFormatter.string(from: flashcard.updatedAt)
            let lastReviewedStr = flashcard.lastReviewed != nil ? dateFormatter.string(from: flashcard.lastReviewed!) : "NULL"
            
            let query = """
                INSERT OR REPLACE INTO flashcards (id, deckId, question, answer, createdAt, updatedAt, lastReviewed) 
                VALUES ('\(flashcard.id)', '\(flashcard.deckId)', '\(flashcard.question.replacingOccurrences(of: "'", with: "''"))', '\(flashcard.answer.replacingOccurrences(of: "'", with: "''"))', '\(createdAtStr)', '\(updatedAtStr)', \(lastReviewedStr == "NULL" ? "NULL" : "'\(lastReviewedStr)'"))
            """
            
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                successCount += 1
                print("✅ Successfully created flashcard \(flashcard.id) for deck '\(flashcard.deckId)'")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("❌ Failed to create flashcard \(flashcard.id): \(errorMessage)")
            }
        }
        
        print("✅ Created \(successCount)/\(flashcards.count) flashcards")
    }
    
    func updateFlashcardReview(id: String) async {
        await initialize()
        
        await withCheckedContinuation { continuation in
            dbQueue.async {
                self.updateFlashcardReviewSync(id: id)
                continuation.resume()
            }
        }
    }
    
    private func updateFlashcardReviewSync(id: String) {
        let now = ISO8601DateFormatter().string(from: Date())
        let query = "UPDATE flashcards SET lastReviewed = ? WHERE id = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, now, -1, nil)
            sqlite3_bind_text(statement, 2, id, -1, nil)
            
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