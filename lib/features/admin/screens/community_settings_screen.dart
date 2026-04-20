import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
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
      appBar: AppBar(title: const Text('Configuración de comunidad')),
      body: communityAsync.when(
        data: (community) {
          if (community == null) {
            return const Center(child: Text('Comunidad no encontrada'));
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
                      _InviteCodeCard(
                        code: community.inviteCode,
                        onCopy: () => _copyCode(community.inviteCode),
                        onRotate: _rotating ? null : _rotateCode,
                        rotating: _rotating,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text('Datos generales', style: AppTextStyles.heading3),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'El nombre es obligatorio'
                            : null,
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Ciudad',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      DropdownButtonFormField<int>(
                        value: _estrato,
                        decoration: const InputDecoration(
                          labelText: 'Estrato',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(6, (i) => i + 1)
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text('Estrato $e'),
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
                              : const Text('Guardar cambios'),
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    context.showSuccessSnackBar('Código copiado');
  }

  Future<void> _rotateCode() async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null) return;

    final confirm = await showConfirmDialog(
      context,
      title: 'Rotar código',
      message:
          'El código actual dejará de funcionar y se generará uno nuevo. Los residentes que aún no se hayan unido deberán pedirlo de nuevo.',
      confirmText: 'Rotar',
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
        newCode != null ? 'Nuevo código: $newCode' : 'Código rotado',
      );
    } on CloudFunctionException catch (e) {
      if (mounted) {
        context.showErrorSnackBar('No se pudo rotar: ${e.statusCode}');
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error: $e');
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
      if (mounted) context.showSuccessSnackBar('Cambios guardados');
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al guardar: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _InviteCodeCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  final VoidCallback? onRotate;
  final bool rotating;

  const _InviteCodeCard({
    required this.code,
    required this.onCopy,
    required this.onRotate,
    required this.rotating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÓDIGO DE INVITACIÓN',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            code.isEmpty ? '------' : code,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, color: Colors.white),
                  label: const Text(
                    'Copiar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRotate,
                  icon: rotating
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Rotar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          _StatItem(label: 'Residentes', value: '${community.memberCount}'),
          const SizedBox(width: AppSizes.lg),
          _StatItem(label: 'Servicio', value: '\$${community.serviceFee}'),
          const SizedBox(width: AppSizes.lg),
          _StatItem(label: 'Unidades', value: community.unitType.label),
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
