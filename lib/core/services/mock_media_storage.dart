import 'dart:io';

import 'package:path_provider/path_provider.dart';

class MockMediaStorage {
  const MockMediaStorage._();

  static Future<String> save(File source, String relativePath) async {
    final root = await getApplicationDocumentsDirectory();
    final safeSegments = relativePath
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map((segment) => segment.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_'));
    final target = File('${root.path}/mock_media/${safeSegments.join('/')}');
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    return target.uri.toString();
  }

  static bool isLocal(String value) => value.startsWith('file:');

  static File fileFromUrl(String value) => File(Uri.parse(value).toFilePath());
}
