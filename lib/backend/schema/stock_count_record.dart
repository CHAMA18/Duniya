import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockCountRecord extends FirestoreRecord {
  StockCountRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "OutletId" field.
  DocumentReference? _outletId;
  DocumentReference? get outletId => _outletId;
  bool hasOutletId() => _outletId != null;

  // "CountedById" field.
  DocumentReference? _countedById;
  DocumentReference? get countedById => _countedById;
  bool hasCountedById() => _countedById != null;

  // "CountDate" field.
  DateTime? _countDate;
  DateTime? get countDate => _countDate;
  bool hasCountDate() => _countDate != null;

  // "Status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "Notes" field.
  String? _notes;
  String? get notes => _notes;
  bool hasNotes() => _notes != null;

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
    _outletId = snapshotData['OutletId'] as DocumentReference?;
    _countedById = snapshotData['CountedById'] as DocumentReference?;
    _countDate = snapshotData['CountDate'] as DateTime?;
    _status = snapshotData['Status'] as String?;
    _notes = snapshotData['Notes'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('StockCount')
          : FirebaseFirestore.instance.collectionGroup('StockCount');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('StockCount').doc(id);

  static Stream<StockCountRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockCountRecord.fromSnapshot(s));

  static Future<StockCountRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StockCountRecord.fromSnapshot(s));

  static StockCountRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StockCountRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockCountRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockCountRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockCountRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockCountRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockCountRecordData({
  DocumentReference? outletId,
  DocumentReference? countedById,
  DateTime? countDate,
  String? status,
  String? notes,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'OutletId': outletId,
      'CountedById': countedById,
      'CountDate': countDate,
      'Status': status,
      'Notes': notes,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockCountRecordDocumentEquality implements Equality<StockCountRecord> {
  const StockCountRecordDocumentEquality();

  @override
  bool equals(StockCountRecord? e1, StockCountRecord? e2) {
    return e1?.outletId == e2?.outletId &&
        e1?.countedById == e2?.countedById &&
        e1?.countDate == e2?.countDate &&
        e1?.status == e2?.status &&
        e1?.notes == e2?.notes &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(StockCountRecord? e) => const ListEquality().hash([
        e?.outletId,
        e?.countedById,
        e?.countDate,
        e?.status,
        e?.notes,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is StockCountRecord;
}
