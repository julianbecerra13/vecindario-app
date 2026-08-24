import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/super_admin/providers/super_admin_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
import 'package:vecindario_app/shared/widgets/confirm_dialog.dart';
import 'package:vecindario_app/shared/widgets/invite_code_card.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

final _communityDetailProvider = StreamProvider.family<CommunityModel?, String>(
  (ref, communityId) {
    return ref.watch(superAdminRepositoryProvider).watchCommunity(communityId);
  },
);

final _communitySubscriptionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, communityId) {
      return ref
          .watch(superAdminRepositoryProvider)
          .watchSubscription(communityId);
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
      appBar: AppBar(title: Text(context.l10n.superAdminCommunityDetailTitle)),
      body: communityAsync.when(
        data: (c) {
          if (c == null) {
            return Center(child: Text(context.l10n.adminCommunityNotFound));
          }
          final subscription = subscriptionAsync.valueOrNull;
          return ListView(
            padding: AppSizes.paddingAll,
            children: [
              _Header(community: c, subscription: subscription),
              const SizedBox(height: AppSizes.lg),
              InviteCodeCard(
                code: c.inviteCode,
                compact: true,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: c.inviteCode));
                  context.showSuccessSnackBar(context.l10n.adminCodeCopied);
                },
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                context.l10n.superAdminInfoTitle,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.sm),
              _InfoRow(label: context.l10n.adminAddressLabel, value: c.address),
              _InfoRow(label: context.l10n.adminCityLabel, value: c.city),
              _InfoRow(
                label: context.l10n.adminEstratoLabel,
                value: c.estratoLabel,
              ),
              _InfoRow(
                label: context.l10n.superAdminUnitTypeLabel,
                value: c.unitType.label,
              ),
              _InfoRow(
                label: context.l10n.adminResidentsLabel,
                value: '${c.memberCount}',
              ),
              _InfoRow(
                label: context.l10n.superAdminAdminUidLabel,
                value: c.adminUid.isEmpty
                    ? context.l10n.superAdminUnassigned
                    : c.adminUid,
                mono: true,
              ),
              _InfoRow(
                label: context.l10n.superAdminCommunityIdLabel,
                value: c.id,
                mono: true,
              ),
              _InfoRow(
                label: context.l10n.superAdminCreatedLabel,
                value: _formatDate(c.createdAt),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                context.l10n.superAdminSubscriptionTitle,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.sm),
              if (subscription == null)
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: context.colors.textHint.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: context.colors.textHint),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          context.l10n.superAdminNoActivePlanMessage,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                _InfoRow(
                  label: context.l10n.superAdminPlanLabel,
                  value: (subscription['plan'] as String? ?? '-').toUpperCase(),
                ),
                _InfoRow(
                  label: context.l10n.superAdminStatusLabel,
                  value: subscription['status'] as String? ?? '-',
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              Text(
                context.l10n.superAdminActionsTitle,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppSizes.sm),
              _ActionTile(
                icon: Icons.person_add,
                title: context.l10n.superAdminAssignAdminAction,
                subtitle: context.l10n.superAdminAssignAdminSubtitle,
                onTap: () => _showAssignAdminDialog(context, ref, c),
              ),
              _ActionTile(
                icon: Icons.workspace_premium,
                title: context.l10n.superAdminActivatePlanAction,
                subtitle: context.l10n.superAdminActivatePlanSubtitle,
                onTap: () => _showActivatePlanDialog(context, ref, c),
              ),
              _ActionTile(
                icon: Icons.delete_outline,
                title: context.l10n.superAdminDeleteCommunityAction,
                subtitle: context.l10n.superAdminDeleteCommunitySubtitle,
                color: AppColors.error,
                onTap: () => _confirmDelete(context, ref, c),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            Center(child: Text(context.l10n.adminGenericError('$e'))),
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
        title: Text(context.l10n.superAdminAssignAdminDialogTitle(c.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.superAdminAssignAdminDialogMessage,
              style: TextStyle(fontSize: 13, color: ctx.colors.textSecondary),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: uidController,
              decoration: InputDecoration(
                labelText: context.l10n.superAdminUidLabel,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final uid = uidController.text.trim();
              if (uid.isEmpty) return;
              try {
                await ref
                    .read(superAdminRepositoryProvider)
                    .assignAdmin(communityId: c.id, uid: uid);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  context.showSuccessSnackBar(
                    context.l10n.superAdminAdminAssigned,
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  context.showErrorSnackBar(
                    context.l10n.adminGenericError('$e'),
                  );
                }
              }
            },
            child: Text(context.l10n.superAdminAssignAction),
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
          title: Text(context.l10n.superAdminActivatePlanDialogTitle(c.name)),
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
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(superAdminRepositoryProvider)
                      .activatePlan(communityId: c.id, plan: selectedPlan);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    context.showSuccessSnackBar(
                      context.l10n.superAdminPlanActivatedMessage(selectedPlan),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    context.showErrorSnackBar(
                      context.l10n.adminGenericError('$e'),
                    );
                  }
                }
              },
              child: Text(context.l10n.superAdminActivateTrialAction),
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
      title: context.l10n.superAdminDeleteCommunityAction,
      message: context.l10n.superAdminDeleteCommunityMessage(c.name),
      confirmText: context.l10n.delete,
      isDestructive: true,
    );
    if (!confirm) return;

    try {
      await ref.read(superAdminRepositoryProvider).deleteCommunity(c.id);
      if (context.mounted) {
        context.showSuccessSnackBar(context.l10n.superAdminCommunityDeleted);
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(context.l10n.adminGenericError('$e'));
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
                    color: isActive
                        ? AppColors.success
                        : context.colors.textHint,
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
                color: context.colors.textHint,
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
