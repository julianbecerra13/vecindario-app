import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';

class OrderTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        title: 'Pedido recibido',
        subtitle: order.createdAt.formatTime,
        isCompleted: true,
      ),
      _TimelineStep(
        title: 'Confirmado por la tienda',
        subtitle: order.confirmedAt?.formatTime,
        isCompleted: order.status.index >= OrderStatus.confirmed.index,
        isCurrent: order.status == OrderStatus.confirmed,
      ),
      _TimelineStep(
        title: 'En camino',
        subtitle: order.status == OrderStatus.inTransit
            ? 'Estimado: 15 min'
            : null,
        isCompleted: order.status.index >= OrderStatus.inTransit.index,
        isCurrent: order.status == OrderStatus.inTransit,
      ),
      _TimelineStep(
        title: 'Entregado',
        subtitle: order.deliveredAt?.formatTime,
        isCompleted: order.status == OrderStatus.delivered,
        isLast: true,
      ),
    ];

    return Column(children: steps.map((step) => _buildStep(step)).toList());
  }

  Widget _buildStep(_TimelineStep step) {
    final Color circleColor;
    final Widget circleChild;

    if (step.isCompleted) {
      circleColor = AppColors.success;
      circleChild = const Icon(Icons.check, size: 12, color: Colors.white);
    } else if (step.isCurrent) {
      circleColor = AppColors.primary;
      circleChild = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      circleColor = AppColors.border;
      circleChild = const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: circleChild,
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 32,
                color: step.isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: step.isCompleted
                        ? AppColors.success
                        : step.isCurrent
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
                if (step.subtitle != null)
                  Text(
                    step.subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final String? subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLast = false,
  });
}
