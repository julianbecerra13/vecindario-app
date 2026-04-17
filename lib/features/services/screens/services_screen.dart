import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/services/widgets/category_chips.dart';
import 'package:vecindario_app/features/services/widgets/service_card.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/error_display.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesListProvider);
    final currentSort = ref.watch(serviceSortProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar servicio...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(serviceSearchProvider.notifier).state = value;
                },
              )
            : const Text('Servicios Vecinales'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchController.clear();
                ref.read(serviceSearchProvider.notifier).state = '';
              }
            },
          ),
          PopupMenuButton<ServiceSortBy>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (sort) {
              ref.read(serviceSortProvider.notifier).state = sort;
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ServiceSortBy.recent,
                child: Row(
                  children: [
                    if (currentSort == ServiceSortBy.recent)
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                    if (currentSort == ServiceSortBy.recent)
                      const SizedBox(width: 8),
                    const Text('Más recientes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ServiceSortBy.rating,
                child: Row(
                  children: [
                    if (currentSort == ServiceSortBy.rating)
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                    if (currentSort == ServiceSortBy.rating)
                      const SizedBox(width: 8),
                    const Text('Mejor calificación'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ServiceSortBy.popular,
                child: Row(
                  children: [
                    if (currentSort == ServiceSortBy.popular)
                      const Icon(Icons.check, size: 18, color: AppColors.primary),
                    if (currentSort == ServiceSortBy.popular)
                      const SizedBox(width: 8),
                    const Text('Más populares'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSizes.sm),
          const CategoryChips(),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return const EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Sin servicios aún',
                    subtitle: 'Ofrece tus productos o servicios a tu comunidad',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(servicesListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    itemCount: services.length,
                    itemBuilder: (_, i) => ServiceCard(
                      service: services[i],
                      onTap: () =>
                          context.push('/services/${services[i].id}'),
                    ),
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorDisplay(
                message: 'Error al cargar servicios',
                onRetry: () => ref.invalidate(servicesListProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'services_fab',
        onPressed: () => context.push('/services/create'),
        icon: const Icon(Icons.add),
        label: const Text('Ofrecer'),
      ),
    );
  }
}
