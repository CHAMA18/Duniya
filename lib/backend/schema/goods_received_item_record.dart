import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GoodsReceivedItemRecord extends FirestoreRecord {
  GoodsReceivedItemRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "QuantityDelivered" field.
  int? _quantityDelivered;
  int get quantityDelivered => _quantityDelivered ?? 0;
  bool hasQuantityDelivered() => _quantityDelivered != null;

  // "QuantityReceived" field.
  int? _quantityReceived;
  int? get quantityReceived => _quantityReceived;
  bool hasQuantityReceived() => _quantityReceived != null;

  // "BatchNumber" field.
  String? _batchNumber;
  String? get batchNumber => _batchNumber;
  bool hasBatchNumber() => _batchNumber != null;

  // "ExpiryDate" field.
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  bool hasExpiryDate() => _expiryDate != null;

  // "Discrepancy" field.
  String? _discrepancy;
  String? get discrepancy => _discrepancy;
  bool hasDiscrepancy() => _discrepancy != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _quantityDelivered = castToType<int>(snapshotData['QuantityDelivered']);
    _quantityReceived = castToType<int>(snapshotData['QuantityReceived']);
    _batchNumber = snapshotData['BatchNumber'] as String?;
    _expiryDate = snapshotData['ExpiryDate'] as DateTime?;
    _discrepancy = snapshotData['Discrepancy'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('GoodsReceivedItem')
          : FirebaseFirestore.instance.collectionGroup('GoodsReceivedItem');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('GoodsReceivedItem').doc(id);

  static Stream<GoodsReceivedItemRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GoodsReceivedItemRecord.fromSnapshot(s));

  static Future<GoodsReceivedItemRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => GoodsReceivedItemRecord.fromSnapshot(s));

  static GoodsReceivedItemRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GoodsReceivedItemRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GoodsReceivedItemRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GoodsReceivedItemRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GoodsReceivedItemRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GoodsReceivedItemRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGoodsReceivedItemRecordData({
  DocumentReference? productId,
  int? quantityDelivered,
  int? quantityReceived,
  String? batchNumber,
  DateTime? expiryDate,
  String? discrepancy,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'QuantityDelivered': quantityDelivered,
      'QuantityReceived': quantityReceived,
      'BatchNumber': batchNumber,
      'ExpiryDate': expiryDate,
      'Discrepancy': discrepancy,
    }.withoutNulls,
  );

  return firestoreData;
}

class GoodsReceivedItemRecordDocumentEquality
    implements Equality<GoodsReceivedItemRecord> {
  const GoodsReceivedItemRecordDocumentEquality();

  @override
  bool equals(GoodsReceivedItemRecord? e1, GoodsReceivedItemRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.quantityDelivered == e2?.quantityDelivered &&
        e1?.quantityReceived == e2?.quantityReceived &&
        e1?.batchNumber == e2?.batchNumber &&
        e1?.expiryDate == e2?.expiryDate &&
        e1?.discrepancy == e2?.discrepancy;
  }

  @override
  int hash(GoodsReceivedItemRecord? e) => const ListEquality().hash([
        e?.productId,
        e?.quantityDelivered,
        e?.quantityReceived,
        e?.batchNumber,
        e?.expiryDate,
        e?.discrepancy
      ]);

  @override
  bool isValidKey(Object? o) => o is GoodsReceivedItemRecord;
}
