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

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

/// A single parsed row from the spreadsheet.
/// Includes the raw cell map, the normalized Stock record fields,
/// and a validation flag with error reason.
class ParsedInventoryRow {
  final Map<String, String> rawCells;
  final String? name;
  final String? category;
  final String? manufacturer;
  final int? quantity;
  final double? price;
  final double? costOfGoods;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int? limitNotice;
  final bool isValid;
  final String? errorReason;

  ParsedInventoryRow({
    required this.rawCells,
    this.name,
    this.category,
    this.manufacturer,
    this.quantity,
    this.price,
    this.costOfGoods,
    this.batchNumber,
    this.expiryDate,
    this.limitNotice,
    required this.isValid,
    this.errorReason,
  });

  Map<String, dynamic> toMap() => {
        'rawCells': rawCells,
        'name': name,
        'category': category,
        'manufacturer': manufacturer,
        'quantity': quantity,
        'price': price,
        'costOfGoods': costOfGoods,
        'batchNumber': batchNumber,
        'expiryDate': expiryDate?.toIso8601String(),
        'limitNotice': limitNotice,
        'isValid': isValid,
        'errorReason': errorReason,
      };
}

/// Result of a spreadsheet parse operation.
class SpreadsheetParseResult {
  final String? fileName;
  final List<String> detectedHeaders;
  final Map<String, String> headerMapping; // spreadsheet header -> canonical field
  final List<ParsedInventoryRow> rows;
  final int validCount;
  final int invalidCount;
  final String? errorMessage;

  SpreadsheetParseResult({
    this.fileName,
    required this.detectedHeaders,
    required this.headerMapping,
    required this.rows,
    required this.validCount,
    required this.invalidCount,
    this.errorMessage,
  });

  int get totalCount => rows.length;
  bool get success => errorMessage == null;
}

/// Canonical field names we map spreadsheet columns to.
const _kCanonicalFields = <String>[
  'name',
  'category',
  'manufacturer',
  'quantity',
  'price',
  'costOfGoods',
  'batchNumber',
  'expiryDate',
  'limitNotice',
];

/// Header aliases — case-insensitive match against any of these
/// maps the spreadsheet column to the canonical field.
const Map<String, List<String>> _kHeaderAliases = {
  'name': ['name', 'product name', 'productname', 'product', 'item name', 'item', 'drug name', 'medicine name', 'description name'],
  'category': ['category', 'product category', 'type', 'product type'],
  'manufacturer': ['manufacturer', 'brand', 'supplier', 'vendor', 'company', 'producer'],
  'quantity': ['quantity', 'qty', 'stock', 'stock level', 'units', 'count', 'on hand', 'quantity in stock'],
  'price': ['price', 'unit price', 'selling price', 'sale price', 'retail price', 'sell price', 'price per unit'],
  'costOfGoods': ['cost', 'cost of goods', 'costofgoods', 'cogs', 'cost price', 'purchase price', 'unit cost', 'buy price'],
  'batchNumber': ['batch number', 'batchnumber', 'batch', 'batch no', 'batch #', 'lot', 'lot number', 'lot no'],
  'expiryDate': ['expiry date', 'expirydate', 'expiry', 'expiration date', 'expiration', 'exp date', 'exp', 'expires', 'best before'],
  'limitNotice': ['limit notice', 'limitnotice', 'reorder level', 'reorder', 'low stock threshold', 'low stock alert', 'min stock', 'minimum stock', 'alert at'],
};

