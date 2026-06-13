import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'sale_details_model.dart';
export 'sale_details_model.dart';

class SaleDetailsWidget extends StatefulWidget {
  const SaleDetailsWidget({
    super.key,
    this.parameter1,
    required this.parameter2,
    required this.saleId,
    required this.pharmacy,
  });

  final String? parameter1;
  final String? parameter2;
  final String? saleId;
  final DocumentReference? pharmacy;

  @override
  State<SaleDetailsWidget> createState() => _SaleDetailsWidgetState();
}

class _SaleDetailsWidgetState extends State<SaleDetailsWidget> {
  late SaleDetailsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaleDetailsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: true,
      cursor: SystemMouseCursors.click ?? MouseCursor.defer,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(10.0, 16.0, 10.0, 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                widget.saleId!,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ),
            if (responsiveVisibility(
              context: context,
              phone: false,
            ))
              Expanded(
                flex: 1,
                child: StreamBuilder<PharmacyRecord>(
                  stream: PharmacyRecord.getDocument(widget.pharmacy!),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: SpinKitRing(
                            color: FlutterFlowTheme.of(context).primary,
                            size: 100.0,
                          ),
                        ),
                      );
                    }

                    final textPharmacyRecord = snapshot.data!;

                    return Text(
                      textPharmacyRecord.name,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    );
                  },
                ),
              ),
            if (responsiveVisibility(
              context: context,
              phone: false,
            ))
              Expanded(
                child: Text(
                  widget.parameter1!,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ),
            Expanded(
              child: Text(
                widget.parameter2!,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ),
          ],
        ),
      ),
      onEnter: ((event) async {
        safeSetState(() => _model.mouseRegionHovered = true);
      }),
      onExit: ((event) async {
        safeSetState(() => _model.mouseRegionHovered = false);
      }),
    );
  }
}
