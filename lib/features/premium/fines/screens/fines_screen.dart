import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/empty_state.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

/// Pantalla de multas - dos capas:
/// Admin: ve todas las multas, puede crear, confirmar, anular
/// Residente: ve solo sus multas, puede presentar descargos
class FinesScreen extends ConsumerWidget {
  const FinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final finesAsync = isAdmin
        ? ref.watch(allFinesProvider)
        : ref.watch(myFinesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Gestión de Multas' : 'Mis Multas')),
      body: finesAsync.when(
        data: (fines) {
          if (fines.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle_outline,
              title: isAdmin ? 'Sin multas registradas' : 'Sin multas',
              subtitle: isAdmin
                  ? 'Las multas que registres aparecerán aquí'
                  : 'No tienes multas pendientes',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: fines.length,
            itemBuilder: (_, i) => _FineCard(fine: fines[i], isAdmin: isAdmin),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _FineCard extends ConsumerWidget {
  final FineModel fine;
  final bool isAdmin;

  const _FineCard({required this.fine, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: fine.status.color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: AppSizes.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(fine.status.icon, color: fine.status.color, size: 20),
                const SizedBox(width: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: fine.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    fine.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: fine.status.color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  formatCOP(fine.amount),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            // Apto
            Text('Apto ${fine.unitNumber}', style: AppTextStyles.caption),
            const SizedBox(height: AppSizes.xs),
            // Motivo
            Text(
              fine.reason,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (fine.manualArticle != null) ...[
              const SizedBox(height: AppSizes.xs),
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 14,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      fine.manualArticle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Descargo del residente
            if (fine.defenseText != null) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descargo del residente',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(fine.defenseText!, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSizes.sm),
            Text(fine.createdAt.smartDate, style: AppTextStyles.caption),
            // Acciones
            if (fine.daysLeftForDefense != null &&
                fine.canDefend &&
                !isAdmin) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                '⏱ ${fine.daysLeftForDefense} días para presentar descargo',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSizes.sm),
            // Botones
            if (!isAdmin && fine.canDefend && fine.defenseText == null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showDefenseDialog(context, ref),
                  child: const Text('Presentar descargo'),
                ),
              ),
            if (isAdmin && fine.status == FineStatus.defense)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final communityId = ref.read(
                          currentCommunityIdProvider,
                        );
                        if (communityId != null) {
                          ref
                              .read(premiumRepositoryProvider)
                              .updateFineStatus(
                                communityId,
                                fine.id,
                                FineStatus.confirmed,
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Confirmar multa'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final communityId = ref.read(
                          currentCommunityIdProvider,
                        );
                        if (communityId != null) {
                          ref
                              .read(premiumRepositoryProvider)
                              .updateFineStatus(
                                communityId,
                                fine.id,
                                FineStatus.voided,
                              );
                        }
                      },
                      child: const Text('Anular'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDefenseDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Presentar descargo'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Escribe tu versión de los hechos...',
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
                ref
                    .read(premiumRepositoryProvider)
                    .submitDefense(
                      communityId,
                      fine.id,
                      controller.text.trim(),
                    );
              }
              Navigator.pop(ctx);
              context.showSuccessSnackBar('Descargo enviado');
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
