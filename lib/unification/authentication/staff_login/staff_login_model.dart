import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'staff_login_widget.dart' show StaffLoginWidget;
import 'package:flutter/material.dart';

class StaffLoginModel extends FlutterFlowModel<StaffLoginWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Read Document] action in StaffLogin widget.
  StaffRecord? staff1;
  // Model for loadingSpinner component.
  late LoadingSpinnerModel loadingSpinnerModel;
  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  @override
  void initState(BuildContext context) {
    loadingSpinnerModel = createModel(context, () => LoadingSpinnerModel());
    passwordVisibility = false;
  }

  @override
  void dispose() {
    loadingSpinnerModel.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
