import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
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
      context.showErrorSnackBar('Comunidad no disponible');
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
      context.showSuccessSnackBar('Zona creada');
      context.pop();
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva zona social')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            Text('Información básica', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Salón social, BBQ, Piscina',
                prefixIcon: Icon(Icons.meeting_room),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'El nombre es obligatorio'
                  : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'La descripción es obligatoria'
                  : null,
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Capacidad y tarifas', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidad (personas)',
                prefixIcon: Icon(Icons.people_outline),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Tarifa por hora (COP)',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Depósito reembolsable (opcional)',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.savings_outlined),
                border: OutlineInputBorder(),
                helperText: 'Se retiene y devuelve si no hay daños',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Depósito inválido';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Horario y reglas', style: AppTextStyles.heading3),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _hoursController,
              decoration: const InputDecoration(
                labelText: 'Horario',
                hintText: '8:00 - 22:00',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _rulesController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Reglas (opcional)',
                hintText: 'Ej: Aforo máximo 15, no música después de 22h',
                prefixIcon: Icon(Icons.rule),
                border: OutlineInputBorder(),
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
                label: Text(_saving ? 'Guardando...' : 'Crear zona'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
