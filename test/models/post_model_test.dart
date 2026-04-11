import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/feed/models/post_model.dart';

void main() {
  group('PostType', () {
    test('fromString parsea correctamente', () {
      expect(PostType.fromString('alert'), PostType.alert);
      expect(PostType.fromString('poll'), PostType.poll);
      expect(PostType.fromString('news'), PostType.news);
      expect(PostType.fromString('invalid'), PostType.news);
    });
  });

  group('PostModel', () {
    test('fromFirestore crea modelo con datos básicos', () {
      final data = {
        'authorUid': 'uid1',
        'authorName': 'Carlos',
        'text': 'Hola vecinos',
        'imageURLs': ['url1', 'url2'],
        'type': 'news',
        'pinned': true,
        'likes': 5,
        'likedBy': ['uid2', 'uid3'],
        'commentCount': 3,
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
      };

      final post = PostModel.fromFirestore(data, 'post1');

      expect(post.id, 'post1');
      expect(post.authorName, 'Carlos');
      expect(post.text, 'Hola vecinos');
      expect(post.imageURLs.length, 2);
      expect(post.pinned, true);
      expect(post.likes, 5);
      expect(post.commentCount, 3);
    });

    test('fromFirestore crea modelo con encuesta', () {
      final data = {
        'authorUid': 'uid1',
        'authorName': 'Admin',
        'text': '¿Aprobar la cuota?',
        'type': 'poll',
        'pinned': false,
        'likes': 0,
        'likedBy': [],
        'commentCount': 0,
        'createdAt': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'pollOptions': [
          {'text': 'Sí', 'votes': 10, 'voterUids': ['a', 'b']},
          {'text': 'No', 'votes': 3, 'voterUids': ['c']},
        ],
      };

      final post = PostModel.fromFirestore(data, 'post2');

      expect(post.type, PostType.poll);
      expect(post.pollOptions, isNotNull);
      expect(post.pollOptions!.length, 2);
      expect(post.pollOptions![0].text, 'Sí');
      expect(post.pollOptions![0].votes, 10);
    });

    test('isLikedBy verifica correctamente', () {
      final post = PostModel(
        id: '1',
        authorUid: 'author',
        authorName: 'Test',
        text: 'Test',
        likedBy: ['uid1', 'uid2'],
        createdAt: DateTime.now(),
      );

      expect(post.isLikedBy('uid1'), true);
      expect(post.isLikedBy('uid3'), false);
    });

    test('toFirestore serializa correctamente', () {
      final post = PostModel(
        id: '1',
        authorUid: 'author',
        authorName: 'Test',
        text: 'Contenido',
        type: PostType.alert,
        pinned: true,
        createdAt: DateTime(2026, 4, 1),
      );

      final data = post.toFirestore();

      expect(data['authorUid'], 'author');
      expect(data['type'], 'alert');
      expect(data['pinned'], true);
    });
  });

  group('PollOption', () {
    test('fromMap y toMap son inversos', () {
      final original = {
        'text': 'Opción A',
        'votes': 5,
        'voterUids': ['uid1', 'uid2'],
      };

      final option = PollOption.fromMap(original);
      final serialized = option.toMap();

      expect(serialized['text'], 'Opción A');
      expect(serialized['votes'], 5);
      expect((serialized['voterUids'] as List).length, 2);
    });
  });
}
