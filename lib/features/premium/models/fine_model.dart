import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum FineStatus {
  notified('Notificada', AppColors.warning, Icons.notifications_active),
  defense('En descargo', Color(0xFFFF9800), Icons.gavel),
  confirmed('Confirmada', AppColors.error, Icons.check_circle),
  paid('Pagada', AppColors.success, Icons.paid),
  voided('Anulada', AppColors.textHint, Icons.cancel);

  final String label;
  final Color color;
  final IconData icon;
  const FineStatus(this.label, this.color, this.icon);

  static FineStatus fromString(String value) {
    return FineStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FineStatus.notified,
    );
  }
}

class FineModel {
  final String id;
  final String unitNumber;
  final String? residentUid;
  final int amount;
  final String reason;
  final String? manualArticle;
  final List<String> evidenceURLs;
  final FineStatus status;
  final String? defenseText;
  final DateTime? defenseDeadline;
  final DateTime createdAt;

  const FineModel({
    required this.id,
    required this.unitNumber,
    this.residentUid,
    required this.amount,
    required this.reason,
    this.manualArticle,
    this.evidenceURLs = const [],
    this.status = FineStatus.notified,
    this.defenseText,
    this.defenseDeadline,
    required this.createdAt,
  });

  factory FineModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FineModel(
      id: id,
      unitNumber: data['unitNumber'] ?? '',
      residentUid: data['residentUid'],
      amount: data['amount'] ?? 0,
      reason: data['reason'] ?? '',
      manualArticle: data['manualArticle'],
      evidenceURLs: List<String>.from(data['evidenceURLs'] ?? []),
      status: FineStatus.fromString(data['status'] ?? 'notified'),
      defenseText: data['defenseText'],
      defenseDeadline:
          (data['defenseDeadline'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'unitNumber': unitNumber,
    'residentUid': residentUid,
    'amount': amount,
    'reason': reason,
    'manualArticle': manualArticle,
    'evidenceURLs': evidenceURLs,
    'status': status.name,
    'defenseText': defenseText,
    if (defenseDeadline != null)
      'defenseDeadline': Timestamp.fromDate(defenseDeadline!),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool get canDefend =>
      status == FineStatus.notified || status == FineStatus.defense;

  bool get canPay => status == FineStatus.confirmed;

  int? get daysLeftForDefense {
    if (defenseDeadline == null) return null;
    return defenseDeadline!.difference(DateTime.now()).inDays;
  }
}
