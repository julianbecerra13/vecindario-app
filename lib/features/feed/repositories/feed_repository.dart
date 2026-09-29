import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vecindario_app/core/constants/firestore_paths.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';
import 'package:vecindario_app/features/feed/models/feed_attachment.dart';

class FeedRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage? _storage;

  FeedRepository(this._firestore, [this._storage]);

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

  Future<String> createPostWithAttachments(
    String communityId,
    PostModel post,
    List<PendingFeedAttachment> pending,
  ) async {
    final doc = await _firestore
        .collection(FirestorePaths.posts(communityId))
        .add(post.toFirestore());
    if (pending.isEmpty) return doc.id;
    try {
      final attachments = <FeedAttachment>[];
      for (var index = 0; index < pending.length; index++) {
        attachments.add(
          await _upload(
            pending[index],
            'communities/$communityId/posts/${doc.id}/${index}_${_safeName(pending[index].name)}',
          ),
        );
      }
      await doc.update({
        'attachments': attachments.map((item) => item.toMap()).toList(),
        'imageURLs': attachments
            .where((item) => item.type == FeedAttachmentType.image)
            .map((item) => item.url)
            .toList(),
      });
      return doc.id;
    } catch (_) {
      await doc.delete();
      rethrow;
    }
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

  Future<void> addCommentWithAttachment(
    String communityId,
    String postId,
    CommentModel comment,
    PendingFeedAttachment pending,
  ) async {
    final commentRef = _firestore
        .collection(FirestorePaths.comments(communityId, postId))
        .doc();
    final postRef = _firestore
        .collection(FirestorePaths.posts(communityId))
        .doc(postId);
    await commentRef.set(comment.toFirestore());
    try {
      final attachment = await _upload(
        pending,
        'communities/$communityId/posts/$postId/comments/${commentRef.id}/${_safeName(pending.name)}',
      );
      final batch = _firestore.batch();
      batch.update(commentRef, {'attachment': attachment.toMap()});
      batch.update(postRef, {'commentCount': FieldValue.increment(1)});
      await batch.commit();
    } catch (_) {
      await commentRef.delete();
      rethrow;
    }
  }

  Future<FeedAttachment> _upload(
    PendingFeedAttachment pending,
    String path,
  ) async {
    final storage = _storage;
    if (storage == null) throw StateError('Almacenamiento no configurado');
    final snapshot = await storage
        .ref(path)
        .putFile(
          pending.file,
          SettableMetadata(contentType: pending.contentType),
        );
    return FeedAttachment(
      url: await snapshot.ref.getDownloadURL(),
      name: pending.name,
      type: pending.type,
      size: pending.size,
    );
  }

  String _safeName(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

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
