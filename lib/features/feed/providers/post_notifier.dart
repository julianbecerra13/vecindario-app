import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/utils/logger.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/providers/feed_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class PostActionState {
  final bool isLoading;
  final String? error;
  const PostActionState({this.isLoading = false, this.error});
}

class PostNotifier extends StateNotifier<PostActionState> {
  final Ref _ref;

  PostNotifier(this._ref) : super(const PostActionState());

  String? get _communityId => _ref.read(currentCommunityIdProvider);

  Future<bool> createPost(PostModel post) async {
    if (_communityId == null) return false;
    state = const PostActionState(isLoading: true);
    try {
      await _ref.read(feedRepositoryProvider).createPost(_communityId!, post);
      state = const PostActionState();
      return true;
    } catch (e) {
      AppLogger.error('Error creando post', e);
      state = PostActionState(error: 'Error al publicar');
      return false;
    }
  }

  Future<void> deletePost(String postId) async {
    if (_communityId == null) return;
    try {
      await _ref.read(feedRepositoryProvider).deletePost(_communityId!, postId);
    } catch (e) {
      AppLogger.error('Error eliminando post', e);
    }
  }

  Future<void> toggleLike(String postId, String uid, bool isLiked) async {
    if (_communityId == null) return;
    try {
      await _ref
          .read(feedRepositoryProvider)
          .toggleLike(_communityId!, postId, uid, isLiked);
    } catch (e) {
      AppLogger.error('Error en like', e);
    }
  }

  Future<void> pinPost(String postId, bool pinned) async {
    if (_communityId == null) return;
    try {
      await _ref
          .read(feedRepositoryProvider)
          .pinPost(_communityId!, postId, pinned);
    } catch (e) {
      AppLogger.error('Error fijando post', e);
    }
  }

  Future<void> reportPost(String postId, String uid, String reason) async {
    if (_communityId == null) return;
    try {
      await _ref
          .read(feedRepositoryProvider)
          .reportPost(_communityId!, postId, uid, reason);
    } catch (e) {
      AppLogger.error('Error reportando post', e);
    }
  }

  Future<void> votePoll(String postId, int optionIndex, String uid) async {
    if (_communityId == null) return;
    try {
      await _ref
          .read(feedRepositoryProvider)
          .votePoll(_communityId!, postId, optionIndex, uid);
    } catch (e) {
      AppLogger.error('Error votando', e);
    }
  }
}

final postNotifierProvider =
    StateNotifierProvider<PostNotifier, PostActionState>((ref) {
  return PostNotifier(ref);
});
