import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/empty_cart_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'cart_widget.dart' show CartWidget;
import 'package:flutter/material.dart';

class CartModel extends FlutterFlowModel<CartWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for emptyCart component.
  late EmptyCartModel emptyCartModel;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  SalesRecord? sales;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  FinanceRecord? fine;
  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  PharmacyRecord? pharm;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  StockRecord? stock;
  // Stores action output result for [Backend Call - API (sendEmail)] action in Button widget.
  ApiCallResponse? ownerCall;
  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  UserRecord? owner;
  // Stores action output result for [Backend Call - API (sendEmail)] action in Button widget.
  ApiCallResponse? apiResult0v5;

  @override
  void initState(BuildContext context) {
    emptyCartModel = createModel(context, () => EmptyCartModel());
  }

  @override
  void dispose() {
    emptyCartModel.dispose();
  }
}
