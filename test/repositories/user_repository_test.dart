import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/shared/models/user_model.dart';
import 'package:vecindario_app/shared/repositories/user_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage fakeStorage;
  late UserRepository repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeStorage = MockFirebaseStorage();
    repo = UserRepository(fakeFirestore, fakeStorage);
  });

  group('UserRepository', () {
    test('createUser y getUser', () async {
      final user = UserModel(
        id: 'uid1',
        displayName: 'Juan Pérez',
        email: 'juan@test.com',
        phone: '3001234567',
        createdAt: DateTime(2026, 1, 1),
      );

      await repo.createUser(user);
      final fetched = await repo.getUser('uid1');

      expect(fetched, isNotNull);
      expect(fetched!.displayName, 'Juan Pérez');
      expect(fetched.email, 'juan@test.com');
      expect(fetched.phone, '3001234567');
    });

    test('getUser retorna null si no existe', () async {
      final fetched = await repo.getUser('nonexistent');
      expect(fetched, isNull);
    });

    test('updateUser actualiza campos', () async {
      final user = UserModel(
        id: 'uid2',
        displayName: 'María',
        email: 'maria@test.com',
        phone: '',
        verified: false,
        createdAt: DateTime.now(),
      );

      await repo.createUser(user);
      await repo.updateUser('uid2', {'verified': true, 'tower': 'T1'});

      final updated = await repo.getUser('uid2');
      expect(updated!.verified, true);
      expect(updated.tower, 'T1');
    });

    test('requestAccountDeletion crea solicitud', () async {
      await repo.requestAccountDeletion('uid3');

      final snap =
          await fakeFirestore.collection('deletion_requests').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['uid'], 'uid3');
      expect(snap.docs.first.data()['status'], 'pending');
    });

    test('requestDataExport crea solicitud', () async {
      await repo.requestDataExport('uid4');

      final snap =
          await fakeFirestore.collection('data_export_requests').get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['uid'], 'uid4');
      expect(snap.docs.first.data()['status'], 'pending');
    });

    test('getConsents retorna defaults si no hay documento', () async {
      final consents = await repo.getConsents('uid5');

      expect(consents['pushNotifications'], true);
      expect(consents['emailMarketing'], false);
      expect(consents['analytics'], true);
    });

    test('updateConsents guarda y se puede leer', () async {
      await repo.updateConsents('uid6', {
        'pushNotifications': false,
        'emailMarketing': true,
        'analytics': false,
      });

      final consents = await repo.getConsents('uid6');
      expect(consents['pushNotifications'], false);
      expect(consents['emailMarketing'], true);
      expect(consents['analytics'], false);
    });

    test('watchPendingResidents filtra por comunidad y no verificados',
        () async {
      // Crear 2 usuarios: uno verificado y uno no
      await fakeFirestore.collection('users').doc('u1').set({
        'displayName': 'Verificado',
        'email': 'v@t.com',
        'phone': '',
        'communityId': 'comm1',
        'verified': true,
        'role': 'resident',
        'createdAt': DateTime.now(),
      });
      await fakeFirestore.collection('users').doc('u2').set({
        'displayName': 'Pendiente',
        'email': 'p@t.com',
        'phone': '',
        'communityId': 'comm1',
        'verified': false,
        'role': 'resident',
        'createdAt': DateTime.now(),
      });

      final pending =
          await repo.watchPendingResidents('comm1').first;
      expect(pending.length, 1);
      expect(pending.first.displayName, 'Pendiente');
    });
  });
}
