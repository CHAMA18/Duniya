import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'sales_vmi_widget.dart' show SalesVMIWidget;
import 'package:flutter/material.dart';

class SalesVMIModel extends FlutterFlowModel<SalesVMIWidget> {
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

  // Dialog form fields
  String? dialogPharmacyValue;
  FormFieldController<String>? dialogPharmacyValueController;
  String? dialogOutletValue;
  FormFieldController<String>? dialogOutletValueController;
  FocusNode? dialogPatientRefFocusNode;
  TextEditingController? dialogPatientRefTextController;

  // Line item fields
  String? lineProductValue;
  FormFieldController<String>? lineProductValueController;
  FocusNode? lineQtyFocusNode;
  TextEditingController? lineQtyTextController;
  FocusNode? linePriceFocusNode;
  TextEditingController? linePriceTextController;

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
    dialogPatientRefFocusNode?.dispose();
    dialogPatientRefTextController?.dispose();
    lineQtyFocusNode?.dispose();
    lineQtyTextController?.dispose();
    linePriceFocusNode?.dispose();
    linePriceTextController?.dispose();
  }
}
