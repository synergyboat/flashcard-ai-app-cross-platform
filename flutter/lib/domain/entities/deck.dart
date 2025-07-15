import 'flashcard.dart';

class Deck {
  final int? id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Flashcard> flashcards;

  Deck({
    this.id,
    required this.name,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.flashcards = const [],
  });

  @override
  String toString() {
    return 'Deck(id: $id, '
        'name: $name, '
        'description: $description), '
        'flashcards: ${flashcards.toString()}, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt) ';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      flashcards: (json['flashcards'] as List<dynamic>)
          .map((f) => Flashcard.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Deck copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Flashcard>? flashcards,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flashcards: flashcards ?? this.flashcards,
    );
  }
}