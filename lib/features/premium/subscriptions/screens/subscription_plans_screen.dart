import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/subscriptions/models/subscription_model.dart';
import 'package:vecindario_app/features/premium/subscriptions/repositories/subscription_repository.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/widgets/app_card.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.subscriptionPlansTitle)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              children: [
                Text(
                  context.l10n.subscriptionTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  context.l10n.subscriptionFirstMonthFree,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                _PlanCard(
                  plan: SubscriptionPlan.starter,
                  units: context.l10n.subscriptionUnitsStarter,
                  features: [
                    _Feature(
                      context.l10n.subscriptionFeatureCircularsTracking,
                      true,
                    ),
                    _Feature(context.l10n.subscriptionFeaturePqrsSla, true),
                    _Feature(context.l10n.subscriptionFeatureManual, true),
                    _Feature(
                      context.l10n.subscriptionFeatureFineManagement,
                      true,
                    ),
                    _Feature(context.l10n.subscriptionFeatureAmenities, false),
                    _Feature(context.l10n.subscriptionFeatureFinances, false),
                  ],
                  onSubscribe: () => _startTrial(SubscriptionPlan.starter),
                ),
                const SizedBox(height: AppSizes.md),
                _PlanCard(
                  plan: SubscriptionPlan.professional,
                  units: context.l10n.subscriptionUnitsProfessional,
                  isPopular: true,
                  features: [
                    _Feature(context.l10n.subscriptionFeatureAllStarter, true),
                    _Feature(
                      context.l10n.subscriptionFeatureAmenitiesBooking,
                      true,
                    ),
                    _Feature(
                      context.l10n.subscriptionFeatureOnlinePayments,
                      true,
                    ),
                    _Feature(
                      context.l10n.subscriptionFeatureFinanceDashboard,
                      true,
                    ),
                    _Feature(
                      context.l10n.subscriptionFeatureIndividualStatement,
                      true,
                    ),
                    _Feature(context.l10n.subscriptionFeatureAssemblies, false),
                  ],
                  onSubscribe: () => _startTrial(SubscriptionPlan.professional),
                ),
                const SizedBox(height: AppSizes.md),
                _PlanCard(
                  plan: SubscriptionPlan.enterprise,
                  units: context.l10n.subscriptionUnitsEnterprise,
                  features: [
                    _Feature(
                      context.l10n.subscriptionFeatureAllProfessional,
                      true,
                    ),
                    _Feature(
                      context.l10n.subscriptionFeatureAssembliesVoting,
                      true,
                    ),
                    _Feature(context.l10n.subscriptionFeaturePdfReports, true),
                    _Feature(
                      context.l10n.subscriptionFeatureAccountingApi,
                      true,
                    ),
                    _Feature(
                      context.l10n.subscriptionFeaturePrioritySupport,
                      true,
                    ),
                  ],
                  onSubscribe: () => _startTrial(SubscriptionPlan.enterprise),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  context.l10n.subscriptionAnnualDiscount,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _startTrial(SubscriptionPlan plan) async {
    if (_isLoading) return;

    final user = ref.read(currentUserProvider).value;
    final communityId = ref.read(currentCommunityIdProvider);
    if (user == null || communityId == null) {
      context.showErrorSnackBar(context.l10n.errorUserOrCommunityUnavailable);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .startTrial(communityId: communityId, plan: plan, adminUid: user.id);
      if (!mounted) return;
      context.showSuccessSnackBar(
        context.l10n.subscriptionTrialActivated(plan.label),
      );
      context.go('/premium/dashboard');
    } on StateError catch (e) {
      if (mounted) context.showErrorSnackBar(e.message);
    } on FirebaseException catch (e) {
      if (mounted) {
        final msg = e.code == 'permission-denied'
            ? context.l10n.subscriptionOnlyAdminsCanActivate
            : context.l10n.subscriptionActivationError(e.message ?? '');
        context.showErrorSnackBar(msg);
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(context.l10n.errorUnexpected(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _Feature {
  final String text;
  final bool included;
  const _Feature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String units;
  final bool isPopular;
  final List<_Feature> features;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.units,
    this.isPopular = false,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        borderColor: isPopular
            ? AppColors.success.withValues(alpha: 0.5)
            : context.colors.border,
        borderWidth: isPopular ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.label, style: AppTextStyles.heading3),
                if (isPopular) ...[
                  const SizedBox(width: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      context.l10n.subscriptionPopular,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(units, style: AppTextStyles.caption),
            const SizedBox(height: AppSizes.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${_formatPrice(plan.priceCOP)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    context.l10n.subscriptionPerMonth,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      f.included ? Icons.check : Icons.close,
                      size: 16,
                      color: f.included
                          ? AppColors.success
                          : context.colors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: f.included
                            ? context.colors.textPrimary
                            : context.colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular
                      ? AppColors.success
                      : AppColors.primary,
                ),
                child: Text(context.l10n.subscriptionTry30DaysFree),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
