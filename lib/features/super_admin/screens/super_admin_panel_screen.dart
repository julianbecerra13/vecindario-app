import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

// === PROVIDERS ===

final allCommunitiesProvider = StreamProvider<List<CommunityModel>>((ref) {
  return ref.watch(firestoreProvider)
      .collection('communities')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => CommunityModel.fromFirestore(doc.data(), doc.id))
          .toList());
});

final communityUsersCountProvider =
    FutureProvider.family<int, String>((ref, communityId) async {
  final snap = await ref.watch(firestoreProvider)
      .collection('users')
      .where('communityId', isEqualTo: communityId)
      .where('verified', isEqualTo: true)
      .count()
      .get();
  return snap.count ?? 0;
});

final allSubscriptionsProvider =
    StreamProvider<Map<String, Map<String, dynamic>>>((ref) {
  return ref.watch(firestoreProvider)
      .collection('subscriptions')
      .snapshots()
      .map((snap) {
    final map = <String, Map<String, dynamic>>{};
    for (final doc in snap.docs) {
      map[doc.id] = doc.data();
    }
    return map;
  });
});

// === PANTALLA PRINCIPAL ===

class SuperAdminPanelScreen extends ConsumerWidget {
  const SuperAdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    // Solo super_admin puede acceder
    if (user == null || user.role.toValue() != 'super_admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso denegado')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 64, color: AppColors.error),
              SizedBox(height: AppSizes.md),
              Text('No tienes permisos de Super Admin'),
            ],
          ),
        ),
      );
    }

    final communitiesAsync = ref.watch(allCommunitiesProvider);
    final subscriptions = ref.watch(allSubscriptionsProvider).value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUPER ADMIN',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.warning,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text('Panel Global'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Crear comunidad',
            onPressed: () => context.push('/super-admin/create-community'),
          ),
        ],
      ),
      body: communitiesAsync.when(
        data: (communities) {
          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: AppSizes.md),
                  const Text('No hay comunidades registradas'),
                  const SizedBox(height: AppSizes.lg),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/super-admin/create-community'),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear primera comunidad'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Stats globales
              _GlobalStats(communities: communities, subscriptions: subscriptions),
              const SizedBox(height: AppSizes.lg),

              Text(
                'COMUNIDADES (${communities.length})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              ...communities.map((c) => _CommunityCard(
                    community: c,
                    subscription: subscriptions[c.id],
                  )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

}

// === WIDGETS ===

class _GlobalStats extends StatelessWidget {
  final List<CommunityModel> communities;
  final Map<String, Map<String, dynamic>> subscriptions;

  const _GlobalStats({
    required this.communities,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final totalMembers =
        communities.fold(0, (sum, c) => sum + c.memberCount);
    final activeSubscriptions =
        subscriptions.values.where((s) => s['status'] == 'active' || s['status'] == 'trial').length;

    return Row(
      children: [
        _StatCard(
          value: '${communities.length}',
          label: 'Conjuntos',
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSizes.sm),
        _StatCard(
          value: '$totalMembers',
          label: 'Residentes',
          color: AppColors.success,
        ),
        const SizedBox(width: AppSizes.sm),
        _StatCard(
          value: '$activeSubscriptions',
          label: 'Suscripciones',
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends ConsumerWidget {
  final CommunityModel community;
  final Map<String, dynamic>? subscription;

  const _CommunityCard({
    required this.community,
    this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = subscription?['plan'] as String?;
    final status = subscription?['status'] as String?;
    final isActive = status == 'active' || status == 'trial';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: () =>
            context.push('/super-admin/community/${community.id}'),
        child: Padding(
        padding: AppSizes.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${community.address}, ${community.city}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (plan != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.textHint.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      plan.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.success
                            : AppColors.textHint,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.xs,
              children: [
                _InfoChip(
                  icon: Icons.people,
                  text: '${community.memberCount} residentes',
                ),
                _InfoChip(
                  icon: Icons.star,
                  text: community.estratoLabel,
                ),
                _InfoChip(
                  icon: Icons.home,
                  text: community.unitType.label,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vpn_key,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        community.inviteCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _showAssignAdminDialog(context, ref, community),
                  child: const Text('Asignar Admin'),
                ),
                TextButton(
                  onPressed: () =>
                      _showActivatePlanDialog(context, ref, community),
                  child: const Text('Plan'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showAssignAdminDialog(
      BuildContext context, WidgetRef ref, CommunityModel community) {
    final uidController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Asignar Admin — ${community.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el UID del usuario que será administrador del conjunto. '
              'Puedes encontrarlo en Firebase Auth.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                hintText: 'UID del usuario',
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
              final fs = ref.read(firestoreProvider);
              await fs.collection('communities').doc(community.id).update({
                'adminUid': uid,
              });
              await fs.collection('users').doc(uid).update({
                'role': 'admin',
                'communityId': community.id,
                'verified': true,
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.showSuccessSnackBar('Admin asignado');
              }
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _showActivatePlanDialog(
      BuildContext context, WidgetRef ref, CommunityModel community) {
    String selectedPlan = 'starter';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Activar Plan — ${community.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['starter', 'professional', 'enterprise'].map((plan) {
                return RadioListTile<String>(
                  title: Text(plan[0].toUpperCase() + plan.substring(1)),
                  subtitle: Text(plan == 'starter'
                      ? '\$150.000/mes'
                      : plan == 'professional'
                          ? '\$350.000/mes'
                          : '\$600.000/mes'),
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
                final fs = ref.read(firestoreProvider);
                final now = DateTime.now();
                await fs
                    .collection('subscriptions')
                    .doc(community.id)
                    .set({
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
              },
              child: const Text('Activar Trial'),
            ),
          ],
        ),
      ),
    );
  }

}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}
