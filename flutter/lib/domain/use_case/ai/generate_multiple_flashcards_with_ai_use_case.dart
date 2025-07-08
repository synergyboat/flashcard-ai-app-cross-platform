import 'package:flashcard/domain/entities/flashcard.dart';
import 'package:flashcard/domain/repository/ai_repository.dart';
import 'package:flashcard/domain/repository/flashcard_repository.dart';

abstract class GenerateMultipleFlashcardsWithAIUseCase {
  final AIRepository _aiRepository;

  GenerateMultipleFlashcardsWithAIUseCase(
    this._aiRepository
  );

  Future<Map<String, Flashcard>> call(String deckId, String prompt) async {
    final generatedFlashcards = await _aiRepository.generateMultipleFlashcards(deckId, prompt);
    return generatedFlashcards;
  }
}