import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/rbac/rbac.dart';
import '../reconciliation_engine.dart';

/// Reconciliation config for the Stock Movement import.
///
/// Expected columns (canonical camelCase):
///   - stockId (resolved via Stock record's ProductId + BatchNumber,
///     OR by the ProductMaster name + BatchNumber lookup)
///   - productName (denormalized snapshot)
///   - movementType (one of RECEIVED, SOLD, RETURNED, TRANSFERRED,
///     DAMAGED, EXPIRED, ADJUSTMENT, COUNT_CORRECTION)
///   - quantity (positive integer)
///   - reason (optional freeform text)
///   - movementReference (optional — must be unique if provided)
///   - movementDate (ISO date or dd/MM/yyyy — must not be in the future)
///
/// Reconciliation:
///   - stockId must resolve to an existing Stock record
///   - movementType must be one of the canonical values (synonyms
///     accepted: "received"/"inflow" → RECEIVED, "sold"/"out" → SOLD)
///   - quantity > 0
///   - movementDate not in the future
///   - Soft warning: for SOLD/DAMAGED movements, projected balance =
///     current stock - quantity; warns if negative
///   - movementReference uniqueness (if provided)
class StockMovementImportConfig extends ReconciliationConfig {
  const StockMovementImportConfig();

  @override
  String get displayName => 'Stock Movements';

  @override
  String get targetCollection => 'StockMovement';

  @override
  List<String> get expectedColumns => const [
        'productId',
        'productName',
        'batchNumber',
        'movementType',
        'quantity',
        'reason',
        'movementReference',
        'movementDate',
      ];

  /// Canonical movement types + their accepted synonyms.
  static const _synonyms = <String, String>{
    'received': 'RECEIVED',
    'in': 'RECEIVED',
    'inflow': 'RECEIVED',
    'sold': 'SOLD',
    'dispensed': 'SOLD',
    'out': 'SOLD',
    'outflow': 'SOLD',
    'return': 'RETURNED',
    'returned': 'RETURNED',
    'transfer': 'TRANSFERRED',
    'transferred': 'TRANSFERRED',
    'damage': 'DAMAGED',
    'damaged': 'DAMAGED',
    'spoilage': 'DAMAGED',
    'expired': 'EXPIRED',
    'expiry': 'EXPIRED',
    'adjust': 'ADJUSTMENT',
    'adjustment': 'ADJUSTMENT',
    'count': 'COUNT_CORRECTION',
    'count_correction': 'COUNT_CORRECTION',
  };

  static const _allowed = <String>[
    'RECEIVED',
    'SOLD',
    'RETURNED',
    'TRANSFERRED',
    'DAMAGED',
    'EXPIRED',
    'ADJUSTMENT',
    'COUNT_CORRECTION',
  ];

  @override
  List<ReconciliationRule> get rules => const [
        RequiredFieldRule('productId'),
        RequiredFieldRule('movementType'),
        EnumRule(
          'movementType',
          _allowed,
          synonyms: _synonyms,
        ),
        RequiredFieldRule('quantity'),
        NumericRangeRule('quantity', min: 1, allowZero: false),
        NotFutureDateRule('movementDate'),
        ExistsRule(
          'productId',
          referenceMapKey: 'productMap',
          referenceLabel: 'Product',
        ),
      ];

  @override
  Future<Map<String, dynamic>> loadReferenceData(BuildContext context) async {
    final parent = AccessControl.parentRef(context) ?? currentUserReference;
    if (parent == null) {
      throw StateError('No parent reference — cannot load StockMovement refs');
    }
    // Load all stock records for this owner scope — used to resolve
    // productId + batchNumber to a stock doc reference.
    final stocks = await queryStockRecordOnce(
      parent: AccessControl.networkWideQueryParent(context),
    );
    final stockByProductBatch = <String, StockRecord>{};
    final stockByName = <String, StockRecord>{};
    for (final s in stocks) {
      final key = '${s.name}|${s.batchNumber}'.toLowerCase();
      stockByProductBatch[key] = s;
      if (s.hasName()) stockByName[s.name.toLowerCase()] = s;
    }
    // Load products for name-based lookup
    final products = await queryProductMasterRecordOnce();
    final productMap = <String, ProductMasterRecord>{};
    for (final p in products) {
      if (p.hasName()) productMap[p.name.toLowerCase()] = p;
      if (p.hasSKU()) productMap[p.sku.toLowerCase()] = p;
    }
    // Load existing movement references for uniqueness check
    final existingMovements = await queryStockMovementRecordOnce(parent: parent);
    final existingRefs = <String>{};
    for (final m in existingMovements) {
      final ref = m.movementReference;
      if (ref != null && ref.isNotEmpty) existingRefs.add(ref);
    }
    return {
      '_parentRef': parent,
      'productMap': productMap,
      'stockByProductBatch': stockByProductBatch,
      'stockByName': stockByName,
      'existingMovementReferences': existingRefs,
    };
  }

