import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository(this._firestore);

  Future<CommunityModel?> getCommunity(String id) async {
    final doc = await _firestore
        .collection(FirestorePaths.communities)
        .doc(id)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return CommunityModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<CommunityModel?> watchCommunity(String id) {
    return _firestore
        .collection(FirestorePaths.communities)
        .doc(id)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return CommunityModel.fromFirestore(doc.data()!, doc.id);
        });
  }

  /// Comunidades administradas por una misma cuenta. El esquema mantiene
  /// `adminUid` para ser compatible con los conjuntos ya creados.
  Stream<List<CommunityModel>> watchManagedCommunities(String adminUid) {
    return _firestore
        .collection(FirestorePaths.communities)
        .where('adminUid', isEqualTo: adminUid)
        .snapshots()
        .map((snapshot) {
          final communities = snapshot.docs
              .map((doc) => CommunityModel.fromFirestore(doc.data(), doc.id))
              .toList();
          communities.sort((a, b) => a.name.compareTo(b.name));
          return communities;
        });
  }

  Future<CommunityModel?> getCommunityByInviteCode(String code) async {
    final query = await _firestore
        .collection(FirestorePaths.communities)
        .where('inviteCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return CommunityModel.fromFirestore(doc.data(), doc.id);
  }

  /// Resuelve un código mediante un documento de acceso exacto. Esta ruta se
  /// usa como respaldo cuando Cloud Functions no está disponible.
  Future<Map<String, String>?> resolveInviteCode(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    final doc = await _firestore
        .collection('invite_codes')
        .doc(normalizedCode)
        .get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    final communityId = data['communityId'] as String?;
    if (communityId == null || communityId.isEmpty) return null;
    return {
      'communityId': communityId,
      'unitType': data['unitType'] as String? ?? 'apartment',
    };
  }

  Future<void> joinCommunity({
    required String communityId,
    required String uid,
    required String tower,
    required String apartment,
  }) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).update({
      'communityId': communityId,
      'tower': tower,
      'apartment': apartment,
      'verified': false,
    });
  }

  Future<void> updateCommunity(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirestorePaths.communities)
        .doc(id)
        .update(data);
  }

  Future<void> regenerateInviteCode(String communityId, String newCode) async {
    await _firestore
        .collection(FirestorePaths.communities)
        .doc(communityId)
        .update({'inviteCode': newCode.toUpperCase()});
  }
}
