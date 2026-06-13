import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'stock_balances_widget.dart' show StockBalancesWidget;
import 'package:flutter/material.dart';

class StockBalancesModel extends FlutterFlowModel<StockBalancesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for SearchBar widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? searchValue;
  String? Function(BuildContext, String?)? searchTextControllerValidator;

  // State field(s) for Pharmacy dropdown.
  String? pharmacyValue;
  FormFieldController<String>? pharmacyValueController;

  // State field(s) for Outlet dropdown.
  String? outletValue;
  FormFieldController<String>? outletValueController;

  // State field(s) for Period dropdown.
  String? periodValue;
  FormFieldController<String>? periodValueController;

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
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
