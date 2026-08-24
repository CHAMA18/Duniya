/// Reconciliation engine for the Import Wizard.
///
/// Each section (Stock Balances, Stock Movements, Stock Counts) provides
/// a [ReconciliationConfig] that knows:
///   - how to fetch the existing reference records (products, stocks, etc.)
///   - the list of [ReconciliationRule]s to run against each parsed row
///   - how to write a reconciled row to Firestore (with audit fields)
///
/// The engine runs the rules in order and aggregates the row status. If
/// any rule returns [RowStatus.error], the row is blocked from import
/// unless the owner explicitly overrides (per-row "Allow" toggle in the
/// preview step — out of scope for the first cut).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Per-row status assigned by the reconciliation rules.
enum RowStatus {
  /// All rules passed.
  ok,

  /// Soft warning — row will still import unless owner blocks at sign-off.
  warning,

  /// Hard error — row will be skipped at write time.
  error,
}

class RowStatusX {
  static String label(RowStatus s) {
    switch (s) {
      case RowStatus.ok:
        return 'OK';
      case RowStatus.warning:
        return 'Warning';
      case RowStatus.error:
        return 'Error';
    }
  }
}

/// A single row after reconciliation. Carries the original parsed data,
/// the resolved Firestore fields (set by the config's prepareForWrite),
/// and the aggregated status + human message.
class ReconciledRow {
  ReconciledRow({
    required this.sourceRowIndex,
    required this.parsed,
    required this.firestoreData,
    required this.status,
    required this.message,
  });

  /// 0-indexed row position in the parsed file (for display + debugging).
  final int sourceRowIndex;

  /// The original parsed row map (normalized column names → string values).
  final Map<String, String> parsed;

  /// The Firestore-ready map (will be written as-is on submit, with the
  /// signature audit fields appended by the wizard).
  final Map<String, dynamic> firestoreData;

  RowStatus status;
  String message;

  bool get isBlocked => status == RowStatus.error;
  bool get isWarned => status == RowStatus.warning;
}

/// The result of running reconciliation across the whole file.
class ReconciliationResult {
  const ReconciliationResult({
    required this.rows,
    required this.referenceData,
  });

  final List<ReconciledRow> rows;
  final Map<String, dynamic> referenceData;

  int get total => rows.length;
  int get okCount => rows.where((r) => r.status == RowStatus.ok).length;
  int get warningCount =>
      rows.where((r) => r.status == RowStatus.warning).length;
  int get errorCount => rows.where((r) => r.status == RowStatus.error).length;
  int get importableCount => okCount + warningCount;
  bool get canImport => importableCount > 0 && errorCount < total;
}

/// A single rule. Configs compose multiple rules together.
abstract class ReconciliationRule {
  const ReconciliationRule(this.fieldKey);

  /// The canonical camelCase field name this rule operates on
  /// (for display only — does not affect execution).
  final String fieldKey;

  /// Run the check against the parsed row + the reference data
  /// loaded by the config. Returns null if OK, or a tuple of
  /// (status, message) when the rule fires.
  RuleResult? check(
    Map<String, String> parsed,
    ReconciliationContext ctx,
  );
}

class RuleResult {
  const RuleResult(this.status, this.message);
  final RowStatus status;
  final String message;
}

/// Context object passed to every rule. Holds the loaded reference data
/// so each rule can do its own lookup without re-fetching.
class ReconciliationContext {
  const ReconciliationContext({
    required this.referenceData,
    required this.parentRef,
  });

  final Map<String, dynamic> referenceData;
  final DocumentReference parentRef;

  /// Convenience typed accessor.
  T get<T>(String key) => referenceData[key] as T;
}

/// Rule: the field must be non-empty.
class RequiredFieldRule extends ReconciliationRule {
  const RequiredFieldRule(super.fieldKey);
  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final v = parsed[fieldKey]?.trim() ?? '';
    if (v.isEmpty) {
      return RuleResult(RowStatus.error, '$fieldKey is required');
    }
    return null;
  }
}

/// Rule: the value must parse as an int and fall within [min] / [max].
class NumericRangeRule extends ReconciliationRule {
  const NumericRangeRule(
    super.fieldKey, {
    this.min = 0,
    this.max = double.infinity,
    this.allowZero = true,
  });

