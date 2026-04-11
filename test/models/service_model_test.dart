import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';

void main() {
  group('ServiceCategory', () {
    test('fromString parsea correctamente', () {
      expect(ServiceCategory.fromString('comida'), ServiceCategory.comida);
      expect(ServiceCategory.fromString('belleza'), ServiceCategory.belleza);
      expect(ServiceCategory.fromString('invalid'), ServiceCategory.hogar);
    });
  });

  group('ServiceModel', () {
    test('fromFirestore crea modelo correctamente', () {
      final data = {
        'ownerUid': 'uid1',
        'communityId': 'comm1',
        'title': 'Almuerzos caseros',
        'description': 'Bandeja paisa, ajiaco',
        'category': 'comida',
        'price': 15000.0,
        'imageURLs': ['url1'],
        'rating': 4.8,
        'ratingCount': 45,
        'orderCount': 156,
        'active': true,
        'ownerName': 'Ana Torres',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 15)),
      };

      final service = ServiceModel.fromFirestore(data, 'svc1');

      expect(service.id, 'svc1');
      expect(service.title, 'Almuerzos caseros');
      expect(service.category, ServiceCategory.comida);
      expect(service.rating, 4.8);
      expect(service.orderCount, 156);
      expect(service.ownerName, 'Ana Torres');
    });

    test('displayPrice muestra precio formateado', () {
      final withPrice = ServiceModel(
        id: '1',
        ownerUid: 'u',
        communityId: 'c',
        title: 'Test',
        description: '',
        category: ServiceCategory.comida,
        price: 15000,
        ownerName: 'Test',
        createdAt: DateTime.now(),
      );
      expect(withPrice.displayPrice, '\$15000 COP');

      final withDesc = ServiceModel(
        id: '2',
        ownerUid: 'u',
        communityId: 'c',
        title: 'Test',
        description: '',
        category: ServiceCategory.comida,
        priceDescription: 'Desde \$12.000',
        ownerName: 'Test',
        createdAt: DateTime.now(),
      );
      expect(withDesc.displayPrice, 'Desde \$12.000');

      final noPrice = ServiceModel(
        id: '3',
        ownerUid: 'u',
        communityId: 'c',
        title: 'Test',
        description: '',
        category: ServiceCategory.comida,
        ownerName: 'Test',
        createdAt: DateTime.now(),
      );
      expect(noPrice.displayPrice, 'Consultar precio');
    });
  });
}
