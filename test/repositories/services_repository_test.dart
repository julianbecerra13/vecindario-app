import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/repositories/services_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ServicesRepository repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = ServicesRepository(fakeFirestore);
  });

  group('ServicesRepository', () {
    test('watchServices sin filtro devuelve activos de la comunidad', () async {
      await fakeFirestore.collection('services').doc('s1').set({
        'communityId': 'comm1',
        'title': 'Servicio 1',
        'category': 'hogar',
        'active': true,
        'ownerUid': 'owner1',
        'ownerName': 'Juan',
        'description': 'desc',
        'imageURLs': [],
        'rating': 4.5,
        'ratingCount': 10,
        'orderCount': 5,
        'createdAt': DateTime(2026, 4, 1),
      });

      await fakeFirestore.collection('services').doc('s2').set({
        'communityId': 'comm1',
        'title': 'Servicio Inactivo',
        'category': 'belleza',
        'active': false,
        'ownerUid': 'owner2',
        'ownerName': 'María',
        'description': 'desc',
        'imageURLs': [],
        'rating': 3.0,
        'ratingCount': 5,
        'orderCount': 2,
        'createdAt': DateTime(2026, 4, 2),
      });

      final services = await repo.watchServices('comm1').first;
      expect(services.length, 1);
      expect(services.first.title, 'Servicio 1');
      expect(services.first.active, true);
    });

    test('watchServices con categoría filtra correctamente', () async {
      await fakeFirestore.collection('services').doc('s1').set({
        'communityId': 'comm1',
        'title': 'Comidas',
        'category': 'comida',
        'active': true,
        'ownerUid': 'owner1',
        'ownerName': 'Juan',
        'description': 'desc',
        'imageURLs': [],
        'rating': 4.5,
        'ratingCount': 10,
        'orderCount': 5,
        'createdAt': DateTime(2026, 4, 1),
      });

      await fakeFirestore.collection('services').doc('s2').set({
        'communityId': 'comm1',
        'title': 'Belleza',
        'category': 'belleza',
        'active': true,
        'ownerUid': 'owner2',
        'ownerName': 'María',
        'description': 'desc',
        'imageURLs': [],
        'rating': 3.0,
        'ratingCount': 5,
        'orderCount': 2,
        'createdAt': DateTime(2026, 4, 2),
      });

      final services = await repo.watchServices(
        'comm1',
        category: ServiceCategory.comida,
      ).first;

      expect(services.length, 1);
      expect(services.first.title, 'Comidas');
      expect(services.first.category, ServiceCategory.comida);
    });

    test('watchServices NO devuelve servicios de otra comunidad', () async {
      await fakeFirestore.collection('services').doc('s1').set({
        'communityId': 'comm1',
        'title': 'Servicio Comm1',
        'category': 'hogar',
        'active': true,
        'ownerUid': 'owner1',
        'ownerName': 'Juan',
        'description': 'desc',
        'imageURLs': [],
        'rating': 4.5,
        'ratingCount': 10,
        'orderCount': 5,
        'createdAt': DateTime(2026, 4, 1),
      });

      await fakeFirestore.collection('services').doc('s2').set({
        'communityId': 'comm2',
        'title': 'Servicio Comm2',
        'category': 'hogar',
        'active': true,
        'ownerUid': 'owner2',
        'ownerName': 'María',
        'description': 'desc',
        'imageURLs': [],
        'rating': 3.0,
        'ratingCount': 5,
        'orderCount': 2,
        'createdAt': DateTime(2026, 4, 2),
      });

      final services = await repo.watchServices('comm1').first;
      expect(services.length, 1);
      expect(services.first.title, 'Servicio Comm1');
    });

    test('getService retorna null si no existe', () async {
      final service = await repo.getService('nonexistent');
      expect(service, isNull);
    });

    test('getService retorna el servicio si existe', () async {
      await fakeFirestore.collection('services').doc('s1').set({
        'communityId': 'comm1',
        'title': 'Mi Servicio',
        'category': 'hogar',
        'active': true,
        'ownerUid': 'owner1',
        'ownerName': 'Juan',
        'description': 'desc',
        'imageURLs': [],
        'rating': 4.5,
        'ratingCount': 10,
        'orderCount': 5,
        'createdAt': DateTime(2026, 4, 1),
      });

      final service = await repo.getService('s1');
      expect(service, isNotNull);
      expect(service!.title, 'Mi Servicio');
    });
  });
}
