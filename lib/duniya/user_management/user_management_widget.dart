import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PulseUserManagementWidget extends StatefulWidget {
  const PulseUserManagementWidget({super.key});
  static String routeName = 'PulseUserManagement';
  static String routePath = '/pulse-user-management';

  @override
  State<PulseUserManagementWidget> createState() => _PulseUserManagementWidgetState();
}

class _PulseUserManagementWidgetState extends State<PulseUserManagementWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _search = '';
  String _roleFilter = 'All';
  String? _busyUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AccessControl.currentRole(context) != AppRole.duniyaAdmin) {
        context.goNamed(HomeWidget.routeName);
        return;
      }
      FFAppState().SelectedPage = 'User Management';
    });
  }

  bool _isPulseUser(UserRecord user) =>
      AppRole.isDuniyaAccountType(user.accountType);

  bool _matches(UserRecord user) {
    final query = _search.trim().toLowerCase();
    final role = user.role.trim().isEmpty ? 'Staff' : user.role.trim();
    return (_roleFilter == 'All' || role.toLowerCase() == _roleFilter.toLowerCase()) &&
        (query.isEmpty ||
            user.displayName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query));
  }

  Future<void> _manage(UserRecord user, String action, {String? role, bool? suspended}) async {
    setState(() => _busyUserId = user.reference.id);
    try {
      await FirebaseFunctions.instance.httpsCallable('managePulseUser').call({
        'userId': user.reference.id,
        'action': action,
        if (role != null) 'role': role,
        if (suspended != null) 'suspended': suspended,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User access updated.'), behavior: SnackBarBehavior.floating));
    } on FirebaseFunctionsException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Unable to update this user.'), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);
    return Title(
      title: 'Pulse User Management',
      color: theme.primary,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.primaryBackground,
        drawer: const Drawer(child: SideNavWidget()),
        body: SafeArea(
          child: Row(children: [
            if (responsiveVisibility(context: context, phone: false, tablet: false)) const SideNavWidget(),
            Expanded(child: Column(children: [
              TopNavWidget(openDrawer: () async => _scaffoldKey.currentState?.openDrawer()),
              Expanded(child: StreamBuilder<List<UserRecord>>(
                stream: queryUserRecord(),
                builder: (context, snapshot) {
                  final users = (snapshot.data ?? const <UserRecord>[]).where(_isPulseUser).where(_matches).toList()
                    ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
                  return _buildContent(theme, users, snapshot.connectionState == ConnectionState.waiting);
                },
              )),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildContent(FlutterFlowTheme theme, List<UserRecord> users, bool loading) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.all(constraints.maxWidth < 700 ? 20 : 32),
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.primary, const Color(0xFF2563EB)]), borderRadius: BorderRadius.circular(24)),
            child: Row(children: [
              const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 38),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Pulse User Management', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                SizedBox(height: 5),
                Text('Control network access, roles, and account status from one secure workspace.', style: TextStyle(color: Colors.white70, fontSize: 15)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _stat(theme, 'Pulse accounts', users.length.toString(), Icons.groups_rounded),
            _stat(theme, 'Administrators', users.where((u) => u.role.toLowerCase() == 'admin').length.toString(), Icons.verified_user_rounded),
            _stat(theme, 'Suspended', users.where((u) => u.snapshotData['account_status'] == 'suspended').length.toString(), Icons.pause_circle_outline_rounded),
          ]),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.lineColor)), child: Column(children: [
            TextField(onChanged: (value) => setState(() => _search = value), decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Search Pulse users by name or email', filled: true, fillColor: theme.primaryBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: SegmentedButton<String>(segments: const [ButtonSegment(value: 'All', label: Text('All')), ButtonSegment(value: 'Admin', label: Text('Admins')), ButtonSegment(value: 'Staff', label: Text('Staff'))], selected: {_roleFilter}, onSelectionChanged: (values) => setState(() => _roleFilter = values.first))),
          ])),
          const SizedBox(height: 16),
          if (loading) const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator())) else if (users.isEmpty) _empty(theme) else ...users.map((user) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _userRow(theme, user))),
        ]),
      )),
    ),
  );

  Widget _stat(FlutterFlowTheme theme, String label, String value, IconData icon) => Container(width: 210, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: theme.lineColor)), child: Row(children: [Icon(icon, color: theme.primary), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: theme.titleLarge), Text(label, style: theme.bodySmall)])]));
  Widget _empty(FlutterFlowTheme theme) => Container(width: double.infinity, padding: const EdgeInsets.all(48), decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: BorderRadius.circular(20)), child: const Column(children: [Icon(Icons.people_outline_rounded, size: 42), SizedBox(height: 12), Text('No Pulse users match this view')]));
  Widget _userRow(FlutterFlowTheme theme, UserRecord user) {
    final suspended = user.snapshotData['account_status'] == 'suspended';
    final busy = _busyUserId == user.reference.id;
    final name = user.displayName.isEmpty ? user.email : user.displayName;
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: theme.secondaryBackground, borderRadius: BorderRadius.circular(18), border: Border.all(color: suspended ? Colors.red.withValues(alpha: .35) : theme.lineColor)), child: Row(children: [
      CircleAvatar(backgroundColor: theme.primary.withValues(alpha: .12), child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(), style: TextStyle(color: theme.primary, fontWeight: FontWeight.w800))),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: theme.titleMedium), Text(user.email, style: theme.bodySmall)])),
      if (busy) const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)) else PopupMenuButton<String>(onSelected: (value) { if (value == 'admin' || value == 'staff') _manage(user, 'setRole', role: value); else _manage(user, 'setStatus', suspended: value == 'suspend'); }, itemBuilder: (context) => [PopupMenuItem(value: 'admin', child: const Text('Make administrator')), PopupMenuItem(value: 'staff', child: const Text('Make staff')), PopupMenuItem(value: suspended ? 'reinstate' : 'suspend', child: Text(suspended ? 'Reinstate account' : 'Suspend account'))]),
    ]));
  }
}
