import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  resident('Residente'),
  admin('Administrador'),
  superAdmin('Super Admin'),
  storeOwner('Tienda'),
  external_('Servicio externo');

  final String label;
  const UserRole(this.label);

  static UserRole fromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      case 'store_owner':
        return UserRole.storeOwner;
      case 'external':
        return UserRole.external_;
      default:
        return UserRole.resident;
    }
  }

  String toValue() {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.storeOwner:
        return 'store_owner';
      case UserRole.external_:
        return 'external';
      default:
        return 'resident';
    }
  }
}

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String? photoURL;
  final String? communityId;
  final UserRole role;
  final int? estrato;
  final bool verified;
  final String? tower;
  final String? apartment;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.phone,
    this.photoURL,
    this.communityId,
    this.role = UserRole.resident,
    this.estrato,
    this.verified = false,
    this.tower,
    this.apartment,
    required this.createdAt,
    this.deletedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoURL: data['photoURL'],
      communityId: data['communityId'],
      role: UserRole.fromString(data['role'] ?? 'resident'),
      estrato: data['estrato'],
      verified: data['verified'] ?? false,
      tower: data['tower'],
      apartment: data['apartment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'photoURL': photoURL,
      'communityId': communityId,
      'role': role.toValue(),
      'estrato': estrato,
      'verified': verified,
      'tower': tower,
      'apartment': apartment,
      'createdAt': Timestamp.fromDate(createdAt),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? photoURL,
    String? communityId,
    UserRole? role,
    int? estrato,
    bool? verified,
    String? tower,
    String? apartment,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      communityId: communityId ?? this.communityId,
      role: role ?? this.role,
      estrato: estrato ?? this.estrato,
      verified: verified ?? this.verified,
      tower: tower ?? this.tower,
      apartment: apartment ?? this.apartment,
      createdAt: createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  String get unitInfo {
    if (tower != null && apartment != null) {
      return 'Torre $tower - Apto $apartment';
    }
    return '';
  }
}
