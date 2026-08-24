import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_provider.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/app_card.dart';

class PremiumDashboardScreen extends ConsumerWidget {
  const PremiumDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final isPremium = ref.watch(isPremiumProvider).value ?? false;
    final plan = ref.watch(subscriptionPlanProvider).value;

    if (!isPremium) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.premiumDashboardTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: context.colors.textHint,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  context.l10n.premiumDashboardTitle,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.l10n.premiumNotActive,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: AppSizes.lg),
                ElevatedButton(
                  onPressed: () => context.push('/premium/plans'),
                  child: Text(context.l10n.premiumViewPlans),
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
            Text(context.l10n.premiumDashboardTitle),
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
          // === STATS REALES (solo admin) ===
          if (isAdmin) ...[
            _AdminStats(),
            const SizedBox(height: AppSizes.lg),
            // Acciones rápidas (cards full-width como en diseño .pen)
            Text(
              context.l10n.premiumQuickActions,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.textHint,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            _QuickActionCard(
              icon: Icons.campaign,
              color: AppColors.info,
              title: context.l10n.circularCreateTitle,
              subtitle: context.l10n.premiumSendOfficialNotice,
              onTap: () => context.push('/premium/circulars/create'),
            ),
            _QuickActionCard(
              icon: Icons.warning_amber,
              color: AppColors.error,
              title: context.l10n.fineCreateTitle,
              subtitle: context.l10n.premiumCreateSanctionWithEvidence,
              onTap: () => context.push('/premium/fines/create'),
            ),
            _QuickActionCard(
              icon: Icons.account_balance,
              color: AppColors.success,
              title: context.l10n.financeDashboardTitle,
              subtitle: context.l10n.financeBudgetVsExecution,
              onTap: () => context.push('/premium/finances'),
            ),
            _QuickActionCard(
              icon: Icons.how_to_vote,
              color: const Color(0xFF8B5CF6),
              title: context.l10n.assemblyConveneTitle,
              subtitle: context.l10n.premiumCreateConvocationWithAgenda,
              onTap: () => context.push('/premium/assemblies'),
            ),
            const SizedBox(height: AppSizes.md),
          ],

          // === MÓDULOS ===
          Text(
            context.l10n.premiumModules,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textHint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          if (isFeatureAvailable(plan, 'circulars'))
            _ModuleTile(
              icon: Icons.campaign,
              color: AppColors.info,
              title: context.l10n.circularScreenTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumCircularsAdminSubtitle
                  : context.l10n.premiumCircularsResidentSubtitle,
              onTap: () => context.push('/premium/circulars'),
            ),
          if (isFeatureAvailable(plan, 'fines'))
            _ModuleTile(
              icon: Icons.gavel,
              color: AppColors.warning,
              title: isAdmin
                  ? context.l10n.fineManagementTitle
                  : context.l10n.fineMyTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumFinesAdminSubtitle
                  : context.l10n.premiumFinesResidentSubtitle,
              onTap: () => context.push('/premium/fines'),
            ),
          if (isFeatureAvailable(plan, 'pqrs'))
            _ModuleTile(
              icon: Icons.assignment,
              color: AppColors.primary,
              title: context.l10n.pqrsScreenTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumPqrsAdminSubtitle
                  : context.l10n.premiumPqrsResidentSubtitle,
              onTap: () => context.push('/premium/pqrs'),
            ),
          if (isFeatureAvailable(plan, 'manual'))
            _ModuleTile(
              icon: Icons.menu_book,
              color: const Color(0xFF8B5CF6),
              title: context.l10n.manualScreenTitle,
              subtitle: context.l10n.premiumManualSubtitle,
              onTap: () => context.push('/premium/manual'),
            ),
          if (isFeatureAvailable(plan, 'amenities'))
            _ModuleTile(
              icon: Icons.pool,
              color: const Color(0xFF06B6D4),
              title: context.l10n.amenityScreenTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumAmenitiesAdminSubtitle
                  : context.l10n.premiumAmenitiesResidentSubtitle,
              onTap: () => context.push('/premium/amenities'),
            ),
          if (isFeatureAvailable(plan, 'finances'))
            _ModuleTile(
              icon: Icons.account_balance,
              color: AppColors.success,
              title: isAdmin
                  ? context.l10n.financeDashboardTitle
                  : context.l10n.financeStatementTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumFinancesAdminSubtitle
                  : context.l10n.premiumFinancesResidentSubtitle,
              onTap: () => context.push('/premium/finances'),
            ),
          if (isFeatureAvailable(plan, 'assemblies'))
            _ModuleTile(
              icon: Icons.how_to_vote,
              color: AppColors.error,
              title: context.l10n.assemblyScreenTitle,
              subtitle: isAdmin
                  ? context.l10n.premiumAssembliesAdminSubtitle
                  : context.l10n.premiumAssembliesResidentSubtitle,
              onTap: () => context.push('/premium/assemblies'),
            ),
        ],
      ),
    );
  }
}

class _AdminStats extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(currentCommunityProvider).value;
    final pqrsAsync = ref.watch(allPqrsProvider);
    final financesAsync = ref.watch(financesProvider);

    final memberCount = community?.memberCount ?? 0;

    final openPqrs =
        pqrsAsync.whenOrNull(
          data: (list) => list
              .where(
                (p) => p.status.name != 'resolved' && p.status.name != 'closed',
              )
              .length,
        ) ??
        0;

    final monthIncome =
        financesAsync.whenOrNull(
          data: (list) => list
              .where((e) => e.type == FinanceType.income)
              .fold(0, (sum, e) => sum + e.amount),
        ) ??
        0;

    return Row(
      children: [
        _StatCard(
          value: '$memberCount',
          label: context.l10n.premiumResidents,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSizes.sm),
        _StatCard(
          value: '$openPqrs',
          label: context.l10n.premiumOpenPqrs,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSizes.sm),
        _StatCard(
          value: formatCOP(monthIncome),
          label: context.l10n.premiumMonthlyRevenue,
          color: AppColors.success,
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
      child: AppCard(
        accentColor: color,
        padding: const EdgeInsets.all(AppSizes.sm + 2),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: context.colors.textHint),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: context.colors.textHint),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.colors.textHint,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
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
        trailing: Icon(Icons.chevron_right, color: context.colors.textHint),
      ),
    );
  }
}
