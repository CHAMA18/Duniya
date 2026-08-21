import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/rbac/rbac.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _searchQuery = '';
  String _actionFilter = 'All';
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuditLogsModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AuditLogs'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Query<Map<String, dynamic>>? _auditQuery() {
    if (currentUserUid.isEmpty) return null;
    final scopeId = AccessControl.isPulseUser(context)
        ? 'Pulse'
        : currentUserDocument?.ownerRef?.path ?? 'User/$currentUserUid';
    return FirebaseFirestore.instance
        .collection('AuditLogs')
        .where('scopeId', isEqualTo: scopeId)
        .limit(250);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

    return Title(
      title: 'Audit Logs',
      color: theme.primary.withAlpha(0xFF),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
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
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ),
                      Expanded(
                        child: AuthUserStreamWidget(
                          builder: (context) => _buildContent(theme),
                        ),
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
    final query = _auditQuery();
    if (query == null) {
      return _buildStatePanel(
        theme,
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to view audit activity',
        message: 'Your organization activity will appear here after sign-in.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey(_refreshKey),
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(theme);
        }
        if (!snapshot.hasData) {
          return _buildLoadingState(theme);
        }

        final entries = snapshot.data!.docs
            .map(_AuditEntry.fromDocument)
            .where(_matchesFilter)
            .toList()
          ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

        return _buildWorkspace(
          theme,
          entries,
          totalEntries: snapshot.data!.docs.length,
        );
      },
    );
  }

  bool _matchesFilter(_AuditEntry entry) {
    final query = _searchQuery.trim().toLowerCase();
    final matchesAction =
        _actionFilter == 'All' || entry.action == _actionFilter;
    if (!matchesAction) return false;
    if (query.isEmpty) return true;
    return entry.title.toLowerCase().contains(query) ||
        entry.actor.toLowerCase().contains(query) ||
        entry.eventName.toLowerCase().contains(query) ||
        entry.details.toLowerCase().contains(query);
  }

  Widget _buildWorkspace(
    FlutterFlowTheme theme,
    List<_AuditEntry> entries, {
    required int totalEntries,
  }) {
    final now = DateTime.now();
    final today = entries.where((entry) {
      final date = entry.createdAt;
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
    final actors = entries.map((entry) => entry.actor).toSet().length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 20 : 32,
            isCompact ? 24 : 32,
            isCompact ? 20 : 32,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, isCompact),
                  const SizedBox(height: 28),
                  _buildSummary(theme, totalEntries, today, actors, isCompact),
                  const SizedBox(height: 24),
                  _buildToolbar(theme, isCompact),
                  const SizedBox(height: 16),
                  if (entries.isEmpty)
                    _buildEmptyState(
                      theme,
                      hasFilters:
                          _searchQuery.isNotEmpty || _actionFilter != 'All',
                    )
                  else
                    _buildEntries(theme, entries),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme, bool isCompact) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.history_rounded, color: theme.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audit Logs',
                style: theme.displaySmall.override(
                  fontFamily: theme.displaySmallFamily,
                  fontSize: isCompact ? 28 : 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  useGoogleFonts: !theme.displaySmallIsCustom,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'A live, tamper-resistant record of activity across your organization.',
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => safeSetState(() => _refreshKey++),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(isCompact ? 'Refresh' : 'Refresh activity'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.primary,
            side: BorderSide(color: theme.primary.withValues(alpha: 0.28)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(
    FlutterFlowTheme theme,
    int total,
    int today,
    int actors,
    bool isCompact,
  ) {
    final cards = [
      _SummaryCard(
          'Total events', total.toString(), Icons.receipt_long_rounded),
      _SummaryCard('Today', today.toString(), Icons.today_rounded),
      _SummaryCard('Active people', actors.toString(), Icons.groups_rounded),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = isCompact
            ? constraints.maxWidth
            : (constraints.maxWidth - 32) / cards.length;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(
                    width: width,
                    child: _buildSummaryCard(theme, card),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildSummaryCard(FlutterFlowTheme theme, _SummaryCard card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.lineColor),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(card.icon, color: theme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.value,
                  style: theme.headlineMedium.override(
                    fontFamily: theme.headlineMediumFamily,
                    fontWeight: FontWeight.w800,
                    useGoogleFonts: !theme.headlineMediumIsCustom,
                  ),
                ),
                Text(
                  card.label,
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
    );
  }

  Widget _buildToolbar(FlutterFlowTheme theme, bool isCompact) {
    final actions = ['All', 'Create', 'Update', 'Delete', 'View', 'Activity'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.lineColor),
      ),
      child: isCompact
          ? Column(
              children: [
                _buildSearchField(theme),
                const SizedBox(height: 12),
                _buildActionFilter(theme, actions),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildSearchField(theme)),
                const SizedBox(width: 12),
                SizedBox(
                  width: 220,
                  child: _buildActionFilter(theme, actions),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchField(FlutterFlowTheme theme) {
    return TextField(
      onChanged: (value) => safeSetState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search events, people, or details',
        prefixIcon: Icon(Icons.search_rounded, color: theme.primary),
        filled: true,
        fillColor: theme.primaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildActionFilter(FlutterFlowTheme theme, List<String> actions) {
    return DropdownButtonFormField<String>(
      initialValue: _actionFilter,
      decoration: InputDecoration(
        labelText: 'Activity type',
        filled: true,
        fillColor: theme.primaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: actions
          .map((action) => DropdownMenuItem(
                value: action,
                child: Text(action),
              ))
          .toList(),
      onChanged: (value) => safeSetState(() => _actionFilter = value ?? 'All'),
    );
  }

  Widget _buildEntries(FlutterFlowTheme theme, List<_AuditEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.lineColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 84,
          endIndent: 24,
          color: theme.lineColor,
        ),
        itemBuilder: (context, index) => _buildEntry(theme, entries[index]),
      ),
    );
  }

  Widget _buildEntry(FlutterFlowTheme theme, _AuditEntry entry) {
    final color = _actionColor(theme, entry.action);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_actionIcon(entry.action), color: color, size: 21),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      entry.title,
                      style: theme.bodyLarge.override(
                        fontFamily: theme.bodyLargeFamily,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !theme.bodyLargeIsCustom,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.action,
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: color,
                          fontWeight: FontWeight.w700,
                          useGoogleFonts: !theme.labelSmallIsCustom,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${entry.actor}  •  ${entry.details}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _formatDate(entry.createdAt),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(FlutterFlowTheme theme) {
    return _buildStatePanel(
      theme,
      icon: Icons.hourglass_top_rounded,
      title: 'Loading audit activity',
      message: 'Connecting to your organization activity stream.',
      showProgress: true,
    );
  }

  Widget _buildErrorState(FlutterFlowTheme theme) {
    return _buildStatePanel(
      theme,
      icon: Icons.cloud_off_rounded,
      title: 'Audit activity could not load',
      message: 'Check your connection and Firestore permissions, then refresh.',
      action: OutlinedButton.icon(
        onPressed: () => safeSetState(() => _refreshKey++),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
    );
  }

  Widget _buildStatePanel(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
    bool showProgress = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: theme.primary, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                fontWeight: FontWeight.w800,
                useGoogleFonts: !theme.headlineSmallIsCustom,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  color: theme.primary,
                  backgroundColor: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(FlutterFlowTheme theme, {required bool hasFilters}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.lineColor),
      ),
      child: Column(
        children: [
          Icon(
            hasFilters
                ? Icons.search_off_rounded
                : Icons.auto_awesome_motion_rounded,
            color: theme.primary,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            hasFilters ? 'No matching events' : 'No audit events yet',
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              fontWeight: FontWeight.w800,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try a different search term or activity type.'
                : 'Real activity will appear here as your team uses Pulse.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(FlutterFlowTheme theme, String action) {
    switch (action) {
      case 'Create':
        return theme.success;
      case 'Update':
        return theme.primary;
      case 'Delete':
        return theme.error;
      case 'View':
        return const Color(0xFF2563EB);
      default:
        return theme.secondaryText;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'Create':
        return Icons.add_circle_outline_rounded;
      case 'Update':
        return Icons.edit_note_rounded;
      case 'Delete':
        return Icons.delete_outline_rounded;
      case 'View':
        return Icons.visibility_outlined;
      default:
        return Icons.bolt_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pending';
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SummaryCard {
  const _SummaryCard(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _AuditEntry {
  const _AuditEntry({
    required this.eventName,
    required this.action,
    required this.title,
    required this.actor,
    required this.details,
    required this.createdAt,
  });

  final String eventName;
  final String action;
  final String title;
  final String actor;
  final String details;
  final DateTime? createdAt;

  factory _AuditEntry.fromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final eventName = (data['eventName'] as String?) ?? 'activity';
    final parameters = Map<String, dynamic>.from(
        (data['parameters'] as Map?)?.cast<String, dynamic>() ?? {});
    final action = _actionFor(eventName);
    final screenName = parameters['screen_name']?.toString();
    final title = eventName == 'screen_view' && screenName != null
        ? 'Viewed ${_humanize(screenName)}'
        : _humanize(eventName);
    final actorName = (data['actorName'] as String?)?.trim() ?? '';
    final actorEmail = (data['actorEmail'] as String?)?.trim() ?? '';
    final actor = actorName.isNotEmpty
        ? actorName
        : actorEmail.isNotEmpty
            ? actorEmail
            : 'Team member';
    final detailParts = <String>[];
    if (screenName == null && parameters.isNotEmpty) {
      detailParts.add(parameters.entries
          .take(2)
          .map((entry) => '${_humanize(entry.key)}: ${entry.value}')
          .join('  |  '));
    } else if (screenName != null) {
      detailParts.add('Pulse workspace');
    }
    detailParts.add(actorEmail.isNotEmpty ? actorEmail : 'Authenticated user');

    return _AuditEntry(
      eventName: eventName,
      action: action,
      title: title,
      actor: actor,
      details: detailParts.join('  |  '),
      createdAt: _toDate(data['createdAt']) ?? _toDate(data['clientCreatedAt']),
    );
  }
}

String _actionFor(String eventName) {
  final normalized = eventName.toLowerCase();
  if (normalized == 'screen_view' || normalized.contains('navigate')) {
    return 'View';
  }
  if (normalized.contains('delete') || normalized.contains('remove')) {
    return 'Delete';
  }
  if (normalized.contains('create') ||
      normalized.contains('add') ||
      normalized.contains('register')) {
    return 'Create';
  }
  if (normalized.contains('update') ||
      normalized.contains('edit') ||
      normalized.contains('save') ||
      normalized.contains('approve') ||
      normalized.contains('reject')) {
    return 'Update';
  }
  return 'Activity';
}

String _humanize(String value) {
  final words = value
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList();
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

DateTime? _toDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
