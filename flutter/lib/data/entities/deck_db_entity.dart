import 'package:flashcard/core/utils/date_time_converter.dart';
import 'package:floor/floor.dart';

import '../../domain/entities/deck.dart';

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

  factory DeckDbEntity.fromJson(Map<String, dynamic> json) {
    return DeckDbEntity(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeckDbEntity.fromDeck(Deck deck) {
    return DeckDbEntity(
      id: deck.id,
      name: deck.name??'',
      description: deck.description??'',
      createdAt: deck.createdAt,
      updatedAt: deck.updatedAt,
    );
  }

  Deck toDeck() {
    return Deck(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}