import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/notifications/models/notification_model.dart';
import 'package:vecindario_app/features/notifications/providers/notification_providers.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(markAllReadProvider)(),
              child: const Text('Marcar todas'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Sin notificaciones',
              subtitle: 'Aquí aparecerán las novedades de tu comunidad',
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (_, i) => _NotificationTile(
              notification: notifications[i],
              onTap: () {
                // Marcar como leída
                if (!notifications[i].read) {
                  ref.read(markAsReadProvider)(notifications[i].id);
                }
                // Navegar si tiene ruta
                final route = notifications[i].route;
                if (route != null) {
                  context.push(route);
                }
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.post:
        return Icons.article;
      case NotificationType.comment:
        return Icons.chat_bubble;
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.circular:
        return Icons.campaign;
      case NotificationType.fine:
        return Icons.gavel;
      case NotificationType.pqrs:
        return Icons.assignment;
      case NotificationType.booking:
        return Icons.event;
      case NotificationType.assembly:
        return Icons.how_to_vote;
      case NotificationType.approval:
        return Icons.person_add;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.post:
        return AppColors.primary;
      case NotificationType.comment:
        return AppColors.info;
      case NotificationType.order:
        return AppColors.success;
      case NotificationType.circular:
        return AppColors.warning;
      case NotificationType.fine:
        return AppColors.error;
      case NotificationType.pqrs:
        return AppColors.primary;
      case NotificationType.booking:
        return const Color(0xFF06B6D4);
      case NotificationType.assembly:
        return const Color(0xFF8B5CF6);
      case NotificationType.approval:
        return AppColors.success;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.read
              ? null
              : AppColors.primary.withValues(alpha: 0.04),
          border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: notification.read
                                ? FontWeight.w400
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(notification.createdAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _iconColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      notification.type.label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: _iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
