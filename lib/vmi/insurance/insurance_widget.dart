import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  Color get _duniyaPurple => FlutterFlowTheme.of(context).primary;
  Color get _duniyaPurpleLight =>
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
  static const Color _paidBadge = Color(0xFF059669);

  // ── Mock Claims Data (10+) ──
  // Claims are loaded from the backend when persistence is connected.
  static final List<_ClaimRecord> _mockClaims = <_ClaimRecord>[];
  /* Legacy seed records removed from runtime.
    _ClaimRecord(
        claimId: 'CLM-2024-0089',
        memberName: 'Grace Phiri',
        scheme: 'Prima Health Plus5K',
        amount: 'K7,850.00',
        status: 'Under Review',
        dateSubmitted: '12 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0090',
        memberName: 'Bwalya Chanda',
        scheme: 'Family Care 10K',
        amount: 'K12,400.00',
        status: 'Approved',
        dateSubmitted: '08 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0091',
        memberName: 'Mwamba Kapata',
        scheme: 'Prima Health Plus5K',
        amount: 'K3,200.00',
        status: 'Submitted',
        dateSubmitted: '14 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0092',
        memberName: 'Nkole Bwalya',
        scheme: 'Basic Health 2K',
        amount: 'K1,850.00',
        status: 'Paid',
        dateSubmitted: '02 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0093',
        memberName: 'Tembo Mulenga',
        scheme: 'Family Care 10K',
        amount: 'K9,600.00',
        status: 'Rejected',
        dateSubmitted: '05 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0094',
        memberName: 'Chisha Mwango',
        scheme: 'Prima Health Plus5K',
        amount: 'K4,500.00',
        status: 'Draft',
        dateSubmitted: '-'),
    _ClaimRecord(
        claimId: 'CLM-2024-0095',
        memberName: 'Daka Sampa',
        scheme: 'Basic Health 2K',
        amount: 'K2,100.00',
        status: 'Under Review',
        dateSubmitted: '11 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0096',
        memberName: 'Lunda Chisenga',
        scheme: 'Family Care 10K',
        amount: 'K15,000.00',
        status: 'Submitted',
        dateSubmitted: '13 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0097',
        memberName: 'Musonda Kasonde',
        scheme: 'Prima Health Plus5K',
        amount: 'K6,300.00',
        status: 'Approved',
        dateSubmitted: '06 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0098',
        memberName: 'Phiri Chilufya',
        scheme: 'Basic Health 2K',
        amount: 'K1,950.00',
        status: 'Paid',
        dateSubmitted: '01 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0099',
        memberName: 'Simwinga Mwelwa',
        scheme: 'Family Care 10K',
        amount: 'K8,750.00',
        status: 'Under Review',
        dateSubmitted: '10 Jan 2025'),
    _ClaimRecord(
        claimId: 'CLM-2024-0100',
        memberName: 'Kalombo Justin',
        scheme: 'Prima Health Plus5K',
        amount: 'K5,400.00',
        status: 'Rejected',
        dateSubmitted: '07 Jan 2025'),
  ];
  */

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InsuranceModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Insurance'});
    _model.memberIdTextController ??= TextEditingController();
    _model.memberIdFocusNode ??= FocusNode();
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, size: 20.0, color: iconColor),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: textColor,
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
              // Scheme
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: bgCol,
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(claim.status), size: 14.0, color: txtCol),
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
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: _duniyaPurpleLight,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.visibility_outlined,
                          size: 16.0, color: _duniyaPurple),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: _duniyaPurpleLight,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(Icons.edit_outlined,
                          size: 16.0, color: _duniyaPurple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Loading state ──
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitRing(color: _duniyaPurple, size: 48.0),
            const SizedBox(height: 16.0),
            Text('Loading claims...',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary)),
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
    final submitted = _mockClaims.where((c) => c.status == 'Submitted').length;
    final underReview =
        _mockClaims.where((c) => c.status == 'Under Review').length;
    final approvedTotal = _mockClaims
        .where((c) => c.status == 'Approved')
        .fold<double>(0.0, (sum, c) => sum + _parseAmount(c.amount));
    final rejected = _mockClaims.where((c) => c.status == 'Rejected').length;
    final rejectionRate = _mockClaims.isNotEmpty
        ? ((rejected / _mockClaims.length) * 100).toStringAsFixed(1)
        : '0.0';

    // ── Filtered claims ──
    final filtered = _model.statusFilter == 'All'
        ? _mockClaims
        : _mockClaims.where((c) => c.status == _model.statusFilter).toList();

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
      color: _duniyaPurple,
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
                                    // ── Header ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Insurance / Claims',
                                                style: TextStyle(
                                                  fontFamily: kAppFontFamily,
                                                  fontSize: 32.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.02,
                                                  height: 1.2,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Manage medical aid claims, verify members, and track reimbursement statuses.',
                                                style: TextStyle(
                                                  fontFamily: kAppFontFamily,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6,
                                                  color: _textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

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
                                              BorderRadius.circular(12.0),
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
                                                    color: _duniyaPurpleLight,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Icon(
                                                      Icons.verified_user,
                                                      color: _duniyaPurple,
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
                                                                _duniyaPurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.badge,
                                                          color: _duniyaPurple,
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
                                                        _duniyaPurple,
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
                                                  color: _duniyaPurpleLight,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  border: Border.all(
                                                      color: _duniyaPurple
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
                                                    _memberDetailRow(
                                                        'Name', 'Grace Phiri'),
                                                    _memberDetailRow('Scheme',
                                                        'Prima Health Plus5K'),
                                                    _memberDetailRow(
                                                        'Status', 'Active'),
                                                    _memberDetailRow(
                                                        'Remaining Benefit',
                                                        'K4,250.00'),
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
                                              BorderRadius.circular(12.0),
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
                                                    color: _duniyaPurpleLight,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Icon(Icons.add_circle,
                                                      color: _duniyaPurple,
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
                                            Row(
                                              children: [
                                                // Sale/Invoice selector
                                                Expanded(
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    initialValue:
                                                        _model.claimSaleValue,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Sale / Invoice',
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
                                                                _duniyaPurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.receipt_long,
                                                          color: _duniyaPurple,
                                                          size: 20.0),
                                                    ),
                                                    items: [
                                                      'INV-2024-0342',
                                                      'INV-2024-0341',
                                                      'INV-2024-0340'
                                                    ]
                                                        .map((v) => DropdownMenuItem(
                                                            value: v,
                                                            child: Text(v,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        kAppFontFamily,
                                                                    fontSize:
                                                                        13.0))))
                                                        .toList(),
                                                    onChanged: (v) =>
                                                        safeSetState(() => _model
                                                            .claimSaleValue = v),
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                // Member selector
                                                Expanded(
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    initialValue:
                                                        _model.claimMemberValue,
                                                    decoration: InputDecoration(
                                                      labelText: 'Member',
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
                                                                _duniyaPurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.person,
                                                          color: _duniyaPurple,
                                                          size: 20.0),
                                                    ),
                                                    items: [
                                                      'Grace Phiri',
                                                      'Bwalya Chanda',
                                                      'Mwamba Kapata'
                                                    ]
                                                        .map((v) => DropdownMenuItem(
                                                            value: v,
                                                            child: Text(v,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        kAppFontFamily,
                                                                    fontSize:
                                                                        13.0))))
                                                        .toList(),
                                                    onChanged: (v) =>
                                                        safeSetState(() => _model
                                                            .claimMemberValue = v),
                                                  ),
                                                ),
                                              ],
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
                                                                _duniyaPurple,
                                                            width: 2.0),
                                                      ),
                                                      prefixIcon: Icon(
                                                          Icons.attach_money,
                                                          color: _duniyaPurple,
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
                                                onPressed: () {},
                                                icon: Icon(Icons.send,
                                                    size: 18.0),
                                                label: Text('Submit Claim'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      _duniyaPurple,
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
                                            BorderRadius.circular(12.0),
                                        border: Border.all(
                                            color: _borderColor, width: 1.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Claims List',
                                              style: TextStyle(
                                                  fontFamily: kAppFontFamily,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w700,
                                                  color: _textPrimary)),
                                          const SizedBox(height: 16.0),
                                          // Status filter tabs
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: statusTabs.map((tab) {
                                                final isActive =
                                                    _model.statusFilter == tab;
                                                final count = tab == 'All'
                                                    ? _mockClaims.length
                                                    : _mockClaims
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
                                                            ? _duniyaPurple
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    9999.0),
                                                        border: Border.all(
                                                          color: isActive
                                                              ? _duniyaPurple
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
                                                    Icon(
                                                        Icons
                                                            .description_outlined,
                                                        size: 56.0,
                                                        color: _textSecondary
                                                            .withValues(
                                                                alpha: 0.4)),
                                                    const SizedBox(
                                                        height: 16.0),
                                                    Text('No claims found',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                kAppFontFamily,
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                _textSecondary)),
                                                    const SizedBox(height: 8.0),
                                                    Text(
                                                        'Try a different status filter or submit a new claim',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                kAppFontFamily,
                                                            fontSize: 13.0,
                                                            color: _textSecondary
                                                                .withValues(
                                                                    alpha:
                                                                        0.7))),
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
