import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import 'package:flutter/material.dart';

/// Debug-only role testing page.
///
/// Allows switching between all pharmacy roles to preview what each
/// role sees in the sidebar. Only accessible in debug/profile mode.
class RoleTestWidget extends StatefulWidget {
  const RoleTestWidget({super.key});

  static String routeName = 'RoleTest';
  static String routePath = '/role-test';

  @override
  State<RoleTestWidget> createState() => _RoleTestWidgetState();
}

class _RoleTestWidgetState extends State<RoleTestWidget> {
  late AppRole _selectedRole;
  bool _sidebarPreview = true;

  @override
  void initState() {
    super.initState();
    _selectedRole = AccessControl.debugOverrideRole ?? AppRole.unknown;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve real role from Firestore once context is available
    if (_selectedRole == AppRole.unknown) {
      _selectedRole =
          AccessControl.debugOverrideRole ?? AccessControl.currentRole(context);
    }
  }

  @override
  void dispose() {
    // Always clean up on exit
    AccessControl.clearDebugRole();
    super.dispose();
  }

  void _applyRole(AppRole role) {
    setState(() {
      _selectedRole = role;
    });
    AccessControl.setDebugRole(role);
    // Force rebuild of the entire app tree
    safeSetState(() {});
  }

  void _resetRole() {
    setState(() {
      _selectedRole = AccessControl.currentRole(context);
    });
    AccessControl.clearDebugRole();
    safeSetState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          'Role Tester (Debug)',
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: theme.primaryText,
            fontWeight: FontWeight.w600,
            useGoogleFonts: !theme.headlineSmallIsCustom,
          ),
        ),
        actions: [
          if (AccessControl.hasDebugOverride)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
              child: FFButtonWidget(
                onPressed: _resetRole,
                text: 'Reset',
                icon: const Icon(Icons.refresh, size: 18),
                options: FFButtonOptions(
                  height: 36,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                  color: theme.error,
                  textStyle: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Active Override Banner ──
          if (AccessControl.hasDebugOverride)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: theme.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: theme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DEBUG MODE: Viewing as ${_selectedRole.displayName}',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.error,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Role Picker ──
          Expanded(
            flex: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a role to preview:',
                    style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pharmacy Roles
                  _buildRoleSection('Pharmacy Roles', [
                    AppRole.owner,
                    AppRole.outletManager,
                    AppRole.pharmacist,
                    AppRole.pharmacyTechnician,
                    AppRole.cashier,
                    AppRole.salesAssistant,
                  ], theme),

                  const SizedBox(height: 12),

                  // Pulse Roles
                  _buildRoleSection('Pulse Network Roles', [
                    AppRole.pulseAdmin,
                    AppRole.pulseStaff,
                  ], theme),

                  const SizedBox(height: 16),

                  // Toggle sidebar preview
                  SwitchListTile.adaptive(
                    value: _sidebarPreview,
                    onChanged: (v) => setState(() => _sidebarPreview = v),
                    title: Text(
                      'Show sidebar preview',
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.primaryText,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: theme.primary,
                    activeTrackColor: theme.primary.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: theme.lineColor),

          // ── Sidebar Preview ──
          if (_sidebarPreview)
            Expanded(
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  border: Border(
                    right: BorderSide(
                      color: theme.lineColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: const SideNavWidget(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(
    String title,
    List<AppRole> roles,
    dynamic theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roles.map((role) {
            final isActive = _selectedRole == role;
            return GestureDetector(
              onTap: () => _applyRole(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.primary
                      : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? theme.primary
                        : theme.lineColor.withValues(alpha: 0.3),
                    width: isActive ? 1.5 : 1.0,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: theme.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: isActive ? Colors.white : theme.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role.displayName,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: isActive ? Colors.white : theme.primaryText,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
