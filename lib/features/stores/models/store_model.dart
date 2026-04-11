import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String ownerUid;
  final String communityId;
  final String name;
  final String description;
  final String? imageURL;
  final String deliveryTime;
  final int minOrder;
  final bool active;
  final double rating;
  final int orderCount;
  final DateTime createdAt;

  const StoreModel({
    required this.id,
    required this.ownerUid,
    required this.communityId,
    required this.name,
    required this.description,
    this.imageURL,
    this.deliveryTime = '15-25 min',
    this.minOrder = 10000,
    this.active = true,
    this.rating = 0,
    this.orderCount = 0,
    required this.createdAt,
  });

  factory StoreModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StoreModel(
      id: id,
      ownerUid: data['ownerUid'] ?? '',
      communityId: data['communityId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageURL: data['imageURL'],
      deliveryTime: data['deliveryTime'] ?? '15-25 min',
      minOrder: data['minOrder'] ?? 10000,
      active: data['active'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      orderCount: data['orderCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'ownerUid': ownerUid,
    'communityId': communityId,
    'name': name,
    'description': description,
    'imageURL': imageURL,
    'deliveryTime': deliveryTime,
    'minOrder': minOrder,
    'active': active,
    'rating': rating,
    'orderCount': orderCount,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  String get formattedMinOrder =>
      '\$${minOrder.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.')}';
}
