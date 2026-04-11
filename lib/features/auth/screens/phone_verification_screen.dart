import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/auth/providers/auth_notifier.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const PhoneVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _sendCode();
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _sendCode() {
    ref
        .read(authNotifierProvider.notifier)
        .sendPhoneOTP(widget.phoneNumber);
    setState(() => _codeSent = true);
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 6) {
      context.showErrorSnackBar('Ingresa el código completo');
      return;
    }

    final success =
        await ref.read(authNotifierProvider.notifier).verifyOTP(code);
    if (success && mounted) {
      context.go('/join-community');
    }
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verificar cuando se completan los 6 dígitos
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length == 6) {
      _verifyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (state.error != null) {
        context.showErrorSnackBar(state.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verificar teléfono')),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.paddingAll,
          child: Column(
            children: [
              const SizedBox(height: AppSizes.xl),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Código de verificación',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Enviamos un código SMS al\n+57 ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Cajas de código OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 46,
                    height: 54,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _codeControllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (v) => _onCodeChanged(i, v),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSizes.xl),
              if (authState.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: const Text('Verificar'),
                ),

              const SizedBox(height: AppSizes.md),
              TextButton(
                onPressed: _codeSent ? _sendCode : null,
                child: const Text('Reenviar código'),
              ),

              const Spacer(),
              TextButton(
                onPressed: () => context.go('/join-community'),
                child: Text(
                  'Verificar después',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
