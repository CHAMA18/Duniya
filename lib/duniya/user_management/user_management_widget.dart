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

  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

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

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxHeight: 640),
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).brightness == Brightness.dark
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header — light, modern, with brand-purple icon chip.
                // Previously this was a solid purple gradient block which
                // pushed the actual form content down and competed with
                // the primary CTA. Modern SaaS dialogs (Linear, Stripe,
                // Vercel) keep modal headers white/light to focus on data
                // entry.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 26, 16, 18),
                  decoration: BoxDecoration(
                    color: Theme.of(dialogContext).brightness == Brightness.dark
                        ? const Color(0xFF1A1A2E)
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(dialogContext).brightness ==
                                Brightness.dark
                            ? const Color(0xFF3B3B4F)
                            : const Color(0xFFEEEAFF),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _purple.withValues(alpha: 0.25),
                            width: 1.5),
                      ),
                      child: Icon(Icons.person_add_alt_1_rounded,
                          color: _purple, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Invite Pulse User',
                                style: TextStyle(
                                    color: Theme.of(dialogContext).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0B1C30),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 3),
                            Text(
                                'They\'ll receive a branded email and set their own password.',
                                style: TextStyle(
                                    color: Theme.of(dialogContext).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF64748B),
                                    fontSize: 13,
                                    height: 1.4)),
                          ]),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: Theme.of(dialogContext).brightness ==
                                  Brightness.dark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ]),
                ),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              hint: 'maya@duniyahealthcare.com',
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
                                      ? _purple
                                      : Colors.transparent),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Info alert — left accent bar style
                          // (Stripe/Linear pattern) so it reads as
                          // 'information' instead of 'another field'.
                          // Previously this was a tinted box that
                          // visually competed with the text inputs
                          // above it.
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            decoration: BoxDecoration(
                              color: _purple.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border(
                                left: BorderSide(
                                    color: _purple.withValues(alpha: 0.55),
                                    width: 3),
                              ),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.mark_email_read_outlined,
                                      color: _purple.withValues(alpha: 0.85),
                                      size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(
                                          'Pulse sends a branded email from the approved domain. The user sets their own password, so no temporary credentials are exposed.',
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              height: 1.5,
                                              color: Theme.of(dialogContext)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? const Color(0xFFCBD5E1)
                                                  : const Color(0xFF475569),
                                              fontWeight: FontWeight.w400))),
                                ]),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Text(errorMessage!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: _red,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ]),
                  ),
                ),
                // Footer — clear divider separates the data-entry zone
                // from the action zone (Apple HIG pattern). Cancel is a
                // ghost button (white bg + 1px purple border + purple
                // text) so it has clear affordance distinct from the
                // primary CTA — previously a plain TextButton that
                // risked false affordance next to the big purple
                // 'Send invitation'.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 22),
                  decoration: BoxDecoration(
                    color: Theme.of(dialogContext).brightness == Brightness.dark
                        ? const Color(0xFF16162A)
                        : const Color(0xFFFBFAFF),
                    border: Border(
                        top: BorderSide(
                            color: Theme.of(dialogContext).brightness ==
                                    Brightness.dark
                                ? const Color(0xFF3B3B4F)
                                : const Color(0xFFEEEAFF),
                            width: 1)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _purple,
                            side: BorderSide(
                                color: _purple.withValues(alpha: 0.35),
                                width: 1.5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  final email = emailController.text.trim();
                                  if (name.length < 2 ||
                                      !email.contains('@')) {
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
                              backgroundColor: _purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1)),
                        ),
                      ]),
                ),
              ],
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
          prefixIcon: Icon(icon, color: _purple),
          filled: true,
          fillColor: const Color(0xFFFCFBFF),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE0D7F7))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _purple, width: 2)),
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

  // ═══════════════════════════════════════════════════════════════
  //   CONTENT BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent(
          FlutterFlowTheme theme, List<UserRecord> users, bool loading) =>
      LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final pad = isWide ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Compact header (no huge banner)
                      _compactHeader(theme, isWide),
                      const SizedBox(height: 20),
                      // KPI cards
                      _kpiRow(theme, users, isWide),
                      const SizedBox(height: 20),
                      // Search + filter bar
                      _searchBar(theme, isWide, users.length),
                      const SizedBox(height: 16),
                      // User table
                      if (loading)
                        _loadingState(theme)
                      else if (users.isEmpty)
                        _emptyState(theme, isWide)
                      else
                        _userTable(theme, users, isWide),
                    ]),
              ),
            ),
          );
        },
      );

  // ── Compact header ─────────────────────────────────────────────
  Widget _compactHeader(FlutterFlowTheme theme, bool isWide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_purpleDark, _purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text('User Management',
                  style: theme.headlineSmall.override(
                    fontFamily: theme.headlineSmallFamily,
                    fontSize: isWide ? 24 : 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    useGoogleFonts: !theme.headlineSmallIsCustom,
                  )),
            ]),
            if (isWide) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                    'Control network access, roles, and account status.',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    )),
              ),
            ],
          ],
        ),
        if (AccessControl.hasPermission(
            context, Permission.userManagementManage))
          FilledButton.icon(
            onPressed: _showInviteUserDialog,
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: const Text('Add Pulse user'),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
      ],
    );
  }

  // ── KPI cards ──────────────────────────────────────────────────
  Widget _kpiRow(FlutterFlowTheme theme, List<UserRecord> users, bool isWide) {
    final adminCount =
        users.where((u) => u.role.toLowerCase() == 'admin').length;
    final suspendedCount = users
        .where((u) => u.snapshotData['account_status'] == 'suspended')
        .length;
    final activeCount = users.length - suspendedCount;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard(theme, 'Total accounts', users.length.toString(),
            Icons.groups_rounded, _purple, const Color(0xFFF1EAFE)),
        _kpiCard(theme, 'Administrators', adminCount.toString(),
            Icons.verified_user_rounded, _blue, const Color(0xFFE0EAFF)),
        _kpiCard(theme, 'Active', activeCount.toString(),
            Icons.check_circle_rounded, _green, const Color(0xFFECFDF5)),
        _kpiCard(theme, 'Suspended', suspendedCount.toString(),
            Icons.pause_circle_outline_rounded, _red, const Color(0xFFFFF1F2)),
      ],
    );
  }

  Widget _kpiCard(FlutterFlowTheme theme, String label, String value,
      IconData icon, Color accent, Color tint) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.lineColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: tint, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: theme.titleLarge.override(
                    fontFamily: theme.titleLargeFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryText,
                    useGoogleFonts: !theme.titleLargeIsCustom,
                  )),
              Text(label,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 12,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  )),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Search bar + filters ───────────────────────────────────────
  Widget _searchBar(FlutterFlowTheme theme, bool isWide, int userCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.lineColor),
      ),
      child: Column(
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: _purple),
                  hintText: 'Search Pulse users by name or email…',
                  hintStyle: TextStyle(color: theme.secondaryText, fontSize: 14),
                  filled: true,
                  fillColor: theme.primaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _filterChip(theme, 'All', _roleFilter == 'All'),
            const SizedBox(width: 8),
            _filterChip(theme, 'Admins', _roleFilter == 'Admin',
                accent: _blue),
            const SizedBox(width: 8),
            _filterChip(theme, 'Staff', _roleFilter == 'Staff',
                accent: _green),
            const Spacer(),
            if (isWide)
              Text('$userCount user${userCount == 1 ? '' : 's'}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  )),
          ]),
        ],
      ),
    );
  }

  Widget _filterChip(FlutterFlowTheme theme, String label, bool selected,
      {Color accent = _purple}) {
    return Material(
      color: selected ? accent : theme.primaryBackground,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _roleFilter = label == 'All'
            ? 'All'
            : label == 'Admins'
                ? 'Admin'
                : 'Staff'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : theme.lineColor,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : theme.secondaryText,
              )),
        ),
      ),
    );
  }

  // ── User table ─────────────────────────────────────────────────
  Widget _userTable(FlutterFlowTheme theme, List<UserRecord> users, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.lineColor),
      ),
      child: Column(children: [
        // Table header
        if (isWide)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            decoration: BoxDecoration(
              color: theme.primaryBackground.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              const SizedBox(width: 48),
              Expanded(flex: 2, child: _tableHeader(theme, 'Name')),
              Expanded(flex: 2, child: _tableHeader(theme, 'Email')),
              Expanded(flex: 1, child: _tableHeader(theme, 'Role')),
              Expanded(flex: 1, child: _tableHeader(theme, 'Status')),
              const SizedBox(width: 36),
            ]),
          ),
        const Divider(height: 1),
        // Rows
        for (final user in users)
          _userRow(theme, user, isWide),
      ]),
    );
  }

  Widget _tableHeader(FlutterFlowTheme theme, String label) {
    return Text(label,
        style: theme.labelSmall.override(
          fontFamily: theme.labelSmallFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: theme.secondaryText,
          letterSpacing: 0.6,
          useGoogleFonts: !theme.labelSmallIsCustom,
        ));
  }

  Widget _userRow(FlutterFlowTheme theme, UserRecord user, bool isWide) {
    final suspended = user.snapshotData['account_status'] == 'suspended';
    final busy = _busyUserId == user.reference.id;
    final isAdmin = user.role.toLowerCase() == 'admin';
    final name =
        user.displayName.isEmpty ? user.email : user.displayName;
    final initials = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isAdmin ? _purple : _blue).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(
                      color: isAdmin ? _purple : _blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    )),
              ),
            ),
            const SizedBox(width: 12),
            // Name + Email
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryText,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      )),
                  if (!isWide)
                    Text(user.email,
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontSize: 12,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        )),
                ],
              ),
            ),
            // Email (wide only)
            if (isWide)
              Expanded(
                flex: 2,
                child: Text(user.email,
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    )),
              ),
            // Role badge
            Expanded(
              flex: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isAdmin ? _purple : _blue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAdmin ? 'Owner' : 'Staff',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAdmin ? _purple : _blue,
                  ),
                ),
              ),
            ),
            // Status badge
            Expanded(
              flex: 1,
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: suspended ? _red : _green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (suspended ? _red : _green)
                            .withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(suspended ? 'Suspended' : 'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: suspended ? _red : _green,
                    )),
              ]),
            ),
            // Actions
            const SizedBox(width: 8),
            if (busy)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
              )
            else
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'admin' || value == 'staff')
                    _manage(user, 'setRole', role: value);
                  else
                    _manage(user, 'setStatus', suspended: value == 'suspend');
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'admin', child: Text('Make administrator')),
                  const PopupMenuItem(
                      value: 'staff', child: Text('Make staff')),
                  PopupMenuItem(
                      value: suspended ? 'reinstate' : 'suspend',
                      child: Text(suspended
                          ? 'Reinstate account'
                          : 'Suspend account')),
                ],
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.lineColor),
                  ),
                  child: Icon(Icons.more_horiz_rounded,
                      color: theme.secondaryText, size: 18),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ── Loading state ──────────────────────────────────────────────
  Widget _loadingState(FlutterFlowTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.lineColor),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _purple),
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────
  Widget _emptyState(FlutterFlowTheme theme, bool isWide) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.lineColor),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: _purple, size: 32),
          ),
          const SizedBox(height: 16),
          Text('No Pulse users match this view',
              style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w700,
                color: theme.primaryText,
                useGoogleFonts: !theme.titleMediumIsCustom,
              )),
          const SizedBox(height: 6),
          Text(
              'Try adjusting the search or filter to find the user you\'re looking for.',
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                useGoogleFonts: !theme.bodySmallIsCustom,
              )),
          const SizedBox(height: 20),
          if (AccessControl.hasPermission(
              context, Permission.userManagementManage))
            FilledButton.icon(
              onPressed: _showInviteUserDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Invite your first team member'),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ),
    );
  }
}

