import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/sidebar_link/sidebar_link_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 1.0, 0.0),
      child: Container(
        width: 280.0,
        height: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 300.0,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              color: FlutterFlowTheme.of(context).lineColor,
              offset: Offset(
                1.0,
                0.0,
              ),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo & Title
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/Vector.png',
                        width: 100.0,
                        height: 50.0,
                        fit: BoxFit.scaleDown,
                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          'xzjjeekv' /* MediTracker */,
                        ),
                        style:
                            FlutterFlowTheme.of(context).headlineLarge.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // MAIN SECTION
                // ============================================================
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 4.0),
                  child: Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Text(
                      'MAIN',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: FlutterFlowTheme.of(context)
                            .labelSmallFamily,
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .labelSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                // Home
                InkWell(
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
                // My Pharmacies (Owner only)
                if (valueOrDefault(currentUserDocument?.role, '') ==
                    'Owner')
                  AuthUserStreamWidget(
                    builder: (context) => InkWell(
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
                // Outlets
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'SIDE_NAV_COMP_Outlets_ON_TAP');
                    logFirebaseEvent('SidebarLink_navigate_to');

                    context.goNamed(
                      OutletsWidget.routeName,
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
                    FFAppState().SelectedPage = 'Outlets';
                  },
                  child: wrapWithModel(
                    model: _model.sidebarLinkModel18,
                    updateCallback: () => safeSetState(() {}),
                    child: SidebarLinkWidget(
                      linkText: 'Outlets',
                      activeIcon: Icon(
                        Icons.store,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      inactiveIcon: Icon(
                        Icons.store_outlined,
                        color:
                            FlutterFlowTheme.of(context).secondaryText,
                      ),
                      isActive: FFAppState().SelectedPage ==
                          'Outlets',
                    ),
                  ),
                ),
                // Human Resource (Owner only)
                if (valueOrDefault(currentUserDocument?.role, '') ==
                    'Owner')
                  AuthUserStreamWidget(
                    builder: (context) => InkWell(
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

                        logFirebaseEvent(
                            'SidebarLink_update_app_state');
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
                // Finances
                InkWell(
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
                      isActive: FFAppState().SelectedPage == 'Finances',
                    ),
                  ),
                ),

                // ============================================================
                // INVENTORY SECTION
                // ============================================================
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 4.0),
                  child: Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Text(
                      'INVENTORY',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: FlutterFlowTheme.of(context)
                            .labelSmallFamily,
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .labelSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                // Store Inventory
                InkWell(
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
                // Product Catalogue
                InkWell(
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
                // Stock Balances
                InkWell(
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
                // Stock Movements
                InkWell(
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
                // Stock Counts
                InkWell(
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

                // ============================================================
                // OPERATIONS SECTION
                // ============================================================
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 4.0),
                  child: Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Text(
                      'OPERATIONS',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: FlutterFlowTheme.of(context)
                            .labelSmallFamily,
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .labelSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                // Goods Received
                InkWell(
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
                // Sales / Dispensing
                InkWell(
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
                // Batch & Expiry
                InkWell(
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
                // Low Stock Alerts
                InkWell(
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
                // Replenishment
                InkWell(
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

                // ============================================================
                // TOOLS SECTION
                // ============================================================
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 4.0),
                  child: Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Text(
                      'TOOLS',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily: FlutterFlowTheme.of(context)
                            .labelSmallFamily,
                        color: FlutterFlowTheme.of(context).alternate,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .labelSmallIsCustom,
                      ),
                    ),
                  ),
                ),
                // VMI Dashboard
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 2.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      logFirebaseEvent(
                          'SIDE_NAV_COMP_VMI_Dashboard_ON_TAP');
                      logFirebaseEvent('SidebarLink_navigate_to');

                      context.goNamed(
                        VMIDashboardWidget.routeName,
                        extra: <String, dynamic>{
                          '__transition_info__': TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );

                      logFirebaseEvent('SidebarLink_update_app_state');
                      FFAppState().SelectedPage = 'VMI Dashboard';
                    },
                    child: wrapWithModel(
                      model: _model.sidebarLinkModel8,
                      updateCallback: () => safeSetState(() {}),
                      child: SidebarLinkWidget(
                        linkText: 'VMI Dashboard',
                        activeIcon: Icon(
                          Icons.dashboard_customize,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                        inactiveIcon: Icon(
                          Icons.dashboard_customize_outlined,
                          color:
                              FlutterFlowTheme.of(context).secondaryText,
                        ),
                        isActive: FFAppState().SelectedPage ==
                            'VMI Dashboard',
                      ),
                    ),
                  ),
                ),

                // ============================================================
                // BOTTOM SECTION (Dark Mode, Settings, Logout)
                // ============================================================
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dark Mode Toggle
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: 48.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 4.0, 16.0, 4.0),
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
                                size: 24.0,
                              ),
                              SizedBox(width: 12.0),
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
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    activeTrackColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Settings
                      InkWell(
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
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            isActive: FFAppState().SelectedPage == 'Settings',
                          ),
                        ),
                      ),
                      // Logout Button
                      InkWell(
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
                          constraints: BoxConstraints(
                            minHeight: 48.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 10.0, 24.0, 10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color:
                                      FlutterFlowTheme.of(context).error,
                                  size: 24.0,
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    'w6w2khw7' /* Logout */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily:
                                            FlutterFlowTheme.of(context)
                                                .titleMediumFamily,
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .error,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(
                                                    context)
                                                .titleMediumIsCustom,
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
          ),
        ),
      ),
    );
  }
}
