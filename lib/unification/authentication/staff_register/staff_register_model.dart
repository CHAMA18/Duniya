import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'staff_register_widget.dart' show StaffRegisterWidget;
import 'package:flutter/material.dart';

class StaffRegisterModel extends FlutterFlowModel<StaffRegisterWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in StaffRegister widget.
  StaffRecord? staff;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // Model for loadingSpinner component.
  late LoadingSpinnerModel loadingSpinnerModel;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    loadingSpinnerModel = createModel(context, () => LoadingSpinnerModel());
    passwordVisibility = false;
  }

  @override
  void dispose() {
    emailFocusNode?.dispose();
    emailTextController?.dispose();

    loadingSpinnerModel.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
