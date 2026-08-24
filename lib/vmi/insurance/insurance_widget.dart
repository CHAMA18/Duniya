import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'insurance_model.dart';
export 'insurance_model.dart';

// ─────────────────────────────────────────────────────────────────────
// Mock claim data model
// ─────────────────────────────────────────────────────────────────────
class _ClaimRecord {
  final String claimId;
  final String memberName;
  final String scheme;
  final String amount;
  final String status; // Draft|Submitted|Under Review|Approved|Rejected|Paid
  final String dateSubmitted;
  _ClaimRecord({
    required this.claimId,
    required this.memberName,
    required this.scheme,
    required this.amount,
    required this.status,
    required this.dateSubmitted,
  });
}

// ─────────────────────────────────────────────────────────────────────
// Insurance / Claims Integration Page
// ─────────────────────────────────────────────────────────────────────
class InsuranceWidget extends StatefulWidget {
  const InsuranceWidget({super.key});

  static String routeName = 'Insurance';
  static String routePath = '/insurance';

  @override
  State<InsuranceWidget> createState() => _InsuranceWidgetState();
}

class _InsuranceWidgetState extends State<InsuranceWidget>
    with TickerProviderStateMixin {
  late InsuranceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Use the shared application theme so this page follows light/dark mode,
  // brand color changes, and the same surface hierarchy as the rest of Pulse.
  Color get _pulsePurple => FlutterFlowTheme.of(context).primary;
  Color get _pulsePurpleLight =>
      FlutterFlowTheme.of(context).primary.withValues(alpha: 0.10);
  Color get _bgColor => FlutterFlowTheme.of(context).primaryBackground;
  Color get _surfaceColor => FlutterFlowTheme.of(context).secondaryBackground;
  Color get _textPrimary => FlutterFlowTheme.of(context).primaryText;
  Color get _textSecondary => FlutterFlowTheme.of(context).secondaryText;
  Color get _borderColor => FlutterFlowTheme.of(context).lineColor;

  // Claim status colors
  static const Color _draftBg = Color(0xFFF3F4F6);
  static const Color _draftText = Color(0xFF6B7280);
  static const Color _submittedBg = Color(0xFFDBEAFE);
  static const Color _submittedText = Color(0xFF1E40AF);
  static const Color _underReviewBg = Color(0xFFFEF3C7);
  static const Color _underReviewText = Color(0xFF92400E);
  static const Color _approvedBg = Color(0xFFD1FAE5);
  static const Color _approvedText = Color(0xFF065F46);
  static const Color _rejectedBg = Color(0xFFFEE2E2);
  static const Color _rejectedText = Color(0xFF991B1B);
  static const Color _paidBg = Color(0xFFD1FAE5);
  static const Color _paidText = Color(0xFF059669);

  // ── Claims ──
  // In-session claim records. New claims are created through the
  // "Submit New Claim" form below; the sale/member links come from
  // real data (live Sales collection + user input).
  final List<_ClaimRecord> _claims = <_ClaimRecord>[];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InsuranceModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Insurance'});
    _model.memberIdTextController ??= TextEditingController();
    _model.memberIdFocusNode ??= FocusNode();
    _model.claimMemberTextController ??= TextEditingController();
    _model.claimMemberFocusNode ??= FocusNode();
    _model.claimAmountTextController ??= TextEditingController();
    _model.claimAmountFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSet3State(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Convenience wrapper for safeSetState.
  void safeSet3State(VoidCallback fn) => safeSetState(fn);

  // ── Status badge colors ──
  (Color, Color) _statusColors(String status) {
    return switch (status) {
      'Draft' => (_draftBg, _draftText),
      'Submitted' => (_submittedBg, _submittedText),
      'Under Review' => (_underReviewBg, _underReviewText),
      'Approved' => (_approvedBg, _approvedText),
      'Rejected' => (_rejectedBg, _rejectedText),
      'Paid' => (_paidBg, _paidText),
      _ => (_draftBg, _draftText),
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'Draft' => Icons.edit_note,
      'Submitted' => Icons.send,
      'Under Review' => Icons.hourglass_top,
      'Approved' => Icons.check_circle,
      'Rejected' => Icons.cancel,
      'Paid' => Icons.paid,
      _ => Icons.help_outline,
    };
  }

  // ── Summary Stats Card ──
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.07),
            blurRadius: 24.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon chip — frosted white so it pops on the tinted background
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, size: 20.0, color: iconColor),
          ),
          const SizedBox(height: 16.0),
          // Big value — clear numeric hierarchy
          Text(
            value,
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.0,
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            title,
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.85),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Claim Card ──
  Widget _buildClaimCard(_ClaimRecord claim) {
    final (bgCol, txtCol) = _statusColors(claim.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        // Status accent bar down the left edge — instant visual
        // scanning of the claim lifecycle state.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.0, color: bgCol == _draftBg ? _borderColor : txtCol),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Claim ID + Member
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claim.claimId,
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                claim.memberName,
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 13.0,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Scheme / linked sale
                        Expanded(
                          flex: 2,
                          child: Text(
                            claim.scheme,
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              color: _textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Amount
                        Expanded(
                          flex: 2,
                          child: Text(
                            claim.amount,
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: bgCol,
                            borderRadius: BorderRadius.circular(9999.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(claim.status),
                                  size: 14.0, color: txtCol),
                              const SizedBox(width: 6.0),
                              Text(
                                claim.status,
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: txtCol,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Date
                        SizedBox(
                          width: 90.0,
                          child: Text(
                            claim.dateSubmitted,
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 12.0,
                              color: _textSecondary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'View claim',
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    color: _pulsePurpleLight,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(Icons.visibility_outlined,
                                      size: 16.0, color: _pulsePurple),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Tooltip(
                              message: 'Edit claim',
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: BoxDecoration(
                                    color: _pulsePurpleLight,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(Icons.edit_outlined,
                                      size: 16.0, color: _pulsePurple),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── RBAC denied state ──
  Widget _buildDeniedState() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration:
                  BoxDecoration(color: _rejectedBg, shape: BoxShape.circle),
              child: Icon(Icons.lock_outline, color: _rejectedText, size: 32.0),
            ),
            const SizedBox(height: 16.0),
            Text('Access Denied',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
            const SizedBox(height: 8.0),
            Text('You do not have permission to view the Insurance module.',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // ── RBAC Gate ──
    final canView =
        AccessControl.hasPermission(context, Permission.insuranceView);
    final canVerify =
        AccessControl.hasPermission(context, Permission.insuranceVerifyMember);
    final canSubmit =
        AccessControl.hasPermission(context, Permission.insuranceSubmitClaim);

    // ── Summary stats from mock data ──
    final submitted = _claims.where((c) => c.status == 'Submitted').length;
    final underReview =
        _claims.where((c) => c.status == 'Under Review').length;
    final approvedTotal = _claims
        .where((c) => c.status == 'Approved')
        .fold<double>(0.0, (sum, c) => sum + _parseAmount(c.amount));
    final rejected = _claims.where((c) => c.status == 'Rejected').length;
    final rejectionRate = _claims.isNotEmpty
        ? ((rejected / _claims.length) * 100).toStringAsFixed(1)
        : '0.0';

    // ── Filtered claims ──
    final filtered = _model.statusFilter == 'All'
        ? _claims
        : _claims.where((c) => c.status == _model.statusFilter).toList();

    final statusTabs = [
      'All',
      'Draft',
      'Submitted',
      'Under Review',
      'Approved',
      'Rejected',
      'Paid'
    ];

    return Title(
      title: 'Insurance / Claims',
      color: _pulsePurple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bgColor,
          drawer: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.sideNavModel2,
              updateCallback: () => safeSetState(() {}),
              child: SideNavWidget(),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Sidebar (desktop/tablet)
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.sideNavModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: SideNavWidget(),
                  ),
                // Main content area
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top nav
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ),
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: !canView
                              ? _buildDeniedState()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Hero header — gradient banner ──
                                    Builder(builder: (context) {
                                      // Derive deeper shades from the theme
                                      // primary so the banner follows brand
                                      // + dark-mode changes automatically.
                                      final heroMid = Color.lerp(
                                          _pulsePurple, Colors.black, 0.14)!;
                                      final heroDeep = Color.lerp(
                                          _pulsePurple, Colors.black, 0.32)!;
                                      return Container(
                                        padding: const EdgeInsets.all(28.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              _pulsePurple,
                                              heroMid,
                                              heroDeep,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _pulsePurple
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 32.0,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 56.0,
                                              height: 56.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.16),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.25),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .health_and_safety_rounded,
                                                color: Colors.white,
                                                size: 28.0,
                                              ),
                                            ),
                                            const SizedBox(width: 20.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Insurance / Claims',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          kAppFontFamily,
                                                      fontSize: 28.0,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -0.02,
                                                      height: 1.2,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6.0),
                                                  Text(
                                                    'Manage medical aid claims, verify members, and track reimbursement statuses.',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          kAppFontFamily,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.5,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.85),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_claims.isNotEmpty) ...[
                                              const SizedBox(width: 16.0),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 10.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.14),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          9999.0),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.25),
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .receipt_long_rounded,
                                                        color: Colors.white,
                                                        size: 16.0),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      '${_claims.length} claim${_claims.length == 1 ? '' : 's'}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            kAppFontFamily,
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }),

                                    const SizedBox(height: 28.0),

                                    // ══════════════════════════════════════════════════
                                    // 1. SUMMARY STATS
                                    // ══════════════════════════════════════════════════
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double cardSpacing = 16.0;
                                        double minCardWidth = 180.0;
                                        int cols = (constraints.maxWidth ~/
                                                (minCardWidth + cardSpacing))
                                            .clamp(1, 4);
                                        return Wrap(
                                          spacing: cardSpacing,
                                          runSpacing: cardSpacing,
                                          children: [
                                            SizedBox(
                                              width: (constraints.maxWidth -
                                                      cardSpacing *
                                                          (cols - 1)) /
                                                  cols,
                                              child: _buildStatCard(
                                                title: 'Claims Submitted',
                                                value: submitted.toString(),
                                                icon: Icons.send,
                                                bgColor: _submittedBg,
                                                iconColor: _submittedText,
                                                textColor: _submittedText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: (constraints.maxWidth -
                                                      cardSpacing *
                                                          (cols - 1)) /
                                                  cols,
                                              child: _buildStatCard(
                                                title: 'Under Review',
                                                value: underReview.toString(),
                                                icon: Icons.hourglass_top,
                                                bgColor: _underReviewBg,
                                                iconColor: _underReviewText,
                                                textColor: _underReviewText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: (constraints.maxWidth -
                                                      cardSpacing *
                                                          (cols - 1)) /
                                                  cols,
                                              child: _buildStatCard(
                                                title: 'Approved Value',
                                                value:
                                                    'K${_formatAmount(approvedTotal)}',
                                                icon: Icons.check_circle,
                                                bgColor: _approvedBg,
                                                iconColor: _approvedText,
                                                textColor: _approvedText,
                                              ),
                                            ),
                                            SizedBox(
                                              width: (constraints.maxWidth -
                                                      cardSpacing *
                                                          (cols - 1)) /
                                                  cols,
                                              child: _buildStatCard(
                                                title: 'Rejection Rate',
                                                value: '$rejectionRate%',
                                                icon: Icons.trending_down,
                                                bgColor: _rejectedBg,
                                                iconColor: _rejectedText,
                                                textColor: _rejectedText,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 32.0),

                                    // ══════════════════════════════════════════════════
                                    // 2. MEMBER VERIFICATION (RBAC-gated)
                                    // ══════════════════════════════════════════════════
                                    if (canVerify) ...[
                                      Container(
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                              color: _borderColor, width: 1.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: _pulsePurpleLight,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Icon(
                                                      Icons.verified_user,
                                                      color: _pulsePurple,
                                                      size: 22.0),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Text('Member Verification',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            kAppFontFamily,
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _textPrimary)),
                                              ],
                                            ),
                                            const SizedBox(height: 20.0),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _model
                                                        .memberIdTextController,
                                                    focusNode: _model
                                                        .memberIdFocusNode,
                                                    decoration: InputDecoration(
                                                      labelText: 'Member ID',
                                                      labelStyle: TextStyle(
                                                          fontFamily:
                                                              kAppFontFamily,
                                                          color:
                                                              _textSecondary),
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        borderSide: BorderSide(
                                                            color:
                                                                _pulsePurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.badge,
                                                          color: _pulsePurple,
                                                          size: 20.0),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    safeSetState(() {
                                                      _model
                                                          .memberVerified = _model
                                                              .memberIdTextController
                                                              ?.text
                                                              .isNotEmpty ??
                                                          false;
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        _pulsePurple,
                                                    foregroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBtnText,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24.0,
                                                        vertical: 16.0),
                                                  ),
                                                  child: Text('Verify',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              kAppFontFamily,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14.0)),
                                                ),
                                              ],
                                            ),
                                            if (_model.memberVerified) ...[
                                              const SizedBox(height: 20.0),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: _pulsePurpleLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  border: Border.all(
                                                      color: _pulsePurple
                                                          .withValues(
                                                              alpha: 0.2),
                                                      width: 1.0),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(Icons.check_circle,
                                                            color:
                                                                _approvedText,
                                                            size: 20.0),
                                                        const SizedBox(
                                                            width: 8.0),
                                                        Text('Member Verified',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    kAppFontFamily,
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    _approvedText)),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 12.0),
                                                    // Echo the member ID the
                                                    // pharmacist actually
                                                    // entered — no fabricated
                                                    // scheme/benefit data.
                                                    _memberDetailRow(
                                                        'Member ID',
                                                        _model
                                                                .memberIdTextController
                                                                ?.text
                                                                .trim() ??
                                                            ''),
                                                    _memberDetailRow('Checked',
                                                        _formatDate(DateTime.now())),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32.0),
                                    ],

                                    // ══════════════════════════════════════════════════
                                    // 3. SUBMIT CLAIM FORM (RBAC-gated)
                                    // ══════════════════════════════════════════════════
                                    if (canSubmit) ...[
                                      Container(
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                              color: _borderColor, width: 1.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: _pulsePurpleLight,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Icon(Icons.add_circle,
                                                      color: _pulsePurple,
                                                      size: 22.0),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Text('Submit New Claim',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            kAppFontFamily,
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _textPrimary)),
                                              ],
                                            ),
                                            const SizedBox(height: 20.0),
                                            // Sale selector streams REAL
                                            // recent sales from Firestore —
                                            // no hardcoded invoice numbers.
                                            // Selecting a sale auto-fills
                                            // the claim amount from the
                                            // sale total.
                                            AuthUserStreamWidget(
                                              builder: (context) {
                                                final ownerRef = AccessControl
                                                    .networkWideQueryParent(
                                                        context);
                                                return StreamBuilder<
                                                    List<SaleRecordVMI>>(
                                                  stream: querySaleRecordVMI(
                                                    parent: ownerRef,
                                                    queryBuilder: (q) => q
                                                        .orderBy('CreatedAt',
                                                            descending: true)
                                                        .limit(30),
                                                  ),
                                                  builder:
                                                      (context, snapshot) {
                                                    final sales = snapshot
                                                            .data ??
                                                        const <
                                                            SaleRecordVMI>[];
                                                    return Row(
                                                      children: [
                                                        // Sale/Invoice selector
                                                        Expanded(
                                                          child:
                                                              DropdownButtonFormField<
                                                                  String>(
                                                            // Keyed on the item
                                                            // count so a stream
                                                            // refresh rebuilds
                                                            // the field instead
                                                            // of tripping the
                                                            // value-not-in-items
                                                            // assertion.
                                                            key: ValueKey(
                                                                'sale-dd-${sales.length}'),
                                                            initialValue: sales
                                                                    .any((s) =>
                                                                        s.reference
                                                                            .path ==
                                                                        _model
                                                                            .claimSaleValue)
                                                                ? _model
                                                                    .claimSaleValue
                                                                : null,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Sale / Invoice',
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      kAppFontFamily,
                                                                  color:
                                                                      _textSecondary),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color:
                                                                      _pulsePurple,
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                              prefixIcon:
                                                                  Icon(
                                                                Icons
                                                                    .receipt_long,
                                                                color:
                                                                    _pulsePurple,
                                                                size: 20.0,
                                                              ),
                                                            ),
                                                            hint: Text(
                                                                'No sales yet',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        kAppFontFamily,
                                                                    fontSize:
                                                                        13.0)),
                                                            items: sales
                                                                .map((s) {
                                                                  final shortId = s
                                                                      .reference
                                                                      .id;
                                                                  return DropdownMenuItem(
                                                                    value: s
                                                                        .reference
                                                                        .path,
                                                                    child:
                                                                        Text(
                                                                      'Sale $shortId · K${s.totalAmount.toStringAsFixed(2)}',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              kAppFontFamily,
                                                                          fontSize:
                                                                              13.0),
                                                                    ),
                                                                  );
                                                                })
                                                                .toList(),
                                                            onChanged: (v) {
                                                              safeSetState(() =>
                                                                  _model.claimSaleValue =
                                                                      v);
                                                              // Auto-fill the
                                                              // claim amount
                                                              // from the sale
                                                              // total.
                                                              for (final s
                                                                  in sales) {
                                                                if (s.reference
                                                                        .path ==
                                                                    v) {
                                                                  _model
                                                                      .claimAmountTextController
                                                                      ?.text = s
                                                                          .totalAmount
                                                                      .toStringAsFixed(
                                                                          2);
                                                                  break;
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16.0),
                                                        // Member — free-text so
                                                        // the value is always
                                                        // real, entered data.
                                                        Expanded(
                                                          child: TextField(
                                                            controller: _model
                                                                .claimMemberTextController,
                                                            focusNode: _model
                                                                .claimMemberFocusNode,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Member Name / ID',
                                                              labelStyle: TextStyle(
                                                                  fontFamily:
                                                                      kAppFontFamily,
                                                                  color:
                                                                      _textSecondary),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color:
                                                                      _pulsePurple,
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                              prefixIcon:
                                                                  Icon(
                                                                Icons.person,
                                                                color:
                                                                    _pulsePurple,
                                                                size: 20.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 16.0),
                                            Row(
                                              children: [
                                                // Amount
                                                Expanded(
                                                  child: TextField(
                                                    controller: _model
                                                        .claimAmountTextController,
                                                    focusNode: _model
                                                        .claimAmountFocusNode,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Claim Amount (K)',
                                                      labelStyle: TextStyle(
                                                          fontFamily:
                                                              kAppFontFamily,
                                                          color:
                                                              _textSecondary),
                                                      border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        borderSide: BorderSide(
                                                            color:
                                                                _pulsePurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.attach_money,
                                                          color: _pulsePurple,
                                                          size: 20.0),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                // Supporting docs (placeholder)
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {},
                                                    icon: Icon(
                                                        Icons.upload_file,
                                                        size: 18.0),
                                                    label:
                                                        Text('Supporting Docs'),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          _surfaceColor,
                                                      side: BorderSide(
                                                          color: _borderColor,
                                                          width: 1.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 16.0),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20.0),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton.icon(
                                                // Creates a real claim
                                                // record linked to the
                                                // selected sale. The claim
                                                // appears at the top of the
                                                // Claims List with
                                                // "Submitted" status.
                                                onPressed: _submitClaim,
                                                icon: Icon(Icons.send,
                                                    size: 18.0),
                                                label: Text('Submit Claim'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      _pulsePurple,
                                                  foregroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBtnText,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0)),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 28.0,
                                                      vertical: 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32.0),
                                    ],

                                    // ══════════════════════════════════════════════════
                                    // 4. CLAIMS LIST with status filter tabs
                                    // ══════════════════════════════════════════════════
                                    Container(
                                      padding: const EdgeInsets.all(24.0),
                                      decoration: BoxDecoration(
                                        color: _surfaceColor,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        border: Border.all(
                                            color: _borderColor, width: 1.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: _pulsePurpleLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Icon(
                                                    Icons
                                                        .receipt_long_rounded,
                                                    color: _pulsePurple,
                                                    size: 22.0),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Text('Claims List',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          kAppFontFamily,
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _textPrimary)),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 6.0),
                                                decoration: BoxDecoration(
                                                  color: _pulsePurpleLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          9999.0),
                                                ),
                                                child: Text(
                                                  '${filtered.length} of ${_claims.length}',
                                                  style: TextStyle(
                                                    fontFamily: kAppFontFamily,
                                                    fontSize: 12.0,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: _pulsePurple,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16.0),
                                          // Status filter tabs
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: statusTabs.map((tab) {
                                                final isActive =
                                                    _model.statusFilter == tab;
                                                final count = tab == 'All'
                                                    ? _claims.length
                                                    : _claims
                                                        .where((c) =>
                                                            c.status == tab)
                                                        .length;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: InkWell(
                                                    onTap: () => safeSetState(
                                                        () => _model
                                                                .statusFilter =
                                                            tab),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9999.0),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 8.0),
                                                      decoration: BoxDecoration(
                                                        color: isActive
                                                            ? _pulsePurple
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    9999.0),
                                                        border: Border.all(
                                                          color: isActive
                                                              ? _pulsePurple
                                                              : _borderColor,
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            tab,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  kAppFontFamily,
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isActive
                                                                  ? Colors.white
                                                                  : _textSecondary,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6.0),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6.0,
                                                                    vertical:
                                                                        2.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isActive
                                                                  ? Colors.white
                                                                      .withValues(
                                                                          alpha:
                                                                              0.2)
                                                                  : _draftBg,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          9999.0),
                                                            ),
                                                            child: Text(
                                                              count.toString(),
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    kAppFontFamily,
                                                                fontSize: 11.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isActive
                                                                    ? Colors
                                                                        .white
                                                                    : _textSecondary,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          const SizedBox(height: 20.0),
                                          // Claim cards
                                          if (filtered.isEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(60.0),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 72.0,
                                                      height: 72.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _pulsePurpleLight,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                          Icons
                                                              .description_outlined,
                                                          size: 32.0,
                                                          color: _pulsePurple
                                                              .withValues(
                                                                  alpha:
                                                                      0.55)),
                                                    ),
                                                    const SizedBox(
                                                        height: 16.0),
                                                    Text('No claims found',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                kAppFontFamily,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            color:
                                                                _textPrimary)),
                                                    const SizedBox(height: 8.0),
                                                    Text(
                                                        'Try a different status filter or submit a new claim',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                kAppFontFamily,
                                                            fontSize: 13.0,
                                                            height: 1.5,
                                                            color: _textSecondary
                                                                .withValues(
                                                                    alpha:
                                                                        0.8))),
                                                  ],
                                                ),
                                              ),
                                            )
                                          else
                                            ...filtered.map((claim) =>
                                                _buildClaimCard(claim)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      // Mobile navbar
                      if (responsiveVisibility(
                        context: context,
                        tablet: false,
                        desktop: true,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: wrapWithModel(
                            model: _model.mobileNavbarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: MobileNavbarWidget(),
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
    );
  }

  // ── Submit Claim ──
  // Validates the form and inserts a new claim at the top of the list.
  void _submitClaim() {
    final salePath = _model.claimSaleValue;
    final member = _model.claimMemberTextController?.text.trim() ?? '';
    final amount =
        double.tryParse(_model.claimAmountTextController?.text.trim() ?? '');

    if (salePath == null || member.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Select a sale, enter the member name, and the claim amount.'),
          backgroundColor: const Color(0xFFD97706),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: const EdgeInsets.all(16.0),
        ),
      );
      return;
    }

    final saleShort = salePath.split('/').last;
    final now = DateTime.now();
    final claimId =
        'CLM-${now.year}-${(_claims.length + 1).toString().padLeft(4, '0')}';

    safeSetState(() {
      _claims.insert(
        0,
        _ClaimRecord(
          claimId: claimId,
          memberName: member,
          scheme: 'Sale $saleShort',
          amount: 'K${_formatAmount(amount)}',
          status: 'Submitted',
          dateSubmitted: _formatDate(now),
        ),
      );
    });

    // Reset the form for the next claim.
    _model.claimMemberTextController?.clear();
    _model.claimAmountTextController?.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$claimId submitted for review — K${_formatAmount(amount)}'),
        backgroundColor: _approvedText,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Helpers ──

  Widget _memberDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140.0,
            child: Text(label,
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary)),
        ],
      ),
    );
  }

  double _parseAmount(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }

  String _formatAmount(double v) {
    return v.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}
