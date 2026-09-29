import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/shared/models/review_model.dart';

class ServicesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage? _storage;

  ServicesRepository(this._firestore, [this._storage]);

  Stream<List<ServiceModel>> watchServices(
    String communityId, {
    ServiceCategory? category,
  }) {
    Query query = _firestore
        .collection(FirestorePaths.services)
        .where('communityId', isEqualTo: communityId)
        .where('active', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ServiceModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<ServiceModel?> getService(String serviceId) async {
    final doc = await _firestore
        .collection(FirestorePaths.services)
        .doc(serviceId)
        .get();
    if (!doc.exists) return null;
    return ServiceModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<List<ServiceModel>> getServicesForOwner(
    String ownerUid,
    String communityId,
  ) {
    return _firestore
        .collection(FirestorePaths.services)
        .where('ownerUid', isEqualTo: ownerUid)
        .where('communityId', isEqualTo: communityId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createService(ServiceModel service) async {
    final doc = await _firestore
        .collection(FirestorePaths.services)
        .add(service.toFirestore());
    return doc.id;
  }

  Future<String> createServiceWithImages(
    ServiceModel service,
    List<File> images,
  ) async {
    final doc = await _firestore
        .collection(FirestorePaths.services)
        .add(service.toFirestore());
    if (images.isEmpty) return doc.id;
    try {
      final urls = <String>[];
      for (var index = 0; index < images.length; index++) {
        final extension = images[index].path.split('.').last.toLowerCase();
        urls.add(
          await _uploadServiceImage(doc.id, images[index], index, extension),
        );
      }
      await doc.update({'imageURLs': urls});
      return doc.id;
    } catch (_) {
      await doc.delete();
      rethrow;
    }
  }

  Future<String> _uploadServiceImage(
    String serviceId,
    File image,
    int index,
    String extension,
  ) async {
    final normalizedExtension =
        {'jpg', 'jpeg', 'png', 'webp'}.contains(extension) ? extension : 'jpg';
    final contentType = normalizedExtension == 'png'
        ? 'image/png'
        : normalizedExtension == 'webp'
        ? 'image/webp'
        : 'image/jpeg';
    final storage = _storage;
    if (storage == null) throw StateError('Almacenamiento no configurado');
    final reference = storage.ref(
      'services/$serviceId/image_$index.$normalizedExtension',
    );
    final snapshot = await reference.putFile(
      image,
      SettableMetadata(contentType: contentType),
    );
    return snapshot.ref.getDownloadURL();
  }

  Future<void> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(FirestorePaths.services)
        .doc(serviceId)
        .update(data);
  }

  Future<void> deleteService(String serviceId) async {
    await _firestore
        .collection(FirestorePaths.services)
        .doc(serviceId)
        .delete();
  }

  Stream<List<ReviewModel>> watchServiceReviews(String serviceId) {
    return _firestore
        .collection(FirestorePaths.reviews)
        .where('targetId', isEqualTo: serviceId)
        .where('targetType', isEqualTo: 'service')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore
        .collection(FirestorePaths.reviews)
        .add(review.toFirestore());
  }
}
