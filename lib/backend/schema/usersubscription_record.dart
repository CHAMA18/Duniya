import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersubscriptionRecord extends FirestoreRecord {
  UsersubscriptionRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "StartDate" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "EndDate" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "Status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "Payment_method" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  bool hasPaymentMethod() => _paymentMethod != null;

  // "SubscriptionID" field.
  DocumentReference? _subscriptionID;
  DocumentReference? get subscriptionID => _subscriptionID;
  bool hasSubscriptionID() => _subscriptionID != null;

  // "UserID" field.
  DocumentReference? _userID;
  DocumentReference? get userID => _userID;
  bool hasUserID() => _userID != null;

  void _initializeFields() {
    _startDate = snapshotData['StartDate'] as DateTime?;
    _endDate = snapshotData['EndDate'] as DateTime?;
    _status = snapshotData['Status'] as String?;
    _paymentMethod = snapshotData['Payment_method'] as String?;
    _subscriptionID = snapshotData['SubscriptionID'] as DocumentReference?;
    _userID = snapshotData['UserID'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Usersubscription');

  static Stream<UsersubscriptionRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersubscriptionRecord.fromSnapshot(s));

  static Future<UsersubscriptionRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => UsersubscriptionRecord.fromSnapshot(s));

  static UsersubscriptionRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UsersubscriptionRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersubscriptionRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersubscriptionRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersubscriptionRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersubscriptionRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersubscriptionRecordData({
  DateTime? startDate,
  DateTime? endDate,
  String? status,
  String? paymentMethod,
  DocumentReference? subscriptionID,
  DocumentReference? userID,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'StartDate': startDate,
      'EndDate': endDate,
      'Status': status,
      'Payment_method': paymentMethod,
      'SubscriptionID': subscriptionID,
      'UserID': userID,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersubscriptionRecordDocumentEquality
    implements Equality<UsersubscriptionRecord> {
  const UsersubscriptionRecordDocumentEquality();

  @override
  bool equals(UsersubscriptionRecord? e1, UsersubscriptionRecord? e2) {
    return e1?.startDate == e2?.startDate &&
        e1?.endDate == e2?.endDate &&
        e1?.status == e2?.status &&
        e1?.paymentMethod == e2?.paymentMethod &&
        e1?.subscriptionID == e2?.subscriptionID &&
        e1?.userID == e2?.userID;
  }

  @override
  int hash(UsersubscriptionRecord? e) => const ListEquality().hash([
        e?.startDate,
        e?.endDate,
        e?.status,
        e?.paymentMethod,
        e?.subscriptionID,
        e?.userID
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersubscriptionRecord;
}
