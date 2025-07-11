import 'package:floor/floor.dart';
import 'flashcard_db_entity.dart'; // Ensure this path is relative if needed

@Entity(tableName: 'deck')
class DeckDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;

  final String description;

  @ignore
  final List<FlashcardDbEntity> flashcard; // Used only for in-memory usage like `DeckWithFlashcards`

  DeckDbEntity({
    this.id,
    required this.name,
    required this.description,
    this.flashcard = const [],
  });
}