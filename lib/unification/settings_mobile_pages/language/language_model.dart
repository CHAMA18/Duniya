import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/language_changer/language_changer_widget.dart';
import 'language_widget.dart' show LanguageWidget;
import 'package:flutter/material.dart';

class LanguageModel extends FlutterFlowModel<LanguageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for languageChanger component.
  late LanguageChangerModel languageChangerModel;

  @override
  void initState(BuildContext context) {
    languageChangerModel = createModel(context, () => LanguageChangerModel());
  }

  @override
  void dispose() {
    languageChangerModel.dispose();
  }
}
