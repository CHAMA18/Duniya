import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReplenishmentRecord extends FirestoreRecord {
  ReplenishmentRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "PharmacyId" field.
  DocumentReference? _pharmacyId;
  DocumentReference? get pharmacyId => _pharmacyId;
  bool hasPharmacyId() => _pharmacyId != null;

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "AverageWeeklySales" field.
  double? _averageWeeklySales;
  double get averageWeeklySales => _averageWeeklySales ?? 0.0;
  bool hasAverageWeeklySales() => _averageWeeklySales != null;

  // "CurrentStock" field.
  int? _currentStock;
  int get currentStock => _currentStock ?? 0;
  bool hasCurrentStock() => _currentStock != null;

  // "TargetStockLevel" field.
  int? _targetStockLevel;
  int get targetStockLevel => _targetStockLevel ?? 0;
  bool hasTargetStockLevel() => _targetStockLevel != null;

  // "SuggestedOrderQty" field.
  int? _suggestedOrderQty;
  int get suggestedOrderQty => _suggestedOrderQty ?? 0;
  bool hasSuggestedOrderQty() => _suggestedOrderQty != null;

  // "Period" field.
  String? _period;
  String get period => _period ?? '';
  bool hasPeriod() => _period != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _pharmacyId = snapshotData['PharmacyId'] as DocumentReference?;
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _averageWeeklySales =
        castToType<double>(snapshotData['AverageWeeklySales']);
    _currentStock = castToType<int>(snapshotData['CurrentStock']);
    _targetStockLevel = castToType<int>(snapshotData['TargetStockLevel']);
    _suggestedOrderQty = castToType<int>(snapshotData['SuggestedOrderQty']);
    _period = snapshotData['Period'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Replenishment');

  static Stream<ReplenishmentRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReplenishmentRecord.fromSnapshot(s));

  static Future<ReplenishmentRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReplenishmentRecord.fromSnapshot(s));

  static ReplenishmentRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReplenishmentRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReplenishmentRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReplenishmentRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReplenishmentRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReplenishmentRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReplenishmentRecordData({
  DocumentReference? pharmacyId,
  DocumentReference? productId,
  double? averageWeeklySales,
  int? currentStock,
  int? targetStockLevel,
  int? suggestedOrderQty,
  String? period,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'PharmacyId': pharmacyId,
      'ProductId': productId,
      'AverageWeeklySales': averageWeeklySales,
      'CurrentStock': currentStock,
      'TargetStockLevel': targetStockLevel,
      'SuggestedOrderQty': suggestedOrderQty,
      'Period': period,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReplenishmentRecordDocumentEquality
    implements Equality<ReplenishmentRecord> {
  const ReplenishmentRecordDocumentEquality();

  @override
  bool equals(ReplenishmentRecord? e1, ReplenishmentRecord? e2) {
    return e1?.pharmacyId == e2?.pharmacyId &&
        e1?.productId == e2?.productId &&
        e1?.averageWeeklySales == e2?.averageWeeklySales &&
        e1?.currentStock == e2?.currentStock &&
        e1?.targetStockLevel == e2?.targetStockLevel &&
        e1?.suggestedOrderQty == e2?.suggestedOrderQty &&
        e1?.period == e2?.period &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(ReplenishmentRecord? e) => const ListEquality().hash([
        e?.pharmacyId,
        e?.productId,
        e?.averageWeeklySales,
        e?.currentStock,
        e?.targetStockLevel,
        e?.suggestedOrderQty,
        e?.period,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is ReplenishmentRecord;
}
