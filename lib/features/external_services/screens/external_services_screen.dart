import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/external_services/models/external_service_model.dart';
import 'package:vecindario_app/features/external_services/providers/external_services_provider.dart';
import 'package:vecindario_app/features/services/widgets/rating_stars.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/error_display.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class ExternalServicesScreen extends ConsumerWidget {
  const ExternalServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(externalServicesListProvider);
    final selectedCategory = ref.watch(externalCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body: Column(
        children: [
          // Chips de categoría
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: selectedCategory == null,
                    onSelected: (_) =>
                        ref.read(externalCategoryProvider.notifier).state =
                            null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedCategory == null
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                ...ExternalCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon, size: 14),
                          const SizedBox(width: 4),
                          Text(cat.label),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) =>
                          ref.read(externalCategoryProvider.notifier).state =
                              isSelected ? null : cat,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Aviso de recomendados por vecinos
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Estos servicios son recomendados por vecinos — no son residentes del conjunto.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return const EmptyState(
                    icon: Icons.build_outlined,
                    title: 'Sin servicios aún',
                    subtitle:
                        'Recomienda un profesional de confianza a tu comunidad',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  itemCount: services.length,
                  itemBuilder: (_, i) =>
                      _ExternalServiceCard(service: services[i]),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorDisplay(
                message: 'Error al cargar servicios',
                onRetry: () => ref.invalidate(externalServicesListProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'external_services_fab',
        onPressed: () => context.push('/external-services/recommend'),
        icon: const Icon(Icons.recommend),
        label: const Text('Recomendar'),
      ),
    );
  }
}

class _ExternalServiceCard extends StatelessWidget {
  final ExternalServiceModel service;

  const _ExternalServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: service.sponsored
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
            )
          : null,
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(service.category.icon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (service.sponsored)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'SPONSOR',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        service.category.label,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                service.description,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                RatingStars(
                  rating: service.rating,
                  size: 14,
                  showCount: service.reviewCount,
                ),
                const Spacer(),
                if (service.recommendedByName != null)
                  Text(
                    'Rec. por ${service.recommendedByName}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                    ),
                  ),
              ],
            ),
            if (service.phone.isNotEmpty) ...[
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('tel:${service.phone}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text('Llamar · ${service.phone}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    side: BorderSide(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
