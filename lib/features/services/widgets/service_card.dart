import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/widgets/rating_stars.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSizes.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.cardRadius),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: service.imageURLs.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: service.imageURLs.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceVariant),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: service.category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      service.category.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: service.category.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    service.displayPrice,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  RatingStars(
                    rating: service.rating,
                    size: 14,
                    showCount: service.ratingCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: service.category.color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          service.category.icon,
          size: 40,
          color: service.category.color,
        ),
      ),
    );
  }
}
