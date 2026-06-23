import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'addstores_widget.dart' show AddstoresWidget;
import 'package:flutter/material.dart';

class TeamMemberDraft {
  String name;
  String email;
  String phone;
  String role;
  String? assignedOutletId;
  String? assignedOutletName;

  TeamMemberDraft({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = 'Pharmacist',
    this.assignedOutletId,
    this.assignedOutletName,
  });
}

class OutletDraft {
  String name;
  String code;
  String address;

  OutletDraft({
    this.name = '',
    this.code = '',
    this.address = '',
  });
}

class AddstoresModel extends FlutterFlowModel<AddstoresWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;

  // Pharmacy Details fields
  FocusNode? pharmacyNameFocusNode;
  TextEditingController? pharmacyNameTextController;
  String? Function(BuildContext, String?)? pharmacyNameValidator;

  FocusNode? addressFocusNode;
  TextEditingController? addressTextController;
  String? Function(BuildContext, String?)? addressValidator;

  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;

  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;

  FocusNode? licenseFocusNode;
  TextEditingController? licenseTextController;

  // Outlet draft fields
  FocusNode? outletNameFocusNode;
  TextEditingController? outletNameTextController;

  FocusNode? outletCodeFocusNode;
  TextEditingController? outletCodeTextController;

  FocusNode? outletAddressFocusNode;
  TextEditingController? outletAddressTextController;

  // Member draft fields
  FocusNode? memberNameFocusNode;
  TextEditingController? memberNameTextController;

  FocusNode? memberEmailFocusNode;
  TextEditingController? memberEmailTextController;

  FocusNode? memberPhoneFocusNode;
  TextEditingController? memberPhoneTextController;

  // Data lists
  List<OutletDraft> outletDrafts = [];
  List<TeamMemberDraft> memberDrafts = [];

  // UI state
  int currentStep = 0; // 0: Details, 1: Outlets, 2: Team
  bool isSaving = false;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    pharmacyNameFocusNode?.dispose();
    pharmacyNameTextController?.dispose();
    addressFocusNode?.dispose();
    addressTextController?.dispose();
    phoneFocusNode?.dispose();
    phoneTextController?.dispose();
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    licenseFocusNode?.dispose();
    licenseTextController?.dispose();
    outletNameFocusNode?.dispose();
    outletNameTextController?.dispose();
    outletCodeFocusNode?.dispose();
    outletCodeTextController?.dispose();
    outletAddressFocusNode?.dispose();
    outletAddressTextController?.dispose();
    memberNameFocusNode?.dispose();
    memberNameTextController?.dispose();
    memberEmailFocusNode?.dispose();
    memberEmailTextController?.dispose();
    memberPhoneFocusNode?.dispose();
    memberPhoneTextController?.dispose();
  }
}
