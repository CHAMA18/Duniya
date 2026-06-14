import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StockRecord extends FirestoreRecord {
  StockRecord._(
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

  // "Quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "ExpiryDate" field.
  DateTime? _expiryDate;
  DateTime? get expiryDate => _expiryDate;
  bool hasExpiryDate() => _expiryDate != null;

  // "Category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "Manufacturer" field.
  String? _manufacturer;
  String get manufacturer => _manufacturer ?? '';
  bool hasManufacturer() => _manufacturer != null;

  // "Price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "CostOfGoods" field.
  double? _costOfGoods;
  double get costOfGoods => _costOfGoods ?? 0.0;
  bool hasCostOfGoods() => _costOfGoods != null;

  // "Pharmacy" field.
  String? _pharmacy;
  String get pharmacy => _pharmacy ?? '';
  bool hasPharmacy() => _pharmacy != null;

  // "UserId" field.
  DocumentReference? _userId;
  DocumentReference? get userId => _userId;
  bool hasUserId() => _userId != null;

  // "BatchNumber" field.
  String? _batchNumber;
  String get batchNumber => _batchNumber ?? '';
  bool hasBatchNumber() => _batchNumber != null;

  // "DamagedGoods" field.
  double? _damagedGoods;
  double get damagedGoods => _damagedGoods ?? 0.0;
  bool hasDamagedGoods() => _damagedGoods != null;

  // "InitialQuantity" field.
  double? _initialQuantity;
  double get initialQuantity => _initialQuantity ?? 0.0;
  bool hasInitialQuantity() => _initialQuantity != null;

  // "LimitNotice" field.
  int? _limitNotice;
  int get limitNotice => _limitNotice ?? 0;
  bool hasLimitNotice() => _limitNotice != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _description = snapshotData['Description'] as String?;
    _quantity = castToType<int>(snapshotData['Quantity']);
    _expiryDate = snapshotData['ExpiryDate'] as DateTime?;
    _category = snapshotData['Category'] as String?;
    _manufacturer = snapshotData['Manufacturer'] as String?;
    _price = castToType<double>(snapshotData['Price']);
    _costOfGoods = castToType<double>(snapshotData['CostOfGoods']);
    _pharmacy = snapshotData['Pharmacy'] as String?;
    _userId = snapshotData['UserId'] as DocumentReference?;
    _batchNumber = snapshotData['BatchNumber'] as String?;
    _damagedGoods = castToType<double>(snapshotData['DamagedGoods']);
    _initialQuantity = castToType<double>(snapshotData['InitialQuantity']);
    _limitNotice = castToType<int>(snapshotData['LimitNotice']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('Stock')
          : FirebaseFirestore.instance.collectionGroup('Stock');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('Stock').doc(id);

  static Stream<StockRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StockRecord.fromSnapshot(s));

  static Future<StockRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StockRecord.fromSnapshot(s));

  static StockRecord fromSnapshot(DocumentSnapshot snapshot) => StockRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StockRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StockRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StockRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StockRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStockRecordData({
  String? name,
  String? description,
  int? quantity,
  DateTime? expiryDate,
  String? category,
  String? manufacturer,
  double? price,
  double? costOfGoods,
  String? pharmacy,
  DocumentReference? userId,
  String? batchNumber,
  double? damagedGoods,
  double? initialQuantity,
  int? limitNotice,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'Description': description,
      'Quantity': quantity,
      'ExpiryDate': expiryDate,
      'Category': category,
      'Manufacturer': manufacturer,
      'Price': price,
      'CostOfGoods': costOfGoods,
      'Pharmacy': pharmacy,
      'UserId': userId,
      'BatchNumber': batchNumber,
      'DamagedGoods': damagedGoods,
      'InitialQuantity': initialQuantity,
      'LimitNotice': limitNotice,
    }.withoutNulls,
  );

  return firestoreData;
}

class StockRecordDocumentEquality implements Equality<StockRecord> {
  const StockRecordDocumentEquality();

  @override
  bool equals(StockRecord? e1, StockRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.quantity == e2?.quantity &&
        e1?.expiryDate == e2?.expiryDate &&
        e1?.category == e2?.category &&
        e1?.manufacturer == e2?.manufacturer &&
        e1?.price == e2?.price &&
        e1?.costOfGoods == e2?.costOfGoods &&
        e1?.pharmacy == e2?.pharmacy &&
        e1?.userId == e2?.userId &&
        e1?.batchNumber == e2?.batchNumber &&
        e1?.damagedGoods == e2?.damagedGoods &&
        e1?.initialQuantity == e2?.initialQuantity &&
        e1?.limitNotice == e2?.limitNotice;
  }

  @override
  int hash(StockRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.quantity,
        e?.expiryDate,
        e?.category,
        e?.manufacturer,
        e?.price,
        e?.costOfGoods,
        e?.pharmacy,
        e?.userId,
        e?.batchNumber,
        e?.damagedGoods,
        e?.initialQuantity,
        e?.limitNotice
      ]);

  @override
  bool isValidKey(Object? o) => o is StockRecord;
}
