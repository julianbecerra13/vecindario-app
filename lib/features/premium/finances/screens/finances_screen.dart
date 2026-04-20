import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/extensions/datetime_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/premium/models/finance_model.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/features/stores/models/order_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/services/payment_service.dart';
import 'package:vecindario_app/shared/widgets/loading_indicator.dart';

class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    return isAdmin ? const _AdminFinancesView() : const _ResidentFinancesView();
  }
}

// ==================== VISTA ADMIN ====================
class _AdminFinancesView extends ConsumerWidget {
  const _AdminFinancesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financesAsync = ref.watch(financesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Financiero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () {
              context.showSuccessSnackBar('Generando reporte PDF...');
            },
          ),
        ],
      ),
      body: financesAsync.when(
        data: (entries) {
          final incomes = entries
              .where((e) => e.type == FinanceType.income)
              .fold(0, (sum, e) => sum + e.amount);
          final expenses = entries
              .where((e) => e.type == FinanceType.expense)
              .fold(0, (sum, e) => sum + e.amount);
          final balance = incomes - expenses;

          // Agrupar por categoría para el gráfico
          final expenseByCategory = <String, int>{};
          final budgetByCategory = <String, int>{};
          for (final e in entries.where((e) => e.type == FinanceType.expense)) {
            expenseByCategory[e.category] =
                (expenseByCategory[e.category] ?? 0) + e.amount;
          }
          // Presupuesto estimado (1.3x del gasto real como placeholder)
          for (final cat in expenseByCategory.keys) {
            budgetByCategory[cat] = (expenseByCategory[cat]! * 1.3).round();
          }

          // Tasa de recaudo (ingresos / (ingresos + cartera))
          final recaudoRate = incomes > 0
              ? (incomes / (incomes + expenses * 0.1))
              : 0.0;

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Stats
              Row(
                children: [
                  _FinanceStatCard(
                    label: 'Ingresos',
                    amount: incomes,
                    color: AppColors.success,
                    icon: Icons.arrow_downward,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _FinanceStatCard(
                    label: 'Egresos',
                    amount: expenses,
                    color: AppColors.error,
                    icon: Icons.arrow_upward,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: AppSizes.paddingCard,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      formatCOP(balance),
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Gráfico Presupuesto vs Ejecución
              if (expenseByCategory.isNotEmpty) ...[
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Presupuesto vs. Ejecución',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _BudgetVsExecutionChart(
                    categories: expenseByCategory.keys.toList(),
                    budget: budgetByCategory,
                    executed: expenseByCategory,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ChartLegend(
                      color: AppColors.primary,
                      label: 'Presupuesto',
                    ),
                    const SizedBox(width: AppSizes.md),
                    _ChartLegend(color: AppColors.success, label: 'Ejecutado'),
                  ],
                ),
              ],

              // Tasa de recaudo
              const SizedBox(height: AppSizes.lg),
              Text('Cartera', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: AppSizes.paddingCard,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tasa de recaudo',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(recaudoRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cartera morosa',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              formatCOP((expenses * 0.1).round()),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: recaudoRate.clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        color: AppColors.success,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),
              Text('Movimientos', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.md),
              ...entries.map((e) => _FinanceEntryTile(entry: e)),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ==================== GRÁFICO ====================
class _BudgetVsExecutionChart extends StatelessWidget {
  final List<String> categories;
  final Map<String, int> budget;
  final Map<String, int> executed;

  const _BudgetVsExecutionChart({
    required this.categories,
    required this.budget,
    required this.executed,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      ...budget.values,
      ...executed.values,
    ].fold(0, (a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < categories.length) {
                  final label = categories[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label.length > 6 ? '${label.substring(0, 6)}.' : label,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textHint,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(categories.length, (i) {
          final cat = categories[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: (budget[cat] ?? 0).toDouble(),
                color: AppColors.primary,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: (executed[cat] ?? 0).toDouble(),
                color: AppColors.success,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
        ),
      ],
    );
  }
}

// ==================== VISTA RESIDENTE ====================
class _ResidentFinancesView extends ConsumerWidget {
  const _ResidentFinancesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementAsync = ref.watch(myAccountStatementProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Estado de Cuenta')),
      body: statementAsync.when(
        data: (statement) {
          if (statement == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: AppColors.textHint,
                    ),
                    SizedBox(height: AppSizes.md),
                    Text(
                      'Estado de cuenta no disponible',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Saldo
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: statement.isUpToDate
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Saldo actual',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      formatCOP(statement.balance),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: statement.isUpToDate
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    if (statement.isUpToDate)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Estás al día',
                            style: TextStyle(color: AppColors.success),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!statement.isUpToDate) ...[
                const SizedBox(height: AppSizes.md),
                PaymentButton(
                  label: 'Pagar cuota pendiente',
                  amountCOP: statement.balance,
                  reference: PaymentService.generateReference(
                    PaymentType.cuota,
                    currentUser?.id ?? '',
                  ),
                  type: PaymentType.cuota,
                  customerEmail: currentUser?.email ?? '',
                ),
              ],
              const SizedBox(height: AppSizes.lg),
              Text('Historial', style: AppTextStyles.heading3),
              const SizedBox(height: AppSizes.md),
              ...statement.items.map((item) => _StatementItemTile(item: item)),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// ==================== WIDGETS COMPARTIDOS ====================
class _FinanceStatCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  const _FinanceStatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppSizes.paddingCard,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              formatCOP(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceEntryTile extends StatelessWidget {
  final FinanceEntryModel entry;

  const _FinanceEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(entry.type.icon, size: 18, color: entry.type.color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.category} \u00b7 ${entry.date.formatDateShort}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '${entry.type == FinanceType.expense ? "-" : "+"}${formatCOP(entry.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: entry.type.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementItemTile extends StatelessWidget {
  final StatementItem item;

  const _StatementItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPaid = item.status == 'paid';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        title: Text(item.concept, style: AppTextStyles.bodySmall),
        subtitle: Text(item.date.formatDateShort, style: AppTextStyles.caption),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCOP(item.amount),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isPaid ? AppColors.success : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                isPaid ? 'Pagado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
