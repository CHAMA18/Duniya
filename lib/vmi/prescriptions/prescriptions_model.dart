import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'prescriptions_widget.dart' show PrescriptionsWidget;
import 'package:flutter/material.dart';

class PrescriptionsModel extends FlutterFlowModel<PrescriptionsWidget> {
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

  // State field(s) for Status filter dropdown.
  String? statusFilterValue;
  FormFieldController<String>? statusFilterController;

  // Dialog form fields
  FocusNode? patientNameFocusNode;
  TextEditingController? patientNameTextController;
  FocusNode? prescriberFocusNode;
  TextEditingController? prescriberTextController;
  FocusNode? notesFocusNode;
  TextEditingController? notesTextController;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    statusFilterController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
    patientNameFocusNode?.dispose();
    patientNameTextController?.dispose();
    prescriberFocusNode?.dispose();
    prescriberTextController?.dispose();
    notesFocusNode?.dispose();
    notesTextController?.dispose();
  }
}
