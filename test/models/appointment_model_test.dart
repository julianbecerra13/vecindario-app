import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/appointments/models/appointment_model.dart';

void main() {
  test('AppointmentModel interpreta una cita solicitada', () async {
    final firestore = FakeFirebaseFirestore();
    final scheduledAt = DateTime(2026, 10, 2, 9);
    await firestore
        .collection('communities')
        .doc('community')
        .collection('appointments')
        .doc('appointment')
        .set({
          'residentUid': 'resident',
          'residentName': 'Valentina Rojas',
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'reason': 'Revisar mi estado de cuenta',
          'status': 'requested',
          'createdAt': Timestamp.fromDate(DateTime(2026, 9, 26)),
        });

    final snapshot = await firestore
        .collection('communities')
        .doc('community')
        .collection('appointments')
        .doc('appointment')
        .get();
    final appointment = AppointmentModel.fromFirestore(snapshot);

    expect(appointment.id, 'appointment');
    expect(appointment.scheduledAt, scheduledAt);
    expect(appointment.status, AppointmentStatus.requested);
    expect(appointment.statusLabel, 'Solicitada');
  });
}
