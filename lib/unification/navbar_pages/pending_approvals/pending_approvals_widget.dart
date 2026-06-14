import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'pending_approvals_model.dart';
export 'pending_approvals_model.dart';

class PendingApprovalsWidget extends StatefulWidget {
  const PendingApprovalsWidget({super.key});

  static String routeName = 'PendingApprovals';
  static String routePath = '/pending-approvals';

  @override
  State<PendingApprovalsWidget> createState() => _PendingApprovalsWidgetState();
}

class _PendingApprovalsWidgetState extends State<PendingApprovalsWidget> {
  late PendingApprovalsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<UserRecord>? _pendingUsers;
  bool _isLoading = true;
  int _selectedQueueTab = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PendingApprovalsModel());
    FFAppState().SelectedPage = 'PendingApprovals';

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadPendingApprovals();
    });
  }

  Future<void> _loadPendingApprovals() async {
    try {
      final snapshot = await queryUserRecordOnce(
        queryBuilder: (query) =>
            query.where('approved_by_duniya', isEqualTo: false),
      );
      if (mounted) {
        setState(() {
          _pendingUsers = snapshot;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveUser(UserRecord user) async {
    try {
      await user.reference.update(createUserRecordData(
        approvedByDuniya: true,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.pharmacyName.isNotEmpty ? user.pharmacyName : user.displayName} approved successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      await _loadPendingApprovals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectUser(UserRecord user) async {
    try {
      await user.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.pharmacyName.isNotEmpty ? user.pharmacyName : user.displayName} rejected and removed',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      await _loadPendingApprovals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<UserRecord> get _visiblePendingUsers {
    final users = List<UserRecord>.from(_pendingUsers ?? <UserRecord>[]);
    final query = _searchQuery.trim().toLowerCase();
    switch (_selectedQueueTab) {
      case 1:
        users.removeWhere((u) => u.accountType != 'pharmacy');
        break;
      case 2:
        users.removeWhere((u) => u.accountType == 'pharmacy');
        break;
    }

    if (query.isNotEmpty) {
      users.removeWhere((u) {
        final haystack = <String>[
          _displayNameFor(u),
          u.displayName,
          u.email,
          u.phoneNumber,
          u.pharmacyName,
          u.accountType,
        ].join(' ').toLowerCase();
        return !haystack.contains(query);
      });
    }

    users.sort((a, b) {
      final aTime = a.createdTime;
      final bTime = b.createdTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });

    return users;
  }

  String _displayNameFor(UserRecord user) {
    if (user.accountType == 'pharmacy') {
      return user.pharmacyName.isNotEmpty
          ? user.pharmacyName
          : user.displayName;
    }
    return user.displayName.isNotEmpty ? user.displayName : user.email;
  }

  Widget _buildHeroStatCard({
    required BuildContext context,
    required String label,
    required String value,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleLargeFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleLargeIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).alternate,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueFilterPill(
    BuildContext context, {
    required String label,
    required int index,
  }) {
    final isActive = _selectedQueueTab == index;
    return InkWell(
      onTap: () => safeSetState(() => _selectedQueueTab = index),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: isActive
                    ? Colors.white
                    : FlutterFlowTheme.of(context).secondaryText,
                fontWeight: FontWeight.w600,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        onChanged: (value) => safeSetState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name, email, pharmacy, or phone',
          prefixIcon: const Icon(Icons.search_rounded),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalMetrics(BuildContext context) {
    final users = _pendingUsers ?? <UserRecord>[];
    final pharmacies = users.where((u) => u.accountType == 'pharmacy').toList();
    final duniyaUsers =
        users.where((u) => u.accountType != 'pharmacy').toList();
    final oldestCandidates = users
        .where((u) => u.hasCreatedTime())
        .map((u) => u.createdTime!)
        .toList();
    final oldest = oldestCandidates.isNotEmpty
        ? oldestCandidates.reduce((a, b) => a.isBefore(b) ? a : b)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1120;
        final topRow = isWide
            ? Row(
                children: [
                  Expanded(
                    child: _buildHeroStatCard(
                      context: context,
                      label: 'Accounts awaiting review',
                      value: users.length.toString(),
                      hint: 'Total pending approvals',
                      icon: Icons.pending_actions_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildHeroStatCard(
                      context: context,
                      label: 'Pharmacy requests',
                      value: pharmacies.length.toString(),
                      hint: 'Clinical network entries',
                      icon: Icons.local_pharmacy_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildHeroStatCard(
                      context: context,
                      label: 'Duniya users',
                      value: duniyaUsers.length.toString(),
                      hint: 'Team and operator invites',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildHeroStatCard(
                      context: context,
                      label: 'Oldest submission',
                      value: oldest == null
                          ? '--'
                          : dateTimeFormat(
                              'd MMM',
                              oldest,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                      hint: oldest == null
                          ? 'No active queue'
                          : 'Process oldest first',
                      icon: Icons.schedule_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildHeroStatCard(
                    context: context,
                    label: 'Accounts awaiting review',
                    value: users.length.toString(),
                    hint: 'Total pending approvals',
                    icon: Icons.pending_actions_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                  const SizedBox(height: 12),
                  _buildHeroStatCard(
                    context: context,
                    label: 'Pharmacy requests',
                    value: pharmacies.length.toString(),
                    hint: 'Clinical network entries',
                    icon: Icons.local_pharmacy_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildHeroStatCard(
                    context: context,
                    label: 'Duniya users',
                    value: duniyaUsers.length.toString(),
                    hint: 'Team and operator invites',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(height: 12),
                  _buildHeroStatCard(
                    context: context,
                    label: 'Oldest submission',
                    value: oldest == null
                        ? '--'
                        : dateTimeFormat(
                            'd MMM',
                            oldest,
                            locale: FFLocalizations.of(context).languageCode,
                          ),
                    hint: oldest == null
                        ? 'No active queue'
                        : 'Process oldest first',
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            topRow,
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 980;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context)
                          .alternate
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: _buildSearchField(context)),
                            const SizedBox(width: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildQueueFilterPill(
                                  context,
                                  label: 'All',
                                  index: 0,
                                ),
                                _buildQueueFilterPill(
                                  context,
                                  label: 'Pharmacies',
                                  index: 1,
                                ),
                                _buildQueueFilterPill(
                                  context,
                                  label: 'Duniya',
                                  index: 2,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSearchField(context),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildQueueFilterPill(
                                  context,
                                  label: 'All',
                                  index: 0,
                                ),
                                _buildQueueFilterPill(
                                  context,
                                  label: 'Pharmacies',
                                  index: 1,
                                ),
                                _buildQueueFilterPill(
                                  context,
                                  label: 'Duniya',
                                  index: 2,
                                ),
                              ],
                            ),
                          ],
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricBadge(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleLargeIsCustom,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSnapshot(
    BuildContext context, {
    required String label,
    required String value,
    required String helper,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelMediumIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).alternate,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPanel(
    BuildContext context, {
    required int total,
    required int pharmacies,
    required int duniyaUsers,
    required DateTime? oldestRequest,
  }) {
    final oldestLabel = oldestRequest == null
        ? 'No pending items'
        : dateTimeFormat(
            'MMM d, y',
            oldestRequest,
            locale: FFLocalizations.of(context).languageCode,
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            title: 'Triage Panel',
            subtitle: 'Fast context for confident decisions',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 18),
          _buildMetricSnapshot(
            context,
            label: 'Queue health',
            value: total == 0
                ? 'Clear'
                : (total <= 3
                    ? 'Light'
                    : total <= 10
                        ? 'Busy'
                        : 'Heavy'),
            helper: total == 0
                ? 'No pending approvals'
                : 'Review ${total > 1 ? 'these requests' : 'this request'} soon',
          ),
          const SizedBox(height: 12),
          _buildMetricSnapshot(
            context,
            label: 'Approval mix',
            value: '$pharmacies pharmacy / $duniyaUsers Duniya',
            helper: 'Helps prioritize clinical accounts first',
          ),
          const SizedBox(height: 12),
          _buildMetricSnapshot(
            context,
            label: 'Oldest request',
            value: oldestLabel,
            helper: oldestRequest == null
                ? 'Nothing waiting right now'
                : 'Process oldest requests first',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
                  const Color(0xFFF5F3FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended flow',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  '1. Open the oldest item. 2. Verify the owner details. 3. Approve only after the account type is correct.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineMeta(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: FlutterFlowTheme.of(context).secondaryText,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ],
    );
  }

  Widget _buildApprovalCard(BuildContext context, UserRecord user) {
    final isPharmacy = user.accountType == 'pharmacy';
    final displayName = _displayNameFor(user);
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final createdLabel = user.hasCreatedTime()
        ? dateTimeFormat(
            'MMM d, y',
            user.createdTime!,
            locale: FFLocalizations.of(context).languageCode,
          )
        : 'Recently added';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (isPharmacy
                          ? const Color(0xFF10B981)
                          : FlutterFlowTheme.of(context).primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'U' : initials,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          color: isPharmacy
                              ? const Color(0xFF10B981)
                              : FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w800,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleLargeFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleLargeIsCustom,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPharmacy
                                ? const Color(0xFFE8FAF1)
                                : const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isPharmacy ? 'Pharmacy' : 'Duniya',
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelSmallFamily,
                                  color: isPharmacy
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelSmallIsCustom,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _buildInlineMeta(
                          context,
                          icon: Icons.email_outlined,
                          text: user.email,
                        ),
                        if (user.phoneNumber.isNotEmpty)
                          _buildInlineMeta(
                            context,
                            icon: Icons.call_outlined,
                            text: user.phoneNumber,
                          ),
                        _buildInlineMeta(
                          context,
                          icon: Icons.schedule_outlined,
                          text: 'Submitted $createdLabel',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMetricBadge(
                context,
                label: 'Type',
                value: isPharmacy ? 'Pharmacy' : 'Duniya',
              ),
              _buildMetricBadge(
                context,
                label: 'Owner',
                value: user.ownerRef == null ? 'Unlinked' : 'Linked',
              ),
              _buildMetricBadge(
                context,
                label: 'Queue',
                value: 'Pending review',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'This request is ready for a final human decision.',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, user),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(context, user),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyApprovalsState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EAFE),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              icon,
              size: 34,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final visibleUsers = _visiblePendingUsers;
    final allUsers = _pendingUsers ?? <UserRecord>[];
    final pharmacyCount =
        visibleUsers.where((u) => u.accountType == 'pharmacy').length;
    final duniyaCount = visibleUsers.length - pharmacyCount;
    final oldestRequest = visibleUsers
        .where((u) => u.hasCreatedTime())
        .map((u) => u.createdTime!)
        .toList()
      ..sort();
    final oldestVisible = oldestRequest.isNotEmpty ? oldestRequest.first : null;

    return Title(
      title: 'Pending Approvals',
      color: FlutterFlowTheme.of(context).primary,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: const Drawer(
            child: SafeArea(
              child: SideNavWidget(),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
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
                    mainAxisSize: MainAxisSize.max,
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
                        child: _isLoading
                            ? const Center(
                                child: LoadingSpinnerWidget(
                                  loadingMessage: 'Loading approvals',
                                  size: 60.0,
                                  showRing: true,
                                  showLabel: true,
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  22,
                                  24,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Pending Approvals',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          fontSize: 34,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing: -0.8,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Review new Duniya and pharmacy accounts with a fast, confident triage flow.',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeFamily,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeIsCustom,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          alignment: WrapAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: _loadPendingApprovals,
                                              icon: const Icon(
                                                Icons.refresh_rounded,
                                                size: 18,
                                              ),
                                              label: const Text('Refresh'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                side: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 18,
                                                  vertical: 14,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                safeSetState(() {
                                                  _selectedQueueTab = 0;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Filters reset to the full approvals queue.',
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.tune_rounded,
                                                size: 18,
                                              ),
                                              label:
                                                  const Text('Reset Filters'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 18,
                                                  vertical: 14,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    _buildApprovalMetrics(context),
                                    const SizedBox(height: 22),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .alternate
                                              .withValues(alpha: 0.35),
                                        ),
                                      ),
                                      child: Wrap(
                                        spacing: 18,
                                        runSpacing: 10,
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          _buildInlineMeta(
                                            context,
                                            icon: Icons.pending_actions_rounded,
                                            text:
                                                '${visibleUsers.length} total in queue',
                                          ),
                                          _buildInlineMeta(
                                            context,
                                            icon: Icons.local_pharmacy_rounded,
                                            text:
                                                '$pharmacyCount pharmacy accounts',
                                          ),
                                          _buildInlineMeta(
                                            context,
                                            icon: Icons.people_alt_rounded,
                                            text:
                                                '$duniyaCount Duniya accounts',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    if (allUsers.isEmpty)
                                      _buildEmptyApprovalsState(
                                        context,
                                        title: 'All caught up',
                                        subtitle:
                                            'New registration requests will appear here for review.',
                                        icon:
                                            Icons.check_circle_outline_rounded,
                                        actionLabel: 'Reload approvals',
                                        onAction: _loadPendingApprovals,
                                      )
                                    else if (visibleUsers.isEmpty)
                                      _buildEmptyApprovalsState(
                                        context,
                                        title: 'No results for this filter',
                                        subtitle:
                                            'Try another queue filter or reset back to all approvals.',
                                        icon: Icons.filter_alt_off_rounded,
                                        actionLabel: 'Reset filters',
                                        onAction: () {
                                          safeSetState(() {
                                            _selectedQueueTab = 0;
                                          });
                                        },
                                      )
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isWide =
                                              constraints.maxWidth >= 1260;

                                          if (isWide) {
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildSectionTitle(
                                                        context,
                                                        title: 'Approval Queue',
                                                        subtitle:
                                                            '${visibleUsers.length} accounts waiting for review',
                                                        icon: Icons
                                                            .pending_actions_rounded,
                                                      ),
                                                      const SizedBox(
                                                          height: 14),
                                                      ...visibleUsers.map(
                                                        (user) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: 14,
                                                          ),
                                                          child:
                                                              _buildApprovalCard(
                                                            context,
                                                            user,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 22),
                                                Expanded(
                                                  flex: 2,
                                                  child: _buildInsightsPanel(
                                                    context,
                                                    total: visibleUsers.length,
                                                    pharmacies: pharmacyCount,
                                                    duniyaUsers: duniyaCount,
                                                    oldestRequest:
                                                        oldestVisible,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildSectionTitle(
                                                context,
                                                title: 'Approval Queue',
                                                subtitle:
                                                    '${visibleUsers.length} accounts waiting for review',
                                                icon: Icons
                                                    .pending_actions_rounded,
                                              ),
                                              const SizedBox(height: 14),
                                              ...visibleUsers.map(
                                                (user) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 14,
                                                  ),
                                                  child: _buildApprovalCard(
                                                    context,
                                                    user,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 22),
                                              _buildInsightsPanel(
                                                context,
                                                total: visibleUsers.length,
                                                pharmacies: pharmacyCount,
                                                duniyaUsers: duniyaCount,
                                                oldestRequest: oldestVisible,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                ),
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

  Widget _buildApproveDialog(BuildContext context, UserRecord user) {
    final name = user.accountType == 'pharmacy'
        ? user.pharmacyName
        : (user.displayName.isNotEmpty ? user.displayName : user.email);

    return AlertDialog(
      title: const Text('Approve Account'),
      content: Text(
        'Are you sure you want to approve "$name"? They will be able to sign in and access the platform immediately.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _approveUser(user);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Approve'),
        ),
      ],
    );
  }

  void _showApproveDialog(BuildContext context, UserRecord user) {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildApproveDialog(dialogContext, user),
    );
  }

  void _showRejectDialog(BuildContext context, UserRecord user) {
    final name = user.accountType == 'pharmacy'
        ? user.pharmacyName
        : (user.displayName.isNotEmpty ? user.displayName : user.email);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Account'),
        content: Text(
          'Are you sure you want to reject "$name"? This will permanently delete their account from the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _rejectUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
