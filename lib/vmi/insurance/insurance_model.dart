import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'insurance_widget.dart' show InsuranceWidget;
import 'package:flutter/material.dart';

class InsuranceModel extends FlutterFlowModel<InsuranceWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component (desktop/tablet).
  late SideNavModel sideNavModel1;
  // Model for SideNav component (drawer/mobile).
  late SideNavModel sideNavModel2;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for Status filter tabs.
  String statusFilter = 'All';

  // State field(s) for Member ID input (verification).
  FocusNode? memberIdFocusNode;
  TextEditingController? memberIdTextController;
  String? memberIdValue;

  // State field(s) for Claim form – sale/invoice dropdown.
  String? claimSaleValue;
  FormFieldController<String>? claimSaleValueController;

  // State field(s) for Claim form – member dropdown.
  String? claimMemberValue;
  FormFieldController<String>? claimMemberValueController;

  // State field(s) for Claim form – amount input.
  FocusNode? claimAmountFocusNode;
  TextEditingController? claimAmountTextController;

  // Whether member verification has been performed.
  bool memberVerified = false;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    claimSaleValueController = FormFieldController<String>(null);
    claimMemberValueController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    memberIdFocusNode?.dispose();
    memberIdTextController?.dispose();
    claimAmountFocusNode?.dispose();
    claimAmountTextController?.dispose();
  }
}
