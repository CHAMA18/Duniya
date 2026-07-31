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
import 'network_analytics_model.dart';
export 'network_analytics_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — NETWORK ANALYTICS
///
///   Aggregate KPIs across every active pharmacy on the Duniya
///   network: total pharmacies, total stock value, products
///   tracked, stock movements this month, low stock alerts, and
///   average days of stock remaining. Below the KPI grid, a list
///   of the top pharmacies ranked by total stock value.
/// ═══════════════════════════════════════════════════════════════

class NetworkAnalyticsWidget extends StatefulWidget {
  const NetworkAnalyticsWidget({super.key});

  static String routeName = 'NetworkAnalytics';
  static String routePath = '/networkAnalytics';

  @override
  State<NetworkAnalyticsWidget> createState() =>
      _NetworkAnalyticsWidgetState();
}

/// Aggregate snapshot computed from the network-wide collectionGroup
/// queries. Built once per refresh and consumed by the dashboard UI.
class _NetworkStats {
  _NetworkStats({
    required this.activePharmacies,
    required this.totalStockValue,
    required this.totalProductsTracked,
    required this.totalStockMovements,
    required this.lowStockAlerts,
    required this.avgDaysRemaining,
    required this.topPharmacies,
  });

  final int activePharmacies;
  final double totalStockValue;
  final int totalProductsTracked;
  final int totalStockMovements;
  final int lowStockAlerts;
  final double avgDaysRemaining;
  final List<_PharmacyValue> topPharmacies;
}

class _PharmacyValue {
  _PharmacyValue({
    required this.name,
    required this.address,
    required this.stockValue,
    required this.productCount,
    required this.daysRemaining,
  });

  final String name;
  final String address;
  final double stockValue;
  final int productCount;
  final double daysRemaining;
}

class _NetworkAnalyticsWidgetState extends State<NetworkAnalyticsWidget> {
  late NetworkAnalyticsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NetworkAnalyticsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'NetworkAnalytics'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  //   AGGREGATION
  // ─────────────────────────────────────────────────────────────

  /// Builds the aggregate snapshot for the supplied list of active
  /// pharmacies. Per-pharmacy stock balances are fetched in
  /// parallel via `queryStockBalanceRecordOnce(parent: userID)`.
  /// Network-wide movements and low-stock alerts are fetched via
  /// collectionGroup queries.
  Future<_NetworkStats> _computeStats(List<PharmacyRecord> pharmacies) async {
    final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);

    // Per-pharmacy aggregation in parallel.
    final perPharmacy = await Future.wait(pharmacies.map((p) async {
      final ownerRef = p.userID;
      if (ownerRef == null) {
        return _PharmacyValue(
          name: p.name,
          address: p.address,
          stockValue: 0.0,
          productCount: 0,
          daysRemaining: 0.0,
        );
      }
      try {
        final balances = await queryStockBalanceRecordOnce(parent: ownerRef);
        double totalValue = 0.0;
        double totalDays = 0.0;
        int daysCount = 0;
        final productSet = <String>{};
        for (final b in balances) {
          totalValue += b.stockValue;
          if (b.productId != null) {
            productSet.add(b.productId!.path);
          }
          if (b.daysOfStockRemaining > 0) {
            totalDays += b.daysOfStockRemaining;
            daysCount++;
          }
        }
        return _PharmacyValue(
          name: p.name,
          address: p.address,
          stockValue: totalValue,
          productCount: productSet.length,
          daysRemaining: daysCount > 0 ? totalDays / daysCount : 0.0,
        );
      } catch (_) {
        return _PharmacyValue(
          name: p.name,
          address: p.address,
          stockValue: 0.0,
          productCount: 0,
          daysRemaining: 0.0,
        );
      }
    }));

