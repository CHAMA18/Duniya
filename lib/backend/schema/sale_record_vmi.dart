import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SaleRecordVMI extends FirestoreRecord {
  SaleRecordVMI._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "OutletId" field.
  DocumentReference? _outletId;
  DocumentReference? get outletId => _outletId;
  bool hasOutletId() => _outletId != null;

  // "SoldById" field.
  DocumentReference? _soldById;
  DocumentReference? get soldById => _soldById;
  bool hasSoldById() => _soldById != null;

  // "SaleDate" field.
  DateTime? _saleDate;
  DateTime? get saleDate => _saleDate;
  bool hasSaleDate() => _saleDate != null;

  // "PatientRef" field.
  String? _patientRef;
  String? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "TotalAmount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _outletId = snapshotData['OutletId'] as DocumentReference?;
    _soldById = snapshotData['SoldById'] as DocumentReference?;
    _saleDate = snapshotData['SaleDate'] as DateTime?;
    _patientRef = snapshotData['PatientRef'] as String?;
    _totalAmount = castToType<double>(snapshotData['TotalAmount']);
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('SaleVMI')
          : FirebaseFirestore.instance.collectionGroup('SaleVMI');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('SaleVMI').doc(id);

  static Stream<SaleRecordVMI> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SaleRecordVMI.fromSnapshot(s));

  static Future<SaleRecordVMI> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SaleRecordVMI.fromSnapshot(s));

  static SaleRecordVMI fromSnapshot(DocumentSnapshot snapshot) =>
      SaleRecordVMI._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SaleRecordVMI getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SaleRecordVMI._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SaleRecordVMI(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SaleRecordVMI &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSaleRecordVMIData({
  DocumentReference? outletId,
  DocumentReference? soldById,
  DateTime? saleDate,
  String? patientRef,
  double? totalAmount,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'OutletId': outletId,
      'SoldById': soldById,
      'SaleDate': saleDate,
      'PatientRef': patientRef,
      'TotalAmount': totalAmount,
      'CreatedAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class SaleRecordVMIDocumentEquality implements Equality<SaleRecordVMI> {
  const SaleRecordVMIDocumentEquality();

  @override
  bool equals(SaleRecordVMI? e1, SaleRecordVMI? e2) {
    return e1?.outletId == e2?.outletId &&
        e1?.soldById == e2?.soldById &&
        e1?.saleDate == e2?.saleDate &&
        e1?.patientRef == e2?.patientRef &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(SaleRecordVMI? e) => const ListEquality().hash([
        e?.outletId,
        e?.soldById,
        e?.saleDate,
        e?.patientRef,
        e?.totalAmount,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is SaleRecordVMI;
}
