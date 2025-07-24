import Foundation
import CoreData

extension DeckEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeckEntity> {
        return NSFetchRequest<DeckEntity>(entityName: "DeckEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var deckDescription: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var updatedAt: Date?

} 