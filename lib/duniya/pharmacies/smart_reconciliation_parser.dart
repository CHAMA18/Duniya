/// Smart Import engine for pharmacy reconciliation workbooks.
///
/// Parses XLSX/CSV reconciliation exports leniently ("smart import"):
///
///  * Auto-detects the best worksheet and the header row inside it (the
///    header does not have to be the first row — title/logo rows above
///    it are tolerated).
///  * Auto-detects columns via a large alias table ("Product",
///    "Product Name", "Opening Balance", "Received Qty", "Counted",
///    "Dispensed", "Unit Price", …) and ignores extra/unrelated
///    columns entirely.
///  * Classifies every data row: valid rows are imported; irrelevant
///    rows (blank lines, section headings, notes, grand-total rows) and
///    broken rows (unreadable figures, totals that do not reconcile)
///    are skipped with a human-readable reason instead of failing the
///    whole import.
///  * Derives missing linear totals when the other two of the trio are
///    present (total = opening + supplied, dispensed = total − physical,
///    …) so workbooks with gaps still import.
///  * Evaluates simple same-row Excel formulas (=F2-G2, =E2*D2) so
///    computed columns survive export.
///  * Parses CSV files (comma, semicolon or tab delimited — sniffed).
///
/// This library is pure Dart (no Flutter imports) so it is fully unit
/// testable.

// ═════════════════════════════════════════════════════════════════
// Result model
// ═════════════════════════════════════════════════════════════════

/// A row that was read but not imported, with the reason why.
class SmartSkippedRow {
  const SmartSkippedRow(this.rowNumber, this.name, this.reason);

  /// 1-based row number inside the worksheet (matches what the user
  /// sees in Excel, including the header offset).
  final int rowNumber;

  /// Product name cell (may be empty).
  final String name;

  /// Human-readable reason.
  final String reason;

  String describe() => name.trim().isEmpty
      ? 'Row $rowNumber — $reason'
      : 'Row $rowNumber “${_ellipsize(name, 28)}” — $reason';

  static String _ellipsize(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}

/// The parse outcome for one sheet.
class SmartParseResult {
  const SmartParseResult({
    required this.sheetName,
    required this.headerRowNumber,
    required this.columns,
    required this.records,
    required this.skipped,
    required this.priceDefaultedCount,
  });

  final String sheetName;

  /// 1-based row number where the header was found.
  final int headerRowNumber;

  /// Canonical column key -> 0-based column index.
  final Map<String, int> columns;

  /// Validated rows in cloud-function record shape:
  /// name, description, openingStock, stockSupplied, totalAvailable,
  /// physicalCount, unitsDispensed, unitCost.
  final List<Map<String, dynamic>> records;

  final List<SmartSkippedRow> skipped;

  /// Rows imported with a defaulted (0) unit price.
  final int priceDefaultedCount;

  bool get isEmpty => records.isEmpty;
}

/// A candidate (sheet, header row) that looked like a reconciliation
/// table, plus its full parse.
class SmartSheetMatch {
  const SmartSheetMatch({
    required this.sheetName,
    required this.headerRowNumber,
    required this.score,
    required this.parse,
  });

  final String sheetName;
  final int headerRowNumber;
  final int score;
  final SmartParseResult parse;
}

// ═════════════════════════════════════════════════════════════════
// Parser
// ═════════════════════════════════════════════════════════════════

class SmartReconciliationParser {
  SmartReconciliationParser._();

  /// Canonical column keys used in [SmartParseResult.columns].
  static const String kProductName = 'product name';
  static const String kDescription = 'description';
  static const String kOpeningStock = 'opening stock';
  static const String kStockSupplied = 'stock supplied';
  static const String kTotalAvailable = 'total available';
  static const String kPhysicalCount = 'physical count';
  static const String kUnitsDispensed = 'units dispensed';
  static const String kUnitPrice = 'transfer unit price';

  static const List<String> _linearTotals = [
    kOpeningStock,
    kStockSupplied,
    kTotalAvailable,
    kPhysicalCount,
    kUnitsDispensed,
  ];

