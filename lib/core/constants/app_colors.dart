import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primarios
  static const primary = Color(0xFF2D5BE3);
  static const primaryLight = Color(0xFF5B7FEE);
  static const primaryDark = Color(0xFF1A3FB0);

  // Secundarios
  static const secondary = Color(0xFF4CAF50);
  static const secondaryLight = Color(0xFF80E27E);
  static const secondaryDark = Color(0xFF087F23);

  // Fondos
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF0F2F5);

  // Estados
  static const error = Color(0xFFE53935);
  static const errorLight = Color(0xFFFFEBEE);
  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);
  static const info = Color(0xFF2196F3);

  // Texto
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Bordes
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const divider = Color(0xFFE5E7EB);

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
