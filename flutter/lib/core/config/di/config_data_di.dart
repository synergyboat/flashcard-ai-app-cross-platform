part of 'config_di.dart';

Future<void> configDataDi() async {
  // Register your data layer dependencies here
  // Example:
  // getIt.registerSingleton<DataService>(DataService());

  // If you have a specific repository, register it here
  // getIt.registerFactory<SomeRepository>(() => SomeRepository(getIt<DataService>()));

  // You can also register your data sources or APIs if needed
  // getIt.registerSingleton<ApiService>(ApiService());

  getIt.registerSingleton<OpenAISource>(OpenAISource());
  getIt.registerSingleton<LocalAppDatabase>(await LocalDatabaseService.database);
  getIt.registerSingleton<AIGeneratorRepository>(AIGeneratorRepositoryImpl(openAiSource: getIt<OpenAISource>()));
  getIt.registerSingleton<DeckRepository>(DeckRepositoryImpl(getIt<LocalAppDatabase>(), getIt<Logger>()));
  getIt.registerSingleton<FlashcardRepository>(FlashcardRepositoryImpl(getIt<LocalAppDatabase>(), getIt<Logger>()));
}