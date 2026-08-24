import 'package:flutter/material.dart';
import 'package:vecindario_app/core/constants/app_sizes.dart';

/// Card compartida que hereda el `cardTheme` global (radius 12, superficie,
/// borde del tema) en vez de que cada feature reinvente su propio
/// Container+BoxDecoration con radius/color a mano.
///
/// [accentColor] pinta el fondo con un tinte suave del color dado (para el
/// patrón de "stat card" coloreada) sin salirse del radius del tema.
/// [borderColor]/[borderWidth] permiten un borde destacado (ej. plan
/// "popular") manteniendo el mismo radius que el resto de las cards.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSizes.md),
      child: child,
    );

    return Card(
      margin: margin,
      color: accentColor?.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      shape: borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              side: BorderSide(color: borderColor!, width: borderWidth),
            )
          : null,
      child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
    );
  }
}
