import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

/// A07 - Inicio. Resume lo relevante sin duplicar las áreas de Comunidad,
/// Barrio y Mi conjunto.
class ResidentHomeScreen extends ConsumerWidget {
  const ResidentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final community = ref.watch(currentCommunityProvider).valueOrNull;
    final firstName = (user?.displayName ?? 'vecino').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text(community?.name ?? 'Vecindario'),
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text(
            'Hola, $firstName',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Lo importante de tu comunidad, en un solo lugar.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSizes.lg),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu comunidad, más cerca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entérate, compra cerca y resuelve lo de tu conjunto.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: AppSizes.md),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/feed'),
                  icon: const Icon(Icons.forum_outlined),
                  label: const Text('Ver la comunidad'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Accesos rápidos',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.sm,
            crossAxisSpacing: AppSizes.sm,
            childAspectRatio: 1.35,
            children: [
              _QuickCard(
                icon: Icons.qr_code_2,
                title: 'Mi QR',
                subtitle: 'Acceso y zonas',
                onTap: () => context.push('/community-access'),
              ),
              _QuickCard(
                icon: Icons.calendar_month_outlined,
                title: 'Reservar',
                subtitle: 'Zonas comunes',
                onTap: () => context.push('/premium/amenities'),
              ),
              _QuickCard(
                icon: Icons.receipt_long_outlined,
                title: 'Mi cuenta',
                subtitle: 'Saldo y movimientos',
                onTap: () => context.push('/premium/account-statement'),
              ),
              _QuickCard(
                icon: Icons.support_agent_outlined,
                title: 'Solicitudes',
                subtitle: 'Seguimiento y citas',
                onTap: () => context.push('/appointments'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.primaryDark,
                ),
              ),
              title: const Text(
                'Descubre tu barrio',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Tiendas, habilidades y proveedores cercanos',
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => context.go('/barrio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
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
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
