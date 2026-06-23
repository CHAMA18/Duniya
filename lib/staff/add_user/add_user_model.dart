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

  // ── Personal Information ──
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

  // ── Role & Pharmacy ──
  // Role is now a chip-picker (not a free-text field) — selectedRole holds the
  // currently-chosen role string. We keep `roleTextController` for backward
  // compatibility with the original submit logic so it still writes the role
  // string into Firestore.
  FocusNode? roleFocusNode;
  TextEditingController? roleTextController;
  String? Function(BuildContext, String?)? roleTextControllerValidator;
  String? selectedRole;

  // State field(s) for pharm widget.
  String? pharmValue;
  FormFieldController<String>? pharmValueController;
  // Stores action output result for [Firestore Query - Query a collection] action in pharm widget.
  PharmacyRecord? pharma;

  // ── Security ──
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

  // ── Submit-action outputs (preserved from original FF codegen) ──
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? users;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? staff;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  PharmacyRecord? pharm;

  // ── New UX state (for the world-class redesign) ──
  /// True while the submit handler is running (used to show a spinner on the
  /// Save button and disable it).
  bool isSubmitting = false;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    passVisibility = false;
    passrVisibility = false;
    // Initialize the role text controller so the submit logic still has
    // something to read from even before the user picks a chip.
    roleTextController ??= TextEditingController();
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

  // ── Password strength helpers ──
  /// Returns a 0-4 strength score for the given password.
  /// 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong.
  int passwordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  /// Returns true when password and confirm-password match and are non-empty.
  bool passwordsMatch() {
    final p = passTextController?.text ?? '';
    final c = passrTextController?.text ?? '';
    return p.isNotEmpty && c == p;
  }
}
