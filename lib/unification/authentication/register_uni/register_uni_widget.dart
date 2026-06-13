import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/google_auth.dart' as google_auth;
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/success/success_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'register_uni_model.dart';
export 'register_uni_model.dart';

class RegisterUniWidget extends StatefulWidget {
  const RegisterUniWidget({super.key});

  static String routeName = 'RegisterUni';
  static String routePath = '/registerUni';

  @override
  State<RegisterUniWidget> createState() => _RegisterUniWidgetState();
}

class _RegisterUniWidgetState extends State<RegisterUniWidget> {
  late RegisterUniModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Design tokens from the HTML source
  static const Color _primaryBlue = Color(0xFF0052FF);
  static const Color _primaryDeep = Color(0xFF003EC7);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceContainer = Color(0xFFE5EEFF);
  static const Color _surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF434656);
  static const Color _outline = Color(0xFF737688);
  static const Color _outlineVariant = Color(0xFFC3C5D9);
  static const Color _inversePrimary = Color(0xFFB7C4FF);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _surface = Color(0xFFF8F9FF);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegisterUniModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'RegisterUni'});
    _model.firstNameTextController ??= TextEditingController();
    _model.firstNameFocusNode ??= FocusNode();

    _model.lastNameTextController ??= TextEditingController();
    _model.lastNameFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Builds the Google logo as a custom painter widget
  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  /// Builds a styled text form field matching the HTML design
  Widget _buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? placeholder,
    IconData? prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(BuildContext, String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label in caps style (JetBrains Mono style → Satoshi)
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.08,
            height: 1.0,
            color: _onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 44.0,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator?.asValidator(context),
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: _onSurface,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: _outline,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Icon(
                        prefixIcon,
                        size: 18.0,
                        color: _outline,
                      ),
                    )
                  : null,
              prefixIconConstraints: prefixIcon != null
                  ? const BoxConstraints(minWidth: 44.0, minHeight: 0)
                  : null,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: _surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 4.0 : 16.0,
                vertical: 0,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _outlineVariant.withValues(alpha: 0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _primaryBlue,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Title(
      title: 'RegisterUni',
      color: _primaryDeep,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _background,
          body: SafeArea(
            top: true,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200.0),
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32.0 : 16.0,
                  vertical: 16.0,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height - 32.0,
                  constraints: const BoxConstraints(
                    minHeight: 600.0,
                    maxHeight: 800.0,
                  ),
                  decoration: BoxDecoration(
                    color: _surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(32.0),
                    border: Border.all(
                      color: _outlineVariant.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      // ── Left Side: Abstract Luminous Branding (desktop only) ──
                      if (isDesktop)
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.asset(
                                  'assets/images/illustration2.png',
                                ).image,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Blue overlay with multiply blend
                                Container(
                                  color: _primaryBlue.withValues(alpha: 0.8),
                                ),
                                // Backdrop blur effect container
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _primaryBlue.withValues(alpha: 0.85),
                                        _primaryDeep.withValues(alpha: 0.9),
                                      ],
                                    ),
                                  ),
                                ),
                                // Content overlay — brand identity
                                Padding(
                                  padding: const EdgeInsets.all(48.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Top: Logo / brand mark
                                      Row(
                                        children: [
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: const Icon(
                                              Icons
                                                  .medical_services_outlined,
                                              color: Colors.white,
                                              size: 22.0,
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          Text(
                                            'MediTracker',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.02,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Center: Marketing copy
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Join the Global Standard',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.w600,
                                              height: 1.2,
                                              letterSpacing: -0.02,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 16.0),
                                          Text(
                                            'Pharmacy management has never been so easy. Track inventory, monitor staff and care for your patients all in one place.',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                              height: 1.6,
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Bottom: Trust signals
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shield_outlined,
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            size: 18.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'HIPAA Compliant · Bank-Level Security',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white
                                                  .withValues(alpha: 0.7),
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

                      // ── Right Side: Form Content ──
                      Expanded(
                        flex: isDesktop ? 7 : 1,
                        child: Stack(
                          children: [
                            // Decorative background elements
                            Positioned(
                              top: -80.0,
                              right: -80.0,
                              child: Container(
                                width: 256.0,
                                height: 256.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _surfaceContainerHigh
                                      .withValues(alpha: 0.3),
                                ),
                                child: BackdropFilter(
                                  filter: ColorFilter.mode(
                                    Colors.white.withValues(alpha: 0.1),
                                    BlendMode.srcOver,
                                  ),
                                  child: Container(),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -40.0,
                              left: -60.0,
                              child: Container(
                                width: 320.0,
                                height: 320.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _inversePrimary
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                            ),

                            // Main form content
                            Center(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 64.0 : 32.0,
                                  vertical: 32.0,
                                ),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 440.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Mobile Branding (hidden on desktop) ──
                                      if (!isDesktop)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 24.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .medical_services_outlined,
                                                color: _primaryDeep,
                                                size: 28.0,
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                'MediTracker',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.04,
                                                  color: _primaryDeep,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // ── Heading ──
                                      Text(
                                        'Create your account',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: isDesktop ? 32.0 : 24.0,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                          letterSpacing: -0.02,
                                          color: _onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Enter your professional details to access the command center.',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                          height: 1.6,
                                          color: _onSurfaceVariant,
                                        ),
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── Google Sign Up Button ──
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44.0,
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            logFirebaseEvent(
                                                'REGISTER_UNI_GOOGLE_SIGN_UP_BTN_ON_TAP');
                                            logFirebaseEvent('Button_auth');
                                            GoRouter.of(context)
                                                .prepareAuthEvent();
                                            try {
                                              final userCredential =
                                                  await google_auth
                                                      .googleSignInFunc();
                                              if (userCredential != null) {
                                                final user =
                                                    userCredential.user;
                                                if (user != null) {
                                                  // Check if user doc exists, create if not
                                                  final userDoc =
                                                      await UserRecord
                                                          .getDocumentOnce(
                                                    UserRecord.collection
                                                        .doc(user.uid),
                                                  );
                                                  if (!userDoc.hasRole()) {
                                                    await UserRecord.collection
                                                        .doc(user.uid)
                                                        .set(
                                                            createUserRecordData(
                                                      email: user.email,
                                                      displayName:
                                                          user.displayName,
                                                      photoUrl: user.photoURL,
                                                      uid: user.uid,
                                                      createdTime:
                                                          getCurrentTimestamp,
                                                      role: 'Owner',
                                                    ));
                                                  }

                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    enableDrag: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return WebViewAware(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child:
                                                                SuccessWidget(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      safeSetState(() {}));

                                                  if (context.mounted) {
                                                    context.goNamedAuth(
                                                        WelcomeWidget
                                                            .routeName,
                                                        context.mounted);
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Google sign up failed: $e'),
                                                ),
                                              );
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: _surface,
                                            side: BorderSide(
                                              color: _outlineVariant
                                                  .withValues(alpha: 0.5),
                                              width: 1.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      9999.0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _buildGoogleLogo(),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                'Sign up with Google',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  letterSpacing: -0.01,
                                                  color: _onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 16.0),

                                      // ── "Or sign up with email" Divider ──
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1.0,
                                              color: _outlineVariant
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                            child: Text(
                                              'OR SIGN UP WITH EMAIL',
                                              style: TextStyle(
                                                fontFamily: 'Satoshi',
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.08,
                                                color: _outline,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1.0,
                                              color: _outlineVariant
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16.0),

                                      // ── First Name + Last Name Row ──
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildTextFormField(
                                              controller: _model
                                                  .firstNameTextController!,
                                              focusNode:
                                                  _model.firstNameFocusNode!,
                                              label: 'First Name',
                                              placeholder: 'Sarah',
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Expanded(
                                            child: _buildTextFormField(
                                              controller: _model
                                                  .lastNameTextController!,
                                              focusNode:
                                                  _model.lastNameFocusNode!,
                                              label: 'Last Name',
                                              placeholder: 'Chen',
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16.0),

                                      // ── Professional Email ──
                                      _buildTextFormField(
                                        controller: _model
                                            .emailAddressTextController!,
                                        focusNode:
                                            _model.emailAddressFocusNode!,
                                        label: 'Professional Email',
                                        placeholder:
                                            'sarah.chen@apexhealth.com',
                                        prefixIcon: Icons.mail_outline,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (context, value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Email is required';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 16.0),

                                      // ── Password ──
                                      _buildTextFormField(
                                        controller:
                                            _model.passwordTextController!,
                                        focusNode: _model.passwordFocusNode!,
                                        label: 'Password',
                                        placeholder: '••••••••',
                                        prefixIcon: Icons.lock_outline,
                                        obscureText:
                                            !_model.passwordVisibility,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _model.passwordVisibility
                                                ? Icons.visibility_outlined
                                                : Icons
                                                    .visibility_off_outlined,
                                            size: 18.0,
                                            color: _outline,
                                          ),
                                          onPressed: () {
                                            safeSetState(() => _model
                                                    .passwordVisibility =
                                                !_model.passwordVisibility);
                                          },
                                        ),
                                        validator: (context, value) {
                                          if (value == null ||
                                              value.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── Create Account Button ──
                                      SizedBox(
                                        width: double.infinity,
                                        height: 44.0,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            logFirebaseEvent(
                                                'REGISTER_UNI_CREATE_ACCOUNT_BTN_ON_TAP');
                                            logFirebaseEvent('Button_auth');
                                            GoRouter.of(context)
                                                .prepareAuthEvent();

                                            // Validate fields
                                            if (_model
                                                    .emailAddressTextController
                                                    .text
                                                    .isEmpty ||
                                                _model.passwordTextController
                                                    .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please fill in all required fields'),
                                                ),
                                              );
                                              return;
                                            }

                                            final user = await authManager
                                                .createAccountWithEmail(
                                              context,
                                              _model
                                                  .emailAddressTextController
                                                  .text,
                                              _model
                                                  .passwordTextController.text,
                                            );
                                            if (user == null) {
                                              return;
                                            }

                                            // Combine first + last name for displayName
                                            final displayName =
                                                '${_model.firstNameTextController.text} ${_model.lastNameTextController.text}'
                                                    .trim();

                                            await UserRecord.collection
                                                .doc(user.uid)
                                                .update(createUserRecordData(
                                              createdTime:
                                                  getCurrentTimestamp,
                                              role: 'Owner',
                                              displayName:
                                                  displayName.isNotEmpty
                                                      ? displayName
                                                      : null,
                                              email: _model
                                                  .emailAddressTextController
                                                  .text,
                                            ));

                                            logFirebaseEvent(
                                                'Button_backend_call');

                                            await currentUserReference!
                                                .update(createUserRecordData(
                                              email: _model
                                                  .emailAddressTextController
                                                  .text,
                                              displayName:
                                                  displayName.isNotEmpty
                                                      ? displayName
                                                      : null,
                                            ));

                                            logFirebaseEvent(
                                                'Button_bottom_sheet');
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return WebViewAware(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      FocusManager.instance
                                                          .primaryFocus
                                                          ?.unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery
                                                          .viewInsetsOf(
                                                              context),
                                                      child: SuccessWidget(),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ).then((value) =>
                                                safeSetState(() {}));

                                            context.goNamedAuth(
                                                WelcomeWidget.routeName,
                                                context.mounted);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _primaryBlue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      9999.0),
                                            ),
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      9999.0),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  _primaryBlue,
                                                  _primaryBlue,
                                                ],
                                              ),
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                  letterSpacing: -0.01,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── Already have an account? Log in here ──
                                      Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'REGISTER_UNI_LOGIN_LINK_ON_TAP');
                                            logFirebaseEvent(
                                                'RichText_navigate_to');
                                            context.goNamed(
                                                LoginUniWidget.routeName);
                                          },
                                          child: RichText(
                                            textScaler: MediaQuery.of(context)
                                                .textScaler,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                      'Already have an account? ',
                                                  style: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.5,
                                                    color: _onSurfaceVariant,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: 'Log in here',
                                                  style: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5,
                                                    color: _primaryDeep,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        _primaryDeep,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

/// Custom painter for the Google "G" logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Blue segment (top-right)
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.15, // start angle (≈ -8.6°)
      1.45, // sweep angle (≈ 83°)
      false,
      bluePaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.38,
    );

    // Red segment (top-left)
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.99, // start angle (≈ 171°)
      0.75, // sweep
      false,
      redPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.38,
    );

    // Yellow segment (left)
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.2, // start angle
      0.8, // sweep
      false,
      yellowPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.38,
    );

    // Green segment (bottom)
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.82, // start angle
      1.38, // sweep
      false,
      greenPaint..style = PaintingStyle.stroke..strokeWidth = radius * 0.38,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
