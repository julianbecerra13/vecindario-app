import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/core/theme/theme_mode_provider.dart';
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
              const SizedBox(height: AppSizes.md),

              // Cuenta
              _SectionCard(
                title: 'Cuenta',
                children: [
                  _SettingsTile(
                    icon: Icons.edit,
                    title: 'Editar perfil',
                    onTap: () => context.push('/profile/edit'),
                  ),
                ],
              ),

              // Super Admin (plataforma)
              if (user.isSuperAdmin)
                _SectionCard(
                  title: 'Plataforma',
                  children: [
                    _SettingsTile(
                      icon: Icons.shield,
                      title: 'Super Admin Panel',
                      subtitle: 'Gestionar comunidades y clientes',
                      onTap: () => context.push('/super-admin'),
                    ),
                  ],
                ),

              // Administración del conjunto (fusiona lo que antes eran dos
              // entradas separadas: panel admin y Vecindario Admin)
              if (isAdmin)
                _SectionCard(
                  title: 'Administración',
                  children: [
                    _SettingsTile(
                      icon: Icons.business,
                      title: 'Administración del conjunto',
                      subtitle:
                          'Aprobaciones, circulares, multas, finanzas, PQRS y más',
                      onTap: () => context.push('/premium'),
                    ),
                  ],
                ),

              // Mi conjunto (residentes + admin, todos los vecinos) — grid
              // de accesos rápidos en vez de una lista larga de 7 filas.
              if (!user.isSuperAdmin && user.communityId != null)
                _QuickAccessSection(
                  title: 'Mi conjunto',
                  items: [
                    _QuickAccessItem(
                      icon: Icons.campaign_outlined,
                      title: 'Circulares',
                      onTap: () => context.push('/premium/circulars'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.pool_outlined,
                      title: 'Reservar zona',
                      onTap: () => context.push('/premium/amenities'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.assignment_outlined,
                      title: 'PQRS',
                      onTap: () => context.push('/premium/pqrs'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Mis multas',
                      onTap: () => context.push('/premium/fines'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Estado de cuenta',
                      onTap: () => context.push('/premium/account-statement'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.how_to_vote_outlined,
                      title: 'Asambleas',
                      onTap: () => context.push('/premium/assemblies'),
                    ),
                    _QuickAccessItem(
                      icon: Icons.menu_book_outlined,
                      title: 'Manual de convivencia',
                      onTap: () => context.push('/premium/manual'),
                    ),
                  ],
                ),

              // Store panel (solo para quien tiene una tienda)
              if (hasStore)
                _SectionCard(
                  title: 'Mi Tienda',
                  children: [
                    _SettingsTile(
                      icon: Icons.storefront,
                      title: 'Panel de tienda',
                      subtitle: 'Gestionar pedidos y catálogo',
                      onTap: () => context.push('/store-panel'),
                    ),
                  ],
                ),

              _SectionCard(
                title: 'Configuración',
                children: [
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
                  Consumer(
                    builder: (context, ref, _) {
                      final themeMode = ref.watch(themeModeProvider);
                      return _SettingsTile(
                        icon: Icons.brightness_6_outlined,
                        title: 'Apariencia',
                        subtitle: switch (themeMode) {
                          ThemeMode.light => 'Claro',
                          ThemeMode.dark => 'Oscuro',
                          ThemeMode.system => 'Automático (sistema)',
                        },
                        onTap: () => _showThemeModeDialog(context, ref),
                      );
                    },
                  ),
                ],
              ),

              _SectionCard(
                title: 'Legal',
                children: [
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
                ],
              ),

              const SizedBox(height: AppSizes.sm),
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

void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final current = ref.read(themeModeProvider);
      return AlertDialog(
        title: const Text('Apariencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final label = switch (mode) {
              ThemeMode.light => 'Claro',
              ThemeMode.dark => 'Oscuro',
              ThemeMode.system => 'Automático (sistema)',
            };
            return RadioListTile<ThemeMode>(
              title: Text(label),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value == null) return;
                ref.read(themeModeProvider.notifier).setThemeMode(value);
                Navigator.of(dialogContext).pop();
              },
            );
          }).toList(),
        ),
      );
    },
  );
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
          style: AppTextStyles.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Agrupa una sección de settings dentro de una única Card, en vez de
/// flotar sobre el fondo separada solo por un Divider fino — da separación
/// visual real por bloque.
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              AppSizes.xs,
            ),
            child: Text(title.toUpperCase(), style: AppTextStyles.label),
          ),
          ...children,
          const SizedBox(height: AppSizes.xs),
        ],
      ),
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
      leading: Icon(icon, color: context.colors.textSecondary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption)
          : null,
      trailing: Icon(Icons.chevron_right, color: context.colors.textHint),
      onTap: onTap,
    );
  }
}

/// Sección con una grid de 2 columnas de accesos rápidos — reemplaza una
/// lista larga de ListTile idénticos por tarjetas escaneables de un vistazo.
class _QuickAccessSection extends StatelessWidget {
  final String title;
  final List<_QuickAccessItem> items;

  const _QuickAccessSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AppTextStyles.label),
            const SizedBox(height: AppSizes.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSizes.sm,
              mainAxisSpacing: AppSizes.sm,
              childAspectRatio: 1.7,
              children: items
                  .map(
                    (item) => _QuickAccessTile(
                      icon: item.icon,
                      title: item.title,
                      onTap: item.onTap,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.sm,
            horizontal: AppSizes.xs,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
              const SizedBox(height: AppSizes.xs),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
