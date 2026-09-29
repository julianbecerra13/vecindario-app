import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/features/appointments/models/appointment_model.dart';

class AppointmentsRepository {
  const AppointmentsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String communityId) =>
      _firestore
          .collection('communities')
          .doc(communityId)
          .collection('appointments');

  Stream<List<AppointmentModel>> watchMine(String communityId, String uid) {
    return _collection(
      communityId,
    ).where('residentUid', isEqualTo: uid).snapshots().map((snapshot) {
      final result = snapshot.docs.map(AppointmentModel.fromFirestore).toList();
      result.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      return result;
    });
  }

  Future<String> create({
    required String communityId,
    required String residentUid,
    required String residentName,
    required DateTime scheduledAt,
    required String reason,
  }) async {
    final doc = await _collection(communityId).add({
      'residentUid': residentUid,
      'residentName': residentName,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'reason': reason,
      'status': AppointmentStatus.requested.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