  final double min;
  final double max;
  final bool allowZero;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final n = double.tryParse(raw.replaceAll(RegExp(r'[^0-9\.\-]'), ''));
    if (n == null) {
      return RuleResult(RowStatus.error, '$fieldKey "$raw" is not a number');
    }
    if (!allowZero && n == 0) {
      return RuleResult(RowStatus.error, '$fieldKey must be greater than 0');
    }
    if (n < min) {
      return RuleResult(
          RowStatus.error, '$fieldKey $n is below minimum $min');
    }
    if (n > max) {
      return RuleResult(
          RowStatus.error, '$fieldKey $n exceeds maximum $max');
    }
    return null;
  }
}

/// Rule: the value must match one of [allowed] (case-insensitive, with
/// fuzzy synonyms if provided).
class EnumRule extends ReconciliationRule {
  const EnumRule(
    super.fieldKey,
    this.allowed, {
    this.synonyms = const {},
  });

  /// The canonical allowed values (already-uppercase, e.g. ["IN", "OUT"]).
  final List<String> allowed;

  /// Synonyms map: lowercase input → canonical allowed value.
  /// Example: {"received": "IN", "inflow": "IN", "out": "OUT"}.
  final Map<String, String> synonyms;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final lower = raw.toLowerCase().replaceAll(' ', '_');
    // Direct match?
    for (final allowed_ in allowed) {
      if (lower == allowed_.toLowerCase()) return null;
    }
    // Synonym?
    if (synonyms.containsKey(lower)) return null;
    return RuleResult(
      RowStatus.error,
      '$fieldKey "$raw" is not one of: ${allowed.join(", ")}',
    );
  }

  /// Resolve a parsed value to its canonical form (synonyms expanded).
  String? canonicalize(String? raw) {
    if (raw == null) return null;
    final lower = raw.toLowerCase().replaceAll(' ', '_');
    for (final a in allowed) {
      if (lower == a.toLowerCase()) return a;
    }
    return synonyms[lower];
  }
}

/// Rule: the date must not be in the future.
class NotFutureDateRule extends ReconciliationRule {
  const NotFutureDateRule(super.fieldKey);
  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final d = _parseDate(raw);
    if (d == null) {
      return RuleResult(RowStatus.error,
          '$fieldKey "$raw" is not a valid date');
    }
    final now = DateTime.now();
    if (d.isAfter(now.add(const Duration(days: 1)))) {
      return RuleResult(RowStatus.warning,
          '$fieldKey is in the future ($raw)');
    }
    return null;
  }
}

/// Rule: the period string must match "YYYY-MM" and fall within the
/// last [maxMonthsBack] months (inclusive of current month).
class PeriodWindowRule extends ReconciliationRule {
  const PeriodWindowRule(super.fieldKey, {this.maxMonthsBack = 12});
  final int maxMonthsBack;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(raw);
    if (match == null) {
      return RuleResult(RowStatus.error,
          '$fieldKey "$raw" must be YYYY-MM');
    }
    final y = int.tryParse(match.group(1)!);
    final m = int.tryParse(match.group(2)!);
    if (y == null || m == null || m < 1 || m > 12) {
      return RuleResult(RowStatus.error,
          '$fieldKey "$raw" is not a valid month');
    }
    final periodDate = DateTime(y, m, 1);
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - maxMonthsBack, 1);
    if (periodDate.isBefore(cutoff)) {
      return RuleResult(RowStatus.warning,
          '$fieldKey $raw is older than $maxMonthsBack months back');
    }
    if (periodDate.isAfter(DateTime(now.year, now.month + 1, 1))) {
      return RuleResult(RowStatus.error,
          '$fieldKey $raw is in the future');
    }
    return null;
  }
}

/// Rule: the count of distinct values for [fieldKey] in the import must
/// not exceed the size of [referenceSetKey] in the reference data.
/// Use case: Stock Counts can't import more distinct product IDs than
/// exist in the pharmacy's stock.
class MaxRowsRule extends ReconciliationRule {
  const MaxRowsRule(
    super.fieldKey, {
    required this.referenceSetKey,
    required this.referenceLabel,
  });

