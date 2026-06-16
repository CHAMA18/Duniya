import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'add_user_model.dart';
export 'add_user_model.dart';

class AddUserWidget extends StatefulWidget {
  const AddUserWidget({super.key});

  static String routeName = 'AddUser';
  static String routePath = '/addUser';

  @override
  State<AddUserWidget> createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends State<AddUserWidget> {
  late AddUserModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Duniya brand tokens (kept in sync with the rest of the app) ──
  static const Color _duniyaPurple = Color(0xFF9900FF);
  static const Color _duniyaPurpleDark = Color(0xFF7C3AED);
  static const Color _duniyaPurpleDeep = Color(0xFF6A00D9);
  static const Color _duniyaPurpleLight = Color(0xFFF3F0FF);
  static const Color _bgColor = Color(0xFFF8F9FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0B1C30);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _dangerColor = Color(0xFFEF4444);
  static const Color _warningColor = Color(0xFFF59E0B);

  // Pre-defined role chips (matches what the original text field accepted,
  // but presented as a guided picker so staff owners can't typo a role).
  static const List<String> _roleOptions = [
    'Cashier',
    'Pharmacist',
    'Manager',
    'Technician',
    'Owner',
  ];

  // Friendly icon per role for the chip picker.
  IconData _roleIcon(String role) {
    switch (role) {
      case 'Cashier':
        return Icons.point_of_sale_outlined;
      case 'Pharmacist':
        return Icons.medical_services_outlined;
      case 'Manager':
        return Icons.manage_accounts_outlined;
      case 'Technician':
        return Icons.science_outlined;
      case 'Owner':
        return Icons.verified_user_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddUserModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AddUser'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('ADD_USER_PAGE_AddUser_ON_INIT_STATE');
      if (currentUserEmail == '') {
        logFirebaseEvent('AddUser_navigate_to');
        context.goNamed(LoginUniWidget.routeName);
        return;
      }
    });

    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();
    _model.nameTextController!.addListener(_onFormChanged);

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();
    _model.emailAddressTextController!.addListener(_onFormChanged);

    _model.phoneTextController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();
    _model.phoneTextController!.addListener(_onFormChanged);

    // roleTextController is initialized inside the model's initState.
    _model.roleFocusNode ??= FocusNode();
    _model.roleTextController!.addListener(_onFormChanged);

    _model.passTextController ??= TextEditingController();
    _model.passFocusNode ??= FocusNode();
    _model.passTextController!.addListener(_onFormChanged);

    _model.passrTextController ??= TextEditingController();
    _model.passrFocusNode ??= FocusNode();
    _model.passrTextController!.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  void _onFormChanged() {
    // Keep the role text controller in sync with the selected role chip so
    // the original submit logic (which reads roleTextController.text) still
    // writes the correct value into Firestore.
    if (_model.selectedRole != null &&
        _model.roleTextController?.text != _model.selectedRole) {
      // Use a quiet setter that doesn't trigger another listener cycle.
      _model.roleTextController?.text = _model.selectedRole ?? '';
    }
    safeSetState(() {});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Validation helpers ──
  bool get _isNameValid =>
      (_model.nameTextController?.text.trim().length ?? 0) >= 2;
  bool get _isEmailValid => RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$')
      .hasMatch(_model.emailAddressTextController?.text.trim() ?? '');
  bool get _isPhoneValid =>
      (_model.phoneTextController?.text.trim().length ?? 0) >= 7;
  bool get _isRoleValid => _model.selectedRole != null;
  bool get _isPharmacyValid => _model.pharmValue != null;
  bool get _isPasswordValid =>
      _model.passwordStrength(_model.passTextController?.text) >= 2;
  bool get _isConfirmValid => _model.passwordsMatch();
  bool get _isFormValid =>
      _isNameValid &&
      _isEmailValid &&
      _isPhoneValid &&
      _isRoleValid &&
      _isPharmacyValid &&
      _isPasswordValid &&
      _isConfirmValid;

  String? _nameError() => !_isNameValid && (_model.nameTextController?.text.isNotEmpty ?? false)
      ? 'Name must be at least 2 characters'
      : null;
  String? _emailError() => !_isEmailValid && (_model.emailAddressTextController?.text.isNotEmpty ?? false)
      ? 'Enter a valid email address'
      : null;
  String? _phoneError() => !_isPhoneValid && (_model.phoneTextController?.text.isNotEmpty ?? false)
      ? 'Enter a valid phone number'
      : null;

  // ── Submit handler (preserved from original FF codegen, with branded
  //    dialog UX and a proper submitting state on the Save button) ──
  Future<void> _handleSave() async {
    if (!_isFormValid || _model.isSubmitting) return;

    safeSetState(() => _model.isSubmitting = true);
    try {
      logFirebaseEvent('ADD_USER_PAGE_SAVE_BTN_ON_TAP');
      var _shouldSetState = false;
      logFirebaseEvent('Button_firestore_query');
      _model.users = await queryUserRecordCount(
        queryBuilder: (userRecord) => userRecord.where(
          'email',
          isEqualTo: _model.emailAddressTextController!.text,
        ),
      );
      _shouldSetState = true;
      if (_model.users.toString() == '0') {
        logFirebaseEvent('Button_firestore_query');
        _model.staff = await queryStaffRecordCount(
          queryBuilder: (staffRecord) => staffRecord.where(
            'Email',
            isEqualTo: _model.emailAddressTextController!.text,
          ),
        );
        _shouldSetState = true;
        if (_model.staff != 0) {
          logFirebaseEvent('Button_alert_dialog');
          await _showDuplicateEmailDialog();
          if (_shouldSetState) safeSetState(() {});
          return;
        }
        logFirebaseEvent('Button_firestore_query');
        _model.pharm = await queryPharmacyRecordOnce(
          parent: currentUserReference,
          queryBuilder: (pharmacyRecord) =>
              pharmacyRecord.where('Name', isEqualTo: _model.pharmValue),
          singleRecord: true,
        ).then((s) => s.firstOrNull);
        _shouldSetState = true;
        logFirebaseEvent('Button_backend_call');

        await StaffRecord.collection.doc().set(
              createStaffRecordData(
                ownerRef: currentUserReference,
                name: _model.nameTextController!.text,
                role: _model.roleTextController!.text,
                email: _model.emailAddressTextController!.text,
                phone: _model.phoneTextController!.text,
                pharmId: _model.pharm?.reference,
                password: _model.passTextController!.text,
                deleted: false,
              ),
            );
        logFirebaseEvent('Button_navigate_to');

        if (context.mounted) {
          await _showSuccessToast();
          context.pushNamed(HumanResourceUniWidget.routeName);
        }
      } else {
        logFirebaseEvent('Button_alert_dialog');
        await _showDuplicateEmailDialog();
      }

      if (_shouldSetState) safeSetState(() {});
    } finally {
      if (mounted) safeSetState(() => _model.isSubmitting = false);
    }
  }

  Future<void> _showDuplicateEmailDialog() async {
    await showDialog(
      context: context,
      builder: (alertDialogContext) => WebViewAware(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: _dangerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(Icons.error_outline,
                    color: _dangerColor, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Text('Email already in use',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                      fontSize: 18.0)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Text(
              'Another staff member is already using this email address. '
              'Please use a different email or remove the existing account.',
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.0,
                  color: _textSecondary,
                  height: 1.5),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: _duniyaPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              ),
              child: Text('Got it',
                  style: TextStyle(
                      fontFamily: 'Satoshi', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSuccessToast() async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _BrandedToast(
        icon: Icons.check_circle_rounded,
        iconColor: _successColor,
        title: 'Staff member added',
        message:
            '${_model.nameTextController?.text.trim() ?? "New staff"} has been added to ${_model.pharmValue ?? "your pharmacy"}.',
      ),
    );
    overlay.insert(entry);
    await Future.delayed(const Duration(seconds: 3));
    entry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Add Staff Member',
      color: _duniyaPurple,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bgColor,
          drawer: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.sideNavModel,
              updateCallback: () => safeSetState(() {}),
              child: SideNavWidget(),
            ),
          ),
          appBar: responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false,
          )
              ? AppBar(
                  backgroundColor: _surfaceColor,
                  automaticallyImplyLeading: false,
                  leading: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    borderWidth: 1.0,
                    buttonSize: 60.0,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: _duniyaPurpleDark,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      logFirebaseEvent(
                          'ADD_USER_chevron_left_rounded_ICN_ON_TAP');
                      logFirebaseEvent('IconButton_navigate_back');
                      context.pop();
                    },
                  ),
                  title: Text(
                    'Add Staff Member',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      fontSize: 18.0,
                      color: _textPrimary,
                    ),
                  ),
                  actions: [],
                  centerTitle: true,
                  elevation: 0.0,
                )
              : null,
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Desktop sidebar
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.sideNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SideNavWidget(),
                  ),
                // Main content
                Expanded(
                  child: FutureBuilder<ApiCallResponse>(
                    future: DrugsCall.call(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: SpinKitRing(color: _duniyaPurple, size: 48.0),
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top nav (desktop)
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            tabletLandscape: false,
                          ))
                            wrapWithModel(
                              model: _model.topNavModel,
                              updateCallback: () => safeSetState(() {}),
                              child: TopNavWidget(
                                openDrawer: () async {
                                  scaffoldKey.currentState?.openDrawer();
                                },
                              ),
                            ),
                          // Scrollable content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    responsiveVisibility(context: context,
                                            phone: false, tablet: false)
                                        ? 40.0
                                        : 20.0,
                                vertical: 28.0,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxWidth: 920.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Hero gradient header ──
                                      _buildHeroHeader(),
                                      const SizedBox(height: 24.0),

                                      // ── Main form card ──
                                      Container(
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          border: Border.all(
                                              color: _borderColor, width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.04),
                                              blurRadius: 30.0,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(28.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ── Section 1: Personal Information ──
                                              _buildSectionLabel(
                                                icon: Icons
                                                    .person_outline_rounded,
                                                title:
                                                    'Personal Information',
                                                subtitle:
                                                    'The staff member\'s basic contact details.',
                                              ),
                                              const SizedBox(height: 20.0),
                                              _buildResponsiveRow(
                                                children: [
                                                  _buildPremiumField(
                                                    label: 'Full Name',
                                                    hint: 'e.g. John Banda',
                                                    icon: Icons
                                                        .person_outline_rounded,
                                                    controller: _model
                                                        .nameTextController,
                                                    focusNode:
                                                        _model.nameFocusNode,
                                                    capitalization:
                                                        TextCapitalization
                                                            .words,
                                                    errorText: _nameError(),
                                                    required: true,
                                                  ),
                                                  _buildPremiumField(
                                                    label: 'Email Address',
                                                    hint:
                                                        'name@pharmacy.com',
                                                    icon: Icons
                                                        .mail_outline_rounded,
                                                    controller: _model
                                                        .emailAddressTextController,
                                                    focusNode: _model
                                                        .emailAddressFocusNode,
                                                    keyboardType:
                                                        TextInputType
                                                            .emailAddress,
                                                    errorText: _emailError(),
                                                    required: true,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16.0),
                                              _buildResponsiveRow(
                                                children: [
                                                  _buildPremiumField(
                                                    label: 'Phone Number',
                                                    hint: 'e.g. 0977112233',
                                                    icon: Icons
                                                        .phone_outlined,
                                                    controller: _model
                                                        .phoneTextController,
                                                    focusNode: _model
                                                        .phoneFocusNode,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    errorText: _phoneError(),
                                                    required: true,
                                                  ),
                                                  // Avatar preview tile
                                                  _buildAvatarPreview(),
                                                ],
                                              ),
                                              const SizedBox(height: 32.0),

                                              // ── Section 2: Role & Pharmacy ──
                                              _buildSectionLabel(
                                                icon: Icons
                                                    .badge_outlined,
                                                title: 'Role & Pharmacy',
                                                subtitle:
                                                    'Pick the staff member\'s role and the pharmacy they belong to.',
                                              ),
                                              const SizedBox(height: 20.0),
                                              _buildRoleChips(),
                                              const SizedBox(height: 20.0),
                                              _buildPharmacyPicker(),
                                              const SizedBox(height: 32.0),

                                              // ── Section 3: Security ──
                                              _buildSectionLabel(
                                                icon: Icons
                                                    .lock_outline_rounded,
                                                title: 'Security',
                                                subtitle:
                                                    'Set a strong password. The staff member can change it later.',
                                              ),
                                              const SizedBox(height: 20.0),
                                              _buildResponsiveRow(
                                                children: [
                                                  _buildPasswordField(
                                                    label: 'Password',
                                                    hint:
                                                        'At least 8 characters',
                                                    controller: _model
                                                        .passTextController,
                                                    focusNode:
                                                        _model.passFocusNode,
                                                    visible:
                                                        _model.passVisibility,
                                                    onToggleVisibility: () =>
                                                        safeSetState(() =>
                                                            _model.passVisibility =
                                                                !_model
                                                                    .passVisibility),
                                                    showStrength: true,
                                                    required: true,
                                                  ),
                                                  _buildPasswordField(
                                                    label: 'Confirm Password',
                                                    hint:
                                                        'Re-enter the password',
                                                    controller: _model
                                                        .passrTextController,
                                                    focusNode: _model
                                                        .passrFocusNode,
                                                    visible:
                                                        _model.passrVisibility,
                                                    onToggleVisibility: () =>
                                                        safeSetState(() =>
                                                            _model.passrVisibility =
                                                                !_model
                                                                    .passrVisibility),
                                                    showMatch: true,
                                                    required: true,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),

                                      // ── Sticky action bar ──
                                      _buildActionBar(),
                                      const SizedBox(height: 28.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Hero gradient header with avatar + step indicator
  // ───────────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final initials = (_model.nameTextController?.text.trim().isNotEmpty ?? false)
        ? _model.nameTextController!.text.trim().split(' ').take(2).map((s) => s[0].toUpperCase()).join()
        : '?';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          colors: [_duniyaPurpleDeep, _duniyaPurple, _duniyaPurpleDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _duniyaPurple.withValues(alpha: 0.3),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40.0,
            top: -40.0,
            child: Container(
              width: 180.0,
              height: 180.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40.0,
            bottom: -30.0,
            child: Container(
              width: 90.0,
              height: 90.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar circle (live initials preview)
                Container(
                  width: 72.0,
                  height: 72.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w800,
                      fontSize: 28.0,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Step pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(9999.0),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.group_add_rounded,
                                color: Colors.white, size: 14.0),
                            SizedBox(width: 6.0),
                            Text(
                              'NEW STAFF MEMBER',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                                fontSize: 11.0,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      const Text(
                        'Add Staff Member',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w800,
                          fontSize: 28.0,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -0.02,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      const Text(
                        'Create a new staff account for your pharmacy team. '
                        'Fill in the details below — they\'ll be able to log in immediately.',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Section label with icon
  // ───────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: _duniyaPurpleLight,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: _duniyaPurple, size: 20.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      color: _textPrimary,
                      letterSpacing: -0.01)),
              const SizedBox(height: 2.0),
              Text(subtitle,
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      color: _textSecondary,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Responsive two-column row that collapses to a single column on phones
  // ───────────────────────────────────────────────────────────────────
  Widget _buildResponsiveRow({required List<Widget> children}) {
    final isPhone = responsiveVisibility(
      context: context,
      phone: false,
      tablet: false,
    );
    if (isPhone) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 16.0),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SizedBox(height: 16.0),
        ],
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Premium text field with icon prefix, focus animation, error state,
  // helper text, and required asterisk.
  // ───────────────────────────────────────────────────────────────────
  Widget _buildPremiumField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? errorText,
    bool required = false,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    color: _textPrimary)),
            if (required) ...[
              const SizedBox(width: 4.0),
              Text('*',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: _dangerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0)),
            ],
          ],
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14.0,
              color: _textPrimary,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14.0,
                color: _textSecondary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400),
            prefixIcon:
                Icon(icon, size: 18.0, color: _duniyaPurpleDark),
            filled: true,
            fillColor: _duniyaPurpleLight.withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                  color: hasError ? _dangerColor : _borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _duniyaPurple, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _dangerColor, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _dangerColor, width: 2.0),
            ),
            errorText: hasError ? errorText : null,
            errorStyle: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11.0,
                color: _dangerColor,
                height: 1.2),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Live avatar preview tile (right column of the phone row)
  // ───────────────────────────────────────────────────────────────────
  Widget _buildAvatarPreview() {
    final name = _model.nameTextController?.text.trim() ?? '';
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((s) => s[0].toUpperCase()).join()
        : '?';
    final email = _model.emailAddressTextController?.text.trim() ?? '';
    final role = _model.selectedRole ?? '—';
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _duniyaPurpleLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
            color: _duniyaPurple.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_duniyaPurple, _duniyaPurpleDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.center,
                child: Text(initials,
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.w800,
                        fontSize: 16.0,
                        color: Colors.white)),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Live preview',
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _duniyaPurpleDark)),
                    const SizedBox(height: 2.0),
                    Text(name.isEmpty ? 'New staff member' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: _textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          if (email.isNotEmpty || role != '—')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (email.isNotEmpty)
                  Row(children: [
                    Icon(Icons.mail_outline, size: 12.0, color: _textSecondary),
                    const SizedBox(width: 6.0),
                    Expanded(
                      child: Text(email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11.5,
                              color: _textSecondary)),
                    ),
                  ]),
                if (role != '—') ...[
                  const SizedBox(height: 4.0),
                  Row(children: [
                    Icon(_roleIcon(role), size: 12.0, color: _textSecondary),
                    const SizedBox(width: 6.0),
                    Text(role,
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.5,
                            color: _textSecondary,
                            fontWeight: FontWeight.w500)),
                  ]),
                ],
              ],
            )
          else
            Text('Start typing to see the staff card preview.',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11.5,
                    color: _textSecondary.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Role chip picker
  // ───────────────────────────────────────────────────────────────────
  Widget _buildRoleChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('Role',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    color: _textPrimary)),
            const SizedBox(width: 4.0),
            Text('*',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: _dangerColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0)),
          ],
        ),
        const SizedBox(height: 10.0),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: _roleOptions.map((role) {
            final isSelected = _model.selectedRole == role;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () {
                  safeSetState(() {
                    _model.selectedRole = role;
                    _model.roleTextController?.text = role;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _duniyaPurple
                        : _duniyaPurpleLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSelected
                          ? _duniyaPurple
                          : _borderColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _duniyaPurple.withValues(alpha: 0.25),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_roleIcon(role),
                          size: 16.0,
                          color: isSelected
                              ? Colors.white
                              : _duniyaPurpleDark),
                      const SizedBox(width: 8.0),
                      Text(role,
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.w600,
                              fontSize: 13.0,
                              color: isSelected
                                  ? Colors.white
                                  : _textPrimary)),
                      if (isSelected) ...[
                        const SizedBox(width: 6.0),
                        const Icon(Icons.check_circle,
                            size: 14.0, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Pharmacy picker (uses the original StreamBuilder + FlutterFlowDropDown
  // so we keep the exact Firestore query + onchange handler intact)
  // ───────────────────────────────────────────────────────────────────
  Widget _buildPharmacyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text('Pharmacy',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    color: _textPrimary)),
            const SizedBox(width: 4.0),
            Text('*',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: _dangerColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0)),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: _isPharmacyValid
                ? [
                    BoxShadow(
                      color: _duniyaPurple.withValues(alpha: 0.08),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: StreamBuilder<List<PharmacyRecord>>(
            stream: queryPharmacyRecord(
              parent: currentUserReference,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: _duniyaPurpleLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: _borderColor, width: 1.0),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: SpinKitRing(
                        color: _duniyaPurple,
                        size: 24.0,
                        lineWidth: 2.0,
                      ),
                    ),
                  ),
                );
              }
              final pharmPharmacyRecordList = snapshot.data!;

              return FlutterFlowDropDown<String>(
                controller: _model.pharmValueController ??=
                    FormFieldController<String>(null),
                options:
                    pharmPharmacyRecordList.map((e) => e.name).toList(),
                onChanged: (val) async {
                  safeSetState(() => _model.pharmValue = val);
                  logFirebaseEvent('ADD_USER_pharm_ON_FORM_WIDGET_SELECTED');
                  logFirebaseEvent('pharm_firestore_query');
                  _model.pharma = await queryPharmacyRecordOnce(
                    parent: currentUserReference,
                    queryBuilder: (pharmacyRecord) =>
                        pharmacyRecord.where('Name', isEqualTo: _model.pharmValue),
                    singleRecord: true,
                  ).then((s) => s.firstOrNull);
                  logFirebaseEvent('pharm_update_app_state');
                  FFAppState().updateCartStruct(
                    (e) => e..pharmId = _model.pharma?.reference,
                  );
                  safeSetState(() {});
                },
                width: double.infinity,
                height: 56.0,
                textStyle: TextStyle(
                  fontFamily: 'Satoshi',
                  color: _textPrimary,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
                hintText: 'Select the pharmacy branch…',
                icon: Icon(
                  Icons.local_pharmacy_outlined,
                  color: _duniyaPurpleDark,
                  size: 18.0,
                ),
                fillColor: _duniyaPurpleLight.withValues(alpha: 0.4),
                elevation: 2.0,
                borderColor:
                    _isPharmacyValid ? _duniyaPurple : _borderColor,
                borderWidth: _isPharmacyValid ? 1.5 : 1.0,
                borderRadius: 12.0,
                margin:
                    const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                hidesUnderline: true,
                isSearchable: false,
                isMultiSelect: false,
              );
            },
          ),
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            Icon(Icons.info_outline,
                size: 12.0, color: _textSecondary.withValues(alpha: 0.7)),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text(
                'The staff member will only see data for the pharmacy you select here.',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11.5,
                    color: _textSecondary.withValues(alpha: 0.8),
                    height: 1.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Password field with optional strength meter or match indicator
  // ───────────────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required bool visible,
    required VoidCallback onToggleVisibility,
    bool showStrength = false,
    bool showMatch = false,
    bool required = false,
  }) {
    final password = controller?.text ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    color: _textPrimary)),
            if (required) ...[
              const SizedBox(width: 4.0),
              Text('*',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: _dangerColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.0)),
            ],
          ],
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !visible,
          style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14.0,
              color: _textPrimary,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14.0,
                color: _textSecondary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400),
            prefixIcon:
                Icon(Icons.lock_outline, size: 18.0, color: _duniyaPurpleDark),
            suffixIcon: InkWell(
              onTap: onToggleVisibility,
              borderRadius: BorderRadius.circular(20.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18.0,
                  color: _textSecondary,
                ),
              ),
            ),
            filled: true,
            fillColor: _duniyaPurpleLight.withValues(alpha: 0.4),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _duniyaPurple, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _dangerColor, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _dangerColor, width: 2.0),
            ),
          ),
        ),
        if (showStrength) ...[
          const SizedBox(height: 10.0),
          _buildPasswordStrengthBar(password),
        ],
        if (showMatch) ...[
          const SizedBox(height: 10.0),
          _buildPasswordMatchIndicator(password),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthBar(String password) {
    final strength = _model.passwordStrength(password);
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      _borderColor,
      _dangerColor,
      _warningColor,
      const Color(0xFF3B82F6),
      _successColor,
    ];
    final label = labels[strength];
    final color = colors[strength];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 1; i <= 4; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: i <= strength ? color : _borderColor,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              if (i < 4) const SizedBox(width: 4.0),
            ],
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          children: [
            if (label.isNotEmpty)
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: color)),
            if (label.isNotEmpty) const SizedBox(width: 12.0),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildStrengthChip('8+', password.length >= 8),
                  _buildStrengthChip(
                      'Aa', RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)),
                  _buildStrengthChip('0-9', RegExp(r'[0-9]').hasMatch(password)),
                  _buildStrengthChip(
                      '!@#', RegExp(r'[^A-Za-z0-9]').hasMatch(password)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrengthChip(String label, bool met) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: met
            ? _successColor.withValues(alpha: 0.12)
            : _borderColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(met ? Icons.check : Icons.circle_outlined,
              size: 10.0,
              color: met ? _successColor : _textSecondary),
          const SizedBox(width: 4.0),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                  color: met ? _successColor : _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPasswordMatchIndicator(String confirmPassword) {
    final password = _model.passTextController?.text ?? '';
    final isMatch = confirmPassword.isNotEmpty && confirmPassword == password;
    final isMismatch =
        confirmPassword.isNotEmpty && confirmPassword != password;
    if (!isMatch && !isMismatch) {
      return const SizedBox(height: 0.0);
    }
    return Row(
      children: [
        Icon(isMatch ? Icons.check_circle : Icons.cancel,
            size: 14.0, color: isMatch ? _successColor : _dangerColor),
        const SizedBox(width: 6.0),
        Text(
          isMatch ? 'Passwords match' : 'Passwords do not match',
          style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isMatch ? _successColor : _dangerColor),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────
  // Sticky action bar — Cancel + Save (gradient pill), with required
  // field counter + isSubmitting spinner.
  // ───────────────────────────────────────────────────────────────────
  Widget _buildActionBar() {
    final requiredCount = 7;
    final metCount = [
      _isNameValid,
      _isEmailValid,
      _isPhoneValid,
      _isRoleValid,
      _isPharmacyValid,
      _isPasswordValid,
      _isConfirmValid,
    ].where((v) => v).length;
    final allMet = metCount == requiredCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: allMet
                  ? _successColor.withValues(alpha: 0.12)
                  : _duniyaPurpleLight,
            ),
            alignment: Alignment.center,
            child: allMet
                ? Icon(Icons.check_rounded, color: _successColor, size: 20.0)
                : Text('$metCount/$requiredCount',
                    style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: _duniyaPurpleDark)),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  allMet
                      ? 'Ready to save'
                      : 'Complete $requiredCount required fields',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary),
                ),
                const SizedBox(height: 2.0),
                Text(
                  allMet
                      ? 'Click Save to add this staff member.'
                      : 'Fill in the remaining $requiredCount - $metCount field${requiredCount - metCount == 1 ? '' : 's'} to enable Save.',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11.5,
                      color: _textSecondary,
                      height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          // Cancel button
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textSecondary,
              backgroundColor: _surfaceColor,
              side: BorderSide(color: _borderColor, width: 1.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999.0)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            ),
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0)),
          ),
          const SizedBox(width: 10.0),
          // Save button (gradient pill, disabled until valid)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFormValid ? 1.0 : 0.55,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(9999.0),
                onTap: _isFormValid && !_model.isSubmitting
                    ? _handleSave
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    gradient: _isFormValid
                        ? const LinearGradient(
                            colors: [_duniyaPurple, _duniyaPurpleDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isFormValid ? null : _borderColor,
                    borderRadius: BorderRadius.circular(9999.0),
                    boxShadow: _isFormValid
                        ? [
                            BoxShadow(
                              color: _duniyaPurple.withValues(alpha: 0.3),
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_model.isSubmitting)
                        const SizedBox(
                            width: 14.0,
                            height: 14.0,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.0))
                      else
                        const Icon(Icons.person_add_alt_1_rounded,
                            color: Colors.white, size: 16.0),
                      const SizedBox(width: 8.0),
                      Text(
                        _model.isSubmitting ? 'Saving…' : 'Save Staff Member',
                        style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Branded success toast overlay
// ───────────────────────────────────────────────────────────────────────
class _BrandedToast extends StatefulWidget {
  const _BrandedToast({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  @override
  State<_BrandedToast> createState() => _BrandedToastState();
}

class _BrandedToastState extends State<_BrandedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24.0,
      left: 0.0,
      right: 0.0,
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _offset,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460.0),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                        color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24.0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(widget.icon,
                            color: widget.iconColor, size: 22.0),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.title,
                                style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.0,
                                    color: Color(0xFF0B1C30))),
                            const SizedBox(height: 2.0),
                            Text(widget.message,
                                style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12.5,
                                    color: Color(0xFF64748B),
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
