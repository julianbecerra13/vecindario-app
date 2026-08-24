import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunityRole {
  resident('Residente'),
  admin('Administrador');

  final String label;
  const CommunityRole(this.label);

  static CommunityRole fromString(String value) {
    switch (value) {
      case 'admin':
        return CommunityRole.admin;
      default:
        return CommunityRole.resident;
    }
  }

  String toValue() {
    switch (this) {
      case CommunityRole.admin:
        return 'admin';
      case CommunityRole.resident:
        return 'resident';
    }
  }
}

/// Único valor válido hoy para el rol de plataforma. Vive aparte de
/// [CommunityRole] porque un super_admin no pertenece a ninguna comunidad.
const String kSuperAdminPlatformRole = 'super_admin';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String phone;
  final String? photoURL;
  final String? communityId;
  final CommunityRole communityRole;
  final String? platformRole;
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
    this.communityRole = CommunityRole.resident,
    this.platformRole,
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
      communityRole: CommunityRole.fromString(
        data['communityRole'] ?? 'resident',
      ),
      platformRole: data['platformRole'],
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
      'communityRole': communityRole.toValue(),
      if (platformRole != null) 'platformRole': platformRole,
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
    CommunityRole? communityRole,
    String? platformRole,
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
      communityRole: communityRole ?? this.communityRole,
      platformRole: platformRole ?? this.platformRole,
      estrato: estrato ?? this.estrato,
      verified: verified ?? this.verified,
      tower: tower ?? this.tower,
      apartment: apartment ?? this.apartment,
      createdAt: createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// True solo si el rol dentro de la comunidad es admin.
  bool get isCommunityAdmin => communityRole == CommunityRole.admin;

  /// True solo para el super_admin de plataforma (no pertenece a comunidad).
  bool get isSuperAdmin => platformRole == kSuperAdminPlatformRole;

  /// True si administra el conjunto O es super_admin de plataforma. Úsalo
  /// para mostrar accesos a "Administración" y proteger /premium.
  bool get isAdmin => isCommunityAdmin || isSuperAdmin;

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
