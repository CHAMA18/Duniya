import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'add_user_widget.dart' show AddUserWidget;
import 'package:flutter/material.dart';

class AddUserModel extends FlutterFlowModel<AddUserWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;
  // State field(s) for role widget.
  FocusNode? roleFocusNode;
  TextEditingController? roleTextController;
  String? Function(BuildContext, String?)? roleTextControllerValidator;
  // State field(s) for pharm widget.
  String? pharmValue;
  FormFieldController<String>? pharmValueController;
  // Stores action output result for [Firestore Query - Query a collection] action in pharm widget.
  PharmacyRecord? pharma;
  // State field(s) for pass widget.
  FocusNode? passFocusNode;
  TextEditingController? passTextController;
  late bool passVisibility;
  String? Function(BuildContext, String?)? passTextControllerValidator;
  // State field(s) for passr widget.
  FocusNode? passrFocusNode;
  TextEditingController? passrTextController;
  late bool passrVisibility;
  String? Function(BuildContext, String?)? passrTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? users;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? staff;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  PharmacyRecord? pharm;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    passVisibility = false;
    passrVisibility = false;
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    roleFocusNode?.dispose();
    roleTextController?.dispose();

    passFocusNode?.dispose();
    passTextController?.dispose();

    passrFocusNode?.dispose();
    passrTextController?.dispose();
  }
}
