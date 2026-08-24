import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/super_admin/providers/super_admin_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  int _estrato = 3;
  UnitType _unitType = UnitType.apartment;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final code = _generateInviteCode();
      final community = CommunityModel(
        id: '',
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        estrato: _estrato,
        adminUid: '',
        inviteCode: code,
        unitType: _unitType,
        createdAt: DateTime.now(),
      );

      await ref.read(superAdminRepositoryProvider).createCommunity(community);

      if (!mounted) return;
      context.showSuccessSnackBar(
        context.l10n.superAdminCommunityCreatedMessage(community.name, code),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.superAdminCreateError('$e'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.superAdminNewCommunityTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      context.l10n.superAdminCreateCommunityHint,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              context.l10n.superAdminBasicInfoTitle,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.superAdminCommunityNameLabel,
                hintText: context.l10n.superAdminCommunityNameHint,
                prefixIcon: const Icon(Icons.apartment),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.adminNameRequired
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.adminAddressLabel,
                hintText: context.l10n.superAdminAddressHint,
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.superAdminAddressRequired
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.adminCityLabel,
                hintText: context.l10n.superAdminCityHint,
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.superAdminCityRequired
                  : null,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              context.l10n.superAdminCharacteristicsTitle,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<int>(
              value: _estrato,
              decoration: InputDecoration(
                labelText: context.l10n.superAdminEstratoSocioLabel,
                prefixIcon: const Icon(Icons.stars_outlined),
                border: const OutlineInputBorder(),
              ),
              items: List.generate(6, (i) => i + 1).map((e) {
                const labels = [
                  'Bajo-bajo',
                  'Bajo',
                  'Medio-bajo',
                  'Medio',
                  'Medio-alto',
                  'Alto',
                ];
                return DropdownMenuItem(
                  value: e,
                  child: Text('Estrato $e - ${labels[e - 1]}'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _estrato = v);
              },
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<UnitType>(
              value: _unitType,
              decoration: InputDecoration(
                labelText: context.l10n.superAdminUnitTypeFieldLabel,
                prefixIcon: const Icon(Icons.home_work_outlined),
                border: const OutlineInputBorder(),
              ),
              items: UnitType.values.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.label));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _unitType = v);
              },
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
                      ? context.l10n.superAdminCreatingAction
                      : context.l10n.superAdminCreateCommunityAction,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
