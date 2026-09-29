import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/visitors/models/visitor_pass_model.dart';

void main() {
  test('VisitorPassModel interpreta vigencia y uso', () async {
    final firestore = FakeFirebaseFirestore();
    final now = DateTime.now();
    await firestore.collection('passes').doc('pass').set({
      'visitorName': 'Jairo Pérez',
      'validFrom': Timestamp.fromDate(now.subtract(const Duration(minutes: 5))),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 2))),
      'used': false,
    });
    final doc = await firestore.collection('passes').doc('pass').get();
    final pass = VisitorPassModel.fromFirestore(doc);
    expect(pass.visitorName, 'Jairo Pérez');
    expect(pass.isActive, isTrue);
  });
}
