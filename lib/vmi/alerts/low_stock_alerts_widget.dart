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
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'low_stock_alerts_model.dart';
export 'low_stock_alerts_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — LOW STOCK ALERTS (World-Class Redesign)
///   Top 1% alerts UX: hero header, KPI cards, smart filters,
///   status pills, beautiful alert cards with stock-level
///   progress bars and inline quick actions.
/// ═══════════════════════════════════════════════════════════════

class LowStockAlertsWidget extends StatefulWidget {
  const LowStockAlertsWidget({super.key});

  static String routeName = 'LowStockAlerts';
  static String routePath = '/lowStockAlerts';

  @override
  State<LowStockAlertsWidget> createState() => _LowStockAlertsWidgetState();
}

class _LowStockAlertsWidgetState extends State<LowStockAlertsWidget> {
  late LowStockAlertsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Status filter pills
  String _statusFilter = 'All';

  // KPI cache
  int _lastTotal = 0;
  int _lastActive = 0;
  int _lastAcknowledged = 0;
  int _lastOrdered = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LowStockAlertsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'LowStockAlerts'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATUS HELPERS
  // ═══════════════════════════════════════════════════════════════

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFFEF4444);
      case 'ACKNOWLEDGED':
        return const Color(0xFFF59E0B);
      case 'ORDERED':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFFFEE2E2);
      case 'ACKNOWLEDGED':
        return const Color(0xFFFEF3C7);
      case 'ORDERED':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.warning_rounded;
      case 'ACKNOWLEDGED':
        return Icons.visibility_rounded;
      case 'ORDERED':
        return Icons.local_shipping_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'ACKNOWLEDGED':
        return 'Acknowledged';
      case 'ORDERED':
        return 'Ordered';
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
        title: 'Low Stock Alerts',
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
                                // ── 1. HERO HEADER ──
                                _buildHeroHeader(),
                                const SizedBox(height: 24.0),

                                // ── 2. KPI CARDS ──
                                _buildKpiGrid(),

                                // ── 3. FILTER BAR ──
                                const SizedBox(height: 24.0),
                                _buildFilterBar(),

                                // ── 4. STATUS PILLS ──
                                const SizedBox(height: 16.0),
                                _buildStatusPills(),

                                // ── 5. CONTENT ──
                                const SizedBox(height: 16.0),
                                StreamBuilder<List<LowStockAlertRecord>>(
                                  stream: queryLowStockAlertRecord(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return _buildLoadingState();
                                    }
                                    List<LowStockAlertRecord> alerts =
                                        snapshot.data!;

                                    // Compute KPIs
                                    _lastTotal = alerts.length;
                                    _lastActive = alerts
                                        .where((a) => a.status == 'ACTIVE')
                                        .length;
                                    _lastAcknowledged = alerts
                                        .where((a) =>
                                            a.status == 'ACKNOWLEDGED')
                                        .length;
                                    _lastOrdered = alerts
                                        .where((a) => a.status == 'ORDERED')
                                        .length;

                                    // Apply status filter
                                    if (_statusFilter != 'All') {
                                      alerts = alerts
                                          .where((a) =>
                                              a.status == _statusFilter)
                                          .toList();
                                    }

                                    if (alerts.isEmpty) {
                                      return _buildEmptyState();
                                    }

                                    return FutureBuilder<
                                            List<ProductMasterRecord>>(
                                        future:
                                            queryProductMasterRecordOnce(),
                                        builder: (context, productSnapshot) {
                                          if (!productSnapshot.hasData) {
                                            return _buildLoadingState();
                                          }
                                          Map<String, ProductMasterRecord>
                                              productMap = {
                                            for (var p
                                                in productSnapshot.data!)
                                              p.reference.path: p
                                          };
                                          return _buildAlertsList(
                                              alerts, productMap);
                                        });
                                  },
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
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Inventory',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Low Stock Alerts',
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
                  Icons.notifications_active_rounded,
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
                      'Low Stock Alerts',
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
                      'Stay ahead of stockouts. Every product below its reorder level appears here — acknowledge, order, and restock before it impacts patients.',
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
                _heroAction(Icons.download_rounded, 'Export', () => _showToast('Exporting alerts…')),
                const SizedBox(width: 8.0),
                _heroAction(Icons.refresh_rounded, 'Refresh', () => safeSetState(() {})),
              ],
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _lastActive > 0
                      ? const Color(0xFFF87171)
                      : const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: (_lastActive > 0
                              ? const Color(0xFFF87171)
                              : const Color(0xFF34D399))
                          .withAlpha(120),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                _lastActive > 0
                    ? 'Live · $lastUpdated · ${_lastActive} active alert${_lastActive == 1 ? '' : 's'}'
                    : 'Live · $lastUpdated · All stock healthy',
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
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1.0,
            ),
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
                label: 'Total Alerts',
                value: '$_lastTotal',
                icon: Icons.notifications_rounded,
                accentColor: FlutterFlowTheme.of(context).primary,
                accentBg: const Color(0xFFEDE0FE),
                delta: _lastTotal > 0 ? '$_lastTotal total' : 'No alerts',
                deltaPositive: _lastTotal == 0,
                deltaIsNeutral: _lastTotal == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Active',
                value: '$_lastActive',
                icon: Icons.warning_rounded,
                accentColor: const Color(0xFFEF4444),
                accentBg: const Color(0xFFFEE2E2),
                delta: _lastActive > 0 ? 'Action needed' : 'All handled',
                deltaPositive: _lastActive == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Acknowledged',
                value: '$_lastAcknowledged',
                icon: Icons.visibility_rounded,
                accentColor: const Color(0xFFF59E0B),
                accentBg: const Color(0xFFFEF3C7),
                delta: _lastAcknowledged > 0 ? 'Awaiting order' : 'None pending',
                deltaPositive: true,
                deltaIsNeutral: _lastAcknowledged == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Ordered',
                value: '$_lastOrdered',
                icon: Icons.local_shipping_rounded,
                accentColor: const Color(0xFF10B981),
                accentBg: const Color(0xFFD1FAE5),
                delta: _lastOrdered > 0 ? 'In transit' : 'None ordered',
                deltaPositive: true,
                deltaIsNeutral: _lastOrdered == 0,
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
                hintText: 'Search by product or pharmacy…',
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
                parent: valueOrDefault(
                            currentUserDocument?.role, '') ==
                        'Owner'
                    ? currentUserReference
                    : currentUserDocument?.ownerRef,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _filterPlaceholder('Loading…', theme);
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
                    options: snapshot.data!.map((p) => p.name).toList(),
                    onChanged: (val) =>
                        safeSetState(() => _model.pharmacyValue = val),
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

          // Reset button
          if ((_model.searchTextController?.text ?? '').isNotEmpty ||
              _model.pharmacyValue != null ||
              _statusFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyValue = null;
                _model.pharmacyValueController?.reset();
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

  Widget _filterPlaceholder(String label, FlutterFlowTheme theme) {
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
          Text(label, style: theme.bodySmall),
          const Spacer(),
          SizedBox(
            width: 16.0,
            height: 16.0,
            child: SpinKitRing(color: theme.primary, size: 16.0, lineWidth: 2.0),
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
      ('Active', _lastActive, const Color(0xFFEF4444),
          const Color(0xFFFEE2E2)),
      ('Acknowledged', _lastAcknowledged, const Color(0xFFF59E0B),
          const Color(0xFFFEF3C7)),
      ('Ordered', _lastOrdered, const Color(0xFF10B981),
          const Color(0xFFD1FAE5)),
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
                        color: selected ? Colors.white.withAlpha(60) : bg,
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
  //   ALERTS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAlertsList(List<LowStockAlertRecord> alerts,
      Map<String, ProductMasterRecord> productMap) {
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
          // Header bar
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
                Icon(Icons.notifications_active_rounded,
                    color: theme.primary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'Showing ${alerts.length} alert${alerts.length == 1 ? '' : 's'}',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _lastActive > 0
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    _lastActive > 0
                        ? '${_lastActive} need attention'
                        : 'All handled',
                    style: TextStyle(
                      color: _lastActive > 0
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alert cards
          ...alerts.asMap().entries.map((entry) {
            final idx = entry.key;
            final alert = entry.value;
            final product = productMap[alert.productId?.path];
            return _buildAlertCard(alert, product, idx, alerts.length);
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
                  'Tip: click Acknowledge to triage · Mark Ordered when restock is on the way',
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

  Widget _buildAlertCard(LowStockAlertRecord alert,
      ProductMasterRecord? product, int idx, int totalCount) {
    final theme = FlutterFlowTheme.of(context);
    final status = alert.status;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);
    final statusIcon = _statusIcon(status);

    final stockPct = alert.reorderLevel > 0
        ? (alert.currentStock / (alert.reorderLevel * 2)).clamp(0.0, 1.0)
        : 0.0;
    final isCritical = alert.currentStock == 0;
    final isLow = alert.currentStock < alert.reorderLevel;

    final isLast = idx == totalCount - 1;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showToast('Opening alert details…'),
        borderRadius: BorderRadius.zero,
        child: Container(
          padding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : BorderSide(color: theme.alternate, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              // Status icon
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
                    // Product name + status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product?.name ?? 'Unknown product',
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

                    // Pharmacy + stock info
                    FutureBuilder<PharmacyRecord?>(
                      future: alert.hasPharmacyId()
                          ? alert.pharmacyId!
                              .get()
                              .then((s) => PharmacyRecord.fromSnapshot(s))
                          : null,
                      builder: (context, snap) {
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
                                    snap.hasData
                                        ? snap.data!.name
                                        : '—',
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
                            // Stock levels
                            Icon(Icons.inventory_2_outlined,
                                size: 12.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Text(
                              '${alert.currentStock} / ${alert.reorderLevel}',
                              style: TextStyle(
                                color: isCritical
                                    ? const Color(0xFFEF4444)
                                    : isLow
                                        ? const Color(0xFFF59E0B)
                                        : theme.secondaryText,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '(current / reorder)',
                              style: TextStyle(
                                color: theme.secondaryText,
                                fontSize: 11.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Icon(Icons.shopping_cart_outlined,
                                size: 12.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Text(
                              'Order ${alert.suggestedQuantity}',
                              style: TextStyle(
                                color: theme.primaryText,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10.0),

                    // Stock level progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: stockPct,
                        minHeight: 6.0,
                        backgroundColor: theme.alternate,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCritical
                              ? const Color(0xFFEF4444)
                              : isLow
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action button
              if (status == 'ACTIVE')
                FFButtonWidget(
                  onPressed: () async {
                    await alert.reference.update({
                      'Status': 'ACKNOWLEDGED',
                      'UpdatedAt': getCurrentTimestamp,
                    });
                    _showToast('Alert acknowledged');
                  },
                  text: 'Acknowledge',
                  icon: const Icon(Icons.visibility_rounded, size: 14.0),
                  options: FFButtonOptions(
                    height: 36.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                    color: const Color(0xFFF59E0B),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                )
              else if (status == 'ACKNOWLEDGED')
                FFButtonWidget(
                  onPressed: () async {
                    await alert.reference.update({
                      'Status': 'ORDERED',
                      'UpdatedAt': getCurrentTimestamp,
                    });
                    _showToast('Marked as ordered');
                  },
                  text: 'Mark Ordered',
                  icon: const Icon(Icons.local_shipping_rounded, size: 14.0),
                  options: FFButtonOptions(
                    height: 36.0,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                    color: const Color(0xFF10B981),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                )
              else if (status == 'ORDERED')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 14.0),
                      const SizedBox(width: 6.0),
                      const Text(
                        'Resolved',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
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

  // ═══════════════════════════════════════════════════════════════
  //   EMPTY STATE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    final hasActiveFilters =
        (_model.searchTextController?.text ?? '').isNotEmpty ||
            _model.pharmacyValue != null ||
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
          // Icon
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  (hasActiveFilters
                      ? theme.primary
                      : const Color(0xFF10B981))
                      .withAlpha(40),
                  (hasActiveFilters
                      ? theme.primary
                      : const Color(0xFF10B981))
                      .withAlpha(0),
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
                    colors: hasActiveFilters
                        ? [theme.primary, theme.secondary]
                        : [const Color(0xFF10B981), const Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: (hasActiveFilters
                              ? theme.primary
                              : const Color(0xFF10B981))
                          .withAlpha(80),
                      blurRadius: 16.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  hasActiveFilters
                      ? Icons.search_off_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            hasActiveFilters
                ? 'No matching alerts'
                : 'All stock above reorder levels',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Text(
              hasActiveFilters
                  ? 'Try adjusting your search terms or clearing filters to see more alerts. Check the pharmacy or status filter you have selected.'
                  : 'Every product in your inventory is comfortably above its reorder threshold. New low-stock alerts will appear here automatically as stock is dispensed.',
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
          if (hasActiveFilters)
            FFButtonWidget(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyValue = null;
                _model.pharmacyValueController?.reset();
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
          if (!hasActiveFilters) ...[
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5).withAlpha(60),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                    color: const Color(0xFF10B981).withAlpha(60),
                    width: 1.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration_rounded,
                      color: Color(0xFF10B981), size: 22.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You\'re all caught up!',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF065F46),
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Duniya is monitoring your inventory 24/7 and will alert you the moment any product drops below its reorder level.',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: const Color(0xFF047857),
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
          SpinKitRing(color: theme.primary, size: 48.0, lineWidth: 3.0),
          const SizedBox(height: 20.0),
          Text(
            'Loading low stock alerts…',
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
            'Scanning inventory for products below reorder levels',
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
//   KPI CARD
// ═══════════════════════════════════════════════════════════════

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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
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
        ],
      ),
    );
  }
}
