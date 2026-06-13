import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SubscriptionpaymentRecord extends FirestoreRecord {
  SubscriptionpaymentRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "Amount" field.
  double? _amount;
  double get amount => _amount ?? 0.0;
  bool hasAmount() => _amount != null;

  // "Status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "SubcriptionID" field.
  DocumentReference? _subcriptionID;
  DocumentReference? get subcriptionID => _subcriptionID;
  bool hasSubcriptionID() => _subcriptionID != null;

  // "UserId" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  void _initializeFields() {
    _date = snapshotData['Date'] as DateTime?;
    _amount = castToType<double>(snapshotData['Amount']);
    _status = snapshotData['Status'] as String?;
    _subcriptionID = snapshotData['SubcriptionID'] as DocumentReference?;
    _userId = snapshotData['UserId'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Subscriptionpayment');

  static Stream<SubscriptionpaymentRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SubscriptionpaymentRecord.fromSnapshot(s));

  static Future<SubscriptionpaymentRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => SubscriptionpaymentRecord.fromSnapshot(s));

  static SubscriptionpaymentRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SubscriptionpaymentRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SubscriptionpaymentRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SubscriptionpaymentRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SubscriptionpaymentRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SubscriptionpaymentRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSubscriptionpaymentRecordData({
  DateTime? date,
  double? amount,
  String? status,
  DocumentReference? subcriptionID,
  DocumentReference? userId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Date': date,
      'Amount': amount,
      'Status': status,
      'SubcriptionID': subcriptionID,
      'UserId': userId,
    }.withoutNulls,
  );

  return firestoreData;
}

class SubscriptionpaymentRecordDocumentEquality
    implements Equality<SubscriptionpaymentRecord> {
  const SubscriptionpaymentRecordDocumentEquality();

  @override
  bool equals(SubscriptionpaymentRecord? e1, SubscriptionpaymentRecord? e2) {
    return e1?.date == e2?.date &&
        e1?.amount == e2?.amount &&
        e1?.status == e2?.status &&
        e1?.subcriptionID == e2?.subcriptionID &&
        e1?.userId == e2?.userId;
  }

  @override
  int hash(SubscriptionpaymentRecord? e) => const ListEquality()
      .hash([e?.date, e?.amount, e?.status, e?.subcriptionID, e?.userId]);

  @override
  bool isValidKey(Object? o) => o is SubscriptionpaymentRecord;
}
