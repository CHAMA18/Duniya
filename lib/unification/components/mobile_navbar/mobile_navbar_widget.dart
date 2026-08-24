import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/rbac/rbac.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mobile_navbar_model.dart';
export 'mobile_navbar_model.dart';

class MobileNavbarWidget extends StatefulWidget {
  const MobileNavbarWidget({super.key});

  @override
  State<MobileNavbarWidget> createState() => _MobileNavbarWidgetState();
}

class _MobileNavbarWidgetState extends State<MobileNavbarWidget> {
  late MobileNavbarModel _model;

  /// RBAC helpers — powered by the centralized AccessControl system.
  bool _canSee(NavItem item) => AccessControl.canSeeNavItem(context, item);
  bool _hasPermission(Permission p) => AccessControl.hasPermission(context, p);

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MobileNavbarModel());

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

    return Visibility(
      visible: responsiveVisibility(
        context: context,
        tablet: false,
        tabletLandscape: false,
        desktop: false,
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 90.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Home (RBAC: everyone)
                if (_canSee(NavItem.home))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.home_rounded,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'DashboardUni'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent('MOBILE_NAVBAR_home_rounded_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Home';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // ─── Point Of Sale (RBAC: pharmacy users with posView permission) ───
                if (_canSee(NavItem.pointOfSale))
                AuthUserStreamWidget(
                  builder: (context) {
                    if (!_hasPermission(Permission.posView)) {
                      return const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () async {
                        logFirebaseEvent('MOBILE_NAVBAR_point_of_sale_ICN_ON_TAP');
                        logFirebaseEvent('IconButton_update_app_state');
                        FFAppState().SelectedPage = 'Point Of Sale';
                        safeSetState(() {});
                        logFirebaseEvent('IconButton_navigate_to');

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
                      },
                      child: Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).primary,
                              FlutterFlowTheme.of(context).primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.3),
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 28.0,
                        ),
                      ),
                    );
                  },
                ),
                // Store Inventory (RBAC)
                if (_canSee(NavItem.storeInventory))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.inbox_rounded,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Store Inventory'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent('MOBILE_NAVBAR_inbox_rounded_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Store Inventory';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // My Pharmacies (RBAC)
                if (_canSee(NavItem.myPharmacies))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.store_rounded,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Patient History'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent('MOBILE_NAVBAR_store_rounded_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'My Pharmacies';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Human Resource (RBAC)
                if (_canSee(NavItem.humanResource))
                AuthUserStreamWidget(
                  builder: (context) {
                    if (!_hasPermission(Permission.hrView)) {
                      return const SizedBox.shrink();
                    }

                    return FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 30.0,
                      borderWidth: 1.0,
                      buttonSize: 50.0,
                      icon: Icon(
                        Icons.badge,
                        color: valueOrDefault<Color>(
                          FFAppState().SelectedPage == 'Human Resource'
                              ? FlutterFlowTheme.of(context).primary
                              : FlutterFlowTheme.of(context).secondaryText,
                          FlutterFlowTheme.of(context).secondaryText,
                        ),
                        size: 24.0,
                      ),
                      onPressed: () async {
                        logFirebaseEvent('MOBILE_NAVBAR_COMP_badge_ICN_ON_TAP');
                        logFirebaseEvent('IconButton_update_app_state');
                        FFAppState().SelectedPage = 'Human Resource';
                        safeSetState(() {});
                        logFirebaseEvent('IconButton_navigate_to');

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
                      },
                    );
                  },
                ),
                // Finances (RBAC)
                if (_canSee(NavItem.finances))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.attach_money_rounded,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Finances'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_attach_money_rounded_ICN_O');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Finances';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // VMI Dashboard (RBAC)
                if (_canSee(NavItem.vmiDashboard))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.dashboard_customize_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'VMI Dashboard'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_vmi_dashboard_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'VMI Dashboard';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Drug Interactions (RBAC)
                if (_canSee(NavItem.drugInteractions))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.medication_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Drug Interactions'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_drug_interactions_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Drug Interactions';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Expiry Tracking (RBAC)
                if (_canSee(NavItem.expiryTracking))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.timer_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Expiry Tracking'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_expiry_tracking_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Expiry Tracking';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Purchase Orders (RBAC)
                if (_canSee(NavItem.purchaseOrders))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Purchase Orders'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_purchase_orders_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Purchase Orders';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Prescriptions (RBAC)
                if (_canSee(NavItem.prescriptions))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.receipt_long_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Prescriptions'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_prescriptions_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Prescriptions';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Insurance (RBAC)
                if (_canSee(NavItem.insurance))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.shield_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Insurance'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_insurance_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Insurance';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Cold Chain (RBAC)
                if (_canSee(NavItem.coldChain))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.ac_unit_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Cold Chain'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_cold_chain_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Cold Chain';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
                // Patient Records (RBAC)
                if (_canSee(NavItem.patientRecords))
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.people_outlined,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Patient Records'
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      FlutterFlowTheme.of(context).secondaryText,
                    ),
                    size: 24.0,
                  ),
                  onPressed: () async {
                    logFirebaseEvent(
                        'MOBILE_NAVBAR_patient_records_ICN_ON_TAP');
                    logFirebaseEvent('IconButton_update_app_state');
                    FFAppState().SelectedPage = 'Patient Records';
                    safeSetState(() {});
                    logFirebaseEvent('IconButton_navigate_to');

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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
