import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/stores/services/catalog_import_service.dart';

void main() {
  test('genera una plantilla que la propia app puede importar', () {
    final template = CatalogImportService.createTemplate();
    final result = CatalogImportService.parseXlsx(template, 'store-1');
    expect(result.items, hasLength(1));
    expect(result.items.single.name, contains('Pan artesanal'));
    expect(result.items.single.variants, hasLength(3));
  });

  test('lee productos válidos y omite filas incompletas', () {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet()!];
    sheet.appendRow([
      TextCellValue('Nombre'),
      TextCellValue('Precio'),
      TextCellValue('Descripcion'),
      TextCellValue('Categoria'),
      TextCellValue('Disponible'),
      TextCellValue('Variantes'),
    ]);
    sheet.appendRow([
      TextCellValue('Pan artesanal'),
      IntCellValue(8500),
      TextCellValue('Pan de masa madre'),
      TextCellValue('Panadería'),
      TextCellValue('Sí'),
      TextCellValue('Pequeño, Mediano; Grande'),
    ]);
    sheet.appendRow([
      TextCellValue('Sin precio'),
      IntCellValue(0),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('No'),
      TextCellValue(''),
    ]);
    final bytes = Uint8List.fromList(workbook.save()!);

    final result = CatalogImportService.parseXlsx(bytes, 'store-1');

    expect(result.items, hasLength(1));
    expect(result.items.single.name, 'Pan artesanal');
    expect(result.items.single.price, 8500);
    expect(result.items.single.category, 'Panadería');
    expect(result.items.single.available, isTrue);
    expect(result.items.single.variants, ['Pequeño', 'Mediano', 'Grande']);
    expect(result.skippedRows, 1);
  });

  test('exige columnas Nombre y Precio', () {
    final workbook = Excel.createExcel();
    workbook[workbook.getDefaultSheet()!].appendRow([
      TextCellValue('Producto'),
    ]);
    final bytes = Uint8List.fromList(workbook.save()!);

    expect(
      () => CatalogImportService.parseXlsx(bytes, 'store-1'),
      throwsFormatException,
    );
  });
}
