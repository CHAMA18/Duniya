import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockMovementRecord extends FirestoreRecord {
  StockMovementRecord._(
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

  // "Quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "MovementType" field.
  String? _movementType;
  String get movementType => _movementType ?? '';
  bool hasMovementType() => _movementType != null;

  // "Reason" field.
  String? _reason;
  String? get reason => _reason;
  bool hasReason() => _reason != null;

  // "MovementReference" field.
  String? _movementReference;
  String? get movementReference => _movementReference;
  bool hasMovementReference() => _movementReference != null;

  // "RecordedById" field.
  DocumentReference? _recordedById;
  DocumentReference? get recordedById => _recordedById;
  bool hasRecordedById() => _recordedById != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _outletId = snapshotData['OutletId'] as DocumentReference?;
    _quantity = castToType<int>(snapshotData['Quantity']);
    _movementType = snapshotData['MovementType'] as String?;
    _reason = snapshotData['Reason'] as String?;
    _movementReference = snapshotData['MovementReference'] as String?;
    _recordedById = snapshotData['RecordedById'] as DocumentReference?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('StockMovement')
          : FirebaseFirestore.instance.collectionGroup('StockMovement');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('StockMovement').doc(id);

  static Stream<StockMovementRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockMovementRecord.fromSnapshot(s));

  static Future<StockMovementRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StockMovementRecord.fromSnapshot(s));

  static StockMovementRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StockMovementRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockMovementRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockMovementRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockMovementRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockMovementRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockMovementRecordData({
  DocumentReference? productId,
  DocumentReference? outletId,
  int? quantity,
  String? movementType,
  String? reason,
  String? movementReference,
  DocumentReference? recordedById,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'OutletId': outletId,
      'Quantity': quantity,
      'MovementType': movementType,
      'Reason': reason,
      'MovementReference': movementReference,
      'RecordedById': recordedById,
      'CreatedAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockMovementRecordDocumentEquality
    implements Equality<StockMovementRecord> {
  const StockMovementRecordDocumentEquality();

  @override
  bool equals(StockMovementRecord? e1, StockMovementRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.outletId == e2?.outletId &&
        e1?.quantity == e2?.quantity &&
        e1?.movementType == e2?.movementType &&
        e1?.reason == e2?.reason &&
        e1?.movementReference == e2?.movementReference &&
        e1?.recordedById == e2?.recordedById &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(StockMovementRecord? e) => const ListEquality().hash([
        e?.productId,
        e?.outletId,
        e?.quantity,
        e?.movementType,
        e?.reason,
        e?.movementReference,
        e?.recordedById,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is StockMovementRecord;
}
