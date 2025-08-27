import 'database_service.dart';
import 'database_service_isar.dart' as isar_db;
import '../models/diary_entry.dart';
import '../models/diary_entry_isar.dart' as isar_model;
import 'package:shared_preferences/shared_preferences.dart';

/// Clase para migrar datos entre diferentes tipos de base de datos
class DatabaseMigrator {
  /// Migra datos de SharedPreferences a Isar
  static Future<bool> migrateToIsar() async {
    try {
      // Obtener datos de SharedPreferences
      final sharedPrefsDb = DatabaseService.instance;
      final entries = await sharedPrefsDb.getAllEntries();

      if (entries.isEmpty) {
        print('No hay datos para migrar');
        return true;
      }

      // Obtener la instancia de Isar
      final isarDb = isar_db.DatabaseService.instance;

      // Convertir y guardar cada entrada en Isar
      for (final entry in entries) {
        final isarEntry = isar_model.DiaryEntry(
          date: entry.date,
          title: entry.title,
          content: entry.content,
          tags: entry.tags,
          attachedImages: entry.attachedImages,
          attachedAudios: entry.attachedAudios,
          isFavorite: entry.isFavorite,
        );

        // Las fechas createdAt y updatedAt se establecen automáticamente en el constructor de Isar

        await isarDb.createEntry(isarEntry);
      }

      print(
          '✅ Migración completada: ${entries.length} entradas migradas a Isar');
      return true;
    } catch (e) {
      print('❌ Error durante la migración: $e');
      return false;
    }
  }

  /// Migra datos de Isar a SharedPreferences
  static Future<bool> migrateToSharedPreferences() async {
    try {
      // Obtener datos de Isar
      final isarDb = isar_db.DatabaseService.instance;
      final entries = await isarDb.getAllEntries();

      if (entries.isEmpty) {
        print('No hay datos para migrar desde Isar');
        return true;
      }

      // Obtener la instancia de SharedPreferences
      final sharedPrefsDb = DatabaseService.instance;

      // Convertir y guardar cada entrada en SharedPreferences
      for (final entry in entries) {
        final sharedPrefsEntry = DiaryEntry(
          id: entry.id, // Mantener como int, no convertir a string
          date: entry.date,
          title: entry.title,
          content: entry.content,
          tags: entry.tags,
          attachedImages: entry.attachedImages,
          attachedAudios: entry.attachedAudios,
          isFavorite: entry.isFavorite,
          // SharedPreferences DiaryEntry no tiene createdAt/updatedAt
        );

        await sharedPrefsDb.createEntry(sharedPrefsEntry);
      }

      print(
          '✅ Migración completada: ${entries.length} entradas migradas a SharedPreferences');
      return true;
    } catch (e) {
      print('❌ Error durante la migración: $e');
      return false;
    }
  }

  /// Compara los datos entre ambas bases de datos
  static Future<Map<String, dynamic>> compareData() async {
    try {
      final sharedPrefsDb = DatabaseService.instance;
      final isarDb = isar_db.DatabaseService.instance;

      final sharedPrefsEntries = await sharedPrefsDb.getAllEntries();
      final isarEntries = await isarDb.getAllEntries();

      return {
        'shared_preferences_count': sharedPrefsEntries.length,
        'isar_count': isarEntries.length,
        'shared_preferences_entries': sharedPrefsEntries
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'date': e.date.toIso8601String(),
                })
            .toList(),
        'isar_entries': isarEntries
            .map((e) => {
                  'id': e.id,
                  'title': e.title,
                  'date': e.date.toIso8601String(),
                })
            .toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Limpia una base de datos específica
  static Future<bool> clearDatabase(String dbType) async {
    try {
      if (dbType == 'shared_preferences') {
        // Para SharedPreferences, simplemente limpiamos la lista
        final prefs = await _getSharedPreferences();
        await prefs.remove('diary_entries');
        print('✅ SharedPreferences limpiado');
        return true;
      } else if (dbType == 'isar') {
        final db = isar_db.DatabaseService.instance;
        final entries = await db.getAllEntries();
        for (final entry in entries) {
          await db.deleteEntry(entry.id);
        }
        print('✅ Isar limpiado');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error limpiando $dbType: $e');
      return false;
    }
  }

  /// Método helper para obtener SharedPreferences
  static Future<SharedPreferences> _getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }
}
