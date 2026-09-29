import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

class AccessRepository {
  AccessRepository(this.db);
  final FirebaseFirestore db;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMembers(String communityId) {
    return db
        .collection('users')
        .where('communityId', isEqualTo: communityId)
        .where('verified', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchStaff(String communityId) {
    return db
        .collection('communities')
        .doc(communityId)
        .collection('access_staff')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchAdministrationStatus(
    String communityId,
    String uid,
  ) => db
      .collection('communities')
      .doc(communityId)
      .collection('access_status')
      .doc(uid)
      .snapshots();

  Future<void> setStaff(String communityId, String uid, bool active) {
    return db
        .collection('communities')
        .doc(communityId)
        .collection('access_staff')
        .doc(uid)
        .set({'active': active, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> setAdministrationStatus(
    String communityId,
    String uid,
    String status,
  ) {
    return db
        .collection('communities')
        .doc(communityId)
        .collection('access_status')
        .doc(uid)
        .set({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<String> issue(UserModel user) async {
    final token = const Uuid().v4();
    await db
        .collection('communities')
        .doc(user.communityId)
        .collection('access_tokens')
        .doc(token)
        .set({
          'residentUid': user.id,
          'name': user.displayName,
          'unit': user.unitInfo,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 5)),
          ),
          'used': false,
        });
    return token;
  }

  Future<Map<String, dynamic>> inspect(String community, String token) async {
    final doc = await db
        .collection('communities')
        .doc(community)
        .collection('access_tokens')
        .doc(token)
        .get(const GetOptions(source: Source.server));
    final data = doc.data();
    if (data == null ||
        data['used'] == true ||
        !(data['expiresAt'] as Timestamp).toDate().isAfter(DateTime.now())) {
      throw StateError('QR vencido, utilizado o inexistente');
    }
    final status = await db
        .collection('communities')
        .doc(community)
        .collection('access_status')
        .doc(data['residentUid'] as String)
        .get(const GetOptions(source: Source.server));
    return {
      ...data,
      'administrationStatus': status.data()?['status'] ?? 'unknown',
    };
  }

  Future<void> admit(
    String community,
    String token,
    String operatorUid,
    String zone,
    int residents,
    int visitors,
  ) async {
    final root = db.collection('communities').doc(community);
    final tokenRef = root.collection('access_tokens').doc(token);
    // One log per token: prevents replay even with simultaneous scans.
    final logRef = root.collection('access_logs').doc(token);
    await db.runTransaction((tx) async {
      final doc = await tx.get(tokenRef);
      final data = doc.data();
      if (data == null ||
          data['used'] == true ||
          !(data['expiresAt'] as Timestamp).toDate().isAfter(DateTime.now())) {
        throw StateError('El QR ya no es válido');
      }
      tx.update(tokenRef, {'used': true});
      tx.set(logRef, {
        'residentUid': data['residentUid'],
        'operatorUid': operatorUid,
        'zone': zone,
        'residents': residents,
        'visitors': visitors,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<Map<String, dynamic>> inspectVisitor(
    String community,
    String token,
  ) async {
    final doc = await db
        .collection('communities')
        .doc(community)
        .collection('visitor_passes')
        .doc(token)
        .get(const GetOptions(source: Source.server));
    final data = doc.data();
    final now = DateTime.now();
    if (data == null ||
        data['used'] == true ||
        !(data['validFrom'] as Timestamp).toDate().isBefore(now) ||
        !(data['expiresAt'] as Timestamp).toDate().isAfter(now)) {
      throw StateError('Autorización no vigente');
    }
    return data;
  }

  Future<void> admitVisitor(
    String community,
    String token,
    String operatorUid,
    String zone,
  ) async {
    final root = db.collection('communities').doc(community);
    final passRef = root.collection('visitor_passes').doc(token);
    final logRef = root.collection('visitor_access_logs').doc(token);
    await db.runTransaction((tx) async {
      final doc = await tx.get(passRef);
      final data = doc.data();
      final now = DateTime.now();
      if (data == null ||
          data['used'] == true ||
          !(data['validFrom'] as Timestamp).toDate().isBefore(now) ||
          !(data['expiresAt'] as Timestamp).toDate().isAfter(now)) {
        throw StateError('Autorización no vigente');
      }
      tx.update(passRef, {'used': true});
      tx.set(logRef, {
        'passId': token,
        'residentUid': data['residentUid'],
        'visitorName': data['visitorName'],
        'operatorUid': operatorUid,
        'zone': zone,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