    // Network-wide movements + low-stock alerts in parallel. We await
    // them together with the per-pharmacy aggregation already in
    // flight; doing so via separate variables keeps the types narrow
    // (vs. `Future.wait(<dynamic>[])`).
    final movementsFuture = queryStockMovementRecordOnce(
      queryBuilder: (q) => q.where('CreatedAt',
          isGreaterThanOrEqualTo: monthStart),
    );
    final alertsFuture = queryLowStockAlertRecordOnce();
    final movements = await movementsFuture;
    final alerts = await alertsFuture;

    double totalStockValue = 0.0;
    int totalProducts = 0;
    double totalDays = 0.0;
    int daysCount = 0;
    for (final pv in perPharmacy) {
      totalStockValue += pv.stockValue;
      totalProducts += pv.productCount;
      if (pv.daysRemaining > 0) {
        totalDays += pv.daysRemaining;
        daysCount++;
      }
    }

    final top = perPharmacy
        .where((pv) => pv.stockValue > 0)
        .toList()
      ..sort((a, b) => b.stockValue.compareTo(a.stockValue));

    return _NetworkStats(
      activePharmacies: pharmacies.length,
      totalStockValue: totalStockValue,
      totalProductsTracked: totalProducts,
      totalStockMovements: movements.length,
      lowStockAlerts: alerts.length,
      avgDaysRemaining: daysCount > 0 ? totalDays / daysCount : 0.0,
      topPharmacies: top.take(8).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //   BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Network Analytics — Duniya',
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
                              _buildContent(),
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
                'Network Analytics',
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
                  Icons.insights_rounded,
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
                      'Network Analytics',
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
                      'Real-time aggregate KPIs across every active pharmacy on the Duniya network — stock value, products tracked, movements, and low-stock alerts.',
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
          const SizedBox(height: 16.0),
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
  //   CONTENT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return StreamBuilder<List<PharmacyRecord>>(
      stream: queryPharmacyRecord(
        queryBuilder: (q) =>
            q.where('NetworkStatus', isEqualTo: 'active'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        final active = snapshot.data!.where((p) => !p.deleted).toList();
        if (active.isEmpty) {
          return _buildEmptyState();
        }
        return FutureBuilder<_NetworkStats>(
          future: _computeStats(active),
          builder: (context, statsSnap) {
            if (!statsSnap.hasData) {
              return _buildLoadingState();
            }
            final stats = statsSnap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiGrid(stats),
                const SizedBox(height: 24.0),
                _buildTopPharmacies(stats),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   KPI GRID (6 cards)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKpiGrid(_NetworkStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1100) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 720) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }
        final spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                crossAxisCount;
        final cards = <Widget>[
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Active Pharmacies',
              value: '${stats.activePharmacies}',
              subtitle: stats.activePharmacies == 1
                  ? 'pharmacy live on Duniya'
                  : 'pharmacies live on Duniya',
              icon: Icons.storefront_rounded,
              color: FlutterFlowTheme.of(context).primary,
              bgColor: FlutterFlowTheme.of(context).primary.withAlpha(20),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Total Stock Value',
              value:
                  'ZMK ${formatNumber(stats.totalStockValue, formatType: FormatType.compact)}',
              subtitle: 'across the entire network',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF10B981),
              bgColor: const Color(0xFFD1FAE5),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Products Tracked',
              value: formatNumber(stats.totalProductsTracked,
                  formatType: FormatType.compact),
              subtitle: 'distinct SKUs in stock',
              icon: Icons.medication_rounded,
              color: const Color(0xFF8B5CF6),
              bgColor: const Color(0xFFEDE9FE),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Stock Movements (Month)',
              value: formatNumber(stats.totalStockMovements,
                  formatType: FormatType.compact),
              subtitle: 'recorded this month',
              icon: Icons.swap_vert_rounded,
              color: const Color(0xFF0EA5E9),
              bgColor: const Color(0xFFE0F2FE),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Low Stock Alerts',
              value: '${stats.lowStockAlerts}',
              subtitle: stats.lowStockAlerts == 0
                  ? 'no pharmacies need attention'
                  : 'pharmacies need attention',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0xFFFEF3C7),
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _kpiCard(
              title: 'Avg Days of Stock',
              value: '${stats.avgDaysRemaining.toStringAsFixed(0)}d',
              subtitle: 'remaining across network',
              icon: Icons.schedule_rounded,
              color: const Color(0xFFEC4899),
              bgColor: const Color(0xFFFCE7F3),
            ),
          ),
        ];
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards,
        );
      },
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18.0, 16.0, 18.0, 16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            value,
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   TOP PHARMACIES BY STOCK VALUE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopPharmacies(_NetworkStats stats) {
    final theme = FlutterFlowTheme.of(context);
    if (stats.topPharmacies.isEmpty) {
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
            Icon(Icons.bar_chart_rounded,
                color: theme.secondaryText, size: 40.0),
            const SizedBox(height: 12.0),
            Text(
              'No stock value recorded yet',
              style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                useGoogleFonts: !theme.titleMediumIsCustom,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Once pharmacies start receiving stock, the top performers by stock value will appear here.',
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

    final maxValue = stats.topPharmacies.first.stockValue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.primary, theme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.leaderboard_rounded,
                    color: Colors.white, size: 18.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Pharmacies by Stock Value',
                      style: theme.titleMedium.override(
                        fontFamily: theme.titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                    Text(
                      '${stats.topPharmacies.length} ${stats.topPharmacies.length == 1 ? 'pharmacy' : 'pharmacies'} ranked by total stock value',
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Column(
            children: stats.topPharmacies.asMap().entries.map((entry) {
              final i = entry.key;
              final pv = entry.value;
              final pct = maxValue > 0 ? (pv.stockValue / maxValue) : 0.0;
              return _topPharmacyRow(i, pv, pct, theme);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _topPharmacyRow(
      int index, _PharmacyValue pv, double pct, FlutterFlowTheme theme) {
    final isTop = index == 0;
    final rankColors = [
      const Color(0xFFF59E0B), // #1 — gold
      const Color(0xFF9CA3AF), // #2 — silver
      const Color(0xFFB45309), // #3 — bronze
      theme.primary, // rest — purple
    ];
    final rankColor = rankColors[index < 3 ? index : 3];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank badge
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: rankColor.withAlpha(60), width: 1.0),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Body: name + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pv.name,
                        style: TextStyle(
                          color: theme.primaryText,
                          fontSize: 13.0,
                          fontWeight:
                              isTop ? FontWeight.w700 : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'ZMK ${formatNumber(pv.stockValue, formatType: FormatType.compact)}',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 8.0,
                    backgroundColor: theme.primaryBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? rankColor : theme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    if (pv.address.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined,
                          size: 11.0, color: theme.secondaryText),
                      const SizedBox(width: 3.0),
                      Expanded(
                        child: Text(
                          pv.address,
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                    Icon(Icons.medication_liquid_rounded,
                        size: 11.0, color: theme.secondaryText),
                    const SizedBox(width: 3.0),
                    Text(
                      '${pv.productCount} ${pv.productCount == 1 ? 'product' : 'products'}',
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(Icons.schedule_rounded,
                        size: 11.0, color: theme.secondaryText),
                    const SizedBox(width: 3.0),
                    Text(
                      '${pv.daysRemaining.toStringAsFixed(0)}d',
                      style: TextStyle(
                        color: pv.daysRemaining < 7
                            ? const Color(0xFFEF4444)
                            : pv.daysRemaining < 14
                                ? const Color(0xFFF59E0B)
                                : theme.secondaryText,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATES (loading + empty)
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
            'Aggregating network KPIs…',
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
            'Fetching stock balances, movements, and alerts across all pharmacies',
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
            child: const Icon(Icons.insights_rounded,
                color: Colors.white, size: 40.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'No active pharmacies yet',
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
            'Once pharmacies are approved on the Duniya network, their aggregate KPIs will be computed and shown here in real-time.',
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
}
