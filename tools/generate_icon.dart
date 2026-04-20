// Genera dos PNG para el icono de Vecindario:
//   - assets/icons/app_icon.png           (1024x1024, icono completo iOS + Android legacy)
//   - assets/icons/app_icon_foreground.png (1024x1024, capa de foreground para adaptive icons)
//
// Ejecutar con: dart run tools/generate_icon.dart
// Después: dart run flutter_launcher_icons

import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

const int size = 1024;
const int center = size ~/ 2;

// Colores de la marca (lib/core/constants/app_colors.dart)
final primary = img.ColorRgb8(0x3B, 0x82, 0xF6); // #3B82F6
final primaryDark = img.ColorRgb8(0x25, 0x63, 0xEB); // #2563EB
final secondary = img.ColorRgb8(0x10, 0xB9, 0x81); // #10B981 (verde de Vecindario Admin)
final white = img.ColorRgb8(0xFF, 0xFF, 0xFF);
final whiteAlpha = img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF);
final transparent = img.ColorRgba8(0, 0, 0, 0);

void main() {
  final outDir = Directory('assets/icons');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  // 1) Icono completo (iOS + Android legacy)
  final fullIcon = _buildFullIcon();
  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(fullIcon));
  print('Generado: assets/icons/app_icon.png');

  // 2) Foreground para adaptive icons Android
  // Safe zone: el sistema recorta 2/3 del canvas, solo el centro se ve siempre
  final foreground = _buildForeground();
  File(
    'assets/icons/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(foreground));
  print('Generado: assets/icons/app_icon_foreground.png');
}

img.Image _buildFullIcon() {
  final canvas = img.Image(width: size, height: size, numChannels: 4);

  // Gradient radial del centro (primary) hacia las esquinas (primaryDark)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = (x - center) / center;
      final dy = (y - center) / center;
      final t = sqrt(dx * dx + dy * dy).clamp(0.0, 1.0);
      final r = _lerp(0x3B, 0x25, t);
      final g = _lerp(0x82, 0x63, t);
      final b = _lerp(0xF6, 0xEB, t);
      canvas.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Esquinas redondeadas (recortar con transparente)
  _applyRoundedCorners(canvas, size ~/ 6);

  _drawBuilding(canvas);

  return canvas;
}

img.Image _buildForeground() {
  // Android adaptive icons: el foreground debe caber en un área central
  // de ~66% del canvas. Fondo transparente.
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  // Transparente todo
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      canvas.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  _drawBuilding(canvas, scale: 0.75);
  return canvas;
}

void _drawBuilding(img.Image canvas, {double scale = 1.0}) {
  // Dibuja un edificio minimalista: rectángulo redondeado con 9 ventanas (3x3)
  // + techo plano. Centrado y proporcional al canvas.
  final buildingWidth = (size * 0.48 * scale).round();
  final buildingHeight = (size * 0.58 * scale).round();
  final buildingX = center - buildingWidth ~/ 2;
  final buildingY = center - buildingHeight ~/ 2 + (size * 0.04).round();

  // Techo (trapezoide plano: rectángulo más ancho arriba)
  final roofHeight = (size * 0.09 * scale).round();
  final roofOverhang = (size * 0.04 * scale).round();
  _fillRoundedRect(
    canvas,
    buildingX - roofOverhang,
    buildingY - roofHeight,
    buildingX + buildingWidth + roofOverhang,
    buildingY,
    radius: (size * 0.02 * scale).round(),
    color: secondary,
  );

  // Edificio principal
  _fillRoundedRect(
    canvas,
    buildingX,
    buildingY,
    buildingX + buildingWidth,
    buildingY + buildingHeight,
    radius: (size * 0.03 * scale).round(),
    color: white,
  );

  // 3x3 grilla de ventanas
  final windowRows = 3;
  final windowCols = 3;
  final windowMargin = (buildingWidth * 0.10).round();
  final windowSpacingX =
      (buildingWidth - 2 * windowMargin) / windowCols;
  final windowSpacingY =
      (buildingHeight * 0.75 - 2 * windowMargin) / windowRows;
  final windowSize = (windowSpacingX * 0.60).round();

  for (int r = 0; r < windowRows; r++) {
    for (int c = 0; c < windowCols; c++) {
      final wx = buildingX +
          windowMargin +
          (c * windowSpacingX + windowSpacingX / 2 - windowSize / 2).round();
      final wy = buildingY +
          windowMargin +
          (r * windowSpacingY + windowSpacingY / 2 - windowSize / 2).round();

      // Una ventana del centro-inferior iluminada (acento verde)
      final isHighlight = r == 2 && c == 1;
      _fillRoundedRect(
        canvas,
        wx,
        wy,
        wx + windowSize,
        wy + windowSize,
        radius: (windowSize * 0.15).round(),
        color: isHighlight ? secondary : primary,
      );
    }
  }

  // Puerta central abajo
  final doorWidth = (buildingWidth * 0.18).round();
  final doorHeight = (buildingHeight * 0.22).round();
  final doorX = center - doorWidth ~/ 2;
  final doorY = buildingY + buildingHeight - doorHeight;
  _fillRoundedRect(
    canvas,
    doorX,
    doorY,
    doorX + doorWidth,
    doorY + doorHeight,
    radius: (doorWidth * 0.20).round(),
    topOnly: true,
    color: primaryDark,
  );
}