/// Pick a spreadsheet file from disk and parse it into Stock record field maps.
/// Supports .xlsx, .xls, and .csv files.
/// Returns null if the user cancels the picker.
Future<SpreadsheetParseResult?> parseInventorySpreadsheet() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final fileName = file.name;
    final bytes = file.bytes;

    if (bytes == null) {
      return SpreadsheetParseResult(
        detectedHeaders: [],
        headerMapping: {},
        rows: [],
        validCount: 0,
        invalidCount: 0,
        errorMessage: 'Could not read the selected file. Please try again.',
      );
    }

    final ext = fileName.split('.').last.toLowerCase();
    List<List<dynamic>> dataRows;

    if (ext == 'csv') {
      final csvString = String.fromCharCodes(bytes);
      dataRows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvString);
    } else {
      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];
      if (sheet == null || sheet.rows.isEmpty) {
        return SpreadsheetParseResult(
          detectedHeaders: [],
          headerMapping: {},
          rows: [],
          validCount: 0,
          invalidCount: 0,
          errorMessage: 'The spreadsheet appears to be empty.',
        );
      }
      dataRows = sheet.rows.map((row) {
        return row.map((cell) => cell?.value).toList();
      }).toList();
    }

    if (dataRows.isEmpty) {
      return SpreadsheetParseResult(
        detectedHeaders: [],
        headerMapping: {},
        rows: [],
        validCount: 0,
        invalidCount: 0,
        errorMessage: 'The spreadsheet appears to be empty.',
      );
    }

    // First row is header
    final headerRow = dataRows.first;
    final detectedHeaders = <String>[];
    final headerMapping = <String, String>{};

    for (final cell in headerRow) {
      final headerText = (cell?.toString() ?? '').trim();
      detectedHeaders.add(headerText);
      final normalized = headerText.toLowerCase().trim();
      if (normalized.isEmpty) continue;

      // Find matching canonical field
      for (final entry in _kHeaderAliases.entries) {
        if (entry.value.contains(normalized)) {
          headerMapping[headerText] = entry.key;
          break;
        }
      }
    }

    // Parse data rows
    final parsedRows = <ParsedInventoryRow>[];
    int valid = 0;
    int invalid = 0;

    for (var i = 1; i < dataRows.length; i++) {
      final row = dataRows[i];

      // Skip completely empty rows
      final isAllEmpty = row.every((cell) {
        final s = (cell?.toString() ?? '').trim();
        return s.isEmpty;
      });
      if (isAllEmpty) continue;

      final rawCells = <String, String>{};
      final fieldValues = <String, dynamic>{};

      for (var j = 0; j < headerRow.length; j++) {
        final headerText = detectedHeaders[j];
        final cellValue = j < row.length ? row[j] : null;
        final cellString = (cellValue?.toString() ?? '').trim();
        rawCells[headerText] = cellString;

        final canonical = headerMapping[headerText];
        if (canonical != null && cellString.isNotEmpty) {
          fieldValues[canonical] = cellString;
        }
      }

      // Validate & convert
      String? errorReason;

      final name = fieldValues['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        errorReason = 'Missing product name';
      }

      int? quantity;
      if (errorReason == null) {
        final qtyRaw = fieldValues['quantity'] as String?;
        if (qtyRaw != null && qtyRaw.isNotEmpty) {
          // Handle values like "46", "46.0", "46 units"
          final cleaned = qtyRaw.replaceAll(RegExp(r'[^0-9.\-]'), '');
          quantity = int.tryParse(cleaned.split('.').first);
          if (quantity == null) {
            errorReason = 'Invalid quantity: "$qtyRaw"';
          } else if (quantity < 0) {
            errorReason = 'Quantity cannot be negative';
          }
        } else {
          quantity = 0;
        }
      }

      double? price;
      if (errorReason == null) {
        final priceRaw = fieldValues['price'] as String?;
        if (priceRaw != null && priceRaw.isNotEmpty) {
          final cleaned = priceRaw
              .replaceAll(RegExp(r'[ZMKzmk$,]'), '')
              .replaceAll(RegExp(r'[^0-9.\-]'), '');
          price = double.tryParse(cleaned);
          if (price == null) {
            errorReason = 'Invalid price: "$priceRaw"';
          } else if (price < 0) {
            errorReason = 'Price cannot be negative';
          }
        } else {
          price = 0.0;
        }
      }

      double? costOfGoods;
      if (errorReason == null) {
        final cogsRaw = fieldValues['costOfGoods'] as String?;
        if (cogsRaw != null && cogsRaw.isNotEmpty) {
          final cleaned = cogsRaw
              .replaceAll(RegExp(r'[ZMKzmk$,]'), '')
              .replaceAll(RegExp(r'[^0-9.\-]'), '');
          costOfGoods = double.tryParse(cleaned) ?? 0.0;
        } else {
          costOfGoods = 0.0;
        }
      }

      int? limitNotice;
      if (errorReason == null) {
        final limitRaw = fieldValues['limitNotice'] as String?;
        if (limitRaw != null && limitRaw.isNotEmpty) {
          final cleaned = limitRaw.replaceAll(RegExp(r'[^0-9]'), '');
          limitNotice = int.tryParse(cleaned) ?? 0;
        } else {
          limitNotice = 0;
        }
      }

      DateTime? expiryDate;
      if (errorReason == null) {
        final dateRaw = fieldValues['expiryDate'] as String?;
        if (dateRaw != null && dateRaw.isNotEmpty) {
          expiryDate = _parseFlexibleDate(dateRaw);
          if (expiryDate == null) {
            errorReason = 'Invalid expiry date: "$dateRaw" (use YYYY-MM-DD or DD/MM/YYYY)';
          }
        }
      }

      final isValid = errorReason == null;
      if (isValid) {
        valid++;
      } else {
        invalid++;
      }

      parsedRows.add(ParsedInventoryRow(
        rawCells: rawCells,
        name: name,
        category: (fieldValues['category'] as String?)?.isNotEmpty == true
            ? fieldValues['category'] as String
            : 'Medicine',
        manufacturer: fieldValues['manufacturer'] as String?,
        quantity: quantity,
        price: price,
        costOfGoods: costOfGoods,
        batchNumber: fieldValues['batchNumber'] as String?,
        expiryDate: expiryDate,
        limitNotice: limitNotice,
        isValid: isValid,
        errorReason: errorReason,
      ));
    }

    return SpreadsheetParseResult(
      fileName: fileName,
      detectedHeaders: detectedHeaders,
      headerMapping: headerMapping,
      rows: parsedRows,
      validCount: valid,
      invalidCount: invalid,
    );
  } catch (e) {
    return SpreadsheetParseResult(
      detectedHeaders: [],
      headerMapping: {},
      rows: [],
      validCount: 0,
      invalidCount: 0,
      errorMessage: 'Failed to parse spreadsheet: ${e.toString()}',
    );
  }
}

