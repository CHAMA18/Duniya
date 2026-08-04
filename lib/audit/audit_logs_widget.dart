import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'audit_logs_model.dart';
export 'audit_logs_model.dart';

class AuditLogsWidget extends StatefulWidget {
  const AuditLogsWidget({super.key});

  static String routeName = 'AuditLogs';
  static String routePath = '/auditLogs';

  @override
  State<AuditLogsWidget> createState() => _AuditLogsWidgetState();
}

class _AuditLogsWidgetState extends State<AuditLogsWidget> {
  late AuditLogsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuditLogsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'AuditLogs'});
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
    final theme = FlutterFlowTheme.of(context);

    return Title(
      title: 'Audit Logs',
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          drawer: Drawer(
            child: wrapWithModel(
              model: _model.sideNavModel,
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
            ),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.sideNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const SideNavWidget(),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const TopNavWidget(),
                      ),
                      Expanded(
                        child: _buildContent(theme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FlutterFlowTheme theme) {
    return Container(
      color: theme.primaryBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: theme.primary.withValues(alpha: 0.5),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Audit Logs',
                style: theme.headlineMedium.override(
                  fontFamily: theme.headlineMediumFamily,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts: !theme.headlineMediumIsCustom,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track every change across your pharmacy. As your team uses the application, every change will be recorded here automatically.',
                textAlign: TextAlign.center,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.lineColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Audit logging is being set up. Entries will appear here soon.',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
