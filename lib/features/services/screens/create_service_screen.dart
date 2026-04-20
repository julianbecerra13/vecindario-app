import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  ServiceCategory _selectedCategory = ServiceCategory.hogar;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      context.showErrorSnackBar('Completa todos los campos');
      return;
    }

    final user = ref.read(currentUserProvider).value;
    final community = ref.read(currentCommunityProvider).value;

    if (user == null || community == null) {
      context.showErrorSnackBar('No hay usuario o comunidad');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = _priceController.text.isEmpty
          ? null
          : double.parse(_priceController.text);

      final service = ServiceModel(
        id: '',
        ownerUid: user.id,
        communityId: community.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: price,
        ownerName: user.displayName,
        ownerPhotoURL: user.photoURL,
        createdAt: DateTime.now(),
      );

      await ref.read(servicesRepositoryProvider).createService(service);

      if (mounted) {
        context.showSuccessSnackBar('Servicio creado');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al crear servicio');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofrecer Servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoría
            const Text('Categoría'),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.xs,
              children: ServiceCategory.values
                  .map(
                    (cat) => FilterChip(
                      label: Text(cat.label),
                      selected: _selectedCategory == cat,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      avatar: Icon(cat.icon, size: 16),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            // Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título del servicio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              maxLength: 60,
            ),
            const SizedBox(height: AppSizes.lg),

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: AppSizes.lg),

            // Precio
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio (COP) - Opcional',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.xl),

            // Botón de publicar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publicar Servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
