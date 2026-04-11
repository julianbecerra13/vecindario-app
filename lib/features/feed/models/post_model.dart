import 'package:cloud_firestore/cloud_firestore.dart';

enum PostType {
  news('Noticia'),
  alert('Alerta'),
  poll('Encuesta');

  final String label;
  const PostType(this.label);

  static PostType fromString(String value) {
    switch (value) {
      case 'alert': return PostType.alert;
      case 'poll': return PostType.poll;
      default: return PostType.news;
    }
  }
}

class PollOption {
  final String text;
  final int votes;
  final List<String> voterUids;

  const PollOption({
    required this.text,
    this.votes = 0,
    this.voterUids = const [],
  });

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      text: map['text'] ?? '',
      votes: map['votes'] ?? 0,
      voterUids: List<String>.from(map['voterUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'votes': votes,
    'voterUids': voterUids,
  };
}

class PostModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoURL;
  final String text;
  final List<String> imageURLs;
  final PostType type;
  final bool pinned;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final List<PollOption>? pollOptions;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    required this.text,
    this.imageURLs = const [],
    this.type = PostType.news,
    this.pinned = false,
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    this.pollOptions,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoURL: data['authorPhotoURL'],
      text: data['text'] ?? '',
      imageURLs: List<String>.from(data['imageURLs'] ?? []),
      type: PostType.fromString(data['type'] ?? 'news'),
      pinned: data['pinned'] ?? false,
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      pollOptions: data['pollOptions'] != null
          ? (data['pollOptions'] as List)
              .map((e) => PollOption.fromMap(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorUid': authorUid,
    'authorName': authorName,
    'authorPhotoURL': authorPhotoURL,
    'text': text,
    'imageURLs': imageURLs,
    'type': type.name,
    'pinned': pinned,
    'likes': likes,
    'likedBy': likedBy,
    'commentCount': commentCount,
    if (pollOptions != null)
      'pollOptions': pollOptions!.map((e) => e.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool isLikedBy(String uid) => likedBy.contains(uid);
}
