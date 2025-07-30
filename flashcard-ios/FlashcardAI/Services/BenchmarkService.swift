import Foundation
import os.log

class BenchmarkService {
    static let shared = BenchmarkService()
    private let logger = Logger(subsystem: "com.flashcardai.benchmark", category: "database")
    
    private init() {}
    
    // MARK: - Execution Duration Benchmarking
    
    func logExecDuration<T>(_ operation: () throws -> T, name: String, tag: String) throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let result = try operation()
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            logger.info("⏱️ \(name) completed in \(String(format: "%.4f", duration))s [\(tag)]")
            print("⏱️ \(name) completed in \(String(format: "%.4f", duration))s [\(tag)]")
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            logger.error("❌ \(name) failed after \(String(format: "%.4f", duration))s [\(tag)]: \(error.localizedDescription)")
            print("❌ \(name) failed after \(String(format: "%.4f", duration))s [\(tag)]: \(error.localizedDescription)")
            throw error
        }
    }
    
    func logExecDurationAsync<T>(_ operation: () async throws -> T, name: String, tag: String) async throws -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        do {
            let result = try await operation()
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            
            logger.info("⏱️ \(name) completed in \(String(format: "%.4f", duration))s [\(tag)]")
            print("⏱️ \(name) completed in \(String(format: "%.4f", duration))s [\(tag)]")
            
            return result
        } catch {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            logger.error("❌ \(name) failed after \(String(format: "%.4f", duration))s [\(tag)]: \(error.localizedDescription)")
            print("❌ \(name) failed after \(String(format: "%.4f", duration))s [\(tag)]: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Database Row Size Benchmarking
    
    func logDbRowSize(_ data: [String: Any], name: String, tag: String) {
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        let sizeInBytes = jsonData?.count ?? 0
        let sizeInKB = Double(sizeInBytes) / 1024.0
        
        logger.info("📊 \(name) row size: \(sizeInBytes) bytes (\(String(format: "%.2f", sizeInKB)) KB) [\(tag)]")
        print("📊 \(name) row size: \(sizeInBytes) bytes (\(String(format: "%.2f", sizeInKB)) KB) [\(tag)]")
    }
    
    func logTotalDbRowSize(_ dataArray: [[String: Any]], name: String, tag: String) {
        let totalSize = dataArray.reduce(0) { total, data in
            let jsonData = try? JSONSerialization.data(withJSONObject: data)
            return total + (jsonData?.count ?? 0)
        }
        let totalSizeInKB = Double(totalSize) / 1024.0
        
        logger.info("📊 \(name) total size: \(totalSize) bytes (\(String(format: "%.2f", totalSizeInKB)) KB) for \(dataArray.count) items [\(tag)]")
        print("📊 \(name) total size: \(totalSize) bytes (\(String(format: "%.2f", totalSizeInKB)) KB) for \(dataArray.count) items [\(tag)]")
    }
    
    // MARK: - Database Benchmark Operations
    
    func benchmarkDatabase() async {
        logger.info("🚀 Starting database benchmark...")
        print("🚀 Starting database benchmark...")
        
        do {
            let database = DatabaseService.shared
            
            // Benchmark deck creation
            let demoDeck = Deck(
                id: UUID().uuidString,
                name: "Benchmark Deck",
                description: "A deck for benchmarking purposes",
                createdAt: Date(),
                updatedAt: Date()
            )
            
            let deckData = [
                "id": demoDeck.id,
                "name": demoDeck.name,
                "description": demoDeck.description ?? "",
                "createdAt": ISO8601DateFormatter().string(from: demoDeck.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: demoDeck.updatedAt)
            ]
            
            logDbRowSize(deckData, name: "Demo Deck", tag: "db_row_size_add_demo_deck")
            
            let deckId = try await logExecDurationAsync({
                return await database.createDeck(name: demoDeck.name, description: demoDeck.description)
            }, name: "Adding demo deck to DB", tag: "db_write_add_demo_deck")
            
            // Benchmark flashcard creation
            let demoFlashcard = Flashcard(
                id: UUID().uuidString,
                deckId: deckId,
                question: "What is the capital of Germany?",
                answer: "Berlin",
                createdAt: Date(),
                updatedAt: Date(),
                lastReviewed: nil
            )
            
            let flashcardData = [
                "id": demoFlashcard.id,
                "deckId": demoFlashcard.deckId,
                "question": demoFlashcard.question,
                "answer": demoFlashcard.answer,
                "createdAt": ISO8601DateFormatter().string(from: demoFlashcard.createdAt),
                "updatedAt": ISO8601DateFormatter().string(from: demoFlashcard.updatedAt),
                "lastReviewed": demoFlashcard.lastReviewed?.description ?? "nil"
            ]
            
            logDbRowSize(flashcardData, name: "Demo Flashcard", tag: "db_row_size_add_demo_flashcard")
            
            try await logExecDurationAsync({
                await database.createFlashcards([demoFlashcard])
            }, name: "Adding demo flashcard to DB", tag: "db_write_add_demo_flashcard")
            
            // Benchmark deck retrieval
            let fetchedDeck = try await logExecDurationAsync({
                return await database.getDeck(id: deckId)
            }, name: "Fetching demo deck from DB", tag: "db_read_fetch_demo_deck")
            
            if let fetchedDeck = fetchedDeck {
                let fetchedDeckData = [
                    "id": fetchedDeck.id,
                    "name": fetchedDeck.name,
                    "description": fetchedDeck.description ?? "",
                    "createdAt": ISO8601DateFormatter().string(from: fetchedDeck.createdAt),
                    "updatedAt": ISO8601DateFormatter().string(from: fetchedDeck.updatedAt)
                ]
                logDbRowSize(fetchedDeckData, name: "Fetched Demo Deck", tag: "db_row_size_fetched_demo_deck")
            }
            
            // Benchmark flashcard retrieval
            let fetchedFlashcards = try await logExecDurationAsync({
                return await database.getFlashcards(deckId: deckId)
            }, name: "Fetching flashcards for demo deck", tag: "db_read_fetch_demo_flashcards")
            
            let fetchedFlashcardData = fetchedFlashcards.map { flashcard in
                return [
                    "id": flashcard.id,
                    "deckId": flashcard.deckId,
                    "question": flashcard.question,
                    "answer": flashcard.answer,
                    "createdAt": ISO8601DateFormatter().string(from: flashcard.createdAt),
                    "updatedAt": ISO8601DateFormatter().string(from: flashcard.updatedAt),
                    "lastReviewed": flashcard.lastReviewed?.description ?? "nil"
                ]
            }
            
            logTotalDbRowSize(fetchedFlashcardData, name: "Fetched Demo Flashcards", tag: "db_row_size_fetched_demo_flashcards")
            
            logger.info("✅ Database benchmark completed successfully")
            print("✅ Database benchmark completed successfully")
            
        } catch {
            logger.error("❌ Database benchmark failed: \(error.localizedDescription)")
            print("❌ Database benchmark failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AI Service Benchmarking
    
    func benchmarkAIService() async {
        logger.info("🚀 Starting AI service benchmark...")
        print("🚀 Starting AI service benchmark...")
        
        do {
            let aiService = AIService.shared
            
            let request = AIGenerationRequest(topic: "Benchmark Topic", cardCount: 3)
            
            let response = try await logExecDurationAsync({
                return try await aiService.generateFlashcards(request: request)
            }, name: "AI flashcard generation", tag: "ai_generate_flashcards")
            
            let responseData = [
                "deckName": response.deck.name,
                "deckDescription": response.deck.description,
                "flashcardCount": response.flashcards.count,
                "flashcards": response.flashcards.map { card in
                    return [
                        "question": card.question,
                        "answer": card.answer
                    ]
                }
            ]
            
            logDbRowSize(responseData, name: "AI Generation Response", tag: "ai_response_size")
            
            logger.info("✅ AI service benchmark completed successfully")
            print("✅ AI service benchmark completed successfully")
            
        } catch {
            logger.error("❌ AI service benchmark failed: \(error.localizedDescription)")
            print("❌ AI service benchmark failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Full App Benchmark
    
    func runFullBenchmark() async {
        logger.info("🚀 Starting full app benchmark...")
        print("🚀 Starting full app benchmark...")
        
        await benchmarkDatabase()
        await benchmarkAIService()
        
        logger.info("✅ Full app benchmark completed")
        print("✅ Full app benchmark completed")
    }
} 