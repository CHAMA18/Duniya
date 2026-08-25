import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:medi_tracker/custom_code/actions/parse_inventory_spreadsheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('real uploaded catalogue XLSX maps fully', () {
    final path =
        '/home/z/my-project/upload/Pulse_Product_Catalogue_Import__VMI (1) platform demo.xlsx';
    final file = File(path);
    if (!file.existsSync()) {
      // One-off verification harness — skip when the demo file is absent.
      return;
    }
    final excel = Excel.decodeBytes(file.readAsBytesSync());
    final sheet = excel.tables[excel.tables.keys.first]!;
    final rows = sheet.rows.map((r) => r.map((c) => c?.value).toList()).toList();
    final headerRow = rows.first.map((c) => c?.toString() ?? '').toList();
    final mapping = mapSpreadsheetHeaders(headerRow);

    final unmapped = headerRow
        .where((h) => h.trim().isNotEmpty && !mapping.containsKey(h))
        .toList();
    expect(unmapped, isEmpty, reason: 'columns must all map: $unmapped');
    expect(isProductCatalogueSheet(headerRow), isTrue);

    // Row 1 of the demo file, end-to-end semantics.
    final row = rows[1];
    String? name, supplier, selling, cost, reorder, minStock, sku,
        generic, brand, strength, dosage, pack, uom;
    for (var j = 0; j < headerRow.length; j++) {
      final canonical = mapping[headerRow[j].trim()];
      final value = j < row.length ? (row[j]?.toString() ?? '').trim() : '';
      if (value.isEmpty) continue;
      switch (canonical) {
        case 'name': name = value;
        case 'manufacturer': supplier = value;
        case 'price': selling = value;
        case 'costOfGoods': cost = value;
        case 'reorderLevel': reorder = value;
        case 'minimumStockLevel': minStock = value;
        case 'sku': sku = value;
        case 'genericName': generic = value;
        case 'brandName': brand = value;
        case 'strength': strength = value;
        case 'dosageForm': dosage = value;
        case 'packSize': pack = value;
        case 'unitOfMeasure': uom = value;
      }
    }
    expect(name, 'Acyclovir cream (herpizyg) 10g');
    expect(supplier, 'Must Pharmaceuticals');
    expect(selling, '17.22');
    expect(cost, '10.76');
    expect(resolveLimitNotice(
        reorderLevel: int.tryParse(reorder ?? ''),
        minimumStockLevel: int.tryParse(minStock ?? '')), 10);
    final description = composeStockDescription(
        genericName: generic, brandName: brand, strength: strength,
        dosageForm: dosage, packSize: pack, unitOfMeasure: uom, sku: sku);
    expect(description,
        'Acyclovir • herpizyg • Cream • 1 tube • Tubes • SKU: ACY-0001');

    // Every non-empty data row must produce a name.
    var valid = 0;
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      if (r.every((c) => (c?.toString() ?? '').trim().isEmpty)) continue;
      final n = r[mapping.keys.toList().indexOf('Name')]?.toString() ?? '';
      if (n.trim().isNotEmpty) valid++;
    }
    print('valid rows: $valid / ${rows.length - 1}');
    expect(valid, rows.length - 1);
  });
}
