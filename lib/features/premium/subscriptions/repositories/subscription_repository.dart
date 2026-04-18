import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/premium/subscriptions/models/subscription_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

class SubscriptionRepository {
  final FirebaseFirestore _firestore;

  SubscriptionRepository(this._firestore);

  Future<SubscriptionModel?> getSubscription(String communityId) async {
    final doc = await _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .get();
    if (!doc.exists) return null;
    return SubscriptionModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<SubscriptionModel?> watchSubscription(String communityId) {
    return _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return SubscriptionModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  Future<void> startTrial({
    required String communityId,
    required SubscriptionPlan plan,
    required String adminUid,
  }) async {
    final existing = await getSubscription(communityId);
    if (existing != null) {
      throw StateError('Esta comunidad ya tiene una suscripción activa.');
    }

    final now = DateTime.now();
    final subscription = SubscriptionModel(
      communityId: communityId,
      plan: plan,
      status: SubscriptionStatus.trial,
      trialStartedAt: now,
      trialEndsAt: now.add(const Duration(days: 30)),
      createdAt: now,
      createdBy: adminUid,
    );

    await _firestore
        .collection(FirestorePaths.subscriptions)
        .doc(communityId)
        .set(subscription.toFirestore());
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(firestoreProvider));
});

final subscriptionProvider =
    StreamProvider.family<SubscriptionModel?, String>((ref, communityId) {
  return ref
      .watch(subscriptionRepositoryProvider)
      .watchSubscription(communityId);
});