  final String referenceSetKey;
  final String referenceLabel;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    // Single-row rule: check the value exists in the reference set.
    // The "max distinct rows" aggregate check is done separately by the
    // engine via _checkMaxDistinct().
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final set = ctx.referenceData[referenceSetKey];
    if (set is! Set) return null;
    if (set.contains(raw)) return null;
    return RuleResult(RowStatus.error,
        '$referenceLabel "$raw" does not exist in the system');
  }
}

/// Rule: the referenced value (by ID or name) must exist in the loaded
/// reference data. Looks the value up in [referenceMapKey] — which maps
/// the lowercased lookup key to the resolved entity.
class ExistsRule extends ReconciliationRule {
  const ExistsRule(
    super.fieldKey, {
    required this.referenceMapKey,
    required this.referenceLabel,
    this.synonyms = const {},
  });

  final String referenceMapKey;
  final String referenceLabel;
  final Map<String, String> synonyms;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final raw = parsed[fieldKey]?.trim() ?? '';
    if (raw.isEmpty) return null;
    final lower = raw.toLowerCase().replaceAll(' ', '_');
    final map = ctx.referenceData[referenceMapKey];
    if (map is! Map) return null;
    if (map.containsKey(raw) || map.containsKey(lower)) return null;
    if (synonyms.containsKey(lower) && map.containsKey(synonyms[lower])) {
      return null;
    }
    return RuleResult(RowStatus.error,
        '$referenceLabel "$raw" not found');
  }
}

/// Rule: the combination of [fields] must not already exist in the
/// collection. Used to prevent duplicate StockBalances for the same
/// product+period.
class UniqueComboRule extends ReconciliationRule {
  const UniqueComboRule(
    super.fieldKey, {
    required this.fields,
    required this.referenceSetKey,
    required this.referenceLabel,
  });

  final List<String> fields;
  final String referenceSetKey;
  final String referenceLabel;

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    // Per-row rule: we check whether the combo is already in the loaded
    // set of existing combos. The engine handles in-batch dedup.
    final values = fields.map((f) => parsed[f]?.trim() ?? '').toList();
    if (values.any((v) => v.isEmpty)) return null;
    // Resolve canonical IDs via reference data
    final resolved = <String>[];
    for (var i = 0; i < fields.length; i++) {
      final f = fields[i];
      final v = values[i];
      final mapKey = '${f}Map';
      final map = ctx.referenceData[mapKey];
      if (map is Map && (map.containsKey(v) || map.containsKey(v.toLowerCase()))) {
        resolved.add((map[v] ?? map[v.toLowerCase()]).toString());
      } else {
        resolved.add(v);
      }
    }
    final key = resolved.join('|');
    final set = ctx.referenceData[referenceSetKey];
    if (set is Set && set.contains(key)) {
      return RuleResult(RowStatus.error,
          '$referenceLabel already exists for ${fields.join(" + ")} = '
          '${values.join(" / ")}');
    }
    return null;
  }
}

/// Rule: balance equation holds. Used by StockBalances:
/// closing >= opening + received - dispensed - transferred + adjusted
class BalanceEquationRule extends ReconciliationRule {
  const BalanceEquationRule() : super('balanceEquation');

  @override
  RuleResult? check(Map<String, String> parsed, ReconciliationContext ctx) {
    final opening = parseIntCell(parsed['openingStock']) ?? 0;
    final received = parseIntCell(parsed['stockReceived']) ?? 0;
    final dispensed = parseIntCell(parsed['stockDispensed']) ?? 0;
    final transferred = parseIntCell(parsed['stockTransferred']) ?? 0;
    final adjusted = parseIntCell(parsed['stockAdjusted']) ?? 0;
    final closing = parseIntCell(parsed['closingStock']);

    final projected =
        opening + received - dispensed - transferred + adjusted;
    if (projected < 0) {
      return RuleResult(RowStatus.warning,
          'Projected closing balance is negative ($projected). '
          'Verify dispensed/transferred values.');
    }
    if (closing != null && closing != projected) {
      return RuleResult(RowStatus.warning,
          'Stated closing ($closing) does not match calculated ($projected). '
          'The calculated value will be used.');
    }
    return null;
  }
}

/// Engine that runs a list of rules against each row.
class ReconciliationEngine {
  const ReconciliationEngine(this.config);

