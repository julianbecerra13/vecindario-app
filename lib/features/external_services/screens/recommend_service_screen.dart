import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/utils/validators.dart';
import 'package:vecindario_app/features/external_services/models/external_service_model.dart';
import 'package:vecindario_app/features/external_services/providers/external_services_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class RecommendServiceScreen extends ConsumerStatefulWidget {
  const RecommendServiceScreen({super.key});

  @override
  ConsumerState<RecommendServiceScreen> createState() =>
      _RecommendServiceScreenState();
}

class _RecommendServiceScreenState
    extends ConsumerState<RecommendServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  ExternalCategory _category = ExternalCategory.electricista;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _recommend() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ExternalServiceModel(
        id: '',
        name: _nameController.text.trim(),
        category: _category,
        phone: _phoneController.text.trim(),
        description: _descController.text.trim(),
        recommendedByUid: user.id,
        recommendedByName: user.displayName,
        createdAt: DateTime.now(),
      );

      await ref
          .read(externalServicesRepositoryProvider)
          .recommendService(service);

      if (mounted) {
        context.showSuccessSnackBar('Servicio recomendado');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al recomendar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recomendar servicio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (v) => Validators.validateRequired(v, 'El nombre'),
              decoration: const InputDecoration(
                labelText: 'Nombre del profesional o empresa',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<ExternalCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: ExternalCategory.values
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(cat.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _phoneController,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                prefixText: '+57 ',
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _descController,
              validator: (v) =>
                  Validators.validateRequired(v, 'La descripción'),
              decoration: const InputDecoration(
                labelText: 'Describe tu experiencia con este servicio',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.description),
                ),
              ),
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _recommend,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Recomendar'),
            ),
          ],
        ),
      ),
    );
  }
}
