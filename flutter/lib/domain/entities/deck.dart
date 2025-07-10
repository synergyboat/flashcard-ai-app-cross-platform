import 'flashcard.dart';

class Deck {
  final String? id;
  final String? name;
  final String? description;
  final List<Flashcard> flashcards;

  Deck({
    this.id,
    required this.name,
    required this.description,
    this.flashcards = const [],
  });

  @override
  String toString() {
    return 'Deck(id: $id, name: $name, description: $description), flashcards: ${flashcards.toString()})';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      flashcards: (json['flashcards'] as List<dynamic>)
          .map((f) => Flashcard.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}