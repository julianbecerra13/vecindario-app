import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

class RecommendExternalServiceScreen extends ConsumerStatefulWidget {
  const RecommendExternalServiceScreen({super.key});

  @override
  ConsumerState<RecommendExternalServiceScreen> createState() =>
      _RecommendExternalServiceScreenState();
}

class _RecommendExternalServiceScreenState
    extends ConsumerState<RecommendExternalServiceScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      context.showErrorSnackBar(context.l10n.externalCompleteNameDesc);
      return;
    }

    final user = ref.read(currentUserProvider).value;
    final community = ref.read(currentCommunityProvider).value;

    if (user == null || community == null) {
      context.showErrorSnackBar(context.l10n.externalNoUserOrCommunity);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Guardar recomendación en Firestore
      await ref.read(firestoreProvider).collection('external_services').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'website': _websiteController.text.trim(),
        'recommendedBy': user.id,
        'recommendedByName': user.displayName,
        'communityId': community.id,
        'createdAt': DateTime.now(),
      });

      if (mounted) {
        context.showSuccessSnackBar(context.l10n.externalServiceRecommended);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.externalErrorRecommending);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.externalRecommendTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.externalRecommendDesc,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSizes.lg),

            // Nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.externalServiceNameLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              maxLength: 60,
            ),
            const SizedBox(height: AppSizes.md),

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: context.l10n.externalDescriptionLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                hintText: context.l10n.externalDescriptionHint,
              ),
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: AppSizes.md),

            // Teléfono
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: context.l10n.phone,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.md),

            // Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: context.l10n.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSizes.md),

            // Sitio web
            TextField(
              controller: _websiteController,
              decoration: InputDecoration(
                labelText: context.l10n.externalWebsiteLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                hintText: context.l10n.externalWebsiteHint,
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSizes.xl),

            // Botón de enviar
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
                    : Text(context.l10n.externalSendRecommendation),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
