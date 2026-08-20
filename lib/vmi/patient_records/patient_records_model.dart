import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'patient_records_widget.dart' show PatientRecordsWidget;
import 'package:flutter/material.dart';

class PatientRecordsModel extends FlutterFlowModel<PatientRecordsWidget> {
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

  // State field(s) for Add Patient dialog.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  FocusNode? dobFocusNode;
  TextEditingController? dobTextController;
  DateTime? dobDate;
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  FocusNode? medicalAidFocusNode;
  TextEditingController? medicalAidTextController;

  // Expanded patient index (for medication history).
  int? expandedPatientIndex;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();
    dobFocusNode?.dispose();
    dobTextController?.dispose();
    phoneFocusNode?.dispose();
    phoneTextController?.dispose();
    addressFocusNode?.dispose();
    addressTextController?.dispose();
    medicalAidFocusNode?.dispose();
    medicalAidTextController?.dispose();
  }
}
