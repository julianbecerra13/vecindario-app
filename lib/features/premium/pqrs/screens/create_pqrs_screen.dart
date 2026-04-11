import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/pqrs_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreatePqrsScreen extends ConsumerStatefulWidget {
  const CreatePqrsScreen({super.key});

  @override
  ConsumerState<CreatePqrsScreen> createState() => _CreatePqrsScreenState();
}

class _CreatePqrsScreenState extends ConsumerState<CreatePqrsScreen> {
  final _descriptionController = TextEditingController();
  PqrsType _type = PqrsType.petition;
  PqrsCategory _category = PqrsCategory.maintenance;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty) {
      context.showErrorSnackBar('Describe tu solicitud');
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) return;

    final pqrs = PqrsModel(
      id: '',
      type: _type,
      category: _category,
      description: _descriptionController.text.trim(),
      residentUid: user.id,
      residentName: user.displayName,
      residentUnit: user.unitInfo,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(premiumRepositoryProvider).createPqrs(communityId, pqrs);
      if (mounted) {
        context.showSuccessSnackBar('PQRS enviado');
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
        title: const Text('Nuevo PQRS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Tipo
          Text('Tipo de solicitud', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: 8,
            children: PqrsType.values.map((t) {
              final selected = _type == t;
              return ChoiceChip(
                avatar: Icon(t.icon, size: 14, color: selected ? Colors.white : t.color),
                label: Text(t.label),
                selected: selected,
                onSelected: (_) => setState(() => _type = t),
                selectedColor: t.color,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),

          // Categoría
          Text('Categoría', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PqrsCategory.values.map((c) {
              final selected = _category == c;
              return ChoiceChip(
                avatar: Icon(c.icon, size: 14),
                label: Text(c.label),
                selected: selected,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),

          // Descripción
          TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Describe tu petición, queja, reclamo o sugerencia...',
              alignLabelWithHint: true,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSizes.md),

          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu solicitud será enviada al administrador del conjunto. Recibirás notificación cuando sea atendida.',
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
