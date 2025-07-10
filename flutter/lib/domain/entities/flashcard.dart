class Flashcard {
  final String? id;
  final String? deckId;
  final String question;
  final String answer;

  Flashcard({
    this.id,
    this.deckId,
    required this.question,
    required this.answer,
  });

  @override
  String toString() {
    return 'Flashcard(id: $id, question: $question, answer: $answer, deckId: $deckId)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'question': question,
      'answer': answer,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String?,
      deckId: json['deckId'] as String?,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}

