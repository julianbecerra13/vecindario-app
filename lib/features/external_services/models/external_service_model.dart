import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ExternalCategory {
  electricista('Electricista', Icons.electrical_services),
  plomero('Plomero', Icons.plumbing),
  cerrajero('Cerrajero', Icons.lock),
  aseo('Aseo', Icons.cleaning_services),
  mudanzas('Mudanzas', Icons.local_shipping),
  pintura('Pintura', Icons.format_paint),
  jardineria('Jardinería', Icons.yard),
  carpinteria('Carpintería', Icons.carpenter);

  final String label;
  final IconData icon;
  const ExternalCategory(this.label, this.icon);

  static ExternalCategory fromString(String value) {
    return ExternalCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExternalCategory.electricista,
    );
  }
}

class ExternalServiceModel {
  final String id;
  final String name;
  final ExternalCategory category;
  final String phone;
  final String description;
  final double rating;
  final int reviewCount;
  final String? recommendedByUid;
  final String? recommendedByName;
  final bool sponsored;
  final bool active;
  final DateTime createdAt;

  const ExternalServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    required this.description,
    this.rating = 0,
    this.reviewCount = 0,
    this.recommendedByUid,
    this.recommendedByName,
    this.sponsored = false,
    this.active = true,
    required this.createdAt,
  });

  factory ExternalServiceModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ExternalServiceModel(
      id: id,
      name: data['name'] ?? '',
      category: ExternalCategory.fromString(data['category'] ?? ''),
      phone: data['phone'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      recommendedByUid: data['recommendedByUid'],
      recommendedByName: data['recommendedByName'],
      sponsored: data['sponsored'] ?? false,
      active: data['active'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category.name,
    'phone': phone,
    'description': description,
    'rating': rating,
    'reviewCount': reviewCount,
    'recommendedByUid': recommendedByUid,
    'recommendedByName': recommendedByName,
    'sponsored': sponsored,
    'active': active,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
