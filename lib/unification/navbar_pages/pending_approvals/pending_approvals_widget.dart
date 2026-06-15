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
  int _selectedCategoryTab = 0; // 0=All, 1=Pharmacy Reg, 2=Staff, 3=Outlet, 4=Subscription
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, oldest, name

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
      setState(() => _isLoading = true);
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
            '${_displayNameFor(user)} has been approved and can now access the platform.',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadPendingApprovals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approval failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
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
            '${_displayNameFor(user)} has been rejected and removed from the queue.',
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      await _loadPendingApprovals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rejection failed: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Categorize the approval type based on user data
  String _approvalCategory(UserRecord user) {
    if (user.accountType == 'pharmacy') return 'Pharmacy Registration';
    if (user.role == 'staff' || user.role == 'Staff') return 'Staff Approval';
    if (user.role == 'outlet_manager' || user.role == 'OutletManager') return 'Outlet Setup';
    if (user.role == 'subscription' || user.accountType == 'subscription') return 'Subscription';
    return 'Pharmacy Registration'; // Default to pharmacy-focused
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Pharmacy Registration':
        return Icons.local_pharmacy_rounded;
      case 'Staff Approval':
        return Icons.badge_rounded;
      case 'Outlet Setup':
        return Icons.store_rounded;
      case 'Subscription':
        return Icons.card_membership_rounded;
      default:
        return Icons.local_pharmacy_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Pharmacy Registration':
        return const Color(0xFF9900FF);
      case 'Staff Approval':
        return const Color(0xFF3B82F6);
      case 'Outlet Setup':
        return const Color(0xFF10B981);
      case 'Subscription':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF9900FF);
    }
  }

  String _categoryDescription(String category) {
    switch (category) {
      case 'Pharmacy Registration':
        return 'New pharmacy applying to join the Duniya network. Verify business details before approval.';
      case 'Staff Approval':
        return 'Staff member awaiting access to a pharmacy workspace. Confirm their role and assignment.';
      case 'Outlet Setup':
        return 'New outlet or store branch requesting activation under a pharmacy group.';
      case 'Subscription':
        return 'Pharmacy subscription payment or plan change requiring verification.';
      default:
        return 'New registration awaiting review and approval.';
    }
  }

  List<UserRecord> get _visiblePendingUsers {
    final users = List<UserRecord>.from(_pendingUsers ?? <UserRecord>[]);
    final query = _searchQuery.trim().toLowerCase();

    // Category filter
    switch (_selectedCategoryTab) {
      case 1: // Pharmacy Registration
        users.removeWhere((u) => _approvalCategory(u) != 'Pharmacy Registration');
        break;
      case 2: // Staff
        users.removeWhere((u) => _approvalCategory(u) != 'Staff Approval');
        break;
      case 3: // Outlet
        users.removeWhere((u) => _approvalCategory(u) != 'Outlet Setup');
        break;
      case 4: // Subscription
        users.removeWhere((u) => _approvalCategory(u) != 'Subscription');
        break;
    }

    // Search filter
    if (query.isNotEmpty) {
      users.removeWhere((u) {
        final haystack = <String>[
          _displayNameFor(u),
          u.displayName,
          u.email,
          u.phoneNumber,
          u.pharmacyName,
          u.accountType,
          u.role,
          _approvalCategory(u),
        ].join(' ').toLowerCase();
        return !haystack.contains(query);
      });
    }

    // Sort
    users.sort((a, b) {
      switch (_sortBy) {
        case 'oldest':
          final aTime = a.createdTime;
          final bTime = b.createdTime;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        case 'name':
          return _displayNameFor(a).toLowerCase().compareTo(_displayNameFor(b).toLowerCase());
        case 'newest':
        default:
          final aTime = a.createdTime;
          final bTime = b.createdTime;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime!.compareTo(aTime!);
      }
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

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'Unknown';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateTimeFormat('MMM d', dt, locale: FFLocalizations.of(context).languageCode);
  }

  // ─── UI BUILDERS ────────────────────────────────────────────────

  Widget _buildPharmacyHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9900FF), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9900FF).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pharmacy Approvals',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                            fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            useGoogleFonts: !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and manage pending approvals across your pharmacy network',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: Colors.white.withValues(alpha: 0.85),
                            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Quick summary badges
          Builder(
            builder: (context) {
              final all = _pendingUsers ?? <UserRecord>[];
              final pharmReg = all.where((u) => _approvalCategory(u) == 'Pharmacy Registration').length;
              final staff = all.where((u) => _approvalCategory(u) == 'Staff Approval').length;
              final outlet = all.where((u) => _approvalCategory(u) == 'Outlet Setup').length;
              final sub = all.where((u) => _approvalCategory(u) == 'Subscription').length;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildHeaderBadge('${all.length} Total', Icons.pending_actions_rounded),
                  if (pharmReg > 0) _buildHeaderBadge('$pharmReg Registrations', Icons.local_pharmacy_rounded),
                  if (staff > 0) _buildHeaderBadge('$staff Staff', Icons.badge_rounded),
                  if (outlet > 0) _buildHeaderBadge('$outlet Outlets', Icons.store_rounded),
                  if (sub > 0) _buildHeaderBadge('$sub Subscriptions', Icons.card_membership_rounded),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final all = _pendingUsers ?? <UserRecord>[];
    final pharmReg = all.where((u) => _approvalCategory(u) == 'Pharmacy Registration').length;
    final staff = all.where((u) => _approvalCategory(u) == 'Staff Approval').length;
    final outlet = all.where((u) => _approvalCategory(u) == 'Outlet Setup').length;
    final sub = all.where((u) => _approvalCategory(u) == 'Subscription').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1100;
        final children = [
          _buildStatCard(
            context,
            title: 'Pharmacy Registrations',
            value: pharmReg.toString(),
            subtitle: 'New pharmacies applying to join',
            icon: Icons.local_pharmacy_rounded,
            color: const Color(0xFF9900FF),
          ),
          _buildStatCard(
            context,
            title: 'Staff Approvals',
            value: staff.toString(),
            subtitle: 'Staff awaiting access',
            icon: Icons.badge_rounded,
            color: const Color(0xFF3B82F6),
          ),
          _buildStatCard(
            context,
            title: 'Outlet Setups',
            value: outlet.toString(),
            subtitle: 'New store branches pending',
            icon: Icons.store_rounded,
            color: const Color(0xFF10B981),
          ),
          _buildStatCard(
            context,
            title: 'Subscriptions',
            value: sub.toString(),
            subtitle: 'Plan changes to verify',
            icon: Icons.card_membership_rounded,
            color: const Color(0xFFF59E0B),
          ),
        ];

        if (isWide) {
          return Row(
            children: children.map((c) => Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: c,
            ))).toList(),
          );
        }
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children.map((c) => SizedBox(
            width: (constraints.maxWidth - 14) / 2,
            child: c,
          )).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                value,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      useGoogleFonts: !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return isWide
              ? Row(
                  children: [
                    Expanded(child: _buildSearchField(context)),
                    const SizedBox(width: 14),
                    _buildCategoryPills(context),
                    const SizedBox(width: 14),
                    _buildSortDropdown(context),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(context),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryPills(context)),
                        const SizedBox(width: 10),
                        _buildSortDropdown(context),
                      ],
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        onChanged: (value) => safeSetState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name, email, pharmacy, or role...',
          hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).alternate,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPill('All', 0, Icons.list_rounded),
          const SizedBox(width: 8),
          _buildPill('Registrations', 1, Icons.local_pharmacy_rounded),
          const SizedBox(width: 8),
          _buildPill('Staff', 2, Icons.badge_rounded),
          const SizedBox(width: 8),
          _buildPill('Outlets', 3, Icons.store_rounded),
          const SizedBox(width: 8),
          _buildPill('Subscriptions', 4, Icons.card_membership_rounded),
        ],
      ),
    );
  }

  Widget _buildPill(String label, int index, IconData icon) {
    final isActive = _selectedCategoryTab == index;
    return InkWell(
      onTap: () => safeSetState(() => _selectedCategoryTab = index),
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF9900FF)
              : FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive
                ? const Color(0xFF9900FF)
                : FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isActive ? Colors.white : FlutterFlowTheme.of(context).secondaryText),
            const SizedBox(width: 6),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: isActive ? Colors.white : FlutterFlowTheme.of(context).secondaryText,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<String>(
        value: _sortBy,
        underline: const SizedBox.shrink(),
        icon: Icon(Icons.sort_rounded, size: 18, color: FlutterFlowTheme.of(context).secondaryText),
        items: const [
          DropdownMenuItem(value: 'newest', child: Text('Newest first')),
          DropdownMenuItem(value: 'oldest', child: Text('Oldest first')),
          DropdownMenuItem(value: 'name', child: Text('By name')),
        ],
        onChanged: (val) {
          if (val != null) safeSetState(() => _sortBy = val);
        },
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              fontWeight: FontWeight.w600,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, UserRecord user) {
    final category = _approvalCategory(user);
    final catColor = _categoryColor(category);
    final catIcon = _categoryIcon(category);
    final displayName = _displayNameFor(user);
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final timeAgo = _timeAgo(user.createdTime);
    final isUrgent = user.hasCreatedTime() &&
        DateTime.now().difference(user.createdTime!).inDays >= 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFEF4444).withValues(alpha: 0.35)
              : FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + category badge + urgency
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                          color: catColor,
                          fontWeight: FontWeight.w800,
                          useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: FlutterFlowTheme.of(context).titleLarge.override(
                                  fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
                                ),
                          ),
                        ),
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(catIcon, size: 13, color: catColor),
                              const SizedBox(width: 4),
                              Text(
                                category,
                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                      color: catColor,
                                      fontWeight: FontWeight.w700,
                                      useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Meta info row
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _buildMetaChip(Icons.email_outlined, user.email),
                        if (user.phoneNumber.isNotEmpty)
                          _buildMetaChip(Icons.call_outlined, user.phoneNumber),
                        if (user.pharmacyName.isNotEmpty && user.accountType == 'pharmacy')
                          _buildMetaChip(Icons.local_pharmacy_outlined, user.pharmacyName),
                        if (user.role.isNotEmpty)
                          _buildMetaChip(Icons.badge_outlined, user.role),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(catIcon, size: 16, color: catColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _categoryDescription(category),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row: time + urgency + actions
          Row(
            children: [
              // Time indicator
              Icon(Icons.schedule_outlined, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
              const SizedBox(width: 6),
              Text(
                'Submitted $timeAgo',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.priority_high_rounded, size: 12, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        'Urgent',
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.w700,
                              useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Action buttons
              OutlinedButton.icon(
                onPressed: () => _showRejectDialog(context, user),
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _showApproveDialog(context, user),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9900FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: FlutterFlowTheme.of(context).secondaryText),
        const SizedBox(width: 5),
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

  Widget _buildEmptyState(BuildContext context) {
    final all = _pendingUsers ?? <UserRecord>[];
    final isFiltered = _selectedCategoryTab != 0 || _searchQuery.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF9900FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isFiltered ? Icons.filter_alt_off_rounded : Icons.verified_rounded,
              size: 34,
              color: const Color(0xFF9900FF),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isFiltered ? 'No matching approvals' : 'All caught up!',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineSmallFamily,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  useGoogleFonts: !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try adjusting your filters or search terms to find what you need.'
                : 'There are no pending pharmacy approvals right now. New requests will appear here automatically.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          const SizedBox(height: 20),
          if (isFiltered)
            OutlinedButton.icon(
              onPressed: () => safeSetState(() {
                _selectedCategoryTab = 0;
                _searchQuery = '';
              }),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9900FF),
                side: const BorderSide(color: Color(0xFF9900FF)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _loadPendingApprovals,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Check for New Requests'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9900FF),
                side: const BorderSide(color: Color(0xFF9900FF)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
        ],
      ),
    );
  }

  // ─── INSIGHTS PANEL (right sidebar on wide screens) ─────────────

  Widget _buildInsightsPanel(BuildContext context) {
    final all = _pendingUsers ?? <UserRecord>[];
    final pharmReg = all.where((u) => _approvalCategory(u) == 'Pharmacy Registration').length;
    final staff = all.where((u) => _approvalCategory(u) == 'Staff Approval').length;
    final outlet = all.where((u) => _approvalCategory(u) == 'Outlet Setup').length;
    final sub = all.where((u) => _approvalCategory(u) == 'Subscription').length;
    final urgentCount = all.where((u) => u.hasCreatedTime() && DateTime.now().difference(u.createdTime!).inDays >= 3).length;
    final oldestTimes = all.where((u) => u.hasCreatedTime()).map((u) => u.createdTime!).toList()..sort();
    final oldest = oldestTimes.isNotEmpty ? oldestTimes.first : null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF9900FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insights_rounded, color: Color(0xFF9900FF), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Queue Overview',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                          ),
                    ),
                    Text(
                      'Pharmacy approval pipeline at a glance',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Queue health
          _insightMetric(
            context,
            label: 'Queue Health',
            value: all.isEmpty ? 'Clear' : (all.length <= 3 ? 'Light' : all.length <= 10 ? 'Busy' : 'Heavy'),
            helper: all.isEmpty ? 'No pending approvals' : '${all.length} request${all.length > 1 ? 's' : ''} in queue',
          ),
          const SizedBox(height: 12),
          // Breakdown
          _insightMetric(
            context,
            label: 'Approval Mix',
            value: '$pharmReg reg / $staff staff / $outlet outlet / $sub sub',
            helper: 'Prioritize pharmacy registrations first',
          ),
          const SizedBox(height: 12),
          // Urgency
          _insightMetric(
            context,
            label: 'Urgent Items',
            value: urgentCount.toString(),
            helper: urgentCount > 0
                ? 'Requests older than 3 days need attention'
                : 'All requests are within the 3-day SLA',
            valueColor: urgentCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          // Oldest
          _insightMetric(
            context,
            label: 'Oldest Request',
            value: oldest == null
                ? '--'
                : dateTimeFormat('MMM d, y', oldest, locale: FFLocalizations.of(context).languageCode),
            helper: oldest == null ? 'No active queue' : 'Process oldest requests first',
          ),
          const SizedBox(height: 20),
          // Recommended flow
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9900FF).withValues(alpha: 0.08),
                  const Color(0xFFF5F3FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Review Flow',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                      ),
                ),
                const SizedBox(height: 10),
                _buildFlowStep('1', 'Check urgent items first (3+ days old)'),
                const SizedBox(height: 6),
                _buildFlowStep('2', 'Verify pharmacy registration details'),
                const SizedBox(height: 6),
                _buildFlowStep('3', 'Approve staff only after pharmacy is verified'),
                const SizedBox(height: 6),
                _buildFlowStep('4', 'Confirm outlet belongs to correct pharmacy'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightMetric(
    BuildContext context, {
    required String label,
    required String value,
    required String helper,
    Color? valueColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: valueColor,
                  useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            helper,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).alternate,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF9900FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(
              number,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                    color: const Color(0xFF9900FF),
                    fontWeight: FontWeight.w800,
                    useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ),
      ],
    );
  }

  // ─── DIALOGS ────────────────────────────────────────────────────

  void _showApproveDialog(BuildContext context, UserRecord user) {
    final category = _approvalCategory(user);
    final name = _displayNameFor(user);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Approve Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to approve this $category request:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (user.email.isNotEmpty) Text(user.email, style: const TextStyle(fontSize: 13)),
                  if (user.pharmacyName.isNotEmpty) Text('Pharmacy: ${user.pharmacyName}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Once approved, this account will be able to sign in and access the platform immediately.',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _approveUser(user);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, UserRecord user) {
    final category = _approvalCategory(user);
    final name = _displayNameFor(user);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Reject Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to reject this $category request:'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (user.email.isNotEmpty) Text(user.email, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This will permanently remove the account from the system. This action cannot be undone.',
              style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _rejectUser(user);
            },
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
                                  loadingMessage: 'Loading pharmacy approvals',
                                  size: 60.0,
                                  showRing: true,
                                  showLabel: true,
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Page header with actions
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: _buildPharmacyHeader(context)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Stat cards
                                    _buildStatCards(context),
                                    const SizedBox(height: 20),
                                    // Filter bar
                                    _buildFilterBar(context),
                                    const SizedBox(height: 22),
                                    // Queue info bar
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.pending_actions_rounded, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${visibleUsers.length} item${visibleUsers.length != 1 ? 's' : ''} in queue',
                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                  fontWeight: FontWeight.w600,
                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                ),
                                          ),
                                          const Spacer(),
                                          OutlinedButton.icon(
                                            onPressed: _loadPendingApprovals,
                                            icon: const Icon(Icons.refresh_rounded, size: 16),
                                            label: const Text('Refresh'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: FlutterFlowTheme.of(context).secondaryText,
                                              side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    // Main content: cards + insights sidebar
                                    if (visibleUsers.isEmpty)
                                      _buildEmptyState(context)
                                    else
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isWide = constraints.maxWidth >= 1260;

                                          if (isWide) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ...visibleUsers.map(
                                                        (user) => Padding(
                                                          padding: const EdgeInsets.only(bottom: 14),
                                                          child: _buildApprovalCard(context, user),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 22),
                                                Expanded(
                                                  flex: 2,
                                                  child: _buildInsightsPanel(context),
                                                ),
                                              ],
                                            );
                                          }

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...visibleUsers.map(
                                                (user) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 14),
                                                  child: _buildApprovalCard(context, user),
                                                ),
                                              ),
                                              const SizedBox(height: 22),
                                              _buildInsightsPanel(context),
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
}
