import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';

/// Verifica si la comunidad actual tiene el módulo premium activo
final isPremiumProvider = StreamProvider<bool>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(false);

  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.subscriptions)
      .doc(communityId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return false;
    final status = doc.data()?['status'] ?? '';
    return status == 'active' || status == 'trial';
  });
});

/// Plan actual de la suscripción
final subscriptionPlanProvider = StreamProvider<String?>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.subscriptions)
      .doc(communityId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return doc.data()?['plan'] as String?;
  });
});

/// Verifica si una feature específica está disponible según el plan
bool isFeatureAvailable(String? plan, String feature) {
  if (plan == null) return false;

  const starterFeatures = [
    'circulars',
    'pqrs',
    'manual',
    'fines',
  ];
  const proFeatures = [
    ...starterFeatures,
    'amenities',
    'finances',
    'payments',
  ];
  const enterpriseFeatures = [
    ...proFeatures,
    'assemblies',
    'reports',
    'api',
  ];

  switch (plan) {
    case 'starter':
      return starterFeatures.contains(feature);
    case 'professional':
      return proFeatures.contains(feature);
    case 'enterprise':
      return enterpriseFeatures.contains(feature);
    default:
      return false;
  }
}
