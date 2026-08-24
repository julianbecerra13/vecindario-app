import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/auth/providers/auth_notifier.dart';
import 'package:vecindario_app/features/profile/providers/profile_stats_provider.dart';
import 'package:vecindario_app/features/stores/providers/orders_provider.dart';
import 'package:vecindario_app/shared/providers/capabilities_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/cached_avatar.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final hasStore = ref.watch(hasStoreProvider);
    final postCountAsync = ref.watch(userPostCountProvider);
    final myOrdersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            children: [
              // Header
              Column(
                children: [
                  CachedAvatar(
                    imageUrl: user.photoURL,
                    name: user.displayName,
                    radius: AppSizes.avatarXl / 2,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(user.displayName, style: AppTextStyles.heading3),
                  Text(user.email, style: AppTextStyles.bodySmall),
                  if (user.unitInfo.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.xs),
                    Text(user.unitInfo, style: AppTextStyles.bodySmall),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.lg),
              _StatsRow(
                postCount: postCountAsync,
                ordersCount: myOrdersAsync.value?.length ?? 0,
                memberSince: user.createdAt,
              ),
              const SizedBox(height: AppSizes.lg),
              const Divider(),
              // Cuenta
              _SectionTitle('Cuenta'),
              _SettingsTile(
                icon: Icons.edit,
                title: 'Editar perfil',
                onTap: () => context.push('/profile/edit'),
              ),
              // Super Admin (plataforma)
              if (user.isSuperAdmin) ...[
                const Divider(),
                _SectionTitle('Plataforma'),
                _SettingsTile(
                  icon: Icons.shield,
                  title: 'Super Admin Panel',
                  subtitle: 'Gestionar comunidades y clientes',
                  onTap: () => context.push('/super-admin'),
                ),
              ],
              // Administración del conjunto (fusiona lo que antes eran dos
              // entradas separadas: panel admin y Vecindario Admin)
              if (isAdmin) ...[
                const Divider(),
                _SectionTitle('Administración'),
                _SettingsTile(
                  icon: Icons.business,
                  title: 'Administración del conjunto',
                  subtitle:
                      'Aprobaciones, circulares, multas, finanzas, PQRS y más',
                  onTap: () => context.push('/premium'),
                ),
              ],
              // Mi conjunto (residentes + admin, todos los vecinos)
              if (!user.isSuperAdmin && user.communityId != null) ...[
                const Divider(),
                _SectionTitle('Mi conjunto'),
                _SettingsTile(
                  icon: Icons.campaign_outlined,
                  title: 'Circulares',
                  subtitle: 'Comunicados de la administración',
                  onTap: () => context.push('/premium/circulars'),
                ),
                _SettingsTile(
                  icon: Icons.pool_outlined,
                  title: 'Reservar zona',
                  subtitle: 'Salón, gimnasio, BBQ, piscina',
                  onTap: () => context.push('/premium/amenities'),
                ),
                _SettingsTile(
                  icon: Icons.assignment_outlined,
                  title: 'PQRS',
                  subtitle: 'Peticiones, quejas, reclamos',
                  onTap: () => context.push('/premium/pqrs'),
                ),
                _SettingsTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Mis multas',
                  subtitle: 'Ver multas activas',
                  onTap: () => context.push('/premium/fines'),
                ),
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Estado de cuenta',
                  onTap: () => context.push('/premium/account-statement'),
                ),
                _SettingsTile(
                  icon: Icons.how_to_vote_outlined,
                  title: 'Asambleas',
                  subtitle: 'Convocatorias y votaciones',
                  onTap: () => context.push('/premium/assemblies'),
                ),
                _SettingsTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Manual de convivencia',
                  onTap: () => context.push('/premium/manual'),
                ),
              ],
              // Store panel (solo para quien tiene una tienda)
              if (hasStore) ...[
                const Divider(),
                _SectionTitle('Mi Tienda'),
                _SettingsTile(
                  icon: Icons.storefront,
                  title: 'Panel de tienda',
                  subtitle: 'Gestionar pedidos y catálogo',
                  onTap: () => context.push('/store-panel'),
                ),
              ],
              const Divider(),
              _SectionTitle('Configuración'),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones',
                onTap: () => context.push('/notifications'),
              ),
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: 'Mi Privacidad',
                subtitle: 'Datos, derechos y eliminación de cuenta',
                onTap: () => context.push('/profile/privacy'),
              ),
              const Divider(),
              _SectionTitle('Legal'),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Términos de uso',
                onTap: () => context.push('/profile/terms'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de privacidad',
                onTap: () => context.push('/profile/privacy-policy'),
              ),
              const SizedBox(height: AppSizes.lg),
              Padding(
                padding: AppSizes.paddingHorizontal,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Cerrar sesión',
                      message: '¿Estás seguro de que quieres cerrar sesión?',
                      confirmText: 'Cerrar sesión',
                      isDestructive: true,
                    );
                    if (confirm) {
                      ref.read(authNotifierProvider.notifier).logout();
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AsyncValue<int> postCount;
  final int ordersCount;
  final DateTime memberSince;

  const _StatsRow({
    required this.postCount,
    required this.ordersCount,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.paddingHorizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'Posts',
            value: postCount.when(
              data: (count) => count.toString(),
              loading: () => '—',
              error: (_, __) => '—',
            ),
          ),
          _StatItem(label: 'Pedidos', value: ordersCount.toString()),
          _StatItem(label: 'Miembro desde', value: '${memberSince.year}'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.xs,
      ),
      child: Text(title.toUpperCase(), style: AppTextStyles.label),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
