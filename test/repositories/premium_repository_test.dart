import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PremiumRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = PremiumRepository(firestore);
  });

  group('PremiumRepository', () {
    group('Circulars', () {
      test('watchCirculars retorna lista ordenada por createdAt descendente', () async {
        // Arrange
        const communityId = 'comm-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.circulars(communityId)).add({
          'title': 'Circular 1',
          'body': 'Body 1',
          'priority': 'informative',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        });

        await firestore.collection(FirestorePaths.circulars(communityId)).add({
          'title': 'Circular 2',
          'body': 'Body 2',
          'priority': 'urgent',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchCirculars(communityId);
        final result = await stream.first;

        // Assert
        expect(result.length, 2);
        expect(result[0].title, 'Circular 2'); // Más reciente primero
        expect(result[1].title, 'Circular 1');
      });

      test('createCircular agrega documento a circulars', () async {
        // Arrange
        const communityId = 'comm-1';
        final circular = CircularModel(
          id: '',
          title: 'Test Circular',
          body: 'Test Body',
          authorUid: 'admin-1',
          authorName: 'Admin User',
          priority: CircularPriority.urgent,
          createdAt: DateTime.now(),
          readBy: const [],
          ackBy: const [],
        );

        // Act
        await repository.createCircular(communityId, circular);

        // Assert
        final docs = await firestore.collection(FirestorePaths.circulars(communityId)).get();
        expect(docs.docs.length, 1);
        expect(docs.docs.first['title'], 'Test Circular');
      });

      test('markCircularAsRead agrega uid a readBy array', () async {
        // Arrange
        const communityId = 'comm-1';
        const circularId = 'circ-1';
        const uid = 'user-1';

        await firestore.collection(FirestorePaths.circulars(communityId)).doc(circularId).set({
          'title': 'Test',
          'body': 'Body',
          'priority': 'informative',
          'readBy': [],
          'ackBy': [],
          'createdAt': Timestamp.now(),
        });

        // Act
        await repository.markCircularAsRead(communityId, circularId, uid);

        // Assert
        final doc = await firestore.collection(FirestorePaths.circulars(communityId)).doc(circularId).get();
        final readBy = doc['readBy'] as List;
        expect(readBy.length, 1);
        expect(readBy[0]['uid'], uid);
      });
    });

    group('Fines', () {
      test('watchFines retorna lista ordenada por createdAt descendente', () async {
        // Arrange
        const communityId = 'comm-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.fines(communityId)).add({
          'unitNumber': '101',
          'residentUid': 'user-1',
          'amount': 150000,
          'reason': 'Ruido',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        });

        await firestore.collection(FirestorePaths.fines(communityId)).add({
          'unitNumber': '102',
          'residentUid': 'user-2',
          'amount': 200000,
          'reason': 'Basura',
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchFines(communityId);
        final result = await stream.first;

        // Assert
        expect(result.length, 2);
        expect(result[0].unitNumber, '102'); // Más reciente primero
        expect(result[1].unitNumber, '101');
      });

      test('watchMyFines filtra solo multas del residente', () async {
        // Arrange
        const communityId = 'comm-1';
        const uid = 'user-1';

        await firestore.collection(FirestorePaths.fines(communityId)).add({
          'unitNumber': '101',
          'residentUid': uid,
          'amount': 150000,
          'reason': 'Ruido',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        await firestore.collection(FirestorePaths.fines(communityId)).add({
          'unitNumber': '102',
          'residentUid': 'user-2',
          'amount': 200000,
          'reason': 'Basura',
          'status': 'pending',
          'createdAt': Timestamp.now(),
        });

        // Act
        final stream = repository.watchMyFines(communityId, uid);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].residentUid, uid);
      });
    });

    group('PQRS', () {
      test('watchAllPqrs retorna todas las PQRS ordenadas por createdAt', () async {
        // Arrange
        const communityId = 'comm-1';

        await firestore.collection(FirestorePaths.pqrs(communityId)).add({
          'title': 'PQRS 1',
          'description': 'Desc 1',
          'category': 'mantenimiento',
          'residentUid': 'user-1',
          'status': 'received',
          'createdAt': Timestamp.now(),
        });

        await firestore.collection(FirestorePaths.pqrs(communityId)).add({
          'title': 'PQRS 2',
          'description': 'Desc 2',
          'category': 'seguridad',
          'residentUid': 'user-2',
          'status': 'inProgress',
          'createdAt': Timestamp.now(),
        });

        // Act
        final stream = repository.watchAllPqrs(communityId);
        final result = await stream.first;

        // Assert
        expect(result.length, 2);
      });

      test('watchMyPqrs filtra solo PQRS del residente', () async {
        // Arrange
        const communityId = 'comm-1';
        const uid = 'user-1';

        await firestore.collection(FirestorePaths.pqrs(communityId)).add({
          'title': 'PQRS 1',
          'description': 'Desc 1',
          'category': 'mantenimiento',
          'residentUid': uid,
          'status': 'received',
          'createdAt': Timestamp.now(),
        });

        await firestore.collection(FirestorePaths.pqrs(communityId)).add({
          'title': 'PQRS 2',
          'description': 'Desc 2',
          'category': 'seguridad',
          'residentUid': 'user-2',
          'status': 'inProgress',
          'createdAt': Timestamp.now(),
        });

        // Act
        final stream = repository.watchMyPqrs(communityId, uid);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].residentUid, uid);
      });
    });

    group('Amenities', () {
      test('watchAmenities retorna todas las amenidades', () async {
        // Arrange
        const communityId = 'comm-1';

        await firestore.collection(FirestorePaths.amenities(communityId)).add({
          'name': 'Piscina',
          'description': 'Piscina olímpica',
          'capacity': 50,
          'basePrice': 50000,
          'createdAt': Timestamp.now(),
        });

        await firestore.collection(FirestorePaths.amenities(communityId)).add({
          'name': 'Cancha',
          'description': 'Cancha deportiva',
          'capacity': 100,
          'basePrice': 30000,
          'createdAt': Timestamp.now(),
        });

        // Act
        final stream = repository.watchAmenities(communityId);
        final result = await stream.first;

        // Assert
        expect(result.length, 2);
      });

      test('watchBookings filtra bookings por amenityId', () async {
        // Arrange
        const communityId = 'comm-1';
        const amenityId = 'amenity-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.bookings(communityId)).add({
          'amenityId': amenityId,
          'amenityName': 'Piscina',
          'residentUid': 'user-1',
          'residentName': 'User 1',
          'date': Timestamp.fromDate(now),
          'startTime': '10:00',
          'endTime': '12:00',
          'totalPaid': 50000,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(now),
        });

        await firestore.collection(FirestorePaths.bookings(communityId)).add({
          'amenityId': 'amenity-2',
          'amenityName': 'Cancha',
          'residentUid': 'user-2',
          'residentName': 'User 2',
          'date': Timestamp.fromDate(now.add(const Duration(days: 1))),
          'startTime': '14:00',
          'endTime': '16:00',
          'totalPaid': 30000,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchBookings(communityId, amenityId);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].amenityId, amenityId);
      });

      test('watchMyBookings filtra solo bookings del residente', () async {
        // Arrange
        const communityId = 'comm-1';
        const uid = 'user-1';
        final now = DateTime.now();

        await firestore.collection(FirestorePaths.bookings(communityId)).add({
          'amenityId': 'amenity-1',
          'amenityName': 'Piscina',
          'residentUid': uid,
          'residentName': 'User 1',
          'date': Timestamp.fromDate(now),
          'startTime': '10:00',
          'endTime': '12:00',
          'totalPaid': 50000,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(now),
        });

        await firestore.collection(FirestorePaths.bookings(communityId)).add({
          'amenityId': 'amenity-2',
          'amenityName': 'Cancha',
          'residentUid': 'user-2',
          'residentName': 'User 2',
          'date': Timestamp.fromDate(now.add(const Duration(days: 1))),
          'startTime': '14:00',
          'endTime': '16:00',
          'totalPaid': 30000,
          'status': 'confirmed',
          'createdAt': Timestamp.fromDate(now),
        });

        // Act
        final stream = repository.watchMyBookings(communityId, uid);
        final result = await stream.first;

        // Assert
        expect(result.length, 1);
        expect(result[0].residentUid, uid);
      });
    });
  });
}
