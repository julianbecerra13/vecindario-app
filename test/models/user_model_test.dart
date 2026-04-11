import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

void main() {
  group('UserRole', () {
    test('fromString devuelve el rol correcto', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromString('store_owner'), UserRole.storeOwner);
      expect(UserRole.fromString('external'), UserRole.external_);
      expect(UserRole.fromString('resident'), UserRole.resident);
      expect(UserRole.fromString('unknown'), UserRole.resident);
    });

    test('toValue devuelve el string correcto', () {
      expect(UserRole.admin.toValue(), 'admin');
      expect(UserRole.superAdmin.toValue(), 'super_admin');
      expect(UserRole.storeOwner.toValue(), 'store_owner');
      expect(UserRole.external_.toValue(), 'external');
      expect(UserRole.resident.toValue(), 'resident');
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
        'role': 'admin',
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
      expect(user.role, UserRole.admin);
      expect(user.estrato, 4);
      expect(user.verified, true);
      expect(user.tower, 'T1');
      expect(user.apartment, '501');
    });

    test('toFirestore serializa correctamente', () {
      final user = UserModel(
        id: 'uid1',
        displayName: 'María López',
        email: 'maria@test.com',
        phone: '3009876543',
        role: UserRole.resident,
        verified: false,
        createdAt: DateTime(2026, 3, 15),
      );

      final data = user.toFirestore();

      expect(data['displayName'], 'María López');
      expect(data['email'], 'maria@test.com');
      expect(data['role'], 'resident');
      expect(data['verified'], false);
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

      final updated = user.copyWith(
        displayName: 'Actualizado',
        verified: true,
      );

      expect(updated.displayName, 'Actualizado');
      expect(updated.verified, true);
      expect(updated.email, 'old@test.com'); // No cambió
      expect(updated.id, '1'); // Nunca cambia
    });
  });
}
