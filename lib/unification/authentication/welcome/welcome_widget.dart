import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = '/welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late WelcomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Welcome'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('WELCOME_PAGE_Welcome_ON_INIT_STATE');
      if (valueOrDefault(currentUserDocument?.role, '') != 'Owner') {
        if (currentUserDocument?.ownerRef == null) {
          logFirebaseEvent('Welcome_backend_call');

          await currentUserReference!.update(createUserRecordData(
            role: 'Owner',
          ));
          logFirebaseEvent('Welcome_auth');
          GoRouter.of(context).prepareAuthEvent();
          await authManager.signOut();
          GoRouter.of(context).clearRedirectLocation();

          logFirebaseEvent('Welcome_navigate_to');

          context.goNamedAuth(LoginUniWidget.routeName, context.mounted);

          return;
        } else {
          logFirebaseEvent('Welcome_backend_call');
          _model.own =
              await UserRecord.getDocumentOnce(currentUserDocument!.ownerRef!);
          if (_model.own?.stripeId == null || _model.own?.stripeId == '') {
            logFirebaseEvent('Welcome_alert_dialog');
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('No Subscription found '),
                    content:
                        Text('Make sure admin account has active subscription'),
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
            logFirebaseEvent('Welcome_auth');
            GoRouter.of(context).prepareAuthEvent();
            await authManager.signOut();
            GoRouter.of(context).clearRedirectLocation();

            logFirebaseEvent('Welcome_navigate_to');

            context.pushNamedAuth(LoginUniWidget.routeName, context.mounted);

            return;
          } else {
            logFirebaseEvent('Welcome_backend_call');
            _model.apiResultzh55 = await SubscriptionstatusCall.call(
              customer: _model.own?.stripeId,
            );

            if ((_model.apiResultzh55?.succeeded ?? true)) {
              if (SubscriptionstatusCall.status(
                    (_model.apiResultzh55?.jsonBody ?? ''),
                  ) ==
                  'active') {
                logFirebaseEvent('Welcome_backend_call');
                _model.customers = await PackageNameCall.call(
                  productid: SubscriptionstatusCall.packageName(
                    (_model.apiResultzh55?.jsonBody ?? ''),
                  ),
                );

                if ((_model.customers?.succeeded ?? true)) {
                  logFirebaseEvent('Welcome_update_app_state');
                  FFAppState().SubscriptionName = PackageNameCall.name(
                    (_model.customers?.jsonBody ?? ''),
                  ).toString();
                  FFAppState().EndDate = SubscriptionstatusCall.endDate(
                    (_model.apiResultzh55?.jsonBody ?? ''),
                  )!
                      .toString();
                } else {
                  logFirebaseEvent('Welcome_update_app_state');
                  FFAppState().SubscriptionName = 'null';
                  FFAppState().EndDate = '';
                }

                logFirebaseEvent('Welcome_navigate_to');

                context.goNamedAuth(HomeWidget.routeName, context.mounted);

                return;
              } else {
                logFirebaseEvent('Welcome_navigate_to');

                context.goNamedAuth(
                    SubscriptionWidget.routeName, context.mounted);

                return;
              }
            } else {
              logFirebaseEvent('Welcome_alert_dialog');
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return WebViewAware(
                    child: AlertDialog(
                      title: Text('Unable to confirm subscrition status'),
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
              logFirebaseEvent('Welcome_auth');
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();

              logFirebaseEvent('Welcome_navigate_to');

              context.pushNamedAuth(LoginUniWidget.routeName, context.mounted);

              return;
            }
          }
        }
      } else {
        if (currentUserDisplayName == '') {
          logFirebaseEvent('Welcome_navigate_to');

          context.goNamedAuth(OnboardingUniWidget.routeName, context.mounted);

          return;
        }
        logFirebaseEvent('Welcome_firestore_query');
        _model.pharmacyCount = await queryPharmacyRecordCount(
          parent: currentUserReference,
        );
        if (_model.pharmacyCount == 0) {
          logFirebaseEvent('Welcome_navigate_to');

          context.pushNamedAuth(
              CreatePharmacyWidget.routeName, context.mounted);

          return;
        } else {
          if (valueOrDefault(currentUserDocument?.stripeId, '') == '') {
            logFirebaseEvent('Welcome_alert_dialog');
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('No Subscription found '),
                    content: Text('Make account has active subscription'),
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
            logFirebaseEvent('Welcome_navigate_to');

            context.goNamedAuth(SubscriptionWidget.routeName, context.mounted);

            return;
          } else {
            logFirebaseEvent('Welcome_backend_call');
            _model.apiResultzh88 = await SubscriptionstatusCall.call(
              customer: valueOrDefault(currentUserDocument?.stripeId, ''),
            );

            if ((_model.apiResultzh88?.succeeded ?? true)) {
              if (SubscriptionstatusCall.status(
                    (_model.apiResultzh88?.jsonBody ?? ''),
                  ) ==
                  'active') {
                logFirebaseEvent('Welcome_backend_call');
                _model.customer = await PackageNameCall.call(
                  productid: SubscriptionstatusCall.packageName(
                    (_model.apiResultzh88?.jsonBody ?? ''),
                  ),
                );

                if ((_model.customer?.succeeded ?? true)) {
                  logFirebaseEvent('Welcome_update_app_state');
                  FFAppState().SubscriptionName = PackageNameCall.name(
                    (_model.customer?.jsonBody ?? ''),
                  ).toString();
                  FFAppState().EndDate = SubscriptionstatusCall.endDate(
                    (_model.apiResultzh88?.jsonBody ?? ''),
                  )!
                      .toString();
                  safeSetState(() {});
                }
                logFirebaseEvent('Welcome_navigate_to');

                context.goNamedAuth(HomeWidget.routeName, context.mounted);

                return;
              } else {
                logFirebaseEvent('Welcome_navigate_to');

                context.goNamedAuth(
                    SubscriptionWidget.routeName, context.mounted);

                return;
              }
            } else {
              logFirebaseEvent('Welcome_alert_dialog');
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return WebViewAware(
                    child: AlertDialog(
                      title: Text('Unable to confirm subscrition status'),
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
              logFirebaseEvent('Welcome_auth');
              GoRouter.of(context).prepareAuthEvent();
              await authManager.signOut();
              GoRouter.of(context).clearRedirectLocation();

              logFirebaseEvent('Welcome_navigate_to');

              context.pushNamedAuth(LoginUniWidget.routeName, context.mounted);

              return;
            }
          }
        }
      }
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
    context.watch<FFAppState>();

    return Title(
        title: 'Welcome',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: SafeArea(
              top: true,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.loadingSpinnerModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LoadingSpinnerWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
