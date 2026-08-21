import 'dart:typed_data';

import '/flutter_flow/platform_download.dart';
import 'package:excel/excel.dart';

/// Downloads the workbook accepted by the SOS Mpilo reconciliation importer.
///
/// The importer deliberately reads the `Recon Final` sheet first, so the
/// instructions and example rows cannot be imported as live reconciliation
/// data.
Future<void> downloadReconciliationTemplate() async {
  final excel = Excel.createExcel();

  const reconciliationSheetName = 'Recon Final';
  final defaultSheet = excel.getDefaultSheet();
  if (defaultSheet != null && defaultSheet != reconciliationSheetName) {
    excel.rename(defaultSheet, reconciliationSheetName);
  }
  final sheet = excel[reconciliationSheetName];

  const headers = [
    'Product Name',
    'Description',
    'Opening Stock',
    'Stock Supplied',
    'Total Available',
    'Physical Count',
    'Units Dispensed',
    'Transfer Unit Price',
  ];
  for (var index = 0; index < headers.length; index++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: index, rowIndex: 0))
        .value = headers[index];
  }

  const widths = [30.0, 42.0, 16.0, 16.0, 18.0, 16.0, 18.0, 22.0];
  for (var index = 0; index < widths.length; index++) {
    sheet.setColWidth(index, widths[index]);
  }

  const instructionsSheetName = 'Instructions';
  final instructionsSheet = excel[instructionsSheetName];
  const instructions = [
    ['Reconciliation import template'],
    ['1. Enter data only on the Recon Final sheet.'],
    ['2. Keep the header names and their order unchanged.'],
    [
      '3. Use whole numbers for all stock quantities and a decimal number for Transfer Unit Price.'
    ],
    ['4. Total Available must equal Opening Stock + Stock Supplied.'],
    ['5. Units Dispensed must equal Total Available - Physical Count.'],
    [
      '6. Save the completed workbook as .xlsx. Include the reconciliation date in the filename, for example: SOS Mpilo Recon 21 AUG.xlsx.'
    ],
    ['Column', 'What to enter'],
    ['Product Name', 'Required product name.'],
    ['Description', 'Optional product description.'],
    ['Opening Stock', 'Whole number, zero or greater.'],
    ['Stock Supplied', 'Whole number, zero or greater.'],
    ['Total Available', 'Opening Stock + Stock Supplied.'],
    ['Physical Count', 'Whole number physically counted, zero or greater.'],
    ['Units Dispensed', 'Total Available - Physical Count.'],
    [
      'Transfer Unit Price',
      'Unit price as a number, without a currency symbol.'
    ],
  ];
  for (var row = 0; row < instructions.length; row++) {
    for (var column = 0; column < instructions[row].length; column++) {
      instructionsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: row))
          .value = instructions[row][column];
    }
  }
  instructionsSheet.setColWidth(0, 28.0);
  instructionsSheet.setColWidth(1, 86.0);

  final bytes = excel.encode();
  if (bytes == null) return;
  await save(
    bytes: Uint8List.fromList(bytes),
    fileName: 'Pulse_Reconciliation_Template.xlsx',
    mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}
