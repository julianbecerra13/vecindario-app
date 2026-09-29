import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vecindario_app/features/feed/models/feed_attachment.dart';

class CommentModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoURL;
  final String text;
  final FeedAttachment? attachment;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    required this.text,
    this.attachment,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CommentModel(
      id: id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoURL: data['authorPhotoURL'],
      text: data['text'] ?? '',
      attachment: data['attachment'] is Map<String, dynamic>
          ? FeedAttachment.fromMap(data['attachment'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorUid': authorUid,
    'authorName': authorName,
    'authorPhotoURL': authorPhotoURL,
    'text': text,
    if (attachment != null) 'attachment': attachment!.toMap(),
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
