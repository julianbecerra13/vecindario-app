import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/super_admin/repositories/super_admin_repository.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SuperAdminRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = SuperAdminRepository(firestore);
  });

  group('SuperAdminRepository', () {
    test('watchAllCommunities ordena por createdAt descendente', () async {
      final now = DateTime.now();
      await firestore.collection(FirestorePaths.communities).add({
        'name': 'Antigua',
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      });
      await firestore.collection(FirestorePaths.communities).add({
        'name': 'Reciente',
        'createdAt': Timestamp.fromDate(now),
      });

      final result = await repository.watchAllCommunities().first;

      expect(result.length, 2);
      expect(result[0].name, 'Reciente');
      expect(result[1].name, 'Antigua');
    });

    test('createCommunity agrega la comunidad', () async {
      final community = CommunityModel(
        id: '',
        name: 'Conjunto Los Robles',
        address: 'Calle 1',
        city: 'Bogotá',
        estrato: 4,
        adminUid: 'admin-1',
        inviteCode: 'ABC123',
        createdAt: DateTime.now(),
      );

      await repository.createCommunity(community);

      final docs = await firestore.collection(FirestorePaths.communities).get();
      expect(docs.docs.length, 1);
      expect(docs.docs.first['name'], 'Conjunto Los Robles');
      expect(docs.docs.first['inviteCode'], 'ABC123');
    });

    test(
      'countVerifiedUsers cuenta solo residentes verificados del conjunto',
      () async {
        const communityId = 'comm-1';
        await firestore.collection(FirestorePaths.users).add({
          'communityId': communityId,
          'verified': true,
        });
        await firestore.collection(FirestorePaths.users).add({
          'communityId': communityId,
          'verified': true,
        });
        await firestore.collection(FirestorePaths.users).add({
          'communityId': communityId,
          'verified': false,
        });
        await firestore.collection(FirestorePaths.users).add({
          'communityId': 'otra',
          'verified': true,
        });

        final count = await repository.countVerifiedUsers(communityId);

        expect(count, 2);
      },
    );

    test('assignAdmin actualiza el conjunto y el rol del usuario', () async {
      const communityId = 'comm-1';
      const uid = 'user-1';
      await firestore
          .collection(FirestorePaths.communities)
          .doc(communityId)
          .set({
            'name': 'Comunidad',
            'adminUid': '',
            'createdAt': Timestamp.now(),
          });
      await firestore.collection(FirestorePaths.users).doc(uid).set({
        'communityRole': 'resident',
        'verified': false,
      });

      await repository.assignAdmin(communityId: communityId, uid: uid);

      final community = await firestore
          .collection(FirestorePaths.communities)
          .doc(communityId)
          .get();
      final user = await firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      expect(community['adminUid'], uid);
      expect(user['communityRole'], 'admin');
      expect(user['communityId'], communityId);
      expect(user['verified'], true);
    });

    test('activatePlan crea la suscripción en trial de 30 días', () async {
      const communityId = 'comm-1';

      await repository.activatePlan(
        communityId: communityId,
        plan: 'professional',
      );

      final sub = await firestore
          .collection(FirestorePaths.subscriptions)
          .doc(communityId)
          .get();
      expect(sub['plan'], 'professional');
      expect(sub['status'], 'trial');
      expect(sub['createdBy'], 'super_admin');
      final start = (sub['trialStartedAt'] as Timestamp).toDate();
      final end = (sub['trialEndsAt'] as Timestamp).toDate();
      expect(end.difference(start).inDays, 30);
    });

    test('deleteCommunity elimina el conjunto y su suscripción', () async {
      const communityId = 'comm-1';
      await firestore
          .collection(FirestorePaths.communities)
          .doc(communityId)
          .set({'name': 'X', 'createdAt': Timestamp.now()});
      await firestore
          .collection(FirestorePaths.subscriptions)
          .doc(communityId)
          .set({'plan': 'starter', 'status': 'trial'});

      await repository.deleteCommunity(communityId);

      final community = await firestore
          .collection(FirestorePaths.communities)
          .doc(communityId)
          .get();
      final sub = await firestore
          .collection(FirestorePaths.subscriptions)
          .doc(communityId)
          .get();
      expect(community.exists, false);
      expect(sub.exists, false);
    });
  });
}
