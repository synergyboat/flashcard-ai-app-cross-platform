import 'package:floor/floor.dart';
import '../../core/utils/date_time_converter.dart';
import 'deck_db_entity.dart';

@Entity(
  tableName: 'flashcard',
  foreignKeys: [
    ForeignKey(
      childColumns: ['deckId'],
      parentColumns: ['id'],
      entity: DeckDbEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class FlashcardDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int deckId;
  final String question;
  final String answer;
  @TypeConverters([DateTimeConverter])
  final DateTime? createdAt;
  @TypeConverters([DateTimeConverter])
  final DateTime? updatedAt;
  @TypeConverters([DateTimeConverter])
  final DateTime? lastReviewed;

  FlashcardDbEntity({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.createdAt,
    this.updatedAt,
    this.lastReviewed,
  });

  FlashcardDbEntity copyWith({
    int? id,
    int? deckId,
    String? question,
    String? answer,
    int? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReviewed,
  }) {
    return FlashcardDbEntity(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}