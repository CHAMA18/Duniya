import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'register_uni_widget.dart' show RegisterUniWidget;
import 'package:flutter/material.dart';

class RegisterUniModel extends FlutterFlowModel<RegisterUniWidget> {
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
  // State field(s) for passwordCon widget.
  FocusNode? passwordConFocusNode;
  TextEditingController? passwordConTextController;
  late bool passwordConVisibility;
  String? Function(BuildContext, String?)? passwordConTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    passwordConVisibility = false;
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    passwordConFocusNode?.dispose();
    passwordConTextController?.dispose();
  }
}
