import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_colors.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';

/// Tarjeta única de "código de invitación" — consolida 3 implementaciones
/// distintas que existían por feature (fondo sólido, gradiente con
/// acciones, gradiente solo lectura) en una sola, con el mismo gradiente
/// de marca (`AppColors.adminBannerGradientStart/End`).
///
/// [compact] usa un layout en fila (ícono + código + botón copiar), pensado
/// para aparecer dentro de una lista de detalles. El modo por defecto es un
/// banner con el código grande y botones Copiar/Rotar debajo.
class InviteCodeCard extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;
  final VoidCallback? onRotate;
  final bool rotating;
  final bool compact;

  const InviteCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
    this.onRotate,
    this.rotating = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.adminBannerGradientStart,
            AppColors.adminBannerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: compact ? _buildCompact() : _buildBanner(),
    );
  }

  Widget _buildCompact() {
    return Row(
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
                code.isEmpty ? '------' : code,
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
          onPressed: onCopy,
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CÓDIGO DE INVITACIÓN',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white70,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          code.isEmpty ? '------' : code,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, color: Colors.white),
                label: const Text(
                  'Copiar',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                ),
              ),
            ),
            if (onRotate != null) ...[
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: rotating ? null : onRotate,
                  icon: rotating
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Rotar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
