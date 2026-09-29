import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:vecindario_app/features/stores/models/store_item_model.dart';

class CatalogImportResult {
  const CatalogImportResult({required this.items, required this.skippedRows});
  final List<StoreItemModel> items;
  final int skippedRows;
}

class CatalogImportService {
  const CatalogImportService._();

  static Uint8List createTemplate() {
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
      TextCellValue('Ejemplo: Pan artesanal'),
      IntCellValue(8500),
      TextCellValue('Descripción opcional'),
      TextCellValue('Panadería'),
      TextCellValue('Sí'),
      TextCellValue('Talla S - Azul, Talla M - Azul, Talla M - Roja'),
    ]);
    return Uint8List.fromList(workbook.save()!);
  }

  static CatalogImportResult parseXlsx(Uint8List bytes, String storeId) {
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) {
      return const CatalogImportResult(items: [], skippedRows: 0);
    }
    final sheet = workbook.tables.values.first;
    if (sheet.rows.isEmpty) {
      return const CatalogImportResult(items: [], skippedRows: 0);
    }

    final headers = <String, int>{};
    for (var index = 0; index < sheet.rows.first.length; index++) {
      final header = _text(sheet.rows.first[index]?.value).toLowerCase();
      headers[header] = index;
    }
    final nameColumn = headers['nombre'];
    final priceColumn = headers['precio'];
    if (nameColumn == null || priceColumn == null) {
      throw const FormatException(
        'El Excel debe incluir las columnas Nombre y Precio.',
      );
    }

    final items = <StoreItemModel>[];
    var skipped = 0;
    for (var rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
      final row = sheet.rows[rowIndex];
      final name = _cell(row, nameColumn);
      final price = _price(_cell(row, priceColumn));
      if (name.isEmpty || price <= 0) {
        skipped++;
        continue;
      }
      final availableText = _cell(row, headers['disponible']).toLowerCase();
      items.add(
        StoreItemModel(
          id: '',
          storeId: storeId,
          name: name,
          description: _nullable(_cell(row, headers['descripcion'])),
          price: price,
          category: _nullable(_cell(row, headers['categoria'])),
          available: !{'no', 'false', '0'}.contains(availableText),
          variants: _variants(_cell(row, headers['variantes'])),
          sortOrder: items.length,
        ),
      );
    }
    return CatalogImportResult(items: items, skippedRows: skipped);
  }

  static String _cell(List<Data?> row, int? index) {
    if (index == null || index < 0 || index >= row.length) return '';
    return _text(row[index]?.value);
  }

  static String _text(CellValue? value) => value?.toString().trim() ?? '';

  static int _price(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(normalized) ?? 0;
  }

  static String? _nullable(String value) => value.isEmpty ? null : value;

  static List<String> _variants(String value) => value
      .split(RegExp(r'[,;]'))
      .map((variant) => variant.trim())
      .where((variant) => variant.isNotEmpty)
      .toSet()
      .toList();
}
