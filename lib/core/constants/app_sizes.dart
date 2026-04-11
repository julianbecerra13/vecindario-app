import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  // Spacing (sistema de 4px)
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Border radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusFull = 999;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  // Avatar sizes
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  // Button heights
  static const double buttonHeight = 48;
  static const double buttonHeightSm = 36;

  // Input heights
  static const double inputHeight = 48;

  // Card
  static const double cardElevation = 1;
  static const double cardRadius = 12;

  // Bottom nav
  static const double bottomNavHeight = 64;

  // Max width para contenido
  static const double maxContentWidth = 600;

  // Padding helpers
  static const EdgeInsets paddingAll = EdgeInsets.all(md);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
}
