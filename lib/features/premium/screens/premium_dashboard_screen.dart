import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/providers/premium_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

/// Dashboard principal de Vecindario Admin
/// Admin: ve stats, acciones rápidas y gestión completa
/// Residente: ve accesos a circulares, sus multas, zonas, PQRS, finanzas
class PremiumDashboardScreen extends ConsumerWidget {
  const PremiumDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    final plan = ref.watch(subscriptionPlanProvider).value;

    if (!isPremium) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vecindario Admin')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: AppColors.textHint),
                const SizedBox(height: AppSizes.md),
                Text('Módulo Premium', style: AppTextStyles.heading3),
                const SizedBox(height: AppSizes.sm),
                const Text(
                  'Tu comunidad aún no tiene Vecindario Admin activo. Contacta a tu administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vecindario Admin'),
            if (plan != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  plan.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Módulos disponibles
          if (isFeatureAvailable(plan, 'circulars'))
            _ModuleTile(
              icon: Icons.campaign,
              color: AppColors.info,
              title: 'Circulares',
              subtitle: isAdmin
                  ? 'Enviar comunicados con tracking de lectura'
                  : 'Comunicados oficiales de tu conjunto',
              onTap: () => context.push('/premium/circulars'),
            ),
          if (isFeatureAvailable(plan, 'fines'))
            _ModuleTile(
              icon: Icons.gavel,
              color: AppColors.warning,
              title: isAdmin ? 'Gestión de Multas' : 'Mis Multas',
              subtitle: isAdmin
                  ? 'Registrar y gestionar sanciones'
                  : 'Tus multas y descargos',
              onTap: () => context.push('/premium/fines'),
            ),
          if (isFeatureAvailable(plan, 'pqrs'))
            _ModuleTile(
              icon: Icons.assignment,
              color: AppColors.primary,
              title: 'PQRS',
              subtitle: isAdmin
                  ? 'Solicitudes de residentes con SLA'
                  : 'Envía peticiones, quejas o sugerencias',
              onTap: () => context.push('/premium/pqrs'),
            ),
          if (isFeatureAvailable(plan, 'manual'))
            _ModuleTile(
              icon: Icons.menu_book,
              color: const Color(0xFF8B5CF6),
              title: 'Manual de Convivencia',
              subtitle: 'Reglamento del conjunto por capítulos',
              onTap: () => context.push('/premium/manual'),
            ),
          if (isFeatureAvailable(plan, 'amenities'))
            _ModuleTile(
              icon: Icons.pool,
              color: const Color(0xFF06B6D4),
              title: 'Zonas Sociales',
              subtitle: isAdmin
                  ? 'Gestionar reservas y depósitos'
                  : 'Reservar salón, BBQ, cancha y más',
              onTap: () => context.push('/premium/amenities'),
            ),
          if (isFeatureAvailable(plan, 'finances'))
            _ModuleTile(
              icon: Icons.account_balance,
              color: AppColors.success,
              title: isAdmin ? 'Dashboard Financiero' : 'Mi Estado de Cuenta',
              subtitle: isAdmin
                  ? 'Ingresos, egresos y presupuesto'
                  : 'Tu saldo, pagos y cuotas',
              onTap: () => context.push('/premium/finances'),
            ),
          if (isFeatureAvailable(plan, 'assemblies'))
            _ModuleTile(
              icon: Icons.how_to_vote,
              color: AppColors.error,
              title: 'Asambleas',
              subtitle: isAdmin
                  ? 'Convocar y gestionar votaciones'
                  : 'Participar y votar en tiempo real',
              onTap: () => context.push('/premium/assemblies'),
            ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }
}
