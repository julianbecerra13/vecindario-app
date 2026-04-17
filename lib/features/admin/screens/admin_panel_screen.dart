import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/features/admin/providers/admin_providers.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingResidentsProvider);
    final communityAsync = ref.watch(communityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PANEL ADMIN',
              style: TextStyle(fontSize: 10, color: AppColors.primary, letterSpacing: 1, fontWeight: FontWeight.w600),
            ),
            Text(
              communityAsync.value?.name ?? 'Mi comunidad',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                pendingAsync.when(
                  data: (list) => list.isNotEmpty
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${list.length}',
                              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            onPressed: () => context.push('/admin/pending'),
          ),
        ],
      ),
      body: ListView(
        padding: AppSizes.paddingAll,
        children: [
          // Código de invitación
          Container(
            padding: AppSizes.paddingAll,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A5F), Color(0xFF1A2744)],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CÓDIGO DE INVITACIÓN',
                        style: TextStyle(fontSize: 9, color: Color(0xFF60A5FA), letterSpacing: 1, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        communityAsync.value?.inviteCode ?? '------',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _SmallButton(
                      icon: Icons.copy,
                      label: 'Copiar',
                      onTap: () {
                        final code = communityAsync.value?.inviteCode;
                        if (code != null) {
                          Clipboard.setData(ClipboardData(text: code));
                          context.showSuccessSnackBar('Código copiado');
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    _SmallButton(
                      icon: Icons.refresh,
                      label: 'Rotar',
                      onTap: () async {
                        final communityId = ref.read(currentCommunityIdProvider);
                        if (communityId == null) return;
                        final newCode = _generateCode();
                        await ref.read(communityRepositoryProvider).regenerateInviteCode(communityId, newCode);
                        if (context.mounted) {
                          context.showSuccessSnackBar('Nuevo código: $newCode');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Solicitudes pendientes
          pendingAsync.when(
            data: (pending) {
              if (pending.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitudes Pendientes (${pending.length})',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  ...pending.take(3).map((user) => Card(
                        margin: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.displayName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    Text(
                                      'Torre ${user.tower} · Apto ${user.apartment}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.tonal(
                                onPressed: () => context.push('/admin/pending'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: const Text('Revisar', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (pending.length > 3)
                    TextButton(
                      onPressed: () => context.push('/admin/pending'),
                      child: Text('Ver todas (${pending.length})'),
                    ),
                  const SizedBox(height: AppSizes.md),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Estadísticas
          Text('Estadísticas', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Residentes',
                  value: communityAsync.value?.memberCount.toString() ?? '-',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatCard(
                  icon: Icons.storefront,
                  label: 'Servicios',
                  value: '-',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_bag,
                  label: 'Pedidos/sem',
                  value: '-',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Acciones rápidas
          Text('Acciones rápidas', style: AppTextStyles.heading3),
          const SizedBox(height: AppSizes.md),
          _ActionTile(
            icon: Icons.person_add,
            color: AppColors.primary,
            title: 'Solicitudes pendientes',
            subtitle: 'Aprobar o rechazar residentes',
            onTap: () => context.push('/admin/pending'),
          ),
          _ActionTile(
            icon: Icons.settings,
            color: AppColors.textSecondary,
            title: 'Configuración de comunidad',
            subtitle: 'Nombre, código de invitación, estrato',
            onTap: () {},
          ),
          _ActionTile(
            icon: Icons.push_pin,
            color: AppColors.warning,
            title: 'Crear post fijado',
            subtitle: 'Publicar un aviso importante',
            onTap: () => context.push('/feed/create'),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF60A5FA)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF60A5FA), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
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
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}
