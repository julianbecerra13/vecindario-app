import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/circular_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateCircularScreen extends ConsumerStatefulWidget {
  const CreateCircularScreen({super.key});

  @override
  ConsumerState<CreateCircularScreen> createState() =>
      _CreateCircularScreenState();
}

class _CreateCircularScreenState extends ConsumerState<CreateCircularScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  CircularPriority _priority = CircularPriority.general;
  bool _requiresSignature = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_titleController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.circularTitleRequired);
      return;
    }
    if (_bodyController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.circularBodyRequired);
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) return;

    final circular = CircularModel(
      id: '',
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      authorUid: user.id,
      authorName: user.displayName,
      priority: _priority,
      requiresAck: _requiresSignature,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(premiumRepositoryProvider)
          .createCircular(communityId, circular);
      if (mounted) {
        context.showSuccessSnackBar(context.l10n.circularPublished);
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
        title: Text(context.l10n.circularCreateTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.sm),
            child: FilledButton(
              onPressed: _isLoading ? null : _publish,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.publish),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prioridad
            Text(context.l10n.circularPriority, style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: 8,
              children: CircularPriority.values.map((p) {
                final selected = _priority == p;
                return ChoiceChip(
                  avatar: Icon(
                    p.icon,
                    size: 14,
                    color: selected ? Colors.white : p.color,
                  ),
                  label: Text(p.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _priority = p),
                  selectedColor: p.color,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : context.colors.textPrimary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.l10n.circularTitleLabel,
                hintText: context.l10n.circularTitleHint,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),

            // Cuerpo
            TextField(
              controller: _bodyController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: context.l10n.circularContentLabel,
                hintText: context.l10n.circularContentHint,
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),

            // Opciones
            SwitchListTile(
              title: Text(
                context.l10n.circularRequiresAck,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                context.l10n.circularRequiresAckHelper,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
              value: _requiresSignature,
              onChanged: (v) => setState(() => _requiresSignature = v),
              activeColor: const Color(0xFF8B5CF6),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
