import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/amenity_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateAmenityScreen extends ConsumerStatefulWidget {
  const CreateAmenityScreen({super.key});

  @override
  ConsumerState<CreateAmenityScreen> createState() =>
      _CreateAmenityScreenState();
}

class _CreateAmenityScreenState extends ConsumerState<CreateAmenityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController(text: '10');
  final _rateController = TextEditingController();
  final _depositController = TextEditingController();
  final _hoursController = TextEditingController(text: '8:00 - 22:00');
  final _rulesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    _rateController.dispose();
    _depositController.dispose();
    _hoursController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) {
      context.showErrorSnackBar(context.l10n.errorCommunityNotAvailable);
      return;
    }

    setState(() => _saving = true);
    try {
      final deposit = _depositController.text.trim().isEmpty
          ? null
          : int.parse(_depositController.text.trim());
      final amenity = AmenityModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        hourlyRate: int.parse(_rateController.text.trim()),
        deposit: deposit,
        rules: _rulesController.text.trim(),
        hours: _hoursController.text.trim(),
      );
      await ref
          .read(premiumRepositoryProvider)
          .createAmenity(communityId, amenity);
      if (!mounted) return;
      context.showSuccessSnackBar(context.l10n.amenityCreated);
      context.pop();
    } catch (e) {
      if (mounted) context.showErrorSnackBar(context.l10n.errorGeneric(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.amenityCreateTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            Text(context.l10n.formBasicInfo, style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.amenityNameLabel,
                hintText: context.l10n.amenityNameHint,
                prefixIcon: const Icon(Icons.meeting_room),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.formDescriptionLabel,
                prefixIcon: const Icon(Icons.description_outlined),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La descripción es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              context.l10n.amenityCapacityFeesSection,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.amenityCapacityFieldLabel,
                prefixIcon: const Icon(Icons.people_outline),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Capacidad inválida';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.amenityHourlyRateLabel,
                prefixText: '\$ ',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n < 0) return 'Tarifa inválida';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _depositController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.amenityDepositOptionalLabel,
                prefixText: '\$ ',
                prefixIcon: const Icon(Icons.savings_outlined),
                border: const OutlineInputBorder(),
                helperText: context.l10n.amenityDepositHelper,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Depósito inválido';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              context.l10n.amenityScheduleRulesSection,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _hoursController,
              decoration: InputDecoration(
                labelText: context.l10n.amenityHoursLabel,
                hintText: '8:00 - 22:00',
                prefixIcon: const Icon(Icons.access_time),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _rulesController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.amenityRulesLabel,
                hintText: context.l10n.amenityRulesHint,
                prefixIcon: const Icon(Icons.rule),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _saving
                      ? context.l10n.savingEllipsis
                      : context.l10n.amenityCreateSubmit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
