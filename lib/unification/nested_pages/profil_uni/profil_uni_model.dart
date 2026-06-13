import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/profile_image/profile_image_widget.dart';
import '/index.dart';
import 'profil_uni_widget.dart' show ProfilUniWidget;
import 'package:flutter/material.dart';

class ProfilUniModel extends FlutterFlowModel<ProfilUniWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for ProfileImage component.
  late ProfileImageModel profileImageModel;
  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for number widget.
  FocusNode? numberFocusNode;
  TextEditingController? numberTextController;
  String? Function(BuildContext, String?)? numberTextControllerValidator;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    profileImageModel = createModel(context, () => ProfileImageModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    profileImageModel.dispose();
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    numberFocusNode?.dispose();
    numberTextController?.dispose();
  }
}
