import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';

final userPostCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  final communityId = ref.watch(currentCommunityIdProvider);

  if (user == null || communityId == null) return 0;

  final snap = await ref
      .watch(firestoreProvider)
      .collection(FirestorePaths.posts(communityId))
      .where('authorUid', isEqualTo: user.id)
      .count()
      .get();

  return snap.count ?? 0;
});
