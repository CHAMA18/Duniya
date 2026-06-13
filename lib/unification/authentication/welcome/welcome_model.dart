import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'welcome_widget.dart' show WelcomeWidget;
import 'package:flutter/material.dart';

class WelcomeModel extends FlutterFlowModel<WelcomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in Welcome widget.
  UserRecord? own;
  // Stores action output result for [Backend Call - API (subscriptionstatus)] action in Welcome widget.
  ApiCallResponse? apiResultzh55;
  // Stores action output result for [Backend Call - API (PackageName)] action in Welcome widget.
  ApiCallResponse? customers;
  // Stores action output result for [Firestore Query - Query a collection] action in Welcome widget.
  int? pharmacyCount;
  // Stores action output result for [Backend Call - API (subscriptionstatus)] action in Welcome widget.
  ApiCallResponse? apiResultzh88;
  // Stores action output result for [Backend Call - API (PackageName)] action in Welcome widget.
  ApiCallResponse? customer;
  // Model for loadingSpinner component.
  late LoadingSpinnerModel loadingSpinnerModel;

  @override
  void initState(BuildContext context) {
    loadingSpinnerModel = createModel(context, () => LoadingSpinnerModel());
  }

  @override
  void dispose() {
    loadingSpinnerModel.dispose();
  }
}
