import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final ImagePicker _picker = ImagePicker();

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
}
