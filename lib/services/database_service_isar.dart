import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import '../models/diary_entry_isar.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Isar> get database async {
    if (_isar != null) return _isar!;
    _isar = await _initDB();
    return _isar!;
  }

  Future<Isar> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();

    return await Isar.open(
      [DiaryEntrySchema],
      directory: dir.path,
      name: 'diary_database',
    );
  }

  // CRUD Operations

  // Crear nueva entrada
  Future<int> createEntry(DiaryEntry entry) async {
    final isar = await database;
    return await isar.writeTxn(() async {
      return await isar.diaryEntrys.put(entry);
    });
  }

  // Obtener todas las entradas
  Future<List<DiaryEntry>> getAllEntries() async {
    final isar = await database;
    return await isar.diaryEntrys.where().sortByDateDesc().findAll();
  }

  // Obtener entradas por fecha
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final isar = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await isar.diaryEntrys
        .where()
        .dateBetween(startOfDay, endOfDay)
        .findAll();
  }

  // Obtener entradas favoritas
  Future<List<DiaryEntry>> getFavoriteEntries() async {
    final isar = await database;
    return await isar.diaryEntrys
        .where()
        .isFavoriteEqualTo(true)
        .sortByDateDesc()
        .findAll();
  }

  // Buscar entradas por texto
  Future<List<DiaryEntry>> searchEntries(String query) async {
    final isar = await database;
    return await isar.diaryEntrys
        .filter()
        .titleContains(query, caseSensitive: false)
        .or()
        .contentContains(query, caseSensitive: false)
        .sortByDateDesc()
        .findAll();
  }

  // Obtener entradas por etiqueta
  Future<List<DiaryEntry>> getEntriesByTag(String tag) async {
    final isar = await database;
    return await isar.diaryEntrys
        .filter()
        .tagsElementContains(tag)
        .sortByDateDesc()
        .findAll();
  }

  // Actualizar entrada
  Future<void> updateEntry(DiaryEntry entry) async {
    final isar = await database;
    entry.updateTimestamp();
    await isar.writeTxn(() async {
      await isar.diaryEntrys.put(entry);
    });
  }

  // Eliminar entrada
  Future<bool> deleteEntry(int id) async {
    final isar = await database;
    return await isar.writeTxn(() async {
      return await isar.diaryEntrys.delete(id);
    });
  }

  // Obtener entrada por ID
  Future<DiaryEntry?> getEntryById(int id) async {
    final isar = await database;
    return await isar.diaryEntrys.get(id);
  }

  // Marcar/desmarcar como favorito
  Future<void> toggleFavorite(int id) async {
    final isar = await database;
    final entry = await isar.diaryEntrys.get(id);
    if (entry != null) {
      entry.isFavorite = !entry.isFavorite;
      entry.updateTimestamp();
      await isar.writeTxn(() async {
        await isar.diaryEntrys.put(entry);
      });
    }
  }

  // Obtener estadísticas
  Future<Map<String, int>> getStatistics() async {
    final isar = await database;
    final totalEntries = await isar.diaryEntrys.count();
    final favoriteEntries =
        await isar.diaryEntrys.where().isFavoriteEqualTo(true).count();

    // Calcular días seguidos (últimos días con entradas)
    final now = DateTime.now();
    int consecutiveDays = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final entriesForDay = await getEntriesByDate(date);
      if (entriesForDay.isNotEmpty) {
        consecutiveDays++;
      } else if (i > 0) {
        break; // Si no hay entrada en un día, rompe la racha
      }
    }

    return {
      'total': totalEntries,
      'favorites': favoriteEntries,
      'consecutive_days': consecutiveDays,
    };
  }

  // Obtener todas las etiquetas únicas
  Future<List<String>> getAllTags() async {
    final isar = await database;
    final entries = await isar.diaryEntrys.where().findAll();
    final allTags = <String>{};

    for (final entry in entries) {
      allTags.addAll(entry.tags);
    }

    return allTags.toList()..sort();
  }

  // Cerrar la base de datos
  Future<void> closeDatabase() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
    }
  }
}
