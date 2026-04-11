import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primarios (del diseño .pen)
  static const primary = Color(0xFF3B82F6);
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF2563EB);

  // Secundarios
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF059669);

  // Fondos (tema oscuro)
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF111118);
  static const surfaceVariant = Color(0xFF1A1A24);

  // Estados
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0x26EF4444);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0x26F59E0B);
  static const success = Color(0xFF10B981);
  static const successLight = Color(0x2610B981);
  static const info = Color(0xFF3B82F6);

  // Texto (claro sobre fondo oscuro)
  static const textPrimary = Color(0xFFF3F4F6);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textHint = Color(0xFF6B7280);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Bordes
  static const border = Color(0xFF2A2A3A);
  static const borderLight = Color(0xFF1E1E2E);
  static const divider = Color(0xFF1E1E2E);

  // Estratos colombianos
  static const List<Color> estratoColors = [
    Color(0xFF8BC34A), // Estrato 1
    Color(0xFF4CAF50), // Estrato 2
    Color(0xFF00BCD4), // Estrato 3
    Color(0xFF2196F3), // Estrato 4
    Color(0xFF673AB7), // Estrato 5
    Color(0xFFE91E63), // Estrato 6
  ];

  static Color estratoColor(int estrato) {
    if (estrato < 1 || estrato > 6) return primary;
    return estratoColors[estrato - 1];
  }

  // Categorías de servicios
  static const categoryComida = Color(0xFFFF7043);
  static const categoryBelleza = Color(0xFFEC407A);
  static const categoryTecnologia = Color(0xFF42A5F5);
  static const categoryMascotas = Color(0xFF8D6E63);
  static const categoryHogar = Color(0xFF66BB6A);
  static const categoryManualidades = Color(0xFFAB47BC);
  static const categorySalud = Color(0xFF26A69A);
  static const categoryRopa = Color(0xFFFFA726);
}
