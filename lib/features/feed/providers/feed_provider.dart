import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/repositories/feed_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.watch(firestoreProvider));
});

final feedSearchProvider = StateProvider<String>((ref) => '');

final feedPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);

  final search = ref.watch(feedSearchProvider).toLowerCase().trim();

  return ref.watch(feedRepositoryProvider).watchPosts(communityId).map((posts) {
    if (search.isEmpty) return posts;
    return posts
        .where(
          (p) =>
              p.text.toLowerCase().contains(search) ||
              p.authorName.toLowerCase().contains(search),
        )
        .toList();
  });
});

final postDetailProvider = FutureProvider.family<PostModel?, String>((
  ref,
  postId,
) async {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return null;
  return ref.read(feedRepositoryProvider).getPost(communityId, postId);
});
