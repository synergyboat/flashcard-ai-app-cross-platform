import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';

class OpenAISource {
  // This class is responsible for generating AI responses using OpenAI's API.
  // It will contain methods to interact with the OpenAI API, handle requests,
  // and process responses.
  Future<String?> sendRequestPrompt(List<OpenAIChatCompletionChoiceMessageModel> prompt) async {
    final start = DateTime.now();
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      responseFormat: {"type": "json_object"},
      seed: 6,
      messages: prompt,
      temperature: 0.3,
      maxTokens: 1000,
    );
    final end = DateTime.now();
    debugPrint("AI call took: ${end.difference(start).inMilliseconds}ms");
    return chatCompletion.choices.first.message.content?[0].text;
  }
}