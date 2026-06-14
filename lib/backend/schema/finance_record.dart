import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FinanceRecord extends FirestoreRecord {
  FinanceRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Revenue" field.
  double? _revenue;
  double get revenue => _revenue ?? 0.0;
  bool hasRevenue() => _revenue != null;

  // "GrossProfit" field.
  double? _grossProfit;
  double get grossProfit => _grossProfit ?? 0.0;
  bool hasGrossProfit() => _grossProfit != null;

  // "NetProfit" field.
  double? _netProfit;
  double get netProfit => _netProfit ?? 0.0;
  bool hasNetProfit() => _netProfit != null;

  // "UserId" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "CostOfGoods" field.
  double? _costOfGoods;
  double get costOfGoods => _costOfGoods ?? 0.0;
  bool hasCostOfGoods() => _costOfGoods != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _revenue = castToType<double>(snapshotData['Revenue']);
    _grossProfit = castToType<double>(snapshotData['GrossProfit']);
    _netProfit = castToType<double>(snapshotData['NetProfit']);
    _userId = snapshotData['UserId'] as DocumentReference?;
    _costOfGoods = castToType<double>(snapshotData['CostOfGoods']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Finance')
          : FirebaseFirestore.instance.collectionGroup('Finance');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Finance').doc(id);

  static Stream<FinanceRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FinanceRecord.fromSnapshot(s));

  static Future<FinanceRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FinanceRecord.fromSnapshot(s));

  static FinanceRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FinanceRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FinanceRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FinanceRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FinanceRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FinanceRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFinanceRecordData({
  double? revenue,
  double? grossProfit,
  double? netProfit,
  DocumentReference? userId,
  double? costOfGoods,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Revenue': revenue,
      'GrossProfit': grossProfit,
      'NetProfit': netProfit,
      'UserId': userId,
      'CostOfGoods': costOfGoods,
    }.withoutNulls,
  );

  return firestoreData;
}

class FinanceRecordDocumentEquality implements Equality<FinanceRecord> {
  const FinanceRecordDocumentEquality();

  @override
  bool equals(FinanceRecord? e1, FinanceRecord? e2) {
    return e1?.revenue == e2?.revenue &&
        e1?.grossProfit == e2?.grossProfit &&
        e1?.netProfit == e2?.netProfit &&
        e1?.userId == e2?.userId &&
        e1?.costOfGoods == e2?.costOfGoods;
  }

  @override
  int hash(FinanceRecord? e) => const ListEquality().hash(
      [e?.revenue, e?.grossProfit, e?.netProfit, e?.userId, e?.costOfGoods]);

  @override
  bool isValidKey(Object? o) => o is FinanceRecord;
}
