import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/extensions/context_extensions.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';

class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planes Vecindario Admin')),
      body: SingleChildScrollView(
        padding: AppSizes.paddingAll,
        child: Column(
          children: [
            Text(
              'Digitaliza la gestión de tu conjunto',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Primer mes gratis',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Plan Starter
            _PlanCard(
              name: 'Starter',
              units: '1 - 50 unidades',
              price: 150000,
              features: const [
                _Feature('Circulares con tracking', true),
                _Feature('PQRS con SLA', true),
                _Feature('Manual de convivencia', true),
                _Feature('Gestión de multas', true),
                _Feature('Zonas sociales', false),
                _Feature('Finanzas', false),
              ],
              onSubscribe: () => _startTrial(context, 'starter'),
            ),

            const SizedBox(height: AppSizes.md),

            // Plan Profesional
            _PlanCard(
              name: 'Profesional',
              units: '51 - 150 unidades',
              price: 350000,
              isPopular: true,
              features: const [
                _Feature('Todo de Starter', true),
                _Feature('Reserva zonas sociales', true),
                _Feature('Pagos en línea', true),
                _Feature('Dashboard financiero', true),
                _Feature('Estado de cuenta individual', true),
                _Feature('Asambleas/votaciones', false),
              ],
              onSubscribe: () => _startTrial(context, 'professional'),
            ),

            const SizedBox(height: AppSizes.md),

            // Plan Enterprise
            _PlanCard(
              name: 'Enterprise',
              units: '151+ unidades',
              price: 600000,
              features: const [
                _Feature('Todo de Profesional', true),
                _Feature('Asambleas + votaciones', true),
                _Feature('Reportes PDF automáticos', true),
                _Feature('API contable (Siigo)', true),
                _Feature('Soporte prioritario', true),
              ],
              onSubscribe: () => _startTrial(context, 'enterprise'),
            ),

            const SizedBox(height: AppSizes.lg),
            Text(
              '20% descuento pago anual (2 meses gratis)',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  void _startTrial(BuildContext context, String plan) {
    context.showSuccessSnackBar(
      'Trial de 30 días activado para el plan ${plan.toUpperCase()}',
    );
  }
}

class _Feature {
  final String text;
  final bool included;
  const _Feature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String units;
  final int price;
  final bool isPopular;
  final List<_Feature> features;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.name,
    required this.units,
    required this.price,
    this.isPopular = false,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isPopular
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: AppTextStyles.heading3),
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
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
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
                '\$${_formatPrice(price)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/mes',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      f.included ? Icons.check : Icons.close,
                      size: 16,
                      color: f.included
                          ? AppColors.success
                          : AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: f.included
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              )),
          if (isPopular) ...[
            const SizedBox(height: AppSizes.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: const Text('Probar gratis 30 días'),
              ),
            ),
          ],
        ],
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