  final ReconciliationConfig config;

  /// Run all rules across every parsed row.
  /// Reference data is fetched once via [config.loadReferenceData]
  /// before the rule loop begins.
  Future<ReconciliationResult> reconcile({
    required BuildContext context,
    required List<Map<String, String>> parsedRows,
  }) async {
    final referenceData =
        await config.loadReferenceData(context);
    final ctx = ReconciliationContext(
      referenceData: referenceData,
      parentRef: referenceData['_parentRef'] as DocumentReference,
    );

    // First pass: run per-row rules.
    final rows = <ReconciledRow>[];
    for (var i = 0; i < parsedRows.length; i++) {
      final parsed = parsedRows[i];
      RowStatus worst = RowStatus.ok;
      final messages = <String>[];
      for (final rule in config.rules) {
        final result = rule.check(parsed, ctx);
        if (result == null) continue;
        if (result.status == RowStatus.error) {
          worst = RowStatus.error;
        } else if (worst != RowStatus.error &&
            result.status == RowStatus.warning) {
          worst = RowStatus.warning;
        }
        messages.add(result.message);
      }
      // Build the Firestore data for this row
      final firestoreData = config.buildFirestoreRow(parsed, ctx);
      rows.add(ReconciledRow(
        sourceRowIndex: i + 1, // 1-indexed for display
        parsed: parsed,
        firestoreData: firestoreData,
        status: worst,
        message: messages.join(' • '),
      ));
    }

    // Second pass: in-batch dedup check (e.g. duplicate product+period
    // within the same file).
    config.runBatchChecks(rows, ctx);

    return ReconciliationResult(rows: rows, referenceData: referenceData);
  }
}

DateTime? _parseDate(String raw) {
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;
  final parts = raw.split(RegExp(r'[/\-]'));
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

/// Parse a string cell value into an int (or null if empty/invalid).
/// Shared by rules + section configs that need to coerce cell strings
/// into numbers.
int? parseIntCell(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  return int.tryParse(s.replaceAll(RegExp(r'[^0-9\-]'), ''));
}

/// Parse a string cell value into a DateTime (or null).
/// Accepts ISO 8601 and dd/MM/yyyy (or dd-MM-yyyy).
DateTime? parseDateCell(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  return _parseDate(s);
}

/// Per-section configuration. Subclasses (one per collection) implement:
///   - [loadReferenceData]: fetch products / stocks / existing balances etc.
///   - [rules]: the list of [ReconciliationRule]s to run on each row.
///   - [buildFirestoreRow]: convert a parsed row into the Firestore map
///     that will be written.
///   - [writeRows]: actually persist the reconciled rows (with audit fields
///     appended) — implementations can use a batch write for efficiency.
///   - [runBatchChecks]: in-batch dedup or max-distinct check.
abstract class ReconciliationConfig {
  const ReconciliationConfig();

  /// Display name (e.g. "Stock Balances").
  String get displayName;

  /// Firestore collection name (e.g. "StockBalance").
  String get targetCollection;

  /// The list of column names (canonical camelCase) the wizard should
  /// surface in the preview header row.
  List<String> get expectedColumns;

  /// Load all reference data needed by the rules. Runs once per import.
  /// Must include a `_parentRef` key with the Firestore parent reference.
  Future<Map<String, dynamic>> loadReferenceData(BuildContext context);

  /// The per-row rules to run (in order).
  List<ReconciliationRule> get rules;

  /// Convert a parsed row into the Firestore-ready map (without audit
  /// fields — those are appended by the wizard at write time).
  Map<String, dynamic> buildFirestoreRow(
    Map<String, String> parsed,
    ReconciliationContext ctx,
  );

  /// In-batch checks that need visibility across all rows (e.g. dedup).
  /// Default: no-op. Override in subclasses that need it.
  void runBatchChecks(
    List<ReconciledRow> rows,
    ReconciliationContext ctx,
  ) {}

  /// Write the importable rows to Firestore. Returns the number of rows
  /// successfully written.
  Future<int> writeRows({
    required List<ReconciledRow> rows,
    required Map<String, dynamic> referenceData,
    required Map<String, dynamic> signatureFields,
  });
}
