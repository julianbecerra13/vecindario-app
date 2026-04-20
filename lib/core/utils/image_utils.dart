import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  ImageUtils._();

  static final _picker = ImagePicker();

  static Future<File?> pickFromCamera({
    int maxWidth = 1200,
    int quality = 85,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<File?> pickFromGallery({
    int maxWidth = 1200,
    int quality = 85,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  static Future<List<File>> pickMultipleFromGallery({
    int maxImages = 5,
    int maxWidth = 1200,
    int quality = 85,
  }) async {
    final picked = await _picker.pickMultiImage(
      maxWidth: maxWidth.toDouble(),
      imageQuality: quality,
    );
    final files = picked
        .take(maxImages)
        .map((xFile) => File(xFile.path))
        .toList();
    return files;
  }
}
