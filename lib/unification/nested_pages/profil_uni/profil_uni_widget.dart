import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/profile_image/profile_image_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'profil_uni_model.dart';
export 'profil_uni_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   PROFILE — Account overview
///
///   World-class redesign:
///   • Brand gradient hero with the avatar ringed in white, the
///     member's name, email and live status chips (email verification,
///     role, membership year) — no more stock banner illustration.
///   • Account details card with stacked-label fields, leading icons
///     and a clear read-only vs editable distinction. The phone
///     number is actually SAVABLE now (persists to the user record)
///     with a dirty-aware Save button — previously the form was
///     decorative.
///   • Logout moved to a de-emphasized outlined destructive action
///     with a confirmation dialog, instead of a big black button that
///     read like the primary form action.
/// ═══════════════════════════════════════════════════════════════
class ProfilUniWidget extends StatefulWidget {
  const ProfilUniWidget({super.key});

  static String routeName = 'ProfilUni';
  static String routePath = '/profilUni';

  @override
  State<ProfilUniWidget> createState() => _ProfilUniWidgetState();
}

class _ProfilUniWidgetState extends State<ProfilUniWidget> {
  late ProfilUniModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Brand tokens (consistent with the app's other redesigned pages).
  static const Color _purple = Color(0xFF9900FF);
  static const Color _purpleDark = Color(0xFF7C3AED);
  static const Color _purpleDeep = Color(0xFF6D28D9);

  // Phone editing state.
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _phoneLoaded = false;
  String _originalPhone = '';
  bool _savingPhone = false;

  bool get _phoneDirty {
    final v = _phoneController.text.trim();
    return _phoneLoaded && v != _originalPhone;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilUniModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'ProfilUni'});

    // Seed the phone field from the current user document (the
    // stream widget re-syncs it after the first frame if the doc was
    // still loading at boot).
    _originalPhone = currentPhoneNumber;
    _phoneController.text = _originalPhone;
    if (_originalPhone.isNotEmpty) _phoneLoaded = true;

    _phoneController.addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    _model.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────

