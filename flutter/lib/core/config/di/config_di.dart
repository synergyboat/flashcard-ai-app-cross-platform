import 'package:get_it/get_it.dart';

part 'config_presentation_di.dart';
part 'config_data_di.dart';
part 'config_domain_di.dart';

final GetIt getIt = GetIt.instance;

void configDi() {
  configDomainDi();
  configPresentationDi();
  configDataDi();

}