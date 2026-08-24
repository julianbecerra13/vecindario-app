import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/fine_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateFineScreen extends ConsumerStatefulWidget {
  const CreateFineScreen({super.key});

  @override
  ConsumerState<CreateFineScreen> createState() => _CreateFineScreenState();
}

class _CreateFineScreenState extends ConsumerState<CreateFineScreen> {
  final _unitController = TextEditingController();
  final _reasonController = TextEditingController();
  final _articleController = TextEditingController();
  final _amountController = TextEditingController();
  int _defenseDays = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _unitController.dispose();
    _reasonController.dispose();
    _articleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_unitController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.fineUnitRequired);
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.fineReasonRequired);
      return;
    }
    final amount = int.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', ''),
    );
    if (amount == null || amount <= 0) {
      context.showErrorSnackBar(context.l10n.fineAmountRequired);
      return;
    }

    setState(() => _isLoading = true);
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;

    final fine = FineModel(
      id: '',
      unitNumber: _unitController.text.trim(),
      amount: amount,
      reason: _reasonController.text.trim(),
      manualArticle: _articleController.text.trim().isEmpty
          ? null
          : _articleController.text.trim(),
      status: FineStatus.notified,
      defenseDeadline: DateTime.now().add(Duration(days: _defenseDays)),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(premiumRepositoryProvider).createFine(communityId, fine);
      if (mounted) {
        context.showSuccessSnackBar(context.l10n.fineRegistered);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.errorGeneric(e));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.fineCreateTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: _isLoading ? null : _create,
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.financeRegister),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unidad
            TextField(
              controller: _unitController,
              decoration: InputDecoration(
                labelText: context.l10n.fineUnitFieldLabel,
                hintText: 'Ej: T2-801',
                prefixIcon: const Icon(Icons.home),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSizes.md),

            // Monto
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: context.l10n.financeAmountLabel,
                hintText: 'Ej: 200000',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.md),

            // Motivo
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.l10n.fineReasonLabel,
                hintText: context.l10n.fineReasonHint,
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),

            // Artículo del manual
            TextField(
              controller: _articleController,
              decoration: InputDecoration(
                labelText: context.l10n.fineManualArticleLabel,
                hintText: 'Ej: Art. 23 — Horarios de silencio',
                prefixIcon: const Icon(Icons.menu_book),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Plazo de descargos
            Text(
              context.l10n.fineDefenseDeadline,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              children: [3, 5, 7, 10].map((days) {
                final selected = _defenseDays == days;
                return ChoiceChip(
                  label: Text(
                    context.l10n.fineDaysCount(days),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : context.colors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _defenseDays = days),
                  selectedColor: AppColors.warning,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : context.colors.textPrimary,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.lg),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.fineNotifyInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
