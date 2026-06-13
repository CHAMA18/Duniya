import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BatchRecord extends FirestoreRecord {
  BatchRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "PharmacyId" field.
  DocumentReference? _pharmacyId;
  DocumentReference? get pharmacyId => _pharmacyId;
  bool hasPharmacyId() => _pharmacyId != null;

  // "BatchNumber" field.
  String? _batchNumber;
  String get batchNumber => _batchNumber ?? '';
  bool hasBatchNumber() => _batchNumber != null;

  // "ExpiryDate" field.
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  bool hasExpiryDate() => _expiryDate != null;

  // "Quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "FacilityLocation" field.
  String? _facilityLocation;
  String? get facilityLocation => _facilityLocation;
  bool hasFacilityLocation() => _facilityLocation != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _pharmacyId = snapshotData['PharmacyId'] as DocumentReference?;
    _batchNumber = snapshotData['BatchNumber'] as String?;
    _expiryDate = snapshotData['ExpiryDate'] as DateTime?;
    _quantity = castToType<int>(snapshotData['Quantity']);
    _facilityLocation = snapshotData['FacilityLocation'] as String?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Batch');

  static Stream<BatchRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BatchRecord.fromSnapshot(s));

  static Future<BatchRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BatchRecord.fromSnapshot(s));

  static BatchRecord fromSnapshot(DocumentSnapshot snapshot) => BatchRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BatchRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BatchRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BatchRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BatchRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBatchRecordData({
  DocumentReference? productId,
  DocumentReference? pharmacyId,
  String? batchNumber,
  DateTime? expiryDate,
  int? quantity,
  String? facilityLocation,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'PharmacyId': pharmacyId,
      'BatchNumber': batchNumber,
      'ExpiryDate': expiryDate,
      'Quantity': quantity,
      'FacilityLocation': facilityLocation,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class BatchRecordDocumentEquality implements Equality<BatchRecord> {
  const BatchRecordDocumentEquality();

  @override
  bool equals(BatchRecord? e1, BatchRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.pharmacyId == e2?.pharmacyId &&
        e1?.batchNumber == e2?.batchNumber &&
        e1?.expiryDate == e2?.expiryDate &&
        e1?.quantity == e2?.quantity &&
        e1?.facilityLocation == e2?.facilityLocation &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(BatchRecord? e) => const ListEquality().hash([
        e?.productId,
        e?.pharmacyId,
        e?.batchNumber,
        e?.expiryDate,
        e?.quantity,
        e?.facilityLocation,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is BatchRecord;
}
