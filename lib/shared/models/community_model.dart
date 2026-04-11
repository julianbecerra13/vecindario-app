import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final int estrato;
  final String adminUid;
  final String inviteCode;
  final int memberCount;
  final DateTime createdAt;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.estrato,
    required this.adminUid,
    required this.inviteCode,
    this.memberCount = 0,
    required this.createdAt,
  });

  factory CommunityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CommunityModel(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      estrato: data['estrato'] ?? 3,
      adminUid: data['adminUid'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'estrato': estrato,
      'adminUid': adminUid,
      'inviteCode': inviteCode,
      'memberCount': memberCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommunityModel copyWith({
    String? name,
    String? address,
    String? city,
    int? estrato,
    String? inviteCode,
    int? memberCount,
  }) {
    return CommunityModel(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      estrato: estrato ?? this.estrato,
      adminUid: adminUid,
      inviteCode: inviteCode ?? this.inviteCode,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt,
    );
  }

  int get serviceFee {
    const fees = [200, 200, 300, 350, 450, 500];
    if (estrato < 1 || estrato > 6) return 300;
    return fees[estrato - 1];
  }

  String get estratoLabel {
    const labels = [
      'Bajo-bajo',
      'Bajo',
      'Medio-bajo',
      'Medio',
      'Medio-alto',
      'Alto',
    ];
    if (estrato < 1 || estrato > 6) return 'N/A';
    return 'Estrato $estrato - ${labels[estrato - 1]}';
  }
}
