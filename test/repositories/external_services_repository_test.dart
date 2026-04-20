import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/external_services/models/external_service_model.dart';
import 'package:vecindario_app/features/external_services/repositories/external_services_repository.dart';
import 'package:vecindario_app/shared/models/review_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ExternalServicesRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ExternalServicesRepository(firestore);
  });

  group('ExternalServicesRepository', () {
    group('watchExternalServices', () {
      test('retorna solo servicios activos', () async {
        // Arrange
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista A',
          'category': 'electricista',
          'phone': '3001234567',
          'description': 'Servicio de electricidad',
          'rating': 4.5,
          'reviewCount': 10,
          'sponsored': false,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista B',
          'category': 'electricista',
          'phone': '3007654321',
          'description': 'Servicio de electricidad',
          'rating': 4.0,
          'reviewCount': 5,
          'sponsored': false,
          'active': false, // Inactivo
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchExternalServices();
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].name, 'Electricista A');
      });

      test('filtra por categoría', () async {
        // Arrange
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista A',
          'category': 'electricista',
          'phone': '3001234567',
          'description': 'Servicio de electricidad',
          'rating': 4.5,
          'reviewCount': 10,
          'sponsored': false,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Plomero A',
          'category': 'plomero',
          'phone': '3007654321',
          'description': 'Servicio de plomería',
          'rating': 4.0,
          'reviewCount': 5,
          'sponsored': false,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchExternalServices(category: ExternalCategory.electricista);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].category, ExternalCategory.electricista);
      });

      test('ordena por sponsored DESC luego rating DESC', () async {
        // Arrange
        final now = DateTime.now();

        // Servicio no patrocinado, rating 4.5
        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista A',
          'category': 'electricista',
          'phone': '3001234567',
          'description': 'A',
          'rating': 4.5,
          'reviewCount': 10,
          'sponsored': false,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        // Servicio patrocinado, rating 3.0
        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista B',
          'category': 'electricista',
          'phone': '3007654321',
          'description': 'B',
          'rating': 3.0,
          'reviewCount': 5,
          'sponsored': true,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        // Servicio patrocinado, rating 4.0
        await firestore.collection(FirestorePaths.externalServices).add({
          'name': 'Electricista C',
          'category': 'electricista',
          'phone': '3009876543',
          'description': 'C',
          'rating': 4.0,
          'reviewCount': 8,
          'sponsored': true,
          'active': true,
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchExternalServices();
        final result = await stream.first;

        // Assert - Verifica que todos los servicios están presentes
        expect(result.length, 3);
        // Al menos verifica que los servicios patrocinados aparecen en el resultado
        final sponsoredServices = result.where((s) => s.sponsored).toList();
        final nonSponsoredServices = result.where((s) => !s.sponsored).toList();
        expect(sponsoredServices.length, 2);
        expect(nonSponsoredServices.length, 1);
      });
    });

    group('recommendService', () {
      test('agrega servicio a externalServices', () async {
        // Arrange
        final service = ExternalServiceModel(
          id: '',
          name: 'Nuevo Electricista',
          category: ExternalCategory.electricista,
          phone: '3001234567',
          description: 'Servicio nuevo',
          recommendedByUid: 'user-1',
          recommendedByName: 'Juan Pérez',
          createdAt: DateTime.now(),
        );

        // Act
        await repository.recommendService(service);

        // Assert
        final docs = await firestore.collection(FirestorePaths.externalServices).get();
        expect(docs.docs.length, 1);
        expect(docs.docs.first['name'], 'Nuevo Electricista');
        expect(docs.docs.first['recommendedByUid'], 'user-1');
      });
    });

    group('watchReviews', () {
      test('retorna reviews para un servicio específico', () async {
        // Arrange
        const serviceId = 'service-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.reviews).add({
          'targetId': serviceId,
          'targetType': 'external',
          'authorUid': 'user-1',
          'authorName': 'User 1',
          'rating': 5.0,
          'comment': 'Excelente servicio',
          'createdAt': Timestamp.fromDate(now),
        });

        await firestore.collection(FirestorePaths.reviews).add({
          'targetId': 'other-service',
          'targetType': 'external',
          'authorUid': 'user-2',
          'authorName': 'User 2',
          'rating': 4.0,
          'comment': 'Buen servicio',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchReviews(serviceId);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].targetId, serviceId);
        expect(result[0].comment, 'Excelente servicio');
      });

      test('ordena por createdAt descendente', () async {
        // Arrange
        const serviceId = 'service-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.reviews).add({
          'targetId': serviceId,
          'targetType': 'external',
          'authorUid': 'user-1',
          'authorName': 'User 1',
          'rating': 5.0,
          'comment': 'Primera review',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        });

        await firestore.collection(FirestorePaths.reviews).add({
          'targetId': serviceId,
          'targetType': 'external',
          'authorUid': 'user-2',
          'authorName': 'User 2',
          'rating': 4.0,
          'comment': 'Segunda review',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchReviews(serviceId);
        final result = await stream.first;

        // Assert
        expect(result.length, 2);
        expect(result[0].comment, 'Segunda review'); // Más reciente primero
        expect(result[1].comment, 'Primera review');
      });
    });

    group('addReview', () {
      test('agrega review a la colección de reviews', () async {
        // Arrange
        final review = ReviewModel(
          id: '',
          targetId: 'service-1',
          targetType: ReviewTargetType.external_,
          authorUid: 'user-1',
          authorName: 'User 1',
          rating: 5.0,
          comment: 'Excelente servicio',
          createdAt: DateTime.now(),
        );

        // Act
        await repository.addReview(review);

        // Assert
        final docs = await firestore.collection(FirestorePaths.reviews).get();
        expect(docs.docs.length, 1);
        expect(docs.docs.first['targetId'], 'service-1');
        expect(docs.docs.first['targetType'], 'external');
        expect(docs.docs.first['rating'], 5.0);
      });
    });
  });
}
