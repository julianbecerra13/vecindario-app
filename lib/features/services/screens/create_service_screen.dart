import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/utils/image_utils.dart';
import 'package:vecindario_app/core/utils/validators.dart';
import 'package:vecindario_app/features/services/models/service_model.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  ServiceCategory _category = ServiceCategory.comida;
  bool _priceNegotiable = false;
  final List<File> _images = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addImages() async {
    if (_images.length >= 5) {
      context.showErrorSnackBar('Máximo 5 fotos');
      return;
    }
    final files = await ImageUtils.pickMultipleFromGallery(
      maxImages: 5 - _images.length,
    );
    setState(() => _images.addAll(files));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ServiceModel(
        id: '',
        ownerUid: user.id,
        communityId: communityId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        price: _priceNegotiable
            ? null
            : double.tryParse(_priceController.text.replaceAll(',', '.')),
        priceDescription: _priceNegotiable ? 'Precio a convenir' : null,
        ownerName: user.displayName,
        ownerPhotoURL: user.photoURL,
        createdAt: DateTime.now(),
      );

      await ref.read(servicesRepositoryProvider).createService(service);

      if (mounted) {
        context.showSuccessSnackBar('Servicio publicado');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al publicar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo servicio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            TextFormField(
              controller: _titleController,
              validator: (v) => Validators.validateRequired(v, 'El título'),
              decoration: const InputDecoration(labelText: 'Título del servicio'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),
            DropdownButtonFormField<ServiceCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: ServiceCategory.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _descriptionController,
              validator: (v) =>
                  Validators.validateRequired(v, 'La descripción'),
              decoration: const InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    enabled: !_priceNegotiable,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixText: '\$ ',
                      suffixText: 'COP',
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Column(
                  children: [
                    const Text('A convenir', style: TextStyle(fontSize: 11)),
                    Switch(
                      value: _priceNegotiable,
                      onChanged: (v) => setState(() => _priceNegotiable = v),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            // Fotos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fotos',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _addImages,
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text('Agregar (${_images.length}/5)'),
                ),
              ],
            ),
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.sm),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          child: Image.file(
                            _images[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _images.removeAt(i)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Publicar servicio'),
            ),
          ],
        ),
      ),
    );
  }
}
