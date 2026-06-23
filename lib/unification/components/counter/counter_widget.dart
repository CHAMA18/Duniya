import '/flutter_flow/flutter_flow_count_controller.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'counter_model.dart';
export 'counter_model.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({
    super.key,
    this.parameter1,
    this.parameter3,
    required this.productQuantity,
  });

  final String? parameter1;
  final double? parameter3;
  final int? productQuantity;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late CounterModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CounterModel());

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

    return Container(
      width: 160.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 2.0,
        ),
      ),
      child: FlutterFlowCountController(
        decrementIconBuilder: (enabled) => FaIcon(
          FontAwesomeIcons.minus,
          color: enabled
              ? FlutterFlowTheme.of(context).secondaryText
              : FlutterFlowTheme.of(context).alternate,
          size: 20.0,
        ),
        incrementIconBuilder: (enabled) => FaIcon(
          FontAwesomeIcons.plus,
          color: enabled
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).alternate,
          size: 20.0,
        ),
        countBuilder: (count) => Text(
          count.toString(),
          style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).titleLargeIsCustom,
              ),
        ),
        count: _model.countControllerValue ??= 0,
        updateCount: (count) async {
          safeSetState(() => _model.countControllerValue = count);
          logFirebaseEvent('COUNTER_CountController_1hlvehdj_ON_FORM');
          var _shouldSetState = false;
          if (FFAppState().Cart.displayName.contains(widget.parameter1)) {
            if (_model.countControllerValue! > widget.productQuantity!
                ? true
                : false) {
              logFirebaseEvent('CountController_alert_dialog');
              await showDialog(
                context: context,
                builder: (alertDialogContext) {
                  return WebViewAware(
                    child: AlertDialog(
                      title: Text('Out Of Stock'),
                      content: Text('This Batch has Limited stock'),
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
              if (_shouldSetState) safeSetState(() {});
              return;
            }
            logFirebaseEvent('CountController_custom_action');
            _model.indexOfUpdate = await actions.newCustomAction(
              widget.parameter1!,
              FFAppState().Cart.displayName.toList(),
            );
            _shouldSetState = true;
            logFirebaseEvent('CountController_update_app_state');
            FFAppState().updateCartStruct(
              (e) => e
                ..updateQuantity(
                  (e) =>
                      e[_model.indexOfUpdate!] = _model.countControllerValue!,
                ),
            );
            FFAppState().update(() {});
            if (_shouldSetState) safeSetState(() {});
            return;
          } else {
            logFirebaseEvent('CountController_update_app_state');
            FFAppState().updateCartStruct(
              (e) => e
                ..updateDisplayName(
                  (e) => e.add(widget.parameter1!),
                )
                ..updateQuantity(
                  (e) => e.add(_model.countControllerValue!),
                )
                ..updatePrice(
                  (e) => e.add(widget.parameter3!),
                ),
            );
            FFAppState().update(() {});
            if (_shouldSetState) safeSetState(() {});
            return;
          }

          if (_shouldSetState) safeSetState(() {});
        },
        stepSize: 1,
        minimum: 0,
      ),
    );
  }
}
