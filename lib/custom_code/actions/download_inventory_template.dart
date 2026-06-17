// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart';

/// Generates and downloads an Excel template with the correct column headers
/// for inventory import. Includes an example row and a second sheet with
/// field-by-field instructions.
Future<void> downloadInventoryTemplate() async {
  final excel = Excel.createExcel();

  // The default sheet is 'Sheet1'. Rename it to 'Inventory Template'.
  const sheetName = 'Inventory Template';
  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null && defaultSheet != sheetName) {
    excel.rename(defaultSheet, sheetName);
  }

  final sheet = excel[sheetName];

  // Header row
  final headers = [
    'Name',
    'Category',
    'Manufacturer',
    'Quantity',
    'Price',
    'CostOfGoods',
    'BatchNumber',
    'ExpiryDate',
    'LimitNotice',
  ];

  for (var i = 0; i < headers.length; i++) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
    cell.value = headers[i];
  }

  // Example row
  final example = [
    'Paracetamol 500mg',
    'Medicine',
    'GSK',
    '100',
    '15.00',
    '8.50',
    'B-2024-001',
    '2026-12-31',
    '20',
  ];

  for (var i = 0; i < example.length; i++) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
    cell.value = example[i];
  }

  // Set column widths
  for (var i = 0; i < headers.length; i++) {
    sheet.setColWidth(i, 22.0);
  }

  // Add an Instructions sheet — copy 'Sheet1' style by creating a new sheet via excel.copy()
  // Excel 2.x: we can access a new sheet name to auto-create it.
  const instructionsSheetName = 'Instructions';
  final existingSheets = excel.tables.keys.toList();
  if (!existingSheets.contains(instructionsSheetName)) {
    // Accessing a non-existent sheet auto-creates it in Excel 2.x
    excel[instructionsSheetName];
  }
  final instructionsSheet = excel[instructionsSheetName];

  final instructions = [
    ['Field', 'Description', 'Required', 'Example'],
    [
      'Name',
      'Product name as it appears on the shelf',
      'Yes',
      'Paracetamol 500mg'
    ],
    [
      'Category',
      'One of: Medicine, Nutrition Supplements, Mother and Babycare, Veterinary Products, Beauty Care, Personal Care',
      'No (defaults to Medicine)',
      'Medicine'
    ],
    ['Manufacturer', 'Brand or supplier name', 'No', 'GSK'],
    [
      'Quantity',
      'Current units in stock (whole number, 0 or positive)',
      'No (defaults to 0)',
      '100'
    ],
    [
      'Price',
      'Selling price per unit in ZMK (no currency symbol)',
      'No (defaults to 0)',
      '15.00'
    ],
    [
      'CostOfGoods',
      'Purchase cost per unit in ZMK',
      'No (defaults to 0)',
      '8.50'
    ],
    ['BatchNumber', 'Batch or lot identifier', 'No', 'B-2024-001'],
    [
      'ExpiryDate',
      'YYYY-MM-DD or DD/MM/YYYY',
      'No',
      '2026-12-31'
    ],
    [
      'LimitNotice',
      'Low-stock threshold (alerts when quantity falls to this level)',
      'No (defaults to 0)',
      '20'
    ],
  ];

  for (var r = 0; r < instructions.length; r++) {
    for (var c = 0; c < instructions[r].length; c++) {
      final cell = instructionsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
      cell.value = instructions[r][c];
    }
  }

  instructionsSheet.setColWidth(0, 18.0);
  instructionsSheet.setColWidth(1, 60.0);
  instructionsSheet.setColWidth(2, 25.0);
  instructionsSheet.setColWidth(3, 25.0);

  // Delete the default 'Sheet1' if it still exists
  if (excel.sheets.containsKey('Sheet1')) {
    excel.delete('Sheet1');
  }

  final bytes = excel.encode();
  if (bytes == null) return;

  final blob = html.Blob(
    [Uint8List.fromList(bytes)],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'Duniya_Inventory_Template.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
}
