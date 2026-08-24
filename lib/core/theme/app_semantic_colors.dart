import 'package:flutter/material.dart';

/// Tokens de color que sí cambian entre modo claro y oscuro (fondos,
/// superficies, texto, bordes). Los colores de marca (primary, secondary,
/// success, warning, error) NO cambian con el tema y siguen viviendo en
/// `AppColors` como constantes fijas.
///
/// Se accede vía `Theme.of(context).extension<AppSemanticColors>()!`, o el
/// atajo `context.colors` (`lib/core/extensions/context_extensions.dart`).
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color borderLight;
  final Color divider;

  const AppSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.borderLight,
    required this.divider,
  });

  static const dark = AppSemanticColors(
    background: Color(0xFF0A0A0F),
    surface: Color(0xFF111118),
    surfaceVariant: Color(0xFF1A1A24),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textHint: Color(0xFF6B7280),
    border: Color(0xFF2A2A3A),
    borderLight: Color(0xFF1E1E2E),
    divider: Color(0xFF1E1E2E),
  );

  static const light = AppSemanticColors(
    background: Color(0xFFF9FAFB),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF3F4F6),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textHint: Color(0xFF9CA3AF),
    border: Color(0xFFE5E7EB),
    borderLight: Color(0xFFF3F4F6),
    divider: Color(0xFFE5E7EB),
  );

  @override
  AppSemanticColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? borderLight,
    Color? divider,
  }) {
    return AppSemanticColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
