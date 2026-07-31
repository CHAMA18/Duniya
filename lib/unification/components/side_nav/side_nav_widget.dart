import '/auth/firebase_auth/auth_util.dart';
import '/rbac/rbac.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/onboarding/onboarding_overlay.dart';
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

  /// Returns true if the current user is a Duniya network admin.
  /// Now powered by the centralized RBAC system (AccessControl).
  bool get _isDuniyaUser => AccessControl.isDuniyaUser(context);

  /// Returns the current user's resolved AppRole from the RBAC system.
  AppRole get _currentRole => AccessControl.currentRole(context);

  /// Returns true if the current user can see the given navigation item.
  bool _canSee(NavItem item) => AccessControl.canSeeNavItem(context, item);

  /// Returns true if the current user has the given permission.
  bool _hasPermission(Permission p) => AccessControl.hasPermission(context, p);

  /// Returns a human-readable role label.
  String get _roleLabel {
    switch (_currentRole) {
      case AppRole.owner:
        return 'Owner';
      case AppRole.outletManager:
        return 'Outlet Manager';
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
      padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 6.0),
      child: Align(
        alignment: AlignmentDirectional(-1.0, 0.0),
        child: Text(
          title,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                color: FlutterFlowTheme.of(context).alternate,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).labelSmallIsCustom,
              ),
        ),
      ),
    );
  }

  /// Helper to build a thin divider between sections.
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 4.0),
      child: Container(
        height: 1.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).lineColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(1.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isCollapsed = FFAppState().SidebarCollapsed;
    final sidebarWidth = isCollapsed ? 88.0 : 280.0;

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        border: Border(
          right: BorderSide(
            color: FlutterFlowTheme.of(context).lineColor,
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
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Logo & Brand ───
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        isCollapsed ? 16.0 : 20.0,
                        16.0,
                        isCollapsed ? 16.0 : 20.0,
                        4.0,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isCollapsed ? 48.0 : double.infinity,
                        height: isCollapsed ? 48.0 : null,
                        child: isCollapsed
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.asset(
                                    'assets/images/duniya_logo.png',
                                    width: 48.0,
                                    height: 48.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : Image.asset(
                                'assets/images/duniya_logo.png',
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                    ),

                    // ─── User Profile Card ───
                    if (!isCollapsed)
                      AuthUserStreamWidget(
                        builder: (context) => Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 4.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                12.0, 10.0, 12.0, 10.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color:
                                    FlutterFlowTheme.of(context).lineColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar circle
                                Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        FlutterFlowTheme.of(context)
                                            .primary
                                            .withValues(alpha: 0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (currentUserDisplayName?.isNotEmpty ==
                                              true)
                                          ? currentUserDisplayName![0]
                                              .toUpperCase()
                                          : '?',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleMediumFamily,
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleMediumIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUserDisplayName ?? 'User',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.01,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                      Text(
                                        _roleLabel,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmallFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .labelSmallIsCustom,
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
                              0.0, 8.0, 0.0, 4.0),
                          child: Tooltip(
                            message: currentUserDisplayName ?? 'User',
                            preferBelow: false,
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    FlutterFlowTheme.of(context)
                                        .primary
                                        .withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  (currentUserDisplayName?.isNotEmpty ==
                                          true)
                                      ? currentUserDisplayName![0]
                                          .toUpperCase()
                                      : '?',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily:
                                            FlutterFlowTheme.of(context)
                                                .titleMediumFamily,
                                        color: Colors.white,
                                        fontSize: 16.0,
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
                    SizedBox(height: 4.0),

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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Home';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Home',
                              activeIcon: Icon(
                                Icons.home_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.home_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage == 'Home',
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
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 0),
                                  ),
                                },
                              );

                              logFirebaseEvent('SidebarLink_update_app_state');
                              FFAppState().SelectedPage = 'My Pharmacies';
                            },
                            child: wrapWithModel(
                              model: _model.sidebarLinkModel3,
                              updateCallback: () => safeSetState(() {}),
                              child: SidebarLinkWidget(
                                linkText: 'My Pharmacies',
                                activeIcon: Icon(
                                  Icons.store_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
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
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 0),
                                  ),
                                },
                              );

                              logFirebaseEvent('SidebarLink_update_app_state');
                              FFAppState().SelectedPage = 'Human Resource';
                            },
                            child: wrapWithModel(
                              model: _model.sidebarLinkModel4,
                              updateCallback: () => safeSetState(() {}),
                              child: SidebarLinkWidget(
                                linkText: 'Human Resource',
                                activeIcon: Icon(
                                  Icons.person,
                                  color: FlutterFlowTheme.of(context).primary,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Finances';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel5,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: FFLocalizations.of(context).getText(
                                'r7lr2djm' /* Finances */,
                              ),
                              activeIcon: Icon(
                                Icons.attach_money_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.attach_money_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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
                                    transitionType: PageTransitionType.fade,
                                    duration: Duration(milliseconds: 0),
                                  ),
                                },
                              );

                              logFirebaseEvent('SidebarLink_update_app_state');
                              FFAppState().SelectedPage = 'Pending Approvals';
                            },
                            child: wrapWithModel(
                              model: _model.sidebarLinkModel19,
                              updateCallback: () => safeSetState(() {}),
                              child: SidebarLinkWidget(
                                linkText: 'Pending Approvals',
                                activeIcon: Icon(
                                  Icons.pending_actions,
                                  color: FlutterFlowTheme.of(context).primary,
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
                    // INVENTORY SECTION
                    // ============================================================
                    if (!isCollapsed) _buildSectionHeader('INVENTORY'),
                    // Store Inventory (RBAC)
                    if (_canSee(NavItem.storeInventory))
                      Tooltip(
                        message: 'Store Inventory',
                        preferBelow: false,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            logFirebaseEvent(
                                'SIDE_NAV_COMP_Container_2ctlhwc2_ON_TAP');
                            logFirebaseEvent('SidebarLink_navigate_to');

                            context.goNamed(
                              StoreInventoryWidget.routeName,
                              extra: <String, dynamic>{
                                '__transition_info__': TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Store Inventory';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Store Inventory',
                              activeIcon: Icon(
                                Icons.inventory_2,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.inventory_2_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage ==
                                  'Store Inventory',
                            ),
                          ),
                        ),
                      ),
                    // Product Catalogue (RBAC)
                    if (_canSee(NavItem.productCatalogue))
                      Tooltip(
                        message: 'Product Catalogue',
                        preferBelow: false,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            logFirebaseEvent(
                                'SIDE_NAV_COMP_Product_Catalogue_ON_TAP');
                            logFirebaseEvent('SidebarLink_navigate_to');

                            context.goNamed(
                              ProductMasterWidget.routeName,
                              extra: <String, dynamic>{
                                '__transition_info__': TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Product Catalogue';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel11,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Product Catalogue',
                              activeIcon: Icon(
                                Icons.medication,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.medication_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage ==
                                  'Product Catalogue',
                            ),
                          ),
                        ),
                      ),
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Stock Balances';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel9,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Stock Balances',
                              activeIcon: Icon(
                                Icons.inventory_2,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.inventory_2_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Stock Movements';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel10,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Stock Movements',
                              activeIcon: Icon(
                                Icons.swap_horiz,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.swap_horiz,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Stock Counts';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel14,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Stock Counts',
                              activeIcon: Icon(
                                Icons.fact_check,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.fact_check_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Goods Received';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel12,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Goods Received',
                              activeIcon: Icon(
                                Icons.local_shipping,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.local_shipping_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Sales / Dispensing';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel13,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Sales / Dispensing',
                              activeIcon: Icon(
                                Icons.point_of_sale,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.point_of_sale_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage ==
                                  'Sales / Dispensing',
                            ),
                          ),
                        ),
                      ),
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Batch & Expiry';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel15,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Batch & Expiry',
                              activeIcon: Icon(
                                Icons.calendar_month,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.calendar_month_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage ==
                                  'Batch & Expiry',
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Low Stock Alerts';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel16,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Low Stock Alerts',
                              activeIcon: Icon(
                                Icons.warning_amber_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.warning_amber_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Replenishment';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel17,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Replenishment',
                              activeIcon: Icon(
                                Icons.autorenew,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.autorenew_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive: FFAppState().SelectedPage ==
                                  'Replenishment',
                            ),
                          ),
                        ),
                      ),

                    // ─── Divider ───
                    if (_canSee(NavItem.auditLogs)) _buildDivider(),

                    // ============================================================
                    // COMPLIANCE SECTION
                    // ============================================================
                    if (_canSee(NavItem.auditLogs)) ...[
                      if (!isCollapsed) _buildSectionHeader('COMPLIANCE'),
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

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Audit Logs';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModelAuditLogs,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Audit Logs',
                              activeIcon: Icon(
                                Icons.history_rounded,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.history_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive:
                                  FFAppState().SelectedPage == 'Audit Logs',
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ─── Divider ───
                    if (_isDuniyaUser) _buildDivider(),

                    // ============================================================
                    // DUNIYA NETWORK SECTION (Duniya users only)
                    // ============================================================
                    if (_isDuniyaUser) ...[
                      if (!isCollapsed) _buildSectionHeader('DUNIYA NETWORK'),
                      // Duniya Pharmacies (RBAC)
                      if (_canSee(NavItem.duniyaPharmacies))
                        Tooltip(
                          message: 'Duniya Pharmacies',
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
                              context
                                  .goNamed(DuniyaPharmaciesWidget.routeName);
                              logFirebaseEvent('SidebarLink_update_app_state');
                              FFAppState().SelectedPage = 'Duniya Pharmacies';
                            },
                            child: wrapWithModel(
                              model: _model.sidebarLinkModel15dup,
                              updateCallback: () => safeSetState(() {}),
                              child: SidebarLinkWidget(
                                linkText: 'Duniya Pharmacies',
                                activeIcon: Icon(
                                  Icons.domain_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                inactiveIcon: Icon(
                                  Icons.domain_outlined,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                                isActive: FFAppState().SelectedPage ==
                                    'Duniya Pharmacies',
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
                              logFirebaseEvent('SidebarLink_update_app_state');
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
                                  color: FlutterFlowTheme.of(context).primary,
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
                              logFirebaseEvent('SidebarLink_update_app_state');
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
                                  color: FlutterFlowTheme.of(context).primary,
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
                              context
                                  .goNamed(NetworkAnalyticsWidget.routeName);
                              logFirebaseEvent('SidebarLink_update_app_state');
                              FFAppState().SelectedPage = 'Network Analytics';
                            },
                            child: wrapWithModel(
                              model: _model.sidebarLinkModel8,
                              updateCallback: () => safeSetState(() {}),
                              child: SidebarLinkWidget(
                                linkText: 'Network Analytics',
                                activeIcon: Icon(
                                  Icons.analytics_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
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
            // FOOTER SECTION (pinned to bottom)
            // ============================================================
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                border: Border(
                  top: BorderSide(
                    color: FlutterFlowTheme.of(context).lineColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dark Mode Toggle
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 44.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                              Theme.of(context).brightness == Brightness.dark
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
                                      safeSetState(() => _model
                                          .switchListTileValue = newValue);
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
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                    tileColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    activeTrackColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                    activeThumbColor:
                                        FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

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
                          logFirebaseEvent('SidebarLink_open_onboarding');
                          DuniyaOnboardingOverlay.show(context);
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 44.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                isCollapsed ? 12.0 : 24.0,
                                10.0,
                                isCollapsed ? 12.0 : 24.0,
                                10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 22.0,
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(width: 12.0),
                                  Text(
                                    'Take Tour',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
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
                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Settings';
                            logFirebaseEvent('SidebarLink_navigate_to');

                            context.goNamed(SettingsWidget.routeName);
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel7,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: 'Settings',
                              activeIcon: Icon(
                                Icons.settings,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.settings_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive:
                                  FFAppState().SelectedPage == 'Settings',
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
                          logFirebaseEvent('SidebarLink_navigate_to');
                          await launchURL('/landing.html#download');
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 44.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              isCollapsed ? 12.0 : 24.0,
                              10.0,
                              isCollapsed ? 12.0 : 24.0,
                              10.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 22.0,
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(width: 12.0),
                                  Text(
                                    'Download App',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
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
                          logFirebaseEvent('SIDE_NAV_COMP_Home_ON_TAP');
                          logFirebaseEvent('Home_auth');
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.signOut();
                          GoRouter.of(context).clearRedirectLocation();

                          logFirebaseEvent('Home_navigate_to');

                          context.goNamedAuth(
                              LoginUniWidget.routeName, context.mounted);
                        },
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 44.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                isCollapsed ? 12.0 : 24.0,
                                10.0,
                                isCollapsed ? 12.0 : 24.0,
                                10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 22.0,
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(width: 12.0),
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'w6w2khw7' /* Logout */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
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

                    const SizedBox(height: 4.0),

                    // Collapse Sidebar Button
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            constraints:
                                const BoxConstraints(minHeight: 40.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                isCollapsed ? 12.0 : 16.0,
                                8.0,
                                isCollapsed ? 12.0 : 16.0,
                                8.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: isCollapsed
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    isCollapsed
                                        ? Icons.chevron_right_rounded
                                        : Icons.chevron_left_rounded,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    size: 22.0,
                                  ),
                                  if (!isCollapsed) ...[
                                    const SizedBox(width: 12.0),
                                    Text(
                                      'Collapse',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
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
    );
  }
}
