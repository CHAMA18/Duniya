import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/google_auth.dart' as google_auth;
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/success/success_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  int _selectedMode = 0;

  // Design tokens from the HTML source
  static const Color _primaryBlue = Color(0xFFA100FF);
  static const Color _primaryDeep = Color(0xFF6A00D9);
  static const Color _surfaceContainerHigh = Color(0xFFE9E6FF);
  static const Color _onSurface = Color(0xFF162033);
  static const Color _onSurfaceVariant = Color(0xFF5B6478);
  static const Color _outline = Color(0xFF8A91A6);
  static const Color _outlineVariant = Color(0xFFE5E7F0);
  static const Color _inversePrimary = Color(0xFFF2EDFF);
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

    _videoController = VideoPlayerController.asset(
      'assets/videos/medicine_bg.mp4',
    )
      ..setLooping(true)
      ..setVolume(0.0);
    _videoController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _videoInitialized = true;
      });
      _videoController.play();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _videoController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _showEmailVerificationSentDialog(String email) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return WebViewAware(
          child: AlertDialog(
            title: const Text('Verify your email'),
            content: Text(
              'We sent a verification email to $email. Please verify your inbox before logging in.',
            ),
            actions: [
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

  /// Builds the Google logo from the uploaded asset
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

  Widget _buildBrandLogo({double size = 44.0}) {
    return Image.asset(
      'assets/images/duniya_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
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
          color: selected ? _primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.28),
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
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Title(
      title: 'Duniya',
      color: _primaryDeep,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final leftWidth = isDesktop ? constraints.maxWidth * 0.31 : 0.0;
                return SizedBox.expand(
                  child: Row(
                    children: [
                      if (isDesktop)
                        SizedBox(
                          width: leftWidth,
                          child: ClipRect(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_videoInitialized)
                                  Positioned.fill(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: SizedBox(
                                        width:
                                            _videoController.value.size.width,
                                        height:
                                            _videoController.value.size.height,
                                        child: VideoPlayer(_videoController),
                                      ),
                                    ),
                                  )
                                else
                                  Container(color: _primaryDeep),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        _primaryBlue.withValues(alpha: 0.46),
                                        _primaryDeep.withValues(alpha: 0.50),
                                        const Color(0xFF133FE1)
                                            .withValues(alpha: 0.56),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      48.0, 56.0, 48.0, 42.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Duniya',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.02,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Join the Global Standard',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 34.0,
                                              fontWeight: FontWeight.w600,
                                              height: 1.15,
                                              letterSpacing: -0.03,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 18.0),
                                          Text(
                                            'Pharmacy management has never been so easy. Track inventory, monitor staff and care for your patients all in one place.',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w400,
                                              height: 1.65,
                                              color: Colors.white
                                                  .withValues(alpha: 0.88),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18.0, vertical: 12.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.09),
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.14),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shield_outlined,
                                              color: Colors.white
                                                  .withValues(alpha: 0.88),
                                              size: 18.0,
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(
                                              'HIPAA Compliant  •  Bank-Level Security',
                                              style: TextStyle(
                                                fontFamily: 'Satoshi',
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.0,
                                                color: Colors.white
                                                    .withValues(alpha: 0.9),
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
                          ),
                        ),

                      // ── Right Side: Form Content ──
                      Expanded(
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
                                  color: _surfaceContainerHigh.withValues(
                                      alpha: 0.3),
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
                                  color: _inversePrimary.withValues(alpha: 0.2),
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
                                      const BoxConstraints(maxWidth: 560.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: _buildBrandLogo(
                                          size: isDesktop ? 144.0 : 112.0,
                                        ),
                                      ),
                                      const SizedBox(height: 28.0),

                                      Center(
                                        child: Text(
                                          'Create your account',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: isDesktop ? 34.0 : 26.0,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                            letterSpacing: -0.03,
                                            color: _onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Center(
                                        child: Text(
                                          'Enter your professional details to access the command center.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: isDesktop ? 18.0 : 15.0,
                                            fontWeight: FontWeight.w400,
                                            height: 1.6,
                                            color: _onSurfaceVariant,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24.0),

                                      Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F2F6),
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildModeTab(
                                                label: 'Duniya',
                                                icon: Icons
                                                    .person_outline_rounded,
                                                selected: _selectedMode == 0,
                                                onTap: () => safeSetState(
                                                  () => _selectedMode = 0,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Expanded(
                                              child: _buildModeTab(
                                                label: 'Pharmacy',
                                                icon: Icons
                                                    .local_pharmacy_outlined,
                                                selected: _selectedMode == 1,
                                                onTap: () => safeSetState(
                                                  () => _selectedMode = 1,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                                      accountType:
                                                          _selectedMode == 0
                                                              ? 'Duniya'
                                                              : 'Pharmacy',
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
                                                        WelcomeWidget.routeName,
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
                                              color: _outlineVariant.withValues(
                                                  alpha: 0.5),
                                              width: 1.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9999.0),
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
                                              color: _outlineVariant.withValues(
                                                  alpha: 0.3),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                              color: _outlineVariant.withValues(
                                                  alpha: 0.3),
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
                                        controller:
                                            _model.emailAddressTextController!,
                                        focusNode:
                                            _model.emailAddressFocusNode!,
                                        label: 'Professional Email',
                                        placeholder:
                                            'sarah.chen@apexhealth.com',
                                        prefixIcon: Icons.mail_outline,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (context, value) {
                                          if (value == null || value.isEmpty) {
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
                                        obscureText: !_model.passwordVisibility,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _model.passwordVisibility
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 18.0,
                                            color: _outline,
                                          ),
                                          onPressed: () {
                                            safeSetState(() =>
                                                _model.passwordVisibility =
                                                    !_model.passwordVisibility);
                                          },
                                        ),
                                        validator: (context, value) {
                                          if (value == null || value.isEmpty) {
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
                                              _model.emailAddressTextController
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
                                                  accountType:
                                                      _selectedMode == 0
                                                          ? 'Duniya'
                                                          : 'Pharmacy',
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

                                            await authManager
                                                .sendEmailVerification();
                                            await _showEmailVerificationSentDialog(
                                              _model.emailAddressTextController.text,
                                            );
                                            await authManager.signOut();
                                            if (!context.mounted) {
                                              return;
                                            }
                                            context.goNamed(
                                                LoginUniWidget.routeName);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _primaryBlue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(9999.0),
                                            ),
                                            shadowColor: Colors.transparent,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(9999.0),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
