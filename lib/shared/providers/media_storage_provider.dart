import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/config/backend_features.dart';
import 'package:vecindario_app/core/services/cloudinary_media_storage.dart';
import 'package:vecindario_app/core/services/media_storage_service.dart';

final mediaStorageProvider = Provider<MediaStorageService?>((ref) {
  if (!kMediaUploadsEnabled ||
      kCloudinaryCloudName.isEmpty ||
      kCloudinaryUploadPreset.isEmpty) {
    return null;
  }
  return CloudinaryMediaStorage(
    cloudName: kCloudinaryCloudName,
    uploadPreset: kCloudinaryUploadPreset,
  );
});
