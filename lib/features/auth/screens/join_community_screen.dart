import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/core/utils/validators.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/repositories/community_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(firestoreProvider));
});

class JoinCommunityScreen extends ConsumerStatefulWidget {
  const JoinCommunityScreen({super.key});

  @override
  ConsumerState<JoinCommunityScreen> createState() =>
      _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends ConsumerState<JoinCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _towerController = TextEditingController();
  final _apartmentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _towerController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(communityRepositoryProvider);
      final community = await repo.getCommunityByInviteCode(
        _codeController.text.trim(),
      );

      if (community == null) {
        if (mounted) {
          context.showErrorSnackBar('Código de invitación inválido');
        }
        setState(() => _isLoading = false);
        return;
      }

      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      await repo.joinCommunity(
        communityId: community.id,
        uid: user.id,
        tower: _towerController.text.trim(),
        apartment: _apartmentController.text.trim(),
      );

      if (mounted) {
        context.go('/pending-approval');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al unirse a la comunidad');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a comunidad')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.paddingAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.apartment,
                  size: 64,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'Ingresa el código de invitación',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Pide el código a tu administrador. Lo encuentras en portería o en los comunicados del conjunto.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSizes.xl),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  validator: Validators.validateInviteCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'ABC123',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                TextFormField(
                  controller: _towerController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateTower,
                  decoration: const InputDecoration(
                    labelText: 'Torre / Bloque',
                    prefixIcon: Icon(Icons.domain),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _apartmentController,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validateApartment,
                  decoration: const InputDecoration(
                    labelText: 'Número de apartamento',
                    prefixIcon: Icon(Icons.door_front_door_outlined),
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleJoin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Solicitar ingreso'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
