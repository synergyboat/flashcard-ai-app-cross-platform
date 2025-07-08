import 'package:dart_openai/dart_openai.dart';

class OpenAiService {
  static void config(String key){
    OpenAI.apiKey = key;
    OpenAI.requestsTimeOut = Duration(seconds: 60);
  }

}