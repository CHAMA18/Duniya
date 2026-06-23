import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PharmacyRecord extends FirestoreRecord {
  PharmacyRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "Address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "UserID" field.
  DocumentReference? _userID;
  DocumentReference? get userID => _userID;
  bool hasUserID() => _userID != null;

  // "deleted" field.
  bool? _deleted;
  bool get deleted => _deleted ?? false;
  bool hasDeleted() => _deleted != null;

  // "NetworkStatus" field — tracks Duniya network approval.
  // Values: 'pending_approval' (self-registered, awaiting Duniya admin),
  //         'active' (approved or invited), 'rejected' (denied by Duniya).
  String? _networkStatus;
  String get networkStatus => _networkStatus ?? 'active';
  bool hasNetworkStatus() => _networkStatus != null;

  // "RegisteredAt" field — when the pharmacy joined the network.
  DateTime? _registeredAt;
  DateTime? get registeredAt => _registeredAt;
  bool hasRegisteredAt() => _registeredAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _address = snapshotData['Address'] as String?;
    _userID = snapshotData['UserID'] as DocumentReference?;
    _deleted = snapshotData['deleted'] as bool?;
    _networkStatus = snapshotData['NetworkStatus'] as String?;
    _registeredAt = snapshotData['RegisteredAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Pharmacy')
          : FirebaseFirestore.instance.collectionGroup('Pharmacy');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Pharmacy').doc(id);

  static Stream<PharmacyRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PharmacyRecord.fromSnapshot(s));

  static Future<PharmacyRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PharmacyRecord.fromSnapshot(s));

  static PharmacyRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PharmacyRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PharmacyRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PharmacyRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PharmacyRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PharmacyRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPharmacyRecordData({
  String? name,
  String? address,
  DocumentReference? userID,
  bool? deleted,
  String? networkStatus,
  DateTime? registeredAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'Address': address,
      'UserID': userID,
      'deleted': deleted,
      'NetworkStatus': networkStatus,
      'RegisteredAt': registeredAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PharmacyRecordDocumentEquality implements Equality<PharmacyRecord> {
  const PharmacyRecordDocumentEquality();

  @override
  bool equals(PharmacyRecord? e1, PharmacyRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.address == e2?.address &&
        e1?.userID == e2?.userID &&
        e1?.deleted == e2?.deleted &&
        e1?.networkStatus == e2?.networkStatus &&
        e1?.registeredAt == e2?.registeredAt;
  }

  @override
  int hash(PharmacyRecord? e) => const ListEquality().hash(
      [e?.name, e?.address, e?.userID, e?.deleted, e?.networkStatus, e?.registeredAt]);

  @override
  bool isValidKey(Object? o) => o is PharmacyRecord;
}
