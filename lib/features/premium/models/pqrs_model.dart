import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum PqrsType {
  petition('Petición', AppColors.info, Icons.request_page),
  complaint('Queja', AppColors.error, Icons.report_problem),
  claim('Reclamo', AppColors.error, Icons.assignment_late),
  suggestion('Sugerencia', AppColors.success, Icons.lightbulb);

  final String label;
  final Color color;
  final IconData icon;
  const PqrsType(this.label, this.color, this.icon);

  static PqrsType fromString(String value) {
    return PqrsType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PqrsType.petition,
    );
  }
}

enum PqrsStatus {
  received('Recibido', AppColors.warning),
  inProgress('En gestión', AppColors.info),
  resolved('Resuelto', AppColors.success),
  closed('Cerrado', AppColors.textHint);

  final String label;
  final Color color;
  const PqrsStatus(this.label, this.color);

  static PqrsStatus fromString(String value) {
    return PqrsStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PqrsStatus.received,
    );
  }
}

enum PqrsCategory {
  maintenance('Mantenimiento', Icons.build),
  security('Seguridad', Icons.security),
  coexistence('Convivencia', Icons.people),
  commonAreas('Zonas comunes', Icons.park),
  administration('Administración', Icons.business);

  final String label;
  final IconData icon;
  const PqrsCategory(this.label, this.icon);

  static PqrsCategory fromString(String value) {
    return PqrsCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PqrsCategory.maintenance,
    );
  }
}

class PqrsModel {
  final String id;
  final PqrsType type;
  final PqrsCategory category;
  final String description;
  final List<String> photoURLs;
  final String? assignedTo;
  final PqrsStatus status;
  final String residentUid;
  final String residentName;
  final String? residentUnit;
  final DateTime? slaDeadline;
  final DateTime? resolvedAt;
  final String? response;
  final DateTime createdAt;

  const PqrsModel({
    required this.id,
    required this.type,
    required this.category,
    required this.description,
    this.photoURLs = const [],
    this.assignedTo,
    this.status = PqrsStatus.received,
    required this.residentUid,
    required this.residentName,
    this.residentUnit,
    this.slaDeadline,
    this.resolvedAt,
    this.response,
    required this.createdAt,
  });

  factory PqrsModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PqrsModel(
      id: id,
      type: PqrsType.fromString(data['type'] ?? 'petition'),
      category: PqrsCategory.fromString(data['category'] ?? 'maintenance'),
      description: data['description'] ?? '',
      photoURLs: List<String>.from(data['photoURLs'] ?? []),
      assignedTo: data['assignedTo'],
      status: PqrsStatus.fromString(data['status'] ?? 'received'),
      residentUid: data['residentUid'] ?? '',
      residentName: data['residentName'] ?? '',
      residentUnit: data['residentUnit'],
      slaDeadline: (data['slaDeadline'] as Timestamp?)?.toDate(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      response: data['response'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'category': category.name,
    'description': description,
    'photoURLs': photoURLs,
    'assignedTo': assignedTo,
    'status': status.name,
    'residentUid': residentUid,
    'residentName': residentName,
    'residentUnit': residentUnit,
    if (slaDeadline != null) 'slaDeadline': Timestamp.fromDate(slaDeadline!),
    if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    'response': response,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool get isOverdue =>
      slaDeadline != null &&
      DateTime.now().isAfter(slaDeadline!) &&
      status != PqrsStatus.resolved &&
      status != PqrsStatus.closed;
}
