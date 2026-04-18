import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

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

      await ref
          .read(firestoreProvider)
          .collection('communities')
          .add(community.toFirestore());

      if (!mounted) return;
      context.showSuccessSnackBar(
        'Comunidad "${community.name}" creada. Código: $code',
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al crear: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva comunidad')),
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
                      'Después de crear la comunidad, se generará un código de invitación único para compartir con el administrador.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Información básica', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del conjunto',
                hintText: 'Ej: Pinares de Granada',
                prefixIcon: Icon(Icons.apartment),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                hintText: 'Ej: Carrera 15 # 80-45',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La dirección es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                hintText: 'Ej: Bogotá',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La ciudad es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Características', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<int>(
              value: _estrato,
              decoration: const InputDecoration(
                labelText: 'Estrato socioeconómico',
                prefixIcon: Icon(Icons.stars_outlined),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Tipo de unidad',
                prefixIcon: Icon(Icons.home_work_outlined),
                border: OutlineInputBorder(),
              ),
              items: UnitType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t.label),
                );
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
                label: Text(_saving ? 'Creando...' : 'Crear comunidad'),
              ),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}
