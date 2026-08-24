import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
import 'package:vecindario_app/shared/widgets/invite_code_card.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class CommunitySettingsScreen extends ConsumerStatefulWidget {
  const CommunitySettingsScreen({super.key});

  @override
  ConsumerState<CommunitySettingsScreen> createState() =>
      _CommunitySettingsScreenState();
}

class _CommunitySettingsScreenState
    extends ConsumerState<CommunitySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  int _estrato = 3;
  bool _loaded = false;
  bool _saving = false;
  bool _rotating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _hydrate(CommunityModel c) {
    if (_loaded) return;
    _nameController.text = c.name;
    _addressController.text = c.address;
    _cityController.text = c.city;
    _estrato = c.estrato;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(currentCommunityProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminSettingsTitle)),
      body: communityAsync.when(
        data: (community) {
          if (community == null) {
            return Center(child: Text(context.l10n.adminCommunityNotFound));
          }
          _hydrate(community);
          return Stack(
            children: [
              SingleChildScrollView(
                padding: AppSizes.paddingAll,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InviteCodeCard(
                        code: community.inviteCode,
                        onCopy: () => _copyCode(community.inviteCode),
                        onRotate: _rotateCode,
                        rotating: _rotating,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        context.l10n.adminGeneralData,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: context.l10n.adminNameLabel,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? context.l10n.adminNameRequired
                            : null,
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: context.l10n.adminAddressLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: context.l10n.adminCityLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      DropdownButtonFormField<int>(
                        value: _estrato,
                        decoration: InputDecoration(
                          labelText: context.l10n.adminEstratoLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: List.generate(6, (i) => i + 1)
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(context.l10n.adminEstratoOption(e)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _estrato = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      _StatsRow(community: community),
                      const SizedBox(height: AppSizes.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : () => _save(community),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.adminSaveChanges),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.adminGenericError('$e'))),
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    context.showSuccessSnackBar(context.l10n.adminCodeCopied);
  }

  Future<void> _rotateCode() async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;

    final confirm = await showConfirmDialog(
      context,
      title: context.l10n.adminRotateCodeTitle,
      message: context.l10n.adminRotateCodeMessage,
      confirmText: context.l10n.adminRotateAction,
      isDestructive: true,
    );
    if (!confirm) return;

    setState(() => _rotating = true);
    try {
      final result = await ref
          .read(cloudFunctionsProvider)
          .rotateInviteCode(communityId);
      if (!mounted) return;
      final newCode = result['newCode'] as String?;
      context.showSuccessSnackBar(
        newCode != null
            ? context.l10n.adminNewCodeMessage(newCode)
            : context.l10n.adminCodeRotated,
      );
    } on CloudFunctionException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(
          context.l10n.adminRotateError('${e.statusCode}'),
        );
      }
    } catch (e) {
      if (mounted)
        context.showErrorSnackBar(context.l10n.adminGenericError('$e'));
    } finally {
      if (mounted) setState(() => _rotating = false);
    }
  }

  Future<void> _save(CommunityModel original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref.read(communityRepositoryProvider).updateCommunity(original.id, {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'estrato': _estrato,
      });
      if (mounted) context.showSuccessSnackBar(context.l10n.adminChangesSaved);
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.adminSaveError('$e'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _StatsRow extends StatelessWidget {
  final CommunityModel community;
  const _StatsRow({required this.community});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _StatItem(
            label: context.l10n.adminResidentsLabel,
            value: '${community.memberCount}',
          ),
          const SizedBox(width: AppSizes.lg),
          _StatItem(
            label: context.l10n.adminServiceLabel,
            value: '\$${community.serviceFee}',
          ),
          const SizedBox(width: AppSizes.lg),
          _StatItem(
            label: context.l10n.adminUnitsLabel,
            value: community.unitType.label,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
