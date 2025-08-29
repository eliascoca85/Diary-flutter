import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialized = false;
  AudioPlayer? _audioPlayer;
  String? _currentPlayingAudio;

  /// Obtener el directorio donde se almacenarán las imágenes de la app
  Future<Directory> get _imageDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'diary_images'));

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    return imageDir;
  }

  /// Obtener el directorio donde se almacenarán los audios de la app
  Future<Directory> get _audioDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(appDir.path, 'diary_audios'));

    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }

  /// Seleccionar imagen desde galería
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85, // Comprimir para ahorrar espacio
      );

      if (image != null) {
        return await _saveImageToLocalDirectory(image);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  /// Tomar foto con cámara
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImageToLocalDirectory(image);
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
    return null;
  }

  /// Guardar imagen en directorio local de la app
  Future<String> _saveImageToLocalDirectory(XFile image) async {
    final imageDir = await _imageDirectory;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final localPath = path.join(imageDir.path, fileName);

    final File localImage = await File(image.path).copy(localPath);
    return localImage.path;
  }

  /// Verificar si una imagen existe
  Future<bool> imageExists(String imagePath) async {
    return await File(imagePath).exists();
  }

  /// Eliminar imagen del almacenamiento local
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
    return false;
  }

  /// Obtener el tamaño de una imagen en bytes
  Future<int> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Error getting image size: $e');
    }
    return 0;
  }

  /// Limpiar imágenes huérfanas (que no están referenciadas en ninguna entrada)
  Future<void> cleanOrphanedImages(List<String> referencedImagePaths) async {
    try {
      final imageDir = await _imageDirectory;
      final List<FileSystemEntity> files = imageDir.listSync();

      for (final file in files) {
        if (file is File) {
          if (!referencedImagePaths.contains(file.path)) {
            await file.delete();
            print('Deleted orphaned image: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning orphaned images: $e');
    }
  }

  /// Obtener información de almacenamiento
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final imageDir = await _imageDirectory;
      final List<FileSystemEntity> files = imageDir.listSync();

      int totalSize = 0;
      int imageCount = 0;

      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
          imageCount++;
        }
      }

      return {
        'imageCount': imageCount,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'imageCount': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
      };
    }
  }

  // ============ MÉTODOS DE AUDIO ============

  /// Inicializar el grabador de audio
  Future<bool> _initializeRecorder() async {
    try {
      if (_audioRecorder == null) {
        _audioRecorder = FlutterSoundRecorder();
      }

      if (!_isRecorderInitialized) {
        await _audioRecorder!.openRecorder();
        _isRecorderInitialized = true;
      }
      return true;
    } catch (e) {
      print('Error initializing recorder: $e');
      return false;
    }
  }

  /// Verificar permisos de micrófono
  Future<bool> checkMicrophonePermission() async {
    try {
      // Verificar si ya tenemos el permiso
      PermissionStatus status = await Permission.microphone.status;

      if (status.isGranted) {
        return true;
      }

      // Si no, solicitarlo
      status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      print('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Iniciar grabación de audio
  Future<bool> startRecording() async {
    try {
      if (!await _initializeRecorder()) {
        return false;
      }

      final audioDir = await _audioDirectory;
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      final filePath = path.join(audioDir.path, fileName);

      await _audioRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Detener grabación y retornar la ruta del archivo
  Future<String?> stopRecording() async {
    try {
      if (_audioRecorder != null && _audioRecorder!.isRecording) {
        return await _audioRecorder!.stopRecorder();
      }
      return null;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Verificar si está grabando
  Future<bool> isRecording() async {
    try {
      return _audioRecorder?.isRecording ?? false;
    } catch (e) {
      print('Error checking recording state: $e');
      return false;
    }
  }

  /// Limpiar recursos del grabador
  Future<void> disposeRecorder() async {
    try {
      if (_audioRecorder != null) {
        await _audioRecorder!.closeRecorder();
        _audioRecorder = null;
        _isRecorderInitialized = false;
      }
    } catch (e) {
      print('Error disposing recorder: $e');
    }
  }

  /// Eliminar audio del almacenamiento local
  Future<bool> deleteAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting audio: $e');
    }
    return false;
  }

  // ============ MÉTODOS DE REPRODUCCIÓN ============

  /// Obtener duración de un archivo de audio
  Future<Duration?> getAudioDuration(String audioPath) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
      }

      await _audioPlayer!.setFilePath(audioPath);
      final duration = _audioPlayer!.duration;
      return duration;
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }

  /// Reproducir audio
  Future<bool> playAudio(String audioPath) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
      }

      // Detener audio actual si está reproduciéndose
      if (_audioPlayer!.playing) {
        await _audioPlayer!.stop();
      }

      await _audioPlayer!.setFilePath(audioPath);
      await _audioPlayer!.play();
      _currentPlayingAudio = audioPath;
      return true;
    } catch (e) {
      print('Error playing audio: $e');
      return false;
    }
  }

  /// Pausar audio
  Future<void> pauseAudio() async {
    try {
      if (_audioPlayer != null && _audioPlayer!.playing) {
        await _audioPlayer!.pause();
      }
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  /// Detener audio
  Future<void> stopAudio() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _currentPlayingAudio = null;
      }
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Verificar si está reproduciendo
  bool get isPlaying => _audioPlayer?.playing ?? false;

  /// Obtener audio actualmente reproduciéndose
  String? get currentPlayingAudio => _currentPlayingAudio;

  /// Obtener posición actual de reproducción
  Duration get currentPosition => _audioPlayer?.position ?? Duration.zero;

  /// Limpiar recursos del reproductor
  Future<void> disposePlayer() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
        _audioPlayer = null;
        _currentPlayingAudio = null;
      }
    } catch (e) {
      print('Error disposing player: $e');
    }
  }

  /// Formatear duración a string legible
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}
