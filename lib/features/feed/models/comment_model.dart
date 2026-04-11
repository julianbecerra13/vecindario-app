import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoURL;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CommentModel(
      id: id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoURL: data['authorPhotoURL'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorUid': authorUid,
    'authorName': authorName,
    'authorPhotoURL': authorPhotoURL,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
