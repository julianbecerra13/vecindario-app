import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final pendingResidentsProvider = StreamProvider((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(userRepositoryProvider).watchPendingResidents(communityId);
});