  /// Alias table. Keys and aliases are normalized (lowercase,
  /// alphanumeric only) before comparison.
  static const Map<String, List<String>> _aliases = {
    kProductName: [
      'productname', 'product', 'productitem', 'itemname', 'item',
      'medicine', 'medicines', 'medicinename', 'drug', 'drugname',
      'producttitle', 'productlist', 'nameofproduct',
    ],
    kDescription: [
      'description', 'desc', 'details', 'notes', 'note', 'remarks',
      'additionalnotes', 'comments',
    ],
    kOpeningStock: [
      'openingstock', 'openingbalance', 'opening', 'beginningstock',
      'openingqty', 'openingquantity', 'startstock', 'startingstock',
      'initialstock', 'stockopening',
    ],
    kStockSupplied: [
      'stocksupplied', 'supplied', 'supply', 'stockreceived', 'received',
      'receivedqty', 'receivedquantity', 'deliveries', 'quantitysupplied',
      'suppliedqty', 'suppliedquantity', 'stockin', 'additions',
      'goodsreceived',
    ],
    kTotalAvailable: [
      'totalavailable', 'total', 'totalstock', 'closingstock',
      'availablestock', 'available', 'stockonhand', 'onhand', 'totalqty',
      'totalquantity', 'availableqty', 'closingbalance',
    ],
    kPhysicalCount: [
      'physicalcount', 'physicalstock', 'count', 'counted', 'actualcount',
      'stockcount', 'physical', 'physicalqty', 'countedqty',
      'verifiedcount', 'physicalinventory',
    ],
    kUnitsDispensed: [
      'unitsdispensed', 'dispensed', 'unitssold', 'sold', 'sales',
      'quantitydispensed', 'dispensedunits', 'dispensedqty',
      'dispensedquantity', 'issued', 'unitsissued',
    ],
    kUnitPrice: [
      'transferunitprice', 'unitprice', 'transferprice', 'price',
      'unitcost', 'costprice', 'priceperunit', 'unitrate', 'transfercost',
      'cost',
    ],
  };

  /// Aliases distinctive enough to allow "header contains alias"
  /// matching (short generic words like "total" would be ambiguous).
  static const Set<String> _containableAliases = {
    'openingstock', 'openingbalance', 'beginningstock', 'startingstock',
    'initialstock', 'stocksupplied', 'quantitysupplied', 'stockreceived',
    'receivedquantity', 'totalavailable', 'closingstock', 'availablestock',
    'stockonhand', 'physicalcount', 'physicalstock', 'actualcount',
    'stockcount', 'unitsdispensed', 'quantitydispensed', 'dispensedunits',
    'transferunitprice', 'unitprice', 'transferprice', 'priceperunit',
    'costprice', 'productname',
  };

  static const Set<String> _missingTokens = {
    '', '-', '–', '—', 'n/a', 'na', 'n.a.', 'nil', 'none', 'tbd', 'tba', '.',
  };

  // ── Public API ──────────────────────────────────────────────────

  /// Picks the worksheet + header row that best matches the
  /// reconciliation format and returns its full parse. Returns null
  /// when no sheet in [sheets] contains anything resembling the
  /// expected columns.
  static SmartSheetMatch? detectBestSheet(
    Map<String, List<List<String>>> sheets, {
    int maxHeaderScanRows = 30,
  }) {
    // Collect (sheet, headerRow, columns, score) candidates.
    final candidates = <_Candidate>[];
    for (final entry in sheets.entries) {
      final rows = entry.value;
      final scanTo = rows.length < maxHeaderScanRows
          ? rows.length
          : maxHeaderScanRows;
      for (var r = 0; r < scanTo; r++) {
        final cols = matchColumns(rows[r]);
        if (!_meetsMinimum(cols)) continue;
        final score = cols.length + _sheetNameBonus(entry.key);
        candidates.add(_Candidate(entry.key, r, cols, score));
      }
    }
    if (candidates.isEmpty) return null;

    // Strongest first; ties → earlier header row.
    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.headerRow.compareTo(b.headerRow);
    });

