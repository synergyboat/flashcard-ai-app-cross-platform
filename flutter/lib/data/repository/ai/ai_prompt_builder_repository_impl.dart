import 'package:dart_openai/dart_openai.dart';

import '../../../domain/repository/ai/ai_prompt_builder_repository.dart';

class AIPromptBuilderRepositoryImpl implements AIPromptBuilderRepository
<OpenAIChatCompletionChoiceMessageModel, List<OpenAIChatCompletionChoiceMessageModel>> {
  @override
  late OpenAIChatCompletionChoiceMessageModel systemPrompt;

  @override
  late OpenAIChatCompletionChoiceMessageModel userPrompt;

  @override
  void setSystemPrompt(String prompt) {
    OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.assistant,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt
        ),
      ],
    );
  }

  @override
  void setUserPrompt(String prompt) {
    OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt
        ),
      ],
    );
  }

  @override
  buildPrompt() {
    return [systemPrompt, userPrompt];
  }

}