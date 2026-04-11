import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/core/utils/validators.dart';
import 'package:vecindario_app/features/auth/providers/auth_notifier.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _acceptDataTreatment = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms || !_acceptDataTreatment) {
      context.showErrorSnackBar(
        'Debes aceptar los términos y autorizar el tratamiento de datos',
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        context.go('/verify-phone/$phone');
      } else {
        context.go('/join-community');
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    if (!_acceptTerms || !_acceptDataTreatment) {
      context.showErrorSnackBar(
        'Debes aceptar los términos y autorizar el tratamiento de datos',
      );
      return;
    }
    final success =
        await ref.read(authNotifierProvider.notifier).loginWithGoogle();
    if (success && mounted) {
      context.go('/join-community');
    }
  }

  Future<void> _handleAppleRegister() async {
    if (!_acceptTerms || !_acceptDataTreatment) {
      context.showErrorSnackBar(
        'Debes aceptar los términos y autorizar el tratamiento de datos',
      );
      return;
    }
    final success =
        await ref.read(authNotifierProvider.notifier).loginWithApple();
    if (success && mounted) {
      context.go('/join-community');
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
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.paddingAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Únete a tu comunidad',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Crea tu cuenta para conectar con tus vecinos',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSizes.lg),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateName,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePhone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+57 ',
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.validateConfirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // Consentimiento de Términos
                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall,
                      children: const [
                        TextSpan(text: 'Acepto los '),
                        TextSpan(
                          text: 'Términos de Uso',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Consentimiento Habeas Data (Ley 1581/2012)
                CheckboxListTile(
                  value: _acceptDataTreatment,
                  onChanged: (v) =>
                      setState(() => _acceptDataTreatment = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodySmall,
                      children: const [
                        TextSpan(
                          text:
                              'Autorizo el tratamiento de mis datos personales según la ',
                        ),
                        TextSpan(
                          text: 'Ley 1581 de 2012',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' para los fines descritos en la Política de Privacidad.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleRegister,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),

                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Text(
                        'o continúa con',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            authState.isLoading ? null : _handleGoogleRegister,
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text('Google'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            authState.isLoading ? null : _handleAppleRegister,
                        icon: const Icon(Icons.apple, size: 24),
                        label: const Text('Apple'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta? '),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
