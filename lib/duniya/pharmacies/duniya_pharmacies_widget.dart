import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'duniya_pharmacies_model.dart';
export 'duniya_pharmacies_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — PHARMACIES (Network-Wide Listing)
///
///   Lists every pharmacy on the Duniya network (active, pending
///   approval, and rejected) with their owner email, registered
///   date, and network status. Network admins can search and filter
///   by status, and click into a pharmacy to view its details.
/// ═══════════════════════════════════════════════════════════════

class DuniyaPharmaciesWidget extends StatefulWidget {
  const DuniyaPharmaciesWidget({super.key});

  static String routeName = 'DuniyaPharmacies';
  static String routePath = '/duniyaPharmacies';

  @override
  State<DuniyaPharmaciesWidget> createState() =>
      _DuniyaPharmaciesWidgetState();
}

class _DuniyaPharmaciesWidgetState extends State<DuniyaPharmaciesWidget> {
  late DuniyaPharmaciesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Active status filter pill. One of: 'All', 'Active', 'Pending', 'Rejected'.
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuniyaPharmaciesModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'DuniyaPharmacies'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //   HELPERS
  // ─────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'pending_approval':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFFD1FAE5);
      case 'pending_approval':
        return const Color(0xFFFEF3C7);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'pending_approval':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Fetches a map of `ownerRef.path → UserRecord` for all unique owner refs
  /// across the supplied pharmacies. Failures are swallowed so a single bad
  /// user doc won't break the whole listing.
  Future<Map<String, UserRecord>> _fetchOwnerMap(
      List<PharmacyRecord> pharmacies) async {
    final refs = pharmacies
        .map((p) => p.userID)
        .whereType<DocumentReference>()
        .toSet()
        .toList();
    final map = <String, UserRecord>{};
    await Future.wait(refs.map((r) async {
      try {
        final snap = await r.get();
        if (snap.exists) {
          map[r.path] = UserRecord.fromSnapshot(snap);
        }
      } catch (_) {
        // Swallow — owner record may be deleted/inaccessible.
      }
    }));
    return map;
  }

