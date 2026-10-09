import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';

class OfflinePaymentNotice extends StatelessWidget {
  const OfflinePaymentNotice({
    super.key,
    this.message =
        'Solicita a la administración los datos vigentes para realizar la transferencia y registrar el pago.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.info.withValues(alpha: .28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, color: AppColors.info),
              SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  'Pago coordinado con administración',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(message),
          const SizedBox(height: AppSizes.sm),
          OutlinedButton.icon(
            onPressed: () => context.push(
              '/premium/pqrs/create?type=petition&category=administration',
            ),
            icon: const Icon(Icons.support_agent_outlined),
            label: const Text('Solicitar datos de pago'),
          ),
        ],
      ),
    );
  }
}
