import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
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
      context.showErrorSnackBar('Ingresa la unidad (ej: T2-801)');
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      context.showErrorSnackBar('Describe el motivo');
      return;
    }
    final amount = int.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      context.showErrorSnackBar('Ingresa un monto válido');
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
      manualArticle: _articleController.text.trim().isEmpty ? null : _articleController.text.trim(),
      status: FineStatus.notified,
      defenseDeadline: DateTime.now().add(Duration(days: _defenseDays)),
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(premiumRepositoryProvider).createFine(communityId, fine);
      if (mounted) {
        context.showSuccessSnackBar('Multa registrada');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Multa'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: _isLoading ? null : _create,
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Registrar'),
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
            decoration: const InputDecoration(
              labelText: 'Unidad / Apartamento',
              hintText: 'Ej: T2-801',
              prefixIcon: Icon(Icons.home),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSizes.md),

          // Monto
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Monto (COP)',
              hintText: 'Ej: 200000',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSizes.md),

          // Motivo
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo de la multa',
              hintText: 'Describe la infracción...',
              alignLabelWithHint: true,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSizes.md),

          // Artículo del manual
          TextField(
            controller: _articleController,
            decoration: const InputDecoration(
              labelText: 'Artículo del manual (opcional)',
              hintText: 'Ej: Art. 23 — Horarios de silencio',
              prefixIcon: Icon(Icons.menu_book),
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Plazo de descargos
          Text('Plazo para descargos', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: 8,
            children: [3, 5, 7, 10].map((days) {
              final selected = _defenseDays == days;
              return ChoiceChip(
                label: Text('$days días', style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 13)),
                selected: selected,
                onSelected: (_) => setState(() => _defenseDays = days),
                selectedColor: AppColors.warning,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
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
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El residente será notificado y tendrá el plazo indicado para presentar descargos.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
