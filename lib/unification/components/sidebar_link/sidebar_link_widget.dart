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

    final bool isActive = widget.isActive ?? false;
    final bool isSelected = FFAppState().SelectedPage == widget.linkText;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 44.0,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? FlutterFlowTheme.of(context).primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 4.0, 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Icon
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: isActive
                  ? widget.activeIcon!
                  : widget.inactiveIcon!,
            ),
            SizedBox(width: 12.0),
            // Link Text
            Expanded(
              child: Text(
                widget.linkText!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
            // Active indicator bar
            Container(
              width: 3.0,
              height: 20.0,
              decoration: BoxDecoration(
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
