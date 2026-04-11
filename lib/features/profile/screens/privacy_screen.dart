import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Privacidad')),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          // Header Ley 1581
          Container(
            padding: AppSizes.paddingAll,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: AppColors.primary, size: 32),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ley 1581 de 2012',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tienes derecho a conocer, actualizar, rectificar y suprimir tus datos personales.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // === MIS DATOS ===
          _SectionHeader(title: 'Mis Datos'),
          const SizedBox(height: AppSizes.sm),
          _PrivacyAction(
            icon: Icons.download,
            title: 'Descargar mis datos',
            subtitle: 'Recibe un archivo con toda tu información',
            onTap: () {
              final user = ref.read(currentUserProvider).value;
              if (user != null) {
                ref.read(userRepositoryProvider).requestDataExport(user.id);
                context.showSuccessSnackBar(
                  'Solicitud enviada. Recibirás un email en máximo 48 horas.',
                );
              }
            },
          ),
          const Divider(height: 1),
          _PrivacyAction(
            icon: Icons.edit,
            title: 'Editar información personal',
            subtitle: 'Nombre, teléfono, foto de perfil',
            onTap: () {
              // Navegar a editar perfil
            },
          ),

          const SizedBox(height: AppSizes.lg),

          // === CONSENTIMIENTOS ===
          _SectionHeader(title: 'Consentimientos'),
          const SizedBox(height: AppSizes.sm),
          _ConsentToggle(
            icon: Icons.notifications,
            title: 'Notificaciones push',
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
          ),
          const Divider(height: 1),
          _ConsentToggle(
            icon: Icons.email,
            title: 'Email de novedades',
            value: _emailEnabled,
            onChanged: (v) => setState(() => _emailEnabled = v),
          ),
          const Divider(height: 1),
          _ConsentToggle(
            icon: Icons.bar_chart,
            title: 'Datos de uso (analytics)',
            value: _analyticsEnabled,
            onChanged: (v) => setState(() => _analyticsEnabled = v),
          ),

          const SizedBox(height: AppSizes.lg),

          // === LEGAL ===
          _SectionHeader(title: 'Legal'),
          const SizedBox(height: AppSizes.sm),
          _PrivacyAction(
            icon: Icons.description,
            title: 'Política de privacidad',
            subtitle: 'Tratamiento de datos personales',
            onTap: () {
              // Abrir política de privacidad
            },
          ),
          const Divider(height: 1),
          _PrivacyAction(
            icon: Icons.assignment,
            title: 'Términos de uso',
            subtitle: 'Condiciones del servicio',
            onTap: () {
              // Abrir términos de uso
            },
          ),

          const SizedBox(height: AppSizes.lg),

          // === ZONA DE PELIGRO ===
          _SectionHeader(title: 'Zona de peligro', isDestructive: true),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: AppSizes.paddingAll,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Esta acción es irreversible',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Después de 15 días no podrás recuperar tu cuenta.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.md),
                const Text(
                  'Se eliminará:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                _DeleteItem(text: 'Tu perfil y foto', isDelete: true),
                _DeleteItem(text: 'Documentos de verificación', isDelete: true),
                _DeleteItem(text: 'Tokens y sesiones', isDelete: true),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Se anonimizará:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                _DeleteItem(text: 'Posts → "Usuario eliminado"', isDelete: false),
                _DeleteItem(text: 'Reseñas → "Usuario eliminado"', isDelete: false),
                _DeleteItem(text: 'Pedidos → uid → null', isDelete: false),
                const SizedBox(height: AppSizes.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context),
                    icon: const Icon(Icons.delete_forever, color: AppColors.error),
                    label: const Text(
                      'Eliminar mi cuenta (15 días de gracia)',
                      style: TextStyle(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Eliminar Cuenta',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Estás seguro? Después de 15 días esta acción no se puede deshacer.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirma tu contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Código OTP (enviado a tu teléfono)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sms),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Ingresa tu contraseña')),
                );
                return;
              }
              Navigator.pop(ctx);
              final user = ref.read(currentUserProvider).value;
              if (user != null) {
                ref.read(userRepositoryProvider).requestAccountDeletion(user.id);
                if (context.mounted) {
                  context.showSnackBar(
                    'Tu cuenta será eliminada en 15 días. Puedes reactivarla iniciando sesión.',
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar mi cuenta'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDestructive;

  const _SectionHeader({required this.title, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDestructive ? AppColors.error : AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PrivacyAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PrivacyAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ConsentToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.success,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;
  final bool isDelete;

  const _DeleteItem({required this.text, required this.isDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 3),
      child: Row(
        children: [
          Text(
            isDelete ? '✕ ' : '~ ',
            style: TextStyle(
              color: isDelete ? AppColors.error : AppColors.warning,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDelete ? AppColors.error : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
