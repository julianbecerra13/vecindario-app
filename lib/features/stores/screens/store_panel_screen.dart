import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

final ownerStoreIdProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return null;

  // Buscar la tienda donde ownerUid == user.id
  final storesRepo = ref.watch(storesRepositoryProvider);
  final stores = await storesRepo.getStoresForOwner(user.id).first;
  return stores.isNotEmpty ? stores.first.id : null;
});

final storeOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  final storeId = ref.watch(ownerStoreIdProvider).value;

  if (user == null || storeId == null) return Stream.value([]);
  return ref.watch(storesRepositoryProvider).watchStoreOrders(storeId);
});

class StorePanelScreen extends ConsumerWidget {
  const StorePanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(storeOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Tienda — Pedidos')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Sin pedidos',
              subtitle: 'Los pedidos de tus clientes aparecerán aquí',
            );
          }

          final pending = orders
              .where((o) => o.status == OrderStatus.pending)
              .toList();
          final active = orders
              .where(
                (o) =>
                    o.status == OrderStatus.confirmed ||
                    o.status == OrderStatus.inTransit,
              )
              .toList();
          final completed = orders
              .where(
                (o) =>
                    o.status == OrderStatus.delivered ||
                    o.status == OrderStatus.cancelled,
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Stats
              Row(
                children: [
                  _StatChip(
                    label: 'Pendientes',
                    count: pending.length,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _StatChip(
                    label: 'Activos',
                    count: active.length,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _StatChip(
                    label: 'Hoy',
                    count: orders
                        .where(
                          (o) =>
                              o.createdAt.day == DateTime.now().day &&
                              o.createdAt.month == DateTime.now().month,
                        )
                        .length,
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              if (pending.isNotEmpty) ...[
                _SectionLabel('Nuevos pedidos (${pending.length})'),
                ...pending.map((o) => _OrderManageCard(order: o)),
                const SizedBox(height: AppSizes.md),
              ],
              if (active.isNotEmpty) ...[
                _SectionLabel('En proceso (${active.length})'),
                ...active.map((o) => _OrderManageCard(order: o)),
                const SizedBox(height: AppSizes.md),
              ],
              if (completed.isNotEmpty) ...[
                _SectionLabel('Completados'),
                ...completed.take(10).map((o) => _OrderManageCard(order: o)),
              ],
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _OrderManageCard extends ConsumerWidget {
  final OrderModel order;

  const _OrderManageCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(order.status.icon, size: 18, color: order.status.color),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    '#${order.id.substring(0, 4).toUpperCase()} — ${order.buyerName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: order.status.color,
                    ),
                  ),
                ),
              ],
            ),
            if (order.buyerApartment != null &&
                order.buyerApartment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  order.buyerApartment!,
                  style: AppTextStyles.caption,
                ),
              ),
            const SizedBox(height: AppSizes.xs),
            Text(
              order.itemsSummary,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCOP(order.total),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(order.createdAt.timeAgoText, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            // Acciones según estado
            if (order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(storesRepositoryProvider)
                          .updateOrderStatus(order.id, OrderStatus.cancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(storesRepositoryProvider)
                          .updateOrderStatus(order.id, OrderStatus.confirmed),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            if (order.status == OrderStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(storesRepositoryProvider)
                      .updateOrderStatus(order.id, OrderStatus.inTransit),
                  icon: const Icon(Icons.delivery_dining, size: 18),
                  label: const Text('Marcar en camino'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            if (order.status == OrderStatus.inTransit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(storesRepositoryProvider)
                      .updateOrderStatus(order.id, OrderStatus.delivered),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Marcar entregado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
