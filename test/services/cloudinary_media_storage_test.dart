import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vecindario_app/core/services/cloudinary_media_storage.dart';

void main() {
  test('sube bytes al endpoint auto y devuelve secure_url', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'secure_url':
              'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        }),
        200,
      );
    });
    final storage = CloudinaryMediaStorage(
      cloudName: 'demo',
      uploadPreset: 'vecindario_unsigned',
      client: client,
    );

    final url = await storage.uploadBytes(
      bytes: Uint8List.fromList([1, 2, 3]),
      name: 'foto prueba.jpg',
      folder: 'communities/demo/posts',
      contentType: 'image/jpeg',
    );

    expect(captured.method, 'POST');
    expect(
      captured.url.toString(),
      'https://api.cloudinary.com/v1_1/demo/auto/upload',
    );
    expect(url, contains('res.cloudinary.com'));
  });

  test('falla de forma clara si falta configuración', () async {
    final storage = CloudinaryMediaStorage(cloudName: '', uploadPreset: '');

    expect(
      () => storage.uploadBytes(
        bytes: Uint8List(0),
        name: 'archivo.pdf',
        folder: 'circulars',
        contentType: 'application/pdf',
      ),
      throwsStateError,
    );
  });
}
