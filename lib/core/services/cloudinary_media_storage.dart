import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:vecindario_app/core/services/media_storage_service.dart';

class CloudinaryMediaStorage implements MediaStorageService {
  CloudinaryMediaStorage({
    required this.cloudName,
    required this.uploadPreset,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;

  Uri get _uploadUri =>
      Uri.https('api.cloudinary.com', '/v1_1/$cloudName/auto/upload');

  @override
  Future<String> uploadFile({
    required File file,
    required String name,
    required String folder,
    required String contentType,
  }) async => uploadBytes(
    bytes: await file.readAsBytes(),
    name: name,
    folder: folder,
    contentType: contentType,
  );

  @override
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String name,
    required String folder,
    required String contentType,
  }) async {
    if (cloudName.isEmpty || uploadPreset.isEmpty) {
      throw StateError('Cloudinary no está configurado');
    }
    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'vecindario/${_safeFolder(folder)}'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _safeName(name),
          contentType: _parseMediaType(contentType),
        ),
      );
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        _cloudinaryError(response.body) ??
            'No fue posible subir el archivo (${response.statusCode})',
      );
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final url = payload['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw const FormatException('Cloudinary no devolvió una URL segura');
    }
    return url;
  }

  String? _cloudinaryError(String body) {
    try {
      final payload = jsonDecode(body) as Map<String, dynamic>;
      return (payload['error'] as Map<String, dynamic>?)?['message'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _safeFolder(String value) => value
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .map(_safeName)
      .join('/');

  String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

  MediaType _parseMediaType(String value) {
    final parts = value.split('/');
    return MediaType(
      parts.isEmpty ? 'application' : parts.first,
      parts.length < 2 ? 'octet-stream' : parts[1],
    );
  }
}
