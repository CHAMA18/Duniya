import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StaffRecord extends FirestoreRecord {
  StaffRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "OwnerRef" field.
  DocumentReference? _ownerRef;
  DocumentReference? get ownerRef => _ownerRef;
  bool hasOwnerRef() => _ownerRef != null;

  // "Name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "Role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "Email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "Phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "UserRef" field.
  DocumentReference? _userRef;
  DocumentReference? get userRef => _userRef;
  bool hasUserRef() => _userRef != null;

  // "PharmId" field.
  DocumentReference? _pharmId;
  DocumentReference? get pharmId => _pharmId;
  bool hasPharmId() => _pharmId != null;

  // "Password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "deleted" field.
  bool? _deleted;
  bool get deleted => _deleted ?? false;
  bool hasDeleted() => _deleted != null;

  void _initializeFields() {
    _ownerRef = snapshotData['OwnerRef'] as DocumentReference?;
    _name = snapshotData['Name'] as String?;
    _role = snapshotData['Role'] as String?;
    _email = snapshotData['Email'] as String?;
    _phone = snapshotData['Phone'] as String?;
    _userRef = snapshotData['UserRef'] as DocumentReference?;
    _pharmId = snapshotData['PharmId'] as DocumentReference?;
    _password = snapshotData['Password'] as String?;
    _deleted = snapshotData['deleted'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Staff');

  static Stream<StaffRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StaffRecord.fromSnapshot(s));

  static Future<StaffRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StaffRecord.fromSnapshot(s));

  static StaffRecord fromSnapshot(DocumentSnapshot snapshot) => StaffRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StaffRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StaffRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StaffRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StaffRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStaffRecordData({
  DocumentReference? ownerRef,
  String? name,
  String? role,
  String? email,
  String? phone,
  DocumentReference? userRef,
  DocumentReference? pharmId,
  String? password,
  bool? deleted,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'OwnerRef': ownerRef,
      'Name': name,
      'Role': role,
      'Email': email,
      'Phone': phone,
      'UserRef': userRef,
      'PharmId': pharmId,
      'Password': password,
      'deleted': deleted,
    }.withoutNulls,
  );

  return firestoreData;
}

class StaffRecordDocumentEquality implements Equality<StaffRecord> {
  const StaffRecordDocumentEquality();

  @override
  bool equals(StaffRecord? e1, StaffRecord? e2) {
    return e1?.ownerRef == e2?.ownerRef &&
        e1?.name == e2?.name &&
        e1?.role == e2?.role &&
        e1?.email == e2?.email &&
        e1?.phone == e2?.phone &&
        e1?.userRef == e2?.userRef &&
        e1?.pharmId == e2?.pharmId &&
        e1?.password == e2?.password &&
        e1?.deleted == e2?.deleted;
  }

  @override
  int hash(StaffRecord? e) => const ListEquality().hash([
        e?.ownerRef,
        e?.name,
        e?.role,
        e?.email,
        e?.phone,
        e?.userRef,
        e?.pharmId,
        e?.password,
        e?.deleted
      ]);

  @override
  bool isValidKey(Object? o) => o is StaffRecord;
}
