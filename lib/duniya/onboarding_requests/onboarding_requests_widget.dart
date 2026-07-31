import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'onboarding_requests_model.dart';
export 'onboarding_requests_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — ONBOARDING REQUESTS
///
///   Approve or reject pharmacies that have self-registered on the
///   Duniya network. Each row shows the pharmacy name, address,
///   registration date, and the owner's name + email. Approving
///   sets `NetworkStatus` to 'active'; rejecting sets it to
///   'rejected'.
/// ═══════════════════════════════════════════════════════════════

class OnboardingRequestsWidget extends StatefulWidget {
  const OnboardingRequestsWidget({super.key});

  static String routeName = 'OnboardingRequests';
  static String routePath = '/onboardingRequests';

  @override
  State<OnboardingRequestsWidget> createState() =>
      _OnboardingRequestsWidgetState();
}

class _OnboardingRequestsWidgetState extends State<OnboardingRequestsWidget> {
  late OnboardingRequestsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Pharmases currently being approved/rejected (by reference path).
  /// Used to disable buttons + show inline progress per row.
  final Set<String> _processing = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingRequestsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'OnboardingRequests'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //   HELPERS
  // ─────────────────────────────────────────────────────────────

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Unknown date';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return _formatDate(dt);
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
            ? const Color(0xFFEF4444)
            : FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Fetches a map of `ownerRef.path → UserRecord` for the supplied
  /// pharmacies. Individual fetch failures are swallowed.
  Future<Map<String, UserRecord>> _fetchOwnerMap(
      List<PharmacyRecord> pharmacies) async {
    final refs = pharmacies
        .map((p) => p.userID)
        .whereType<DocumentReference>()
        .toSet()
        .toList();
    final map = <String, UserRecord>{};
    await Future.wait(refs.map((r) async {
      try {
        final snap = await r.get();
        if (snap.exists) {
          map[r.path] = UserRecord.fromSnapshot(snap);
        }
      } catch (_) {
        // Swallow — owner record may be missing.
      }
    }));
    return map;
  }

  Future<void> _approve(PharmacyRecord pharmacy) async {
    if (_processing.contains(pharmacy.reference.path)) return;
    safeSetState(() => _processing.add(pharmacy.reference.path));
    try {
      logFirebaseEvent('duniya_onboarding_approve', parameters: {
        'pharmacy_ref': pharmacy.reference.path,
      });
      await pharmacy.reference
          .update(createPharmacyRecordData(networkStatus: 'active'));
      _showToast('${pharmacy.name} approved and is now active.');
    } catch (e) {
      _showToast('Failed to approve ${pharmacy.name}. Please try again.',
          isError: true);
    } finally {
      if (mounted) {
        safeSetState(() => _processing.remove(pharmacy.reference.path));
      }
    }
  }

