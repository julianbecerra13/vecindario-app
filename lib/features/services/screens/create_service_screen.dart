import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
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
  final _maxPriceController = TextEditingController();
  _PriceMode _priceMode = _PriceMode.fixed;
  ServiceCategory _selectedCategory = ServiceCategory.hogar;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      context.showErrorSnackBar(context.l10n.serviceFillAllFields);
      return;
    }

    final user = ref.read(currentUserProvider).value;
    final community = ref.read(currentCommunityProvider).value;

    if (user == null || community == null) {
      context.showErrorSnackBar(context.l10n.serviceNoUserOrCommunity);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price =
          _priceMode == _PriceMode.fixed &&
              _priceController.text.trim().isNotEmpty
          ? double.parse(_priceController.text.trim())
          : null;
      String? priceDescription;
      if (_priceMode == _PriceMode.range) {
        if (_priceController.text.trim().isEmpty ||
            _maxPriceController.text.trim().isEmpty) {
          throw const FormatException('El rango requiere dos valores');
        }
        priceDescription =
            '\$${_priceController.text.trim()} – \$${_maxPriceController.text.trim()} COP';
      } else if (_priceMode == _PriceMode.noPrice) {
        priceDescription = 'Sin precio';
      }

      final service = ServiceModel(
        id: '',
        ownerUid: user.id,
        communityId: community.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: price,
        priceDescription: priceDescription,
        ownerName: user.displayName,
        ownerPhotoURL: user.photoURL,
        contactPhone: user.phone,
        communityName: community.name,
        createdAt: DateTime.now(),
      );

      await ref.read(servicesRepositoryProvider).createService(service);

      if (mounted) {
        context.showSuccessSnackBar(context.l10n.serviceCreated);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.serviceCreateError);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.serviceOfferTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categoría
            Text(context.l10n.serviceCategoryLabel),
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
                labelText: context.l10n.serviceTitleLabel,
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
                labelText: context.l10n.serviceDescriptionLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: AppSizes.lg),

            DropdownButtonFormField<_PriceMode>(
              value: _priceMode,
              decoration: const InputDecoration(labelText: 'Tipo de precio'),
              items: _PriceMode.values
                  .map(
                    (mode) =>
                        DropdownMenuItem(value: mode, child: Text(mode.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priceMode = value);
              },
            ),
            if (_priceMode == _PriceMode.fixed ||
                _priceMode == _PriceMode.range) ...[
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: _priceMode == _PriceMode.range
                            ? 'Precio mínimo'
                            : context.l10n.servicePriceLabel,
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (_priceMode == _PriceMode.range) ...[
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio máximo',
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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
                    : Text(context.l10n.servicePublishButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PriceMode {
  fixed('Precio fijo'),
  range('Rango de precios'),
  consult('Consultar precio'),
  noPrice('Sin precio');

  const _PriceMode(this.label);
  final String label;
}
