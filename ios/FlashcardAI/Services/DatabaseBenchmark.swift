import Foundation

protocol Logger {
    func debug(_ message: String)
    func info(_ message: String)
    func error(_ message: String)
}

struct Metrics {
    let iteration: Int
    let dbRowSizeAddDemoDeck: Int              // bytes
    let dbWriteAddDemoDeck: Double             // ms (2 decimals)
    let dbRowSizeAddDemoFlashcard: Int         // bytes
    let dbWriteAddDemoFlashcard: Double        // ms (2 decimals)
    let dbReadFetchDemoDeck: Double            // ms (2 decimals)
    let dbRowSizeFetchedDemoDeck: Int          // bytes
    let dbReadFetchDemoFlashcards: Double      // ms (2 decimals)
    let dbRowSizeFetchedDemoFlashcards: Int    // bytes
    let dbRead: Double                         // ms (2 decimals)
    let dbReadGetAllDecksWithFlashcards: Double // ms (2 decimals)
    let dbRowSizeGetAllDecksWithFlashcards: Int // bytes
}

class DatabaseBenchmark {
    static let shared = DatabaseBenchmark()
    
    private var logger: Logger = DefaultLogger()
    
    private init() {}
    
    func setLogger(_ logger: Logger) {
        self.logger = logger
    }
    
    func runBenchmark(iterations: Int = 1) async {
        await DatabaseService.shared.initialize()
        var allMetrics: [Metrics] = []
        
        for i in 1...iterations {
            logger.info("=== Iteration \(i) ===")
            let metrics = await benchmarkOnce(iteration: i)
            allMetrics.append(metrics)
        }
        
        prettyPrint(allMetrics)
    }
    
