import 'package:flashcard/core/config/di/config_di.dart';
import 'package:flashcard/core/config/services/env_service.dart';
import 'package:flashcard/core/config/services/openai_service.dart';
import 'package:flashcard/data/sources/database/database_benchmark_runner.dart';
import 'package:flashcard/presentation/router/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'data/sources/database/database_initializer.dart';
import 'data/sources/database/local/local_database_service.dart';

void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.config();
  await configDi();
  await DatabaseInitializer.initialize();
  // Uncomment the line below to add sample data to the database for benchmarking purposes
  await DatabaseBenchmarkRunner.run(database: getIt<LocalAppDatabase>(), logger: getIt<Logger>(), iterations: 5);
  OpenAiService.config(EnvService.getVariable('API_KEY') ?? '');
  PerformanceOverlay.allEnabled();
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