import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/l10n_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class AccountStatementScreen extends ConsumerWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementAsync = ref.watch(myAccountStatementProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.financeStatementTitle)),
      body: statementAsync.when(
        data: (statement) {
          if (statement == null) {
            return Center(
              child: Text(context.l10n.financeStatementUnavailable),
            );
          }
          return SingleChildScrollView(
            padding: AppSizes.paddingAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saldo actual
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    color: statement.balance <= 0
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: statement.balance <= 0
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.financeCurrentBalance,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '\$${_formatNumber(statement.balance.abs())}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: statement.balance <= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        statement.balance <= 0
                            ? context.l10n.financeUpToDate
                            : context.l10n.financePendingBalance,
                        style: TextStyle(
                          fontSize: 13,
                          color: statement.balance <= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Botón de pagar cuota
                if (statement.balance > 0)
                  PaymentButton(
                    label: context.l10n.financePayFee,
                    amountCOP: statement.balance,
                    reference: PaymentService.generateReference(
                      PaymentType.cuota,
                      currentUser?.id ?? '',
                    ),
                    type: PaymentType.cuota,
                    customerEmail: currentUser?.email ?? '',
                  ),

                const SizedBox(height: AppSizes.xl),

                // Historial
                Text(
                  context.l10n.financeHistory,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.md),

                if (statement.items.isEmpty)
                  Text(
                    context.l10n.financeNoMovements,
                    style: TextStyle(color: context.colors.textHint),
                  )
                else
                  ...statement.items.map(
                    (item) => _StatementItemTile(item: item),
                  ),

                const SizedBox(height: AppSizes.xl),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text(context.l10n.errorGeneric(e))),
      ),
    );
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _StatementItemTile extends StatelessWidget {
  final StatementItem item;

  const _StatementItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPaid = item.status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.concept,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: item.concept.toLowerCase().contains('multa')
                        ? AppColors.error
                        : context.colors.textPrimary,
                  ),
                ),
                Text(
                  '${item.date.day}/${item.date.month}/${item.date.year}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-\$${item.amount}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPaid ? AppColors.success : AppColors.error,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  isPaid
                      ? context.l10n.financePaid
                      : context.l10n.financePending,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
