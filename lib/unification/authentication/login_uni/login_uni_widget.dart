import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/google_auth.dart' as google_auth;
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'login_uni_model.dart';
export 'login_uni_model.dart';

class LoginUniWidget extends StatefulWidget {
  const LoginUniWidget({super.key});

  static String routeName = 'LoginUni';
  static String routePath = '/loginUni';

  @override
  State<LoginUniWidget> createState() => _LoginUniWidgetState();
}

class _LoginUniWidgetState extends State<LoginUniWidget> {
  late LoginUniModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedMode = 0;

  static const Color _primary = Color(0xFFA100FF);
  static const Color _text = Color(0xFF162033);
  static const Color _muted = Color(0xFF5B6478);
  static const Color _line = Color(0xFFD8DCE2);

  Widget _buildBrandLogo({double size = 44.0}) {
    return Image.asset(
      'assets/images/duniya_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: Image.asset(
        'assets/images/google_icon.png',
        width: 20.0,
        height: 20.0,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 48.0,
        decoration: BoxDecoration(
          color: selected ? _primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.28),
                    blurRadius: 12.0,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                icon,
                size: 20.0,
                color: selected ? Colors.white : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                    color: selected ? Colors.white : const Color(0xFF4B5563),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginUniModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'LoginUni'});
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

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Duniya',
      color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            top: true,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18.0,
                  vertical: 18.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 48.0),
                      _buildBrandLogo(size: 72.0),
                      const SizedBox(height: 24.0),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .displaySmallFamily,
                                  fontSize: 34.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.03,
                                  color: _text,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .displaySmallIsCustom,
                                ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        "Let's get started by filling out the form below.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          fontSize: 14.0,
                          height: 1.4,
                          color: _muted,
                          letterSpacing: 0.0,
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F6),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildModeTab(
                                label: 'Duniya',
                                icon: Icons.person_outline_rounded,
                                selected: _selectedMode == 0,
                                onTap: () =>
                                    safeSetState(() => _selectedMode = 0),
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: _buildModeTab(
                                label: 'Pharmacy',
                                icon: Icons.local_pharmacy_outlined,
                                selected: _selectedMode == 1,
                                onTap: () =>
                                    safeSetState(() => _selectedMode = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: TextFormField(
                          controller: _model.emailAddressTextController,
                          focusNode: _model.emailAddressFocusNode,
                          autofocus: false,
                          obscureText: false,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 14.0,
                                  color: _text,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _line.withValues(alpha: 0.9),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: _primary,
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 14.0,
                                color: _text,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                          validator: _model.emailAddressTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: TextFormField(
                          controller: _model.passwordTextController,
                          focusNode: _model.passwordFocusNode,
                          autofocus: false,
                          obscureText: !_model.passwordVisibility,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 14.0,
                                  color: _text,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _line.withValues(alpha: 0.9),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: _primary,
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _model.passwordVisibility
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF7A8190),
                              ),
                              onPressed: () => safeSetState(
                                () => _model.passwordVisibility =
                                    !_model.passwordVisibility,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                fontSize: 14.0,
                                color: _text,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                          validator: _model.passwordTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              ResetPasswordUniWidget.routeName,
                              extra: <String, dynamic>{
                                '__transition_info__': TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              'Forgot Password',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF6B7280),
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'LOGIN_UNI_PAGE_SIGN_IN_BTN_ON_TAP');
                            var _shouldSetState = false;

                            logFirebaseEvent('Button_firestore_query');
                            _model.tuk = await queryStaffRecordOnce(
                              queryBuilder: (staffRecord) => staffRecord.where(
                                'Email',
                                isEqualTo:
                                    _model.emailAddressTextController.text,
                              ),
                              singleRecord: true,
                            ).then((s) => s.firstOrNull);
                            _shouldSetState = true;
                            logFirebaseEvent('Button_firestore_query');
                            _model.staff = await queryStaffRecordCount(
                              queryBuilder: (staffRecord) => staffRecord.where(
                                'Email',
                                isEqualTo:
                                    _model.emailAddressTextController.text,
                              ),
                            );
                            _shouldSetState = true;
                            if (_model.staff == 0) {
                              logFirebaseEvent('Button_firestore_query');
                              _model.usercheak = await queryUserRecordCount(
                                queryBuilder: (userRecord) => userRecord
                                    .where(
                                      'email',
                                      isEqualTo: _model
                                          .emailAddressTextController.text,
                                    )
                                    .where(
                                      'role',
                                      isEqualTo: 'Owner',
                                    ),
                              );
                              _shouldSetState = true;
                              if (_model.usercheak.toString() == '0') {
                                logFirebaseEvent('Button_alert_dialog');
                                await showDialog(
                                  context: context,
                                  builder: (alertDialogContext) {
                                    return WebViewAware(
                                      child: AlertDialog(
                                        title: Text('Error '),
                                        content: Text('Try Again'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                alertDialogContext),
                                            child: Text('Ok'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              }
                            } else {
                              logFirebaseEvent('Button_firestore_query');
                              _model.user = await queryUserRecordCount(
                                queryBuilder: (userRecord) => userRecord.where(
                                  'email',
                                  isEqualTo:
                                      _model.emailAddressTextController.text,
                                ),
                              );
                              _shouldSetState = true;
                              logFirebaseEvent('Button_firestore_query');
                              _model.pcheck = await queryStaffRecordOnce(
                                queryBuilder: (staffRecord) =>
                                    staffRecord.where(
                                  'Email',
                                  isEqualTo:
                                      _model.emailAddressTextController.text,
                                ),
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);
                              _shouldSetState = true;
                              if (_model.user == 0) {
                                if (_model.passwordTextController.text ==
                                    _model.pcheck?.password) {
                                  logFirebaseEvent('Button_navigate_to');
                                  context.pushNamedAuth(
                                    StaffRegisterWidget.routeName,
                                    context.mounted,
                                    queryParameters: {
                                      'staffId': serializeParam(
                                        _model.tuk?.reference,
                                        ParamType.DocumentReference,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  logFirebaseEvent('Button_alert_dialog');
                                  await showDialog(
                                    context: context,
                                    builder: (alertDialogContext) {
                                      return WebViewAware(
                                        child: AlertDialog(
                                          title: Text('Wrong Password'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              } else {
                                if (_model.passwordTextController.text ==
                                    _model.pcheck?.password) {
                                  logFirebaseEvent('Button_navigate_to');
                                  context.pushNamedAuth(
                                    StaffLoginWidget.routeName,
                                    context.mounted,
                                    queryParameters: {
                                      'staffId': serializeParam(
                                        _model.tuk?.reference,
                                        ParamType.DocumentReference,
                                      ),
                                    }.withoutNulls,
                                  );
                                } else {
                                  logFirebaseEvent('Button_alert_dialog');
                                  await showDialog(
                                    context: context,
                                    builder: (alertDialogContext) {
                                      return WebViewAware(
                                        child: AlertDialog(
                                          title: Text('Wrong Password'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext),
                                              child: Text('Ok'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              }
                              if (_shouldSetState) safeSetState(() {});
                              return;
                            }

                            logFirebaseEvent('Button_auth');
                            GoRouter.of(context).prepareAuthEvent();
                            final user = await authManager.signInWithEmail(
                              context,
                              _model.emailAddressTextController.text,
                              _model.passwordTextController.text,
                            );
                            if (user == null) {
                              return;
                            }
                            logFirebaseEvent('Button_navigate_to');
                            context.goNamedAuth(
                                WelcomeWidget.routeName, context.mounted);
                            if (_shouldSetState) safeSetState(() {});
                          },
                          text: 'Sign In',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 52.0,
                            padding: EdgeInsets.zero,
                            iconPadding: EdgeInsets.zero,
                            color: _primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleSmallIsCustom,
                                ),
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22.0),

                      // ── OR Divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: _line.withValues(alpha: 0.5),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.12,
                                color: _muted.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: _line.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18.0),

                      // ── Google Sign In Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: OutlinedButton(
                          onPressed: () async {
                            logFirebaseEvent(
                                'LOGIN_UNI_GOOGLE_SIGN_IN_BTN_ON_TAP');
                            logFirebaseEvent('Button_auth');
                            GoRouter.of(context).prepareAuthEvent();
                            try {
                              final userCredential =
                                  await google_auth.googleSignInFunc();
                              if (userCredential != null) {
                                final user = userCredential.user;
                                if (user != null) {
                                  // Check if user doc exists, create if not
                                  final userDoc =
                                      await UserRecord.getDocumentOnce(
                                    UserRecord.collection.doc(user.uid),
                                  );
                                  if (!userDoc.hasRole()) {
                                    await UserRecord.collection
                                        .doc(user.uid)
                                        .set(createUserRecordData(
                                          email: user.email,
                                          displayName: user.displayName,
                                          photoUrl: user.photoURL,
                                          uid: user.uid,
                                          createdTime: getCurrentTimestamp,
                                          role: 'Owner',
                                        ));
                                  }

                                  if (context.mounted) {
                                    context.goNamedAuth(
                                        WelcomeWidget.routeName,
                                        context.mounted);
                                  }
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Google sign in failed: $e'),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: _line.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildGoogleLogo(),
                              const SizedBox(width: 10.0),
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                  letterSpacing: -0.01,
                                  color: _text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18.0),
                      if (kDebugMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: const Color(0xFFE9D5FF),
                              ),
                            ),
                            child: Text(
                              'Use your real pharmacy credentials to continue.',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    color: const Color(0xFF6D28D9),
                                    fontWeight: FontWeight.w600,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  fontSize: 14.0,
                                  color: _text,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                          InkWell(
                            onTap: () async {
                              context.goNamed(RegisterUniWidget.routeName);
                            },
                            child: Text(
                              'Register',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: _primary,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0),
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
