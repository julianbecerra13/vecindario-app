import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

final pendingResidentsProvider = StreamProvider((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(userRepositoryProvider).watchPendingResidents(communityId);
});

final communityProvider = StreamProvider<CommunityModel?>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value(null);
  return ref.watch(communityRepositoryProvider).watchCommunity(communityId);
});
