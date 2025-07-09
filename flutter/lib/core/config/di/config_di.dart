import 'package:dart_openai/dart_openai.dart';
import 'package:flashcard/domain/use_case/ai/generate_deck_with_ai_use_case.dart';
import 'package:get_it/get_it.dart';

import '../../../data/repository/ai/ai_generator_repository_impl.dart';
import '../../../data/repository/ai/ai_prompt_builder_repository_impl.dart';
import '../../../data/sources/openai/openai_ai_source.dart';
import '../../../domain/repository/ai/ai_generator_repository.dart';
import '../../../domain/repository/ai/ai_prompt_builder_repository.dart';

part 'config_presentation_di.dart';
part 'config_data_di.dart';
part 'config_domain_di.dart';

final GetIt getIt = GetIt.instance;

void configDi() {
  configDataDi();
  configDomainDi();
  configPresentationDi();
}