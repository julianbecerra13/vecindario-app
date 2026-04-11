import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/features/stores/providers/orders_provider.dart';
import 'package:vecindario_app/features/stores/widgets/order_timeline.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Estado del Pedido')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Pedido no encontrado'));
          }
          return SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              children: [
                const SizedBox(height: AppSizes.md),
                Icon(
                  order.status.icon,
                  size: 56,
                  color: order.status.color,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Pedido #${order.id.substring(0, 4).toUpperCase()}',
                  style: AppTextStyles.heading3,
                ),
                Text(
                  order.storeName,
                  style: AppTextStyles.bodySmall,
                ),
                if (order.status == OrderStatus.cancelled)
                  Container(
                    margin: const EdgeInsets.only(top: AppSizes.md),
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Text(
                      'Este pedido fue cancelado',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                const SizedBox(height: AppSizes.xl),
                // Timeline
                if (order.status != OrderStatus.cancelled)
                  OrderTimeline(order: order),
                const SizedBox(height: AppSizes.lg),
                // Resumen
                Container(
                  width: double.infinity,
                  padding: AppSizes.paddingCard,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ...order.items.map((item) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSizes.xs),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.name} x${item.quantity}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  formatCOP(item.total),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: AppSizes.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Servicio',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                          Text(
                            formatCOP(order.serviceFee),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            formatCOP(order.total),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
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
