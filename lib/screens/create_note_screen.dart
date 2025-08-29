import 'package:flutter/material.dart';
import 'dart:io';
import '../main.dart';
import '../services/database_service_isar.dart';
import '../services/media_service.dart';
import '../models/diary_entry_isar.dart';

class CreateNoteScreen extends StatefulWidget {
  final bool isEditing;
  final String? noteTitle;
  final String? noteContent;
  final DateTime? noteDate;
  final List<String>? noteTags;
  final List<String>? noteImages;
  final List<String>? noteAudios;
  final int? entryId;

  const CreateNoteScreen({
    super.key,
    this.isEditing = false,
    this.noteTitle,
    this.noteContent,
    this.noteDate,
    this.noteTags,
    this.noteImages,
    this.noteAudios,
    this.entryId,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  List<String> selectedTags = [];
  List<String> attachedImages = [];
  List<String> attachedAudios = [];

  // Audio recording state
  bool isRecording = false;
  bool isPlayingAudio = false;
  int currentPlayingIndex = -1;

  final List<String> predefinedTags = [
    'Personal',
    'Trabajo',
    'Viaje',
    'Familia',
    'Estudio',
    'Salud',
    'Reflexiones',
    'Ideas',
    'Metas',
    'Recuerdos'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _titleController.text = widget.noteTitle ?? '';
      _contentController.text = widget.noteContent ?? '';
      selectedDate = widget.noteDate ?? DateTime.now();
      selectedTags = List.from(widget.noteTags ?? []);
      attachedImages = List.from(widget.noteImages ?? []);
      attachedAudios = List.from(widget.noteAudios ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Editar entrada' : 'Nueva entrada',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              DiaryApp.appKey.currentState?.isDarkMode == true
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () {
              DiaryApp.appKey.currentState?.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            _buildDateSection(),
            const SizedBox(height: 24),

            // Title Input
            _buildTitleSection(),
            const SizedBox(height: 24),

            // Content Input
            _buildContentSection(),
            const SizedBox(height: 24),

            // Tags Section
            _buildTagsSection(),
            const SizedBox(height: 24),

            // Attachments Section
            _buildAttachmentsSection(),
            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Theme.of(context).iconTheme.color, size: 20),
                const SizedBox(width: 12),
                Text(
                  _formatDate(selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Título',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Título de tu entrada',
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF007C91)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contenido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Escribe aquí tus pensamientos...',
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF007C91)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 12),

        // Selected Tags
        if (selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                selectedTags.map((tag) => _buildSelectedTag(tag)).toList(),
          ),

        const SizedBox(height: 12),

        // Predefined Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: predefinedTags
              .where((tag) => !selectedTags.contains(tag))
              .map((tag) => _buildAvailableTag(tag))
              .toList(),
        ),

        const SizedBox(height: 12),

        // Add Custom Tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTagController,
                decoration: InputDecoration(
                  hintText: 'Crear nueva etiqueta',
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF007C91)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addCustomTag,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF007C91),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF007C91),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTag(String tag) {
    return GestureDetector(
      onTap: () => _addTag(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.image_outlined,
                label: 'Adjuntar Imagen',
                onTap: _attachImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttachmentButton(
                icon: isRecording ? Icons.stop : Icons.mic_outlined,
                label: isRecording ? 'Detener grabación' : 'Adjuntar Audio',
                onTap: _attachAudio,
                isActive: isRecording,
              ),
            ),
          ],
        ),

