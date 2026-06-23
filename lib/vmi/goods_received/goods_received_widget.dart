import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'goods_received_model.dart';
export 'goods_received_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — GOODS RECEIVED (World-Class Redesign)
///   Top 1% receiving UX: hero header, KPI cards, smart filters,
///   status pills, beautiful card list with status badges and
///   inline quick actions, and a stunning empty state.
/// ═══════════════════════════════════════════════════════════════

class GoodsReceivedWidget extends StatefulWidget {
  const GoodsReceivedWidget({super.key});

  static String routeName = 'GoodsReceived';
  static String routePath = '/goodsReceived';

  @override
  State<GoodsReceivedWidget> createState() => _GoodsReceivedWidgetState();
}

class _GoodsReceivedWidgetState extends State<GoodsReceivedWidget> {
  late GoodsReceivedModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Sort state
  String _sortColumn = 'date';
  bool _sortAscending = false;

  // Status filter pills
  String _statusFilter = 'All';

  // KPI cache
  int _lastTotal = 0;
  int _lastPending = 0;
  int _lastConfirmed = 0;
  int _lastDiscrepancy = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoodsReceivedModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'GoodsReceived'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  DocumentReference? _pharmacyScopeParent() {
    return valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef ?? currentUserReference;
  }

  DocumentReference? _resolvePharmacyRef(List<PharmacyRecord> pharmacies) {
    final name = (_model.pharmacyValue ?? '').trim();
    if (name.isEmpty || name == 'All Pharmacies') {
      return null;
    }
    return pharmacies.firstWhereOrNull((p) => p.name == name)?.reference;
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATUS HELPERS
  // ═══════════════════════════════════════════════════════════════

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFF10B981); // Emerald 500
      case 'PENDING':
        return const Color(0xFFF59E0B); // Amber 500
      case 'DISCREPANCY':
        return const Color(0xFFEF4444); // Red 500
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return const Color(0xFFD1FAE5); // Emerald 100
      case 'PENDING':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'DISCREPANCY':
        return const Color(0xFFFEE2E2); // Red 100
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Icons.check_circle_rounded;
      case 'PENDING':
        return Icons.pending_actions_rounded;
      case 'DISCREPANCY':
        return Icons.warning_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Pending';
      case 'DISCREPANCY':
        return 'Discrepancy';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.0),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   MAIN BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Goods Received',
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
                      child: SideNavWidget(),
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
                                // ─────────────────────────────────────
                                // 1. HERO HEADER
                                // ─────────────────────────────────────
                                _buildHeroHeader(),
                                const SizedBox(height: 24.0),

                                // ─────────────────────────────────────
                                // 2. KPI CARDS
                                // ─────────────────────────────────────
                                _buildKpiGrid(),

                                // ─────────────────────────────────────
                                // 3. SMART FILTER BAR
                                // ─────────────────────────────────────
                                const SizedBox(height: 24.0),
                                _buildFilterBar(),

                                // ─────────────────────────────────────
                                // 4. STATUS PILLS
                                // ─────────────────────────────────────
                                const SizedBox(height: 16.0),
                                _buildStatusPills(),

                                // ─────────────────────────────────────
                                // 5. CONTENT (list or empty state)
                                // ─────────────────────────────────────
                                const SizedBox(height: 16.0),
                                AuthUserStreamWidget(
                                  builder: (context) =>
                                      StreamBuilder<List<GoodsReceivedRecord>>(
                                    stream: queryGoodsReceivedRecord(
                                      parent: _pharmacyScopeParent(),
                                      queryBuilder: (goodsReceivedRecord) {
                                        var query =
                                            goodsReceivedRecord.orderBy(
                                                'CreatedAt',
                                                descending: true);
                                        if (_model.pharmacyRef != null) {
                                          query = query.where('OutletId',
                                              isEqualTo: _model.pharmacyRef);
                                        }
                                        return query;
                                      },
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return _buildLoadingState();
                                      }
                                      List<GoodsReceivedRecord> receipts =
                                          snapshot.data!;

                                      // Compute KPIs
                                      _lastTotal = receipts.length;
                                      _lastPending = receipts
                                          .where((r) =>
                                              r.status == 'PENDING')
                                          .length;
                                      _lastConfirmed = receipts
                                          .where((r) =>
                                              r.status == 'CONFIRMED')
                                          .length;
                                      _lastDiscrepancy = receipts
                                          .where((r) =>
                                              r.status == 'DISCREPANCY')
                                          .length;

                                      // Apply status pill filter
                                      if (_statusFilter != 'All') {
                                        receipts = receipts
                                            .where((r) =>
                                                r.status == _statusFilter)
                                            .toList();
                                      }

                                      // Apply search filter
                                      String? search = _model
                                          .searchTextController?.text
                                          .toLowerCase();
                                      if (search != null &&
                                          search.isNotEmpty) {
                                        receipts = receipts.where((r) {
                                          final note = r
                                              .deliveryNoteNumber
                                              .toLowerCase();
                                          return note.contains(search);
                                        }).toList();
                                      }

                                      // Sort
                                      receipts.sort((a, b) {
                                        int cmp;
                                        switch (_sortColumn) {
                                          case 'status':
                                            cmp = a.status.compareTo(b.status);
                                            break;
                                          case 'note':
                                            cmp = a.deliveryNoteNumber
                                                .compareTo(b
                                                    .deliveryNoteNumber);
                                            break;
                                          case 'date':
                                          default:
                                            final aDate = a.receivedDate ??
                                                a.deliveryDate ??
                                                a.createdAt;
                                            final bDate = b.receivedDate ??
                                                b.deliveryDate ??
                                                b.createdAt;
                                            cmp = (aDate ??
                                                    DateTime.now())
                                                .compareTo(bDate ??
                                                    DateTime.now());
                                        }
                                        return _sortAscending ? cmp : -cmp;
                                      });

                                      if (receipts.isEmpty) {
                                        return _buildEmptyState();
                                      }

                                      return _buildReceiptsList(receipts);
                                    },
                                  ),
                                ),
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
        ));
  }

  // ═══════════════════════════════════════════════════════════════
  //   HERO HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader() {
    final theme = FlutterFlowTheme.of(context);
    final now = DateTime.now();
    final lastUpdated =
        '${now.day}/${now.month}/${now.year} · ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                'Operations',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Goods Received',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Title + actions row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient icon badge
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
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Goods Received',
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
                      'Track every delivery, reconcile discrepancies, and keep your inventory audit-ready across all pharmacies.',
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
              // Action buttons (desktop only)
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              )) ...[
                _HeroActionButton(
                  icon: Icons.download_rounded,
                  label: 'Export',
                  onTap: () => _showToast('Exporting goods received…'),
                  isPrimary: false,
                ),
                const SizedBox(width: 8.0),
                _HeroActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: () => safeSetState(() {}),
                  isPrimary: false,
                ),
                const SizedBox(width: 8.0),
                _HeroActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Receipt',
                  onTap: () async {
                    context.pushNamed(GoodsReceivedDetailWidget.routeName);
                  },
                  isPrimary: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),

          // Last updated + live indicator
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34D399).withAlpha(120),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Live · Last updated $lastUpdated',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   KPI CARDS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossCount = 4;
        double available = constraints.maxWidth;
        if (available < 1100) crossCount = 2;
        if (available < 600) crossCount = 1;

        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Total Receipts',
                value: '$_lastTotal',
                icon: Icons.inventory_2_rounded,
                accentColor: FlutterFlowTheme.of(context).primary,
                accentBg: const Color(0xFFEDE0FE),
                delta: _lastTotal > 0 ? '$_lastTotal records' : 'No records yet',
                deltaPositive: _lastTotal > 0,
                deltaIsNeutral: _lastTotal == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Pending',
                value: '$_lastPending',
                icon: Icons.pending_actions_rounded,
                accentColor: const Color(0xFFF59E0B),
                accentBg: const Color(0xFFFEF3C7),
                delta: _lastPending > 0 ? 'Awaiting confirmation' : 'All confirmed',
                deltaPositive: _lastPending == 0,
                deltaIsNeutral: _lastPending == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Confirmed',
                value: '$_lastConfirmed',
                icon: Icons.check_circle_rounded,
                accentColor: const Color(0xFF10B981),
                accentBg: const Color(0xFFD1FAE5),
                delta: _lastConfirmed > 0 ? 'Ready for stock' : 'None yet',
                deltaPositive: true,
                deltaIsNeutral: _lastConfirmed == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Discrepancies',
                value: '$_lastDiscrepancy',
                icon: Icons.warning_rounded,
                accentColor: const Color(0xFFEF4444),
                accentBg: const Color(0xFFFEE2E2),
                delta: _lastDiscrepancy > 0 ? 'Needs review' : 'No discrepancies',
                deltaPositive: _lastDiscrepancy == 0,
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   FILTER BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterBar() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
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
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search bar
          Container(
            width: 280.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: theme.alternate, width: 1.0),
            ),
            child: TextField(
              controller: _model.searchTextController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search by delivery note #…',
                hintStyle: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.secondaryText, size: 20.0),
                suffixIcon: (_model.searchTextController?.text ?? '')
                        .isNotEmpty
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

          // Pharmacy dropdown
          AuthUserStreamWidget(
            builder: (context) =>
                FutureBuilder<List<PharmacyRecord>>(
              future: queryPharmacyRecordOnce(
                parent: _pharmacyScopeParent(),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _filterPlaceholder('Loading pharmacies…');
                }
                return Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: theme.alternate, width: 1.0),
                  ),
                  child: FlutterFlowDropDown<String>(
                    controller: _model.pharmacyValueController ??=
                        FormFieldController<String>(null),
                    options: [
                      'All Pharmacies',
                      ...snapshot.data!.map((p) => p.name).toList(),
                    ],
                    onChanged: (val) {
                      safeSetState(() {
                        _model.pharmacyValue = val;
                        _model.pharmacyRef = (val == null ||
                                val == 'All Pharmacies')
                            ? null
                            : _resolvePharmacyRef(snapshot.data!);
                      });
                    },
                    width: 200.0,
                    height: 44.0,
                    textStyle: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                    hintText: 'All Pharmacies',
                    icon: Icon(Icons.local_pharmacy_outlined,
                        color: theme.secondaryText, size: 18.0),
                    fillColor: theme.primaryBackground,
                    borderColor: Colors.transparent,
                    borderRadius: 10.0,
                    elevation: 2,
                    borderWidth: 0.0,
                    margin: EdgeInsets.zero,
                  ),
                );
              },
            ),
          ),

          // Period dropdown
          Container(
            width: 180.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: theme.alternate, width: 1.0),
            ),
            child: FlutterFlowDropDown<String>(
              controller: _model.periodValueController ??=
                  FormFieldController<String>(null),
              options: [
                'All Time',
                'Current Month',
                'Last Month',
                'Last 3 Months',
                'Current Year',
              ],
              onChanged: (val) =>
                  safeSetState(() => _model.periodValue = val),
              width: 180.0,
              height: 44.0,
              textStyle: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
              hintText: 'Period',
              icon: Icon(Icons.calendar_today_outlined,
                  color: theme.secondaryText, size: 18.0),
              fillColor: theme.primaryBackground,
              borderColor: Colors.transparent,
              borderRadius: 10.0,
              elevation: 2,
              borderWidth: 0.0,
              margin: EdgeInsets.zero,
            ),
          ),

          // Sort dropdown
          Container(
            width: 160.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: theme.alternate, width: 1.0),
            ),
            child: DropdownButtonFormField<String>(
              value: _sortColumn,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.sort_rounded,
                    color: theme.secondaryText, size: 18.0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              ),
              items: const [
                DropdownMenuItem(value: 'date', child: Text('Sort: Date')),
                DropdownMenuItem(
                    value: 'status', child: Text('Sort: Status')),
                DropdownMenuItem(
                    value: 'note', child: Text('Sort: Note #')),
              ],
              onChanged: (val) =>
                  safeSetState(() => _sortColumn = val ?? 'date'),
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
              dropdownColor: theme.secondaryBackground,
            ),
          ),

          // Reset filters (only when filters active)
          if ((_model.searchTextController?.text ?? '').isNotEmpty ||
              _model.pharmacyRef != null ||
              _model.periodValue != null ||
              _statusFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyValue = null;
                _model.pharmacyRef = null;
                _model.pharmacyValueController?.reset();
                _model.periodValue = null;
                _model.periodValueController?.reset();
                setState(() => _statusFilter = 'All');
              },
              icon: Icon(Icons.restart_alt_rounded, size: 16.0),
              label: Text(
                'Reset',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterPlaceholder(String label) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: 200.0,
      height: 44.0,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12.0),
          Icon(Icons.local_pharmacy_outlined,
              color: theme.secondaryText, size: 18.0),
          const SizedBox(width: 8.0),
          Text(label, style: theme.bodySmall),
          const Spacer(),
          SizedBox(
            width: 16.0,
            height: 16.0,
            child: SpinKitRing(
              color: theme.primary,
              size: 16.0,
              lineWidth: 2.0,
            ),
          ),
          const SizedBox(width: 12.0),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATUS PILLS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusPills() {
    final theme = FlutterFlowTheme.of(context);
    final pills = [
      ('All', _lastTotal, theme.primary, theme.primaryBackground),
      ('Pending', _lastPending, const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7)),
      ('Confirmed', _lastConfirmed, const Color(0xFF10B981),
          const Color(0xFFD1FAE5)),
      ('Discrepancy', _lastDiscrepancy, const Color(0xFFEF4444),
          const Color(0xFFFEE2E2)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pills.map((p) {
          final (label, count, fg, bg) = p;
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
                  color: selected ? fg : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: selected ? fg : theme.alternate,
                    width: 1.0,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: fg.withAlpha(60),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? Colors.white : theme.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withAlpha(60)
                            : bg,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: selected ? Colors.white : fg,
                          fontSize: 11,
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
  //   RECEIPTS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildReceiptsList(List<GoodsReceivedRecord> receipts) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
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
      child: Column(
        children: [
          // List header bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              border: Border(
                bottom: BorderSide(color: theme.alternate, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_rounded,
                    color: theme.primary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'Showing ${receipts.length} receipt${receipts.length == 1 ? '' : 's'}',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                const Spacer(),
                FFButtonWidget(
                  onPressed: () async {
                    context.pushNamed(GoodsReceivedDetailWidget.routeName);
                  },
                  text: 'Add Receipt',
                  icon: const Icon(Icons.add_rounded, size: 16.0),
                  options: FFButtonOptions(
                    height: 36.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    color: theme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
          ),

          // Cards list
          ...receipts.asMap().entries.map((entry) {
            final index = entry.key;
            final receipt = entry.value;
            return _buildReceiptCard(receipt, index, receipts.length);
          }),

          // Footer
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              border: Border(
                top: BorderSide(color: theme.alternate, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: theme.secondaryText, size: 14.0),
                const SizedBox(width: 6.0),
                Text(
                  'Tip: use status pills above to filter · click a receipt to view details',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
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

  Widget _buildReceiptCard(
      GoodsReceivedRecord receipt, int index, int totalCount) {
    final theme = FlutterFlowTheme.of(context);
    final status = receipt.status;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);
    final statusIcon = _statusIcon(status);

    final deliveryStr = receipt.hasDeliveryDate()
        ? dateTimeFormat('yMMMd', receipt.deliveryDate!,
            locale: FFLocalizations.of(context).languageCode)
        : 'No delivery date';
    final receivedStr = receipt.hasReceivedDate()
        ? dateTimeFormat('yMMMd · jm', receipt.receivedDate!,
            locale: FFLocalizations.of(context).languageCode)
        : 'Not yet received';

    final isLast = index == totalCount - 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          context.pushNamed(
            GoodsReceivedDetailWidget.routeName,
            pathParameters: {
              'docRef': receipt.reference.path,
            },
          );
        },
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: theme.alternate, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              // Status icon badge
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24.0),
              ),
              const SizedBox(width: 16.0),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            receipt.deliveryNoteNumber.isEmpty
                                ? 'Receipt #${index + 1}'
                                : receipt.deliveryNoteNumber,
                            style: theme.titleMedium.override(
                              fontFamily: theme.titleMediumFamily,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              useGoogleFonts: !theme.titleMediumIsCustom,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    // Pharmacy + dates row
                    FutureBuilder<PharmacyRecord?>(
                      future: receipt.outletId != null
                          ? PharmacyRecord.getDocumentOnce(
                              receipt.outletId!)
                          : Future.value(null),
                      builder: (context, pharmacySnapshot) {
                        final pharmacyName = (pharmacySnapshot.hasData &&
                                pharmacySnapshot.data != null &&
                                pharmacySnapshot.data!.name.isNotEmpty)
                            ? pharmacySnapshot.data!.name
                            : 'All Pharmacies';
                        return Row(
                          children: [
                            // Pharmacy pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: theme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_pharmacy_outlined,
                                      size: 11.0, color: theme.primary),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    pharmacyName,
                                    style: theme.bodySmall.override(
                                      fontFamily: theme.bodySmallFamily,
                                      color: theme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !theme.bodySmallIsCustom,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Icon(Icons.local_shipping_outlined,
                                size: 12.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Flexible(
                              child: Text(
                                deliveryStr,
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
                            const SizedBox(width: 12.0),
                            Icon(Icons.event_available_rounded,
                                size: 12.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Flexible(
                              child: Text(
                                receivedStr,
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
                        );
                      },
                    ),
                    if (receipt.hasDiscrepancies() &&
                        (receipt.discrepancies ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 12.0, color: const Color(0xFFEF4444)),
                          const SizedBox(width: 4.0),
                          Flexible(
                            child: Text(
                              receipt.discrepancies!,
                              style: theme.bodySmall.override(
                                fontFamily: theme.bodySmallFamily,
                                color: const Color(0xFFEF4444),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodySmallIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Quick actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionIcon(
                    Icons.visibility_outlined,
                    'View details',
                    theme,
                    onTap: () async {
                      context.pushNamed(
                        GoodsReceivedDetailWidget.routeName,
                        pathParameters: {
                          'docRef': receipt.reference.path,
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 6.0),
                  _actionIcon(
                    Icons.print_outlined,
                    'Print receipt',
                    theme,
                    onTap: () => _showToast(
                        'Printing ${receipt.deliveryNoteNumber}…'),
                  ),
                  const SizedBox(width: 6.0),
                  _actionIcon(
                    Icons.delete_outline_rounded,
                    'Delete',
                    theme,
                    iconColor: theme.error,
                    onTap: () => _showDeleteConfirmation(receipt),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(Icons.chevron_right_rounded,
                      color: theme.secondaryText, size: 20.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    String tooltip,
    FlutterFlowTheme theme, {
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: theme.alternate, width: 1.0),
          ),
          child: Icon(icon,
              color: iconColor ?? theme.secondaryText, size: 16.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GoodsReceivedRecord receipt) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              Icon(Icons.warning_rounded,
                  color: FlutterFlowTheme.of(context).error, size: 24.0),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Delete receipt?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400.0),
            child: Text(
              'This action cannot be undone. The receipt "${receipt.deliveryNoteNumber}" and all its line items will be permanently deleted.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondaryText),
              ),
            ),
            FFButtonWidget(
              onPressed: () async {
                await receipt.reference.delete();
                Navigator.pop(dialogContext);
                _showToast(
                    'Receipt ${receipt.deliveryNoteNumber} deleted');
              },
              text: 'Delete',
              icon: Icon(Icons.delete_outline_rounded, size: 16.0),
              options: FFButtonOptions(
                height: 40.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                color: FlutterFlowTheme.of(context).error,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                  color: Colors.white,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleSmallIsCustom,
                ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    final hasActiveFilters =
        (_model.searchTextController?.text ?? '').isNotEmpty ||
            _model.pharmacyRef != null ||
            _model.periodValue != null ||
            _statusFilter != 'All';

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 56.0, 32.0, 56.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  theme.primary.withAlpha(40),
                  theme.primary.withAlpha(0),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.primary, theme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withAlpha(80),
                      blurRadius: 16.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  hasActiveFilters
                      ? Icons.search_off_rounded
                      : Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Heading
          Text(
            hasActiveFilters
                ? 'No matching receipts'
                : 'No goods received yet',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),

          // Description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Text(
              hasActiveFilters
                  ? 'Try adjusting your search terms or clearing filters to see more receipts. Check the pharmacy, status, or time period you have selected.'
                  : 'Goods received records track every delivery into your pharmacy — delivery note numbers, dates, line items, and any discrepancies. Add your first receipt to start building an audit-ready receiving history.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          const SizedBox(height: 28.0),

          // CTAs
          if (hasActiveFilters) ...[
            FFButtonWidget(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyValue = null;
                _model.pharmacyRef = null;
                _model.pharmacyValueController?.reset();
                _model.periodValue = null;
                _model.periodValueController?.reset();
                setState(() => _statusFilter = 'All');
              },
              text: 'Clear All Filters',
              icon: Icon(Icons.restart_alt_rounded, size: 16.0),
              options: FFButtonOptions(
                height: 44.0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
                color: theme.primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0.0,
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ] else ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                FFButtonWidget(
                  onPressed: () async {
                    context.pushNamed(GoodsReceivedDetailWidget.routeName);
                  },
                  text: 'Add Your First Receipt',
                  icon: Icon(Icons.add_rounded, size: 18.0),
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 0.0),
                    color: theme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () => _showToast('Opening receiving guide…'),
                  text: 'Learn How It Works',
                  icon: Icon(Icons.help_outline_rounded, size: 18.0),
                  options: FFButtonOptions(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0.0),
                    color: theme.secondaryBackground,
                    textStyle: TextStyle(
                      color: theme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0.0,
                    borderSide:
                        BorderSide(color: theme.alternate, width: 1.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Help link
            TextButton.icon(
              onPressed: () => _showToast('Opening documentation…'),
              icon: Icon(Icons.menu_book_rounded,
                  size: 14.0, color: theme.secondaryText),
              label: Text(
                'Read the goods received guide',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],

          const SizedBox(height: 40.0),

          // Feature highlights row
          if (!hasActiveFilters)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: theme.alternate, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _featureHint(
                    Icons.local_shipping_rounded,
                    'Track Deliveries',
                    'Every receipt logged',
                    theme,
                  ),
                  _divider(theme),
                  _featureHint(
                    Icons.compare_arrows_rounded,
                    'Spot Variances',
                    'Quantity vs ordered',
                    theme,
                  ),
                  _divider(theme),
                  _featureHint(
                    Icons.verified_rounded,
                    'Audit Trail',
                    'Approval workflow',
                    theme,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureHint(
      IconData icon, String title, String subtitle, FlutterFlowTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(icon, color: Colors.white, size: 20.0),
        ),
        const SizedBox(height: 10.0),
        Text(
          title,
          style: theme.bodyMedium.override(
            fontFamily: theme.bodyMediumFamily,
            fontWeight: FontWeight.w600,
            fontSize: 12.0,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          subtitle,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            fontSize: 11.0,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
      ],
    );
  }

  Widget _divider(FlutterFlowTheme theme) {
    return Container(
      width: 1.0,
      height: 50.0,
      color: theme.alternate,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   LOADING STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(
            color: theme.primary,
            size: 48.0,
            lineWidth: 3.0,
          ),
          const SizedBox(height: 20.0),
          Text(
            'Loading goods received…',
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
            'Fetching live data from your pharmacies',
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
}

// ═══════════════════════════════════════════════════════════════
//   HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white
                : Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isPrimary
                  ? Colors.white
                  : Colors.white.withAlpha(50),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: isPrimary
                    ? const Color(0xFF9900FF)
                    : Colors.white,
              ),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary
                      ? const Color(0xFF9900FF)
                      : Colors.white,
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
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.delta,
    required this.deltaPositive,
    this.deltaIsNeutral = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final String delta;
  final bool deltaPositive;
  final bool deltaIsNeutral;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(6),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: accentColor, size: 18.0),
              ),
              const Spacer(),
              if (!deltaIsNeutral)
                Icon(
                  deltaPositive
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 14.0,
                  color: deltaPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            label,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              fontWeight: FontWeight.w700,
              fontSize: 22.0,
              letterSpacing: -0.5,
              useGoogleFonts: !theme.headlineMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: deltaIsNeutral
                      ? theme.primaryBackground
                      : (deltaPositive
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  delta,
                  style: TextStyle(
                    color: deltaIsNeutral
                        ? theme.secondaryText
                        : (deltaPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444)),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                'current status',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
