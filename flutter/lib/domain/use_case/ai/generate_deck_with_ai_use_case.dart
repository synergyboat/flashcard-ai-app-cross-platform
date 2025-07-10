import 'dart:convert';

import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flashcard/domain/repository/ai/ai_generator_repository.dart';

import '../../entities/deck.dart';

class GenerateDeckWithAIUseCase {
  final AIGeneratorRepository _aiRepository;

  GenerateDeckWithAIUseCase(
    this._aiRepository
  );

  Future<Deck> call({
    String? deckId,
    int count = 10,
    String prompt = ""}
      ) async {
    final String? response = await _aiRepository.generateDeck(
        deckId,
        count,
        prompt
    );
    if (response == null || response.isEmpty) {
      throw Exception("Failed to generate deck with AI");
    }
    // Assuming the generated flashcards are in a format that can be parsed into a Deck
    Deck deck = Deck.fromJson(json.decode(response));
    return deck;
  }
}