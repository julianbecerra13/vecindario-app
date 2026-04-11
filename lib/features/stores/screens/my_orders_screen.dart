import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/orders_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/error_display.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin pedidos',
              subtitle: 'Tus pedidos a tiendas del barrio aparecerán aquí',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.sm),
                child: ListTile(
                  onTap: () => context.push('/stores/order/${order.id}'),
                  leading: Icon(
                    order.status.icon,
                    color: order.status.color,
                    size: 28,
                  ),
                  title: Text(
                    order.storeName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${order.createdAt.smartDate} \u00b7 ${formatCOP(order.total)}',
                    style: AppTextStyles.caption,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xxs,
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
                ),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar pedidos',
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
      ),
    );
  }
}
