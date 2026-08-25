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

  // ── Product Catalogue format (Pulse_Product_Catalogue_Import) ──
  // The Store Inventory import accepts BOTH the classic stock format
  // (Name/Category/Manufacturer/Quantity/Price/…) and the full Product
  // Catalogue format (GenericName/BrandName/Strength/DosageForm/PackSize/
  // UnitOfMeasure/SKU/…). The catalogue attributes are composed into a
  // rich [description] so nothing from the file is dropped.
  final String? genericName;
  final String? brandName;
  final String? strength;
  final String? dosageForm;
  final String? packSize;
  final String? unitOfMeasure;
  final String? sku;
  final String? description;

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
    this.genericName,
    this.brandName,
    this.strength,
    this.dosageForm,
    this.packSize,
    this.unitOfMeasure,
    this.sku,
    this.description,
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
        'genericName': genericName,
        'brandName': brandName,
        'strength': strength,
        'dosageForm': dosageForm,
        'packSize': packSize,
        'unitOfMeasure': unitOfMeasure,
        'sku': sku,
        'description': description,
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
  // Product Catalogue format fields.
  'genericName',
  'brandName',
  'strength',
  'dosageForm',
  'packSize',
  'unitOfMeasure',
  'sku',
  'reorderLevel',
  'minimumStockLevel',
];

/// Header aliases — case-insensitive match against any of these
/// maps the spreadsheet column to the canonical field.
///
/// Covers BOTH supported input formats:
///   • Classic stock sheet — Name, Category, Manufacturer, Quantity, Price,
///     CostOfGoods, BatchNumber, ExpiryDate, LimitNotice (+ friendly aliases).
///   • Product Catalogue sheet (Pulse_Product_Catalogue_Import__VMI) —
///     Name, GenericName, BrandName, Strength, DosageForm, PackSize,
///     UnitOfMeasure, SKU, Category, Supplier, CostPrice, SellingPrice,
///     MinimumStockLevel, ReorderLevel.
const Map<String, List<String>> _kHeaderAliases = {
  'name': ['name', 'product name', 'productname', 'product', 'item name', 'item', 'drug name', 'medicine name', 'description name'],
  'category': ['category', 'product category', 'type', 'product type'],
  'manufacturer': ['manufacturer', 'brand', 'supplier', 'vendor', 'company', 'producer'],
  'quantity': ['quantity', 'qty', 'stock', 'stock level', 'units', 'count', 'on hand', 'quantity in stock'],
  'price': ['price', 'unit price', 'selling price', 'sellingprice', 'sale price', 'retail price', 'sell price', 'price per unit'],
  'costOfGoods': ['cost', 'cost of goods', 'costofgoods', 'cogs', 'cost price', 'costprice', 'purchase price', 'unit cost', 'buy price'],
  'batchNumber': ['batch number', 'batchnumber', 'batch', 'batch no', 'batch #', 'lot', 'lot number', 'lot no'],
  'expiryDate': ['expiry date', 'expirydate', 'expiry', 'expiration date', 'expiration', 'exp date', 'exp', 'expires', 'best before'],
  'limitNotice': ['limit notice', 'limitnotice', 'reorder', 'low stock threshold', 'low stock alert', 'alert at'],
  'reorderLevel': ['reorder level', 'reorderlevel', 're-order level'],
  'minimumStockLevel': ['minimum stock level', 'minimumstocklevel', 'minimum stock', 'min stock', 'minstocklevel', 'minimumstock'],
  // Product Catalogue format fields.
  'genericName': ['generic name', 'genericname', 'generic', 'inn'],
  'brandName': ['brand name', 'brandname', 'label'],
  'strength': ['strength', 'concentration', 'potency'],
  'dosageForm': ['dosage form', 'dosageform', 'form', 'dose form'],
  'packSize': ['pack size', 'packsize', 'packaging', 'pack'],
  'unitOfMeasure': ['unit of measure', 'unitofmeasure', 'uom', 'unit', 'units of measure'],
  'sku': ['sku', 'item code', 'product code', 'code', 'barcode'],
};

/// The exact column set of the Product Catalogue import format — used to
/// detect (and surface in the preview) that a catalogue file was uploaded.
const kProductCatalogueHeaders = <String>{
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
};

/// True when the parsed header row is the Product Catalogue format.
bool isProductCatalogueSheet(List<String> detectedHeaders) {
  final normalized =
      detectedHeaders.map((h) => h.trim().toLowerCase()).toSet();
  // The catalogue format is unambiguous when the two format-exclusive
  // columns are present; Name/Category/Supplier alone are ambiguous.
  return normalized.containsAll({'genericname', 'sellingprice'}) ||
      normalized.containsAll({'genericname', 'dosageform'}) ||
      normalized.containsAll({'sku', 'sellingprice'});
}

/// Pure header-mapping function (unit-tested): maps a spreadsheet header
/// row to canonical Stock fields, e.g. 'SellingPrice' → 'price'.
Map<String, String> mapSpreadsheetHeaders(List<String> headerRow) {
  final mapping = <String, String>{};
  for (final cell in headerRow) {
    final headerText = (cell).trim();
    final normalized = headerText.toLowerCase().trim();
    if (normalized.isEmpty) continue;
    for (final entry in _kHeaderAliases.entries) {
      if (entry.value.contains(normalized)) {
        mapping[headerText] = entry.key;
        break;
      }
    }
  }
  return mapping;
}

