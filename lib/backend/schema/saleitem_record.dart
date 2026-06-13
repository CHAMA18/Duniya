import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SaleitemRecord extends FirestoreRecord {
  SaleitemRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "Unit_price" field.
  double? _unitPrice;
  double get unitPrice => _unitPrice ?? 0.0;
  bool hasUnitPrice() => _unitPrice != null;

  // "Total_price" field.
  double? _totalPrice;
  double get totalPrice => _totalPrice ?? 0.0;
  bool hasTotalPrice() => _totalPrice != null;

  // "StockID" field.
  DocumentReference? _stockID;
  DocumentReference? get stockID => _stockID;
  bool hasStockID() => _stockID != null;

  // "SaleID" field.
  DocumentReference? _saleID;
  DocumentReference? get saleID => _saleID;
  bool hasSaleID() => _saleID != null;

  // "Discount" field.
  double? _discount;
  double get discount => _discount ?? 0.0;
  bool hasDiscount() => _discount != null;

  // "Final_price" field.
  double? _finalPrice;
  double get finalPrice => _finalPrice ?? 0.0;
  bool hasFinalPrice() => _finalPrice != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _quantity = castToType<int>(snapshotData['Quantity']);
    _unitPrice = castToType<double>(snapshotData['Unit_price']);
    _totalPrice = castToType<double>(snapshotData['Total_price']);
    _stockID = snapshotData['StockID'] as DocumentReference?;
    _saleID = snapshotData['SaleID'] as DocumentReference?;
    _discount = castToType<double>(snapshotData['Discount']);
    _finalPrice = castToType<double>(snapshotData['Final_price']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Saleitem')
          : FirebaseFirestore.instance.collectionGroup('Saleitem');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Saleitem').doc(id);

  static Stream<SaleitemRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SaleitemRecord.fromSnapshot(s));

  static Future<SaleitemRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SaleitemRecord.fromSnapshot(s));

  static SaleitemRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SaleitemRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SaleitemRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SaleitemRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SaleitemRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SaleitemRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSaleitemRecordData({
  int? quantity,
  double? unitPrice,
  double? totalPrice,
  DocumentReference? stockID,
  DocumentReference? saleID,
  double? discount,
  double? finalPrice,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Quantity': quantity,
      'Unit_price': unitPrice,
      'Total_price': totalPrice,
      'StockID': stockID,
      'SaleID': saleID,
      'Discount': discount,
      'Final_price': finalPrice,
    }.withoutNulls,
  );

  return firestoreData;
}

class SaleitemRecordDocumentEquality implements Equality<SaleitemRecord> {
  const SaleitemRecordDocumentEquality();

  @override
  bool equals(SaleitemRecord? e1, SaleitemRecord? e2) {
    return e1?.quantity == e2?.quantity &&
        e1?.unitPrice == e2?.unitPrice &&
        e1?.totalPrice == e2?.totalPrice &&
        e1?.stockID == e2?.stockID &&
        e1?.saleID == e2?.saleID &&
        e1?.discount == e2?.discount &&
        e1?.finalPrice == e2?.finalPrice;
  }

  @override
  int hash(SaleitemRecord? e) => const ListEquality().hash([
        e?.quantity,
        e?.unitPrice,
        e?.totalPrice,
        e?.stockID,
        e?.saleID,
        e?.discount,
        e?.finalPrice
      ]);

  @override
  bool isValidKey(Object? o) => o is SaleitemRecord;
}
