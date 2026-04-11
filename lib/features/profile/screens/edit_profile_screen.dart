import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/utils/validators.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';
import 'package:vecindario_app/shared/widgets/image_picker_sheet.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await showImagePickerSheet(context);
    if (file != null) setState(() => _newPhoto = file);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(userRepositoryProvider);
      String? photoURL = user.photoURL;

      if (_newPhoto != null) {
        photoURL = await repo.uploadProfilePhoto(user.id, _newPhoto!);
      }

      await repo.updateUser(user.id, {
        'displayName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        if (photoURL != null) 'photoURL': photoURL,
      });

      if (mounted) {
        context.showSuccessSnackBar('Perfil actualizado');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al guardar');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSizes.paddingAll,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  _newPhoto != null
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: FileImage(_newPhoto!),
                        )
                      : CachedAvatar(
                          imageUrl: user.photoURL,
                          name: user.displayName,
                          radius: 48,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            TextFormField(
              controller: _nameController,
              validator: Validators.validateName,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _phoneController,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
                prefixText: '+57 ',
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              initialValue: user.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'No se puede modificar',
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              initialValue: user.tower ?? '',
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Torre / Bloque',
                prefixIcon: Icon(Icons.domain),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              initialValue: user.apartment ?? '',
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Apartamento',
                prefixIcon: Icon(Icons.door_front_door_outlined),
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
