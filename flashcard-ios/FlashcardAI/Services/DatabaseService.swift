import Foundation
import CoreData

class DatabaseService {
    static let shared = DatabaseService()
    
    private var _persistentContainer: NSPersistentContainer?
    private var initializationTask: Task<Void, Never>?
    
    private init() {}
    
    var persistentContainer: NSPersistentContainer {
        get async {
            if let container = _persistentContainer {
                return container
            }
            
            if let task = initializationTask {
                await task.value
                return _persistentContainer!
            }
            
            initializationTask = Task {
                await initializeContainer()
            }
            
            await initializationTask!.value
            return _persistentContainer!
        }
    }
    
    var context: NSManagedObjectContext {
        get async {
            let container = await persistentContainer
            return container.viewContext
        }
    }
    
    private func initializeContainer() async {
        print("🗄️ DatabaseService: Starting Core Data initialization...")
        
        let container = NSPersistentContainer(name: "FlashcardModel")
        
        await withCheckedContinuation { continuation in
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("❌ Core Data failed to load: \(error)")
                    fatalError("Core Data failed to load: \(error)")
                }
                print("✅ DatabaseService: Core Data initialization completed")
                self._persistentContainer = container
                continuation.resume()
            }
        }
    }
    
    func initialize() async {
        _ = await persistentContainer
    }
    
    func saveContext() async {
        let managedContext = await context
        if managedContext.hasChanges {
            do {
                try managedContext.save()
                print("💾 Context saved successfully")
            } catch {
                print("❌ Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Deck Operations
    
    func getDecks() async -> [Deck] {
        await initialize()
        let managedContext = await context
        
        return await withCheckedContinuation { continuation in
            let request: NSFetchRequest<DeckEntity> = DeckEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
            
            do {
                let deckEntities = try managedContext.fetch(request)
                let decks = deckEntities.map { entity in
                    let flashcardCount = getFlashcardCount(for: entity.id ?? "", context: managedContext)
                    return Deck(
                        id: entity.id ?? "",
                        name: entity.name ?? "",
                        description: entity.deckDescription,
                        createdAt: entity.createdAt ?? Date(),
                        updatedAt: entity.updatedAt ?? Date(),
                        flashcardCount: flashcardCount
                    )
                }
                print("📖 Fetched \(decks.count) decks")
                continuation.resume(returning: decks)
            } catch {
                print("❌ Failed to fetch decks: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    func getDeck(id: String) async -> Deck? {
        await initialize()
        
        return await withCheckedContinuation { continuation in
            let request: NSFetchRequest<DeckEntity> = DeckEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let deckEntities = try context.fetch(request)
                if let entity = deckEntities.first {
                    let deck = Deck(
                        id: entity.id ?? "",
                        name: entity.name ?? "",
                        description: entity.deckDescription,
                        createdAt: entity.createdAt ?? Date(),
                        updatedAt: entity.updatedAt ?? Date()
                    )
                    continuation.resume(returning: deck)
                } else {
                    continuation.resume(returning: nil)
                }
            } catch {
                print("Failed to fetch deck: \(error)")
                continuation.resume(returning: nil)
            }
        }
    }
    
    func createDeck(name: String, description: String?) async -> String {
        await initialize()
        let managedContext = await context
        
        return await withCheckedContinuation { continuation in
            let entity = DeckEntity(context: managedContext)
            let id = UUID().uuidString
            entity.id = id
            entity.name = name
            entity.deckDescription = description
            entity.createdAt = Date()
            entity.updatedAt = Date()
            
            Task {
                await saveContext()
                print("✅ Created deck with ID: \(id)")
                continuation.resume(returning: id)
            }
        }
    }
    
    func deleteDeck(id: String) async {
        await initialize()
        
        await withCheckedContinuation { continuation in
            let request: NSFetchRequest<DeckEntity> = DeckEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let deckEntities = try context.fetch(request)
                for entity in deckEntities {
                    context.delete(entity)
                }
                saveContext()
            } catch {
                print("Failed to delete deck: \(error)")
            }
            continuation.resume(returning: ())
        }
    }
    
    // MARK: - Flashcard Operations
    
    func getFlashcards(deckId: String) async -> [Flashcard] {
        await initialize()
        
        return await withCheckedContinuation { continuation in
            let request: NSFetchRequest<FlashcardEntity> = FlashcardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "deckId == %@", deckId)
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
            
            do {
                let flashcardEntities = try context.fetch(request)
                let flashcards = flashcardEntities.map { entity in
                    Flashcard(
                        id: entity.id ?? "",
                        deckId: entity.deckId ?? "",
                        question: entity.question ?? "",
                        answer: entity.answer ?? "",
                        createdAt: entity.createdAt ?? Date(),
                        updatedAt: entity.updatedAt ?? Date(),
                        lastReviewed: entity.lastReviewed
                    )
                }
                continuation.resume(returning: flashcards)
            } catch {
                print("Failed to fetch flashcards: \(error)")
                continuation.resume(returning: [])
            }
        }
    }
    
    func createFlashcards(_ flashcards: [Flashcard]) async {
        await initialize()
        let managedContext = await context
        
        await withCheckedContinuation { continuation in
            for flashcard in flashcards {
                let entity = FlashcardEntity(context: managedContext)
                entity.id = flashcard.id
                entity.deckId = flashcard.deckId
                entity.question = flashcard.question
                entity.answer = flashcard.answer
                entity.createdAt = flashcard.createdAt
                entity.updatedAt = flashcard.updatedAt
                entity.lastReviewed = flashcard.lastReviewed
            }
            
            Task {
                await saveContext()
                print("✅ Created \(flashcards.count) flashcards")
                continuation.resume(returning: ())
            }
        }
    }
    
    func updateFlashcardReview(id: String) async {
        await initialize()
        
        await withCheckedContinuation { continuation in
            let request: NSFetchRequest<FlashcardEntity> = FlashcardEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let flashcardEntities = try context.fetch(request)
                if let entity = flashcardEntities.first {
                    entity.lastReviewed = Date()
                    saveContext()
                }
            } catch {
                print("Failed to update flashcard review: \(error)")
            }
            continuation.resume(returning: ())
        }
    }
    
    private func getFlashcardCount(for deckId: String, context: NSManagedObjectContext) -> Int {
        let request: NSFetchRequest<FlashcardEntity> = FlashcardEntity.fetchRequest()
        request.predicate = NSPredicate(format: "deckId == %@", deckId)
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Failed to count flashcards: \(error)")
            return 0
        }
    }
}

// MARK: - Core Data Entities are auto-generated by Core Data with codeGenerationType="class" 