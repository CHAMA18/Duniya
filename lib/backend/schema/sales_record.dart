import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SalesRecord extends FirestoreRecord {
  SalesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "Total_amount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  // "NumberOfItems" field.
  int? _numberOfItems;
  int get numberOfItems => _numberOfItems ?? 0;
  bool hasNumberOfItems() => _numberOfItems != null;

  // "UserID" field.
  DocumentReference? _userID;
  DocumentReference? get userID => _userID;
  bool hasUserID() => _userID != null;

  // "PharmaID" field.
  DocumentReference? _pharmaID;
  DocumentReference? get pharmaID => _pharmaID;
  bool hasPharmaID() => _pharmaID != null;

  // "OwnerRef" field.
  DocumentReference? _ownerRef;
  DocumentReference? get ownerRef => _ownerRef;
  bool hasOwnerRef() => _ownerRef != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _date = snapshotData['Date'] as DateTime?;
    _totalAmount = castToType<double>(snapshotData['Total_amount']);
    _numberOfItems = castToType<int>(snapshotData['NumberOfItems']);
    _userID = snapshotData['UserID'] as DocumentReference?;
    _pharmaID = snapshotData['PharmaID'] as DocumentReference?;
    _ownerRef = snapshotData['OwnerRef'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Sales')
          : FirebaseFirestore.instance.collectionGroup('Sales');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Sales').doc(id);

  static Stream<SalesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SalesRecord.fromSnapshot(s));

  static Future<SalesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SalesRecord.fromSnapshot(s));

  static SalesRecord fromSnapshot(DocumentSnapshot snapshot) => SalesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SalesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SalesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SalesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SalesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSalesRecordData({
  DateTime? date,
  double? totalAmount,
  int? numberOfItems,
  DocumentReference? userID,
  DocumentReference? pharmaID,
  DocumentReference? ownerRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Date': date,
      'Total_amount': totalAmount,
      'NumberOfItems': numberOfItems,
      'UserID': userID,
      'PharmaID': pharmaID,
      'OwnerRef': ownerRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class SalesRecordDocumentEquality implements Equality<SalesRecord> {
  const SalesRecordDocumentEquality();

  @override
  bool equals(SalesRecord? e1, SalesRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.numberOfItems == e2?.numberOfItems &&
        e1?.userID == e2?.userID &&
        e1?.pharmaID == e2?.pharmaID &&
        e1?.ownerRef == e2?.ownerRef;
  }

  @override
  int hash(SalesRecord? e) => const ListEquality().hash([
        e?.date,
        e?.totalAmount,
        e?.numberOfItems,
        e?.userID,
        e?.pharmaID,
        e?.ownerRef
      ]);

  @override
  bool isValidKey(Object? o) => o is SalesRecord;
}
