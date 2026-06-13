import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'add_product_widget.dart' show AddProductWidget;
import 'package:flutter/material.dart';

class AddProductModel extends FlutterFlowModel<AddProductWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for Category widget.
  String? categoryValue;
  FormFieldController<String>? categoryValueController;
  // State field(s) for pharm widget.
  String? pharmValue;
  FormFieldController<String>? pharmValueController;
  // Stores action output result for [Firestore Query - Query a collection] action in pharm widget.
  PharmacyRecord? pharm;
  // State field(s) for Price widget.
  FocusNode? priceFocusNode;
  TextEditingController? priceTextController;
  String? Function(BuildContext, String?)? priceTextControllerValidator;
  // State field(s) for Ouantity widget.
  FocusNode? ouantityFocusNode;
  TextEditingController? ouantityTextController;
  String? Function(BuildContext, String?)? ouantityTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for INCOM widget.
  FocusNode? incomFocusNode;
  TextEditingController? incomTextController;
  String? Function(BuildContext, String?)? incomTextControllerValidator;
  // State field(s) for batch widget.
  FocusNode? batchFocusNode;
  TextEditingController? batchTextController;
  String? Function(BuildContext, String?)? batchTextControllerValidator;
  // State field(s) for limit widget.
  FocusNode? limitFocusNode;
  TextEditingController? limitTextController;
  String? Function(BuildContext, String?)? limitTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  FinanceRecord? finee;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    priceFocusNode?.dispose();
    priceTextController?.dispose();

    ouantityFocusNode?.dispose();
    ouantityTextController?.dispose();

    incomFocusNode?.dispose();
    incomTextController?.dispose();

    batchFocusNode?.dispose();
    batchTextController?.dispose();

    limitFocusNode?.dispose();
    limitTextController?.dispose();
  }
}
