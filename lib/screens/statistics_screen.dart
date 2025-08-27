import 'package:flutter/material.dart';
import '../services/database_service_isar.dart';
import '../models/diary_entry_isar.dart';
import '../main.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  Map<String, int> _stats = {};
  List<DiaryEntry> _entries = [];
  Map<String, int> _monthlyStats = {};
  List<String> _topTags = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() => _isLoading = true);

      final stats = await DatabaseService.instance.getStatistics();
      final entries = await DatabaseService.instance.getAllEntries();
      final allTags = await DatabaseService.instance.getAllTags();

      // Calcular estadísticas mensuales desde la primera entrada
      final monthlyStats = <String, int>{};
      final now = DateTime.now();

      if (entries.isNotEmpty) {
        // Encontrar la fecha de la primera entrada (instalación de la app)
        final oldestEntry =
            entries.reduce((a, b) => a.date.isBefore(b.date) ? a : b);
        final firstMonth =
            DateTime(oldestEntry.date.year, oldestEntry.date.month, 1);
        final currentMonth = DateTime(now.year, now.month, 1);

        // Calcular todos los meses desde la primera entrada hasta ahora
        DateTime month = firstMonth;
        while (month.isBefore(currentMonth) ||
            month.isAtSameMomentAs(currentMonth)) {
          final monthKey = '${month.month}/${month.year}';
          final count = entries
              .where((entry) =>
                  entry.date.year == month.year &&
                  entry.date.month == month.month)
              .length;
          monthlyStats[monthKey] = count;

          // Avanzar al siguiente mes
          if (month.month == 12) {
            month = DateTime(month.year + 1, 1, 1);
          } else {
            month = DateTime(month.year, month.month + 1, 1);
          }
        }
      }

      // Calcular palabras promedio
      int totalWords = 0;
      for (final entry in entries) {
        totalWords += entry.content.split(' ').length;
      }
      final avgWords =
          entries.isNotEmpty ? (totalWords / entries.length).round() : 0;

      // Calcular racha más larga
      int longestStreak = 0;
      int currentStreak = 0;
      final sortedEntries = entries.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      for (int i = 0; i < sortedEntries.length; i++) {
        if (i == 0) {
          currentStreak = 1;
        } else {
          final currentDate = sortedEntries[i].date;
          final previousDate = sortedEntries[i - 1].date;
          final daysDifference = previousDate.difference(currentDate).inDays;

          if (daysDifference == 1) {
            currentStreak++;
          } else {
            longestStreak =
                longestStreak > currentStreak ? longestStreak : currentStreak;
            currentStreak = 1;
          }
        }
      }
      longestStreak =
          longestStreak > currentStreak ? longestStreak : currentStreak;

      if (mounted) {
        setState(() {
          _stats = {
            ...stats,
            'avg_words': avgWords,
            'longest_streak': longestStreak,
            'total_words': totalWords,
          };
          _entries = entries;
          _monthlyStats = monthlyStats;
          _topTags = allTags.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = {};
          _entries = [];
          _monthlyStats = {};
          _topTags = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        actions: [
          IconButton(
              icon: Icon(
                DiaryApp.appKey.currentState?.isDarkMode == true
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                size: 28,
              ),
              onPressed: () {
                DiaryApp.appKey.currentState?.toggleTheme();
              }),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen General
                  _buildStatsCard(
                    'Resumen General',
                    [
                      _StatItem('Total de Entradas', '${_stats['total'] ?? 0}',
                          Icons.book),
                      _StatItem('Favoritas', '${_stats['favorites'] ?? 0}',
                          Icons.favorite),
                      _StatItem(
                          'Racha Actual',
                          '${_stats['consecutive_days'] ?? 0} días',
                          Icons.local_fire_department),
                      _StatItem(
                          'Racha Más Larga',
                          '${_stats['longest_streak'] ?? 0} días',
                          Icons.trending_up),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estadísticas de Escritura
                  _buildStatsCard(
                    'Estadísticas de Escritura',
                    [
                      _StatItem('Total de Palabras',
                          '${_stats['total_words'] ?? 0}', Icons.text_fields),
                      _StatItem(
                          'Promedio por Entrada',
                          '${_stats['avg_words'] ?? 0} palabras',
                          Icons.analytics),
                      _StatItem('Etiquetas Únicas', '${_topTags.length}',
                          Icons.label),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Actividad Mensual
                  if (_monthlyStats.isNotEmpty) ...[
                    _buildMonthlyActivityCard(),
                    const SizedBox(height: 16),
                  ],

                  // Etiquetas Más Usadas
                  if (_topTags.isNotEmpty) ...[
                    _buildTagsCard(),
                    const SizedBox(height: 16),
                  ],

                  // Entradas Recientes
                  if (_entries.isNotEmpty) ...[
                    _buildRecentEntriesCard(),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard(String title, List<_StatItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20, color: const Color(0xFF007C91)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007C91),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyActivityCard() {
    // Convertir a lista y ordenar cronológicamente (más antiguos primero)
    final sortedMonths = _monthlyStats.entries.toList()
      ..sort((a, b) {
        final aParts = a.key.split('/');
        final bParts = b.key.split('/');
        final aDate = DateTime(int.parse(aParts[1]), int.parse(aParts[0]));
        final bDate = DateTime(int.parse(bParts[1]), int.parse(bParts[0]));
        return aDate.compareTo(bDate);
      });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actividad Mensual',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedMonths.map((entry) {
              final monthParts = entry.key.split('/');
              final monthNum = int.parse(monthParts[0]);
              final year = int.parse(monthParts[1]);
              final monthName = _getMonthName(monthNum);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month,
                        size: 20, color: const Color(0xFF007C91)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$monthName $year',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${entry.value} ${entry.value == 1 ? 'entrada' : 'entradas'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007C91),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (sortedMonths.length > 1) ...[
              const Divider(),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${sortedMonths.length} ${sortedMonths.length == 1 ? 'mes' : 'meses'} de actividad',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month];
  }

  Widget _buildTagsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Etiquetas Más Usadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _topTags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007C91).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF007C91).withOpacity(0.3)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF007C91),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntriesCard() {
    final recentEntries = _entries.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entradas Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recentEntries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        entry.isFavorite ? Icons.favorite : Icons.book_outlined,
                        size: 20,
                        color: entry.isFavorite
                            ? Colors.red
                            : const Color(0xFF007C91),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(entry.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${entry.content.split(' ').length} palabras',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF007C91),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  _StatItem(this.label, this.value, this.icon);
}
