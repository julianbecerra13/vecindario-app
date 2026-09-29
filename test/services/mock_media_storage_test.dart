import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/services/mock_media_storage.dart';

void main() {
  test('reconoce y reconstruye rutas locales del backend mock', () {
    const uri = 'file:///data/user/0/app/mock_media/posts/foto.jpg';
    expect(MockMediaStorage.isLocal(uri), isTrue);
    expect(MockMediaStorage.fileFromUrl(uri).path, contains('foto.jpg'));
  });

  test('no confunde una URL remota con un archivo mock', () {
    expect(MockMediaStorage.isLocal('https://example.com/foto.jpg'), isFalse);
  });
}
