import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

final _communityDetailProvider = StreamProvider.family<CommunityModel?, String>(
  (ref, communityId) {
    return ref
        .watch(firestoreProvider)
        .collection('communities')
        .doc(communityId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return CommunityModel.fromFirestore(doc.data()!, doc.id);
        });
  },
);

final _communitySubscriptionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, communityId) {
      return ref
          .watch(firestoreProvider)
          .collection('subscriptions')
          .doc(communityId)
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);
    });

class CommunityDetailAdminScreen extends ConsumerWidget {
  final String communityId;
  const CommunityDetailAdminScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(_communityDetailProvider(communityId));
    final subscriptionAsync = ref.watch(
      _communitySubscriptionProvider(communityId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de comunidad')),
      body: communityAsync.when(
        data: (c) {
          if (c == null) {
            return const Center(child: Text('Comunidad no encontrada'));
          }
          final subscription = subscriptionAsync.valueOrNull;
          return ListView(
            padding: AppSizes.paddingAll,
            children: [
              _Header(community: c, subscription: subscription),
              const SizedBox(height: AppSizes.lg),
              _InviteCodeCard(code: c.inviteCode),
              const SizedBox(height: AppSizes.lg),
              Text('Información', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.sm),
              _InfoRow(label: 'Dirección', value: c.address),
              _InfoRow(label: 'Ciudad', value: c.city),
              _InfoRow(label: 'Estrato', value: c.estratoLabel),
              _InfoRow(label: 'Tipo unidad', value: c.unitType.label),
              _InfoRow(label: 'Residentes', value: '${c.memberCount}'),
              _InfoRow(
                label: 'Admin UID',
                value: c.adminUid.isEmpty ? 'Sin asignar' : c.adminUid,
                mono: true,
              ),
              _InfoRow(label: 'ID comunidad', value: c.id, mono: true),
              _InfoRow(label: 'Creada', value: _formatDate(c.createdAt)),
              const SizedBox(height: AppSizes.lg),
              Text('Suscripción', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.sm),
              if (subscription == null)
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.textHint),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'Sin Vecindario Admin activo. El admin puede activar el trial o tú puedes activar un plan aquí.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _InfoRow(
                  label: 'Plan',
                  value: (subscription['plan'] as String? ?? '-').toUpperCase(),
                ),
                _InfoRow(
                  label: 'Estado',
                  value: subscription['status'] as String? ?? '-',
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              Text('Acciones', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.sm),
              _ActionTile(
                icon: Icons.person_add,
                title: 'Asignar administrador',
                subtitle:
                    'Ingresa el UID del usuario que gestionará la comunidad',
                onTap: () => _showAssignAdminDialog(context, ref, c),
              ),
              _ActionTile(
                icon: Icons.workspace_premium,
                title: 'Activar plan',
                subtitle: 'Starter, Profesional o Enterprise (trial o activo)',
                onTap: () => _showActivatePlanDialog(context, ref, c),
              ),
              _ActionTile(
                icon: Icons.delete_outline,
                title: 'Eliminar comunidad',
                subtitle: 'Acción irreversible. No borra usuarios.',
                color: AppColors.error,
                onTap: () => _confirmDelete(context, ref, c),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _showAssignAdminDialog(
    BuildContext context,
    WidgetRef ref,
    CommunityModel c,
  ) {
    final uidController = TextEditingController(text: c.adminUid);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Asignar Admin — ${c.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el UID del usuario que será administrador. Puedes encontrarlo en Firebase Auth.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                labelText: 'UID del usuario',
                border: OutlineInputBorder(),
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
            onPressed: () async {
              final uid = uidController.text.trim();
              if (uid.isEmpty) return;
              try {
                final fs = ref.read(firestoreProvider);
                await fs.collection('communities').doc(c.id).update({
                  'adminUid': uid,
                });
                await fs.collection('users').doc(uid).update({
                  'role': 'admin',
                  'communityId': c.id,
                  'verified': true,
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  context.showSuccessSnackBar('Admin asignado');
                }
              } catch (e) {
                if (ctx.mounted) {
                  context.showErrorSnackBar('Error: $e');
                }
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _showActivatePlanDialog(
    BuildContext context,
    WidgetRef ref,
    CommunityModel c,
  ) {
    String selectedPlan = 'starter';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Activar Plan — ${c.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['starter', 'professional', 'enterprise'].map((plan) {
                return RadioListTile<String>(
                  title: Text(plan[0].toUpperCase() + plan.substring(1)),
                  subtitle: Text(
                    plan == 'starter'
                        ? '\$150.000/mes'
                        : plan == 'professional'
                        ? '\$350.000/mes'
                        : '\$600.000/mes',
                  ),
                  value: plan,
                  groupValue: selectedPlan,
                  onChanged: (v) =>
                      setDialogState(() => selectedPlan = v ?? 'starter'),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final fs = ref.read(firestoreProvider);
                  final now = DateTime.now();
                  await fs.collection('subscriptions').doc(c.id).set({
                    'plan': selectedPlan,
                    'status': 'trial',
                    'trialStartedAt': Timestamp.fromDate(now),
                    'trialEndsAt': Timestamp.fromDate(
                      now.add(const Duration(days: 30)),
                    ),
                    'createdAt': Timestamp.fromDate(now),
                    'createdBy': 'super_admin',
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    context.showSuccessSnackBar(
                      'Plan $selectedPlan activado (trial 30 días gratis)',
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    context.showErrorSnackBar('Error: $e');
                  }
                }
              },
              child: const Text('Activar Trial'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CommunityModel c,
  ) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Eliminar comunidad',
      message:
          '¿Seguro? Se eliminará el documento de "${c.name}" y su suscripción. Los usuarios NO se eliminan (quedan sin comunidad).',
      confirmText: 'Eliminar',
      isDestructive: true,
    );
    if (!confirm) return;

    try {
      final fs = ref.read(firestoreProvider);
      await fs.collection('communities').doc(c.id).delete();
      await fs.collection('subscriptions').doc(c.id).delete();
      if (context.mounted) {
        context.showSuccessSnackBar('Comunidad eliminada');
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Error: $e');
      }
    }
  }
}

class _Header extends StatelessWidget {
  final CommunityModel community;
  final Map<String, dynamic>? subscription;
  const _Header({required this.community, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final plan = subscription?['plan'] as String?;
    final status = subscription?['status'] as String?;
    final isActive = status == 'active' || status == 'trial';

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(community.name, style: AppTextStyles.heading2),
              ),
              if (plan != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.success : AppColors.textHint,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    plan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '${community.address} · ${community.city}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _InviteCodeCard extends StatelessWidget {
  final String code;
  const _InviteCodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF1A2744)],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.vpn_key, color: Colors.white),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CÓDIGO DE INVITACIÓN',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              context.showSuccessSnackBar('Código copiado');
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;
  const _InfoRow({required this.label, required this.value, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? const TextStyle(fontFamily: 'monospace', fontSize: 12)
                  : AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: c),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
