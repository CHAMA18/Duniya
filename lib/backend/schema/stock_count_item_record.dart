import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockCountItemRecord extends FirestoreRecord {
  StockCountItemRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "ProductId" field.
  DocumentReference? _productId;
  DocumentReference? get productId => _productId;
  bool hasProductId() => _productId != null;

  // "SystemQuantity" field.
  int? _systemQuantity;
  int get systemQuantity => _systemQuantity ?? 0;
  bool hasSystemQuantity() => _systemQuantity != null;

  // "CountedQuantity" field.
  int? _countedQuantity;
  int get countedQuantity => _countedQuantity ?? 0;
  bool hasCountedQuantity() => _countedQuantity != null;

  // "Variance" field.
  int? _variance;
  int get variance => _variance ?? 0;
  bool hasVariance() => _variance != null;

  // "Explanation" field.
  String? _explanation;
  String? get explanation => _explanation;
  bool hasExplanation() => _explanation != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _productId = snapshotData['ProductId'] as DocumentReference?;
    _systemQuantity = castToType<int>(snapshotData['SystemQuantity']);
    _countedQuantity = castToType<int>(snapshotData['CountedQuantity']);
    _variance = castToType<int>(snapshotData['Variance']);
    _explanation = snapshotData['Explanation'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('StockCountItem')
          : FirebaseFirestore.instance.collectionGroup('StockCountItem');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('StockCountItem').doc(id);

  static Stream<StockCountItemRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockCountItemRecord.fromSnapshot(s));

  static Future<StockCountItemRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => StockCountItemRecord.fromSnapshot(s));

  static StockCountItemRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StockCountItemRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockCountItemRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockCountItemRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockCountItemRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockCountItemRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockCountItemRecordData({
  DocumentReference? productId,
  int? systemQuantity,
  int? countedQuantity,
  int? variance,
  String? explanation,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'ProductId': productId,
      'SystemQuantity': systemQuantity,
      'CountedQuantity': countedQuantity,
      'Variance': variance,
      'Explanation': explanation,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockCountItemRecordDocumentEquality
    implements Equality<StockCountItemRecord> {
  const StockCountItemRecordDocumentEquality();

  @override
  bool equals(StockCountItemRecord? e1, StockCountItemRecord? e2) {
    return e1?.productId == e2?.productId &&
        e1?.systemQuantity == e2?.systemQuantity &&
        e1?.countedQuantity == e2?.countedQuantity &&
        e1?.variance == e2?.variance &&
        e1?.explanation == e2?.explanation;
  }

  @override
  int hash(StockCountItemRecord? e) => const ListEquality().hash([
        e?.productId,
        e?.systemQuantity,
        e?.countedQuantity,
        e?.variance,
        e?.explanation
      ]);

  @override
  bool isValidKey(Object? o) => o is StockCountItemRecord;
}
