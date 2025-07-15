import 'package:dart_openai/dart_openai.dart';
import 'package:flashcard/data/repository/deck/deck_repository_impl.dart';
import 'package:flashcard/data/sources/database/local/local_database_service.dart';
import 'package:flashcard/domain/repository/deck_repository.dart';
import 'package:flashcard/domain/use_case/ai/generate_deck_with_ai_use_case.dart';
import 'package:flashcard/domain/use_case/deck/create_new_deck_use_case.dart';
import 'package:flashcard/domain/use_case/deck/get_all_decks_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../../data/repository/ai/ai_generator_repository_impl.dart';
import '../../../data/repository/ai/ai_prompt_builder_repository_impl.dart';
import '../../../data/sources/openai/openai_ai_source.dart';
import '../../../domain/repository/ai/ai_generator_repository.dart';
import '../../../domain/repository/ai/ai_prompt_builder_repository.dart';

part 'config_presentation_di.dart';
part 'config_data_di.dart';
part 'config_domain_di.dart';

final GetIt getIt = GetIt.instance;

Future<void> configDi() async {
  await configDataDi();
  configDomainDi();
  configPresentationDi();
}