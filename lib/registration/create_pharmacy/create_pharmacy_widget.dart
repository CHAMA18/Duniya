import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/walkthroughs/data.dart';
import '/index.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'
    show TutorialCoachMark;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'create_pharmacy_model.dart';
export 'create_pharmacy_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — CREATE PHARMACY (World-Class Onboarding)
///   Top 1% onboarding UX: split-screen hero + form card with
///   branded header, labeled fields with icons, live validation,
///   helpful tips, and a clear primary action.
/// ═══════════════════════════════════════════════════════════════

class CreatePharmacyWidget extends StatefulWidget {
  const CreatePharmacyWidget({super.key});

  static String routeName = 'CreatePharmacy';
  static String routePath = '/profileMobil';

  @override
  State<CreatePharmacyWidget> createState() => _CreatePharmacyWidgetState();
}

class _CreatePharmacyWidgetState extends State<CreatePharmacyWidget> {
  late CreatePharmacyModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreatePharmacyModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'CreatePharmacy'});
    _model.storeNameTextController ??= TextEditingController();
    _model.storeNameFocusNode ??= FocusNode();
    _model.storesTextController ??= TextEditingController();
    _model.storesFocusNode ??= FocusNode();
    _model.phoneTextController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? FlutterFlowTheme.of(context).error
            : FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _inputDecoration(FlutterFlowTheme theme,
      {required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: theme.bodyMedium.override(
        fontFamily: theme.bodyMediumFamily,
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodyMediumIsCustom,
      ),
      hintStyle: theme.bodySmall.override(
        fontFamily: theme.bodySmallFamily,
        color: theme.secondaryText,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodySmallIsCustom,
      ),
      prefixIcon: Icon(icon, color: theme.primary, size: 18.0),
      filled: true,
      fillColor: theme.primaryBackground,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.alternate, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primary, width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.error, width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 14.0),
    );
  }

  Widget _labeledField({
    required String label,
    required IconData icon,
    required bool required_,
    required Widget child,
    required FlutterFlowTheme theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.secondaryText, size: 14.0),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
            if (required_) ...[
              const SizedBox(width: 2.0),
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8.0),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiCallResponse>(
      future: CountryCall.call(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SpinKitRing(
                color: FlutterFlowTheme.of(context).primary,
                size: 56.0,
                lineWidth: 3.0,
              ),
            ),
          );
        }

        final theme = FlutterFlowTheme.of(context);

        return Title(
            title: 'Create Your Pharmacy',
            color: theme.primary.withAlpha(0XFF),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: theme.primaryBackground,
                body: SafeArea(
                  top: true,
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;

                        if (isWide) {
                          // ── Desktop: split-screen layout ──
                          return Row(
                            children: [
                              // Left: branded hero panel
                              Expanded(
                                flex: 5,
                                child: _buildHeroPanel(theme),
                              ),
                              // Right: form
                              Expanded(
                                flex: 6,
                                child: _buildFormCard(theme),
                              ),
                            ],
                          );
                        }

                        // ── Mobile: stacked layout ──
                        return SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 16.0, 24.0, 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMobileHeader(theme),
                              const SizedBox(height: 24.0),
                              _buildFormCard(theme, isMobile: true),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   HERO PANEL (desktop left side)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroPanel(FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, theme.secondary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(48.0, 48.0, 48.0, 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 1.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy_rounded,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                const Text(
                  'Duniya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48.0),

            // Big headline
            const Text(
              'Set up your pharmacy in minutes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Tell us about your pharmacy and we\'ll set up everything you need — inventory tracking, sales, stock counts, and a powerful dashboard to run your operations.',
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40.0),

            // Feature bullets
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroFeature(Icons.inventory_2_rounded,
                    'Real-time inventory across all outlets'),
                _heroFeature(Icons.point_of_sale_rounded,
                    'Point of sale with live stock deductions'),
                _heroFeature(Icons.fact_check_rounded,
                    'Audit-ready stock counts & variances'),
                _heroFeature(Icons.notifications_active_rounded,
                    'Smart low-stock alerts before stockouts'),
              ],
            ),

            const Spacer(),
            // Footer trust badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.white.withAlpha(40),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 16.0),
                  const SizedBox(width: 8.0),
                  Text(
                    'HIPAA-ready · Bank-level security',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: Colors.white, size: 16.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   MOBILE HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileHeader(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.primary, theme.secondary],
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                color: Colors.white,
                size: 22.0,
              ),
            ),
            const SizedBox(width: 12.0),
            const Text(
              'Duniya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        Text(
          'Set up your pharmacy',
          style: theme.headlineMedium.override(
            fontFamily: theme.headlineMediumFamily,
            fontSize: 26.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            useGoogleFonts: !theme.headlineMediumIsCustom,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Tell us about your pharmacy to get started with inventory, sales, and stock management.',
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            color: theme.secondaryText,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   FORM CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFormCard(FlutterFlowTheme theme, {bool isMobile = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(
          isMobile ? 0.0 : 48.0,
          isMobile ? 0.0 : 32.0,
          isMobile ? 0.0 : 48.0,
          isMobile ? 0.0 : 32.0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobile) ...[
                // Desktop form header
                Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: theme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(Icons.add_business_rounded,
                          color: theme.primary, size: 20.0),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Your Pharmacy',
                            style: theme.headlineSmall.override(
                              fontFamily: theme.headlineSmallFamily,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              useGoogleFonts: !theme.headlineSmallIsCustom,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Fill in your pharmacy details below',
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28.0),
              ],

              // ── Form fields card ──
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 24.0, 24.0, 24.0),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: theme.alternate, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF111827).withAlpha(12),
                      blurRadius: 20.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pharmacy Name
                    _labeledField(
                      label: 'Pharmacy Name',
                      icon: Icons.local_pharmacy_rounded,
                      required_: true,
                      theme: theme,
                      child: TextFormField(
                        controller: _model.storeNameTextController,
                        focusNode: _model.storeNameFocusNode,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          theme,
                          label: 'Pharmacy Name',
                          hint: 'e.g. Chungu Pharmacy',
                          icon: Icons.local_pharmacy_rounded,
                        ),
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                        validator: _model.storeNameTextControllerValidator
                            .asValidator(context),
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction((old, new_) {
                              return TextEditingValue(
                                selection: new_.selection,
                                text: new_.text
                                    .toCapitalization(TextCapitalization.words),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Address
                    _labeledField(
                      label: 'Address',
                      icon: Icons.location_on_rounded,
                      required_: true,
                      theme: theme,
                      child: TextFormField(
                        controller: _model.storesTextController,
                        focusNode: _model.storesFocusNode,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          theme,
                          label: 'Address',
                          hint: 'e.g. Salama Park, Lusaka',
                          icon: Icons.location_on_rounded,
                        ),
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                        validator: _model.storesTextControllerValidator
                            .asValidator(context),
                        inputFormatters: [
                          if (!isAndroid && !isiOS)
                            TextInputFormatter.withFunction((old, new_) {
                              return TextEditingValue(
                                selection: new_.selection,
                                text: new_.text
                                    .toCapitalization(TextCapitalization.words),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18.0),

                    // Phone + Email (two columns on desktop, stacked on mobile)
                    if (isMobile) ...[
                      _labeledField(
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        required_: false,
                        theme: theme,
                        child: TextFormField(
                          controller: _model.phoneTextController,
                          focusNode: _model.phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            theme,
                            label: 'Phone Number',
                            hint: '+260 7X XXX XXXX',
                            icon: Icons.phone_rounded,
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      _labeledField(
                        label: 'Email (optional)',
                        icon: Icons.mail_outline_rounded,
                        required_: false,
                        theme: theme,
                        child: TextFormField(
                          controller: _model.emailTextController,
                          focusNode: _model.emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            theme,
                            label: 'Email (optional)',
                            hint: 'contact@yourpharmacy.com',
                            icon: Icons.mail_outline_rounded,
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _labeledField(
                              label: 'Phone',
                              icon: Icons.phone_rounded,
                              required_: false,
                              theme: theme,
                              child: TextFormField(
                                controller: _model.phoneTextController,
                                focusNode: _model.phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  theme,
                                  label: 'Phone',
                                  hint: '+260 7X XXX XXXX',
                                  icon: Icons.phone_rounded,
                                ),
                                style: theme.bodyMedium.override(
                                  fontFamily: theme.bodyMediumFamily,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodyMediumIsCustom,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: _labeledField(
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              required_: false,
                              theme: theme,
                              child: TextFormField(
                                controller: _model.emailTextController,
                                focusNode: _model.emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                decoration: _inputDecoration(
                                  theme,
                                  label: 'Email',
                                  hint: 'contact@pharmacy.com',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                style: theme.bodyMedium.override(
                                  fontFamily: theme.bodyMediumFamily,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodyMediumIsCustom,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24.0),

                    // Create button
                    FFButtonWidget(
                      onPressed: () async {
                        logFirebaseEvent(
                            'CREATE_PHARMACY_PAGE_CREATE_BTN_ON_TAP');
                        // Validate form
                        final name = _model.storeNameTextController?.text ?? '';
                        final address = _model.storesTextController?.text ?? '';
                        if (name.isEmpty) {
                          _showToast('Please enter your pharmacy name',
                              isError: true);
                          _model.storeNameFocusNode?.requestFocus();
                          return;
                        }
                        if (address.isEmpty) {
                          _showToast('Please enter your pharmacy address',
                              isError: true);
                          _model.storesFocusNode?.requestFocus();
                          return;
                        }

                        logFirebaseEvent('Button_backend_call');
                        final userRef = currentUserReference;
                        if (userRef == null) {
                          _showToast(
                              'Unable to identify your account. Please sign in again.',
                              isError: true);
                          return;
                        }
                        await PharmacyRecord.createDoc(userRef).set(
                            createPharmacyRecordData(
                          name: name,
                          address: address,
                          userID: currentUserReference,
                          deleted: false,
                          // Self-registered pharmacies start as 'pending_approval'.
                          // A Duniya admin must approve them before they appear
                          // as active on the Duniya network.
                          networkStatus: 'pending_approval',
                          registeredAt: getCurrentTimestamp,
                        ));
                        logFirebaseEvent('Button_navigate_to');
                        context.pushNamed(WelcomeWidget.routeName);
                      },
                      text: 'Create Pharmacy',
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18.0),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 52.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        color: theme.primary,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        elevation: 0.0,
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),

                    const SizedBox(height: 14.0),

                    // Help text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 12.0, color: theme.secondaryText),
                        const SizedBox(width: 6.0),
                        Text(
                          'Your information is encrypted and HIPAA-ready',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            fontSize: 11.0,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TutorialCoachMark createPageWalkthrough(BuildContext context) =>
      TutorialCoachMark(
        targets: createWalkthroughTargets(context),
        onFinish: () async {
          safeSetState(() => _model.dataController = null);
        },
        onSkip: () {
          return true;
        },
      );
}
