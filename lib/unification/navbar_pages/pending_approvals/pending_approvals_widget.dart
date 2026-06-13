import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/components/loading_spinner_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'pending_approvals_model.dart';
export 'pending_approvals_model.dart';

class PendingApprovalsWidget extends StatefulWidget {
  const PendingApprovalsWidget({super.key});

  static String routeName = 'PendingApprovals';
  static String routePath = '/pending-approvals';

  @override
  State<PendingApprovalsWidget> createState() =>
      _PendingApprovalsWidgetState();
}

class _PendingApprovalsWidgetState extends State<PendingApprovalsWidget> {
  late PendingApprovalsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<UserRecord>? _pendingUsers;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PendingApprovalsModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadPendingApprovals();
    });
  }

  Future<void> _loadPendingApprovals() async {
    try {
      final snapshot = await queryUserRecordOnce(
        queryBuilder: (query) => query.where('approved_by_duniya', isEqualTo: false),
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

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
          body: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Sidebar
              if (responsiveVisibility(
                context: context,
                phone: true,
                tablet: true,
              ))
                wrapWithModel(
                  model: _model.sideNavModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const SideNavWidget(),
                ),

              // Main content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Top Nav
                    wrapWithModel(
                      model: _model.topNavModel,
                      updateCallback: () => safeSetState(() {}),
                      child: TopNavWidget(
                        openDrawer: () async {
                          scaffoldKey.currentState!.openDrawer();
                        },
                      ),
                    ),

                    // Page Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Approvals',
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineMediumFamily,
                                  fontWeight: FontWeight.w700,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineMediumIsCustom,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review and approve pharmacy and user registration requests',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Content
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
                          : _pendingUsers == null || _pendingUsers!.isEmpty
                              ? _buildEmptyState(context)
                              : _buildApprovalsList(context),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily:
                      FlutterFlowTheme.of(context).headlineMediumFamily,
                  color: FlutterFlowTheme.of(context).primary,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending approvals at this time.',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'New registration requests will appear here.',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalsList(BuildContext context) {
    final pharmacies = _pendingUsers!
        .where((u) => u.accountType == 'pharmacy')
        .toList();
    final duniyaUsers =
        _pendingUsers!.where((u) => u.accountType != 'pharmacy').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              _buildSummaryCard(
                context,
                title: 'Total Pending',
                count: _pendingUsers!.length,
                icon: Icons.pending_actions,
                color: FlutterFlowTheme.of(context).primary,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                context,
                title: 'Pharmacies',
                count: pharmacies.length,
                icon: Icons.local_pharmacy,
                color: Colors.teal,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                context,
                title: 'Duniya Users',
                count: duniyaUsers.length,
                icon: Icons.person_outline,
                color: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Pharmacy Approvals Section
          if (pharmacies.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'Pharmacy Accounts',
              subtitle: 'Pharmacies awaiting approval to access the platform',
              icon: Icons.local_pharmacy,
            ),
            const SizedBox(height: 12),
            ...pharmacies.map((user) => _buildApprovalCard(context, user)),
            const SizedBox(height: 32),
          ],

          // Duniya User Approvals Section
          if (duniyaUsers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'Duniya User Accounts',
              subtitle: 'Duniya users awaiting approval',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            ...duniyaUsers.map((user) => _buildApprovalCard(context, user)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).displaySmallFamily,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).displaySmallIsCustom,
                      ),
                ),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).titleMediumFamily,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleMediumIsCustom,
                  ),
            ),
            Text(
              subtitle,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily:
                        FlutterFlowTheme.of(context).bodySmallFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalCard(BuildContext context, UserRecord user) {
    final isPharmacy = user.accountType == 'pharmacy';
    final displayName = isPharmacy
        ? user.pharmacyName
        : (user.displayName.isNotEmpty ? user.displayName : user.email);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar / Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPharmacy
                  ? Colors.teal.withOpacity(0.1)
                  : Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPharmacy ? Icons.local_pharmacy : Icons.person_outline,
              color: isPharmacy ? Colors.teal : Colors.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .bodyMediumFamily,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPharmacy
                            ? Colors.teal.withOpacity(0.1)
                            : Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isPharmacy ? 'Pharmacy' : 'Duniya',
                        style: FlutterFlowTheme.of(context)
                            .labelSmall
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .labelSmallFamily,
                              color: isPharmacy ? Colors.teal : Colors.indigo,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .labelSmallIsCustom,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
                if (user.phoneNumber.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.phoneNumber,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
                if (user.hasCreatedTime()) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Registered: ${dateTimeFormat("yMMMd", user.createdTime, locale: FFLocalizations.of(context).languageCode)}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).alternate,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reject button
              OutlinedButton.icon(
                onPressed: () => _showRejectDialog(context, user),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Approve button
              ElevatedButton.icon(
                onPressed: () => _showApproveDialog(context, user),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context, UserRecord user) {
    final name = user.accountType == 'pharmacy'
        ? user.pharmacyName
        : (user.displayName.isNotEmpty ? user.displayName : user.email);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve Account'),
        content: Text(
          'Are you sure you want to approve "$name"? They will be able to sign in and access the platform immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _approveUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
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
