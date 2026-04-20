import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';
import 'package:vecindario_app/core/theme/text_styles.dart';
import 'package:vecindario_app/features/auth/providers/auth_notifier.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizes.paddingAll,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Tu solicitud está en revisión',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'El administrador de tu conjunto revisará tu solicitud pronto. Te notificaremos cuando seas aprobado.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              userAsync.when(
                data: (user) {
                  if (user == null) return const SizedBox.shrink();
                  return Container(
                    padding: AppSizes.paddingAll,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Nombre', user.displayName),
                        const SizedBox(height: AppSizes.sm),
                        _infoRow('Torre', user.tower ?? '-'),
                        const SizedBox(height: AppSizes.sm),
                        _infoRow('Apartamento', user.apartment ?? '-'),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).logout(),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.buttonHeight,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
