import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'create_note_screen.dart';
import 'note_view_screen.dart';
import '../main.dart';
import '../services/database_service_isar.dart';
import '../models/diary_entry_isar.dart';

class NotesScreen extends StatefulWidget {
  final String? initialFilter;

  const NotesScreen({super.key, this.initialFilter});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isLoading = true;
  List<DiaryEntry> _entries = [];
  List<DiaryEntry> _filteredEntries = [];
  String _selectedFilter = 'Todas';
  Map<String, int> _stats = {'total': 0, 'favorites': 0, 'thisMonth': 0};
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Variables para ordenamiento
  String _sortBy = 'date'; // 'date' o 'title'
  bool _sortAscending =
      false; // false = descendente por defecto (más reciente primero)

  @override
  void initState() {
    super.initState();
    // Aplicar filtro inicial si se proporcionó
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _loadEntries();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyCurrentFilter();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _applyCurrentFilter();
      }
    });
  }

  Future<void> _loadEntries() async {
    try {
      setState(() => _isLoading = true);

      final entries = await DatabaseService.instance.getAllEntries();
      final stats = await DatabaseService.instance.getStatistics();

      // Calcular entradas de este mes
      final now = DateTime.now();
      final thisMonthEntries = entries
          .where((entry) =>
              entry.date.year == now.year && entry.date.month == now.month)
          .length;

      if (mounted) {
        setState(() {
          _entries = entries;
          _stats = {
            'total': stats['total'] ?? 0,
            'favorites': stats['favorites'] ?? 0,
            'thisMonth': thisMonthEntries,
          };
          _isLoading = false;
        });
        _applyCurrentFilter(); // Aplicar filtros después de cargar
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _entries = [];
          _filteredEntries = [];
          _stats = {'total': 0, 'favorites': 0, 'thisMonth': 0};
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyCurrentFilter();
    });

    // Debug: Mostrar cuántas entradas se filtraron
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtro "$filter": ${_filteredEntries.length} entradas'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _applyCurrentFilter() {
    List<DiaryEntry> filtered = [];

    // Aplicar filtro de categoría
    switch (_selectedFilter) {
      case 'Favoritas':
        filtered = _entries.where((entry) => entry.isFavorite).toList();
        break;
      case 'Recientes':
        final recentDate = DateTime.now().subtract(const Duration(days: 10));
        filtered =
            _entries.where((entry) => entry.date.isAfter(recentDate)).toList();
        break;
      default: // 'Todas'
        filtered = _entries;
    }

    // Aplicar filtro de búsqueda si existe
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((entry) =>
              entry.title.toLowerCase().contains(_searchQuery) ||
              entry.content.toLowerCase().contains(_searchQuery) ||
              entry.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)))
          .toList();
    }

    // Aplicar ordenamiento
    _applySorting(filtered);

    _filteredEntries = filtered;
  }

  void _applySorting(List<DiaryEntry> entries) {
    entries.sort((a, b) {
      int comparison;
      if (_sortBy == 'title') {
        comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      } else {
        // 'date'
        comparison = a.date.compareTo(b.date);
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ordenar por'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Fecha'),
                    value: 'date',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Título (A-Z)'),
                    value: 'title',
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortBy = value!;
                      });
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: Text(
                        _sortBy == 'date' ? 'Más antiguos primero' : 'Z-A'),
                    value: _sortAscending,
                    onChanged: (value) {
                      setDialogState(() {
                        _sortAscending = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _applyCurrentFilter();
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Ordenado por ${_sortBy == 'date' ? 'fecha' : 'título'} '
                            '(${_sortAscending ? 'ascendente' : 'descendente'})'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite(int entryId) async {
    try {
      await DatabaseService.instance.toggleFavorite(entryId);
      _loadEntries(); // Recargar para actualizar la UI y mantener filtros
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar favorito: $e')),
        );
      }
    }
  }

  Future<void> _editNote(DiaryEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNoteScreen(
          isEditing: true,
          noteTitle: entry.title,
          noteContent: entry.content,
          noteDate: entry.date,
          noteTags: entry.tags,
          noteImages: entry.attachedImages,
          noteAudios: entry.attachedAudios,
          entryId: entry.id,
        ),
      ),
    );

    // Si se editó la nota, recargar la lista
    if (result == true) {
      _loadEntries();
    }
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

  Color _getNoteColor(int index) {
    final isDark = DiaryApp.appKey.currentState?.isDarkMode ?? false;

    if (isDark) {
      // Colores oscuros semi-transparentes para modo oscuro
      final darkColors = [
        const Color(0xFF424242).withOpacity(0.5), // Gris oscuro
        const Color(0xFF37474F).withOpacity(0.5), // Azul gris oscuro
        const Color(0xFF263238).withOpacity(0.5), // Azul gris muy oscuro
        const Color(0xFF3E2723).withOpacity(0.5), // Marrón oscuro
        const Color(0xFF1A237E).withOpacity(0.5), // Azul oscuro
        const Color(0xFF004D40).withOpacity(0.5), // Verde azulado oscuro
      ];
      return darkColors[index % darkColors.length];
    } else {
      // Colores claros para modo claro
      final lightColors = [
        const Color(0xFFFFF3CD), // Amarillo claro
        const Color(0xFFE8F5E8), // Verde claro
        const Color(0xFFE3F2FD), // Azul claro
        const Color(0xFFFCE4EC), // Rosa claro
        const Color(0xFFF3E5F5), // Púrpura claro
        const Color(0xFFE0F2F1), // Verde azulado claro
      ];
      return lightColors[index % lightColors.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Forzar dependencia del tema para que se reconstruya cuando cambie
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.favorite, color: Color(0xFF007C91)),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar en notas...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Mis Notas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
        actions: [
          IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, size: 28),
              onPressed: _toggleSearch),
          if (!_isSearching)
            IconButton(
                icon: const Icon(Icons.sort, size: 28),
                onPressed: _showSortDialog),
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
          : Column(
              children: [
                // Header Stats
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFc6e6f7).withOpacity(0.8),
                        const Color(0xFFeaf6fa).withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(
                        icon: Icons.note_outlined,
                        count: '${_stats['total']}',
                        label: 'Notas',
                        color: Color(0xFF007C91),
                      ),
                      _StatCard(
                        icon: Icons.favorite_border,
                        count: '${_stats['favorites']}',
                        label: 'Favoritas',
                        color: Color(0xFF4F8CFF),
                      ),
                      _StatCard(
                        icon: Icons.calendar_today,
                        count: '${_stats['thisMonth']}',
                        label: 'Este mes',
                        color: Color(0xFF007C91),
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip('Todas', _selectedFilter == 'Todas',
                          () => _applyFilter('Todas')),
                      const SizedBox(width: 8),
                      _FilterChip('Favoritas', _selectedFilter == 'Favoritas',
                          () => _applyFilter('Favoritas')),
                      const SizedBox(width: 8),
                      _FilterChip('Recientes', _selectedFilter == 'Recientes',
                          () => _applyFilter('Recientes')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Notes List
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.note_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'Todas'
                                    ? 'No hay entradas aún'
                                    : 'No hay entradas en "$_selectedFilter"',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedFilter == 'Todas'
                                    ? 'Crea tu primera entrada del diario'
                                    : 'Prueba con otro filtro',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return GestureDetector(
                              onTap: () async {
                                // Navegar a la pantalla de vista previa
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteViewScreen(
                                      entry: entry,
                                    ),
                                  ),
                                );

                                // Si se editó o eliminó la nota, recargar la lista
                                if (result == true) {
                                  _loadEntries();
                                }
                              },
                              child: _NoteCard(
                                title: entry.title,
                                content: entry.contentPreview,
                                date: _formatDate(entry.date),
                                isFavorite: entry.isFavorite,
                                color: _getNoteColor(index),
                                tags: entry.tags,
                                onFavoriteToggle: () =>
                                    _toggleFavorite(entry.id),
                                onEdit: () => _editNote(entry),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
          // Si se creó una nueva entrada, recargar la lista
          if (result == true) {
            _loadEntries();
          }
        },
        backgroundColor: const Color(0xFF4F8CFF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isDark = DiaryApp.appKey.currentState?.isDarkMode ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007C91)
              : Colors.transparent, // Transparente cuando no está seleccionado
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF007C91)
                : (isDark ? Colors.white.withOpacity(0.5) : Colors.grey[400]!),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white.withOpacity(0.8) : Colors.grey[600]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final bool isFavorite;
  final Color color;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onEdit;
  final List<String> tags;

  const _NoteCard({
    required this.title,
    required this.content,
    required this.date,
    required this.isFavorite,
    required this.color,
    required this.tags,
    this.onFavoriteToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = DiaryApp.appKey.currentState?.isDarkMode ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onFavoriteToggle,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red[400]
                      : (isDark ? Colors.grey[300] : Colors.grey[400]),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: tags
                            .take(3)
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.black12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      if (tags.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '+${tags.length - 3} más',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit,
                        size: 16,
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.more_vert,
                      size: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey[600]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