  List<PharmacyRecord> _applyFilters(
      List<PharmacyRecord> all, Map<String, UserRecord> ownerMap) {
    final search = _model.searchTextController?.text.toLowerCase().trim() ?? '';
    return all.where((p) {
      // Status filter
      if (_statusFilter == 'Active' && p.networkStatus != 'active') {
        return false;
      }
      if (_statusFilter == 'Pending' && p.networkStatus != 'pending_approval') {
        return false;
      }
      if (_statusFilter == 'Rejected' && p.networkStatus != 'rejected') {
        return false;
      }
      // Search filter
      if (search.isEmpty) return true;
      final owner = p.userID != null ? ownerMap[p.userID!.path] : null;
      final ownerEmail = owner?.email.toLowerCase() ?? '';
      final ownerName = owner?.displayName.toLowerCase() ?? '';
      return p.name.toLowerCase().contains(search) ||
          p.address.toLowerCase().contains(search) ||
          ownerEmail.contains(search) ||
          ownerName.contains(search);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // ─────────────────────────────────────────────────────────────
  //   BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Duniya Pharmacies',
      color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          drawer: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.sideNavModel,
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, -1.0),
                        child: wrapWithModel(
                          model: _model.topNavModel,
                          updateCallback: () => safeSetState(() {}),
                          child: TopNavWidget(
                            openDrawer: () async {
                              scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 8.0, 24.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroHeader(),
                              const SizedBox(height: 24.0),
                              _buildPharmacyContent(),
                            ],
                          ),
                        ),
                      ),
                      if (responsiveVisibility(
                        context: context,
                        tablet: false,
                        tabletLandscape: false,
                        desktop: false,
                      ))
                        wrapWithModel(
                          model: _model.mobileNavbarModel,
                          updateCallback: () => safeSetState(() {}),
                          child: MobileNavbarWidget(),
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

  // ═══════════════════════════════════════════════════════════════
  //   HERO HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(28.0, 24.0, 28.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, theme.secondary],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(40),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Duniya Network',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Pharmacies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duniya Pharmacies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Browse every pharmacy on the Duniya network — active, pending approval, and rejected. Click any pharmacy to view its details.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              )) ...[
                _heroAction(Icons.refresh_rounded, 'Refresh',
                    () => safeSetState(() {})),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10.0),
            border:
                Border.all(color: Colors.white.withAlpha(50), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   MAIN CONTENT (StreamBuilder → KPIs + Filters + List)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyContent() {
    return StreamBuilder<List<PharmacyRecord>>(
      stream: queryPharmacyRecord(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        final allPharmacies =
            snapshot.data!.where((p) => !p.deleted).toList();
        if (allPharmacies.isEmpty) {
          return _buildEmptyState();
        }
        return FutureBuilder<Map<String, UserRecord>>(
          future: _fetchOwnerMap(allPharmacies),
          builder: (context, ownerSnap) {
            final ownerMap = ownerSnap.data ?? {};
            final filtered = _applyFilters(allPharmacies, ownerMap);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiRow(allPharmacies),
                const SizedBox(height: 20.0),
                _buildFilterBar(),
                const SizedBox(height: 16.0),
                _buildStatusPills(allPharmacies),
                const SizedBox(height: 16.0),
                if (filtered.isEmpty)
                  _buildNoMatchState()
                else
                  _buildPharmacyList(filtered, ownerMap),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   KPI ROW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKpiRow(List<PharmacyRecord> pharmacies) {
    final total = pharmacies.length;
    final active =
        pharmacies.where((p) => p.networkStatus == 'active').length;
    final pending = pharmacies
        .where((p) => p.networkStatus == 'pending_approval')
        .length;
    final rejected =
        pharmacies.where((p) => p.networkStatus == 'rejected').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final crossAxisCount = wide ? 4 : 2;
        return Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Total Pharmacies',
                value: '$total',
                icon: Icons.storefront_rounded,
                color: FlutterFlowTheme.of(context).primary,
                bgColor: FlutterFlowTheme.of(context).primary.withAlpha(20),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Active',
                value: '$active',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFD1FAE5),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Pending Approval',
                value: '$pending',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Rejected',
                value: '$rejected',
                icon: Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEE2E2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   FILTER BAR (search + reset)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterBar() {
    final theme = FlutterFlowTheme.of(context);
    final hasActiveFilters =
        (_model.searchTextController?.text ?? '').isNotEmpty ||
            _statusFilter != 'All';
    return Container(
      padding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 320.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: theme.alternate, width: 1.0),
            ),
            child: TextField(
              controller: _model.searchTextController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search by name, address, or owner email…',
                hintStyle: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.secondaryText, size: 20.0),
                suffixIcon:
                    (_model.searchTextController?.text ?? '').isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: theme.secondaryText, size: 18.0),
                            onPressed: () {
                              _model.searchTextController?.clear();
                              safeSetState(() {});
                            },
                          )
                        : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                    12.0, 12.0, 12.0, 12.0),
              ),
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
              onChanged: (value) => safeSetState(() {}),
            ),
          ),
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                setState(() => _statusFilter = 'All');
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 16.0),
              label: Text(
                'Reset',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATUS PILLS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusPills(List<PharmacyRecord> pharmacies) {
    final theme = FlutterFlowTheme.of(context);
    final all = pharmacies.length;
    final active =
        pharmacies.where((p) => p.networkStatus == 'active').length;
    final pending = pharmacies
        .where((p) => p.networkStatus == 'pending_approval')
        .length;
    final rejected =
        pharmacies.where((p) => p.networkStatus == 'rejected').length;

    final pills = <(String, int, Color)>[
      ('All', all, theme.primary),
      ('Active', active, const Color(0xFF10B981)),
      ('Pending', pending, const Color(0xFFF59E0B)),
      ('Rejected', rejected, const Color(0xFFEF4444)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pills.map((p) {
          final (label, count, color) = p;
          final selected = _statusFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => safeSetState(() => _statusFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: selected ? color : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                      color: selected ? color : theme.alternate,
                      width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : theme.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withAlpha(40)
                            : theme.primaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : theme.secondaryText,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   PHARMACY LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyList(
      List<PharmacyRecord> pharmacies, Map<String, UserRecord> ownerMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            '${pharmacies.length} ${pharmacies.length == 1 ? 'pharmacy' : 'pharmacies'}',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          children: pharmacies
              .map((p) => _buildPharmacyCard(p, ownerMap))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPharmacyCard(
      PharmacyRecord pharmacy, Map<String, UserRecord> ownerMap) {
    final theme = FlutterFlowTheme.of(context);
    final status = pharmacy.networkStatus;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);
    final owner =
        pharmacy.userID != null ? ownerMap[pharmacy.userID!.path] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _showToast('Opening details for ${pharmacy.name}…'),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                16.0, 14.0, 16.0, 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.primary, theme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: Colors.white, size: 24.0),
                ),
                const SizedBox(width: 14.0),
                // Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pharmacy.name,
                              style: theme.titleMedium.override(
                                fontFamily: theme.titleMediumFamily,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                useGoogleFonts: !theme.titleMediumIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: statusColor.withAlpha(60),
                                  width: 1.0),
                            ),
                            child: Text(
                              _statusLabel(status).toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (pharmacy.address.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13.0,
                                color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                pharmacy.address,
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodySmallIsCustom,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6.0),
                      Wrap(
                        spacing: 14.0,
                        runSpacing: 4.0,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13.0, color: theme.secondaryText),
                              const SizedBox(width: 4.0),
                              Text(
                                'Registered ${_formatDate(pharmacy.registeredAt)}',
                                style: TextStyle(
                                  color: theme.secondaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 13.0, color: theme.secondaryText),
                              const SizedBox(width: 4.0),
                              Text(
                                owner == null
                                    ? 'Owner not linked'
                                    : (owner.email.isNotEmpty
                                        ? owner.email
                                        : (owner.displayName.isNotEmpty
                                            ? owner.displayName
                                            : 'Unknown owner')),
                                style: TextStyle(
                                  color: owner == null
                                      ? theme.secondaryText
                                      : theme.primaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(Icons.chevron_right_rounded,
                    color: theme.secondaryText, size: 22.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATES (loading / empty / no-match)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(color: theme.primary, size: 48.0, lineWidth: 3.0),
          const SizedBox(height: 20.0),
          Text(
            'Loading network pharmacies…',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Fetching pharmacies and their owners across the network',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 56.0, 32.0, 56.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primary, theme.secondary],
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: const Icon(Icons.local_pharmacy_rounded,
                color: Colors.white, size: 40.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'No pharmacies on the network yet',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Once a pharmacy registers on Duniya, it will appear here for you to review and manage.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 40.0, 32.0, 40.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              color: theme.secondaryText, size: 40.0),
          const SizedBox(height: 12.0),
          Text(
            'No pharmacies match your filters',
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Try clearing your search or selecting a different status.',
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}
