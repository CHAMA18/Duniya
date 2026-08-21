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
  State<PulseUserManagementWidget> createState() =>
      _PulseUserManagementWidgetState();
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
      if (AccessControl.currentRole(context) != AppRole.pulseAdmin) {
        context.goNamed(HomeWidget.routeName);
        return;
      }
      FFAppState().SelectedPage = 'User Management';
    });
  }

  bool _isPulseUser(UserRecord user) =>
      AppRole.isPulseAccountType(user.accountType);

  bool _matches(UserRecord user) {
    final query = _search.trim().toLowerCase();
    final role = user.role.trim().isEmpty ? 'Staff' : user.role.trim();
    return (_roleFilter == 'All' ||
            role.toLowerCase() == _roleFilter.toLowerCase()) &&
        (query.isEmpty ||
            user.displayName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query));
  }

  Future<void> _manage(UserRecord user, String action,
      {String? role, bool? suspended}) async {
    setState(() => _busyUserId = user.reference.id);
    try {
      await FirebaseFunctions.instance.httpsCallable('managePulseUser').call({
        'userId': user.reference.id,
        'action': action,
        if (role != null) 'role': role,
        if (suspended != null) 'suspended': suspended,
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User access updated.'),
            behavior: SnackBarBehavior.floating));
    } on FirebaseFunctionsException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.message ?? 'Unable to update this user.'),
            behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _busyUserId = null);
    }
  }

  Future<void> _showInviteUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    var role = 'staff';
    var isSubmitting = false;
    String? errorMessage;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Material(
              color: Colors.white,
              elevation: 24,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EAFE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded,
                              color: Color(0xFF9900FF), size: 27),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Invite Pulse user',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827))),
                              SizedBox(height: 3),
                              Text(
                                  'They will receive a secure password-setup email.',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF667085))),
                            ])),
                        IconButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Close'),
                      ]),
                      const SizedBox(height: 26),
                      _inviteField(
                          controller: nameController,
                          label: 'Full name',
                          hint: 'e.g. Maya Phiri',
                          icon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words),
                      const SizedBox(height: 16),
                      _inviteField(
                          controller: emailController,
                          label: 'Work email',
                          hint: 'maya@pulsehealthcare.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 22),
                      const Text('Access level',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937))),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'staff',
                              icon: Icon(Icons.groups_2_outlined),
                              label: Text('Staff')),
                          ButtonSegment(
                              value: 'admin',
                              icon: Icon(Icons.admin_panel_settings_outlined),
                              label: Text('Administrator')),
                        ],
                        selected: {role},
                        onSelectionChanged: isSubmitting
                            ? null
                            : (value) =>
                                setDialogState(() => role = value.first),
                        style: ButtonStyle(
                          visualDensity: VisualDensity.comfortable,
                          foregroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? Colors.white
                                  : const Color(0xFF4B5563)),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? const Color(0xFF9900FF)
                                  : Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF8F6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE7DCFF))),
                        child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.mark_email_read_outlined,
                                  color: Color(0xFF7C3AED), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text(
                                      'Pulse sends a branded email from the approved domain. The user sets their own password, so no temporary credentials are exposed.',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          height: 1.45,
                                          color: Color(0xFF5B4B85)))),
                            ]),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(errorMessage!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB42318),
                                fontWeight: FontWeight.w600)),
                      ],
                      const SizedBox(height: 26),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            child: const Text('Cancel')),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  final email = emailController.text.trim();
                                  if (name.length < 2 || !email.contains('@')) {
                                    setDialogState(() => errorMessage =
                                        'Enter a full name and valid work email.');
                                    return;
                                  }
                                  setDialogState(() {
                                    isSubmitting = true;
                                    errorMessage = null;
                                  });
                                  try {
                                    await FirebaseFunctions.instance
                                        .httpsCallable('invitePulseUser')
                                        .call({
                                      'displayName': name,
                                      'email': email,
                                      'role': role,
                                    });
                                    if (!mounted) return;
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Invitation sent. The new user can now set up their account.'),
                                            behavior:
                                                SnackBarBehavior.floating));
                                  } on FirebaseFunctionsException catch (error) {
                                    setDialogState(() => errorMessage =
                                        error.message ??
                                            'Unable to send the invitation.');
                                  } finally {
                                    if (mounted)
                                      setDialogState(
                                          () => isSubmitting = false);
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(isSubmitting
                              ? 'Sending invitation...'
                              : 'Send invitation'),
                          style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF9900FF),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
    emailController.dispose();
  }

  Widget _inviteField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF9900FF)),
          filled: true,
          fillColor: const Color(0xFFFCFBFF),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0D7F7))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF9900FF), width: 2)),
        ),
      );

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
            if (responsiveVisibility(
                context: context, phone: false, tablet: false))
              const SideNavWidget(),
            Expanded(
                child: Column(children: [
              TopNavWidget(
                  openDrawer: () async =>
                      _scaffoldKey.currentState?.openDrawer()),
              Expanded(
                  child: StreamBuilder<List<UserRecord>>(
                stream: queryUserRecord(),
                builder: (context, snapshot) {
                  final users = (snapshot.data ?? const <UserRecord>[])
                      .where(_isPulseUser)
                      .where(_matches)
                      .toList()
                    ..sort((a, b) => a.displayName
                        .toLowerCase()
                        .compareTo(b.displayName.toLowerCase()));
                  return _buildContent(theme, users,
                      snapshot.connectionState == ConnectionState.waiting);
                },
              )),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildContent(
          FlutterFlowTheme theme, List<UserRecord> users, bool loading) =>
      LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.all(constraints.maxWidth < 700 ? 20 : 32),
          child: Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [theme.primary, const Color(0xFF2563EB)]),
                    borderRadius: BorderRadius.circular(24)),
                child: Row(children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 38),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                        Text('Pulse User Management',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text(
                            'Control network access, roles, and account status from one secure workspace.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 15)),
                      ])),
                  if (AccessControl.hasPermission(
                      context, Permission.userManagementManage)) ...[
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _showInviteUserDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Add Pulse user'),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14)),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 24),
              Wrap(spacing: 12, runSpacing: 12, children: [
                _stat(theme, 'Pulse accounts', users.length.toString(),
                    Icons.groups_rounded),
                _stat(
                    theme,
                    'Administrators',
                    users
                        .where((u) => u.role.toLowerCase() == 'admin')
                        .length
                        .toString(),
                    Icons.verified_user_rounded),
                _stat(
                    theme,
                    'Suspended',
                    users
                        .where((u) =>
                            u.snapshotData['account_status'] == 'suspended')
                        .length
                        .toString(),
                    Icons.pause_circle_outline_rounded),
              ]),
              const SizedBox(height: 24),
              Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.lineColor)),
                  child: Column(children: [
                    TextField(
                        onChanged: (value) => setState(() => _search = value),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: 'Search Pulse users by name or email',
                            filled: true,
                            fillColor: theme.primaryBackground,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none))),
                    const SizedBox(height: 12),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'All', label: Text('All')),
                              ButtonSegment(
                                  value: 'Admin', label: Text('Admins')),
                              ButtonSegment(
                                  value: 'Staff', label: Text('Staff'))
                            ],
                            selected: {
                              _roleFilter
                            },
                            onSelectionChanged: (values) =>
                                setState(() => _roleFilter = values.first))),
                  ])),
              const SizedBox(height: 16),
              if (loading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator()))
              else if (users.isEmpty)
                _empty(theme)
              else
                ...users.map((user) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _userRow(theme, user))),
            ]),
          )),
        ),
      );

  Widget _stat(
          FlutterFlowTheme theme, String label, String value, IconData icon) =>
      Container(
          width: 210,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.lineColor)),
          child: Row(children: [
            Icon(icon, color: theme.primary),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: theme.titleLarge),
              Text(label, style: theme.bodySmall)
            ])
          ]));
  Widget _empty(FlutterFlowTheme theme) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20)),
      child: const Column(children: [
        Icon(Icons.people_outline_rounded, size: 42),
        SizedBox(height: 12),
        Text('No Pulse users match this view')
      ]));
  Widget _userRow(FlutterFlowTheme theme, UserRecord user) {
    final suspended = user.snapshotData['account_status'] == 'suspended';
    final busy = _busyUserId == user.reference.id;
    final name = user.displayName.isEmpty ? user.email : user.displayName;
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: suspended
                    ? Colors.red.withValues(alpha: .35)
                    : theme.lineColor)),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: theme.primary.withValues(alpha: .12),
              child: Text(
                  name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: theme.primary, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name, style: theme.titleMedium),
                Text(user.email, style: theme.bodySmall)
              ])),
          if (busy)
            const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'admin' || value == 'staff')
                    _manage(user, 'setRole', role: value);
                  else
                    _manage(user, 'setStatus', suspended: value == 'suspend');
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                          value: 'admin',
                          child: const Text('Make administrator')),
                      PopupMenuItem(
                          value: 'staff', child: const Text('Make staff')),
                      PopupMenuItem(
                          value: suspended ? 'reinstate' : 'suspend',
                          child: Text(suspended
                              ? 'Reinstate account'
                              : 'Suspend account'))
                    ]),
        ]));
  }
}
