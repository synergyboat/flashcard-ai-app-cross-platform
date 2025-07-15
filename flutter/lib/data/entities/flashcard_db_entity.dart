import 'package:floor/floor.dart';
import '../../core/utils/date_time_converter.dart';
import '../../domain/entities/flashcard.dart';
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

  final int? deckId;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'question': question,
      'answer': answer,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }

  factory FlashcardDbEntity.fromJson(Map<String, dynamic> json) {
    return FlashcardDbEntity(
      id: json['id'] as int?,
      deckId: json['deckId'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String)
          : null,
    );
  }

  factory FlashcardDbEntity.fromFlashcard(Flashcard flashcard) {
    return FlashcardDbEntity(
      id: flashcard.id,
      deckId: flashcard.deckId,
      question: flashcard.question,
      answer: flashcard.answer,
      createdAt: flashcard.createdAt,
      updatedAt: flashcard.updatedAt,
      lastReviewed: flashcard.lastReviewed,
    );
  }

  Flashcard toFlashcard() {
    return Flashcard(
      id: id,
      deckId: deckId,
      question: question,
      answer: answer,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastReviewed: lastReviewed,
    );
  }
}