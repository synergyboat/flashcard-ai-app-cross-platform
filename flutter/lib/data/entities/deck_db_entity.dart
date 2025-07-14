import 'package:flashcard/core/utils/date_time_converter.dart';
import 'package:floor/floor.dart';

@Entity(tableName: 'deck')
class DeckDbEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String description;

  @TypeConverters([DateTimeConverter])
  final DateTime? createdAt;
  @TypeConverters([DateTimeConverter])
  final DateTime? updatedAt;

  DeckDbEntity({
    this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  DeckDbEntity copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeckDbEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}