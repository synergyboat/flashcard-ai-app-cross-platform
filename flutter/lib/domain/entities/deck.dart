import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String description;
  final List<Flashcard> flashcards;

  Deck({
    required this.id,
    required this.name,
    required this.description,
    this.flashcards = const [],
  });

  @override
  String toString() {
    return 'Deck(id: $id, name: $name, description: $description)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }
}