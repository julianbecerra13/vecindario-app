import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/shared/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepository(this._firestore, this._storage);

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore.collection(FirestorePaths.users).doc(uid).snapshots().map(
      (doc) {
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromFirestore(doc.data()!, doc.id);
      },
    );
  }

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.id)
        .set(user.toFirestore());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).update(data);
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> requestAccountDeletion(String uid) async {
    await _firestore.collection(FirestorePaths.deletionRequests).add({
      'uid': uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> requestDataExport(String uid) async {
    // La Cloud Function processará esta solicitud
    await _firestore.collection('data_export_requests').add({
      'uid': uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // --- Consentimientos ---
  Future<Map<String, bool>> getConsents(String uid) async {
    final doc = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('consents')
        .doc('preferences')
        .get();
    if (!doc.exists || doc.data() == null) {
      return {
        'pushNotifications': true,
        'emailMarketing': false,
        'analytics': true,
      };
    }
    final data = doc.data()!;
    return {
      'pushNotifications': data['pushNotifications'] ?? true,
      'emailMarketing': data['emailMarketing'] ?? false,
      'analytics': data['analytics'] ?? true,
    };
  }

  Future<void> updateConsents(String uid, Map<String, bool> consents) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection('consents')
        .doc('preferences')
        .set({
          ...consents,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Stream<List<UserModel>> watchPendingResidents(String communityId) {
    return _firestore
        .collection(FirestorePaths.users)
        .where('communityId', isEqualTo: communityId)
        .where('verified', isEqualTo: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
