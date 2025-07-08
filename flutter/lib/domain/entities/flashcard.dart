class Flashcard {
  final String? id;
  final String? deckId;
  final String question;
  final String answer;
  final String? imageUrl;

  Flashcard({
    this.id,
    this.deckId,
    required this.question,
    required this.answer,
    this.imageUrl,
  });

  @override
  String toString() {
    return 'Flashcard(id: $id, question: $question, answer: $answer, imageUrl: $imageUrl)';
  }
}

