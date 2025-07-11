import 'package:floor/floor.dart';
import 'deck_db_entity.dart';

@Entity(
  tableName: 'flashcard',
  foreignKeys: [
    ForeignKey(
      childColumns: ['deckId'],           // Local column in this table
      parentColumns: ['id'],              // References 'id' in parent table
      entity: DeckDbEntity,               // Parent table
      onDelete: ForeignKeyAction.cascade, // Delete flashcards if deck is deleted
    ),
  ],
)
class FlashcardDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int deckId; // foreign key field — linked via the Entity-level metadata

  final String question;
  final String answer;

  FlashcardDbEntity({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });
}