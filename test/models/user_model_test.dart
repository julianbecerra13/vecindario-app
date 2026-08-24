import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

void main() {
  group('CommunityRole', () {
    test('fromString devuelve el rol correcto', () {
      expect(CommunityRole.fromString('admin'), CommunityRole.admin);
      expect(CommunityRole.fromString('resident'), CommunityRole.resident);
      expect(CommunityRole.fromString('unknown'), CommunityRole.resident);
    });

    test('toValue devuelve el string correcto', () {
      expect(CommunityRole.admin.toValue(), 'admin');
      expect(CommunityRole.resident.toValue(), 'resident');
    });
  });

  group('UserModel', () {
    test('fromFirestore crea modelo correctamente', () {
      final data = {
        'displayName': 'Juan Pérez',
        'email': 'juan@test.com',
        'phone': '3001234567',
        'photoURL': 'https://example.com/photo.jpg',
        'communityId': 'comm1',
        'communityRole': 'admin',
        'estrato': 4,
        'verified': true,
        'tower': 'T1',
        'apartment': '501',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };

      final user = UserModel.fromFirestore(data, 'uid1');

      expect(user.id, 'uid1');
      expect(user.displayName, 'Juan Pérez');
      expect(user.email, 'juan@test.com');
      expect(user.communityRole, CommunityRole.admin);
      expect(user.platformRole, isNull);
      expect(user.estrato, 4);
      expect(user.verified, true);
      expect(user.tower, 'T1');
      expect(user.apartment, '501');
    });

    test('fromFirestore reconoce platformRole de super_admin', () {
      final data = {
        'displayName': 'Ada',
        'email': 'ada@test.com',
        'phone': '3000000000',
        'communityRole': 'resident',
        'platformRole': 'super_admin',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };

      final user = UserModel.fromFirestore(data, 'uid2');

      expect(user.platformRole, 'super_admin');
      expect(user.isSuperAdmin, true);
      expect(user.isCommunityAdmin, false);
      expect(user.isAdmin, true);
    });

    test('toFirestore serializa correctamente', () {
      final user = UserModel(
        id: 'uid1',
        displayName: 'María López',
        email: 'maria@test.com',
        phone: '3009876543',
        communityRole: CommunityRole.resident,
        verified: false,
        createdAt: DateTime(2026, 3, 15),
      );

      final data = user.toFirestore();

      expect(data['displayName'], 'María López');
      expect(data['email'], 'maria@test.com');
      expect(data['communityRole'], 'resident');
      expect(data.containsKey('platformRole'), false);
      expect(data['verified'], false);
    });

    test('isAdmin es true para admin de comunidad y para super_admin', () {
      final communityAdmin = UserModel(
        id: '1',
        displayName: '',
        email: '',
        phone: '',
        communityRole: CommunityRole.admin,
        createdAt: DateTime.now(),
      );
      final superAdmin = UserModel(
        id: '2',
        displayName: '',
        email: '',
        phone: '',
        platformRole: 'super_admin',
        createdAt: DateTime.now(),
      );
      final resident = UserModel(
        id: '3',
        displayName: '',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );

      expect(communityAdmin.isAdmin, true);
      expect(communityAdmin.isCommunityAdmin, true);
      expect(communityAdmin.isSuperAdmin, false);
      expect(superAdmin.isAdmin, true);
      expect(superAdmin.isSuperAdmin, true);
      expect(superAdmin.isCommunityAdmin, false);
      expect(resident.isAdmin, false);
    });

    test('initials funciona correctamente', () {
      final user = UserModel(
        id: '1',
        displayName: 'Juan Pérez',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
      expect(user.initials, 'JP');

      final singleName = UserModel(
        id: '2',
        displayName: 'Ana',
        email: '',
        phone: '',
        createdAt: DateTime.now(),
      );
      expect(singleName.initials, 'A');
    });

    test('unitInfo formatea torre y apartamento', () {
      final user = UserModel(
        id: '1',
        displayName: 'Test',
        email: '',
        phone: '',
        tower: '3',
        apartment: '402',
        createdAt: DateTime.now(),
      );
      expect(user.unitInfo, 'Torre 3 - Apto 402');
    });

    test('copyWith actualiza campos correctamente', () {
      final user = UserModel(
        id: '1',
        displayName: 'Original',
        email: 'old@test.com',
        phone: '',
        verified: false,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(displayName: 'Actualizado', verified: true);

      expect(updated.displayName, 'Actualizado');
      expect(updated.verified, true);
      expect(updated.email, 'old@test.com'); // No cambió
      expect(updated.id, '1'); // Nunca cambia
    });
  });
}