  Future<void> _reject(PharmacyRecord pharmacy) async {
    if (_processing.contains(pharmacy.reference.path)) return;
    safeSetState(() => _processing.add(pharmacy.reference.path));
    try {
      logFirebaseEvent('duniya_onboarding_reject', parameters: {
        'pharmacy_ref': pharmacy.reference.path,
      });
      await pharmacy.reference
          .update(createPharmacyRecordData(networkStatus: 'rejected'));
      _showToast('${pharmacy.name} has been rejected.');
    } catch (e) {
      _showToast('Failed to reject ${pharmacy.name}. Please try again.',
          isError: true);
    } finally {
      if (mounted) {
        safeSetState(() => _processing.remove(pharmacy.reference.path));
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  //   BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Onboarding Requests — Duniya',
      color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.sideNavModel,
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
            ),
          ),
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
                    child: const SideNavWidget(),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, -1.0),
                        child: wrapWithModel(
                          model: _model.topNavModel,
                          updateCallback: () => safeSetState(() {}),
                          child: TopNavWidget(
                            openDrawer: () async {
                              scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 8.0, 24.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroHeader(),
                              const SizedBox(height: 24.0),
                              _buildContent(),
                            ],
                          ),
                        ),
                      ),
                      if (responsiveVisibility(
                        context: context,
                        tablet: false,
                        tabletLandscape: false,
                        desktop: false,
                      ))
                        wrapWithModel(
                          model: _model.mobileNavbarModel,
                          updateCallback: () => safeSetState(() {}),
                          child: MobileNavbarWidget(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   HERO HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(28.0, 24.0, 28.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, theme.secondary],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(40),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Duniya Network',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Onboarding Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Onboarding Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Review pharmacies that have self-registered on the Duniya network. Approve to activate, or reject to deny access.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   CONTENT (StreamBuilder → KPI + list / empty)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return StreamBuilder<List<PharmacyRecord>>(
      stream: queryPharmacyRecord(
        queryBuilder: (q) => q.where('NetworkStatus',
            isEqualTo: 'pending_approval'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        final pending = snapshot.data!.where((p) => !p.deleted).toList();
        if (pending.isEmpty) {
          return _buildAllCaughtUpState();
        }
        return FutureBuilder<Map<String, UserRecord>>(
          future: _fetchOwnerMap(pending),
          builder: (context, ownerSnap) {
            final ownerMap = ownerSnap.data ?? {};
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiRow(pending.length),
                const SizedBox(height: 20.0),
                _buildRequestsList(pending, ownerMap),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKpiRow(int pendingCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFF59E0B),
                const Color(0xFFF59E0B).withAlpha(200),
              ],
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withAlpha(50),
                blurRadius: 16.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                      color: Colors.white.withAlpha(80), width: 1.0),
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pending Approval',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '$pendingCount ${pendingCount == 1 ? 'pharmacy' : 'pharmacies'} awaiting your review',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              ))
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withAlpha(160), size: 18.0),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   REQUESTS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRequestsList(
      List<PharmacyRecord> pharmacies, Map<String, UserRecord> ownerMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'Pending requests',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Column(
          children: pharmacies
              .map((p) => _buildRequestCard(p, ownerMap))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRequestCard(
      PharmacyRecord pharmacy, Map<String, UserRecord> ownerMap) {
    final theme = FlutterFlowTheme.of(context);
    final owner =
        pharmacy.userID != null ? ownerMap[pharmacy.userID!.path] : null;
    final isProcessing = _processing.contains(pharmacy.reference.path);
    final ownerName =
        owner != null && owner.displayName.isNotEmpty ? owner.displayName : null;
    final ownerEmail =
        owner != null && owner.email.isNotEmpty ? owner.email : null;
    final ownerPhone =
        owner != null && owner.phoneNumber.isNotEmpty ? owner.phoneNumber : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18.0, 16.0, 18.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + registered
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.primary, theme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: Colors.white, size: 24.0),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                      if (pharmacy.address.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                pharmacy.address,
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodySmallIsCustom,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: const Color(0xFFF59E0B).withAlpha(60),
                        width: 1.0),
                  ),
                  child: const Text(
                    'PENDING',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            // Owner + registered meta
            Container(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: theme.alternate, width: 1.0),
              ),
              child: Wrap(
                spacing: 18.0,
                runSpacing: 8.0,
                children: [
                  _metaItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Owner',
                    value: ownerName ?? 'Unknown owner',
                  ),
                  if (ownerEmail != null)
                    _metaItem(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email',
                      value: ownerEmail,
                    ),
                  if (ownerPhone != null)
                    _metaItem(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: ownerPhone,
                    ),
                  _metaItem(
                    icon: Icons.event_outlined,
                    label: 'Registered',
                    value: '${_formatDate(pharmacy.registeredAt)} '
                        '· ${_relativeTime(pharmacy.registeredAt)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: isProcessing ? null : () => _reject(pharmacy),
                    text: 'Reject',
                    icon: const Icon(Icons.close_rounded, size: 16.0),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 42.0,
                      padding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      color: const Color(0xFFEF4444),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                      ),
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  flex: 2,
                  child: FFButtonWidget(
                    onPressed: isProcessing ? null : () => _approve(pharmacy),
                    text: 'Approve',
                    icon: const Icon(Icons.check_rounded, size: 16.0),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 42.0,
                      padding: EdgeInsets.zero,
                      iconPadding: EdgeInsets.zero,
                      color: const Color(0xFF10B981),
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                      ),
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: theme.secondaryText),
        const SizedBox(width: 6.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 9.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 1.0),
            Text(
              value,
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATES (loading + all-caught-up)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(color: theme.primary, size: 48.0, lineWidth: 3.0),
          const SizedBox(height: 20.0),
          Text(
            'Loading pending requests…',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Fetching pharmacies awaiting approval',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCaughtUpState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 56.0, 32.0, 56.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(
                  color: const Color(0xFF10B981).withAlpha(80), width: 2.0),
            ),
            child: const Icon(Icons.task_alt_rounded,
                color: Color(0xFF10B981), size: 44.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'All caught up!',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'There are no pharmacies waiting for approval right now. New self-registrations will appear here automatically.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}
