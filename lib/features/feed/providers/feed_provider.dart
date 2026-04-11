import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/repositories/feed_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.watch(firestoreProvider));
});

final feedPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(feedRepositoryProvider).watchPosts(communityId);
});