/// Compose the Stock record [Description] from the Product Catalogue
/// attributes so no information from the imported file is dropped, e.g.
/// 'Acyclovir • herpizyg • 200 mg • Tablet • 100 tablets • SKU: ACY-0002'.
String? composeStockDescription({
  String? genericName,
  String? brandName,
  String? strength,
  String? dosageForm,
  String? packSize,
  String? unitOfMeasure,
  String? sku,
}) {
  final parts = <String>[
    if ((genericName ?? '').trim().isNotEmpty) genericName!.trim(),
    if ((brandName ?? '').trim().isNotEmpty) brandName!.trim(),
    if ((strength ?? '').trim().isNotEmpty &&
        (strength ?? '').trim().toLowerCase() != 'nil')
      strength!.trim(),
    if ((dosageForm ?? '').trim().isNotEmpty &&
        (dosageForm ?? '').trim().toLowerCase() != 'nil')
      dosageForm!.trim(),
    if ((packSize ?? '').trim().isNotEmpty &&
        (packSize ?? '').trim().toLowerCase() != 'nil')
      packSize!.trim(),
    if ((unitOfMeasure ?? '').trim().isNotEmpty &&
        (unitOfMeasure ?? '').trim().toLowerCase() != 'nil' &&
        (packSize ?? '').trim().toLowerCase() != (unitOfMeasure ?? '').trim().toLowerCase())
      unitOfMeasure!.trim(),
  ];
  if (parts.isEmpty && (sku ?? '').trim().isEmpty) return null;
  final body = parts.join(' • ');
  final skuPart = (sku ?? '').trim().isEmpty ? '' : ' • SKU: ${sku!.trim()}';
  final composed = '$body$skuPart'.trim();
  // When only the SKU survived (everything else was 'Nil'/empty), strip
  // the leading bullet so the description reads 'SKU: ACY-0001'.
  if (composed.startsWith('• ')) return composed.substring(2);
  return composed.isEmpty ? null : composed;
}

/// Resolve the low-stock alert threshold from the catalogue columns:
/// ReorderLevel wins when present (it is the actionable trigger),
/// otherwise MinimumStockLevel, otherwise the classic LimitNotice.
int resolveLimitNotice({int? reorderLevel, int? minimumStockLevel, int? limitNotice}) {
  return reorderLevel ?? minimumStockLevel ?? limitNotice ?? 0;
}

/// Pick a spreadsheet file from disk and parse it into Stock record field maps.
/// Supports .xlsx, .xls, and .csv files — in BOTH the classic stock-sheet
/// format and the Product Catalogue format.
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
    final headerRow =
        dataRows.first.map((c) => c?.toString() ?? '').toList();
    final detectedHeaders = headerRow
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .toList();
    final headerMapping = mapSpreadsheetHeaders(headerRow);

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
        final headerText = headerRow[j].trim();
        if (headerText.isEmpty) continue;
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

      // Low-stock threshold: catalogue ReorderLevel / MinimumStockLevel
      // take precedence over the classic LimitNotice column.
      int? reorderLevel;
      final reorderRaw = fieldValues['reorderLevel'] as String?;
      if (reorderRaw != null && reorderRaw.isNotEmpty) {
        reorderLevel =
            int.tryParse(reorderRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      int? minimumStockLevel;
      final minStockRaw = fieldValues['minimumStockLevel'] as String?;
      if (minStockRaw != null && minStockRaw.isNotEmpty) {
        minimumStockLevel =
            int.tryParse(minStockRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
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
      final resolvedLimit = resolveLimitNotice(
        reorderLevel: reorderLevel,
        minimumStockLevel: minimumStockLevel,
        limitNotice: limitNotice,
      );

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

      // Product Catalogue attributes.
      final genericName = fieldValues['genericName'] as String?;
      final brandName = fieldValues['brandName'] as String?;
      final strength = fieldValues['strength'] as String?;
      final dosageForm = fieldValues['dosageForm'] as String?;
      final packSize = fieldValues['packSize'] as String?;
      final unitOfMeasure = fieldValues['unitOfMeasure'] as String?;
      final sku = fieldValues['sku'] as String?;
      final description = composeStockDescription(
        genericName: genericName,
        brandName: brandName,
        strength: strength,
        dosageForm: dosageForm,
        packSize: packSize,
        unitOfMeasure: unitOfMeasure,
        sku: sku,
      );

      // Manufacturer: prefer an explicit Manufacturer/Supplier column,
      // fall back to the catalogue BrandName so the maker is still
      // captured when only the catalogue format was provided.
      final manufacturerRaw = fieldValues['manufacturer'] as String?;
      final manufacturer = (manufacturerRaw ?? '').trim().isNotEmpty
          ? manufacturerRaw
          : ((brandName ?? '').trim().isNotEmpty ? brandName : null);

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
        manufacturer: manufacturer,
        quantity: quantity,
        price: price,
        costOfGoods: costOfGoods,
        batchNumber: fieldValues['batchNumber'] as String?,
        expiryDate: expiryDate,
        limitNotice: resolvedLimit,
        genericName: genericName,
        brandName: brandName,
        strength: strength,
        dosageForm: dosageForm,
        packSize: packSize,
        unitOfMeasure: unitOfMeasure,
        sku: sku,
        description: description,
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