    private func benchmarkOnce(iteration: Int) async -> Metrics {
        // 1) Demo Deck
        let demoDeck = Deck(
            name: "Benchmark Deck",
            description: "A deck for benchmarking purposes"
        )
        
        // Log row size for demo deck
        let demoDeckDict = demoDeck.toDictionary()
        DbSizeLogger.logDbRowSize(
            demoDeckDict,
            name: "Demo Deck",
            tag: "db_row_size_add_demo_Deck"
        )
        let dbRowSizeAddDemoDeck = RowSizeBenchmark.getRowSizeInBytes(demoDeck)
        
        // Create deck and measure time
        let deckStart = HighResolutionTimer.now()
        let deckId = await ExecutionLogger.logExecDurationAsync(
            name: "Adding demo deck to DB",
            tag: "db_write_add_demo_deck"
        ) {
            await DatabaseService.shared.createDeck(
                name: demoDeck.name,
                description: demoDeck.description
            )
        }
        let dbWriteAddDemoDeck = round2(HighResolutionTimer.elapsed(since: deckStart))
        
        // 2) Demo Flashcard
        let demoFlashcard = Flashcard(
            deckId: deckId,
            question: "What is the capital of Germany?",
            answer: "Berlin"
        )
        
        let demoFlashcardDict = demoFlashcard.toDictionary()
        DbSizeLogger.logDbRowSize(
            demoFlashcardDict,
            name: "Demo Flashcard",
            tag: "db_row_size_add_demo_flashcard"
        )
        let dbRowSizeAddDemoFlashcard = RowSizeBenchmark.getRowSizeInBytes(demoFlashcard)
        
        let flashcardStart = HighResolutionTimer.now()
        await ExecutionLogger.logExecDurationAsync(
            name: "Adding demo flashcard to DB",
            tag: "db_write_add_demo_flashcard"
        ) {
            await DatabaseService.shared.createFlashcards([demoFlashcard])
        }
        let dbWriteAddDemoFlashcard = round2(HighResolutionTimer.elapsed(since: flashcardStart))
        
        // 3) Fetch demo deck by id
        let fetchDeckStart = HighResolutionTimer.now()
        let fetchedDeck = await ExecutionLogger.logExecDurationAsync(
            name: "Fetching demo deck from DB",
            tag: "db_read_fetch_demo_deck"
        ) {
            await DatabaseService.shared.getDeck(id: deckId)
        }
        let dbReadFetchDemoDeck = round2(HighResolutionTimer.elapsed(since: fetchDeckStart))
        
        let deckForSize = fetchedDeck ?? Deck(name: "Not Found", description: "Not Found")
        let dbRowSizeFetchedDemoDeck = RowSizeBenchmark.getRowSizeInBytes(deckForSize)
        DbSizeLogger.logDbRowSize(
            deckForSize.toDictionary(),
            name: "Fetched Demo Deck",
            tag: "db_row_size_fetched_demo_deck"
        )
        
        // 4) Fetch flashcards for deck
        let fetchFlashcardsStart = HighResolutionTimer.now()
        let fetchedFlashcards = await ExecutionLogger.logExecDurationAsync(
            name: "Fetching flashcards for demo deck",
            tag: "db_read_fetch_demo_flashcards"
        ) {
            await DatabaseService.shared.getFlashcards(deckId: deckId)
        }
        let dbReadFetchDemoFlashcards = round2(HighResolutionTimer.elapsed(since: fetchFlashcardsStart))
        
        let dbRowSizeFetchedDemoFlashcards = RowSizeBenchmark.getRowSizeInBytes(fetchedFlashcards)
        DbSizeLogger.logTotalDbRowSize(
            fetchedFlashcards.map { $0.toDictionary() },
            name: "Fetched Demo Flashcards",
            tag: "db_row_size_fetched_demo_flashcards"
        )
        
        // 5) General read - all decks
        let readAllStart = HighResolutionTimer.now()
        await ExecutionLogger.logExecDurationAsync(
            name: "General read (all decks)",
            tag: "db_read"
        ) {
            await DatabaseService.shared.getDecks()
        }
        let dbRead = round2(HighResolutionTimer.elapsed(since: readAllStart))
        
        // 6) Fetch ALL decks WITH flashcards
        let allDecksWithFlashcardsStart = HighResolutionTimer.now()
        let allDecksWithFlashcards = await ExecutionLogger.logExecDurationAsync(
            name: "Fetching all decks with flashcards",
            tag: "db_read_getAllDecksWithFlashcards"
        ) {
            await getAllDecksWithFlashcards()
        }
        let dbReadGetAllDecksWithFlashcards = round2(HighResolutionTimer.elapsed(since: allDecksWithFlashcardsStart))
        
        let dbRowSizeGetAllDecksWithFlashcards = RowSizeBenchmark.getRowSizeInBytes(allDecksWithFlashcards)
        DbSizeLogger.logTotalDbRowSize(
            allDecksWithFlashcards.map { $0.toDictionary() },
            name: "All Decks With Flashcards",
            tag: "db_row_size_getAllDecksWithFlashcards"
        )
        
        // Clean up
        do {
            await DatabaseService.shared.deleteDeck(id: deckId)
        } catch {
            logger.debug("Cleanup deleteDeck ignored: \(error.localizedDescription)")
        }
        
        return Metrics(
            iteration: iteration,
            dbRowSizeAddDemoDeck: dbRowSizeAddDemoDeck,
            dbWriteAddDemoDeck: dbWriteAddDemoDeck,
            dbRowSizeAddDemoFlashcard: dbRowSizeAddDemoFlashcard,
            dbWriteAddDemoFlashcard: dbWriteAddDemoFlashcard,
            dbReadFetchDemoDeck: dbReadFetchDemoDeck,
            dbRowSizeFetchedDemoDeck: dbRowSizeFetchedDemoDeck,
            dbReadFetchDemoFlashcards: dbReadFetchDemoFlashcards,
            dbRowSizeFetchedDemoFlashcards: dbRowSizeFetchedDemoFlashcards,
            dbRead: dbRead,
            dbReadGetAllDecksWithFlashcards: dbReadGetAllDecksWithFlashcards,
            dbRowSizeGetAllDecksWithFlashcards: dbRowSizeGetAllDecksWithFlashcards
        )
    }
    
    private func getAllDecksWithFlashcards() async -> [DeckWithFlashcards] {
        let decks = await DatabaseService.shared.getDecks()
        var decksWithFlashcards: [DeckWithFlashcards] = []
        
        for deck in decks {
            guard let deckId = deck.id else { continue }
            let flashcards = await DatabaseService.shared.getFlashcards(deckId: deckId)
            let deckWithFlashcards = DeckWithFlashcards(deck: deck, flashcards: flashcards)
            decksWithFlashcards.append(deckWithFlashcards)
        }
        
        return decksWithFlashcards
    }
    
