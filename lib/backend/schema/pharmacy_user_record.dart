import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PharmacyUserRecord extends FirestoreRecord {
  PharmacyUserRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "UserId" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "PharmacyId" field.
  DocumentReference? _pharmacyId;
  DocumentReference? get pharmacyId => _pharmacyId;
  bool hasPharmacyId() => _pharmacyId != null;

  // "OutletIds" field.
  List<String>? _outletIds;
  List<String> get outletIds => _outletIds ?? const [];
  bool hasOutletIds() => _outletIds != null;

  // "Role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['UserId'] as DocumentReference?;
    _pharmacyId = snapshotData['PharmacyId'] as DocumentReference?;
    _outletIds = getDataList(snapshotData['OutletIds']);
    _role = snapshotData['Role'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('PharmacyUser')
          : FirebaseFirestore.instance.collectionGroup('PharmacyUser');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('PharmacyUser').doc(id);

  static Stream<PharmacyUserRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PharmacyUserRecord.fromSnapshot(s));

  static Future<PharmacyUserRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PharmacyUserRecord.fromSnapshot(s));

  static PharmacyUserRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PharmacyUserRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PharmacyUserRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PharmacyUserRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PharmacyUserRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PharmacyUserRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPharmacyUserRecordData({
  DocumentReference? userId,
  DocumentReference? pharmacyId,
  List<String>? outletIds,
  String? role,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'UserId': userId,
      'PharmacyId': pharmacyId,
      'OutletIds': outletIds,
      'Role': role,
      'CreatedAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PharmacyUserRecordDocumentEquality
    implements Equality<PharmacyUserRecord> {
  const PharmacyUserRecordDocumentEquality();

  @override
  bool equals(PharmacyUserRecord? e1, PharmacyUserRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userId == e2?.userId &&
        e1?.pharmacyId == e2?.pharmacyId &&
        listEquality.equals(e1?.outletIds, e2?.outletIds) &&
        e1?.role == e2?.role &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(PharmacyUserRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.pharmacyId,
        e?.outletIds,
        e?.role,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PharmacyUserRecord;
}
