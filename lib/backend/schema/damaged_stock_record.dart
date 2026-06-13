import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DamagedStockRecord extends FirestoreRecord {
  DamagedStockRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "StockId" field.
  DocumentReference? _stockId;
  DocumentReference? get stockId => _stockId;
  bool hasStockId() => _stockId != null;

  // "Quantity" field.
  double? _quantity;
  double get quantity => _quantity ?? 0.0;
  bool hasQuantity() => _quantity != null;

  // "Description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _stockId = snapshotData['StockId'] as DocumentReference?;
    _quantity = castToType<double>(snapshotData['Quantity']);
    _description = snapshotData['Description'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('DamagedStock')
          : FirebaseFirestore.instance.collectionGroup('DamagedStock');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('DamagedStock').doc(id);

  static Stream<DamagedStockRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DamagedStockRecord.fromSnapshot(s));

  static Future<DamagedStockRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DamagedStockRecord.fromSnapshot(s));

  static DamagedStockRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DamagedStockRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DamagedStockRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DamagedStockRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DamagedStockRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DamagedStockRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDamagedStockRecordData({
  DocumentReference? stockId,
  double? quantity,
  String? description,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'StockId': stockId,
      'Quantity': quantity,
      'Description': description,
    }.withoutNulls,
  );

  return firestoreData;
}

class DamagedStockRecordDocumentEquality
    implements Equality<DamagedStockRecord> {
  const DamagedStockRecordDocumentEquality();

  @override
  bool equals(DamagedStockRecord? e1, DamagedStockRecord? e2) {
    return e1?.stockId == e2?.stockId &&
        e1?.quantity == e2?.quantity &&
        e1?.description == e2?.description;
  }

  @override
  int hash(DamagedStockRecord? e) =>
      const ListEquality().hash([e?.stockId, e?.quantity, e?.description]);

  @override
  bool isValidKey(Object? o) => o is DamagedStockRecord;
}
