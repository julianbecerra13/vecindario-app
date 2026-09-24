import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/services/cloud_functions_service.dart';

class JoinCommunityScreen extends ConsumerStatefulWidget {
  const JoinCommunityScreen({super.key});

  @override
  ConsumerState<JoinCommunityScreen> createState() =>
      _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends ConsumerState<JoinCommunityScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  final _towerController = TextEditingController();
  final _apartmentController = TextEditingController();
  bool _isLoading = false;
  String _primaryLabel = 'Torre / Bloque';
  String _secondaryLabel = 'Número de apartamento';

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    _towerController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  String get _code => _codeControllers.map((c) => c.text).join();

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _codeFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _codeFocusNodes[index - 1].requestFocus();
    }
    // Auto-buscar comunidad cuando se completan los 6 dígitos
    final code = _code;
    if (code.length == 6) {
      _lookupCommunity(code);
    }
  }

  Future<void> _lookupCommunity(String code) async {
    try {
      final result = await _resolveInvite(code, preview: true);
      final unitType = UnitType.fromString(
        result['unitType'] as String? ?? 'apartment',
      );
      if (!mounted) return;
      setState(() {
        _primaryLabel = unitType.primaryLabel;
        _secondaryLabel = unitType.secondaryLabel;
      });
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _resolveInvite(
    String code, {
    required bool preview,
  }) async {
    try {
      return await ref
          .read(cloudFunctionsProvider)
          .joinCommunity(
            inviteCode: code,
            tower: preview ? null : _towerController.text.trim(),
            apartment: preview ? null : _apartmentController.text.trim(),
            preview: preview,
          );
    } catch (_) {
      final repository = ref.read(communityRepositoryProvider);
      final invite = await repository.resolveInviteCode(code);
      if (invite == null) {
        throw StateError('Código de invitación inválido');
      }
      if (!preview) {
        final user = ref.read(currentUserProvider).value;
        if (user == null) throw StateError('Usuario no autenticado');
        await repository.joinCommunity(
          communityId: invite['communityId']!,
          uid: user.id,
          tower: _towerController.text.trim(),
          apartment: _apartmentController.text.trim(),
        );
      }
      return invite;
    }
  }

  Future<void> _handleJoin() async {
    final code = _code.trim();
    if (code.length < 6) {
      context.showErrorSnackBar(context.l10n.authEnterFullCode);
      return;
    }
    if (_towerController.text.trim().isEmpty ||
        _apartmentController.text.trim().isEmpty) {
      context.showErrorSnackBar(context.l10n.authFillTowerAndApartment);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      await _resolveInvite(code, preview: false);

      if (mounted) {
        context.go('/pending-approval');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(context.l10n.authJoinCommunityError);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.authJoinCommunityTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.paddingAll,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.lg),
              Icon(
                Icons.lock_outlined,
                size: 48,
                color: context.colors.textPrimary,
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                context.l10n.authJoinCommunityDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // 6 cajas de código con borde azul
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 44,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _codeControllers[i],
                      focusNode: _codeFocusNodes[i],
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 1,
                      onChanged: (v) => _onCodeChanged(i, v),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: context.colors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSizes.xl),
              TextFormField(
                controller: _towerController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(hintText: _primaryLabel),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _apartmentController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleJoin(),
                decoration: InputDecoration(hintText: _secondaryLabel),
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
                    : Text(context.l10n.requestJoin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
