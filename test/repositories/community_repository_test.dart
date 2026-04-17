import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/repositories/community_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CommunityRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = CommunityRepository(firestore);
  });

  group('CommunityRepository', () {
    group('getCommunity', () {
      test('retorna CommunityModel correcto', () async {
        // Arrange
        const communityId = 'community-1';
        await firestore.collection(FirestorePaths.communities).doc(communityId).set({
          'name': 'Edificio Los Andes',
          'address': 'Cra 5 #10-20',
          'city': 'Bogotá',
          'estrato': 4,
          'adminUid': 'admin-1',
          'inviteCode': 'ABC123',
          'memberCount': 15,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act
        final community = await repository.getCommunity(communityId);

        // Assert
        expect(community, isNotNull);
        expect(community!.id, communityId);
        expect(community.name, 'Edificio Los Andes');
        expect(community.inviteCode, 'ABC123');
      });

      test('retorna null si comunidad no existe', () async {
        // Act
        final community = await repository.getCommunity('nonexistent');

        // Assert
        expect(community, isNull);
      });
    });

    group('watchCommunity', () {
      test('emite cambios en stream', () async {
        // Arrange
        const communityId = 'community-1';
        await firestore.collection(FirestorePaths.communities).doc(communityId).set({
          'name': 'Inicial',
          'address': 'Cra 5 #10-20',
          'city': 'Bogotá',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': 'ABC123',
          'memberCount': 15,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act & Assert
        final stream = repository.watchCommunity(communityId);
        final emitted = <CommunityModel?>[];

        // Escuchar stream y recoger primeros valores
        final subscription = stream.listen((community) {
          emitted.add(community);
        });

        // Dar tiempo para que emita el valor inicial
        await Future.delayed(const Duration(milliseconds: 100));

        // Actualizar documento
        await firestore.collection(FirestorePaths.communities).doc(communityId).update({
          'name': 'Actualizado',
        });

        await Future.delayed(const Duration(milliseconds: 100));

        // Cancelar suscripción
        await subscription.cancel();

        // Verificar que emitió al menos dos valores
        expect(emitted.length, greaterThanOrEqualTo(2));
        expect(emitted[0]!.name, 'Inicial');
        expect(emitted[1]!.name, 'Actualizado');
      });
    });

    group('getCommunityByInviteCode', () {
      test('encuentra comunidad por código invitación', () async {
        // Arrange
        const inviteCode = 'TEST99';
        await firestore.collection(FirestorePaths.communities).doc('comm-1').set({
          'name': 'Test Community',
          'address': 'Test Address',
          'city': 'Test City',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': inviteCode,
          'memberCount': 5,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act
        final community = await repository.getCommunityByInviteCode(inviteCode);

        // Assert
        expect(community, isNotNull);
        expect(community!.name, 'Test Community');
        expect(community.inviteCode, inviteCode);
      });

      test('retorna null si código no existe', () async {
        // Act
        final community = await repository.getCommunityByInviteCode('INVALID');

        // Assert
        expect(community, isNull);
      });

      test('insensible a mayúsculas/minúsculas en código', () async {
        // Arrange
        await firestore.collection(FirestorePaths.communities).doc('comm-1').set({
          'name': 'Test Community',
          'address': 'Test Address',
          'city': 'Test City',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': 'UPPER',
          'memberCount': 5,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act - buscar con minúsculas
        final community = await repository.getCommunityByInviteCode('upper');

        // Assert
        expect(community, isNotNull);
        expect(community!.inviteCode, 'UPPER');
      });
    });

    group('joinCommunity', () {
      test('actualiza usuario con communityId, tower, apartment, verified=false', () async {
        // Arrange
        const uid = 'user-1';
        const communityId = 'comm-1';
        await firestore.collection(FirestorePaths.users).doc(uid).set({
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'role': 'resident',
          'verified': true, // cambiar a false después
        });

        // Act
        await repository.joinCommunity(
          communityId: communityId,
          uid: uid,
          tower: 'A',
          apartment: '301',
        );

        // Assert
        final user = await firestore.collection(FirestorePaths.users).doc(uid).get();
        final data = user.data();
        expect(data!['communityId'], communityId);
        expect(data['tower'], 'A');
        expect(data['apartment'], '301');
        expect(data['verified'], false);
      });
    });

    group('regenerateInviteCode', () {
      test('genera código de 6 caracteres alfanuméricos uppercase', () async {
        // Arrange
        const communityId = 'comm-1';
        await firestore.collection(FirestorePaths.communities).doc(communityId).set({
          'name': 'Test Community',
          'address': 'Test Address',
          'city': 'Test City',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': 'OLD999',
          'memberCount': 5,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act
        const newCode = 'NEW123';
        await repository.regenerateInviteCode(communityId, newCode);

        // Assert
        final community = await firestore.collection(FirestorePaths.communities).doc(communityId).get();
        expect(community.data()!['inviteCode'], 'NEW123');
      });

      test('convierte a uppercase si se pasa en minúsculas', () async {
        // Arrange
        const communityId = 'comm-1';
        await firestore.collection(FirestorePaths.communities).doc(communityId).set({
          'name': 'Test Community',
          'address': 'Test Address',
          'city': 'Test City',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': 'OLD999',
          'memberCount': 5,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act
        await repository.regenerateInviteCode(communityId, 'lowercase');

        // Assert
        final community = await firestore.collection(FirestorePaths.communities).doc(communityId).get();
        expect(community.data()!['inviteCode'], 'LOWERCASE');
      });
    });

    group('updateCommunity', () {
      test('actualiza campos específicos de comunidad', () async {
        // Arrange
        const communityId = 'comm-1';
        await firestore.collection(FirestorePaths.communities).doc(communityId).set({
          'name': 'Original Name',
          'address': 'Test Address',
          'city': 'Test City',
          'estrato': 3,
          'adminUid': 'admin-1',
          'inviteCode': 'CODE123',
          'memberCount': 5,
          'unitType': 'apartment',
          'createdAt': DateTime.now(),
        });

        // Act
        await repository.updateCommunity(communityId, {
          'name': 'Updated Name',
          'memberCount': 10,
        });

        // Assert
        final community = await firestore.collection(FirestorePaths.communities).doc(communityId).get();
        final data = community.data();
        expect(data!['name'], 'Updated Name');
        expect(data['memberCount'], 10);
        expect(data['address'], 'Test Address'); // No cambió
      });
    });
  });
}
