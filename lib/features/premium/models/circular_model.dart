import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum CircularPriority {
  urgent('Urgente', AppColors.error, Icons.warning_amber),
  info('Informativo', AppColors.info, Icons.info_outline),
  requiresAck('Requiere firma', Color(0xFF8B5CF6), Icons.draw),
  general('General', AppColors.success, Icons.check_circle_outline);

  final String label;
  final Color color;
  final IconData icon;
  const CircularPriority(this.label, this.color, this.icon);

  static CircularPriority fromString(String value) {
    return CircularPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CircularPriority.general,
    );
  }
}

class ReadReceipt {
  final String uid;
  final DateTime timestamp;

  const ReadReceipt({required this.uid, required this.timestamp});

  factory ReadReceipt.fromMap(Map<String, dynamic> map) {
    return ReadReceipt(
      uid: map['uid'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ReadReceipt.fromRaw(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return ReadReceipt.fromMap(raw);
    }
    if (raw is Map) {
      return ReadReceipt.fromMap(Map<String, dynamic>.from(raw));
    }
    if (raw is String) {
      return ReadReceipt(uid: raw, timestamp: DateTime.now());
    }
    return ReadReceipt(uid: '', timestamp: DateTime.now());
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}

class CircularModel {
  final String id;
  final String title;
  final String body;
  final List<String> attachmentURLs;
  final String authorUid;
  final String authorName;
  final CircularPriority priority;
  final List<ReadReceipt> readBy;
  final bool requiresAck;
  final List<ReadReceipt> ackBy;
  final DateTime createdAt;

  const CircularModel({
    required this.id,
    required this.title,
    required this.body,
    this.attachmentURLs = const [],
    required this.authorUid,
    required this.authorName,
    this.priority = CircularPriority.general,
    this.readBy = const [],
    this.requiresAck = false,
    this.ackBy = const [],
    required this.createdAt,
  });

  factory CircularModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CircularModel(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      attachmentURLs: List<String>.from(data['attachmentURLs'] ?? []),
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      priority: CircularPriority.fromString(data['priority'] ?? 'general'),
      readBy:
          (data['readBy'] as List?)?.map(ReadReceipt.fromRaw).toList() ?? [],
      requiresAck: data['requiresAck'] ?? false,
      ackBy: (data['ackBy'] as List?)?.map(ReadReceipt.fromRaw).toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'body': body,
    'attachmentURLs': attachmentURLs,
    'authorUid': authorUid,
    'authorName': authorName,
    'priority': priority.name,
    'readBy': readBy.map((e) => e.toMap()).toList(),
    'requiresAck': requiresAck,
    'ackBy': ackBy.map((e) => e.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool isReadBy(String uid) => readBy.any((r) => r.uid == uid);
  bool isAckedBy(String uid) => ackBy.any((r) => r.uid == uid);

  double readPercentage(int totalMembers) {
    if (totalMembers == 0) return 0;
    return readBy.length / totalMembers;
  }

  double ackPercentage(int totalMembers) {
    if (totalMembers == 0) return 0;
    return ackBy.length / totalMembers;
  }
}
