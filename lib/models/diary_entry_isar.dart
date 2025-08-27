import 'package:isar/isar.dart';

part 'diary_entry_isar.g.dart';

@collection
class DiaryEntry {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  late String title;

  late String content;

  late List<String> tags;

  late List<String> attachedImages;

  late List<String> attachedAudios;

  @Index()
  late bool isFavorite;

  late DateTime createdAt;

  late DateTime updatedAt;

  // Constructor
  DiaryEntry({
    this.id = Isar.autoIncrement,
    required this.date,
    required this.title,
    required this.content,
    this.tags = const [],
    this.attachedImages = const [],
    this.attachedAudios = const [],
    this.isFavorite = false,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  // Método para actualizar el timestamp
  void updateTimestamp() {
    updatedAt = DateTime.now();
  }

  // Método para formatear la fecha
  String get formattedDate {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // Método para obtener un preview del contenido
  String get contentPreview {
    if (content.length <= 100) return content;
    return "${content.substring(0, 100)}...";
  }
}
