import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GoodsReceivedRecord extends FirestoreRecord {
  GoodsReceivedRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "DeliveryNoteNumber" field.
  String? _deliveryNoteNumber;
  String get deliveryNoteNumber => _deliveryNoteNumber ?? '';
  bool hasDeliveryNoteNumber() => _deliveryNoteNumber != null;

  // "OutletId" field.
  DocumentReference? _outletId;
  DocumentReference? get outletId => _outletId;
  bool hasOutletId() => _outletId != null;

  // "ReceivedById" field.
  DocumentReference? _receivedById;
  DocumentReference? get receivedById => _receivedById;
  bool hasReceivedById() => _receivedById != null;

  // "DeliveryDate" field.
  DateTime? _deliveryDate;
  DateTime? get deliveryDate => _deliveryDate;
  bool hasDeliveryDate() => _deliveryDate != null;

  // "ReceivedDate" field.
  DateTime? _receivedDate;
  DateTime? get receivedDate => _receivedDate;
  bool hasReceivedDate() => _receivedDate != null;

  // "Discrepancies" field.
  String? _discrepancies;
  String? get discrepancies => _discrepancies;
  bool hasDiscrepancies() => _discrepancies != null;

  // "Status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

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
    _deliveryNoteNumber = snapshotData['DeliveryNoteNumber'] as String?;
    _outletId = snapshotData['OutletId'] as DocumentReference?;
    _receivedById = snapshotData['ReceivedById'] as DocumentReference?;
    _deliveryDate = snapshotData['DeliveryDate'] as DateTime?;
    _receivedDate = snapshotData['ReceivedDate'] as DateTime?;
    _discrepancies = snapshotData['Discrepancies'] as String?;
    _status = snapshotData['Status'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('GoodsReceived')
          : FirebaseFirestore.instance.collectionGroup('GoodsReceived');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('GoodsReceived').doc(id);

  static Stream<GoodsReceivedRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GoodsReceivedRecord.fromSnapshot(s));

  static Future<GoodsReceivedRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GoodsReceivedRecord.fromSnapshot(s));

  static GoodsReceivedRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GoodsReceivedRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GoodsReceivedRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GoodsReceivedRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GoodsReceivedRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GoodsReceivedRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGoodsReceivedRecordData({
  String? deliveryNoteNumber,
  DocumentReference? outletId,
  DocumentReference? receivedById,
  DateTime? deliveryDate,
  DateTime? receivedDate,
  String? discrepancies,
  String? status,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'DeliveryNoteNumber': deliveryNoteNumber,
      'OutletId': outletId,
      'ReceivedById': receivedById,
      'DeliveryDate': deliveryDate,
      'ReceivedDate': receivedDate,
      'Discrepancies': discrepancies,
      'Status': status,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class GoodsReceivedRecordDocumentEquality
    implements Equality<GoodsReceivedRecord> {
  const GoodsReceivedRecordDocumentEquality();

  @override
  bool equals(GoodsReceivedRecord? e1, GoodsReceivedRecord? e2) {
    return e1?.deliveryNoteNumber == e2?.deliveryNoteNumber &&
        e1?.outletId == e2?.outletId &&
        e1?.receivedById == e2?.receivedById &&
        e1?.deliveryDate == e2?.deliveryDate &&
        e1?.receivedDate == e2?.receivedDate &&
        e1?.discrepancies == e2?.discrepancies &&
        e1?.status == e2?.status &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(GoodsReceivedRecord? e) => const ListEquality().hash([
        e?.deliveryNoteNumber,
        e?.outletId,
        e?.receivedById,
        e?.deliveryDate,
        e?.receivedDate,
        e?.discrepancies,
        e?.status,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is GoodsReceivedRecord;
}
