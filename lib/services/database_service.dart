import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static DatabaseService get instance => _instance;

  // Métodos temporales usando SharedPreferences
  Future<void> get database async {
    // Implementación temporal - no hace nada
  }

  Future<List<DiaryEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('diary_entries') ?? [];

    return entriesJson.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      return DiaryEntry(
        id: json['id'] ?? 0,
        date: DateTime.parse(json['date']),
        title: json['title'],
        content: json['content'],
        tags: List<String>.from(json['tags'] ?? []),
        attachedImages: List<String>.from(json['attachedImages'] ?? []),
        attachedAudios: List<String>.from(json['attachedAudios'] ?? []),
        isFavorite: json['isFavorite'] ?? false,
      );
    }).toList();
  }

  Future<void> createEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('diary_entries') ?? [];

    // Asignar un ID simple
    final newId = DateTime.now().millisecondsSinceEpoch;
    final newEntry = DiaryEntry(
      id: newId,
      date: entry.date,
      title: entry.title,
      content: entry.content,
      tags: entry.tags,
      attachedImages: entry.attachedImages,
      attachedAudios: entry.attachedAudios,
      isFavorite: entry.isFavorite,
    );

    final entryJson = jsonEncode({
      'id': newEntry.id,
      'date': newEntry.date.toIso8601String(),
      'title': newEntry.title,
      'content': newEntry.content,
      'tags': newEntry.tags,
      'attachedImages': newEntry.attachedImages,
      'attachedAudios': newEntry.attachedAudios,
      'isFavorite': newEntry.isFavorite,
    });

    entriesJson.add(entryJson);
    await prefs.setStringList('diary_entries', entriesJson);
  }

  Future<void> updateEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('diary_entries') ?? [];

    final updatedEntriesJson = entriesJson.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      if (json['id'] == entry.id) {
        return jsonEncode({
          'id': entry.id,
          'date': entry.date.toIso8601String(),
          'title': entry.title,
          'content': entry.content,
          'tags': entry.tags,
          'attachedImages': entry.attachedImages,
          'attachedAudios': entry.attachedAudios,
          'isFavorite': entry.isFavorite,
        });
      }
      return jsonStr;
    }).toList();

    await prefs.setStringList('diary_entries', updatedEntriesJson);
  }

  Future<DiaryEntry?> getEntryById(int id) async {
    final entries = await getAllEntries();
    try {
      return entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleFavorite(int entryId) async {
    final entry = await getEntryById(entryId);
    if (entry != null) {
      final updatedEntry = DiaryEntry(
        id: entry.id,
        date: entry.date,
        title: entry.title,
        content: entry.content,
        tags: entry.tags,
        attachedImages: entry.attachedImages,
        attachedAudios: entry.attachedAudios,
        isFavorite: !entry.isFavorite,
      );
      await updateEntry(updatedEntry);
    }
  }

  Future<Map<String, int>> getStatistics() async {
    final entries = await getAllEntries();
    final favorites = entries.where((entry) => entry.isFavorite).length;

    return {
      'total': entries.length,
      'favorites': favorites,
    };
  }

  Future<List<String>> getAllTags() async {
    final entries = await getAllEntries();
    final Set<String> allTags = {};

    for (final entry in entries) {
      allTags.addAll(entry.tags);
    }

    return allTags.toList()..sort();
  }
}
