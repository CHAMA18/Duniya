import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'stock_count_detail_widget.dart' show StockCountDetailWidget;
import 'package:flutter/material.dart';

class StockCountDetailModel extends FlutterFlowModel<StockCountDetailWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for Pharmacy dropdown.
  String? pharmacyValue;
  FormFieldController<String>? pharmacyValueController;

  // State field(s) for Outlet dropdown.
  String? outletValue;
  FormFieldController<String>? outletValueController;

  // State field(s) for Notes.
  FocusNode? notesFocusNode;
  TextEditingController? notesTextController;

  // Counted quantity controllers per product
  Map<String, TextEditingController> countedQtyControllers = {};
  Map<String, FocusNode> countedQtyFocusNodes = {};

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    notesFocusNode?.dispose();
    notesTextController?.dispose();
    for (var controller in countedQtyControllers.values) {
      controller.dispose();
    }
    for (var node in countedQtyFocusNodes.values) {
      node.dispose();
    }
  }
}
