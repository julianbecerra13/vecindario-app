import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/constants/app_strings.dart';
import 'package:vecindario_app/core/extensions/string_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/services/widgets/rating_stars.dart';
import 'package:vecindario_app/features/feed/widgets/image_carousel.dart';
import 'package:vecindario_app/shared/models/review_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';

final serviceDetailProvider =
    FutureProvider.family<ServiceModel?, String>((ref, serviceId) {
  return ref.watch(servicesRepositoryProvider).getService(serviceId);
});

final serviceReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, serviceId) {
  return ref.watch(servicesRepositoryProvider).watchServiceReviews(serviceId);
});

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  Future<void> _contactWhatsApp(String phone, String title) async {
    final number = phone.whatsappNumber;
    final message = Uri.encodeComponent(AppStrings.whatsappServiceMessage(title));
    final url = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));
    final reviewsAsync = ref.watch(serviceReviewsProvider(serviceId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: serviceAsync.when(
        data: (service) {
          if (service == null) {
            return const Center(child: Text('Servicio no encontrado'));
          }
          final isOwner = currentUser?.id == service.ownerUid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imágenes o placeholder
                if (service.imageURLs.isNotEmpty)
                  ImageCarousel(imageUrls: service.imageURLs, height: 250)
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: service.category.color.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        service.category.icon,
                        size: 64,
                        color: service.category.color,
                      ),
                    ),
                  ),

                Padding(
                  padding: AppSizes.paddingAll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y categoría
                      Text(service.title, style: AppTextStyles.heading2),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: AppSizes.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: service.category.color
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(service.category.icon,
                                    size: 14, color: service.category.color),
                                const SizedBox(width: 4),
                                Text(
                                  service.category.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: service.category.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Text(
                            service.displayPrice,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Rating
                      Row(
                        children: [
                          RatingStars(
                            rating: service.rating,
                            size: 20,
                            showCount: service.ratingCount,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Descripción
                      Text(service.description, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSizes.lg),

                      // Ofrecido por
                      Container(
                        padding: AppSizes.paddingCard,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLg),
                        ),
                        child: Row(
                          children: [
                            CachedAvatar(
                              imageUrl: service.ownerPhotoURL,
                              name: service.ownerName,
                              radius: 20,
                            ),
                            const SizedBox(width: AppSizes.md),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ofrecido por',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                  ),
                                ),
                                Text(
                                  service.ownerName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Botón WhatsApp
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () => _contactWhatsApp(
                            currentUser?.phone ?? '',
                            service.title,
                          ),
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text('Contactar por WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                          ),
                        ),
                      ),

                      // Acciones del dueño
                      if (isOwner) ...[
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Editar'),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  final confirm = await showConfirmDialog(
                                    context,
                                    title: 'Eliminar servicio',
                                    message:
                                        '¿Estás seguro de eliminar este servicio?',
                                    confirmText: 'Eliminar',
                                    isDestructive: true,
                                  );
                                  if (confirm) {
                                    await ref
                                        .read(servicesRepositoryProvider)
                                        .deleteService(serviceId);
                                    if (context.mounted) {
                                      context.showSuccessSnackBar(
                                          'Servicio eliminado');
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side:
                                      const BorderSide(color: AppColors.error),
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Reseñas
                      const SizedBox(height: AppSizes.xl),
                      Text('Reseñas', style: AppTextStyles.heading3),
                      const SizedBox(height: AppSizes.md),
                      reviewsAsync.when(
                        data: (reviews) {
                          if (reviews.isEmpty) {
                            return const Text(
                              'Sin reseñas aún',
                              style: TextStyle(color: AppColors.textHint),
                            );
                          }
                          return Column(
                            children: reviews
                                .map((r) => _ReviewTile(review: r))
                                .toList(),
                          );
                        },
                        loading: () => const LoadingIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedAvatar(
            imageUrl: review.authorPhotoURL,
            name: review.authorName,
            radius: 16,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.authorName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    RatingStars(rating: review.rating, size: 12),
                  ],
                ),
                Text(review.comment, style: AppTextStyles.bodySmall),
                Text(
                  review.createdAt.timeAgoText,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
