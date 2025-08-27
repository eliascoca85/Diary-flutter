import '../models/diary_entry.dart';
import 'database_service.dart';
import 'database_service_isar.dart' as isar_db;

/// Enumeración para seleccionar el tipo de base de datos
enum DatabaseType { sharedPreferences, isar }

/// Clase para seleccionar y configurar el tipo de base de datos a usar
class DatabaseSelector {
  static DatabaseType _currentType = DatabaseType.sharedPreferences;

  /// Cambia el tipo de base de datos
  static void setDatabaseType(DatabaseType type) {
    _currentType = type;
  }

  /// Obtiene el tipo actual de base de datos
  static DatabaseType get currentType => _currentType;

  /// Factory method para obtener el servicio de base de datos actual
  static dynamic getDatabaseService() {
    switch (_currentType) {
      case DatabaseType.sharedPreferences:
        return DatabaseService.instance;
      case DatabaseType.isar:
        return isar_db.DatabaseService.instance;
    }
  }
}

/// Clase abstracta que define la interfaz común para ambos servicios de base de datos
abstract class DatabaseServiceInterface {
  Future<List<DiaryEntry>> getAllEntries();
  Future<void> createEntry(DiaryEntry entry);
  Future<void> updateEntry(DiaryEntry entry);
  Future<bool> deleteEntry(String id);
  Future<DiaryEntry?> getEntryById(String id);
  Future<void> toggleFavorite(String id);
  Future<List<String>> getAllTags();
  Future<List<DiaryEntry>> searchEntries(String query);
  Future<List<DiaryEntry>> getEntriesByTag(String tag);
  Future<List<DiaryEntry>> getFavoriteEntries();
  Future<Map<String, int>> getStatistics();
}
