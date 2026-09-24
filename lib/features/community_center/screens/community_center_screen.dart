import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';

/// Puerta de entrada del residente a comunicación, trámites y transparencia.
class CommunityCenterScreen extends ConsumerWidget {
  const CommunityCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(currentCommunityProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Administración del conjunto')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text(community?.name ?? 'Mi conjunto', style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          const Text(
            'Comunícate con la administración y consulta la información de tu comunidad.',
          ),
          const SizedBox(height: AppSizes.lg),
          _SectionTile(
            icon: Icons.qr_code_scanner,
            title: 'Mi QR de zonas comunes',
            subtitle: 'Identificación y registro de ingreso con el operario',
            onTap: () => context.push('/community-access'),
          ),
          Text('¿Qué necesitas?', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _PrimaryAction(
                  icon: Icons.report_problem_outlined,
                  label: 'Presentar\nuna queja',
                  color: AppColors.error,
                  onTap: () => context.push(
                    '/premium/pqrs/create?type=complaint&category=administration',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _PrimaryAction(
                  icon: Icons.event_available_outlined,
                  label: 'Solicitar\nuna cita',
                  color: AppColors.info,
                  onTap: () => context.push(
                    '/premium/pqrs/create?type=petition&category=administration',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _PrimaryAction(
                  icon: Icons.pool_outlined,
                  label: 'Reservar\nzona social',
                  color: AppColors.success,
                  onTap: () => context.push('/premium/amenities'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),
          Text('Mi información', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          _SectionTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Mi saldo y estado de cuenta',
            subtitle: 'Cuotas, pagos y movimientos',
            onTap: () => context.push('/premium/account-statement'),
          ),
          _SectionTile(
            icon: Icons.gavel_outlined,
            title: 'Mis multas',
            subtitle: 'Sanciones, estado y descargos',
            onTap: () => context.push('/premium/fines'),
          ),
          _SectionTile(
            icon: Icons.assignment_outlined,
            title: 'Mis solicitudes',
            subtitle: 'Radicados, respuestas y seguimiento',
            onTap: () => context.push('/premium/pqrs'),
          ),
          const SizedBox(height: AppSizes.lg),
          Text('Transparencia y comunidad', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          _SectionTile(
            icon: Icons.account_balance_outlined,
            title: 'Presupuesto y gastos',
            subtitle: 'Ingresos, egresos y ejecución del conjunto',
            onTap: () => context.push('/premium/finances'),
          ),
          _SectionTile(
            icon: Icons.menu_book_outlined,
            title: 'Manuales y reglamentos',
            subtitle: 'Normas y manual de convivencia',
            onTap: () => context.push('/premium/manual'),
          ),
          _SectionTile(
            icon: Icons.campaign_outlined,
            title: 'Circulares y avisos oficiales',
            subtitle: 'Información publicada por la administración',
            onTap: () => context.push('/premium/circulars'),
          ),
          _SectionTile(
            icon: Icons.groups_outlined,
            title: 'Asambleas y actas',
            subtitle: 'Reuniones, decisiones y documentos',
            onTap: () => context.push('/premium/assemblies'),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: AppSizes.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
