import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductMasterRecord extends FirestoreRecord {
  ProductMasterRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "Name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "GenericName" field.
  String? _genericName;
  String? get genericName => _genericName;
  bool hasGenericName() => _genericName != null;

  // "BrandName" field.
  String? _brandName;
  String? get brandName => _brandName;
  bool hasBrandName() => _brandName != null;

  // "Strength" field.
  String? _strength;
  String? get strength => _strength;
  bool hasStrength() => _strength != null;

  // "DosageForm" field.
  String? _dosageForm;
  String? get dosageForm => _dosageForm;
  bool hasDosageForm() => _dosageForm != null;

  // "PackSize" field.
  String? _packSize;
  String? get packSize => _packSize;
  bool hasPackSize() => _packSize != null;

  // "UnitOfMeasure" field.
  String? _unitOfMeasure;
  String? get unitOfMeasure => _unitOfMeasure;
  bool hasUnitOfMeasure() => _unitOfMeasure != null;

  // "SKU" field.
  String? _sku;
  String get sku => _sku ?? '';
  bool hasSKU() => _sku != null;

  // "Category" field.
  String? _category;
  String? get category => _category;
  bool hasCategory() => _category != null;

  // "Supplier" field.
  String? _supplier;
  String? get supplier => _supplier;
  bool hasSupplier() => _supplier != null;

  // "CostPrice" field.
  double? _costPrice;
  double get costPrice => _costPrice ?? 0.0;
  bool hasCostPrice() => _costPrice != null;

  // "SellingPrice" field.
  double? _sellingPrice;
  double get sellingPrice => _sellingPrice ?? 0.0;
  bool hasSellingPrice() => _sellingPrice != null;

  // "MinimumStockLevel" field.
  int? _minimumStockLevel;
  int get minimumStockLevel => _minimumStockLevel ?? 0;
  bool hasMinimumStockLevel() => _minimumStockLevel != null;

  // "ReorderLevel" field.
  int? _reorderLevel;
  int get reorderLevel => _reorderLevel ?? 0;
  bool hasReorderLevel() => _reorderLevel != null;

  // "TargetStockLevel" field.
  int? _targetStockLevel;
  int get targetStockLevel => _targetStockLevel ?? 0;
  bool hasTargetStockLevel() => _targetStockLevel != null;

  // "IsActive" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "CreatedAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "UpdatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _name = snapshotData['Name'] as String?;
    _genericName = snapshotData['GenericName'] as String?;
    _brandName = snapshotData['BrandName'] as String?;
    _strength = snapshotData['Strength'] as String?;
    _dosageForm = snapshotData['DosageForm'] as String?;
    _packSize = snapshotData['PackSize'] as String?;
    _unitOfMeasure = snapshotData['UnitOfMeasure'] as String?;
    _sku = snapshotData['SKU'] as String?;
    _category = snapshotData['Category'] as String?;
    _supplier = snapshotData['Supplier'] as String?;
    _costPrice = castToType<double>(snapshotData['CostPrice']);
    _sellingPrice = castToType<double>(snapshotData['SellingPrice']);
    _minimumStockLevel = castToType<int>(snapshotData['MinimumStockLevel']);
    _reorderLevel = castToType<int>(snapshotData['ReorderLevel']);
    _targetStockLevel = castToType<int>(snapshotData['TargetStockLevel']);
    _isActive = snapshotData['IsActive'] as bool?;
    _createdAt = snapshotData['CreatedAt'] as DateTime?;
    _updatedAt = snapshotData['UpdatedAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('ProductMaster');

  static Stream<ProductMasterRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProductMasterRecord.fromSnapshot(s));

  static Future<ProductMasterRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProductMasterRecord.fromSnapshot(s));

  static ProductMasterRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProductMasterRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProductMasterRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProductMasterRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProductMasterRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProductMasterRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createProductMasterRecordData({
  String? name,
  String? genericName,
  String? brandName,
  String? strength,
  String? dosageForm,
  String? packSize,
  String? unitOfMeasure,
  String? sku,
  String? category,
  String? supplier,
  double? costPrice,
  double? sellingPrice,
  int? minimumStockLevel,
  int? reorderLevel,
  int? targetStockLevel,
  bool? isActive,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'Name': name,
      'GenericName': genericName,
      'BrandName': brandName,
      'Strength': strength,
      'DosageForm': dosageForm,
      'PackSize': packSize,
      'UnitOfMeasure': unitOfMeasure,
      'SKU': sku,
      'Category': category,
      'Supplier': supplier,
      'CostPrice': costPrice,
      'SellingPrice': sellingPrice,
      'MinimumStockLevel': minimumStockLevel,
      'ReorderLevel': reorderLevel,
      'TargetStockLevel': targetStockLevel,
      'IsActive': isActive,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProductMasterRecordDocumentEquality
    implements Equality<ProductMasterRecord> {
  const ProductMasterRecordDocumentEquality();

  @override
  bool equals(ProductMasterRecord? e1, ProductMasterRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.genericName == e2?.genericName &&
        e1?.brandName == e2?.brandName &&
        e1?.strength == e2?.strength &&
        e1?.dosageForm == e2?.dosageForm &&
        e1?.packSize == e2?.packSize &&
        e1?.unitOfMeasure == e2?.unitOfMeasure &&
        e1?.sku == e2?.sku &&
        e1?.category == e2?.category &&
        e1?.supplier == e2?.supplier &&
        e1?.costPrice == e2?.costPrice &&
        e1?.sellingPrice == e2?.sellingPrice &&
        e1?.minimumStockLevel == e2?.minimumStockLevel &&
        e1?.reorderLevel == e2?.reorderLevel &&
        e1?.targetStockLevel == e2?.targetStockLevel &&
        e1?.isActive == e2?.isActive &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(ProductMasterRecord? e) => const ListEquality().hash([
        e?.name,
        e?.genericName,
        e?.brandName,
        e?.strength,
        e?.dosageForm,
        e?.packSize,
        e?.unitOfMeasure,
        e?.sku,
        e?.category,
        e?.supplier,
        e?.costPrice,
        e?.sellingPrice,
        e?.minimumStockLevel,
        e?.reorderLevel,
        e?.targetStockLevel,
        e?.isActive,
        e?.createdAt,
        e?.updatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is ProductMasterRecord;
}
