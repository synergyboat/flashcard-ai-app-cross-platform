import 'package:logger/logger.dart';

import 'config_di.dart';

Future<void> configCoreDi() async {
  // Register your core layer dependencies here
  // Example:
  // getIt.registerSingleton<Logger>(Logger());

  // If you have a specific service, register it here
  // getIt.registerFactory<SomeService>(() => SomeService(getIt<Logger>()));

  // You can also register your utilities or helpers if needed
  // getIt.registerSingleton<UtilityService>(UtilityService());

  getIt.registerSingleton<Logger>(Logger(
    printer: PrettyPrinter(
      excludeBox: { Level.all : true },
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 0,
      //colors: true,
      //printEmojis: true,
      //dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  ));
}