// === Utilidades de dibujo ===

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

void _fillRoundedRect(
  img.Image canvas,
  int x1,
  int y1,
  int x2,
  int y2, {
  required int radius,
  required img.Color color,
  bool topOnly = false,
}) {
  final minX = x1;
  final maxX = x2;
  final minY = y1;
  final maxY = y2;

  for (int y = minY; y < maxY; y++) {
    for (int x = minX; x < maxX; x++) {
      if (_insideRoundedRect(
        x,
        y,
        minX,
        minY,
        maxX,
        maxY,
        radius,
        topOnly: topOnly,
      )) {
        canvas.setPixel(x, y, color);
      }
    }
  }
}

bool _insideRoundedRect(
  int x,
  int y,
  int x1,
  int y1,
  int x2,
  int y2,
  int r, {
  bool topOnly = false,
}) {
  // Esquinas con radio r
  final corners = <List<int>>[
    [x1 + r, y1 + r], // top-left
    [x2 - r - 1, y1 + r], // top-right
    if (!topOnly) [x1 + r, y2 - r - 1], // bottom-left
    if (!topOnly) [x2 - r - 1, y2 - r - 1], // bottom-right
  ];

  // Dentro del rectángulo interior (sin esquinas)
  if (x >= x1 + r && x < x2 - r) return true;
  if (!topOnly && y >= y1 + r && y < y2 - r) return true;
  if (topOnly && y >= y1 + r) return true;

  // Esquinas: verificar distancia al centro del arco
  for (final c in corners) {
    final dx = x - c[0];
    final dy = y - c[1];
    if (dx * dx + dy * dy <= r * r) return true;
  }
  return false;
}

void _applyRoundedCorners(img.Image canvas, int radius) {
  // Solo transparenta las esquinas; el centro queda intacto.
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final inTopLeft = x < radius && y < radius;
      final inTopRight = x >= size - radius && y < radius;
      final inBottomLeft = x < radius && y >= size - radius;
      final inBottomRight = x >= size - radius && y >= size - radius;
      if (!inTopLeft && !inTopRight && !inBottomLeft && !inBottomRight) {
        continue;
      }
      int cx = 0, cy = 0;
      if (inTopLeft) {
        cx = radius;
        cy = radius;
      } else if (inTopRight) {
        cx = size - radius - 1;
        cy = radius;
      } else if (inBottomLeft) {
        cx = radius;
        cy = size - radius - 1;
      } else {
        cx = size - radius - 1;
        cy = size - radius - 1;
      }
      final dx = x - cx;
      final dy = y - cy;
      if (dx * dx + dy * dy > radius * radius) {
        canvas.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
}
