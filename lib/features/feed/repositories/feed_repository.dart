import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;

  FeedRepository(this._firestore);

  Stream<List<PostModel>> watchPosts(String communityId, {int limit = 30}) {
    return _firestore
        .collection(FirestorePaths.posts(communityId))
        .orderBy('pinned', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PostModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<PostModel?> getPost(String communityId, String postId) async {
    final doc = await _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId)
        .get();
    if (!doc.exists) return null;
    return PostModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createPost(String communityId, PostModel post) async {
    await _firestore
        .collection(FirestorePaths.posts(communityId))
        .add(post.toFirestore());
  }

  Future<void> deletePost(String communityId, String postId) async {
    await _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId)
        .delete();
  }

  Future<void> toggleLike(
    String communityId,
    String postId,
    String uid,
    bool isLiked,
  ) async {
    final ref = _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId);

    if (isLiked) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likes': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likes': FieldValue.increment(1),
      });
    }
  }

  Future<void> pinPost(String communityId, String postId, bool pinned) async {
    await _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId)
        .update({'pinned': pinned});
  }

  Future<void> votePoll(
    String communityId,
    String postId,
    int optionIndex,
    String uid,
  ) async {
    final ref = _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId);

    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final data = doc.data()!;
      final options = (data['pollOptions'] as List)
          .map((e) => PollOption.fromMap(e as Map<String, dynamic>))
          .toList();

      options[optionIndex] = PollOption(
        text: options[optionIndex].text,
        votes: options[optionIndex].votes + 1,
        voterUids: [...options[optionIndex].voterUids, uid],
      );

      tx.update(ref, {'pollOptions': options.map((e) => e.toMap()).toList()});
    });
  }

  // Reportar post
  Future<void> reportPost(
    String communityId,
    String postId,
    String reporterUid,
    String reason,
  ) async {
    await _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId)
        .collection('reports')
        .add({
          'reporterUid': reporterUid,
          'reason': reason,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  // Comentarios
  Stream<List<CommentModel>> watchComments(String communityId, String postId) {
    return _firestore
        .collection(FirestorePaths.comments(communityId, postId))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addComment(
    String communityId,
    String postId,
    CommentModel comment,
  ) async {
    final batch = _firestore.batch();

    batch.set(
      _firestore.collection(FirestorePaths.comments(communityId, postId)).doc(),
      comment.toFirestore(),
    );

    batch.update(
      _firestore.collection(FirestorePaths.posts(communityId)).doc(postId),
      {'commentCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  Future<void> deleteComment(
    String communityId,
    String postId,
    String commentId,
  ) async {
    final batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection(FirestorePaths.comments(communityId, postId))
          .doc(commentId),
    );

    batch.update(
      _firestore.collection(FirestorePaths.posts(communityId)).doc(postId),
      {'commentCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }
}
