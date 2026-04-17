import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';
import 'package:vecindario_app/features/feed/models/comment_model.dart';
import 'package:vecindario_app/features/feed/repositories/feed_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FeedRepository repo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repo = FeedRepository(fakeFirestore);
  });

  group('FeedRepository', () {
    test('watchPosts devuelve posts de la comunidad', () async {
      await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .set({
        'authorUid': 'u1',
        'authorName': 'Juan',
        'text': 'Post 1',
        'pinned': false,
        'likes': 0,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': DateTime(2026, 4, 1),
        'type': 'news',
      });

      await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p2')
          .set({
        'authorUid': 'u2',
        'authorName': 'María',
        'text': 'Post 2',
        'pinned': false,
        'likes': 0,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': DateTime(2026, 4, 2),
        'type': 'news',
      });

      final posts = await repo.watchPosts('comm1').first;
      expect(posts.length, 2);
      final texts = posts.map((p) => p.text).toList();
      expect(texts, containsAll(['Post 1', 'Post 2']));
    });

    test('createPost agrega documento', () async {
      final post = PostModel(
        id: 'p1',
        authorUid: 'u1',
        authorName: 'Juan',
        text: 'Nuevo post',
        imageURLs: [],
        type: PostType.news,
        pinned: false,
        likedBy: [],
        likes: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
      );

      await repo.createPost('comm1', post);

      final snap = await fakeFirestore
          .collection('communities/comm1/posts')
          .get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['text'], 'Nuevo post');
    });

    test('toggleLike con isLiked=false incrementa likes y añade uid', () async {
      await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .set({
        'authorUid': 'u1',
        'authorName': 'Juan',
        'text': 'Post',
        'pinned': false,
        'likes': 0,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': DateTime.now(),
        'type': 'news',
      });

      await repo.toggleLike('comm1', 'p1', 'u2', false);

      final doc = await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .get();
      expect(doc['likes'], 1);
      expect(doc['likedBy'], contains('u2'));
    });

    test('toggleLike con isLiked=true decrementa likes y remueve uid', () async {
      await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .set({
        'authorUid': 'u1',
        'authorName': 'Juan',
        'text': 'Post',
        'pinned': false,
        'likes': 1,
        'likedBy': ['u2'],
        'commentCount': 0,
        'createdAt': DateTime.now(),
        'type': 'news',
      });

      await repo.toggleLike('comm1', 'p1', 'u2', true);

      final doc = await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .get();
      expect(doc['likes'], 0);
      expect(doc['likedBy'], isNot(contains('u2')));
    });

    test('addComment incrementa commentCount y crea doc en sub-colección',
        () async {
      await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .set({
        'authorUid': 'u1',
        'authorName': 'Juan',
        'text': 'Post',
        'pinned': false,
        'likes': 0,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': DateTime.now(),
        'type': 'news',
      });

      final comment = CommentModel(
        id: 'c1',
        authorUid: 'u2',
        authorName: 'María',
        text: 'Comentario',
        createdAt: DateTime.now(),
      );

      await repo.addComment('comm1', 'p1', comment);

      final post = await fakeFirestore
          .collection('communities/comm1/posts')
          .doc('p1')
          .get();
      expect(post['commentCount'], 1);

      final comments = await fakeFirestore
          .collection('communities/comm1/posts/p1/comments')
          .get();
      expect(comments.docs.length, 1);
    });
  });
}
