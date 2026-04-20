import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';
import 'package:vecindario_app/features/feed/providers/feed_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

final commentsProvider = StreamProvider.family<List<CommentModel>, String>((
  ref,
  postId,
) {
  final communityId = ref.watch(currentCommunityIdProvider);
  if (communityId == null) return Stream.value([]);
  return ref.watch(feedRepositoryProvider).watchComments(communityId, postId);
});
