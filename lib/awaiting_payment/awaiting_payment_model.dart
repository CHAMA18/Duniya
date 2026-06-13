import '/backend/api_requests/api_calls.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'awaiting_payment_widget.dart' show AwaitingPaymentWidget;
import 'package:flutter/material.dart';

class AwaitingPaymentModel extends FlutterFlowModel<AwaitingPaymentWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetStripeUser)] action in AwaitingPayment widget.
  ApiCallResponse? stripeuser;
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
