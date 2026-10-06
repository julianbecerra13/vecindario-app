import 'dart:io';
import 'dart:typed_data';

abstract interface class MediaStorageService {
  Future<String> uploadFile({
    required File file,
    required String name,
    required String folder,
    required String contentType,
  });

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String name,
    required String folder,
    required String contentType,
  });
}