    // Parse candidates in order; the first one with actual records
    // wins. If none have records, return the strongest so the caller
    // can explain what was skipped.
    SmartSheetMatch? fallback;
    for (final c in candidates) {
      final parse = _parseSheet(c.sheetName, c.headerRow, c.columns,
          sheets[c.sheetName]!);
      final match = SmartSheetMatch(
        sheetName: c.sheetName,
        headerRowNumber: c.headerRow + 1,
        score: c.score,
        parse: parse,
      );
      fallback ??= match;
      if (parse.records.isNotEmpty) return match;
    }
    return fallback;
  }

  /// Parses [rows] treating [headerRow] (0-based) as the header.
  static SmartParseResult parseSheet(
    String sheetName,
    int headerRow,
    List<List<String>> rows,
  ) {
    final cols = matchColumns(rows[headerRow]);
    return _parseSheet(sheetName, headerRow, cols, rows);
  }

  /// Maps a header row to canonical column keys. Extra/unrecognized
  /// headers are ignored.
  static Map<String, int> matchColumns(List<String> header) {
    final result = <String, int>{};
    final norms = <int, String>{};
    for (var i = 0; i < header.length; i++) {
      final n = _normalize(header[i]);
      if (n.isNotEmpty) norms[i] = n;
    }

    // Pass 1 — exact alias matches.
    for (final entry in norms.entries) {
      for (final canonical in _aliases.keys) {
        if (result.containsKey(canonical)) continue;
        if (_aliases[canonical]!.contains(entry.value)) {
          result[canonical] = entry.key;
          break;
        }
      }
    }

    // Pass 2 — containment matches (long, distinctive aliases only).
    // "Grand total" and "Subtotal" headers are never matched.
    final containHits = <(int, String, int)>[]; // headerIdx, canonical, aliasLen
    for (final entry in norms.entries) {
      if (result.containsValue(entry.key)) continue;
      final header = entry.value;
      if (header.contains('grand') || header.startsWith('sub')) continue;
      for (final canonical in _aliases.keys) {
        if (result.containsKey(canonical)) continue;
        for (final alias in _aliases[canonical]!) {
          if (alias.length >= 8 &&
              _containableAliases.contains(alias) &&
              header.contains(alias)) {
            containHits.add((entry.key, canonical, alias.length));
          }
        }
      }
    }
    containHits.sort((a, b) => b.$3.compareTo(a.$3));
    for (final hit in containHits) {
      if (result.containsKey(hit.$2)) continue;
      if (result.containsValue(hit.$1)) continue;
      result[hit.$2] = hit.$1;
    }

    return result;
  }

  /// Parses CSV text into rows. Delimiter (comma / semicolon / tab) is
  /// sniffed from the first non-empty line. Handles quoted fields,
  /// escaped quotes, CRLF and a leading BOM.
  static List<List<String>> parseCsv(String content) {
    if (content.startsWith('\uFEFF')) content = content.substring(1);

    // Sniff delimiter.
    final firstLine = content
        .split(RegExp(r'\r?\n'))
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    String delimiter = ',';
    var bestCount = 0;
    for (final d in const [',', ';', '\t']) {
      final count = d.allMatches(firstLine).length;
      if (count > bestCount) {
        bestCount = count;
        delimiter = d;
      }
    }

    final rows = <List<String>>[];
    final field = StringBuffer();
    final row = <String>[];
    var inQuotes = false;
    for (var i = 0; i < content.length; i++) {
      final c = content[i];
      if (inQuotes) {
        if (c == '"') {
          if (i + 1 < content.length && content[i + 1] == '"') {
            field.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(c);
        }
      } else {
        if (c == '"') {
          inQuotes = true;
        } else if (c == delimiter) {
          row.add(field.toString());
          field.clear();
        } else if (c == '\r') {
          // Swallow — handled with \n.
        } else if (c == '\n') {
          row.add(field.toString());
          field.clear();
          rows.add(List.of(row));
          row.clear();
        } else {
          field.write(c);
        }
      }
    }
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      rows.add(row);
    }
    return rows;
  }

  // ── Internals ───────────────────────────────────────────────────

  static int _sheetNameBonus(String name) {
    final n = _normalize(name);
    var bonus = 0;
    if (n.contains('recon')) bonus += 2;
    if (n.contains('final')) bonus += 1;
    return bonus;
  }

  /// A header row qualifies when it maps the product name plus at
  /// least three of the five linear-total columns.
  static bool _meetsMinimum(Map<String, int> columns) {
    if (!columns.containsKey(kProductName)) return false;
    final totals = _linearTotals.where(columns.containsKey).length;
    return totals >= 3;
  }

  static SmartParseResult _parseSheet(
    String sheetName,
    int headerRow,
    Map<String, int> columns,
    List<List<String>> rows,
  ) {
    final records = <Map<String, dynamic>>[];
    final skipped = <SmartSkippedRow>[];
    var priceDefaulted = 0;

    String valueAt(List<String> row, String key) {
      final idx = columns[key];
      if (idx == null || idx >= row.length) return '';
      return row[idx].trim();
    }

    for (var r = headerRow + 1; r < rows.length; r++) {
      final row = rows[r];
      final rowNumber = r + 1;
      final name = valueAt(row, kProductName);

      // Completely blank row — ignore silently.
      final hasAnything = row.any((c) => c.trim().isNotEmpty);
      if (!hasAnything) continue;

      final summaryName = _normalize(name);
      const summaryTokens = {
        'total', 'totals', 'grandtotal', 'grandtotals', 'subtotal',
        'subtotals', 'summary',
      };

      // Grand-total / summary rows — never imported.
      if (summaryTokens.contains(summaryName)) {
        skipped.add(SmartSkippedRow(rowNumber, name, 'summary row'));
        continue;
      }

      // Totals + price raw values.
      final raws = <String, String>{
        for (final k in _linearTotals) k: valueAt(row, k),
      };
      final priceRaw = valueAt(row, kUnitPrice);
      final allTotalsMissing = _linearTotals
          .every((k) => _isMissing(raws[k] ?? ''));

      if (name.isEmpty) {
        if (allTotalsMissing && _isMissing(priceRaw)) continue; // spacer
        skipped.add(SmartSkippedRow(
            rowNumber, name, 'missing product name'));
        continue;
      }

      // Named row with no figures at all — a heading or note.
      if (allTotalsMissing) {
        skipped.add(SmartSkippedRow(
            rowNumber, name, 'no stock figures (heading or note)'));
        continue;
      }

      // Parse each numeric field.
      final vals = <String, num?>{};
      var unreadable = <String>[];
      for (final k in _linearTotals) {
        final parsed = _parseNumeric(raws[k] ?? '', row);
        if (parsed != null && parsed.isNaN) {
          unreadable.add(k);
        } else {
          vals[k] = parsed;
        }
      }
      if (unreadable.isNotEmpty) {
        skipped.add(SmartSkippedRow(rowNumber, name, 'unreadable figures'));
        continue;
      }

      // Derive missing linear totals (two passes resolve chains).
      for (var pass = 0; pass < 2; pass++) {
        if (vals[kTotalAvailable] == null &&
            vals[kOpeningStock] != null &&
            vals[kStockSupplied] != null) {
          vals[kTotalAvailable] =
              vals[kOpeningStock]! + vals[kStockSupplied]!;
        }
        if (vals[kOpeningStock] == null &&
            vals[kTotalAvailable] != null &&
            vals[kStockSupplied] != null) {
          vals[kOpeningStock] = vals[kTotalAvailable]! - vals[kStockSupplied]!;
        }
        if (vals[kStockSupplied] == null &&
            vals[kTotalAvailable] != null &&
            vals[kOpeningStock] != null) {
          vals[kStockSupplied] = vals[kTotalAvailable]! - vals[kOpeningStock]!;
        }
        if (vals[kUnitsDispensed] == null &&
            vals[kTotalAvailable] != null &&
            vals[kPhysicalCount] != null) {
          vals[kUnitsDispensed] =
              vals[kTotalAvailable]! - vals[kPhysicalCount]!;
        }
        if (vals[kPhysicalCount] == null &&
            vals[kTotalAvailable] != null &&
            vals[kUnitsDispensed] != null) {
          vals[kPhysicalCount] =
              vals[kTotalAvailable]! - vals[kUnitsDispensed]!;
        }
      }

      if (_linearTotals.any((k) => vals[k] == null)) {
        skipped.add(SmartSkippedRow(
            rowNumber, name, 'incomplete figures'));
        continue;
      }
      if (_linearTotals.any((k) => vals[k]! < 0)) {
        skipped.add(SmartSkippedRow(
            rowNumber, name, 'implausible (negative) figures'));
        continue;
      }

      final opening = vals[kOpeningStock]!;
      final supplied = vals[kStockSupplied]!;
      final total = vals[kTotalAvailable]!;
      final physical = vals[kPhysicalCount]!;
      final dispensed = vals[kUnitsDispensed]!;

      // Only explicitly-supplied conflicting values can fail here —
      // derived values satisfy the identities by construction.
      const eps = 0.001;
      if ((total - (opening + supplied)).abs() > eps ||
          (dispensed - (total - physical)).abs() > eps) {
        skipped.add(
            SmartSkippedRow(rowNumber, name, 'totals do not reconcile'));
        continue;
      }

      // Unit price — optional, defaults to 0 with a visible note.
      final priceParsed = _parseNumeric(priceRaw, row);
      double unitCost;
      if (priceParsed == null ||
          priceParsed.isNaN ||
          priceParsed < 0) {
        unitCost = 0;
        priceDefaulted++;
      } else {
        unitCost = priceParsed.toDouble();
      }

      records.add({
        'name': name,
        'description': valueAt(row, kDescription),
        'openingStock': _asIntIfIntegral(opening),
        'stockSupplied': _asIntIfIntegral(supplied),
        'totalAvailable': _asIntIfIntegral(total),
        'physicalCount': _asIntIfIntegral(physical),
        'unitsDispensed': _asIntIfIntegral(dispensed),
        'unitCost': unitCost,
      });
    }

    return SmartParseResult(
      sheetName: sheetName,
      headerRowNumber: headerRow + 1,
      columns: columns,
      records: records,
      skipped: skipped,
      priceDefaultedCount: priceDefaulted,
    );
  }

  /// Parses a numeric cell. Returns null when the cell is missing
  /// (blank / dash / N/A), [double.nan] when present but unreadable,
  /// and the value otherwise. Formulas (=F2-G2) are evaluated against
  /// the same row; unresolvable formulas count as missing.
  static num? _parseNumeric(String raw, List<String> row) {
    final s = raw.trim();
    if (_isMissing(s)) return null;
    if (s.startsWith('=')) {
      return _evalFormula(s, row);
    }
    final cleaned = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    if (cleaned.isEmpty ||
        cleaned == '-' ||
        cleaned == '.' ||
        cleaned == '-.') {
      return double.nan;
    }
    return double.tryParse(cleaned) ?? double.nan;
  }

  static bool _isMissing(String raw) =>
      _missingTokens.contains(raw.trim().toLowerCase());

  /// Resolves simple Excel formulas (CELL op CELL) against the same
  /// row. Supports +, -, *, /. Referenced cells that themselves hold
  /// formulas are resolved recursively (bounded) so chains like
  /// =D2-E2 where D2 is =B2+C2 evaluate correctly.
  static num? _evalFormula(String formula, List<String> row,
      {int depth = 0}) {
    final expr = formula.substring(1).trim();
    final m = RegExp(r'^([A-Za-z]+)\d+\s*([+\-*/])\s*([A-Za-z]+)\d+$')
        .firstMatch(expr);
    if (m == null) return null;
    final leftIdx = _excelColToIndex(m.group(1)!);
    final rightIdx = _excelColToIndex(m.group(3)!);
    if (leftIdx == null || rightIdx == null) return null;
    if (leftIdx >= row.length || rightIdx >= row.length) return null;
    final left = _tryDouble(row[leftIdx], row, depth: depth);
    final right = _tryDouble(row[rightIdx], row, depth: depth);
    if (left == null || right == null) return null;
    switch (m.group(2)!) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        return right == 0 ? null : left / right;
    }
    return null;
  }

  static double? _tryDouble(String raw, List<String> row, {int depth = 0}) {
    final s = raw.trim();
    // Referenced cell holds another formula — resolve it (bounded to
    // guard against circular references).
    if (s.startsWith('=') && depth < 3) {
      final v = _evalFormula(s, row, depth: depth + 1);
      return v?.toDouble();
    }
    final cleaned = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }

  /// Excel column letters (A, B, …, AA) → 0-based index.
  static int? _excelColToIndex(String letters) {
    var result = 0;
    for (final c in letters.toUpperCase().codeUnits) {
      if (c < 65 || c > 90) return null;
      result = result * 26 + (c - 64);
    }
    return result - 1;
  }

  static num _asIntIfIntegral(num v) =>
      v == v.roundToDouble() ? v.toInt() : v;

  /// Lowercase alphanumeric, with parenthetical/bracketed remarks and
  /// non-alphanumerics removed: "Product Name (brand)" → "productname".
  static String _normalize(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    s = s.replaceAll(RegExp(r'\[[^\]]*\]'), ' ');
    s = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return s;
  }
}

class _Candidate {
  const _Candidate(this.sheetName, this.headerRow, this.columns, this.score);

  final String sheetName;
  final int headerRow;
  final Map<String, int> columns;
  final int score;
}
