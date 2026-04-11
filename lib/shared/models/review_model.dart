import 'package:cloud_firestore/cloud_firestore.dart';

enum ReviewTargetType {
  service,
  store,
  external_;

  static ReviewTargetType fromString(String value) {
    switch (value) {
      case 'store':
        return ReviewTargetType.store;
      case 'external':
        return ReviewTargetType.external_;
      default:
        return ReviewTargetType.service;
    }
  }

  String toValue() {
    switch (this) {
      case ReviewTargetType.external_:
        return 'external';
      default:
        return name;
    }
  }
}

class ReviewModel {
  final String id;
  final String targetId;
  final ReviewTargetType targetType;
  final String authorUid;
  final String authorName;
  final String? authorPhotoURL;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoURL,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      targetId: data['targetId'] ?? '',
      targetType: ReviewTargetType.fromString(data['targetType'] ?? 'service'),
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoURL: data['authorPhotoURL'],
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'targetId': targetId,
      'targetType': targetType.toValue(),
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoURL': authorPhotoURL,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
