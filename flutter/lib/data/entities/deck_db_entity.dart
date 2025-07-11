import 'package:flashcard/data/entities/flashcard_db_entity.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'deck')
class DeckDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'description')
  final String description;

  @ignore
  final List<FlashcardDbEntity> flashcard;

  DeckDbEntity({
    this.id,
    required this.name,
    required this.description,
    this.flashcard = const [],
  });
}