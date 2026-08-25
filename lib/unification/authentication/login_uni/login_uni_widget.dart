import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/google_auth.dart' as google_auth;
import '/auth/auth_session_preferences.dart';
import '/backend/backend.dart';
import '/rbac/rbac.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/components/pulse_logo_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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

  /// Cinematic heartbeat film (Remotion-rendered) behind the auth card.
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  static const Color _primary = Color(0xFFA100FF);
  static const Color _text = Color(0xFF162033);
  static const Color _muted = Color(0xFF5B6478);
  static const Color _line = Color(0xFFD8DCE2);
  static const Color _ink = Color(0xFF07070B);

  Widget _buildBrandLogo({double size = 44.0}) {
    return PulseLogoWidget(
      size: size,
      showWordmark: true,
      color: _primary,
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

    _restoreRememberedLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Ambient heartbeat film — muted, looping, resilient to failure.
    _videoController = VideoPlayerController.asset(
      'assets/videos/pulse_hero_bg.mp4',
    )
      ..setLooping(true)
      ..setVolume(0.0);
    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() => _videoInitialized = true);
      _videoController.play();
    }).catchError((_) {
      // Film unavailable — deep-ink gradient fallback remains.
    });
  }

  Future<void> _restoreRememberedLogin() async {
    final preferences = AuthSessionPreferences.instance;
    await preferences.initialize();
    if (!mounted || !preferences.rememberSession) return;

    final email = preferences.rememberedEmail;
    final mode = preferences.rememberedLoginMode;
    safeSetState(() {
      _model.rememberMe = true;
      if (email.isNotEmpty) {
        _model.emailAddressTextController?.text = email;
      }
      _selectedMode = mode == 1 ? 1 : 0;
    });
  }

  /// Firebase Auth provides LOCAL and SESSION persistence on web. Native
  /// clients are cleared on the next cold start in main.dart when the user
  /// did not opt in to being remembered.
  Future<bool> _applySessionPersistence() async {
    if (!kIsWeb) return true;

    try {
      await FirebaseAuth.instance.setPersistence(
        _model.rememberMe ? Persistence.LOCAL : Persistence.SESSION,
      );
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to set the requested session preference.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _saveSessionPreference(String email) {
    return AuthSessionPreferences.instance.save(
      rememberSession: _model.rememberMe,
      email: email,
      loginMode: _selectedMode,
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _showEmailVerificationRequiredDialog(String email) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return WebViewAware(
          child: AlertDialog(
            title: const Text('Verify your email'),
            content: Text(
              'Your account is not verified yet. We can resend the verification email to $email if needed.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await authManager.sendEmailVerification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email sent.'),
                    ),
                  );
                  Navigator.pop(alertDialogContext);
                },
                child: const Text('Resend'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Full-bleed cinematic backdrop: deep-ink gradient, the heartbeat
  /// film (when ready), and a gentle vignette that frames the card.
  Widget _buildFilmBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B0B12), Color(0xFF07070B), Color(0xFF050508)],
            ),
          ),
        ),
        if (_videoInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          ),
        // Cinematic vignette — melts the film edges into the ink.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.25,
              colors: [
                Colors.transparent,
                _ink.withValues(alpha: 0.0),
                _ink.withValues(alpha: 0.62),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Pulse',
      color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _ink,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Cinematic heartbeat film backdrop.
              _buildFilmBackground(),
              // Auth surface.
              SafeArea(
                top: true,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 26.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28.0,
                          vertical: 34.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            // Brand glow — the card breathes purple.
                            BoxShadow(
                              color: const Color(0xFF9900FF).withValues(
                                alpha: 0.20,
                              ),
                              blurRadius: 70.0,
                              offset: const Offset(0, 26.0),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 40.0,
                              offset: const Offset(0, 12.0),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildBrandLogo(size: 88.0),
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
                                label: 'Pulse',
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
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(8.0),
                            onTap: () => safeSetState(
                              () => _model.rememberMe = !_model.rememberMe,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 2.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _model.rememberMe,
                                    onChanged: (value) => safeSetState(
                                      () => _model.rememberMe = value ?? false,
                                    ),
                                    activeColor: _primary,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    'Remember me',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: FlutterFlowTheme.of(context)
                                              .bodyMediumFamily,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF4B5563),
                                          useGoogleFonts: !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
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
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: FFButtonWidget(
                          onPressed: () async {
                            logFirebaseEvent(
                                'LOGIN_UNI_PAGE_SIGN_IN_BTN_ON_TAP');

                            // ───────────────────────────────────────────────
                            //  unified email/password sign-in
                            //
                            // Both the Pulse and Pharmacy tabs now flow
                            // through the SAME Firebase Auth path. The
                            // account-type validation block further down
                            // ensures a Pulse user can't log in via the
                            // Pharmacy tab (and vice-versa) by signing them
                            // out and surfacing a clear message.
                            //
                            // NOTE: the previous implementation queried the
                            // `Staff` and `User` Firestore collections
                            // BEFORE authentication. The Firestore rules
                            // (`firebase/firestore.rules` lines 47-51 and
                            // 228-231) require `signedIn()` for both — so
                            // unauthenticated queries returned 0/false and
                            // the Pharmacy path silently aborted with a
                            // generic "Error / Try Again" dialog before
                            // ever reaching Firebase Auth. That is why
                            // users could not sign in on the Pharmacy tab.
                            // ───────────────────────────────────────────────

                            // Basic empty-field guard — Firebase Auth will
                            // surface its own error message if the credentials
                            // are wrong, so we don't replicate that here.
                            final emailInput = _model
                                .emailAddressTextController.text
                                .trim();
                            final passwordInput =
                                _model.passwordTextController.text;
                            if (emailInput.isEmpty ||
                                passwordInput.isEmpty) {
                              await showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return WebViewAware(
                                    child: AlertDialog(
                                      title: const Text('Missing details'),
                                      content: const Text(
                                          'Please enter both your email and password to continue.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                                color: _primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                              return;
                            }

                            logFirebaseEvent('Button_auth');
                            if (!await _applySessionPersistence()) return;
                            GoRouter.of(context).prepareAuthEvent();
                            final user = await authManager.signInWithEmail(
                              context,
                              emailInput,
                              passwordInput,
                            );
                            if (user == null) {
                              // Firebase Auth failed — `_signInOrCreateAccount`
                              // already surfaced the specific error message via
                              // a SnackBar (e.g. "INVALID_LOGIN_CREDENTIALS"
                              // → "The supplied auth credential is
                              // incorrect, malformed or has expired").
                              //
                              // For the Pharmacy tab specifically, if the
                              // error code indicates the email is not a
                              // registered Firebase user, surface a clearer
                              // dialog guiding them to contact their
                              // pharmacy owner to complete onboarding.
                              if (_selectedMode == 1 && mounted) {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return WebViewAware(
                                      child: AlertDialog(
                                        title: const Text(
                                            'Unable to sign in'),
                                        content: const Text(
                                            'We could not sign you in with those credentials. If you are a pharmacy staff member who has not yet completed account setup, please ask your pharmacy owner to resend your invitation, or use the Pulse tab if this is a Pulse network account.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: _primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                              return;
                            }

                            try {
                              await authManager.refreshUser();
                            } catch (_) {}
                            final isEmailVerified =
                                currentUserEmailVerified || user.emailVerified;
                            if (!isEmailVerified) {
                              await _showEmailVerificationRequiredDialog(
                                _model.emailAddressTextController.text,
                              );
                              await authManager.signOut();
                              return;
                            }

                            // ═══════════════════════════════════════════════
                            //   ACCOUNT TYPE VALIDATION
                            //   Ensure a user can't sign in with the wrong
                            //   account type. If their stored account_type
                            //   doesn't match the selected toggle, sign
                            //   them out and show an error.
                            // ═══════════════════════════════════════════════
                            try {
                              final userDoc = await UserRecord.getDocumentOnce(
                                UserRecord.collection.doc(user.uid),
                              );
                              final selectedAccountType =
                                  _selectedMode == 0 ? 'Pulse' : 'Pharmacy';
                              final storedAccountType = userDoc.accountType
                                      .trim()
                                      .isNotEmpty
                                  ? userDoc.accountType.trim()
                                  : (AppRole.fromFirestoreValue(userDoc.role)
                                          .isPulseRole
                                      ? 'Pulse'
                                      : 'Pharmacy');

                              if (storedAccountType.toLowerCase() !=
                                  selectedAccountType.toLowerCase()) {
                                // Wrong account type — sign out and inform user
                                await authManager.signOut();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error_outline_rounded,
                                            color: Colors.white, size: 18.0),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            'This account is registered as "$storedAccountType". '
                                            'Please select the "$storedAccountType" tab and try again.',
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    margin: const EdgeInsets.all(16.0),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                                return;
                              }
                            } catch (e) {
                              // If we can't read the user doc, allow login
                              // (don't block users due to a transient error)
                              debugPrint(
                                  '[login_uni] Account type check failed: $e');
                            }

                            await _saveSessionPreference(user.email ?? emailInput);

                            logFirebaseEvent('Button_navigate_to');
                            context.goNamedAuth(
                              HomeWidget.routeName,
                              context.mounted,
                            );
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
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
                            if (!await _applySessionPersistence()) return;
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
                                          role: _selectedMode == 0
                                              ? AppRole
                                                  .pulseAdmin.firestoreValue
                                              : AppRole.owner.firestoreValue,
                                          accountType: _selectedMode == 0
                                              ? AppRole
                                                  .pulseAdmin.accountTypeValue
                                              : AppRole.owner.accountTypeValue,
                                        ));
                                  } else {
                                    // ═══════════════════════════════════════
                                    //   ACCOUNT TYPE VALIDATION (Google)
                                    //   For existing users, verify the
                                    //   selected tab matches their stored
                                    //   account_type. If not, sign out and
                                    //   inform them.
                                    // ═══════════════════════════════════════
                                    final selectedAccountType =
                                        _selectedMode == 0
                                            ? 'Pulse'
                                            : 'Pharmacy';
                                    final storedAccountType =
                                        userDoc.accountType.isNotEmpty
                                            ? userDoc.accountType
                                            : 'Pulse';

                                    if (storedAccountType !=
                                        selectedAccountType) {
                                      await authManager.signOut();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                    Icons.error_outline_rounded,
                                                    color: Colors.white,
                                                    size: 18.0),
                                                const SizedBox(width: 8.0),
                                                Expanded(
                                                  child: Text(
                                                    'This account is registered as "$storedAccountType". '
                                                    'Please select the "$storedAccountType" tab and try again.',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor:
                                                const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            margin: const EdgeInsets.all(16.0),
                                            duration:
                                                const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                  }

                                  await _saveSessionPreference(user.email ?? '');

                                  if (context.mounted) {
                                    context.goNamedAuth(WelcomeWidget.routeName,
                                        context.mounted);
                                  }
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google sign in failed: $e'),
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
                                  fontFamily: kAppFontFamily,
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
                      const SizedBox(height: 34.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
