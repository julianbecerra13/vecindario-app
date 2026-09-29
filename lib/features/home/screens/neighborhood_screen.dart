import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';

/// A12 - Barrio. Reúne las tres familias comerciales sin mezclarlas.
class NeighborhoodScreen extends StatelessWidget {
  const NeighborhoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu barrio')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Text(
            'Encuentra cerca, sin confundir quién ofrece.',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSizes.lg),
          _AreaCard(
            icon: Icons.storefront_outlined,
            title: 'Tiendas de la comunidad',
            description: 'Compra productos y sigue tus pedidos.',
            action: 'Explorar tiendas',
            onTap: () => context.go('/stores'),
          ),
          _AreaCard(
            icon: Icons.handyman_outlined,
            title: 'Servicios de vecinos',
            description: 'Conoce habilidades ofrecidas por residentes.',
            action: 'Ver servicios',
            onTap: () => context.go('/services'),
          ),
          _AreaCard(
            icon: Icons.verified_outlined,
            title: 'Directorio recomendado',
            description: 'Proveedores externos recomendados por la comunidad.',
            action: 'Abrir directorio',
            onTap: () => context.go('/external-services'),
          ),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                    const SizedBox(height: 8),
                    Text(
                      action,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
