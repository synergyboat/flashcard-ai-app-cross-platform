import 'package:floor/floor.dart';
import 'deck_db_entity.dart';

@Entity(
  tableName: 'flashcard',
  foreignKeys: [
    ForeignKey(
      childColumns: ['deckId'],
      parentColumns: ['id'],
      entity: DeckDbEntity,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class FlashcardDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int deckId;
  final String question;
  final String answer;

  FlashcardDbEntity({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });
}