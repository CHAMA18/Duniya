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
        width: 270.0,
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
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
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
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    height: 400.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
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
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            logFirebaseEvent(
                                'SIDE_NAV_COMP_Container_h8nxhb88_ON_TAP');
                            logFirebaseEvent('SidebarLink_navigate_to');

                            context.goNamed(
                              PharmacyToolsWidget.routeName,
                              extra: <String, dynamic>{
                                '__transition_info__': TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );

                            logFirebaseEvent('SidebarLink_update_app_state');
                            FFAppState().SelectedPage = 'Pharmacy Tools';
                          },
                          child: wrapWithModel(
                            model: _model.sidebarLinkModel6,
                            updateCallback: () => safeSetState(() {}),
                            child: SidebarLinkWidget(
                              linkText: FFLocalizations.of(context).getText(
                                '67w31bpw' /* Pharmacy Tools */,
                              ),
                              activeIcon: Icon(
                                Icons.build,
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                              inactiveIcon: Icon(
                                Icons.build_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              isActive:
                                  FFAppState().SelectedPage == 'Pharmacy Tools',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                      Container(
                        width: double.infinity,
                        height: 50.0,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              30.0, 0.0, 30.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  if (Theme.of(context).brightness ==
                                      Brightness.dark)
                                    Icon(
                                      Icons.wb_sunny_outlined,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 24.0,
                                    ),
                                  if (Theme.of(context).brightness ==
                                      Brightness.light)
                                    FaIcon(
                                      FontAwesomeIcons.moon,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 24.0,
                                    ),
                                ],
                              ),
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
                                          ? 'Switch to Dark'
                                          : 'Switch to Light',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyLargeIsCustom,
                                          ),
                                    ),
                                    tileColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    activeTrackColor:
                                        FlutterFlowTheme.of(context).accent1,
                                    dense: false,
                                    controlAffinity:
                                        ListTileControlAffinity.trailing,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            20.0, 0.0, 0.0, 0.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                30.0, 0.0, 0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                logFirebaseEvent(
                                    'SIDE_NAV_COMP_Row_k75zw53y_ON_TAP');
                                logFirebaseEvent('Row_auth');
                                GoRouter.of(context).prepareAuthEvent();
                                await authManager.signOut();
                                GoRouter.of(context).clearRedirectLocation();

                                context.goNamedAuth(RegisterUniWidget.routeName,
                                    context.mounted);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        size: 24.0,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            15.0, 0.0, 0.0, 0.0),
                                        child: Text(
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
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .titleMediumIsCustom,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
