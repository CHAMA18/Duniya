import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'cold_chain_widget.dart' show ColdChainWidget;
import 'package:flutter/material.dart';

class ColdChainModel extends FlutterFlowModel<ColdChainWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component (desktop/tablet).
  late SideNavModel sideNavModel1;
  // Model for SideNav component (drawer/mobile).
  late SideNavModel sideNavModel2;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for SearchBar widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? searchValue;

  // State field(s) for Unit Type dropdown filter.
  String? unitTypeFilterValue;
  FormFieldController<String>? unitTypeFilterController;

  // Dialog form fields (Sensor Management)
  String? dialogSensorTypeValue;
  FormFieldController<String>? dialogSensorTypeController;
  FocusNode? dialogSensorIdFocusNode;
  TextEditingController? dialogSensorIdTextController;
  FocusNode? dialogUnitNameFocusNode;
  TextEditingController? dialogUnitNameTextController;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    unitTypeFilterController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
    dialogSensorIdFocusNode?.dispose();
    dialogSensorIdTextController?.dispose();
    dialogUnitNameFocusNode?.dispose();
    dialogUnitNameTextController?.dispose();
  }
}