/// Try multiple date formats and return the first that parses.
DateTime? _parseFlexibleDate(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Try ISO 8601 first
  final iso = DateTime.tryParse(trimmed);
  if (iso != null) return iso;

  // Common formats
  final formats = [
    'yyyy-MM-dd',
    'dd/MM/yyyy',
    'd/M/yyyy',
    'MM/dd/yyyy',
    'M/d/yyyy',
    'dd-MM-yyyy',
    'd-M-yyyy',
    'yyyy/MM/dd',
    'dd.MM.yyyy',
    'd.M.yyyy',
  ];

  for (final fmt in formats) {
    try {
      // Manual parse — avoids intl dependency
      final parts = _splitByFormat(trimmed, fmt);
      if (parts != null) {
        final m = parts[1].toString().padLeft(2, '0');
        final d = parts[2].toString().padLeft(2, '0');
        final dt = DateTime.tryParse('${parts[0]}-$m-$d');
        if (dt != null) return dt;
      }
    } catch (_) {}
  }

  return null;
}

/// Returns [year, month, day] based on the format string, or null if no match.
List<int>? _splitByFormat(String input, String format) {
  final sep = format.contains('-') ? '-' : (format.contains('/') ? '/' : (format.contains('.') ? '.' : '-'));
  final inputParts = input.split(RegExp(r'[-/.]'));
  if (inputParts.length != 3) return null;
  final fmtParts = format.split(RegExp(r'[-/.]'));
  if (fmtParts.length != 3) return null;

  int? year, month, day;
  for (var i = 0; i < 3; i++) {
    final val = int.tryParse(inputParts[i]);
    if (val == null) return null;
    switch (fmtParts[i]) {
      case 'yyyy':
        year = val;
        break;
      case 'MM':
      case 'M':
        month = val;
        break;
      case 'dd':
      case 'd':
        day = val;
        break;
    }
  }
  if (year == null || month == null || day == null) return null;
  if (year < 100) year = year + 2000;
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > 31) return null;
  return [year, month, day];
}
