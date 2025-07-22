import 'package:flashcard/core/config/di/config_di.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

Future<T> logExecDuration<T>(
    Future<T> Function() action, {
      String name = 'no_name',
      String tag = 'no_tag',
      bool log = true,
      Logger? logger,
    }) async {
  final stopwatch = Stopwatch()..start();
  final result = await action();
  stopwatch.stop();

  logger ??= getIt<Logger>();

  if (log && kDebugMode) {
    logger.d('$tag | Execution time for $name: ${stopwatch.elapsedMilliseconds} ms');
  }
  return result;
}