    private func prettyPrint(_ metrics: [Metrics]) {
        guard !metrics.isEmpty else { return }
        
        let headers = [
            "Iteration",
            "db_row_size_add_demo_Deck",
            "db_write_add_demo_deck",
            "db_row_size_add_demo_flashcard",
            "db_write_add_demo_flashcard",
            "db_read_fetch_demo_deck",
            "db_row_size_fetched_demo_deck",
            "db_read_fetch_demo_flashcards",
            "db_row_size_fetched_demo_flashcards",
            "db_read",
            "db_read_getAllDecksWithFlashcards",
            "db_row_size_getAllDecksWithFlashcards"
        ]
        
        let rowsStr: [[String]] = [headers] + metrics.map { m in
            [
                String(m.iteration),
                "\(m.dbRowSizeAddDemoDeck) B",
                String(format: "%.2f ms", m.dbWriteAddDemoDeck),
                "\(m.dbRowSizeAddDemoFlashcard) B",
                String(format: "%.2f ms", m.dbWriteAddDemoFlashcard),
                String(format: "%.2f ms", m.dbReadFetchDemoDeck),
                "\(m.dbRowSizeFetchedDemoDeck) B",
                String(format: "%.2f ms", m.dbReadFetchDemoFlashcards),
                "\(m.dbRowSizeFetchedDemoFlashcards) B",
                String(format: "%.2f ms", m.dbRead),
                String(format: "%.2f ms", m.dbReadGetAllDecksWithFlashcards),
                "\(m.dbRowSizeGetAllDecksWithFlashcards) B"
            ]
        }
        
        let colWidths = headers.indices.map { columnIndex in
            rowsStr.map { row in row[columnIndex].count }.max() ?? 0
        }
        
        let pad = { (string: String, width: Int) in
            string + String(repeating: " ", count: max(0, width - string.count))
        }
        
        let line = { (row: [String]) in
            row.enumerated().map { (index, cell) in
                pad(cell, colWidths[index])
            }.joined(separator: "  ")
        }
        
        let sepLen = colWidths.reduce(0, +) + (headers.count - 1) * 2
        
        logger.info("=== Benchmark Results ===")
        logger.info(line(rowsStr[0]))
        logger.info(String(repeating: "-", count: sepLen))
        for i in 1..<rowsStr.count {
            logger.info(line(rowsStr[i]))
        }
    }
}

// MARK: - Helper Classes and Extensions

struct DeckWithFlashcards: Codable {
    let deck: Deck
    let flashcards: [Flashcard]
}

class DefaultLogger: Logger {
    func debug(_ message: String) {
        print("[DEBUG] \(message)")
    }
    
    func info(_ message: String) {
        print("[INFO] \(message)")
    }
    
    func error(_ message: String) {
        print("[ERROR] \(message)")
    }
}

enum HighResolutionTimer {
    static func now() -> Double {
        return CFAbsoluteTimeGetCurrent() * 1000.0 // Convert to milliseconds
    }
    
    static func elapsed(since start: Double) -> Double {
        return now() - start
    }
}

private func round2(_ value: Double) -> Double {
    return (value * 100.0).rounded() / 100.0
}

// MARK: - Extensions for Dictionary conversion

extension Deck {
    func toDictionary() -> [String: Any] {
        let dateFormatter = ISO8601DateFormatter()
        return [
            "id": id as Any,
            "name": name,
            "description": description,
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt),
            "flashcardCount": flashcardCount as Any
        ]
    }
}

extension Flashcard {
    func toDictionary() -> [String: Any] {
        let dateFormatter = ISO8601DateFormatter()
        return [
            "id": id as Any,
            "deckId": deckId,
            "question": question,
            "answer": answer,
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt),
            "lastReviewed": lastReviewed.map { dateFormatter.string(from: $0) } as Any
        ]
    }
}

extension DeckWithFlashcards {
    func toDictionary() -> [String: Any] {
        return [
            "deck": deck.toDictionary(),
            "flashcards": flashcards.map { $0.toDictionary() }
        ]
    }
}

// MARK: - Convenience Functions

func runBenchmark(iterations: Int = 1) async {
    await DatabaseBenchmark.shared.runBenchmark(iterations: iterations)
}

func runQuickBenchmark() async {
    await DatabaseBenchmark.shared.runBenchmark(iterations: 1)
}