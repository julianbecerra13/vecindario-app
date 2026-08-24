import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/services/widgets/rating_stars.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({required this.serviceId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.serviceDetailTitle)),
      body: serviceAsync.when(
        data: (service) {
          if (service == null) {
            return Center(child: Text(context.l10n.serviceNotFound));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imágenes
                if (service.imageURLs.isNotEmpty)
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      color: context.colors.background,
                    ),
                    child: PageView.builder(
                      itemCount: service.imageURLs.length,
                      itemBuilder: (_, i) => Image.network(
                        service.imageURLs[i],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSizes.lg),

                // Categoría
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: service.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service.category.icon,
                        size: 14,
                        color: service.category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: service.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Título
                Text(service.title, style: AppTextStyles.heading2),
                const SizedBox(height: AppSizes.sm),

                // Rating y contador
                Row(
                  children: [
                    RatingStars(rating: service.rating, size: 16),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      '${service.rating.toStringAsFixed(1)} (${service.ratingCount})',
                      style: AppTextStyles.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.serviceOrdersCount(service.orderCount),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Precio
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.servicePriceHeading,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        service.displayPrice,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Descripción
                Text(
                  context.l10n.serviceDescriptionLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(service.description, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSizes.lg),

                // Información del prestador
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      if (service.ownerPhotoURL != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(service.ownerPhotoURL!),
                          radius: 28,
                        )
                      else
                        const CircleAvatar(
                          child: Icon(Icons.person),
                          radius: 28,
                        ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.ownerName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.serviceProviderLabel,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorWithDetail('$e'))),
      ),
    );
  }
}
