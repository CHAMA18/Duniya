import '/auth/firebase_auth/auth_util.dart';
import '/rbac/rbac.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/onboarding/onboarding_overlay.dart';
import '/components/pulse_logo_widget.dart';
import '/unification/components/sidebar_link/sidebar_link_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'side_nav_model.dart';
export 'side_nav_model.dart';

class SideNavWidget extends StatefulWidget {
  const SideNavWidget({super.key});

  @override
  State<SideNavWidget> createState() => _SideNavWidgetState();
}

class _SideNavWidgetState extends State<SideNavWidget> {
  late SideNavModel _model;

  /// Returns true if the current user is a Pulse network admin.
  /// Now powered by the centralized RBAC system (AccessControl).
  bool get _isDuniyaUser => AccessControl.isDuniyaUser(context);

  /// Inventory has one portal-specific destination. Keeping this decision in
  /// the sidebar prevents both labels from ever appearing together.
  bool get _showsStoreInventory => !_isDuniyaUser;

  /// Returns the current user's resolved AppRole from the RBAC system.
  AppRole get _currentRole => AccessControl.currentRole(context);

  /// Returns true if the current user can see the given navigation item.
  bool _canSee(NavItem item) => AccessControl.canSeeNavItem(context, item);

  /// Returns a human-readable role label.
  String get _roleLabel {
    switch (_currentRole) {
      case AppRole.owner:
        return 'Owner';
      case AppRole.outletManager:
        return 'Pharmacy Manager';
      case AppRole.pharmacist:
        return 'Pharmacist';
      case AppRole.pharmacyTechnician:
        return 'Pharmacy Tech';
      case AppRole.cashier:
        return 'Cashier';
      case AppRole.salesAssistant:
        return 'Sales Assistant';
      case AppRole.duniyaAdmin:
        return 'Network Admin';
      case AppRole.duniyaStaff:
        return 'Network Staff';
      case AppRole.subscriber:
        return 'Subscriber';
      case AppRole.unknown:
        return 'User';
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SideNavModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  /// Helper to build a section header label (only shown when expanded).
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 6.0),
      child: Align(
        alignment: AlignmentDirectional(-1.0, 0.0),
        child: Row(
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                    color: FlutterFlowTheme.of(context)
                        .secondaryText
                        .withValues(alpha: 0.55),
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelSmallIsCustom,
                  ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Container(
                height: 1.0,
                color: FlutterFlowTheme.of(context)
                    .lineColor
                    .withValues(alpha: 0.22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build a thin divider between sections.
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 4.0),
      child: Container(
        height: 1.0,
        color: FlutterFlowTheme.of(context).lineColor.withValues(alpha: 0.18),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Expandable Inventory Section
  // ────────────────────────────────────────────────────────────────
  // Presents one portal-specific inventory destination so the parent and
  // child cannot duplicate the same section in the sidebar.
  // ────────────────────────────────────────────────────────────────

  bool _isInventoryExpanded = true;
  bool _isFooterExpanded = false;

  /// Whether any inventory sub-item is currently active.
  bool get _isInventoryChildActive => _showsStoreInventory
      ? FFAppState().SelectedPage == 'Store Inventory'
      : FFAppState().SelectedPage == 'Product Catalogue';

  /// The full expandable Inventory section.
  Widget _buildExpandableInventorySection(bool isCollapsed) {
    final isParentActive = _isInventoryChildActive;
    // Auto-expand when a child is active (user navigated to a sub-item)
    final isExpanded = _isInventoryExpanded || isParentActive;

    // ── Collapsed sidebar: single icon → navigates to Store Inventory ──
    if (isCollapsed) {
      return Tooltip(
        message: _showsStoreInventory ? 'Store Inventory' : 'Product Catalogue',
        preferBelow: false,
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            logFirebaseEvent('SIDE_NAV_COLLAPSED_INVENTORY_ON_TAP');
            logFirebaseEvent('SidebarLink_navigate_to');
            context.goNamed(
              _showsStoreInventory
                  ? StoreInventoryWidget.routeName
                  : ProductMasterWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
            FFAppState().SelectedPage =
                _showsStoreInventory ? 'Store Inventory' : 'Product Catalogue';
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 40.0),
            decoration: BoxDecoration(
              color: isParentActive
                  ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 7.0, 12.0, 7.0),
              child: Center(
                child: Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: isParentActive
                        ? FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.12)
                        : FlutterFlowTheme.of(context)
                            .primaryBackground
                            .withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 18.0,
                      height: 18.0,
                      child: Icon(
                        isParentActive
                            ? Icons.warehouse_rounded
                            : Icons.warehouse_outlined,
                        color: isParentActive
                            ? FlutterFlowTheme.of(context).primary
                            : FlutterFlowTheme.of(context).secondaryText,
                        size: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // ── Expanded sidebar: parent row + animated sub-items ──
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent row — opens the portal-specific inventory destination.
        MouseRegion(
          onEnter: (_) => safeSetState(() {}),
          onExit: (_) => safeSetState(() {}),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              final routeName = _showsStoreInventory
                  ? StoreInventoryWidget.routeName
                  : ProductMasterWidget.routeName;
              final pageLabel = _showsStoreInventory
                  ? 'Store Inventory'
                  : 'Product Catalogue';

              logFirebaseEvent('SIDE_NAV_INVENTORY_ON_TAP');
              context.goNamed(
                routeName,
                extra: <String, dynamic>{
                  '__transition_info__': TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.fade,
                    duration: Duration(milliseconds: 0),
                  ),
                },
              );
              FFAppState().SelectedPage = pageLabel;

              safeSetState(() {
                _isInventoryExpanded = true;
              });
            },
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 40.0),
              decoration: BoxDecoration(
                color: isParentActive
                    ? FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10.0, 7.0, 10.0, 7.0),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 34.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        color: isParentActive
                            ? FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.12)
                            : FlutterFlowTheme.of(context)
                                .primaryBackground
                                .withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: Icon(
                            isParentActive
                                ? Icons.warehouse_rounded
                                : Icons.warehouse_outlined,
                            color: isParentActive
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).secondaryText,
                            size: 18.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    // Label
                    Expanded(
                      child: Text(
                        _showsStoreInventory
                            ? 'Store Inventory'
                            : 'Product Catalogue',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: isParentActive
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 13.5,
                              letterSpacing: isParentActive ? -0.1 : 0.0,
                              fontWeight: isParentActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    // Animated chevron
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      turns: isExpanded ? -0.25 : 0.25,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: FlutterFlowTheme.of(context)
                            .secondaryText
                            .withValues(alpha: 0.5),
                        size: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isCollapsed = FFAppState().SidebarCollapsed;
    final sidebarWidth = isCollapsed ? 88.0 : 280.0;
    final theme = FlutterFlowTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // A DrawerController may build this widget before passing a finite
        // height. Supplying a viewport fallback keeps the scrollable/flex
        // layout valid during that transition and avoids unlaid render boxes.
        final sidebarHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;

        return SizedBox(
          width: sidebarWidth,
          height: sidebarHeight,
          child: Container(
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              border: Border(
                right: BorderSide(
                  color: theme.lineColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: sidebarWidth,
              child: Column(
                children: [
                  // ─── Scrollable Navigation Area ───
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ─── Logo & Brand ───
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              isCollapsed ? 12.0 : 16.0,
                              14.0,
                              isCollapsed ? 12.0 : 16.0,
                              6.0,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Padding(
                                padding:
                                    EdgeInsets.all(isCollapsed ? 10.0 : 8.0),
                                child: isCollapsed
                                    ? Center(
                                        child: SizedBox.square(
                                          dimension: 42.0,
                                          child: PulseLogoWidget(
                                            size: 42.0,
                                            showWordmark: false,
                                            color: theme.primary,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: PulseLogoWidget(
                                            size: 48.0,
                                            showWordmark: true,
                                            color: theme.primary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // ─── User Profile Card ───
                          if (!isCollapsed)
                            AuthUserStreamWidget(
                              builder: (context) => Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 2.0, 16.0, 8.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 10.0, 12.0, 10.0),
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: theme.lineColor
                                          .withValues(alpha: 0.14),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar circle
                                      Container(
                                        width: 36.0,
                                        height: 36.0,
                                        decoration: BoxDecoration(
                                          color: theme.primary,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (currentUserDisplayName
                                                        .isNotEmpty ==
                                                    true)
                                                ? currentUserDisplayName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: theme.titleMedium.override(
                                              fontFamily:
                                                  theme.titleMediumFamily,
                                              color: Colors.white,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w700,
                                              useGoogleFonts:
                                                  !theme.titleMediumIsCustom,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentUserDisplayName
                                                          .isNotEmpty ==
                                                      true
                                                  ? currentUserDisplayName
                                                  : 'User',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: theme.titleMedium.override(
                                                fontFamily:
                                                    theme.titleMediumFamily,
                                                color: theme.primaryText,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.2,
                                                fontSize: 13.5,
                                                useGoogleFonts:
                                                    !theme.titleMediumIsCustom,
                                              ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                                vertical: 2.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.primary
                                                    .withValues(alpha: 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: Text(
                                                _roleLabel,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: theme.bodySmall.override(
                                                  fontFamily:
                                                      theme.bodySmallFamily,
                                                  color: theme.primary,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.1,
                                                  useGoogleFonts:
                                                      !theme.bodySmallIsCustom,
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
                            )
                          else
                            // Collapsed: avatar only
                            AuthUserStreamWidget(
                              builder: (context) => Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 6.0, 0.0, 4.0),
                                child: Tooltip(
                                  message:
                                      currentUserDisplayName.isNotEmpty == true
                                          ? currentUserDisplayName
                                          : 'User',
                                  preferBelow: false,
                                  child: Container(
                                    width: 38.0,
                                    height: 38.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (currentUserDisplayName.isNotEmpty ==
                                                true)
                                            ? currentUserDisplayName[0]
                                                .toUpperCase()
                                            : '?',
                                        style: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMediumFamily,
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleMediumIsCustom,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // ─── Spacer ───
                          SizedBox(height: 8.0),

                          // ============================================================
                          // MAIN SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('MAIN'),
                          // Home (RBAC)
                          if (_canSee(NavItem.home))
                            Tooltip(
                              message: 'Home',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Container_xein5tez_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    HomeWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Home';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Home',
                                    activeIcon: Icon(
                                      Icons.home_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.home_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive:
                                        FFAppState().SelectedPage == 'Home',
                                  ),
                                ),
                              ),
                            ),
                          // My Pharmacies (Owner only)
                          if (_canSee(NavItem.myPharmacies))
                            AuthUserStreamWidget(
                              builder: (context) => Tooltip(
                                message: 'My Pharmacies',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_COMP_Container_tc3g9ivl_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');

                                    context.goNamed(
                                      MyPharmaciesWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 0),
                                        ),
                                      },
                                    );

                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage = 'My Pharmacies';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'My Pharmacies',
                                      activeIcon: Icon(
                                        Icons.store_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.store_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'My Pharmacies',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Human Resource (RBAC)
                          if (_canSee(NavItem.humanResource))
                            AuthUserStreamWidget(
                              builder: (context) => Tooltip(
                                message: 'Human Resource',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_COMP_Container_omwz15yo_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');

                                    context.goNamed(
                                      HumanResourceUniWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 0),
                                        ),
                                      },
                                    );

                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Human Resource';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Human Resource',
                                      activeIcon: Icon(
                                        Icons.person,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.person_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Human Resource',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Finances (RBAC)
                          if (_canSee(NavItem.finances))
                            Tooltip(
                              message: 'Finances',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Container_s5ds1au0_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    FinancesWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Finances';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText:
                                        FFLocalizations.of(context).getText(
                                      'r7lr2djm' /* Finances */,
                                    ),
                                    activeIcon: Icon(
                                      Icons.attach_money_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.attach_money_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive:
                                        FFAppState().SelectedPage == 'Finances',
                                  ),
                                ),
                              ),
                            ),
                          // Pending Approvals (RBAC)
                          if (_canSee(NavItem.pendingApprovals))
                            AuthUserStreamWidget(
                              builder: (context) => Tooltip(
                                message: 'Pending Approvals',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_COMP_PendingApprovals_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');

                                    context.goNamed(
                                      PendingApprovalsWidget.routeName,
                                      extra: <String, dynamic>{
                                        '__transition_info__': TransitionInfo(
                                          hasTransition: true,
                                          transitionType:
                                              PageTransitionType.fade,
                                          duration: Duration(milliseconds: 0),
                                        ),
                                      },
                                    );

                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Pending Approvals';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel19,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Pending Approvals',
                                      activeIcon: Icon(
                                        Icons.pending_actions,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.pending_actions_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Pending Approvals',
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // INVENTORY SECTION — Expandable parent with sub-items
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('INVENTORY'),
                          if (_canSee(NavItem.storeInventory) ||
                              _canSee(NavItem.productCatalogue))
                            _buildExpandableInventorySection(isCollapsed),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // STOCK SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('STOCK'),
                          // Stock Balances (RBAC)
                          if (_canSee(NavItem.stockBalances))
                            Tooltip(
                              message: 'Stock Balances',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Stock_Balances_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    StockBalancesWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Stock Balances';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel9,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Stock Balances',
                                    activeIcon: Icon(
                                      Icons.inventory_2,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.inventory_2_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Stock Balances',
                                  ),
                                ),
                              ),
                            ),
                          // Stock Movements (RBAC)
                          if (_canSee(NavItem.stockMovements))
                            Tooltip(
                              message: 'Stock Movements',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Stock_Movements_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    StockMovementsWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Stock Movements';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel10,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Stock Movements',
                                    activeIcon: Icon(
                                      Icons.swap_horiz,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.swap_horiz,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Stock Movements',
                                  ),
                                ),
                              ),
                            ),
                          // Stock Counts (RBAC)
                          if (_canSee(NavItem.stockCounts))
                            Tooltip(
                              message: 'Stock Counts',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Stock_Counts_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    StockCountsWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Stock Counts';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel14,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Stock Counts',
                                    activeIcon: Icon(
                                      Icons.fact_check,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.fact_check_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Stock Counts',
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // OPERATIONS SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('OPERATIONS'),
                          // Goods Received (RBAC)
                          if (_canSee(NavItem.goodsReceived))
                            Tooltip(
                              message: 'Goods Received',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Goods_Received_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    GoodsReceivedWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Goods Received';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel12,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Goods Received',
                                    activeIcon: Icon(
                                      Icons.local_shipping,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.local_shipping_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Goods Received',
                                  ),
                                ),
                              ),
                            ),
                          // Sales / Dispensing (RBAC)
                          if (_canSee(NavItem.salesDispensing))
                            Tooltip(
                              message: 'Sales / Dispensing',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Sales_Dispensing_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    SalesVMIWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage =
                                      'Sales / Dispensing';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel13,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Sales / Dispensing',
                                    activeIcon: Icon(
                                      Icons.point_of_sale,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.point_of_sale_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Sales / Dispensing',
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // MONITORING SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('MONITORING'),
                          // Batch & Expiry (RBAC)
                          if (_canSee(NavItem.batchesExpiry))
                            Tooltip(
                              message: 'Batch & Expiry',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Batch_Expiry_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    BatchesWidget.routeName,
                                    queryParameters: {
                                      'pharmacy': serializeParam(
                                        FFAppState().Pharm,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Batch & Expiry';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel15,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Batch & Expiry',
                                    activeIcon: Icon(
                                      Icons.calendar_month,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.calendar_month_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Batch & Expiry',
                                  ),
                                ),
                              ),
                            ),
                          // Expiry Tracking (RBAC)
                          if (_canSee(NavItem.expiryTracking))
                            Tooltip(
                              message: 'Expiry Tracking',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Expiry_Tracking_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    ExpiryTrackingWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Expiry Tracking';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelExpiryTracking,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Expiry Tracking',
                                    activeIcon: Icon(
                                      Icons.timer,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.timer_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Expiry Tracking',
                                  ),
                                ),
                              ),
                            ),
                          // Low Stock Alerts (RBAC)
                          if (_canSee(NavItem.lowStockAlerts))
                            Tooltip(
                              message: 'Low Stock Alerts',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Low_Stock_Alerts_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    LowStockAlertsWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage =
                                      'Low Stock Alerts';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel16,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Low Stock Alerts',
                                    activeIcon: Icon(
                                      Icons.warning_amber_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.warning_amber_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Low Stock Alerts',
                                  ),
                                ),
                              ),
                            ),
                          // Replenishment (RBAC)
                          if (_canSee(NavItem.replenishment))
                            Tooltip(
                              message: 'Replenishment',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Replenishment_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    ReplenishmentWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Replenishment';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModel17,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Replenishment',
                                    activeIcon: Icon(
                                      Icons.autorenew,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.autorenew_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Replenishment',
                                  ),
                                ),
                              ),
                            ),
                          // Cold Chain (RBAC)
                          if (_canSee(NavItem.coldChain))
                            Tooltip(
                              message: 'Cold Chain',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Cold_Chain_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    ColdChainWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Cold Chain';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelColdChain,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Cold Chain',
                                    activeIcon: Icon(
                                      Icons.ac_unit,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.ac_unit_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Cold Chain',
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // CLINICAL SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('CLINICAL'),
                          // Prescriptions (RBAC)
                          if (_canSee(NavItem.prescriptions))
                            Tooltip(
                              message: 'Prescriptions',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Prescriptions_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    PrescriptionsWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Prescriptions';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelPrescription,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Prescriptions',
                                    activeIcon: Icon(
                                      Icons.receipt_long,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.receipt_long_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Prescriptions',
                                  ),
                                ),
                              ),
                            ),
                          // Insurance (RBAC)
                          if (_canSee(NavItem.insurance))
                            Tooltip(
                              message: 'Insurance',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Insurance_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    InsuranceWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Insurance';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelInsurance,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Insurance',
                                    activeIcon: Icon(
                                      Icons.shield,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.shield_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Insurance',
                                  ),
                                ),
                              ),
                            ),
                          // Patient Records (RBAC)
                          if (_canSee(NavItem.patientRecords))
                            Tooltip(
                              message: 'Patient Records',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Patient_Records_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    PatientRecordsWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Patient Records';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelPatientRecords,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Patient Records',
                                    activeIcon: Icon(
                                      Icons.people,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.people_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Patient Records',
                                  ),
                                ),
                              ),
                            ),
                          // Drug Interactions (RBAC)
                          if (_canSee(NavItem.drugInteractions))
                            Tooltip(
                              message: 'Drug Interactions',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Drug_Interactions_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    DrugInteractionsWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage =
                                      'Drug Interactions';
                                },
                                child: wrapWithModel(
                                  model:
                                      _model.sidebarLinkModelDrugInteractions,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Drug Interactions',
                                    activeIcon: Icon(
                                      Icons.medication,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.medication_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Drug Interactions',
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          _buildDivider(),

                          // ============================================================
                          // PROCUREMENT SECTION
                          // ============================================================
                          if (!isCollapsed) _buildSectionHeader('PROCUREMENT'),
                          // Purchase Orders (RBAC)
                          if (_canSee(NavItem.purchaseOrders))
                            Tooltip(
                              message: 'Purchase Orders',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Purchase_Orders_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');
                                  context.goNamed(
                                    PurchaseOrdersWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );
                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Purchase Orders';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelPurchaseOrders,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Purchase Orders',
                                    activeIcon: Icon(
                                      Icons.shopping_cart,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Purchase Orders',
                                  ),
                                ),
                              ),
                            ),

                          // ─── Divider ───
                          if (_canSee(NavItem.auditLogs)) _buildDivider(),

                          // ============================================================
                          // ADMIN SECTION
                          // ============================================================
                          if (_canSee(NavItem.auditLogs)) ...[
                            if (!isCollapsed) _buildSectionHeader('ADMIN'),
                            // Audit Logs (RBAC)
                            Tooltip(
                              message: 'Audit Logs',
                              preferBelow: false,
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'SIDE_NAV_COMP_Audit_Logs_ON_TAP');
                                  logFirebaseEvent('SidebarLink_navigate_to');

                                  context.goNamed(
                                    AuditLogsWidget.routeName,
                                    extra: <String, dynamic>{
                                      '__transition_info__': TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                        duration: Duration(milliseconds: 0),
                                      ),
                                    },
                                  );

                                  logFirebaseEvent(
                                      'SidebarLink_update_app_state');
                                  FFAppState().SelectedPage = 'Audit Logs';
                                },
                                child: wrapWithModel(
                                  model: _model.sidebarLinkModelAuditLogs,
                                  updateCallback: () => safeSetState(() {}),
                                  child: SidebarLinkWidget(
                                    linkText: 'Audit Logs',
                                    activeIcon: Icon(
                                      Icons.history_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                    inactiveIcon: Icon(
                                      Icons.history_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                    isActive: FFAppState().SelectedPage ==
                                        'Audit Logs',
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // ─── Divider ───
                          if (_isDuniyaUser) _buildDivider(),

                          // ============================================================
                          // PULSE NETWORK SECTION (Duniya users only)
                          // ============================================================
                          if (_isDuniyaUser) ...[
                            if (!isCollapsed)
                              _buildSectionHeader('DUNIYA NETWORK'),
                            // Pulse Pharmacies (RBAC)
                            if (_canSee(NavItem.duniyaPharmacies))
                              Tooltip(
                                message: 'Pulse Pharmacies',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_Duniya_Pharmacies_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');
                                    context.goNamed(
                                        DuniyaPharmaciesWidget.routeName);
                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Pulse Pharmacies';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel15dup,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Pulse Pharmacies',
                                      activeIcon: Icon(
                                        Icons.domain_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.domain_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Pulse Pharmacies',
                                    ),
                                  ),
                                ),
                              ),
                            // Stock Balance Visibility (RBAC)
                            if (_canSee(NavItem.duniyaStockBalances))
                              Tooltip(
                                message: 'Stock Balance Visibility',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_Stock_Visibility_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');
                                    context.goNamed(
                                        DuniyaStockBalancesWidget.routeName);
                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Stock Balance Visibility';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel16dup,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Stock Balance Visibility',
                                      activeIcon: Icon(
                                        Icons.visibility_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.visibility_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Stock Balance Visibility',
                                    ),
                                  ),
                                ),
                              ),
                            // Onboarding Requests (RBAC)
                            if (_canSee(NavItem.duniyaOnboardingRequests))
                              Tooltip(
                                message: 'Onboarding Requests',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_Onboarding_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');
                                    context.goNamed(
                                        OnboardingRequestsWidget.routeName);
                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Onboarding Requests';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel17dup,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Onboarding Requests',
                                      activeIcon: Icon(
                                        Icons.pending_actions_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.pending_actions_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Onboarding Requests',
                                    ),
                                  ),
                                ),
                              ),
                            // Network Analytics (RBAC)
                            if (_canSee(NavItem.duniyaNetworkAnalytics))
                              Tooltip(
                                message: 'Network Analytics',
                                preferBelow: false,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent(
                                        'SIDE_NAV_Network_Analytics_ON_TAP');
                                    logFirebaseEvent('SidebarLink_navigate_to');
                                    context.goNamed(
                                        NetworkAnalyticsWidget.routeName);
                                    logFirebaseEvent(
                                        'SidebarLink_update_app_state');
                                    FFAppState().SelectedPage =
                                        'Network Analytics';
                                  },
                                  child: wrapWithModel(
                                    model: _model.sidebarLinkModel8,
                                    updateCallback: () => safeSetState(() {}),
                                    child: SidebarLinkWidget(
                                      linkText: 'Network Analytics',
                                      activeIcon: Icon(
                                        Icons.analytics_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      inactiveIcon: Icon(
                                        Icons.analytics_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      isActive: FFAppState().SelectedPage ==
                                          'Network Analytics',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ============================================================
                  // FOOTER SECTION (pinned to bottom, collapsible)
                  // ============================================================
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      border: Border(
                        top: BorderSide(
                          color: FlutterFlowTheme.of(context)
                              .lineColor
                              .withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 14.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Dark Mode Toggle (always visible) ──
                          Container(
                            width: double.infinity,
                            height: 44.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  isCollapsed ? 12.0 : 24.0,
                                  2.0,
                                  isCollapsed ? 12.0 : 16.0,
                                  2.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Icon(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Icons.wb_sunny_outlined
                                        : Icons.dark_mode_outlined,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    size: 22.0,
                                  ),
                                  if (!isCollapsed) ...[
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: SwitchListTile.adaptive(
                                          value: _model.switchListTileValue ??=
                                              Theme.of(context).brightness ==
                                                  Brightness.dark,
                                          onChanged: (newValue) async {
                                            safeSetState(() =>
                                                _model.switchListTileValue =
                                                    newValue);
                                            if (newValue) {
                                              logFirebaseEvent(
                                                  'SIDE_NAV_SwitchListTile_bct8t3vw_ON_TOGG');
                                              logFirebaseEvent(
                                                  'SwitchListTile_set_dark_mode_settings');
                                              setDarkModeSetting(
                                                  context, ThemeMode.dark);
                                            } else {
                                              logFirebaseEvent(
                                                  'SIDE_NAV_SwitchListTile_bct8t3vw_ON_TOGG');
                                              logFirebaseEvent(
                                                  'SwitchListTile_set_dark_mode_settings');
                                              setDarkModeSetting(
                                                  context, ThemeMode.light);
                                            }
                                          },
                                          title: Text(
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? 'Dark Mode'
                                                : 'Light Mode',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                          tileColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          activeTrackColor:
                                              FlutterFlowTheme.of(context)
                                                  .accent1,
                                          dense: true,
                                          controlAffinity:
                                              ListTileControlAffinity.trailing,
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          activeThumbColor:
                                              FlutterFlowTheme.of(context)
                                                  .primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // ── Collapsible Quick Access Section ──
                          if (!isCollapsed)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section header — tappable to expand/collapse
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    safeSetState(() {
                                      _isFooterExpanded = !_isFooterExpanded;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 36.0,
                                    decoration: BoxDecoration(
                                      color: _isFooterExpanded
                                          ? FlutterFlowTheme.of(context)
                                              .primary
                                              .withValues(alpha: 0.04)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 8.0, 16.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8.0, 6.0, 8.0, 6.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.grid_view_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate
                                                .withValues(alpha: 0.7),
                                            size: 16.0,
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: Text(
                                              'Quick Access',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate
                                                        .withValues(alpha: 0.7),
                                                    letterSpacing: 1.2,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10.5,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmallIsCustom,
                                                  ),
                                            ),
                                          ),
                                          AnimatedRotation(
                                            duration: const Duration(
                                                milliseconds: 220),
                                            curve: Curves.easeOutCubic,
                                            turns: _isFooterExpanded
                                                ? -0.25
                                                : 0.25,
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate
                                                      .withValues(alpha: 0.6),
                                              size: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // ── Animated expandable content ──
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 250),
                                  firstCurve: Curves.easeOutCubic,
                                  secondCurve: Curves.easeOutCubic,
                                  sizeCurve: Curves.easeOutCubic,
                                  crossFadeState: _isFooterExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4.0),

                                      // Take Tour
                                      Tooltip(
                                        message: 'Take Tour',
                                        preferBelow: false,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            logFirebaseEvent(
                                                'SIDE_NAV_COMP_TAKE_TOUR_ON_TAP');
                                            logFirebaseEvent(
                                                'SidebarLink_open_onboarding');
                                            DuniyaOnboardingOverlay.show(
                                                context);
                                          },
                                          child: _SidebarFooterItem(
                                            isCollapsed: isCollapsed,
                                            icon: Icons.school_rounded,
                                            iconColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            label: 'Take Tour',
                                            labelColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                          ),
                                        ),
                                      ),

                                      // Settings
                                      if (_canSee(NavItem.settings))
                                        Tooltip(
                                          message: 'Settings',
                                          preferBelow: false,
                                          child: InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              logFirebaseEvent(
                                                  'SIDE_NAV_COMP_Container_101euyv5_ON_TAP');
                                              logFirebaseEvent(
                                                  'SidebarLink_update_app_state');
                                              FFAppState().SelectedPage =
                                                  'Settings';
                                              logFirebaseEvent(
                                                  'SidebarLink_navigate_to');

                                              context.goNamed(
                                                  SettingsWidget.routeName);
                                            },
                                            child: wrapWithModel(
                                              model: _model.sidebarLinkModel7,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: SidebarLinkWidget(
                                                linkText: 'Settings',
                                                activeIcon: Icon(
                                                  Icons.settings,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                ),
                                                inactiveIcon: Icon(
                                                  Icons.settings_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                ),
                                                isActive:
                                                    FFAppState().SelectedPage ==
                                                        'Settings',
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Download App Link
                                      Tooltip(
                                        message: 'Download App',
                                        preferBelow: false,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'SIDE_NAV_COMP_DOWNLOAD_ON_TAP');
                                            logFirebaseEvent(
                                                'SidebarLink_navigate_to');
                                            await launchURL(
                                                '/landing.html#download');
                                          },
                                          child: _SidebarFooterItem(
                                            isCollapsed: isCollapsed,
                                            icon: Icons.download_rounded,
                                            iconColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            label: 'Download App',
                                            labelColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                          ),
                                        ),
                                      ),

                                      // Logout Button
                                      Tooltip(
                                        message: 'Logout',
                                        preferBelow: false,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'SIDE_NAV_COMP_Home_ON_TAP');
                                            logFirebaseEvent('Home_auth');
                                            GoRouter.of(context)
                                                .prepareAuthEvent();
                                            await authManager.signOut();
                                            GoRouter.of(context)
                                                .clearRedirectLocation();

                                            logFirebaseEvent(
                                                'Home_navigate_to');

                                            context.goNamedAuth(
                                                LoginUniWidget.routeName,
                                                context.mounted);
                                          },
                                          child: _SidebarFooterItem(
                                            isCollapsed: isCollapsed,
                                            icon: Icons.logout_rounded,
                                            iconColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                            label: FFLocalizations.of(context)
                                                .getText(
                                              'w6w2khw7' /* Logout */,
                                            ),
                                            labelColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            // Collapsed sidebar: show icon-only quick access items
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 4.0),
                                _CollapsedFooterIcon(
                                  icon: Icons.school_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  tooltip: 'Take Tour',
                                  onTap: () {
                                    DuniyaOnboardingOverlay.show(context);
                                  },
                                ),
                                if (_canSee(NavItem.settings))
                                  _CollapsedFooterIcon(
                                    icon: Icons.settings_outlined,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    tooltip: 'Settings',
                                    onTap: () {
                                      FFAppState().SelectedPage = 'Settings';
                                      context.goNamed(SettingsWidget.routeName);
                                    },
                                  ),
                                _CollapsedFooterIcon(
                                  icon: Icons.download_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  tooltip: 'Download App',
                                  onTap: () =>
                                      launchURL('/landing.html#download'),
                                ),
                                _CollapsedFooterIcon(
                                  icon: Icons.logout_rounded,
                                  color: FlutterFlowTheme.of(context).error,
                                  tooltip: 'Logout',
                                  onTap: () async {
                                    GoRouter.of(context).prepareAuthEvent();
                                    await authManager.signOut();
                                    GoRouter.of(context)
                                        .clearRedirectLocation();
                                    context.goNamedAuth(
                                        LoginUniWidget.routeName,
                                        context.mounted);
                                  },
                                ),
                              ],
                            ),

                          const SizedBox(height: 4.0),

                          // ── Collapse Sidebar Button (always visible) ──
                          Align(
                            alignment: Alignment.center,
                            child: Tooltip(
                              message: isCollapsed
                                  ? 'Expand Sidebar'
                                  : 'Collapse Sidebar',
                              preferBelow: false,
                              child: InkWell(
                                onTap: () {
                                  FFAppState().SidebarCollapsed = !isCollapsed;
                                  safeSetState(() {});
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  width: double.infinity,
                                  constraints:
                                      const BoxConstraints(minHeight: 40.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      isCollapsed ? 12.0 : 16.0,
                                      6.0,
                                      isCollapsed ? 12.0 : 16.0,
                                      6.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: isCollapsed
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                      children: [
                                        AnimatedRotation(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          curve: Curves.easeOutCubic,
                                          turns: 0.0,
                                          child: Icon(
                                            isCollapsed
                                                ? Icons.chevron_right_rounded
                                                : Icons.chevron_left_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText
                                                .withValues(alpha: 0.6),
                                            size: 18.0,
                                          ),
                                        ),
                                        if (!isCollapsed) ...[
                                          const SizedBox(width: 10.0),
                                          Text(
                                            'Collapse',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ],
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Sub-item hover builder — lightweight wrapper that provides
// hover state to sub-items without requiring a full model.
// ────────────────────────────────────────────────────────────────
class _SubItemHoverBuilder extends StatefulWidget {
  const _SubItemHoverBuilder({
    required this.isActive,
    required this.builder,
  });

  final bool isActive;
  final Widget Function(BuildContext context, bool isHovered) builder;

  @override
  State<_SubItemHoverBuilder> createState() => _SubItemHoverBuilderState();
}

class _SubItemHoverBuilderState extends State<_SubItemHoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovered = true),
      onExit: (_) => safeSetState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Footer item — consistent styling for Take Tour, Download, Logout, etc.
// ────────────────────────────────────────────────────────────────
class _SidebarFooterItem extends StatefulWidget {
  const _SidebarFooterItem({
    required this.isCollapsed,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
  });

  final bool isCollapsed;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;

  @override
  State<_SidebarFooterItem> createState() => _SidebarFooterItemState();
}

class _SidebarFooterItemState extends State<_SidebarFooterItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovered = true),
      onExit: (_) => safeSetState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 36.0),
        decoration: BoxDecoration(
          color: _isHovered
              ? FlutterFlowTheme.of(context)
                  .secondaryBackground
                  .withValues(alpha: 0.55)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            widget.isCollapsed ? 0.0 : 10.0,
            6.0,
            widget.isCollapsed ? 0.0 : 10.0,
            6.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
                size: 18.0,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 10.0),
                Text(
                  widget.label,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: widget.labelColor,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Collapsed footer icon — icon-only button for collapsed sidebar.
// ────────────────────────────────────────────────────────────────
class _CollapsedFooterIcon extends StatefulWidget {
  const _CollapsedFooterIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_CollapsedFooterIcon> createState() => _CollapsedFooterIconState();
}

class _CollapsedFooterIconState extends State<_CollapsedFooterIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      preferBelow: false,
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: widget.onTap,
        child: MouseRegion(
          onEnter: (_) => safeSetState(() => _isHovered = true),
          onExit: (_) => safeSetState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: _isHovered
                  ? FlutterFlowTheme.of(context)
                      .secondaryBackground
                      .withValues(alpha: 0.55)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9.0),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
