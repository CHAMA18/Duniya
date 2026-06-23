import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'reset_pass_widget.dart' show ResetPassWidget;
import 'package:flutter/material.dart';

class ResetPassModel extends FlutterFlowModel<ResetPassWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
