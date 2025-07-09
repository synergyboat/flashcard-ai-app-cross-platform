part of 'config_di.dart';
void configPresentationDi() {
  // Register your presentation layer dependencies here
  // Example:
  // getIt.registerFactory<SomeViewModel>(() => SomeViewModel(getIt<SomeService>()));

  // If you have a specific presentation service, register it here
  // getIt.registerSingleton<PresentationService>(PresentationService());

  // You can also register your screens or widgets if needed
  // getIt.registerFactory<SplashScreen>(() => SplashScreen());

  getIt.registerSingleton<Logger>(Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  ));
}