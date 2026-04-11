import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/features/feed/screens/feed_screen.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

/// Pantalla de circulares - ambas capas:
/// Admin: ve tracking de lectura, puede crear nuevas
/// Residente: ve circulares, marca como leída, firma si requiere
class CircularsScreen extends ConsumerWidget {
  const CircularsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circularsAsync = ref.watch(circularsProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circulares'),
        actions: [
          if (isAdmin)
            TextButton.icon(
              onPressed: () => context.push('/premium/circulars/create'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            ),
        ],
      ),
      body: circularsAsync.when(
        data: (circulars) {
          if (circulars.isEmpty) {
            return const EmptyState(
              icon: Icons.mail_outline,
              title: 'Sin circulares',
              subtitle: 'Los comunicados oficiales aparecerán aquí',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: circulars.length,
            itemBuilder: (_, i) => _CircularCard(
              circular: circulars[i],
              isAdmin: isAdmin,
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CircularCard extends ConsumerWidget {
  final CircularModel circular;
  final bool isAdmin;

  const _CircularCard({required this.circular, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isRead = currentUser != null && circular.isReadBy(currentUser.id);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(
          color: isRead
              ? AppColors.border
              : circular.priority.color.withValues(alpha: 0.3),
          width: isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: () {
          // Marcar como leída al abrir
          if (currentUser != null && !isRead) {
            final communityId = ref.read(currentCommunityIdProvider);
            if (communityId != null) {
              ref.read(premiumRepositoryProvider).markCircularAsRead(
                    communityId,
                    circular.id,
                    currentUser.id,
                  );
            }
          }
        },
        child: Padding(
          padding: AppSizes.paddingCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Badge de prioridad
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: circular.priority.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          circular.priority.icon,
                          size: 12,
                          color: circular.priority.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          circular.priority.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: circular.priority.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    circular.createdAt.timeAgoText,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                circular.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                circular.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSizes.sm),
              // Indicadores
              Row(
                children: [
                  if (circular.attachmentURLs.isNotEmpty)
                    _MetaChip(
                      icon: Icons.attach_file,
                      text: '${circular.attachmentURLs.length} adjunto(s)',
                    ),
                  const Spacer(),
                  if (isAdmin) ...[
                    Builder(builder: (context) {
                      final community = ref.watch(currentCommunityProvider).value;
                      final total = community?.memberCount ?? 1;
                      final readCount = circular.readBy.length;
                      final pct = (readCount / total).clamp(0.0, 1.0);
                      final pctInt = (pct * 100).round();
                      final color = pctInt >= 80
                          ? AppColors.success
                          : pctInt >= 50
                              ? AppColors.warning
                              : AppColors.error;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$pctInt% leído',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.border,
                                color: color,
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ] else if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              // Botón de firma si requiere
              if (circular.requiresAck &&
                  currentUser != null &&
                  !circular.isAckedBy(currentUser.id) &&
                  !isAdmin) ...[
                const SizedBox(height: AppSizes.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final communityId = ref.read(currentCommunityIdProvider);
                      if (communityId != null) {
                        ref.read(premiumRepositoryProvider).acknowledgeCircular(
                              communityId,
                              circular.id,
                              currentUser.id,
                            );
                      }
                    },
                    icon: const Icon(Icons.draw, size: 16),
                    label: const Text('Firmar acuse de recibo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}
