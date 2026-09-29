import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorPassModel {
  const VisitorPassModel({
    required this.id,
    required this.visitorName,
    required this.validFrom,
    required this.expiresAt,
    required this.used,
  });
  final String id;
  final String visitorName;
  final DateTime validFrom;
  final DateTime expiresAt;
  final bool used;

  factory VisitorPassModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return VisitorPassModel(
      id: doc.id,
      visitorName: data['visitorName'] as String? ?? '',
      validFrom: (data['validFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      used: data['used'] as bool? ?? false,
    );
  }

  bool get isActive =>
      !used &&
      validFrom.isBefore(DateTime.now()) &&
      expiresAt.isAfter(DateTime.now());
}
