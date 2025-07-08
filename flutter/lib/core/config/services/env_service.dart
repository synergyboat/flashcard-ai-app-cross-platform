import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> config([String? path]) async {
    await dotenv.load(fileName: path??".env");
  }

  static String? getVariable(String key) {
    return dotenv.env[key];
  }
}