import Foundation
import CoreData

extension FlashcardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlashcardEntity> {
        return NSFetchRequest<FlashcardEntity>(entityName: "FlashcardEntity")
    }

    @NSManaged public var answer: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var deckId: String?
    @NSManaged public var id: String?
    @NSManaged public var lastReviewed: Date?
    @NSManaged public var question: String?
    @NSManaged public var updatedAt: Date?

} 