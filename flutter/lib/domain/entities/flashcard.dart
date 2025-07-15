class Flashcard {
  final int? id;
  final int? deckId;
  final String question;
  final String answer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastReviewed;

  Flashcard({
    this.id,
    this.deckId,
    required this.question,
    required this.answer,
    this.createdAt,
    this.updatedAt,
    this.lastReviewed,
  });

  @override
  String toString() {
    return 'Flashcard(id: $id, question: $question, answer: $answer, deckId: $deckId), '
        'createdAt: $createdAt, updatedAt: $updatedAt, lastReviewed: $lastReviewed';
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

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as int?,
      deckId: json['deckId'] as int?,
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
          : null
    );
  }

  Flashcard copyWith({
    int? id,
    int? deckId,
    String? question,
    String? answer,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReviewed,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}

