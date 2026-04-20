import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FineDetailScreen extends ConsumerStatefulWidget {
  final String fineId;

  const FineDetailScreen({super.key, required this.fineId});

  @override
  ConsumerState<FineDetailScreen> createState() => _FineDetailScreenState();
}

class _FineDetailScreenState extends ConsumerState<FineDetailScreen> {
  final _defenseController = TextEditingController();

  @override
  void dispose() {
    _defenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fineAsync = ref.watch(fineDetailProvider(widget.fineId));
    final isAdmin = ref.watch(isAdminProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Multa')),
      body: fineAsync.when(
        data: (fine) {
          if (fine == null) {
            return const Center(child: Text('Multa no encontrada'));
          }
          return SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado y monto
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: fine.status.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: fine.status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm,
                              vertical: AppSizes.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: fine.status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  fine.status.icon,
                                  size: 14,
                                  color: fine.status.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fine.status.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: fine.status.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Multa #${fine.id.substring(0, 6)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        '\$${fine.amount}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(fine.unitNumber, style: AppTextStyles.caption),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Motivo
                Text('Motivo', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.sm),
                Text(fine.reason, style: AppTextStyles.bodyLarge),

                // Artículo del manual
                if (fine.manualArticle != null &&
                    fine.manualArticle!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Text('Artículo del manual', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      fine.manualArticle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],

                // Evidencia
                if (fine.evidenceURLs.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.lg),
                  Text('Evidencia', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSizes.sm),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: fine.evidenceURLs.length,
                      itemBuilder: (_, i) => Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: AppSizes.sm),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: fine.evidenceURLs[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Descargo del residente
                if (fine.canDefend) ...[
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Descargo', style: AppTextStyles.heading3),
                      if (fine.daysLeftForDefense != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: AppSizes.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: fine.daysLeftForDefense! <= 1
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            '${fine.daysLeftForDefense} días restantes',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: fine.daysLeftForDefense! <= 1
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (fine.defenseText != null &&
                      fine.defenseText!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        fine.defenseText!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ] else if (!isAdmin) ...[
                    TextField(
                      controller: _defenseController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu descargo aquí...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitDefense(fine),
                        child: const Text('Enviar descargo'),
                      ),
                    ),
                  ],
                ],

                // Acciones del admin
                if (isAdmin &&
                    (fine.status == FineStatus.defense ||
                        fine.status == FineStatus.notified)) ...[
                  const SizedBox(height: AppSizes.xl),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _confirmFine(fine),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Confirmar Multa'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _voidFine(fine),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.success,
                            side: const BorderSide(color: AppColors.success),
                          ),
                          child: const Text('Anular'),
                        ),
                      ),
                    ],
                  ),
                ],

                // Botón de pago
                if (fine.canPay && !isAdmin) ...[
                  const SizedBox(height: AppSizes.xl),
                  PaymentButton(
                    label: 'Pagar multa',
                    amountCOP: fine.amount,
                    reference: PaymentService.generateReference(
                      PaymentType.fine,
                      fine.id,
                    ),
                    type: PaymentType.fine,
                    customerEmail: currentUser?.email ?? '',
                  ),
                ],

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _submitDefense(FineModel fine) async {
    final text = _defenseController.text.trim();
    if (text.isEmpty) {
      context.showErrorSnackBar('Escribe tu descargo');
      return;
    }
    await ref.read(premiumRepositoryProvider).updateFine(fine.id, {
      'defenseText': text,
      'status': 'defense',
    });
    if (mounted) {
      context.showSuccessSnackBar('Descargo enviado');
    }
  }

  Future<void> _confirmFine(FineModel fine) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Confirmar multa',
      message: '¿Confirmar la multa de \$${fine.amount}?',
      confirmText: 'Confirmar',
      isDestructive: true,
    );
    if (confirm) {
      await ref.read(premiumRepositoryProvider).updateFine(fine.id, {
        'status': 'confirmed',
      });
    }
  }

  Future<void> _voidFine(FineModel fine) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Anular multa',
      message: '¿Estás seguro de anular esta multa?',
      confirmText: 'Anular',
    );
    if (confirm) {
      await ref.read(premiumRepositoryProvider).updateFine(fine.id, {
        'status': 'voided',
      });
    }
  }
}
