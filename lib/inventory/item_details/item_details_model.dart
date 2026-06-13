import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'item_details_widget.dart' show ItemDetailsWidget;
import 'package:flutter/material.dart';

class ItemDetailsModel extends FlutterFlowModel<ItemDetailsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for Category widget.
  String? categoryValue;
  FormFieldController<String>? categoryValueController;
  // State field(s) for price widget.
  FocusNode? priceFocusNode;
  TextEditingController? priceTextController;
  String? Function(BuildContext, String?)? priceTextControllerValidator;
  // State field(s) for quantity widget.
  FocusNode? quantityFocusNode;
  TextEditingController? quantityTextController;
  String? Function(BuildContext, String?)? quantityTextControllerValidator;
  // State field(s) for BatchNumber widget.
  FocusNode? batchNumberFocusNode1;
  TextEditingController? batchNumberTextController1;
  String? Function(BuildContext, String?)? batchNumberTextController1Validator;
  // State field(s) for BatchNumber widget.
  FocusNode? batchNumberFocusNode2;
  TextEditingController? batchNumberTextController2;
  String? Function(BuildContext, String?)? batchNumberTextController2Validator;
  DateTime? datePicked;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    priceFocusNode?.dispose();
    priceTextController?.dispose();

    quantityFocusNode?.dispose();
    quantityTextController?.dispose();

    batchNumberFocusNode1?.dispose();
    batchNumberTextController1?.dispose();

    batchNumberFocusNode2?.dispose();
    batchNumberTextController2?.dispose();
  }
}
