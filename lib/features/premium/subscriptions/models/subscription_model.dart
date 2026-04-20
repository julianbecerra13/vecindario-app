import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan {
  starter('starter', 'Starter', 150000),
  professional('professional', 'Profesional', 350000),
  enterprise('enterprise', 'Enterprise', 600000);

  final String value;
  final String label;
  final int priceCOP;
  const SubscriptionPlan(this.value, this.label, this.priceCOP);

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (p) => p.value == value,
      orElse: () => SubscriptionPlan.starter,
    );
  }
}

enum SubscriptionStatus {
  trial('trial', 'Periodo de prueba'),
  active('active', 'Activa'),
  expired('expired', 'Expirada'),
  cancelled('cancelled', 'Cancelada');

  final String value;
  final String label;
  const SubscriptionStatus(this.value, this.label);

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }
}

class SubscriptionModel {
  final String communityId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime trialStartedAt;
  final DateTime trialEndsAt;
  final DateTime createdAt;
  final String createdBy;

  const SubscriptionModel({
    required this.communityId,
    required this.plan,
    required this.status,
    required this.trialStartedAt,
    required this.trialEndsAt,
    required this.createdAt,
    required this.createdBy,
  });

  factory SubscriptionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return SubscriptionModel(
      communityId: id,
      plan: SubscriptionPlan.fromString(data['plan'] ?? 'starter'),
      status: SubscriptionStatus.fromString(data['status'] ?? 'expired'),
      trialStartedAt:
          (data['trialStartedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trialEndsAt:
          (data['trialEndsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'plan': plan.value,
    'status': status.value,
    'trialStartedAt': Timestamp.fromDate(trialStartedAt),
    'trialEndsAt': Timestamp.fromDate(trialEndsAt),
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
  };

  bool get isActive {
    if (status == SubscriptionStatus.active) return true;
    if (status == SubscriptionStatus.trial) {
      return DateTime.now().isBefore(trialEndsAt);
    }
    return false;
  }

  int get daysLeftInTrial {
    if (status != SubscriptionStatus.trial) return 0;
    final diff = trialEndsAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
}
