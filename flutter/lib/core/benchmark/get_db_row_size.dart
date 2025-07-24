import 'dart:convert';

int getRowSizeInBytes(Map<String, dynamic> row) {
  final jsonString = jsonEncode(row);
  final bytes = utf8.encode(jsonString);
  return bytes.length;
}

double getRowSizeInKB(Map<String, dynamic> row) {
  return getRowSizeInBytes(row) / 1024.0;
}