import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'create_pharmacy_widget.dart' show CreatePharmacyWidget;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'
    show TutorialCoachMark;
import 'package:flutter/material.dart';

class CreatePharmacyModel extends FlutterFlowModel<CreatePharmacyWidget> {
  ///  State fields for stateful widgets in this page.

  TutorialCoachMark? dataController;
  final formKey = GlobalKey<FormState>();

  // State field(s) for StoreName widget.
  FocusNode? storeNameFocusNode;
  TextEditingController? storeNameTextController;
  String? Function(BuildContext, String?)? storeNameTextControllerValidator;
  String? _storeNameTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Pharmacy name is required';
    }
    if (val.length < 2) {
      return 'Please enter the full name of your pharmacy';
    }
    if (val.length > 60) {
      return 'Name is too long (max 60 characters)';
    }
    return null;
  }

  // State field(s) for Stores (Address) widget.
  FocusNode? storesFocusNode;
  TextEditingController? storesTextController;
  String? Function(BuildContext, String?)? storesTextControllerValidator;
  String? _storesTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Address is required';
    }
    if (val.length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }

  // State field(s) for Phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(BuildContext, String?)? phoneTextControllerValidator;

  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  @override
  void initState(BuildContext context) {
    storeNameTextControllerValidator = _storeNameTextControllerValidator;
    storesTextControllerValidator = _storesTextControllerValidator;
  }

  @override
  void dispose() {
    dataController?.finish();
    storeNameFocusNode?.dispose();
    storeNameTextController?.dispose();
    storesFocusNode?.dispose();
    storesTextController?.dispose();
    phoneFocusNode?.dispose();
    phoneTextController?.dispose();
    emailFocusNode?.dispose();
    emailTextController?.dispose();
  }
}
