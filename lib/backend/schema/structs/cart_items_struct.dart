// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CartItemsStruct extends FFFirebaseStruct {
  CartItemsStruct({
    List<String>? displayName,
    List<int>? quantity,
    DocumentReference? pharmId,
    String? pharmName,
    List<double>? price,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _displayName = displayName,
        _quantity = quantity,
        _pharmId = pharmId,
        _pharmName = pharmName,
        _price = price,
        super(firestoreUtilData);

  // "Display_Name" field.
  List<String>? _displayName;
  List<String> get displayName => _displayName ?? const [];
  set displayName(List<String>? val) => _displayName = val;

  void updateDisplayName(Function(List<String>) updateFn) {
    updateFn(_displayName ??= []);
  }

  bool hasDisplayName() => _displayName != null;

  // "Quantity" field.
  List<int>? _quantity;
  List<int> get quantity => _quantity ?? const [];
  set quantity(List<int>? val) => _quantity = val;

  void updateQuantity(Function(List<int>) updateFn) {
    updateFn(_quantity ??= []);
  }

  bool hasQuantity() => _quantity != null;

  // "PharmId" field.
  DocumentReference? _pharmId;
  DocumentReference? get pharmId => _pharmId;
  set pharmId(DocumentReference? val) => _pharmId = val;

  bool hasPharmId() => _pharmId != null;

  // "PharmName" field.
  String? _pharmName;
  String get pharmName => _pharmName ?? '';
  set pharmName(String? val) => _pharmName = val;

  bool hasPharmName() => _pharmName != null;

  // "Price" field.
  List<double>? _price;
  List<double> get price => _price ?? const [];
  set price(List<double>? val) => _price = val;

  void updatePrice(Function(List<double>) updateFn) {
    updateFn(_price ??= []);
  }

  bool hasPrice() => _price != null;

  static CartItemsStruct fromMap(Map<String, dynamic> data) => CartItemsStruct(
        displayName: getDataList(data['Display_Name']),
        quantity: getDataList(data['Quantity']),
        pharmId: data['PharmId'] as DocumentReference?,
        pharmName: data['PharmName'] as String?,
        price: getDataList(data['Price']),
      );

  static CartItemsStruct? maybeFromMap(dynamic data) => data is Map
      ? CartItemsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'Display_Name': _displayName,
        'Quantity': _quantity,
        'PharmId': _pharmId,
        'PharmName': _pharmName,
        'Price': _price,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'Display_Name': serializeParam(
          _displayName,
          ParamType.String,
          isList: true,
        ),
        'Quantity': serializeParam(
          _quantity,
          ParamType.int,
          isList: true,
        ),
        'PharmId': serializeParam(
          _pharmId,
          ParamType.DocumentReference,
        ),
        'PharmName': serializeParam(
          _pharmName,
          ParamType.String,
        ),
        'Price': serializeParam(
          _price,
          ParamType.double,
          isList: true,
        ),
      }.withoutNulls;

  static CartItemsStruct fromSerializableMap(Map<String, dynamic> data) =>
      CartItemsStruct(
        displayName: deserializeParam<String>(
          data['Display_Name'],
          ParamType.String,
          true,
        ),
        quantity: deserializeParam<int>(
          data['Quantity'],
          ParamType.int,
          true,
        ),
        pharmId: deserializeParam(
          data['PharmId'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['User', 'Pharmacy'],
        ),
        pharmName: deserializeParam(
          data['PharmName'],
          ParamType.String,
          false,
        ),
        price: deserializeParam<double>(
          data['Price'],
          ParamType.double,
          true,
        ),
      );

  static CartItemsStruct fromAlgoliaData(Map<String, dynamic> data) =>
      CartItemsStruct(
        displayName: convertAlgoliaParam<String>(
          data['Display_Name'],
          ParamType.String,
          true,
        ),
        quantity: convertAlgoliaParam<int>(
          data['Quantity'],
          ParamType.int,
          true,
        ),
        pharmId: convertAlgoliaParam(
          data['PharmId'],
          ParamType.DocumentReference,
          false,
        ),
        pharmName: convertAlgoliaParam(
          data['PharmName'],
          ParamType.String,
          false,
        ),
        price: convertAlgoliaParam<double>(
          data['Price'],
          ParamType.double,
          true,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'CartItemsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CartItemsStruct &&
        listEquality.equals(displayName, other.displayName) &&
        listEquality.equals(quantity, other.quantity) &&
        pharmId == other.pharmId &&
        pharmName == other.pharmName &&
        listEquality.equals(price, other.price);
  }

  @override
  int get hashCode => const ListEquality()
      .hash([displayName, quantity, pharmId, pharmName, price]);
}

CartItemsStruct createCartItemsStruct({
  DocumentReference? pharmId,
  String? pharmName,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CartItemsStruct(
      pharmId: pharmId,
      pharmName: pharmName,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CartItemsStruct? updateCartItemsStruct(
  CartItemsStruct? cartItems, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    cartItems
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCartItemsStructData(
  Map<String, dynamic> firestoreData,
  CartItemsStruct? cartItems,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (cartItems == null) {
    return;
  }
  if (cartItems.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && cartItems.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final cartItemsData = getCartItemsFirestoreData(cartItems, forFieldValue);
  final nestedData = cartItemsData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = cartItems.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCartItemsFirestoreData(
  CartItemsStruct? cartItems, [
  bool forFieldValue = false,
]) {
  if (cartItems == null) {
    return {};
  }
  final firestoreData = mapToFirestore(cartItems.toMap());

  // Add any Firestore field values
  mapToFirestore(cartItems.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCartItemsListFirestoreData(
  List<CartItemsStruct>? cartItemss,
) =>
    cartItemss?.map((e) => getCartItemsFirestoreData(e, true)).toList() ?? [];
