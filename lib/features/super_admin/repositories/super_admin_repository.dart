import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

class SuperAdminRepository {
  final FirebaseFirestore _firestore;

  SuperAdminRepository(this._firestore);

  // ==================== COMUNIDADES ====================
  Stream<List<CommunityModel>> watchAllCommunities() {
    return _firestore
        .collection(FirestorePaths.communities)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => CommunityModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<CommunityModel?> watchCommunity(String communityId) {
    return _firestore
        .collection(FirestorePaths.communities)
        .doc(communityId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return CommunityModel.fromFirestore(doc.data()!, doc.id);
        });
  }

  // Conteo de residentes verificados de una comunidad
  Future<int> countVerifiedUsers(String communityId) async {
    final snap = await _firestore
        .collection(FirestorePaths.users)
        .where('communityId', isEqualTo: communityId)
        .where('verified', isEqualTo: true)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<void> createCommunity(CommunityModel community) async {
    await _firestore
        .collection(FirestorePaths.communities)
        .add(community.toFirestore());
  }

  Future<void> deleteCommunity(String communityId) async {
    await _firestore
        .collection(FirestorePaths.communities)
        .doc(communityId)
        .delete();
    await _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .delete();
  }

  // Asigna un usuario como admin del conjunto y lo marca verificado
  Future<void> assignAdmin({
    required String communityId,
    required String uid,
  }) async {
    await _firestore
        .collection(FirestorePaths.communities)
        .doc(communityId)
        .update({'adminUid': uid});
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      'communityRole': 'admin',
      'communityId': communityId,
      'verified': true,
    });
  }

  // ==================== SUSCRIPCIONES ====================
  Stream<Map<String, Map<String, dynamic>>> watchAllSubscriptions() {
    return _firestore.collection(FirestorePaths.subscriptions).snapshots().map((
      snap,
    ) {
      final map = <String, Map<String, dynamic>>{};
      for (final doc in snap.docs) {
        map[doc.id] = doc.data();
      }
      return map;
    });
  }

  Stream<Map<String, dynamic>?> watchSubscription(String communityId) {
    return _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Crea la suscripción en modo trial (30 días gratis)
  Future<void> activatePlan({
    required String communityId,
    required String plan,
    String createdBy = 'super_admin',
  }) async {
    final now = DateTime.now();
    await _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .set({
          'plan': plan,
          'status': 'trial',
          'trialStartedAt': Timestamp.fromDate(now),
          'trialEndsAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
          'createdAt': Timestamp.fromDate(now),
          'createdBy': createdBy,
        });
  }
}