        // Show attached files
        if (attachedImages.isNotEmpty || attachedAudios.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attachedImages.isNotEmpty) ...[
                  const Text(
                    'Imágenes adjuntas:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attachedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(attachedImages[index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (attachedAudios.isNotEmpty) ...[
                  const Text(
                    'Audios adjuntos:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: attachedAudios.asMap().entries.map((entry) {
                      int index = entry.key;
                      String audioPath = entry.value;
                      String audioName = audioPath.split('/').last;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.audiotrack,
                              color: Color(0xFF007C91),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                audioName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isPlayingAudio && currentPlayingIndex == index
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Color(0xFF007C91),
                              ),
                              onPressed: () =>
                                  _toggleAudioPlayback(index, audioPath),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeAudio(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.red[50]
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? Colors.red : Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? Colors.red : const Color(0xFF007C91),
                size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007C91),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.isEditing ? 'Actualizar entrada' : 'Guardar entrada',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007C91),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _addTag(String tag) {
    if (!selectedTags.contains(tag)) {
      setState(() {
        selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      selectedTags.remove(tag);
    });
  }

  void _addCustomTag() {
    final tag = _newTagController.text.trim();
    if (tag.isNotEmpty && !selectedTags.contains(tag)) {
      setState(() {
        selectedTags.add(tag);
        _newTagController.clear();
      });
    }
  }

  void _attachImage() {
    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final String? imagePath = await MediaService().takePhoto();
      if (imagePath != null) {
        setState(() {
          attachedImages.add(imagePath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto agregada correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final String? imagePath = await MediaService().pickImageFromGallery();
      if (imagePath != null) {
        setState(() {
          attachedImages.add(imagePath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen agregada correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      attachedImages.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen eliminada')),
    );
  }

  void _attachAudio() {
    _showAudioSourceDialog();
  }

  void _showAudioSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjuntar audio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.red : Color(0xFF007C91),
                ),
                title: Text(
                  isRecording ? 'Detener grabación' : 'Grabar audio',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (isRecording) {
                    _stopRecording();
                  } else {
                    _startRecording();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      final bool hasPermission =
          await MediaService().checkMicrophonePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se requiere permiso de micrófono para grabar audio'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bool recordingStarted = await MediaService().startRecording();
      if (recordingStarted) {
        setState(() {
          isRecording = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Grabación iniciada. Toca el botón de audio para detener.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar grabación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final String? audioPath = await MediaService().stopRecording();
      if (audioPath != null) {
        setState(() {
          isRecording = false;
          attachedAudios.add(audioPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al detener grabación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAudioPlayback(int index, String audioPath) async {
    try {
      if (isPlayingAudio && currentPlayingIndex == index) {
        // Pausar audio actual
        await MediaService().pauseAudio();
        setState(() {
          isPlayingAudio = false;
          currentPlayingIndex = -1;
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
            currentPlayingIndex = index;
          });

          // Crear un timer para verificar cuando termine la reproducción
          _checkAudioCompletion();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en reproducción de audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkAudioCompletion() {
    // Verificar periódicamente si el audio sigue reproduciéndose
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && isPlayingAudio) {
        if (!MediaService().isPlaying) {
          setState(() {
            isPlayingAudio = false;
            currentPlayingIndex = -1;
          });
        } else {
          _checkAudioCompletion(); // Continuar verificando
        }
      }
    });
  }

  void _removeAudio(int index) {
    setState(() {
      if (currentPlayingIndex == index && isPlayingAudio) {
        MediaService().stopAudio();
        isPlayingAudio = false;
        currentPlayingIndex = -1;
      }
      attachedAudios.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio eliminado')),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título y contenido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (widget.isEditing && widget.entryId != null) {
        // Modo edición: actualizar entrada existente
        final entry = DiaryEntry(
          date: selectedDate,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: selectedTags,
          attachedImages: attachedImages,
          attachedAudios: attachedAudios,
          isFavorite: false, // Mantener el estado actual de favorito
        );

        // Para editar en Isar, necesitamos mantener el ID existente
        entry.id = widget.entryId!;

        await DatabaseService.instance.updateEntry(entry);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada actualizada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Modo creación: crear nueva entrada
        final entry = DiaryEntry(
          date: selectedDate,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: selectedTags,
          attachedImages: attachedImages,
          attachedAudios: attachedAudios,
          isFavorite: false,
        );

        await DatabaseService.instance.createEntry(entry);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada guardada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Retorna true para indicar que se guardó
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _newTagController.dispose();

    // Cleanup audio resources
    if (isPlayingAudio) {
      MediaService().stopAudio();
    }
    if (isRecording) {
      MediaService().stopRecording();
    }
    MediaService().disposePlayer();
    MediaService().disposeRecorder();

    super.dispose();
  }
}
