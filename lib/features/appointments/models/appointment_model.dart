import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  requested,
  confirmed,
  rescheduled,
  cancelled,
  completed,
}

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.residentUid,
    required this.residentName,
    required this.scheduledAt,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String residentUid;
  final String residentName;
  final DateTime scheduledAt;
  final String reason;
  final AppointmentStatus status;
  final DateTime createdAt;

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppointmentModel(
      id: doc.id,
      residentUid: data['residentUid'] as String? ?? '',
      residentName: data['residentName'] as String? ?? '',
      scheduledAt:
          (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: data['reason'] as String? ?? '',
      status: AppointmentStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => AppointmentStatus.requested,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get statusLabel => switch (status) {
    AppointmentStatus.requested => 'Solicitada',
    AppointmentStatus.confirmed => 'Confirmada',
    AppointmentStatus.rescheduled => 'Reprogramada',
    AppointmentStatus.cancelled => 'Cancelada',
    AppointmentStatus.completed => 'Realizada',
  };
}
