import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';
import '../models/diary_entry_isar.dart';
import '../services/database_service_isar.dart';
import '../services/media_service.dart';
import 'create_note_screen.dart';

class NoteViewScreen extends StatefulWidget {
  final DiaryEntry entry;

  const NoteViewScreen({
    super.key,
    required this.entry,
  });

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late DiaryEntry entry;
  bool isPlayingAudio = false;
  String? currentPlayingAudio;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = DiaryApp.appKey.currentState?.isDarkMode ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          entry.formattedDate,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: entry.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editNote(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteNote();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              entry.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Contenido
            Text(
              entry.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Etiquetas
            if (entry.tags.isNotEmpty) ...[
              Text(
                'Etiquetas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007C91).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF007C91)),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF007C91),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Imágenes adjuntas
            if (entry.attachedImages.isNotEmpty) ...[
              Text(
                'Imágenes adjuntas (${entry.attachedImages.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: entry.attachedImages.length,
                itemBuilder: (context, index) {
                  final imagePath = entry.attachedImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerScreen(
                            imagePaths: entry.attachedImages,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: File(imagePath).existsSync()
                            ? Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Audios adjuntos
            if (entry.attachedAudios.isNotEmpty) ...[
              Text(
                'Audios adjuntos (${entry.attachedAudios.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ...entry.attachedAudios.map((audioPath) {
                return _buildAudioItem(audioPath, isDarkMode);
              }).toList(),
            ],

            // Información adicional
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Creado: ${entry.formattedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  if (entry.attachedImages.isNotEmpty)
                    Text(
                      'Imágenes: ${entry.attachedImages.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  if (entry.attachedAudios.isNotEmpty)
                    Text(
                      'Audios: ${entry.attachedAudios.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioItem(String audioPath, bool isDarkMode) {
    String audioName = audioPath.split('/').last;
    bool isCurrentlyPlaying =
        currentPlayingAudio == audioPath && isPlayingAudio;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentlyPlaying
            ? (isDarkMode ? Colors.blue[900] : Colors.blue[50])
            : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentlyPlaying
              ? (isDarkMode ? Colors.blue[700]! : Colors.blue[300]!)
              : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.audiotrack,
            color: isCurrentlyPlaying
                ? (isDarkMode ? Colors.blue[400] : Colors.blue[600])
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audioName,
                  style: TextStyle(
                    color: isCurrentlyPlaying
                        ? (isDarkMode ? Colors.blue[200] : Colors.blue[800])
                        : (isDarkMode ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<Duration?>(
                  future: MediaService().getAudioDuration(audioPath),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Text(
                        MediaService.formatDuration(snapshot.data!),
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      );
                    }
                    return Text(
                      'Cargando duración...',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isCurrentlyPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              size: 40,
              color: isCurrentlyPlaying
                  ? (isDarkMode ? Colors.blue[400] : Colors.blue[600])
                  : (isDarkMode ? Colors.white70 : Colors.grey[600]),
            ),
            onPressed: () => _toggleAudioPlayback(audioPath),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudioPlayback(String audioPath) async {
    try {
      if (isPlayingAudio && currentPlayingAudio == audioPath) {
        // Pausar audio actual
        await MediaService().pauseAudio();
        setState(() {
          isPlayingAudio = false;
          currentPlayingAudio = null;
        });
      } else {
        // Detener cualquier audio que esté reproduciéndose
        if (isPlayingAudio) {
          await MediaService().stopAudio();
        }

        // Reproducir nuevo audio
        final bool playbackStarted = await MediaService().playAudio(audioPath);
        if (playbackStarted) {
          setState(() {
            isPlayingAudio = true;
            currentPlayingAudio = audioPath;
          });

          // Verificar cuando termine la reproducción
          _checkAudioCompletion();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en reproducción: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkAudioCompletion() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && isPlayingAudio) {
        if (!MediaService().isPlaying) {
          setState(() {
            isPlayingAudio = false;
            currentPlayingAudio = null;
          });
        } else {
          _checkAudioCompletion();
        }
      }
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      entry.isFavorite = !entry.isFavorite;
      await DatabaseService.instance.updateEntry(entry);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            entry.isFavorite
                ? 'Nota marcada como favorita'
                : 'Nota desmarcada como favorita',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favorito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editNote() async {
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

    if (result == true) {
      // Recargar la entrada actualizada
      final updatedEntry =
          await DatabaseService.instance.getEntryById(entry.id);
      if (updatedEntry != null) {
        setState(() {
          entry = updatedEntry;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que quieres eliminar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteEntry(entry.id);

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nota eliminada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar nota: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Detener audio si está reproduciéndose al salir de la pantalla
    if (isPlayingAudio) {
      MediaService().stopAudio();
    }
    super.dispose();
  }
}

class ImageViewerScreen extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${initialIndex + 1} de ${imagePaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: File(imagePaths[index]).existsSync()
                  ? Image.file(
                      File(imagePaths[index]),
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 100,
                    ),
            ),
          );
        },
      ),
    );
  }
}
