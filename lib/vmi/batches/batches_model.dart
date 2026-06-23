import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'batches_widget.dart' show BatchesWidget;
import 'package:flutter/material.dart';

class BatchesModel extends FlutterFlowModel<BatchesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component (desktop/tablet).
  late SideNavModel sideNavModel1;
  // Model for SideNav component (drawer/mobile).
  late SideNavModel sideNavModel2;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for Pharmacy dropdown.
  String? pharmacyValue;
  FormFieldController<String>? pharmacyValueController;

  // State field(s) for Expiry Status dropdown.
  String? expiryStatusValue;
  FormFieldController<String>? expiryStatusValueController;

  // State field(s) for SearchBar widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? searchValue;

  // Dialog form fields
  String? dialogProductValue;
  FormFieldController<String>? dialogProductValueController;
  FocusNode? dialogBatchFocusNode;
  TextEditingController? dialogBatchTextController;
  DateTime? dialogExpiryDate;
  FocusNode? dialogQtyFocusNode;
  TextEditingController? dialogQtyTextController;
  FocusNode? dialogFacilityFocusNode;
  TextEditingController? dialogFacilityTextController;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    // Initialize the expiry status dropdown controller so it is never null
    // when passed to FlutterFlowDropDown (otherwise the dropdown's initState
    // throws `Null check operator used on a null value` and the whole section
    // collapses into a grey ErrorWidget).
    expiryStatusValueController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
    dialogBatchFocusNode?.dispose();
    dialogBatchTextController?.dispose();
    dialogQtyFocusNode?.dispose();
    dialogQtyTextController?.dispose();
    dialogFacilityFocusNode?.dispose();
    dialogFacilityTextController?.dispose();
  }
}
