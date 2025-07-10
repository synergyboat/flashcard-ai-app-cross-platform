import 'package:floor/floor.dart';

@Entity(tableName: 'deck')
class DeckDao {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String description;

  DeckDao({
    this.id,
    required this.name,
    required this.description,
  });
}