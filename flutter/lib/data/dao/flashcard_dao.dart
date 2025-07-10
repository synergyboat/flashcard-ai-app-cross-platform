import 'package:floor/floor.dart';
import 'deck_dao.dart';

@Entity(
  tableName: 'flashcard',
  foreignKeys: [
    ForeignKey(
      childColumns: ['deckId'],
      parentColumns: ['id'],
      entity: DeckDao,
      onDelete: ForeignKeyAction.cascade,
    )
  ],
)
class Flashcard {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int deckId;
  final String question;
  final String answer;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });
}