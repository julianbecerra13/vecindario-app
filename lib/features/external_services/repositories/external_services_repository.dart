import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/external_services/models/external_service_model.dart';
import 'package:vecindario_app/shared/models/review_model.dart';

class ExternalServicesRepository {
  final FirebaseFirestore _firestore;

  ExternalServicesRepository(this._firestore);

  Stream<List<ExternalServiceModel>> watchExternalServices({
    ExternalCategory? category,
  }) {
    Query query = _firestore
        .collection(FirestorePaths.externalServices)
        .where('active', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query
        .orderBy('sponsored', descending: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ExternalServiceModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<void> recommendService(ExternalServiceModel service) async {
    await _firestore
        .collection(FirestorePaths.externalServices)
        .add(service.toFirestore());
  }

  Stream<List<ReviewModel>> watchReviews(String serviceId) {
    return _firestore
        .collection(FirestorePaths.reviews)
        .where('targetId', isEqualTo: serviceId)
        .where('targetType', isEqualTo: 'external')
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
