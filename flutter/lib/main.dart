import 'package:dart_openai/dart_openai.dart';
import 'package:flashcard/core/config/di/config_di.dart';
import 'package:flashcard/core/config/services/env_service.dart';
import 'package:flashcard/core/config/services/openai_service.dart';
import 'package:flashcard/presentation/router/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.config();
  configDi();
  OpenAiService.config(EnvService.getVariable('API_KEY') ?? '');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flashcard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: appRouter,
    );
  }
}