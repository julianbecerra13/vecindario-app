import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:vecindario_app/features/visitors/models/visitor_pass_model.dart';

class VisitorsRepository {
  const VisitorsRepository(this._firestore);
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> _passes(String communityId) =>
      _firestore
          .collection('communities')
          .doc(communityId)
          .collection('visitor_passes');

  Stream<List<VisitorPassModel>> watchMine(String communityId, String uid) {
    return _passes(
      communityId,
    ).where('residentUid', isEqualTo: uid).snapshots().map((snapshot) {
      final passes = snapshot.docs.map(VisitorPassModel.fromFirestore).toList()
        ..sort((a, b) => b.validFrom.compareTo(a.validFrom));
      return passes;
    });
  }

  Future<String> create({
    required String communityId,
    required String residentUid,
    required String residentName,
    required String unit,
    required String visitorName,
    required DateTime validFrom,
    required DateTime expiresAt,
  }) async {
    final id = const Uuid().v4();
    await _passes(communityId).doc(id).set({
      'residentUid': residentUid,
      'residentName': residentName,
      'unit': unit,
      'visitorName': visitorName,
      'validFrom': Timestamp.fromDate(validFrom),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'used': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  Future<void> cancel(String communityId, String passId) =>
      _passes(communityId).doc(passId).update({'used': true});
}
