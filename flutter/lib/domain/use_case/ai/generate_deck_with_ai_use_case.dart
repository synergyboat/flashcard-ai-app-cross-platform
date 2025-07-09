import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flashcard/domain/repository/ai/ai_generator_repository.dart';

class GenerateDeckWithAIUseCase {
  final AIGeneratorRepository _aiRepository;

  GenerateDeckWithAIUseCase(
    this._aiRepository
  );

  Future<Map<String, Flashcard>> call({
    String? deckId,
    int count = 5,
    String prompt = ""}
      ) async {
    final generatedFlashcards = await _aiRepository.generateDeck(
        deckId,
        count,
        prompt
    );
    return generatedFlashcards;
  }
}