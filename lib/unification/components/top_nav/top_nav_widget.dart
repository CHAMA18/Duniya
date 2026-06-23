import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/profile_image/profile_image_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'top_nav_model.dart';
export 'top_nav_model.dart';

class TopNavWidget extends StatefulWidget {
  const TopNavWidget({
    super.key,
    required this.openDrawer,
  });

  final Future Function()? openDrawer;

  @override
  State<TopNavWidget> createState() => _TopNavWidgetState();
}

class _TopNavWidgetState extends State<TopNavWidget> {
  late TopNavModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TopNavModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Container(
            height: 58.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              boxShadow: [
                BoxShadow(
                  color: FlutterFlowTheme.of(context)
                      .primary
                      .withValues(alpha: 0.04),
                  blurRadius: 18.0,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border(
                bottom: BorderSide(
                  color: FlutterFlowTheme.of(context).lineColor,
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (responsiveVisibility(
                        context: context,
                        tabletLandscape: false,
                        desktop: false,
                      ))
                        FlutterFlowIconButton(
                          borderRadius: 12.0,
                          borderWidth: 0.0,
                          buttonSize: 40.0,
                          icon: Icon(
                            Icons.menu_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            logFirebaseEvent(
                                'TOP_NAV_COMP_menu_rounded_ICN_ON_TAP');
                            logFirebaseEvent('IconButton_execute_callback');
                            await widget.openDrawer?.call();
                          },
                        ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Search button
                      FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 12.0,
                        borderWidth: 0.0,
                        buttonSize: 36.0,
                        fillColor: FlutterFlowTheme.of(context)
                            .secondaryBackground
                            .withValues(alpha: 0.92),
                        icon: Icon(
                          Icons.search_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 20.0,
                        ),
                        onPressed: () async {
                          logFirebaseEvent('TOP_NAV_search_ICN_ON_TAP');
                        },
                      ),
                      SizedBox(width: 8.0),
                      // Notification bell with purple accent
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 12.0,
                          borderWidth: 0.0,
                          buttonSize: 36.0,
                          fillColor: Colors.transparent,
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            logFirebaseEvent(
                                'TOP_NAV_notifications_active_ICN_ON_TAP');
                            logFirebaseEvent('IconButton_navigate_to');

                            context.pushNamed(NotificationsWidget.routeName);
                          },
                        ),
                      ),
                      SizedBox(width: 8.0),
                      // Profile
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () async {
                          logFirebaseEvent(
                              'TOP_NAV_COMP_Container_f28jowjh_ON_TAP');
                          logFirebaseEvent('ProfileImage_navigate_to');

                          context.pushNamed(ProfilUniWidget.routeName);
                        },
                        child: wrapWithModel(
                          model: _model.profileImageModel,
                          updateCallback: () => safeSetState(() {}),
                          child: ProfileImageWidget(
                            radius: 36.0,
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
      ],
    );
  }
}
