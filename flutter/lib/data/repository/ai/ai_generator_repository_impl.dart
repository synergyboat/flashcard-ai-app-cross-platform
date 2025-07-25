import 'package:dart_openai/dart_openai.dart';
import 'package:flashcard/core/consts.dart';
import 'package:flashcard/data/sources/openai/openai_ai_source.dart';
import 'package:flashcard/domain/repository/ai/ai_prompt_builder_repository.dart';

import '../../../domain/repository/ai/ai_generator_repository.dart';
import 'ai_prompt_builder_repository_impl.dart';

class AIGeneratorRepositoryImpl implements AIGeneratorRepository {
  final OpenAISource openAiSource;

  AIGeneratorRepositoryImpl({
    required this.openAiSource,
  });

  @override
  Future<String?> generateDeck(
      String? deckId,
      int count,
      String prompt) async {
    AIPromptBuilderRepository<OpenAIChatCompletionChoiceMessageModel, List<OpenAIChatCompletionChoiceMessageModel>>
        promptBuilder = AIPromptBuilderRepositoryImpl();
    promptBuilder.setSystemPrompt(DEFAULT_AI_SYSTEM_PROMPT);
    promptBuilder.setUserPrompt("Topic: $prompt \n\n Number of flashcards to generate, strictly: $count");
   return await openAiSource.sendRequestPrompt(promptBuilder.buildPrompt());
  }
}