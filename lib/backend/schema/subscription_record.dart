import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SubscriptionRecord extends FirestoreRecord {
  SubscriptionRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "Description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "Price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "Duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  // "Features" field.
  List<String>? _features;
  List<String> get features => _features ?? const [];
  bool hasFeatures() => _features != null;

  // "payment_url" field.
  String? _paymentUrl;
  String get paymentUrl => _paymentUrl ?? '';
  bool hasPaymentUrl() => _paymentUrl != null;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _description = snapshotData['Description'] as String?;
    _price = castToType<double>(snapshotData['Price']);
    _duration = castToType<int>(snapshotData['Duration']);
    _features = getDataList(snapshotData['Features']);
    _paymentUrl = snapshotData['payment_url'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Subscription');

  static Stream<SubscriptionRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SubscriptionRecord.fromSnapshot(s));

  static Future<SubscriptionRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SubscriptionRecord.fromSnapshot(s));

  static SubscriptionRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SubscriptionRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SubscriptionRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SubscriptionRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SubscriptionRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SubscriptionRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSubscriptionRecordData({
  String? name,
  String? description,
  double? price,
  int? duration,
  String? paymentUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'Description': description,
      'Price': price,
      'Duration': duration,
      'payment_url': paymentUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class SubscriptionRecordDocumentEquality
    implements Equality<SubscriptionRecord> {
  const SubscriptionRecordDocumentEquality();

  @override
  bool equals(SubscriptionRecord? e1, SubscriptionRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.price == e2?.price &&
        e1?.duration == e2?.duration &&
        listEquality.equals(e1?.features, e2?.features) &&
        e1?.paymentUrl == e2?.paymentUrl;
  }

  @override
  int hash(SubscriptionRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.price,
        e?.duration,
        e?.features,
        e?.paymentUrl
      ]);

  @override
  bool isValidKey(Object? o) => o is SubscriptionRecord;
}
