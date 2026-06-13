import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'no_record_component_model.dart';
export 'no_record_component_model.dart';

class NoRecordComponentWidget extends StatefulWidget {
  const NoRecordComponentWidget({
    super.key,
    String? message,
  }) : this.message = message ?? 'No items found';

  final String message;

  @override
  State<NoRecordComponentWidget> createState() =>
      _NoRecordComponentWidgetState();
}

class _NoRecordComponentWidgetState extends State<NoRecordComponentWidget> {
  late NoRecordComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NoRecordComponentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: FlutterFlowTheme.of(context).primary,
            size: 80.0,
          ),
          Text(
            widget.message,
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleLargeIsCustom,
                ),
          ),
        ],
      ),
    );
  }
}
