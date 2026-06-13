import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'web_create_user_model.dart';
export 'web_create_user_model.dart';

class WebCreateUserWidget extends StatefulWidget {
  const WebCreateUserWidget({
    super.key,
    required this.websiteUrl,
    required this.email,
    required this.pharmId,
  });

  final String? websiteUrl;
  final String? email;
  final DocumentReference? pharmId;

  static String routeName = 'WebCreateUser';
  static String routePath = '/webCreateUser';

  @override
  State<WebCreateUserWidget> createState() => _WebCreateUserWidgetState();
}

class _WebCreateUserWidgetState extends State<WebCreateUserWidget> {
  late WebCreateUserModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WebCreateUserModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'WebCreateUser'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('WEB_CREATE_USER_WebCreateUser_ON_INIT_ST');
      logFirebaseEvent('WebCreateUser_wait__delay');
      await Future.delayed(
        Duration(
          milliseconds: 3000,
        ),
      );
      logFirebaseEvent('WebCreateUser_firestore_query');
      _model.uu = await queryUserRecordOnce(
        queryBuilder: (userRecord) => userRecord.where(
          'email',
          isEqualTo: widget.email,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      if (_model.uu?.email != null && _model.uu?.email != '') {
        logFirebaseEvent('WebCreateUser_alert_dialog');
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: Text('Error'),
                content: Text('Error creating User'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext),
                    child: Text('Ok'),
                  ),
                ],
              ),
            );
          },
        );
        logFirebaseEvent('WebCreateUser_navigate_to');

        context.goNamed(HumanResourceUniWidget.routeName);

        return;
      }
      logFirebaseEvent('WebCreateUser_wait__delay');
      await Future.delayed(
        Duration(
          milliseconds: 2500,
        ),
      );
      logFirebaseEvent('WebCreateUser_backend_call');

      await PharmacyStaffRecord.createDoc(currentUserReference!)
          .set(createPharmacyStaffRecordData(
        pharmacyId: widget.pharmId,
        staffId: _model.uu?.reference,
      ));
      logFirebaseEvent('WebCreateUser_alert_dialog');
      await showDialog(
        context: context,
        builder: (alertDialogContext) {
          return WebViewAware(
            child: AlertDialog(
              title: Text('Staff User Created'),
              content: Text('You can view the user on the user page'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: Text('Ok'),
                ),
              ],
            ),
          );
        },
      );
      logFirebaseEvent('WebCreateUser_navigate_to');

      context.pushNamed(HumanResourceUniWidget.routeName);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'WebCreateUser',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlutterFlowWebView(
                    content: widget.websiteUrl!,
                    bypass: false,
                    height: MediaQuery.sizeOf(context).height * 0.1,
                    verticalScroll: false,
                    horizontalScroll: false,
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 120.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/Irh80RlodL.gif',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          FFLocalizations.of(context).getText(
                            'fhff1mx3' /* Loading */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
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
                ],
              ),
            ),
          ),
        ));
  }
}
