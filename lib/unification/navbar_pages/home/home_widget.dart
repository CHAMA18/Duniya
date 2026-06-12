import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/hr_table_widget.dart';
import '/components/pharma_table_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with TickerProviderStateMixin {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Time period selector state
  int _selectedPeriod = 0; // 0: Today, 1: 7D, 2: 30D

  // Pulse animation for low stock indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // AI dot pulse animation
  late AnimationController _aiDotController;
  late Animation<double> _aiDotAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Home'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('HOME_PAGE_Home_ON_INIT_STATE');
      logFirebaseEvent('Home_generate_current_page_link');
      _model.currentPageLink = await generateCurrentPageLink(
        context,
        title: 'Link',
        imageUrl: 'Link',
        description: 'Links',
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Pulse animation for low stock badge
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // AI dot pulse animation
    _aiDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _aiDotAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _aiDotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _aiDotController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ─── Helper: Period selector pill button ────────────────────────────
  Widget _buildPeriodPill(String label, int index) {
    final isActive = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => safeSetState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily:
                    FlutterFlowTheme.of(context).bodySmallFamily,
                color: isActive
                    ? Colors.white
                    : FlutterFlowTheme.of(context).secondaryText,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }

  // ─── Helper: Section header ─────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily:
                    FlutterFlowTheme.of(context).titleLargeFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).titleLargeIsCustom,
              ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                actionLabel,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodySmallFamily,
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Helper: Glass-panel KPI card ───────────────────────────────────
  Widget _buildGlassKpiCard({
    required IconData icon,
    required Color iconBgColor,
    required Widget? badge,
    required String value,
    required String label,
    required Color gradientColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative blurred gradient circle (top-right)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gradientColor.withOpacity(0.3),
                          gradientColor.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconBgColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconBgColor,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        if (badge != null) badge,
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      value,
                      style: FlutterFlowTheme.of(context)
                          .displaySmall
                          .override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .displaySmallFamily,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            lineHeight: 1.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .displaySmallIsCustom,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 13,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helper: Quick action card ──────────────────────────────────────
  Widget _buildQuickActionCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .bodyLargeFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyLargeIsCustom,
                            ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 6),
                        trailing,
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FlutterFlowTheme.of(context)
                              .bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12,
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .bodySmallIsCustom,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper: Premium card container ─────────────────────────────────
  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPhone = screenWidth <= 768;

    context.watch<FFAppState>();

    return Title(
      title: 'Home',
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
            child: WebViewAware(
              child: wrapWithModel(
                model: _model.sideNavModel2,
                updateCallback: () => safeSetState(() {}),
                child: SideNavWidget(),
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Column(
              children: [
                // ── Main body row ────────────────────────────────────
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // SideNav (desktop/tablet only)
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
                      // Main content column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TopNav
                            Align(
                              alignment: const AlignmentDirectional(0, -1),
                              child: wrapWithModel(
                                model: _model.topNavModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TopNavWidget(
                                  openDrawer: () async {
                                    logFirebaseEvent(
                                        'HOME_PAGE_Container_1gnhj73v_CALLBACK');
                                    logFirebaseEvent('TopNav_drawer');
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                ),
                              ),
                            ),
                            // Scrollable content
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isPhone ? 16 : 24,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ───────────────────────────────────
                                    // 1. PAGE HEADER
                                    // ───────────────────────────────────
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Command Center',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .displaySmallFamily,
                                                fontSize: isPhone ? 26 : 34,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmallIsCustom,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (!isPhone)
                                          AutoSizeText(
                                            'Real-time overview of your pharmacy operations and performance metrics.',
                                            minFontSize: 8,
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  fontSize: 14,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallIsCustom,
                                                ),
                                          ),
                                        const SizedBox(height: 16),
                                        // Time period selector
                                        Row(
                                          children: [
                                            _buildPeriodPill('Today', 0),
                                            const SizedBox(width: 8),
                                            _buildPeriodPill('7D', 1),
                                            const SizedBox(width: 8),
                                            _buildPeriodPill('30D', 2),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 28),

                                    // ───────────────────────────────────
                                    // 2. KEY METRICS ROW (3 glass cards)
                                    // ───────────────────────────────────
                                    isPhone
                                        ? Column(
                                            children: [
                                              // Sales Card
                                              AuthUserStreamWidget(
                                                builder: (context) =>
                                                    FutureBuilder<int>(
                                                  future:
                                                      querySalesRecordCount(
                                                    parent: () {
                                                      if (valueOrDefault(
                                                              currentUserDocument
                                                                  ?.role,
                                                              '') ==
                                                          'Owner') {
                                                        return currentUserReference;
                                                      } else if (valueOrDefault(
                                                              currentUserDocument
                                                                  ?.role,
                                                              '') !=
                                                          'Owner') {
                                                        return currentUserDocument
                                                            ?.ownerRef;
                                                      } else {
                                                        return currentUserDocument
                                                            ?.ownerRef;
                                                      }
                                                    }(),
                                                  ),
                                                  builder:
                                                      (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return ShimmerLoadingCardWidget();
                                                    }
                                                    int containerCount =
                                                        snapshot.data!;
                                                    return _buildGlassKpiCard(
                                                      icon: Icons
                                                          .point_of_sale_rounded,
                                                      iconBgColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      badge: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 4),
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                    0xFF10B981)
                                                                .withOpacity(
                                                                    0.12),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .trending_up_rounded,
                                                              size: 14,
                                                              color: Color(
                                                                  0xFF10B981),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              '+12.5%',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context).bodySmallFamily,
                                                                    color: const Color(
                                                                        0xFF10B981),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        12,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      value: formatNumber(
                                                        containerCount,
                                                        formatType: FormatType
                                                            .decimal,
                                                        decimalType:
                                                            DecimalType
                                                                .automatic,
                                                      ),
                                                      label:
                                                          'Total Sales Transactions',
                                                      gradientColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      onTap: () async {
                                                        logFirebaseEvent(
                                                            'HOME_PAGE_SalesCard_ON_TAP');
                                                        logFirebaseEvent(
                                                            'SalesCard_navigate_to');
                                                        context.pushNamed(
                                                            FinancesWidget
                                                                .routeName);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Staff Card (Owner only)
                                              if (valueOrDefault(
                                                      currentUserDocument
                                                          ?.role,
                                                      '') ==
                                                  'Owner')
                                                AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<int>(
                                                    future:
                                                        queryStaffRecordCount(
                                                      queryBuilder:
                                                          (staffRecord) =>
                                                              staffRecord
                                                                  .where(
                                                                    'OwnerRef',
                                                                    isEqualTo:
                                                                        currentUserReference,
                                                                  )
                                                                  .where(
                                                                    'deleted',
                                                                    isNotEqualTo:
                                                                        true,
                                                                  ),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return ShimmerLoadingCardWidget();
                                                      }
                                                      int containerCount =
                                                          snapshot.data!;
                                                      return _buildGlassKpiCard(
                                                        icon:
                                                            Icons.groups_rounded,
                                                        iconBgColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        badge: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondary
                                                                  .withOpacity(
                                                                      0.12),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Text(
                                                            'ACTIVE: $containerCount',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(context).bodySmallFamily,
                                                                  color: FlutterFlowTheme
                                                                      .of(context)
                                                                      .secondary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 12,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                        value:
                                                            containerCount
                                                                .toString(),
                                                        label:
                                                            'Total Staff Members',
                                                        gradientColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        onTap: () async {
                                                          logFirebaseEvent(
                                                              'HOME_PAGE_StaffCard_ON_TAP');
                                                          logFirebaseEvent(
                                                              'StaffCard_navigate_to');
                                                          context.pushNamed(
                                                              HumanResourceUniWidget
                                                                  .routeName);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              if (valueOrDefault(
                                                      currentUserDocument
                                                          ?.role,
                                                      '') ==
                                                  'Owner')
                                                const SizedBox(height: 16),
                                              // Inventory Card
                                              AuthUserStreamWidget(
                                                builder: (context) =>
                                                    FutureBuilder<int>(
                                                  future:
                                                      queryStockRecordCount(
                                                    parent: valueOrDefault(
                                                                currentUserDocument
                                                                    ?.role,
                                                                '') ==
                                                            'Owner'
                                                        ? currentUserReference
                                                        : currentUserDocument
                                                            ?.ownerRef,
                                                    queryBuilder:
                                                        (stockRecord) =>
                                                            stockRecord.where(
                                                      'Quantity',
                                                      isGreaterThan: 0,
                                                    ),
                                                  ),
                                                  builder:
                                                      (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return ShimmerLoadingCardWidget();
                                                    }
                                                    int containerCount =
                                                        snapshot.data!;
                                                    return _buildGlassKpiCard(
                                                      icon: Icons
                                                          .inventory_2_rounded,
                                                      iconBgColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      badge: AnimatedBuilder(
                                                        animation:
                                                            _pulseAnimation,
                                                        builder:
                                                            (context, child) {
                                                          return Transform.scale(
                                                            scale:
                                                                _pulseAnimation
                                                                    .value,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                              decoration: BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error
                                                                      .withOpacity(
                                                                          0.12),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          20)),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Icon(
                                                                    Icons
                                                                        .warning_amber_rounded,
                                                                    size: 14,
                                                                    color: Color(
                                                                        0xFFEF4444),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 4),
                                                                  Text(
                                                                    'LOW STOCK',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          color:
                                                                              const Color(0xFFEF4444),
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              11,
                                                                          letterSpacing:
                                                                              0.5,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      value:
                                                          containerCount
                                                              .toString(),
                                                      label:
                                                          'Total Inventory SKUs',
                                                      gradientColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      onTap: () async {
                                                        logFirebaseEvent(
                                                            'HOME_PAGE_InventoryCard_ON_TAP');
                                                        logFirebaseEvent(
                                                            'InventoryCard_navigate_to');
                                                        context.pushNamed(
                                                            StoreInventoryWidget
                                                                .routeName);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              // Sales Card
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<int>(
                                                    future:
                                                        querySalesRecordCount(
                                                      parent: () {
                                                        if (valueOrDefault(
                                                                currentUserDocument
                                                                    ?.role,
                                                                '') ==
                                                            'Owner') {
                                                          return currentUserReference;
                                                        } else if (valueOrDefault(
                                                                currentUserDocument
                                                                    ?.role,
                                                                '') !=
                                                            'Owner') {
                                                          return currentUserDocument
                                                              ?.ownerRef;
                                                        } else {
                                                          return currentUserDocument
                                                              ?.ownerRef;
                                                        }
                                                      }(),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot
                                                          .hasData) {
                                                        return ShimmerLoadingCardWidget();
                                                      }
                                                      int containerCount =
                                                          snapshot.data!;
                                                      return _buildGlassKpiCard(
                                                        icon: Icons
                                                            .point_of_sale_rounded,
                                                        iconBgColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        badge: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                      0xFF10B981)
                                                                  .withOpacity(
                                                                      0.12),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .trending_up_rounded,
                                                                size: 14,
                                                                color: Color(
                                                                    0xFF10B981),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                '+12.5%',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context).bodySmallFamily,
                                                                      color: const Color(
                                                                          0xFF10B981),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          12,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        value: formatNumber(
                                                          containerCount,
                                                          formatType: FormatType
                                                              .decimal,
                                                          decimalType:
                                                              DecimalType
                                                                  .automatic,
                                                        ),
                                                        label:
                                                            'Total Sales Transactions',
                                                        gradientColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        onTap: () async {
                                                          logFirebaseEvent(
                                                              'HOME_PAGE_SalesCard_ON_TAP');
                                                          logFirebaseEvent(
                                                              'SalesCard_navigate_to');
                                                          context.pushNamed(
                                                              FinancesWidget
                                                                  .routeName);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Staff Card (Owner only)
                                              if (valueOrDefault(
                                                      currentUserDocument
                                                          ?.role,
                                                      '') ==
                                                  'Owner')
                                                Expanded(
                                                  flex: 1,
                                                  child:
                                                      AuthUserStreamWidget(
                                                    builder: (context) =>
                                                        FutureBuilder<int>(
                                                      future:
                                                          queryStaffRecordCount(
                                                        queryBuilder:
                                                            (staffRecord) =>
                                                                staffRecord
                                                                    .where(
                                                                      'OwnerRef',
                                                                      isEqualTo:
                                                                          currentUserReference,
                                                                    )
                                                                    .where(
                                                                      'deleted',
                                                                      isNotEqualTo:
                                                                          true,
                                                                    ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot
                                                            .hasData) {
                                                          return ShimmerLoadingCardWidget();
                                                        }
                                                        int containerCount =
                                                            snapshot.data!;
                                                        return _buildGlassKpiCard(
                                                          icon: Icons
                                                              .groups_rounded,
                                                          iconBgColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondary,
                                                          badge: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary
                                                                    .withOpacity(
                                                                        0.12),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Text(
                                                              'ACTIVE: $containerCount',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context).bodySmallFamily,
                                                                    color: FlutterFlowTheme.of(context).secondary,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 12,
                                                                    letterSpacing: 0.0,
                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                          value:
                                                              containerCount
                                                                  .toString(),
                                                          label:
                                                              'Total Staff Members',
                                                          gradientColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondary,
                                                          onTap: () async {
                                                            logFirebaseEvent(
                                                                'HOME_PAGE_StaffCard_ON_TAP');
                                                            logFirebaseEvent(
                                                                'StaffCard_navigate_to');
                                                            context.pushNamed(
                                                                HumanResourceUniWidget
                                                                    .routeName);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              if (valueOrDefault(
                                                      currentUserDocument
                                                          ?.role,
                                                      '') ==
                                                  'Owner')
                                                const SizedBox(width: 16),
                                              // Inventory Card
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<int>(
                                                    future:
                                                        queryStockRecordCount(
                                                      parent: valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.role,
                                                                  '') ==
                                                              'Owner'
                                                          ? currentUserReference
                                                          : currentUserDocument
                                                              ?.ownerRef,
                                                      queryBuilder:
                                                          (stockRecord) =>
                                                              stockRecord
                                                                  .where(
                                                        'Quantity',
                                                        isGreaterThan: 0,
                                                      ),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot
                                                          .hasData) {
                                                        return ShimmerLoadingCardWidget();
                                                      }
                                                      int containerCount =
                                                          snapshot.data!;
                                                      return _buildGlassKpiCard(
                                                        icon: Icons
                                                            .inventory_2_rounded,
                                                        iconBgColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        badge:
                                                            AnimatedBuilder(
                                                          animation:
                                                              _pulseAnimation,
                                                          builder:
                                                              (context,
                                                                  child) {
                                                            return Transform
                                                                .scale(
                                                              scale:
                                                                  _pulseAnimation
                                                                      .value,
                                                              child:
                                                                  Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                                decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error
                                                                        .withOpacity(
                                                                            0.12),
                                                                    borderRadius:
                                                                        BorderRadius.circular(20)),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .warning_amber_rounded,
                                                                      size:
                                                                          14,
                                                                      color: Color(
                                                                          0xFFEF4444),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      'LOW STOCK',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                const Color(0xFFEF4444),
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize:
                                                                                11,
                                                                            letterSpacing:
                                                                                0.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        value:
                                                            containerCount
                                                                .toString(),
                                                        label:
                                                            'Total Inventory SKUs',
                                                        gradientColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        onTap: () async {
                                                          logFirebaseEvent(
                                                              'HOME_PAGE_InventoryCard_ON_TAP');
                                                          logFirebaseEvent(
                                                              'InventoryCard_navigate_to');
                                                          context.pushNamed(
                                                              StoreInventoryWidget
                                                                  .routeName);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                    const SizedBox(height: 32),

                                    // ───────────────────────────────────
                                    // 3. TWO-COLUMN LAYOUT
                                    // ───────────────────────────────────
                                    isPhone
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLeftColumn(),
                                              const SizedBox(height: 28),
                                              _buildRightColumn(context),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left 2/3
                                              Expanded(
                                                flex: 2,
                                                child:
                                                    _buildLeftColumn(),
                                              ),
                                              const SizedBox(width: 24),
                                              // Right 1/3
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    _buildRightColumn(
                                                        context),
                                              ),
                                            ],
                                          ),

                                    const SizedBox(height: 32),

                                    // ───────────────────────────────────
                                    // 4. BOTTOM SECTION (full width)
                                    // ───────────────────────────────────
                                    if (valueOrDefault(
                                            currentUserDocument?.role,
                                            '') ==
                                        'Owner')
                                      _buildSectionHeader(
                                        'Active Staff',
                                        Icons.badge_rounded,
                                        actionLabel: 'View Roster',
                                        onAction: () async {
                                          logFirebaseEvent(
                                              'HOME_PAGE_ViewRoster_ON_TAP');
                                          logFirebaseEvent(
                                              'ViewRoster_navigate_to');
                                          context.pushNamed(
                                              HumanResourceUniWidget
                                                  .routeName);
                                        },
                                      ),
                                    if (valueOrDefault(
                                            currentUserDocument?.role,
                                            '') ==
                                        'Owner')
                                      const SizedBox(height: 16),
                                    if (valueOrDefault(
                                            currentUserDocument?.role,
                                            '') ==
                                        'Owner')
                                      AuthUserStreamWidget(
                                        builder: (context) =>
                                            wrapWithModel(
                                          model: _model.hrTableModel,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: HrTableWidget(),
                                        ),
                                      ),

                                    const SizedBox(height: 28),

                                    _buildSectionHeader(
                                      'Outlets Network',
                                      Icons.storefront_rounded,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildOutletsSection(),

                                    // Bottom padding for scroll
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Mobile bottom navbar
                if (responsiveVisibility(
                  context: context,
                  tablet: false,
                  tabletLandscape: false,
                  desktop: false,
                ))
                  MobileNavbarWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── LEFT COLUMN ─────────────────────────────────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performance Analytics section
        _buildSectionHeader(
          'Performance Analytics',
          Icons.analytics_rounded,
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Row(
                children: [
                  Text(
                    'Sales Revenue Trend',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context)
                                  .titleMediumIsCustom,
                        ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      logFirebaseEvent(
                          'HOME_PAGE_ExportReport_ON_TAP');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        'Export Report',
                        style: FlutterFlowTheme.of(context)
                            .bodySmall
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .bodySmallFamily,
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              useGoogleFonts:
                                  !FlutterFlowTheme.of(context)
                                      .bodySmallIsCustom,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Chart placeholder
              SizedBox(
                height: 200,
                child: CustomPaint(
                  size: Size.zero,
                  painter: _ChartPlaceholderPainter(
                    lineColor: FlutterFlowTheme.of(context).primary,
                    gradientTop: FlutterFlowTheme.of(context)
                        .primary
                        .withOpacity(0.2),
                    gradientBottom:
                        FlutterFlowTheme.of(context).primary.withOpacity(0.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
                ]
                    .map((day) => Text(
                          day,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                fontSize: 11,
                                letterSpacing: 0.0,
                                useGoogleFonts:
                                    !FlutterFlowTheme.of(context)
                                        .bodySmallIsCustom,
                              ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Quick Actions section
        _buildSectionHeader(
          'Quick Actions',
          Icons.bolt_rounded,
        ),
        const SizedBox(height: 16),
        // 2x2 grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final cardWidth = isWide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            final cardHeight = 88.0; // Fixed card height for consistency

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
            // Point of Sale
            SizedBox(
              width: isWide ? cardWidth : null,
              child: _buildQuickActionCard(
              icon: Icon(Icons.point_of_sale_rounded, color: FlutterFlowTheme.of(context).primary, size: 22),
              title: 'Point of Sale',
              subtitle: 'Process transactions & billing',
              accentColor: FlutterFlowTheme.of(context).primary,
              onTap: () async {
                logFirebaseEvent(
                    'HOME_PAGE_QuickAction_POS_ON_TAP');
                var _shouldSetState = false;
                if (valueOrDefault(
                        currentUserDocument?.role, '') ==
                    'Owner') {
                  logFirebaseEvent('QuickAction_POS_navigate_to');
                  context.pushNamed(PointOfSalesWidget.routeName);
                  if (_shouldSetState) safeSetState(() {});
                  return;
                } else {
                  logFirebaseEvent('QuickAction_POS_firestore_query');
                  _model.staff = await queryStaffRecordOnce(
                    queryBuilder: (staffRecord) => staffRecord.where(
                      'Email',
                      isEqualTo: currentUserEmail,
                    ),
                    singleRecord: true,
                  ).then((s) => s.firstOrNull);
                  _shouldSetState = true;
                  logFirebaseEvent('QuickAction_POS_backend_call');
                  _model.pharm = await PharmacyRecord.getDocumentOnce(
                      _model.staff!.pharmId!);
                  _shouldSetState = true;
                }
                logFirebaseEvent('QuickAction_POS_navigate_to');
                context.pushNamed(
                  PointOfSalesWidget.routeName,
                  queryParameters: {
                    'pharm': serializeParam(
                      _model.pharm?.name,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
                if (_shouldSetState) safeSetState(() {});
              },
              ),
            ),
            // HR Portal (Owner only)
            if (valueOrDefault(currentUserDocument?.role, '') == 'Owner')
              AuthUserStreamWidget(
                builder: (context) => SizedBox(
                  width: isWide ? cardWidth : null,
                  child: _buildQuickActionCard(
                  icon: Icon(Icons.people_alt_rounded, color: FlutterFlowTheme.of(context).secondary, size: 22),
                  title: 'HR Portal',
                  subtitle: 'Manage staff & resources',
                  accentColor: FlutterFlowTheme.of(context).secondary,
                  onTap: () async {
                    logFirebaseEvent(
                        'HOME_PAGE_QuickAction_HR_ON_TAP');
                    logFirebaseEvent('QuickAction_HR_navigate_to');
                    context.goNamed(
                        HumanResourceUniWidget.routeName);
                  },
                ),
                ),
              ),
            // AI Assistant
            SizedBox(
              width: isWide ? cardWidth : null,
              child: _buildQuickActionCard(
              icon: FaIcon(FontAwesomeIcons.robot, color: const Color(0xFF8B5CF6), size: 22),
              title: 'AI Assistant',
              subtitle: 'Smart pharmacy insights',
              accentColor: const Color(0xFF8B5CF6),
              trailing: AnimatedBuilder(
                animation: _aiDotAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _aiDotAnimation.value,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              onTap: () async {
                logFirebaseEvent(
                    'HOME_PAGE_QuickAction_AI_ON_TAP');
                logFirebaseEvent('QuickAction_AI_navigate_to');
                context.goNamed(AiAssistantWidget.routeName);
              },
              ),
            ),
            // Calculators
            SizedBox(
              width: isWide ? cardWidth : null,
              child: _buildQuickActionCard(
              icon: const Icon(Icons.calculate_rounded, color: Color(0xFFF59E0B), size: 22),
              title: 'Calculators',
              subtitle: 'BMI & health calculators',
              accentColor: const Color(0xFFF59E0B),
              onTap: () async {
                logFirebaseEvent(
                    'HOME_PAGE_QuickAction_Calc_ON_TAP');
                logFirebaseEvent('QuickAction_Calc_navigate_to');
                context.goNamed(BMICalcWidget.routeName);
              },
              ),
            ),
            ],
            );
          },
        ),
      ],
    );
  }

  // ─── RIGHT COLUMN ────────────────────────────────────────────────────
  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Inventory Mix',
          Icons.pie_chart_rounded,
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          child: Column(
            children: [
              // Donut chart placeholder
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Custom painted donut
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _DonutChartPainter(),
                    ),
                    // Center text
                    AuthUserStreamWidget(
                      builder: (context) => FutureBuilder<int>(
                        future: queryStockRecordCount(
                          parent: valueOrDefault(
                                      currentUserDocument?.role, '') ==
                                  'Owner'
                              ? currentUserReference
                              : currentUserDocument?.ownerRef,
                          queryBuilder: (stockRecord) =>
                              stockRecord.where(
                            'Quantity',
                            isGreaterThan: 0,
                          ),
                        ),
                        builder: (context, snapshot) {
                          final count =
                              snapshot.hasData ? snapshot.data! : 0;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                count.toString(),
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .headlineMediumFamily,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      lineHeight: 1.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .headlineMediumIsCustom,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total SKUs',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
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
              const SizedBox(height: 24),
              // Legend
              _buildLegendItem(
                'Prescription Rx',
                '55%',
                const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 10),
              _buildLegendItem(
                'Over-The-Counter',
                '30%',
                const Color(0xFF06B6D4),
              ),
              const SizedBox(height: 10),
              _buildLegendItem(
                'Supplements & Other',
                '15%',
                const Color(0xFF93C5FD),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Legend item ──────────────────────────────────────────────────────
  Widget _buildLegendItem(String label, String percent, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily:
                      FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontSize: 13,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
        Text(
          percent,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily:
                    FlutterFlowTheme.of(context).bodyMediumFamily,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ],
    );
  }

  // ─── Outlets section ─────────────────────────────────────────────────
  Widget _buildOutletsSection() {
    return wrapWithModel(
      model: _model.pharmaTableModel,
      updateCallback: () => safeSetState(() {}),
      child: PharmaTableWidget(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: Chart placeholder with gradient area
// ─────────────────────────────────────────────────────────────────────────────
class _ChartPlaceholderPainter extends CustomPainter {
  final Color lineColor;
  final Color gradientTop;
  final Color gradientBottom;

  _ChartPlaceholderPainter({
    required this.lineColor,
    required this.gradientTop,
    required this.gradientBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 8.0;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    // Simulated data points (7 days)
    final points = [
      Offset(padding + w * 0.0, padding + h * 0.6),
      Offset(padding + w * 0.167, padding + h * 0.45),
      Offset(padding + w * 0.333, padding + h * 0.55),
      Offset(padding + w * 0.5, padding + h * 0.25),
      Offset(padding + w * 0.667, padding + h * 0.35),
      Offset(padding + w * 0.833, padding + h * 0.15),
      Offset(padding + w * 1.0, padding + h * 0.3),
    ];

    // Draw gradient fill
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      fillPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientTop, gradientBottom],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(fillPath, paint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots on data points
    for (final p in points) {
      canvas.drawCircle(
        p,
        4,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        p,
        2.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: Donut chart placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final innerRadius = outerRadius * 0.62;

    // Prescription Rx: 55% (blue)
    final rxPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius
      ..strokeCap = StrokeCap.round;
    final rxSweep = 55 / 100 * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
      -math.pi / 2,
      rxSweep,
      false,
      rxPaint,
    );

    // OTC: 30% (cyan)
    final otcPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius
      ..strokeCap = StrokeCap.round;
    final otcSweep = 30 / 100 * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
      -math.pi / 2 + rxSweep + 0.04,
      otcSweep,
      false,
      otcPaint,
    );

    // Supplements & Other: 15% (light blue)
    final suppPaint = Paint()
      ..color = const Color(0xFF93C5FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius
      ..strokeCap = StrokeCap.round;
    final suppSweep = 15 / 100 * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: (outerRadius + innerRadius) / 2),
      -math.pi / 2 + rxSweep + 0.04 + otcSweep + 0.04,
      suppSweep,
      false,
      suppPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
