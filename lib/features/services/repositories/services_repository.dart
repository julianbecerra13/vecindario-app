import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/shared/models/review_model.dart';

class ServicesRepository {
  final FirebaseFirestore _firestore;

  ServicesRepository(this._firestore);

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
        .map((snap) => snap.docs
            .map((doc) =>
                ServiceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<ServiceModel?> getService(String serviceId) async {
    final doc = await _firestore
        .collection(FirestorePaths.services)
        .doc(serviceId)
        .get();
    if (!doc.exists) return null;
    return ServiceModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<String> createService(ServiceModel service) async {
    final doc = await _firestore
        .collection(FirestorePaths.services)
        .add(service.toFirestore());
    return doc.id;
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
        .map((snap) => snap.docs
            .map((doc) => ReviewModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore
        .collection(FirestorePaths.reviews)
        .add(review.toFirestore());
  }
}