  Future<void> _savePhoneNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone == _originalPhone) return;
    final userDoc = currentUserDocument;
    if (userDoc == null) {
      _toast('Your profile could not be found. Please sign in again.',
          isError: true);
      return;
    }

    safeSetState(() => _savingPhone = true);
    try {
      await userDoc.reference
          .update(createUserRecordData(phoneNumber: phone));
      _originalPhone = phone;
      _phoneLoaded = true;
      if (!mounted) return;
      safeSetState(() => _savingPhone = false);
      _toast('Phone number updated');
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _savingPhone = false);
      _toast('Could not update the phone number. Please try again.',
          isError: true);
    }
  }

  void _toast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError ? Icons.error_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : _purple,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out of Pulse?'),
        content: const Text(
            'You will need to sign in again to access your pharmacies and inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    GoRouter.of(context).prepareAuthEvent();
    await authManager.signOut();
    GoRouter.of(context).clearRedirectLocation();
    if (!mounted) return;
    context.goNamedAuth(LoginUniWidget.routeName, context.mounted);
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Title(
      title: 'Profile',
      color: theme.primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
          appBar: responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false,
          )
              ? AppBar(
                  backgroundColor: theme.secondaryBackground,
                  automaticallyImplyLeading: false,
                  leading: FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    borderWidth: 1.0,
                    buttonSize: 60.0,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: theme.secondary,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      logFirebaseEvent(
                          'PROFIL_UNI_chevron_left_rounded_ICN_ON_T');
                      context.pop();
                    },
                  ),
                  title: Text(
                    'Profile',
                    style:
                        theme.headlineMedium.override(
                      fontFamily: theme.headlineMediumFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineMediumIsCustom,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0.0,
                )
              : null,
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
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
                Expanded(
                  child: AuthUserStreamWidget(
                    builder: (context) {
                      // Sync the phone field once the user stream is
                      // live (covers the boot race where the document
                      // had not loaded in initState).
                      if (!_phoneLoaded &&
                          currentPhoneNumber.isNotEmpty) {
                        _originalPhone = currentPhoneNumber;
                        _phoneController.text = _originalPhone;
                        _phoneLoaded = true;
                      }

                      final userDoc = currentUserDocument;
                      final roleLabel = _roleLabel(userDoc?.role ?? '');
                      final accountType = (userDoc?.accountType ?? '').trim();
                      final memberSince = userDoc?.createdTime;

                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHero(
                              theme,
                              roleLabel: roleLabel,
                              accountType: accountType,
                              memberSince: memberSince,
                            ),
                            // Content column.
                            Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 780),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      24, 28, 24, 40),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildAccountCard(theme),
                                      const SizedBox(height: 18),
                                      _buildSessionCard(theme),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  static String _roleLabel(String role) {
    final normalized = role.toLowerCase().replaceAll('_', ' ').trim();
    if (normalized.isEmpty) return '';
    return normalized
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ── Hero ──────────────────────────────────────────────────────

  Widget _buildHero(
    FlutterFlowTheme theme, {
    required String roleLabel,
    required String accountType,
    DateTime? memberSince,
  }) {
    Widget chip({
      required IconData icon,
      required String label,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(38),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: color.withAlpha(96), width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ]),
      );
    }

    final verified = currentUserEmailVerified;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_purpleDark, _purple, _purpleDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 40),
          child: Column(
            children: [
              // Avatar with ring + glow.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: wrapWithModel(
                  model: _model.profileImageModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const ProfileImageWidget(radius: 76.0),
                ),
              ),
              const SizedBox(height: 18),
              // Name + email.
              Text(
                currentUserDisplayName.isNotEmpty
                    ? currentUserDisplayName
                    : 'Pulse Member',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                currentUserEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(220),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              // Status chips.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (verified)
                    chip(
                      icon: Icons.verified_rounded,
                      label: 'Email verified',
                      color: const Color(0xFF6EE7B7),
                    )
                  else
                    chip(
                      icon: Icons.mark_email_unread_rounded,
                      label: 'Email not verified',
                      color: const Color(0xFFFDE047),
                    ),
                  if (accountType.isNotEmpty)
                    chip(
                      icon: Icons.workspace_premium_rounded,
                      label: accountType,
                      color: const Color(0xFFC77DFF),
                    ),
                  if (roleLabel.isNotEmpty)
                    chip(
                      icon: Icons.badge_rounded,
                      label: roleLabel,
                      color: const Color(0xFF93C5FD),
                    ),
                  if (memberSince != null)
                    chip(
                      icon: Icons.calendar_month_rounded,
                      label: 'Member since ${memberSince.year}',
                      color: const Color(0xFFFDBA74),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Account details card ──────────────────────────────────────

  Widget _buildAccountCard(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _purple.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded,
                  color: _purple, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account details',
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.2,
                      color: theme.primaryText,
                      useGoogleFonts: !theme.titleMediumIsCustom,
                    ),
                  ),
                  Text(
                    'Your name and email come from your sign-in provider. Update your phone number here.',
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
          ]),
          const SizedBox(height: 22),

          // Name (read-only).
          _field(
            theme,
            icon: Icons.person_outline_rounded,
            label: 'Full Name',
            value: currentUserDisplayName,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Email (read-only).
          _field(
            theme,
            icon: Icons.mail_outline_rounded,
            label: 'Email Address',
            value: currentUserEmail,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // Phone (editable).
          _phoneField(theme),
          const SizedBox(height: 22),

          // Save action.
          Row(children: [
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _phoneDirty ? 1.0 : 0.45,
                child: FFButtonWidget(
                  onPressed:
                      (_phoneDirty && !_savingPhone) ? _savePhoneNumber : null,
                  text: _savingPhone ? 'Saving…' : 'Save Phone Number',
                  icon: Icon(
                    _savingPhone ? null : Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  options: FFButtonOptions(
                    height: 48,
                    color: _purple,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ]),
          if (_phoneDirty && !_savingPhone)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 2),
              child: Text(
                'Unsaved change — tap Save to update your phone number.',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: const Color(0xFFF59E0B),
                  fontSize: 12,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String label,
    required String value,
    required bool readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.labelMedium.override(
            fontFamily: theme.labelMediumFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            letterSpacing: 0.3,
            color: theme.secondaryText,
            useGoogleFonts: !theme.labelMediumIsCustom,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: readOnly
                ? theme.primaryBackground
                : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate),
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(icon, size: 19, color: theme.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : '—',
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 14.5,
                  fontWeight: readOnly ? FontWeight.w500 : FontWeight.w600,
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (readOnly) ...[
              const SizedBox(width: 10),
              Icon(Icons.lock_outline_rounded,
                  size: 15, color: theme.secondaryText.withAlpha(140)),
            ],
            const SizedBox(width: 14),
          ]),
        ),
      ],
    );
  }

  Widget _phoneField(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: theme.labelMedium.override(
            fontFamily: theme.labelMediumFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            letterSpacing: 0.3,
            color: theme.secondaryText,
            useGoogleFonts: !theme.labelMediumIsCustom,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _phoneDirty ? _purple : theme.alternate,
              width: _phoneDirty ? 1.6 : 1.0,
            ),
            boxShadow: _phoneDirty
                ? [
                    BoxShadow(
                      color: _purple.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(children: [
            const SizedBox(width: 14),
            Icon(Icons.phone_iphone_rounded,
                size: 19, color: _phoneDirty ? _purple : theme.secondaryText),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    fontSize: 14,
                    color: theme.secondaryText.withAlpha(160),
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_phoneDirty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    _phoneController.text = _originalPhone;
                    FocusScope.of(context).unfocus();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 15, color: theme.secondaryText),
                  ),
                ),
              )
            else
              const SizedBox(width: 14),
          ]),
        ),
      ],
    );
  }

  // ── Session card ──────────────────────────────────────────────

  Widget _buildSessionCard(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFEF4444), size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session',
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.2,
                      color: theme.primaryText,
                      useGoogleFonts: !theme.titleMediumIsCustom,
                    ),
                  ),
                  Text(
                    'Sign out on this device. Your data stays safely in sync.',
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
          ]),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.power_settings_new_rounded, size: 18),
              label: const Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
