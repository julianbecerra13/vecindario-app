import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

enum ServiceCategory {
  comida('Comida', Icons.restaurant, AppColors.categoryComida),
  belleza('Belleza', Icons.spa, AppColors.categoryBelleza),
  tecnologia('Tecnología', Icons.computer, AppColors.categoryTecnologia),
  mascotas('Mascotas', Icons.pets, AppColors.categoryMascotas),
  hogar('Hogar', Icons.home_repair_service, AppColors.categoryHogar),
  manualidades('Manualidades', Icons.handyman, AppColors.categoryManualidades),
  salud('Salud', Icons.health_and_safety, AppColors.categorySalud),
  ropa('Ropa', Icons.checkroom, AppColors.categoryRopa);

  final String label;
  final IconData icon;
  final Color color;
  const ServiceCategory(this.label, this.icon, this.color);

  static ServiceCategory fromString(String value) {
    return ServiceCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServiceCategory.hogar,
    );
  }
}

class ServiceModel {
  final String id;
  final String ownerUid;
  final String communityId;
  final String title;
  final String description;
  final ServiceCategory category;
  final double? price;
  final String? priceDescription;
  final List<String> imageURLs;
  final double rating;
  final int ratingCount;
  final int orderCount;
  final bool active;
  final String ownerName;
  final String? ownerPhotoURL;
  final DateTime createdAt;

  const ServiceModel({
    required this.id,
    required this.ownerUid,
    required this.communityId,
    required this.title,
    required this.description,
    required this.category,
    this.price,
    this.priceDescription,
    this.imageURLs = const [],
    this.rating = 0,
    this.ratingCount = 0,
    this.orderCount = 0,
    this.active = true,
    required this.ownerName,
    this.ownerPhotoURL,
    required this.createdAt,
  });

  factory ServiceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      ownerUid: data['ownerUid'] ?? '',
      communityId: data['communityId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ServiceCategory.fromString(data['category'] ?? 'hogar'),
      price: (data['price'] as num?)?.toDouble(),
      priceDescription: data['priceDescription'],
      imageURLs: List<String>.from(data['imageURLs'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      orderCount: data['orderCount'] ?? 0,
      active: data['active'] ?? true,
      ownerName: data['ownerName'] ?? '',
      ownerPhotoURL: data['ownerPhotoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'ownerUid': ownerUid,
    'communityId': communityId,
    'title': title,
    'description': description,
    'category': category.name,
    'price': price,
    'priceDescription': priceDescription,
    'imageURLs': imageURLs,
    'rating': rating,
    'ratingCount': ratingCount,
    'orderCount': orderCount,
    'active': active,
    'ownerName': ownerName,
    'ownerPhotoURL': ownerPhotoURL,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  String get displayPrice {
    if (price != null) return '\$${price!.toStringAsFixed(0)} COP';
    if (priceDescription != null) return priceDescription!;
    return 'Consultar precio';
  }
}
