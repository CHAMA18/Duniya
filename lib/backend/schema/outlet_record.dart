import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OutletRecord extends FirestoreRecord {
  OutletRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "Code" field.
  String? _code;
  String get code => _code ?? '';
  bool hasCode() => _code != null;

  // "Address" field.
  String? _address;
  String? get address => _address;
  bool hasAddress() => _address != null;

  // "IsActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? true;
  bool hasIsActive() => _isActive != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _code = snapshotData['Code'] as String?;
    _address = snapshotData['Address'] as String?;
    _isActive = snapshotData['IsActive'] as bool?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Outlet')
          : FirebaseFirestore.instance.collectionGroup('Outlet');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Outlet').doc(id);

  static Stream<OutletRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OutletRecord.fromSnapshot(s));

  static Future<OutletRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OutletRecord.fromSnapshot(s));

  static OutletRecord fromSnapshot(DocumentSnapshot snapshot) => OutletRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OutletRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OutletRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OutletRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OutletRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOutletRecordData({
  String? name,
  String? code,
  String? address,
  bool? isActive,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'Code': code,
      'Address': address,
      'IsActive': isActive,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class OutletRecordDocumentEquality implements Equality<OutletRecord> {
  const OutletRecordDocumentEquality();

  @override
  bool equals(OutletRecord? e1, OutletRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.code == e2?.code &&
        e1?.address == e2?.address &&
        e1?.isActive == e2?.isActive &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(OutletRecord? e) => const ListEquality().hash([
        e?.name,
        e?.code,
        e?.address,
        e?.isActive,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is OutletRecord;
}
