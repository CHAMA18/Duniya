import '/flutter_flow/platform_download.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart';

/// Downloads a Product Catalogue import template.
///
/// This schema intentionally mirrors ProductMasterWidget's spreadsheet
/// importer. `Name` and `SKU` are required; every other column is optional.
Future<void> downloadProductCatalogueTemplate() async {
  final excel = Excel.createExcel();
  final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

  const headers = [
    'Name',
    'GenericName',
    'BrandName',
    'Strength',
    'DosageForm',
    'PackSize',
    'UnitOfMeasure',
    'SKU',
    'Category',
    'Supplier',
    'CostPrice',
    'SellingPrice',
    'MinimumStockLevel',
    'ReorderLevel',
  ];

  const examples = [
    [
      'Paracetamol 500 mg Tablets',
      'Paracetamol',
      'Panadol',
      '500 mg',
      'Tablet',
      '100 tablets',
      'Tablets',
      'PAR-500-100',
      'Analgesics',
      'GSK',
      1.80,
      3.50,
      40,
      60,
    ],
    [
      'Amoxicillin 250 mg Capsules',
      'Amoxicillin',
      'Amoxil',
      '250 mg',
      'Capsule',
      '100 capsules',
      'Capsules',
      'AMX-250-100',
      'Antibiotics',
      'GSK',
      4.20,
      7.50,
      25,
      40,
    ],
  ];

  for (var column = 0; column < headers.length; column++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0))
        .value = headers[column];
  }

  for (var row = 0; row < examples.length; row++) {
    for (var column = 0; column < headers.length; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: column, rowIndex: row + 1))
          .value = examples[row][column];
    }
  }

  final widths = [30, 22, 18, 14, 16, 18, 18, 18, 18, 18, 14, 15, 20, 16];
  for (var column = 0; column < widths.length; column++) {
    sheet.setColWidth(column, widths[column].toDouble());
  }

  const instructionsName = 'Instructions';
  if (!excel.tables.containsKey(instructionsName)) {
    excel[instructionsName];
  }
  final instructionsSheet = excel[instructionsName];
  const instructions = [
    ['Product catalogue import', '', '', ''],
    ['Required fields', 'Name and SKU', '', ''],
    ['Field', 'Required', 'What to enter', 'Example'],
    [
      'Name',
      'Yes',
      'Product name shown in the catalogue',
      'Paracetamol 500 mg Tablets'
    ],
    ['SKU', 'Yes', 'Unique product code; do not leave it blank', 'PAR-500-100'],
    ['GenericName', 'No', 'Non-brand medicine name', 'Paracetamol'],
    ['BrandName', 'No', 'Brand or manufacturer product name', 'Panadol'],
    ['Strength', 'No', 'Dose or concentration', '500 mg'],
    ['DosageForm', 'No', 'Tablet, capsule, syrup, injection, etc.', 'Tablet'],
    ['PackSize', 'No', 'Pack description', '100 tablets'],
    ['UnitOfMeasure', 'No', 'Counting unit', 'Tablets'],
    ['Category', 'No', 'Product grouping', 'Analgesics'],
    ['Supplier', 'No', 'Supplier or manufacturer', 'GSK'],
    ['CostPrice', 'No', 'Purchase price; numbers only', '1.80'],
    ['SellingPrice', 'No', 'Retail price; numbers only', '3.50'],
    ['MinimumStockLevel', 'No', 'Low-stock alert quantity', '40'],
    ['ReorderLevel', 'No', 'Quantity at which to reorder', '60'],
  ];

  for (var row = 0; row < instructions.length; row++) {
    for (var column = 0; column < instructions[row].length; column++) {
      instructionsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
          .value = instructions[row][column];
    }
  }
  instructionsSheet.setColWidth(0, 22.0);
  instructionsSheet.setColWidth(1, 16.0);
  instructionsSheet.setColWidth(2, 48.0);
  instructionsSheet.setColWidth(3, 30.0);

  final bytes = excel.encode();
  if (bytes == null) return;

  await save(
    bytes: Uint8List.fromList(bytes),
    fileName: 'Pulse_Product_Catalogue_Import_Template.xlsx',
    mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}
