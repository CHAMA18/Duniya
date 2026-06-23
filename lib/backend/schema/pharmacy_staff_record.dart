import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PharmacyStaffRecord extends FirestoreRecord {
  PharmacyStaffRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "PharmacyId" field.
  DocumentReference? _pharmacyId;
  DocumentReference? get pharmacyId => _pharmacyId;
  bool hasPharmacyId() => _pharmacyId != null;

  // "StaffId" field.
  DocumentReference? _staffId;
  DocumentReference? get staffId => _staffId;
  bool hasStaffId() => _staffId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _pharmacyId = snapshotData['PharmacyId'] as DocumentReference?;
    _staffId = snapshotData['StaffId'] as DocumentReference?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('PharmacyStaff')
          : FirebaseFirestore.instance.collectionGroup('PharmacyStaff');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('PharmacyStaff').doc(id);

  static Stream<PharmacyStaffRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PharmacyStaffRecord.fromSnapshot(s));

  static Future<PharmacyStaffRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PharmacyStaffRecord.fromSnapshot(s));

  static PharmacyStaffRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PharmacyStaffRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PharmacyStaffRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PharmacyStaffRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PharmacyStaffRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PharmacyStaffRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPharmacyStaffRecordData({
  DocumentReference? pharmacyId,
  DocumentReference? staffId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'PharmacyId': pharmacyId,
      'StaffId': staffId,
    }.withoutNulls,
  );

  return firestoreData;
}

class PharmacyStaffRecordDocumentEquality
    implements Equality<PharmacyStaffRecord> {
  const PharmacyStaffRecordDocumentEquality();

  @override
  bool equals(PharmacyStaffRecord? e1, PharmacyStaffRecord? e2) {
    return e1?.pharmacyId == e2?.pharmacyId && e1?.staffId == e2?.staffId;
  }

  @override
  int hash(PharmacyStaffRecord? e) =>
      const ListEquality().hash([e?.pharmacyId, e?.staffId]);

  @override
  bool isValidKey(Object? o) => o is PharmacyStaffRecord;
}
