import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/pqrs_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

/// PQRS - dos capas:
/// Admin: ve todos, asigna, responde, cambia estado
/// Residente: ve los suyos, crea nuevos, ve respuestas
class PqrsScreen extends ConsumerWidget {
  const PqrsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final pqrsAsync =
        isAdmin ? ref.watch(allPqrsProvider) : ref.watch(myPqrsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PQRS'),
        actions: [
          if (!isAdmin)
            TextButton.icon(
              onPressed: () => context.push('/premium/pqrs/create'),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Stats (admin)
          if (isAdmin)
            pqrsAsync.when(
              data: (pqrs) => _AdminStats(pqrs: pqrs),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          Expanded(
            child: pqrsAsync.when(
              data: (pqrs) {
                if (pqrs.isEmpty) {
                  return EmptyState(
                    icon: Icons.assignment_outlined,
                    title: isAdmin ? 'Sin PQRS' : 'Sin solicitudes',
                    subtitle: isAdmin
                        ? 'Las solicitudes de residentes aparecerán aquí'
                        : 'Envía peticiones, quejas o sugerencias',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: pqrs.length,
                  itemBuilder: (_, i) => _PqrsCard(
                    pqrs: pqrs[i],
                    isAdmin: isAdmin,
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

}

class _AdminStats extends StatelessWidget {
  final List<PqrsModel> pqrs;

  const _AdminStats({required this.pqrs});

  @override
  Widget build(BuildContext context) {
    final open = pqrs.where((p) => p.status == PqrsStatus.received).length;
    final inProgress =
        pqrs.where((p) => p.status == PqrsStatus.inProgress).length;
    final resolved =
        pqrs.where((p) => p.status == PqrsStatus.resolved).length;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          _StatBadge(label: 'Abiertos', value: '$open', color: AppColors.warning),
          const SizedBox(width: AppSizes.sm),
          _StatBadge(
              label: 'En gestión', value: '$inProgress', color: AppColors.info),
          const SizedBox(width: AppSizes.sm),
          _StatBadge(
              label: 'Resueltos', value: '$resolved', color: AppColors.success),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PqrsCard extends ConsumerWidget {
  final PqrsModel pqrs;
  final bool isAdmin;

  const _PqrsCard({required this.pqrs, required this.isAdmin});

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
                // Badge tipo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pqrs.type.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    pqrs.type.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pqrs.type.color,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                // Categoría
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(pqrs.category.icon, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(pqrs.category.label, style: AppTextStyles.caption),
                  ],
                ),
                const Spacer(),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pqrs.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    pqrs.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: pqrs.status.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              pqrs.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
            if (isAdmin && pqrs.residentUnit != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                '${pqrs.residentName} \u00b7 ${pqrs.residentUnit}',
                style: AppTextStyles.caption,
              ),
            ],
            if (pqrs.response != null) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Respuesta de la administración',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(pqrs.response!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Text(pqrs.createdAt.timeAgoText, style: AppTextStyles.caption),
                if (pqrs.isOverdue) ...[
                  const SizedBox(width: AppSizes.sm),
                  const Text(
                    'SLA vencido',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            // Admin: botón responder
            if (isAdmin &&
                pqrs.status != PqrsStatus.resolved &&
                pqrs.status != PqrsStatus.closed) ...[
              const SizedBox(height: AppSizes.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showRespondDialog(context, ref),
                  child: const Text('Responder'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRespondDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Responder PQRS'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Escribe la respuesta...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              final communityId = ref.read(currentCommunityIdProvider);
              if (communityId != null) {
                ref.read(premiumRepositoryProvider).updatePqrsStatus(
                      communityId,
                      pqrs.id,
                      PqrsStatus.resolved,
                      response: controller.text.trim(),
                    );
              }
              Navigator.pop(ctx);
              context.showSuccessSnackBar('Respuesta enviada');
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
