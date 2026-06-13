import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockBalanceRecord extends FirestoreRecord {
  StockBalanceRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "OutletId" field.
  DocumentReference? _outletId;
  DocumentReference? get outletId => _outletId;
  bool hasOutletId() => _outletId != null;

  // "OpeningStock" field.
  int? _openingStock;
  int get openingStock => _openingStock ?? 0;
  bool hasOpeningStock() => _openingStock != null;

  // "StockReceived" field.
  int? _stockReceived;
  int get stockReceived => _stockReceived ?? 0;
  bool hasStockReceived() => _stockReceived != null;

  // "StockDispensed" field.
  int? _stockDispensed;
  int get stockDispensed => _stockDispensed ?? 0;
  bool hasStockDispensed() => _stockDispensed != null;

  // "StockTransferred" field.
  int? _stockTransferred;
  int get stockTransferred => _stockTransferred ?? 0;
  bool hasStockTransferred() => _stockTransferred != null;

  // "StockAdjusted" field.
  int? _stockAdjusted;
  int get stockAdjusted => _stockAdjusted ?? 0;
  bool hasStockAdjusted() => _stockAdjusted != null;

  // "ClosingStock" field.
  int? _closingStock;
  int get closingStock => _closingStock ?? 0;
  bool hasClosingStock() => _closingStock != null;

  // "StockValue" field.
  double? _stockValue;
  double get stockValue => _stockValue ?? 0.0;
  bool hasStockValue() => _stockValue != null;

  // "DaysOfStockRemaining" field.
  double? _daysOfStockRemaining;
  double get daysOfStockRemaining => _daysOfStockRemaining ?? 0.0;
  bool hasDaysOfStockRemaining() => _daysOfStockRemaining != null;

  // "Period" field.
  String? _period;
  String get period => _period ?? '';
  bool hasPeriod() => _period != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _outletId = snapshotData['OutletId'] as DocumentReference?;
    _openingStock = castToType<int>(snapshotData['OpeningStock']);
    _stockReceived = castToType<int>(snapshotData['StockReceived']);
    _stockDispensed = castToType<int>(snapshotData['StockDispensed']);
    _stockTransferred = castToType<int>(snapshotData['StockTransferred']);
    _stockAdjusted = castToType<int>(snapshotData['StockAdjusted']);
    _closingStock = castToType<int>(snapshotData['ClosingStock']);
    _stockValue = castToType<double>(snapshotData['StockValue']);
    _daysOfStockRemaining =
        castToType<double>(snapshotData['DaysOfStockRemaining']);
    _period = snapshotData['Period'] as String?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('StockBalance')
          : FirebaseFirestore.instance.collectionGroup('StockBalance');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('StockBalance').doc(id);

  static Stream<StockBalanceRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockBalanceRecord.fromSnapshot(s));

  static Future<StockBalanceRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StockBalanceRecord.fromSnapshot(s));

  static StockBalanceRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StockBalanceRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockBalanceRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockBalanceRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockBalanceRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockBalanceRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockBalanceRecordData({
  DocumentReference? productId,
  DocumentReference? outletId,
  int? openingStock,
  int? stockReceived,
  int? stockDispensed,
  int? stockTransferred,
  int? stockAdjusted,
  int? closingStock,
  double? stockValue,
  double? daysOfStockRemaining,
  String? period,
  DateTime? updatedAt,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'OutletId': outletId,
      'OpeningStock': openingStock,
      'StockReceived': stockReceived,
      'StockDispensed': stockDispensed,
      'StockTransferred': stockTransferred,
      'StockAdjusted': stockAdjusted,
      'ClosingStock': closingStock,
      'StockValue': stockValue,
      'DaysOfStockRemaining': daysOfStockRemaining,
      'Period': period,
      'UpdatedAt': updatedAt,
      'CreatedAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockBalanceRecordDocumentEquality
    implements Equality<StockBalanceRecord> {
  const StockBalanceRecordDocumentEquality();

  @override
  bool equals(StockBalanceRecord? e1, StockBalanceRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.outletId == e2?.outletId &&
        e1?.openingStock == e2?.openingStock &&
        e1?.stockReceived == e2?.stockReceived &&
        e1?.stockDispensed == e2?.stockDispensed &&
        e1?.stockTransferred == e2?.stockTransferred &&
        e1?.stockAdjusted == e2?.stockAdjusted &&
        e1?.closingStock == e2?.closingStock &&
        e1?.stockValue == e2?.stockValue &&
        e1?.daysOfStockRemaining == e2?.daysOfStockRemaining &&
        e1?.period == e2?.period &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(StockBalanceRecord? e) => const ListEquality().hash([
        e?.productId,
        e?.outletId,
        e?.openingStock,
        e?.stockReceived,
        e?.stockDispensed,
        e?.stockTransferred,
        e?.stockAdjusted,
        e?.closingStock,
        e?.stockValue,
        e?.daysOfStockRemaining,
        e?.period,
        e?.updatedAt,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is StockBalanceRecord;
}
