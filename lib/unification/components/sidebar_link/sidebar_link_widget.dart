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
    final theme = FlutterFlowTheme.of(context);
    final primary = theme.primary;

    // ── Background: subtle active fill, transparent otherwise ──
    final bgColor = isSelected
        ? primary.withValues(alpha: 0.08)
        : _isHovered
            ? theme.secondaryBackground.withValues(alpha: 0.60)
            : Colors.transparent;

    // ── Border: only visible on active or hover ──
    final borderColor = isSelected
        ? primary.withValues(alpha: 0.12)
        : _isHovered
            ? theme.lineColor.withValues(alpha: 0.20)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => safeSetState(() => _isHovered = true),
      onExit: (_) => safeSetState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 40.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.06),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            isCollapsed ? 0.0 : 10.0,
            0.0,
            isCollapsed ? 0.0 : 10.0,
            0.0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              // ── Icon container ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 34.0,
                height: 34.0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.12)
                      : _isHovered
                          ? primary.withValues(alpha: 0.06)
                          : theme.primaryBackground.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Center(
                  child: SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: isSelected
                        ? (widget.activeIcon ?? const SizedBox.shrink())
                        : (widget.inactiveIcon ?? const SizedBox.shrink()),
                  ),
                ),
              ),

              // ── Label ──
              if (!isCollapsed) ...[
                const SizedBox(width: 10.0),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: isSelected
                          ? theme.primaryText
                          : _isHovered
                              ? theme.primaryText
                              : theme.secondaryText,
                      fontSize: 13.5,
                      letterSpacing: isSelected ? -0.1 : 0.0,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                    child: Text(
                      widget.linkText ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
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
