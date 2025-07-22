import 'package:logger/logger.dart';

import '../config/di/config_di.dart';
import 'get_db_row_size.dart';

void logDbRowSize(Map<String, dynamic> row, {
  String name = '',
  String tag = 'db_row_size',
  bool log = true,
  Logger? logger,}) {
  final sizeInBytes = getRowSizeInBytes(row);
  final sizeInKB = getRowSizeInKB(row);

  logger ??= getIt<Logger>();

  if (log) {
    logger.d('$tag | Row size for $name: $sizeInBytes bytes (${sizeInKB.toStringAsFixed(2)} KB)');
  }
}

void logTotalDbRowSize(List<Map<String, dynamic>> rows, {
  String name = '',
  String tag = 'db_row_size',
  bool log = true,
  Logger? logger,}) {
  final totalSizeInBytes = rows.fold<int>(0, (sum, row) => sum + getRowSizeInBytes(row));
  final totalSizeInKB = totalSizeInBytes / 1024;

  logger ??= getIt<Logger>();

  if (log) {
    logger.d('$tag | Total row size for $name: $totalSizeInBytes bytes (${totalSizeInKB.toStringAsFixed(2)} KB)');
  }
}