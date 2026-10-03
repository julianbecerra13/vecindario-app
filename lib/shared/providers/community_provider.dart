import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

final currentCommunityProvider = StreamProvider<CommunityModel?>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(null);
  return ref.watch(communityRepositoryProvider).watchCommunity(communityId);
});

final managedCommunitiesProvider = StreamProvider<List<CommunityModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || !user.isAdmin) return Stream.value(const []);
  return ref
      .watch(communityRepositoryProvider)
      .watchManagedCommunities(user.id);
});
