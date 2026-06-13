import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'login_uni_widget.dart' show LoginUniWidget;
import 'package:flutter/material.dart';

class LoginUniModel extends FlutterFlowModel<LoginUniWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  StaffRecord? tuk;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? staff;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? usercheak;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? user;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  StaffRecord? pcheck;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
