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
  bool _isHovered = false;

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

    final bool isSelected = FFAppState().SelectedPage == widget.linkText;
    final bool isCollapsed = FFAppState().SidebarCollapsed;

    // Determine background color based on state
    Color bgColor;
    if (isSelected) {
      bgColor = FlutterFlowTheme.of(context).primary.withValues(alpha: 0.12);
    } else if (_isHovered) {
      bgColor =
          FlutterFlowTheme.of(context).primaryBackground.withValues(alpha: 0.8);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovered = true),
      onExit: (_) => safeSetState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 40.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            isCollapsed ? 12.0 : 16.0,
            7.0,
            isCollapsed ? 12.0 : 10.0,
            7.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              // Icon with background circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? FlutterFlowTheme.of(context)
                          .primary
                          .withValues(alpha: 0.18)
                      : _isHovered
                          ? FlutterFlowTheme.of(context)
                              .primary
                              .withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: isSelected
                        ? widget.activeIcon!
                        : widget.inactiveIcon!,
                  ),
                ),
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 12.0),
                // Link Text
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: isSelected
                              ? FlutterFlowTheme.of(context).primary
                              : _isHovered
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: isSelected ? -0.01 : 0.0,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                    child: Text(
                      widget.linkText!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                // Active indicator bar — Duniya purple accent
                if (isSelected)
                  Container(
                    width: 3.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
