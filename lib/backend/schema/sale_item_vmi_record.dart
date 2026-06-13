import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SaleItemVMIRecord extends FirestoreRecord {
  SaleItemVMIRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "Quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "SellingPrice" field.
  double? _sellingPrice;
  double get sellingPrice => _sellingPrice ?? 0.0;
  bool hasSellingPrice() => _sellingPrice != null;

  // "Total" field.
  double? _total;
  double get total => _total ?? 0.0;
  bool hasTotal() => _total != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _quantity = castToType<int>(snapshotData['Quantity']);
    _sellingPrice = castToType<double>(snapshotData['SellingPrice']);
    _total = castToType<double>(snapshotData['Total']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('SaleItemVMI')
          : FirebaseFirestore.instance.collectionGroup('SaleItemVMI');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('SaleItemVMI').doc(id);

  static Stream<SaleItemVMIRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SaleItemVMIRecord.fromSnapshot(s));

  static Future<SaleItemVMIRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SaleItemVMIRecord.fromSnapshot(s));

  static SaleItemVMIRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SaleItemVMIRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SaleItemVMIRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SaleItemVMIRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SaleItemVMIRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SaleItemVMIRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSaleItemVMIRecordData({
  DocumentReference? productId,
  int? quantity,
  double? sellingPrice,
  double? total,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'Quantity': quantity,
      'SellingPrice': sellingPrice,
      'Total': total,
    }.withoutNulls,
  );

  return firestoreData;
}

class SaleItemVMIRecordDocumentEquality
    implements Equality<SaleItemVMIRecord> {
  const SaleItemVMIRecordDocumentEquality();

  @override
  bool equals(SaleItemVMIRecord? e1, SaleItemVMIRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.quantity == e2?.quantity &&
        e1?.sellingPrice == e2?.sellingPrice &&
        e1?.total == e2?.total;
  }

  @override
  int hash(SaleItemVMIRecord? e) =>
      const ListEquality().hash([e?.productId, e?.quantity, e?.sellingPrice, e?.total]);

  @override
  bool isValidKey(Object? o) => o is SaleItemVMIRecord;
}
