import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'awaiting_payment_model.dart';
export 'awaiting_payment_model.dart';

class AwaitingPaymentWidget extends StatefulWidget {
  const AwaitingPaymentWidget({super.key});

  static String routeName = 'AwaitingPayment';
  static String routePath = '/awaitingPayment';

  @override
  State<AwaitingPaymentWidget> createState() => _AwaitingPaymentWidgetState();
}

class _AwaitingPaymentWidgetState extends State<AwaitingPaymentWidget> {
  late AwaitingPaymentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AwaitingPaymentModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'AwaitingPayment'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('AWAITING_PAYMENT_AwaitingPayment_ON_INIT');
      while (true) {
        logFirebaseEvent('AwaitingPayment_backend_call');
        _model.stripeuser = await GetStripeUserCall.call(
          email: currentUserEmail,
        );

        if ((_model.stripeuser?.succeeded ?? true)) {
          if (GetStripeUserCall.customerId(
                (_model.stripeuser?.jsonBody ?? ''),
              ) !=
              'null') {
            logFirebaseEvent('AwaitingPayment_backend_call');

            await currentUserReference!.update(createUserRecordData(
              stripeId: GetStripeUserCall.customerId(
                (_model.stripeuser?.jsonBody ?? ''),
              ),
            ));
            logFirebaseEvent('AwaitingPayment_alert_dialog');
            await showDialog(
              context: context,
              builder: (alertDialogContext) {
                return WebViewAware(
                  child: AlertDialog(
                    title: Text('Congratulations'),
                    content: Text('Your subscription was a success'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(alertDialogContext),
                        child: Text('Continue to application'),
                      ),
                    ],
                  ),
                );
              },
            );
            logFirebaseEvent('AwaitingPayment_navigate_to');

            context.goNamed(WelcomeWidget.routeName);

            return;
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
    return Title(
        title: 'AwaitingPayment',
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
                      child: LoadingSpinnerWidget(
                        loadingMessage: 'Awaiting Payment',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
