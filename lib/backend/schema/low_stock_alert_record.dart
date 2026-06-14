import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LowStockAlertRecord extends FirestoreRecord {
  LowStockAlertRecord._(
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

  // "CurrentStock" field.
  int? _currentStock;
  int get currentStock => _currentStock ?? 0;
  bool hasCurrentStock() => _currentStock != null;

  // "ReorderLevel" field.
  int? _reorderLevel;
  int get reorderLevel => _reorderLevel ?? 0;
  bool hasReorderLevel() => _reorderLevel != null;

  // "SuggestedQuantity" field.
  int? _suggestedQuantity;
  int get suggestedQuantity => _suggestedQuantity ?? 0;
  bool hasSuggestedQuantity() => _suggestedQuantity != null;

  // "Status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

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
    _currentStock = castToType<int>(snapshotData['CurrentStock']);
    _reorderLevel = castToType<int>(snapshotData['ReorderLevel']);
    _suggestedQuantity = castToType<int>(snapshotData['SuggestedQuantity']);
    _status = snapshotData['Status'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('LowStockAlert');

  static Stream<LowStockAlertRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LowStockAlertRecord.fromSnapshot(s));

  static Future<LowStockAlertRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LowStockAlertRecord.fromSnapshot(s));

  static LowStockAlertRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LowStockAlertRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LowStockAlertRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LowStockAlertRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LowStockAlertRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LowStockAlertRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLowStockAlertRecordData({
  DocumentReference? pharmacyId,
  DocumentReference? productId,
  int? currentStock,
  int? reorderLevel,
  int? suggestedQuantity,
  String? status,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'PharmacyId': pharmacyId,
      'ProductId': productId,
      'CurrentStock': currentStock,
      'ReorderLevel': reorderLevel,
      'SuggestedQuantity': suggestedQuantity,
      'Status': status,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class LowStockAlertRecordDocumentEquality
    implements Equality<LowStockAlertRecord> {
  const LowStockAlertRecordDocumentEquality();

  @override
  bool equals(LowStockAlertRecord? e1, LowStockAlertRecord? e2) {
    return e1?.pharmacyId == e2?.pharmacyId &&
        e1?.productId == e2?.productId &&
        e1?.currentStock == e2?.currentStock &&
        e1?.reorderLevel == e2?.reorderLevel &&
        e1?.suggestedQuantity == e2?.suggestedQuantity &&
        e1?.status == e2?.status &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(LowStockAlertRecord? e) => const ListEquality().hash([
        e?.pharmacyId,
        e?.productId,
        e?.currentStock,
        e?.reorderLevel,
        e?.suggestedQuantity,
        e?.status,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is LowStockAlertRecord;
}
