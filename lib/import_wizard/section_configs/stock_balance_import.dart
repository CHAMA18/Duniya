import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/rbac/rbac.dart';
import '../reconciliation_engine.dart';

/// Reconciliation config for the Stock Balance import.
///
/// Expected columns (canonical camelCase):
///   - productId (resolved via the ProductMaster name OR SKU lookup)
///   - period (YYYY-MM)
///   - openingStock, stockReceived, stockDispensed, stockTransferred,
///     stockAdjusted (integers)
///   - closingStock (optional — engine will compute if missing)
///
/// Reconciliation:
///   - productId must exist in the ProductMaster collection
///   - period must be YYYY-MM and within the last 12 months
///   - (productId, period) combo must not already exist in StockBalance
///   - all quantities must be non-negative integers
///   - balance equation holds (warning if stated closing != calculated)
class StockBalanceImportConfig extends ReconciliationConfig {
  const StockBalanceImportConfig();

  @override
  String get displayName => 'Stock Balances';

  @override
  String get targetCollection => 'StockBalance';

  @override
  List<String> get expectedColumns => const [
        'productId',
        'period',
        'openingStock',
        'stockReceived',
        'stockDispensed',
        'stockTransferred',
        'stockAdjusted',
        'closingStock',
      ];

  @override
  List<ReconciliationRule> get rules => const [
        RequiredFieldRule('productId'),
        ExistsRule(
          'productId',
          referenceMapKey: 'productMap',
          referenceLabel: 'Product',
          synonyms: {
            'received': 'stockReceived',
          },
        ),
        RequiredFieldRule('period'),
        PeriodWindowRule('period', maxMonthsBack: 12),
        NumericRangeRule('openingStock', min: 0),
        NumericRangeRule('stockReceived', min: 0),
        NumericRangeRule('stockDispensed', min: 0),
        NumericRangeRule('stockTransferred', min: 0),
        NumericRangeRule('stockAdjusted'),
        BalanceEquationRule(),
        UniqueComboRule(
          'productId',
          fields: ['productId', 'period'],
          referenceSetKey: 'existingBalanceKeys',
          referenceLabel: 'Stock balance',
        ),
      ];

  @override
  Future<Map<String, dynamic>> loadReferenceData(BuildContext context) async {
    final parent = AccessControl.parentRef(context) ??
        currentUserReference;
    if (parent == null) {
      throw StateError('No parent reference — cannot load StockBalance refs');
    }
    // Load products
    final products = await queryProductMasterRecordOnce();
    final productMap = <String, ProductMasterRecord>{};
    for (final p in products) {
      if (p.hasName()) productMap[p.name.toLowerCase()] = p;
      if (p.hasSKU()) productMap[p.sku.toLowerCase()] = p;
    }
    // Load existing balance combos to prevent duplicates
    final existing = await queryStockBalanceRecordOnce(parent: parent);
    final existingKeys = <String>{};
    for (final b in existing) {
      if (b.hasProductId() && b.hasPeriod()) {
        existingKeys.add('${b.productId!.id}|${b.period}');
      }
    }
    return {
      '_parentRef': parent,
      'productMap': productMap,
      'productIdMap': productMap,
      'existingBalanceKeys': existingKeys,
    };
  }

  @override
  Map<String, dynamic> buildFirestoreRow(
    Map<String, String> parsed,
    ReconciliationContext ctx,
  ) {
    final parent = ctx.parentRef;
    // Resolve productId via the productMap (by name or SKU)
    final raw = parsed['productId']?.trim() ?? '';
    final productMap = ctx.referenceData['productMap'] as Map<String, ProductMasterRecord>;
    final product = productMap[raw.toLowerCase()] ??
        productMap[raw] ??
        productMap[raw.toLowerCase().replaceAll(' ', '_')];
    final productIdRef = product?.reference;

    final opening = parseIntCell(parsed['openingStock']) ?? 0;
    final received = parseIntCell(parsed['stockReceived']) ?? 0;
    final dispensed = parseIntCell(parsed['stockDispensed']) ?? 0;
    final transferred = parseIntCell(parsed['stockTransferred']) ?? 0;
    final adjusted = parseIntCell(parsed['stockAdjusted']) ?? 0;
    final statedClosing = parseIntCell(parsed['closingStock']);
    final calculatedClosing =
        opening + received - dispensed - transferred + adjusted;
    final closing = statedClosing ?? calculatedClosing;
    final stockValue =
        product != null ? closing * product.costPrice : 0.0;
    final days = dispensed > 0 ? (closing / dispensed * 30.0) : 999.0;

    return createStockBalanceRecordData(
      productId: productIdRef,
      outletId: parent,
      openingStock: opening,
      stockReceived: received,
      stockDispensed: dispensed,
      stockTransferred: transferred,
      stockAdjusted: adjusted,
      closingStock: closing,
      stockValue: stockValue,
      daysOfStockRemaining: days,
      period: parsed['period']?.trim(),
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  @override
  void runBatchChecks(
    List<ReconciledRow> rows,
    ReconciliationContext ctx,
  ) {
    // In-batch dedup: flag rows that share the same (productId, period)
    // within this import as warnings (the second occurrence will be
    // skipped at write time).
    final seen = <String, int>{};
    for (final r in rows) {
      final p = r.parsed['productId']?.trim() ?? '';
      final period = r.parsed['period']?.trim() ?? '';
      if (p.isEmpty || period.isEmpty) continue;
      final key = '$p|$period';
      if (seen.containsKey(key)) {
        if (r.status != RowStatus.error) {
          r.status = RowStatus.warning;
          r.message = '${r.message.isEmpty ? "" : "${r.message} • "}'
              'Duplicate row within this import (first seen at row '
              '${seen[key]}); will be skipped at write time.';
        }
      } else {
        seen[key] = r.sourceRowIndex;
      }
    }
  }

  @override
  Future<int> writeRows({
    required List<ReconciledRow> rows,
    required Map<String, dynamic> referenceData,
    required Map<String, dynamic> signatureFields,
  }) async {
    final parent = referenceData['_parentRef'] as DocumentReference;
    final batch = FirebaseFirestore.instance.batch();
    var written = 0;
    final seen = <String>{};
    for (final r in rows) {
      if (r.isBlocked) continue;
      // Resolve the product ID to a doc reference so we can build the
      // stock balance doc path correctly.
      final raw = r.parsed['productId']?.trim() ?? '';
      final productMap =
          referenceData['productMap'] as Map<String, ProductMasterRecord>;
      final product = productMap[raw.toLowerCase()] ??
          productMap[raw] ??
          productMap[raw.toLowerCase().replaceAll(' ', '_')];
      if (product == null) continue; // can't write without a product ref
      final period = r.parsed['period']?.trim() ?? '';
      if (period.isEmpty) continue;
      final dedupKey = '${product.reference.id}|$period';
      if (seen.contains(dedupKey)) continue;
      seen.add(dedupKey);

      final docRef = StockBalanceRecord.createDoc(parent);
      final data = {
        ...r.firestoreData,
        ...signatureFields,
        'imported_at': FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data);
      written++;
    }
    if (written > 0) {
      await batch.commit();
    }
    return written;
  }
}
