import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// The result of picking + parsing a spreadsheet file.
class ImportedFile {
  const ImportedFile({
    required this.fileName,
    required this.rows,
    required this.headerColumns,
  });

  /// The original file name (e.g. "stock_balances_aug.csv").
  final String fileName;

  /// The data rows, each as a Map<String, String> keyed by the NORMALIZED
  /// column name (see [_normalizeColumnName]).
  final List<Map<String, String>> rows;

  /// The list of normalized column names detected in the header row.
  final List<String> headerColumns;

  int get rowCount => rows.length;
}

/// Service that picks a CSV/XLSX file via the OS file picker and parses
/// it into a list of row maps. Smart column normalization: "Product ID",
/// "product_id", "ProductId", and "productId" all map to the canonical
/// camelCase key "productId".
class CsvImporterService {
  const CsvImporterService();

  /// Opens the file picker, reads the picked file, and parses it.
  /// Returns null if the user cancels the picker.
  /// Throws [ImportFormatException] on parse errors.
  Future<ImportedFile?> pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx', 'xls'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;
    if (picked.bytes == null) {
      throw const ImportFormatException('Could not read file bytes');
    }
    final fileName = picked.name;
    final bytes = picked.bytes!;

    if (fileName.toLowerCase().endsWith('.csv')) {
      return _parseCsv(fileName, bytes);
    }
    if (fileName.toLowerCase().endsWith('.xlsx') ||
        fileName.toLowerCase().endsWith('.xls')) {
      return _parseExcel(fileName, bytes);
    }
    throw const ImportFormatException(
        'Unsupported file format. Use .csv or .xlsx');
  }

  ImportedFile _parseCsv(String fileName, Uint8List bytes) {
    final content = String.fromCharCodes(bytes);
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
      allowInvalid: true,
    ).convert(content);
    if (rows.isEmpty) {
      throw const ImportFormatException('File is empty');
    }
    final stringRows =
        rows.map((r) => r.map((c) => c?.toString() ?? '').toList()).toList();
    return _stringRowsToImportedFile(fileName, stringRows);
  }

  ImportedFile _parseExcel(String fileName, Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheetNames = excel.tables.keys.toList();
    if (sheetNames.isEmpty) {
      throw const ImportFormatException('Excel file has no sheets');
    }
    final sheet = excel.tables[sheetNames.first]!;
    final maxRows = sheet.maxRows;
    if (maxRows == 0) {
      throw const ImportFormatException('First sheet is empty');
    }
    final stringRows = sheet.rows
        .map((row) => row.map((cell) => cell?.value?.toString() ?? '').toList())
        .toList();
    return _stringRowsToImportedFile(fileName, stringRows);
  }

  ImportedFile _stringRowsToImportedFile(
    String fileName,
    List<List<String>> rows,
  ) {
    if (rows.isEmpty) {
      throw const ImportFormatException('File has no rows');
    }
    final header = rows.first;
    final normalizedHeader =
        header.map(_normalizeColumnName).toList(growable: false);

    final dataRows = <Map<String, String>>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.trim().isEmpty)) continue;
      final map = <String, String>{};
      for (var j = 0; j < normalizedHeader.length && j < row.length; j++) {
        final key = normalizedHeader[j];
        if (key.isEmpty) continue;
        map[key] = row[j].trim();
      }
      if (map.isNotEmpty) dataRows.add(map);
    }
    if (dataRows.isEmpty) {
      throw const ImportFormatException(
          'No data rows found (header only)');
    }
    return ImportedFile(
      fileName: fileName,
      rows: dataRows,
      headerColumns: normalizedHeader.where((s) => s.isNotEmpty).toList(),
    );
  }
}

/// Normalize a column header to the canonical camelCase form used by the
/// reconciliation rules. Examples:
///   "Product ID"   → "productId"
///   "product_id"   → "productId"
///   "ProductId"    → "productId"
///   "Movement Type" → "movementType"
///   "Period"       → "period"
String _normalizeColumnName(String input) {
  if (input.isEmpty) return '';
  final s = input.trim().toLowerCase();
  if (s.isEmpty) return '';
  final parts = s.split(RegExp(r'[\s_\-]+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '';
  final iter = parts.iterator..moveNext();
  final first = iter.current;
  final buf = StringBuffer(first);
  while (iter.moveNext()) {
    final p = iter.current;
    if (p.isEmpty) continue;
    buf.write(p[0].toUpperCase());
    if (p.length > 1) buf.write(p.substring(1));
  }
  return buf.toString();
}

/// Friendly error type surfaced to the UI when a file can't be parsed.
class ImportFormatException implements Exception {
  const ImportFormatException(this.message);
  final String message;
  @override
  String toString() => 'ImportFormatException: $message';
}

/// Helpers for parsing common cell types out of a row map.
extension RowParsing on Map<String, String> {
  String str(String key) => this[key]?.trim() ?? '';

  int? parseInt(String key) {
    final v = this[key];
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim().replaceAll(RegExp(r'[^0-9\-]'), ''));
  }

  double? parseDouble(String key) {
    final v = this[key];
    if (v == null || v.trim().isEmpty) return null;
    return double.tryParse(v.trim().replaceAll(RegExp(r'[^0-9\.\-]'), ''));
  }

  DateTime? parseDate(String key) {
    final v = this[key];
    if (v == null || v.trim().isEmpty) return null;
    final s = v.trim();
    // ISO 8601 first
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // dd/MM/yyyy or dd-MM-yyyy
    final parts = s.split(RegExp(r'[/\-]'));
    if (parts.length == 3) {
      final d = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }
}
