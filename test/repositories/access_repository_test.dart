import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/access/access_repository.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

void main() {
  test('QR conserva identidad, vence y no contiene el saldo', () async {
    final db = FakeFirebaseFirestore();
    final repo = AccessRepository(db);
    final token = await repo.issue(UserModel(id: 'resident', displayName: 'Ana',
      email: '', phone: '', communityId: 'community', tower: '1',
      apartment: '101', verified: true, createdAt: DateTime.now()));
    final data = (await db.doc('communities/community/access_tokens/$token').get()).data()!;
    expect(data['residentUid'], 'resident');
    expect(data['unit'], 'Torre 1 - Apto 101');
    expect(data.containsKey('balance'), false);
    expect((data['expiresAt'] as Timestamp).toDate().isAfter(DateTime.now()), true);
  });

  test('registra cantidades y rechaza reutilización del token', () async {
    final db = FakeFirebaseFirestore();
    final repo = AccessRepository(db);
    await db.doc('communities/community/access_tokens/token').set({
      'residentUid': 'resident', 'used': false,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 2))),
    });
    await repo.admit('community', 'token', 'employee', 'Piscina', 1, 2);
    final log = (await db.doc('communities/community/access_logs/token').get()).data()!;
    expect(log['visitors'], 2);
    expect(log['operatorUid'], 'employee');
    await expectLater(repo.admit('community', 'token', 'employee', 'Piscina', 1, 2), throwsStateError);
  });

  test('no registra QR vencido', () async {
    final db = FakeFirebaseFirestore();
    await db.doc('communities/community/access_tokens/old').set({
      'used': false, 'residentUid': 'resident',
      'expiresAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 1))),
    });
    await expectLater(AccessRepository(db).admit('community', 'old', 'employee', 'Piscina', 1, 0), throwsStateError);
    expect((await db.collection('communities/community/access_logs').get()).docs, isEmpty);
  });
}
