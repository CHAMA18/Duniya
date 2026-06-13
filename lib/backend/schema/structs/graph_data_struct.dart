// ignore_for_file: unnecessary_getters_setters
import '/backend/algolia/serialization_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GraphDataStruct extends FFFirebaseStruct {
  GraphDataStruct({
    List<String>? months,
    List<double>? totals,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _months = months,
        _totals = totals,
        super(firestoreUtilData);

  // "Months" field.
  List<String>? _months;
  List<String> get months => _months ?? const [];
  set months(List<String>? val) => _months = val;

  void updateMonths(Function(List<String>) updateFn) {
    updateFn(_months ??= []);
  }

  bool hasMonths() => _months != null;

  // "Totals" field.
  List<double>? _totals;
  List<double> get totals => _totals ?? const [];
  set totals(List<double>? val) => _totals = val;

  void updateTotals(Function(List<double>) updateFn) {
    updateFn(_totals ??= []);
  }

  bool hasTotals() => _totals != null;

  static GraphDataStruct fromMap(Map<String, dynamic> data) => GraphDataStruct(
        months: getDataList(data['Months']),
        totals: getDataList(data['Totals']),
      );

  static GraphDataStruct? maybeFromMap(dynamic data) => data is Map
      ? GraphDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'Months': _months,
        'Totals': _totals,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'Months': serializeParam(
          _months,
          ParamType.String,
          isList: true,
        ),
        'Totals': serializeParam(
          _totals,
          ParamType.double,
          isList: true,
        ),
      }.withoutNulls;

  static GraphDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      GraphDataStruct(
        months: deserializeParam<String>(
          data['Months'],
          ParamType.String,
          true,
        ),
        totals: deserializeParam<double>(
          data['Totals'],
          ParamType.double,
          true,
        ),
      );

  static GraphDataStruct fromAlgoliaData(Map<String, dynamic> data) =>
      GraphDataStruct(
        months: convertAlgoliaParam<String>(
          data['Months'],
          ParamType.String,
          true,
        ),
        totals: convertAlgoliaParam<double>(
          data['Totals'],
          ParamType.double,
          true,
        ),
        firestoreUtilData: FirestoreUtilData(
          clearUnsetFields: false,
          create: true,
        ),
      );

  @override
  String toString() => 'GraphDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is GraphDataStruct &&
        listEquality.equals(months, other.months) &&
        listEquality.equals(totals, other.totals);
  }

  @override
  int get hashCode => const ListEquality().hash([months, totals]);
}

GraphDataStruct createGraphDataStruct({
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    GraphDataStruct(
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

GraphDataStruct? updateGraphDataStruct(
  GraphDataStruct? graphData, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    graphData
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addGraphDataStructData(
  Map<String, dynamic> firestoreData,
  GraphDataStruct? graphData,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (graphData == null) {
    return;
  }
  if (graphData.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && graphData.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final graphDataData = getGraphDataFirestoreData(graphData, forFieldValue);
  final nestedData = graphDataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = graphData.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getGraphDataFirestoreData(
  GraphDataStruct? graphData, [
  bool forFieldValue = false,
]) {
  if (graphData == null) {
    return {};
  }
  final firestoreData = mapToFirestore(graphData.toMap());

  // Add any Firestore field values
  mapToFirestore(graphData.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getGraphDataListFirestoreData(
  List<GraphDataStruct>? graphDatas,
) =>
    graphDatas?.map((e) => getGraphDataFirestoreData(e, true)).toList() ?? [];
