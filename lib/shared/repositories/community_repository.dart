import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository(this._firestore);

  Future<CommunityModel?> getCommunity(String id) async {
    final doc =
        await _firestore.collection(FirestorePaths.communities).doc(id).get();
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

  Future<void> updateCommunity(
    String id,
    Map<String, dynamic> data,
  ) async {
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
