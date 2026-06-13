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
      return FFLocalizations.of(context).getText(
        'x5yprl3e' /* Field is required */,
      );
    }

    if (val.length < 2) {
      return FFLocalizations.of(context).getText(
        'fdktm382' /* Please enter the name of your ... */,
      );
    }
    if (val.length > 30) {
      return FFLocalizations.of(context).getText(
        'eubte9wv' /* You have exceeded the number o... */,
      );
    }

    return null;
  }

  // State field(s) for Stores widget.
  FocusNode? storesFocusNode;
  TextEditingController? storesTextController;
  String? Function(BuildContext, String?)? storesTextControllerValidator;
  String? _storesTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        'ct1cjlq6' /* Field is required */,
      );
    }

    return null;
  }

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
  }
}
