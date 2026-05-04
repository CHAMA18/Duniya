import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
                          : Color(0xFF9299A1),
                      Color(0xFF9299A1),
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
                          : Color(0xFF9299A1),
                      Color(0xFF9299A1),
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
                          : Color(0xFF9299A1),
                      Color(0xFF9299A1),
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
                FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 30.0,
                  borderWidth: 1.0,
                  buttonSize: 50.0,
                  icon: Icon(
                    Icons.badge,
                    color: valueOrDefault<Color>(
                      FFAppState().SelectedPage == 'Human Resource'
                          ? FlutterFlowTheme.of(context).primary
                          : Color(0xFF9299A1),
                      Color(0xFF9299A1),
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
                ),
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
                          : Color(0xFF9299A1),
                      Color(0xFF9299A1),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
