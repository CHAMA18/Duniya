import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sidebar_link_model.dart';
export 'sidebar_link_model.dart';

class SidebarLinkWidget extends StatefulWidget {
  const SidebarLinkWidget({
    super.key,
    required this.activeIcon,
    required this.linkText,
    required this.inactiveIcon,
    this.isActive,
  });

  final Widget? activeIcon;
  final String? linkText;
  final Widget? inactiveIcon;
  final bool? isActive;

  @override
  State<SidebarLinkWidget> createState() => _SidebarLinkWidgetState();
}

class _SidebarLinkWidgetState extends State<SidebarLinkWidget> {
  late SidebarLinkModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SidebarLinkModel());

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
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    if (!widget.isActive!) widget.inactiveIcon!,
                    if (widget.isActive ?? true) widget.activeIcon!,
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 0.0, 0.0),
                  child: Text(
                    widget.linkText!,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          color: valueOrDefault<Color>(
                            FFAppState().SelectedPage == widget.linkText
                                ? FlutterFlowTheme.of(context).primary
                                : FlutterFlowTheme.of(context).secondaryText,
                            FlutterFlowTheme.of(context).secondaryText,
                          ),
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ),
              ],
            ),
            Container(
              width: 4.0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: valueOrDefault<Color>(
                  FFAppState().SelectedPage == widget.linkText
                      ? FlutterFlowTheme.of(context).primary
                      : FlutterFlowTheme.of(context).secondaryBackground,
                  FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
