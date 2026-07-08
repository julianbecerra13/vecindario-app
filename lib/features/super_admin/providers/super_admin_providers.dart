import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/super_admin/repositories/super_admin_repository.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final superAdminRepositoryProvider = Provider<SuperAdminRepository>((ref) {
  return SuperAdminRepository(ref.watch(firestoreProvider));
});

final allCommunitiesProvider = StreamProvider<List<CommunityModel>>((ref) {
  return ref.watch(superAdminRepositoryProvider).watchAllCommunities();
});

final communityUsersCountProvider = FutureProvider.family<int, String>((
  ref,
  communityId,
) {
  return ref
      .watch(superAdminRepositoryProvider)
      .countVerifiedUsers(communityId);
});

final allSubscriptionsProvider =
    StreamProvider<Map<String, Map<String, dynamic>>>((ref) {
      return ref.watch(superAdminRepositoryProvider).watchAllSubscriptions();
    });