  @override
  Map<String, dynamic> buildFirestoreRow(
    Map<String, String> parsed,
    ReconciliationContext ctx,
  ) {
    final raw = parsed['productId']?.trim() ?? '';
    final productMap =
        ctx.referenceData['productMap'] as Map<String, ProductMasterRecord>;
    final product = productMap[raw.toLowerCase()] ??
        productMap[raw] ??
        productMap[raw.toLowerCase().replaceAll(' ', '_')];
    final productRef = product?.reference;
    final productName = parsed['productName']?.trim().isNotEmpty == true
        ? parsed['productName']!.trim()
        : (product?.name ?? '');
    final batchNumber = parsed['batchNumber']?.trim() ?? '';
    final stockKey = '${productName.toLowerCase()}|${batchNumber.toLowerCase()}';
    final stockByBatch =
        ctx.referenceData['stockByProductBatch'] as Map<String, StockRecord>;
    final stock = stockByBatch[stockKey] ??
        (ctx.referenceData['stockByName']
                as Map<String, StockRecord>)[productName.toLowerCase()];

    final movementTypeRaw = parsed['movementType']?.trim() ?? '';
    final movementType = _canonicalizeMovementType(movementTypeRaw);

    final quantity = parseIntCell(parsed['quantity']) ?? 0;
    final reason = parsed['reason']?.trim();
    final movementReference = parsed['movementReference']?.trim();
    final movementDate = parseDateCell(parsed['movementDate']);

    return createStockMovementRecordData(
      productId: stock?.reference ?? productRef,
      productName: productName,
      outletId: ctx.parentRef,
      quantity: quantity,
      movementType: movementType,
      reason: reason,
      movementReference: movementReference,
      recordedById: currentUserReference,
      createdAt: movementDate ?? DateTime.now(),
    );
  }

  @override
  void runBatchChecks(
    List<ReconciledRow> rows,
    ReconciliationContext ctx,
  ) {
    final seenRefs = <String, int>{};
    final existingRefs =
        ctx.referenceData['existingMovementReferences'] as Set;
    for (final r in rows) {
      final ref = r.parsed['movementReference']?.trim();
      if (ref == null || ref.isEmpty) continue;
      if (existingRefs.contains(ref)) {
        if (r.status != RowStatus.error) {
          r.status = RowStatus.error;
          r.message = '${r.message.isEmpty ? "" : "${r.message} • "}'
              'Movement reference "$ref" already exists in the system.';
        }
        continue;
      }
      if (seenRefs.containsKey(ref)) {
        if (r.status != RowStatus.error) {
          r.status = RowStatus.warning;
          r.message = '${r.message.isEmpty ? "" : "${r.message} • "}'
              'Duplicate movement reference within this import '
              '(first seen at row ${seenRefs[ref]}); will be skipped.';
        }
      } else {
        seenRefs[ref] = r.sourceRowIndex;
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
    final seenRefs = <String>{};
    for (final r in rows) {
      if (r.isBlocked) continue;
      final ref = r.parsed['movementReference']?.trim() ?? '';
      if (ref.isNotEmpty && seenRefs.contains(ref)) continue;
      if (ref.isNotEmpty) seenRefs.add(ref);
      final docRef = StockMovementRecord.createDoc(parent);
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

  /// Resolve an incoming movement-type string to its canonical form
  /// (e.g. "received" / "inflow" → "RECEIVED").
  static String _canonicalizeMovementType(String raw) {
    if (raw.isEmpty) return '';
    final lower = raw.toLowerCase().replaceAll(' ', '_');
    for (final a in _allowed) {
      if (lower == a.toLowerCase()) return a;
    }
    return _synonyms[lower] ?? raw.toUpperCase();
  }
}
