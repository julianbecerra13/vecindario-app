import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';

class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 20,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceVariant,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, __) => _initialsWidget(),
            errorWidget: (_, __, ___) => _initialsWidget(),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _initialsWidget() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
