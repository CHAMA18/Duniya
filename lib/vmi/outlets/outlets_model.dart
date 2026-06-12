import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'outlets_widget.dart' show OutletsWidget;
import 'package:flutter/material.dart';

class OutletsModel extends FlutterFlowModel<OutletsWidget> {
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

  // Dialog form fields
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  FocusNode? codeFocusNode;
  TextEditingController? codeTextController;
  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;

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
    nameFocusNode?.dispose();
    nameTextController?.dispose();
    codeFocusNode?.dispose();
    codeTextController?.dispose();
    addressFocusNode?.dispose();
    addressTextController?.dispose();
  }
}
