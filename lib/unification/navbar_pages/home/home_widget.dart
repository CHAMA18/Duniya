import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/pharma_table_widget.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'dart:math' as math;
import 'dart:ui' as dartui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'home_model.dart';
export 'home_model.dart';

class _PharmacyDashboardData {
  const _PharmacyDashboardData({
    required this.pharmacy,
    required this.stockItems,
    required this.sales,
    required this.goodsReceived,
    required this.movements,
    required this.lowStockAlertCount,
    required this.inventoryValue,
    required this.totalItemsSold,
    required this.nearExpiryItems,
    required this.lowStockItems,
  });

  final PharmacyRecord? pharmacy;
  final List<StockRecord> stockItems;
  final List<SalesRecord> sales;
  final List<GoodsReceivedRecord> goodsReceived;
  final List<StockMovementRecord> movements;
  final int lowStockAlertCount;
  final double inventoryValue;
  final int totalItemsSold;
  final int nearExpiryItems;
  final int lowStockItems;
}

class _PharmacyFinanceSnapshot {
  const _PharmacyFinanceSnapshot({
    required this.pharmacy,
    required this.revenue,
    required this.grossProfit,
    required this.netProfit,
    required this.costOfGoods,
  });

  final PharmacyRecord pharmacy;
  final double revenue;
  final double grossProfit;
  final double netProfit;
  final double costOfGoods;

  double get profitMargin => revenue > 0 ? (grossProfit / revenue) * 100 : 0.0;
}

class _DuniyaFinanceOverviewData {
  const _DuniyaFinanceOverviewData({
    required this.pharmacySnapshots,
    required this.totalRevenue,
    required this.totalGrossProfit,
    required this.totalNetProfit,
    required this.totalCostOfGoods,
  });

  final List<_PharmacyFinanceSnapshot> pharmacySnapshots;
  final double totalRevenue;
  final double totalGrossProfit;
  final double totalNetProfit;
  final double totalCostOfGoods;

  double get totalMargin =>
      totalRevenue > 0 ? (totalGrossProfit / totalRevenue) * 100 : 0.0;
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Time period selector state
  int _selectedPeriod = 0; // 0: Today, 1: 7D, 2: 30D

  // Pulse animation for low stock indicator
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // AI dot pulse animation
  late AnimationController _aiDotController;
  late Animation<double> _aiDotAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Home'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('HOME_PAGE_Home_ON_INIT_STATE');
      logFirebaseEvent('Home_generate_current_page_link');
      _model.currentPageLink = await generateCurrentPageLink(
        context,
        title: 'Link',
        imageUrl: 'Link',
        description: 'Links',
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Pulse animation for low stock badge
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // AI dot pulse animation
    _aiDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _aiDotAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _aiDotController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _aiDotController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ─── Helper: Period selector pill button ────────────────────────────
  Widget _buildPeriodPill(String label, int index) {
    final isActive = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => safeSetState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FlutterFlowTheme.of(context).primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: isActive
                    ? Colors.white
                    : FlutterFlowTheme.of(context).secondaryText,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.0,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'ZMK ${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return 'ZMK ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'ZMK ${value.toStringAsFixed(2)}';
  }

  // ─── Helper: Section header ─────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).titleLargeIsCustom,
              ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                actionLabel,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodySmallIsCustom,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDashboardActionButton({
    required String label,
    required IconData icon,
    required Color fillColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricFooterBars(Color color) {
    final heights = <double>[4, 20, 36, 48, 28, 8, 10, 6];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights
          .map(
            (height) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: height,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required Widget footer,
    required double width,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).displaySmallFamily,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  lineHeight: 1.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).displaySmallIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 12,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
          footer,
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    fontSize: 13,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader({
    required bool isPhone,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pharmacy Dashboard',
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).displaySmallFamily,
                      fontSize: isPhone ? 28 : 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      lineHeight: 1.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).displaySmallIsCustom,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage and track your primary pharmacy stock.',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ],
          ),
        ),
        if (!isPhone) ...[
          const SizedBox(width: 16),
          _buildDashboardActionButton(
            label: 'Export',
            icon: Icons.download_rounded,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            iconColor: FlutterFlowTheme.of(context).primary,
            textColor: FlutterFlowTheme.of(context).primary,
            onTap: () async {
              logFirebaseEvent('HOME_PAGE_Export_ON_TAP');
            },
          ),
          const SizedBox(width: 12),
          _buildDashboardActionButton(
            label: 'Add Product',
            icon: Icons.add_rounded,
            fillColor: Colors.black,
            iconColor: Colors.white,
            textColor: Colors.white,
            isPrimary: true,
            onTap: () async {
              logFirebaseEvent('HOME_PAGE_AddProduct_ON_TAP');
              context.pushNamed(ProductMasterWidget.routeName);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTopOverviewSection({required bool isPhone}) {
    final stockParent = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef;

    return AuthUserStreamWidget(
      builder: (context) => FutureBuilder<List<StockRecord>>(
        future: queryStockRecordOnce(
          parent: stockParent,
          queryBuilder: (stockRecord) => stockRecord.where(
            'Quantity',
            isGreaterThan: 0,
          ),
        ),
        builder: (context, snapshot) {
          final stocks = snapshot.data ?? <StockRecord>[];
          final totalStockValue = stocks.fold<double>(
            0.0,
            (sum, stock) => sum + (stock.quantity * stock.price),
          );
          final activeStockItems = stocks.length;
          final nearExpiryItems = stocks.where((stock) {
            final expiry = stock.expiryDate;
            if (expiry == null) {
              return false;
            }
            final now = DateTime.now();
            final cutOff = now.add(const Duration(days: 30));
            return expiry.isAfter(now) && expiry.isBefore(cutOff);
          }).length;
          final lowStockItems = stocks.where((stock) {
            final threshold = stock.limitNotice > 0 ? stock.limitNotice : 5;
            return stock.quantity <= threshold;
          }).length;

          final cards = [
            _buildMetricCard(
              title: 'Total Stock Value',
              value: 'ZMK ${formatNumber(
                totalStockValue,
                formatType: FormatType.compact,
              )}',
              subtitle: '$activeStockItems products in inventory',
              icon: Icons.bar_chart_rounded,
              iconBackground: const Color(0xFFF3E8FF),
              iconColor: FlutterFlowTheme.of(context).primary,
              footer:
                  _buildMetricFooterBars(FlutterFlowTheme.of(context).primary),
              width: double.infinity,
            ),
            _buildMetricCard(
              title: 'Items Near Expiry',
              value: '$nearExpiryItems SKUs',
              subtitle: nearExpiryItems == 0
                  ? 'All items within range'
                  : 'Some items need review',
              icon: Icons.warning_amber_rounded,
              iconBackground: const Color(0xFFE8FAF1),
              iconColor: const Color(0xFF10B981),
              footer: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Next 30 Days',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
              ),
              width: double.infinity,
            ),
            _buildMetricCard(
              title: 'Active Stock Items',
              value: activeStockItems.toString(),
              subtitle: '$lowStockItems low stock alerts',
              icon: Icons.inventory_2_rounded,
              iconBackground: const Color(0xFFF1F1F1),
              iconColor: Colors.black,
              footer: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              width: double.infinity,
            ),
          ];

          if (isPhone) {
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  cards[i],
                  if (i != cards.length - 1) const SizedBox(height: 16),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 20),
              Expanded(child: cards[1]),
              const SizedBox(width: 20),
              Expanded(child: cards[2]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsOverviewSection({required bool isPhone}) {
    final stockParent = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Performance Analytics',
          Icons.analytics_rounded,
        ),
        const SizedBox(height: 16),
        if (isPhone)
          Column(
            children: [
              _buildAnalyticsOverviewCard(
                  isPhone: isPhone, stockParent: stockParent),
              const SizedBox(height: 20),
              _buildInventorySummaryCard(
                  isPhone: isPhone, stockParent: stockParent),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildAnalyticsOverviewCard(
                  isPhone: isPhone,
                  stockParent: stockParent,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: _buildInventorySummaryCard(
                  isPhone: isPhone,
                  stockParent: stockParent,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnalyticsOverviewCard({
    required bool isPhone,
    required DocumentReference? stockParent,
  }) {
    return _buildPremiumCard(
      child: AuthUserStreamWidget(
        builder: (context) => FutureBuilder<int>(
          future: querySalesRecordCount(
            parent: () {
              if (valueOrDefault(currentUserDocument?.role, '') == 'Owner') {
                return currentUserReference;
              }
              return currentUserDocument?.ownerRef;
            }(),
          ),
          builder: (context, salesSnapshot) {
            final salesCount = salesSnapshot.data ?? 0;

            return FutureBuilder<int>(
              future: queryStaffRecordCount(
                queryBuilder: (staffRecord) => staffRecord
                    .where(
                      'OwnerRef',
                      isEqualTo: currentUserReference,
                    )
                    .where(
                      'deleted',
                      isNotEqualTo: true,
                    ),
              ),
              builder: (context, staffSnapshot) {
                final staffCount = staffSnapshot.data ?? 0;

                return FutureBuilder<List<StockRecord>>(
                  future: queryStockRecordOnce(
                    parent: stockParent,
                    queryBuilder: (stockRecord) => stockRecord.where(
                      'Quantity',
                      isGreaterThan: 0,
                    ),
                  ),
                  builder: (context, stockSnapshot) {
                    final stockCount = stockSnapshot.data?.length ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: FlutterFlowTheme.of(context).secondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Sales Overview',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleMediumFamily,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleMediumIsCustom,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _buildStatRow(
                          dotColor: FlutterFlowTheme.of(context).primary,
                          label: 'Total Sales',
                          value: salesCount.toString(),
                        ),
                        _buildStatRow(
                          dotColor: Colors.black,
                          label: 'Inventory Items',
                          value: stockCount.toString(),
                        ),
                        _buildStatRow(
                          dotColor: FlutterFlowTheme.of(context).success,
                          label: 'Active Staff',
                          value: staffCount.toString(),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInventorySummaryCard({
    required bool isPhone,
    required DocumentReference? stockParent,
  }) {
    return _buildPremiumCard(
      child: AuthUserStreamWidget(
        builder: (context) => FutureBuilder<List<StockRecord>>(
          future: queryStockRecordOnce(
            parent: stockParent,
            queryBuilder: (stockRecord) => stockRecord.where(
              'Quantity',
              isGreaterThan: 0,
            ),
          ),
          builder: (context, snapshot) {
            final stocks = snapshot.data ?? <StockRecord>[];
            final stockCount = stocks.length;
            final lowStockCount = stocks.where((stock) {
              final threshold = stock.limitNotice > 0 ? stock.limitNotice : 5;
              return stock.quantity <= threshold;
            }).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Inventory Summary',
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleMediumIsCustom,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _buildStatRow(
                  dotColor: FlutterFlowTheme.of(context).primary,
                  label: 'Total SKUs',
                  value: stockCount.toString(),
                ),
                _buildStatRow(
                  dotColor: Colors.black,
                  label: 'In Stock',
                  value: stockCount.toString(),
                ),
                _buildStatRow(
                  dotColor: const Color(0xFFEF4444),
                  label: 'Low Stock Alerts',
                  value: lowStockCount.toString(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<_DuniyaFinanceOverviewData> _loadDuniyaFinanceOverview({
    required DocumentReference ownerRef,
  }) async {
    final pharmacyRecords = await queryPharmacyRecordOnce(
      parent: ownerRef,
      queryBuilder: (query) => query.where('deleted', isEqualTo: false),
    );

    final pharmacySnapshots = await Future.wait(
      pharmacyRecords.map((pharmacy) async {
        final financeRecords = pharmacy.userID == null
            ? <FinanceRecord>[]
            : await queryFinanceRecordOnce(
                parent: pharmacy.userID!,
                singleRecord: true,
              );
        final finance = financeRecords.firstOrNull;
        return _PharmacyFinanceSnapshot(
          pharmacy: pharmacy,
          revenue: finance?.revenue ?? 0.0,
          grossProfit: finance?.grossProfit ?? 0.0,
          netProfit: finance?.netProfit ?? 0.0,
          costOfGoods: finance?.costOfGoods ?? 0.0,
        );
      }),
    );

    final sortedSnapshots = [...pharmacySnapshots]
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return _DuniyaFinanceOverviewData(
      pharmacySnapshots: sortedSnapshots,
      totalRevenue: sortedSnapshots.fold<double>(
        0.0,
        (sum, snapshot) => sum + snapshot.revenue,
      ),
      totalGrossProfit: sortedSnapshots.fold<double>(
        0.0,
        (sum, snapshot) => sum + snapshot.grossProfit,
      ),
      totalNetProfit: sortedSnapshots.fold<double>(
        0.0,
        (sum, snapshot) => sum + snapshot.netProfit,
      ),
      totalCostOfGoods: sortedSnapshots.fold<double>(
        0.0,
        (sum, snapshot) => sum + snapshot.costOfGoods,
      ),
    );
  }

  Widget _buildFinanceNetworkSection({required bool isPhone}) {
    final ownerRef = currentUserReference!;

    return AuthUserStreamWidget(
      builder: (context) => FutureBuilder<_DuniyaFinanceOverviewData>(
        future: _loadDuniyaFinanceOverview(ownerRef: ownerRef),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildPremiumCard(
              child: SizedBox(
                height: 260,
                child: Center(
                  child: LoadingSpinnerWidget(
                    size: 42,
                    showLabel: false,
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data;
          if (data == null || data.pharmacySnapshots.isEmpty) {
            return _buildPremiumCard(
              child: Container(
                height: 220,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Network Finances',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleMediumFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleMediumIsCustom,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No pharmacy finance records are available yet.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          final heroCards = [
            _buildMetricCard(
              title: 'All Pharmacies Revenue',
              value: _formatCurrency(data.totalRevenue),
              subtitle:
                  '${data.pharmacySnapshots.length} pharmacies combined',
              icon: Icons.account_balance_wallet_rounded,
              iconBackground: const Color(0xFFF3E8FF),
              iconColor: FlutterFlowTheme.of(context).primary,
              footer: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      const Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              width: double.infinity,
            ),
            _buildMetricCard(
              title: 'Gross Profit',
              value: _formatCurrency(data.totalGrossProfit),
              subtitle: 'Network-wide gross performance',
              icon: Icons.trending_up_rounded,
              iconBackground: const Color(0xFFE8FAF1),
              iconColor: const Color(0xFF10B981),
              footer: Row(
                children: [
                  Icon(
                    Icons.stacked_line_chart_rounded,
                    color: FlutterFlowTheme.of(context).success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${data.totalMargin.toStringAsFixed(1)}% margin',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
              ),
              width: double.infinity,
            ),
            _buildMetricCard(
              title: 'Net Profit',
              value: _formatCurrency(data.totalNetProfit),
              subtitle: 'After operating costs',
              icon: Icons.savings_rounded,
              iconBackground: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4F46E5),
              footer: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              width: double.infinity,
            ),
            _buildMetricCard(
              title: 'Cost of Goods',
              value: _formatCurrency(data.totalCostOfGoods),
              subtitle: 'Inventory spend across the network',
              icon: Icons.receipt_long_rounded,
              iconBackground: const Color(0xFFFDE7E9),
              iconColor: const Color(0xFFEF4444),
              footer: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              width: double.infinity,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Network Finances',
                Icons.account_balance_rounded,
                actionLabel: 'Open Finance View',
                onAction: () async {
                  context.pushNamed(FinancesWidget.routeName);
                },
              ),
              const SizedBox(height: 16),
              _buildPremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FlutterFlowTheme.of(context)
                                .primary
                                .withValues(alpha: 0.98),
                            const Color(0xFF1D4ED8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.pie_chart_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All pharmacies in one view',
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily:
                                            FlutterFlowTheme.of(context)
                                                .titleMediumFamily,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleMediumIsCustom,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'A combined finance snapshot with pharmacy-level performance below.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily:
                                            FlutterFlowTheme.of(context)
                                                .bodySmallFamily,
                                        color: Colors.white.withValues(
                                            alpha: 0.88),
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              '${data.pharmacySnapshots.length} pharmacies',
                              style: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily:
                                        FlutterFlowTheme.of(context)
                                            .labelMediumFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .labelMediumIsCustom,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1200
                            ? 4
                            : constraints.maxWidth >= 760
                                ? 2
                                : 1;
                        return GridView.count(
                          crossAxisCount: columns,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: columns == 1 ? 2.4 : 1.1,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: heroCards,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                'Per Pharmacy',
                Icons.storefront_rounded,
                actionLabel: 'Open Full Finance View',
                onAction: () async {
                  context.pushNamed(FinancesWidget.routeName);
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1200
                      ? 2
                      : constraints.maxWidth >= 780
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 1.35 : 1.1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: data.pharmacySnapshots
                        .map(
                          (snapshot) => _buildPharmacyFinanceCard(
                            context,
                            snapshot: snapshot,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPharmacyFinanceCard(
    BuildContext context, {
    required _PharmacyFinanceSnapshot snapshot,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FlutterFlowTheme.of(context).primary.withValues(
                            alpha: 0.12,
                          ),
                      const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_pharmacy_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.pharmacy.name.isNotEmpty
                          ? snapshot.pharmacy.name
                          : 'Unnamed Pharmacy',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleMediumFamily,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleMediumIsCustom,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snapshot.pharmacy.address.isNotEmpty
                          ? snapshot.pharmacy.address
                          : 'Address not captured',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodySmallIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${snapshot.profitMargin.toStringAsFixed(1)}% margin',
                  style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).labelMediumFamily,
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).labelMediumIsCustom,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildFinancePill(
                context,
                label: 'Revenue',
                value: _formatCurrency(snapshot.revenue),
                tint: FlutterFlowTheme.of(context).primary,
              ),
              _buildFinancePill(
                context,
                label: 'Gross Profit',
                value: _formatCurrency(snapshot.grossProfit),
                tint: const Color(0xFF10B981),
              ),
              _buildFinancePill(
                context,
                label: 'Net Profit',
                value: _formatCurrency(snapshot.netProfit),
                tint: const Color(0xFF4F46E5),
              ),
              _buildFinancePill(
                context,
                label: 'Cost of Goods',
                value: _formatCurrency(snapshot.costOfGoods),
                tint: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancePill(
    BuildContext context, {
    required String label,
    required String value,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tint.withValues(alpha: 0.15)),
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
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).labelSmallIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: tint,
                  fontWeight: FontWeight.w800,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  // ─── Helper: Glass-panel KPI card ───────────────────────────────────
  Widget _buildGlassKpiCard({
    required IconData icon,
    required Color iconBgColor,
    required Widget? badge,
    required String value,
    required String label,
    required Color gradientColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: dartui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative blurred gradient circle (top-right)
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gradientColor.withValues(alpha: 0.3),
                          gradientColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconBgColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconBgColor,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        if (badge != null) badge,
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      value,
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).displaySmallFamily,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            lineHeight: 1.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .displaySmallIsCustom,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 13,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helper: Quick action card ──────────────────────────────────────
  Widget _buildQuickActionCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyLargeFamily,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyLargeIsCustom,
                            ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 6),
                        trailing,
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper: Premium card container ─────────────────────────────────
  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPhone = screenWidth <= 768;
    final renderLegacyDashboard =
        ModalRoute.of(context)?.settings.name == '__legacy_dashboard__';

    context.watch<FFAppState>();
    if (valueOrDefault(currentUserDocument?.role, '') != 'Owner') {
      return _buildPharmacyDashboard(isPhone: isPhone);
    }

    return Title(
      title: 'Home',
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
            child: WebViewAware(
              child: wrapWithModel(
                model: _model.sideNavModel2,
                updateCallback: () => safeSetState(() {}),
                child: SideNavWidget(),
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Column(
              children: [
                // ── Main body row ────────────────────────────────────
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // SideNav (desktop/tablet only)
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                        tablet: false,
                      ))
                        wrapWithModel(
                          model: _model.sideNavModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: SideNavWidget(),
                        ),
                      // Main content column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TopNav
                            Align(
                              alignment: const AlignmentDirectional(0, -1),
                              child: wrapWithModel(
                                model: _model.topNavModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TopNavWidget(
                                  openDrawer: () async {
                                    logFirebaseEvent(
                                        'HOME_PAGE_Container_1gnhj73v_CALLBACK');
                                    logFirebaseEvent('TopNav_drawer');
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                ),
                              ),
                            ),
                            // Scrollable content
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isPhone ? 16 : 24,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDashboardHeader(isPhone: isPhone),
                                    const SizedBox(height: 24),
                                    _buildTopOverviewSection(isPhone: isPhone),
                                    const SizedBox(height: 28),
                                    _buildAnalyticsOverviewSection(
                                        isPhone: isPhone),
                                    if (valueOrDefault(
                                            currentUserDocument?.accountType,
                                            'Duniya') ==
                                        'Duniya') ...[
                                      const SizedBox(height: 28),
                                      _buildFinanceNetworkSection(
                                          isPhone: isPhone),
                                    ],
                                    const SizedBox(height: 32),
                                    if (renderLegacyDashboard) ...[
                                      // ───────────────────────────────────
                                      // 1. PAGE HEADER
                                      // ───────────────────────────────────
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Command Center',
                                            style: FlutterFlowTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmallFamily,
                                                  fontSize: isPhone ? 26 : 34,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.5,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmallIsCustom,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (!isPhone)
                                            AutoSizeText(
                                              'Real-time overview of your pharmacy operations and performance metrics.',
                                              minFontSize: 8,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmallFamily,
                                                    fontSize: 14,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmallIsCustom,
                                                  ),
                                            ),
                                          const SizedBox(height: 16),
                                          // Time period selector
                                          Row(
                                            children: [
                                              _buildPeriodPill('Today', 0),
                                              const SizedBox(width: 8),
                                              _buildPeriodPill('7D', 1),
                                              const SizedBox(width: 8),
                                              _buildPeriodPill('30D', 2),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 28),

                                      // ───────────────────────────────────
                                      // 2. KEY METRICS ROW (3 glass cards)
                                      // ───────────────────────────────────
                                      isPhone
                                          ? Column(
                                              children: [
                                                // Sales Card
                                                AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<int>(
                                                    future:
                                                        querySalesRecordCount(
                                                      parent: () {
                                                        if (valueOrDefault(
                                                                currentUserDocument
                                                                    ?.role,
                                                                '') ==
                                                            'Owner') {
                                                          return currentUserReference;
                                                        } else if (valueOrDefault(
                                                                currentUserDocument
                                                                    ?.role,
                                                                '') !=
                                                            'Owner') {
                                                          return currentUserDocument
                                                              ?.ownerRef;
                                                        } else {
                                                          return currentUserDocument
                                                              ?.ownerRef;
                                                        }
                                                      }(),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return ShimmerLoadingCardWidget();
                                                      }
                                                      int containerCount =
                                                          snapshot.data!;
                                                      return _buildGlassKpiCard(
                                                        icon: Icons
                                                            .point_of_sale_rounded,
                                                        iconBgColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        badge: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 4),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                      0xFF10B981)
                                                                  .withValues(
                                                                      alpha:
                                                                          0.12),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .trending_up_rounded,
                                                                size: 14,
                                                                color: Color(
                                                                    0xFF10B981),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                '+12.5%',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: const Color(
                                                                          0xFF10B981),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          12,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        value: formatNumber(
                                                          containerCount,
                                                          formatType: FormatType
                                                              .decimal,
                                                          decimalType:
                                                              DecimalType
                                                                  .automatic,
                                                        ),
                                                        label:
                                                            'Total Sales Transactions',
                                                        gradientColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        onTap: () async {
                                                          logFirebaseEvent(
                                                              'HOME_PAGE_SalesCard_ON_TAP');
                                                          logFirebaseEvent(
                                                              'SalesCard_navigate_to');
                                                          context.pushNamed(
                                                              FinancesWidget
                                                                  .routeName);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Staff Card (Owner only)
                                                if (valueOrDefault(
                                                        currentUserDocument
                                                            ?.role,
                                                        '') ==
                                                    'Owner')
                                                  AuthUserStreamWidget(
                                                    builder: (context) =>
                                                        FutureBuilder<int>(
                                                      future:
                                                          queryStaffRecordCount(
                                                        queryBuilder:
                                                            (staffRecord) =>
                                                                staffRecord
                                                                    .where(
                                                                      'OwnerRef',
                                                                      isEqualTo:
                                                                          currentUserReference,
                                                                    )
                                                                    .where(
                                                                      'deleted',
                                                                      isNotEqualTo:
                                                                          true,
                                                                    ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return ShimmerLoadingCardWidget();
                                                        }
                                                        int containerCount =
                                                            snapshot.data!;
                                                        return _buildGlassKpiCard(
                                                          icon: Icons
                                                              .groups_rounded,
                                                          iconBgColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondary,
                                                          badge: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.12),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Text(
                                                              'ACTIVE: $containerCount',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodySmallFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        12,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodySmallIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                          value: containerCount
                                                              .toString(),
                                                          label:
                                                              'Total Staff Members',
                                                          gradientColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondary,
                                                          onTap: () async {
                                                            logFirebaseEvent(
                                                                'HOME_PAGE_StaffCard_ON_TAP');
                                                            logFirebaseEvent(
                                                                'StaffCard_navigate_to');
                                                            context.pushNamed(
                                                                HumanResourceUniWidget
                                                                    .routeName);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                if (valueOrDefault(
                                                        currentUserDocument
                                                            ?.role,
                                                        '') ==
                                                    'Owner')
                                                  const SizedBox(height: 16),
                                                // Inventory Card
                                                AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<int>(
                                                    future:
                                                        queryStockRecordCount(
                                                      parent: valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.role,
                                                                  '') ==
                                                              'Owner'
                                                          ? currentUserReference
                                                          : currentUserDocument
                                                              ?.ownerRef,
                                                      queryBuilder:
                                                          (stockRecord) =>
                                                              stockRecord.where(
                                                        'Quantity',
                                                        isGreaterThan: 0,
                                                      ),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return ShimmerLoadingCardWidget();
                                                      }
                                                      int containerCount =
                                                          snapshot.data!;
                                                      return _buildGlassKpiCard(
                                                        icon: Icons
                                                            .inventory_2_rounded,
                                                        iconBgColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        badge: AnimatedBuilder(
                                                          animation:
                                                              _pulseAnimation,
                                                          builder:
                                                              (context, child) {
                                                            return Transform
                                                                .scale(
                                                              scale:
                                                                  _pulseAnimation
                                                                      .value,
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                                decoration: BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error
                                                                        .withValues(
                                                                            alpha:
                                                                                0.12),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .warning_amber_rounded,
                                                                      size: 14,
                                                                      color: Color(
                                                                          0xFFEF4444),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
                                                                    Text(
                                                                      'LOW STOCK',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmall
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodySmallFamily,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).error,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            fontSize:
                                                                                11,
                                                                            letterSpacing:
                                                                                0.5,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        value: containerCount
                                                            .toString(),
                                                        label:
                                                            'Total Inventory SKUs',
                                                        gradientColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        onTap: () async {
                                                          logFirebaseEvent(
                                                              'HOME_PAGE_InventoryCard_ON_TAP');
                                                          logFirebaseEvent(
                                                              'InventoryCard_navigate_to');
                                                          context.pushNamed(
                                                              StoreInventoryWidget
                                                                  .routeName);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : IntrinsicHeight(
                                              child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                // Sales Card
                                                Expanded(
                                                  flex: 1,
                                                  child: AuthUserStreamWidget(
                                                    builder: (context) =>
                                                        FutureBuilder<int>(
                                                      future:
                                                          querySalesRecordCount(
                                                        parent: () {
                                                          if (valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.role,
                                                                  '') ==
                                                              'Owner') {
                                                            return currentUserReference;
                                                          } else if (valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.role,
                                                                  '') !=
                                                              'Owner') {
                                                            return currentUserDocument
                                                                ?.ownerRef;
                                                          } else {
                                                            return currentUserDocument
                                                                ?.ownerRef;
                                                          }
                                                        }(),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return ShimmerLoadingCardWidget();
                                                        }
                                                        int containerCount =
                                                            snapshot.data!;
                                                        return _buildGlassKpiCard(
                                                          icon: Icons
                                                              .point_of_sale_rounded,
                                                          iconBgColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          badge: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration: BoxDecoration(
                                                                color: const Color(
                                                                        0xFF10B981)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.12),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .trending_up_rounded,
                                                                  size: 14,
                                                                  color: Color(
                                                                      0xFF10B981),
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                Text(
                                                                  '+12.5%',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodySmallFamily,
                                                                        color: const Color(
                                                                            0xFF10B981),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontSize:
                                                                            12,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          value: formatNumber(
                                                            containerCount,
                                                            formatType:
                                                                FormatType
                                                                    .decimal,
                                                            decimalType:
                                                                DecimalType
                                                                    .automatic,
                                                          ),
                                                          label:
                                                              'Total Sales Transactions',
                                                          gradientColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          onTap: () async {
                                                            logFirebaseEvent(
                                                                'HOME_PAGE_SalesCard_ON_TAP');
                                                            logFirebaseEvent(
                                                                'SalesCard_navigate_to');
                                                            context.pushNamed(
                                                                FinancesWidget
                                                                    .routeName);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Staff Card (Owner only)
                                                if (valueOrDefault(
                                                        currentUserDocument
                                                            ?.role,
                                                        '') ==
                                                    'Owner')
                                                  Expanded(
                                                    flex: 1,
                                                    child: AuthUserStreamWidget(
                                                      builder: (context) =>
                                                          FutureBuilder<int>(
                                                        future:
                                                            queryStaffRecordCount(
                                                          queryBuilder:
                                                              (staffRecord) =>
                                                                  staffRecord
                                                                      .where(
                                                                        'OwnerRef',
                                                                        isEqualTo:
                                                                            currentUserReference,
                                                                      )
                                                                      .where(
                                                                        'deleted',
                                                                        isNotEqualTo:
                                                                            true,
                                                                      ),
                                                        ),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
                                                            return ShimmerLoadingCardWidget();
                                                          }
                                                          int containerCount =
                                                              snapshot.data!;
                                                          return _buildGlassKpiCard(
                                                            icon: Icons
                                                                .groups_rounded,
                                                            iconBgColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                            badge: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                              decoration: BoxDecoration(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary
                                                                      .withValues(
                                                                          alpha:
                                                                              0.12),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20)),
                                                              child: Text(
                                                                'ACTIVE: $containerCount',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          12,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                            value:
                                                                containerCount
                                                                    .toString(),
                                                            label:
                                                                'Total Staff Members',
                                                            gradientColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                            onTap: () async {
                                                              logFirebaseEvent(
                                                                  'HOME_PAGE_StaffCard_ON_TAP');
                                                              logFirebaseEvent(
                                                                  'StaffCard_navigate_to');
                                                              context.pushNamed(
                                                                  HumanResourceUniWidget
                                                                      .routeName);
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                if (valueOrDefault(
                                                        currentUserDocument
                                                            ?.role,
                                                        '') ==
                                                    'Owner')
                                                  const SizedBox(width: 16),
                                                // Inventory Card
                                                Expanded(
                                                  flex: 1,
                                                  child: AuthUserStreamWidget(
                                                    builder: (context) =>
                                                        FutureBuilder<int>(
                                                      future:
                                                          queryStockRecordCount(
                                                        parent: valueOrDefault(
                                                                    currentUserDocument
                                                                        ?.role,
                                                                    '') ==
                                                                'Owner'
                                                            ? currentUserReference
                                                            : currentUserDocument
                                                                ?.ownerRef,
                                                        queryBuilder:
                                                            (stockRecord) =>
                                                                stockRecord
                                                                    .where(
                                                          'Quantity',
                                                          isGreaterThan: 0,
                                                        ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return ShimmerLoadingCardWidget();
                                                        }
                                                        int containerCount =
                                                            snapshot.data!;
                                                        return _buildGlassKpiCard(
                                                          icon: Icons
                                                              .inventory_2_rounded,
                                                          iconBgColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          badge:
                                                              AnimatedBuilder(
                                                            animation:
                                                                _pulseAnimation,
                                                            builder: (context,
                                                                child) {
                                                              return Transform
                                                                  .scale(
                                                                scale:
                                                                    _pulseAnimation
                                                                        .value,
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4),
                                                                  decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error
                                                                          .withValues(
                                                                              alpha:
                                                                                  0.12),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20)),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .warning_amber_rounded,
                                                                        size:
                                                                            14,
                                                                        color: Color(
                                                                            0xFFEF4444),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              4),
                                                                      Text(
                                                                        'LOW STOCK',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 11,
                                                                              letterSpacing: 0.5,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          value: containerCount
                                                              .toString(),
                                                          label:
                                                              'Total Inventory SKUs',
                                                          gradientColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error,
                                                          onTap: () async {
                                                            logFirebaseEvent(
                                                                'HOME_PAGE_InventoryCard_ON_TAP');
                                                            logFirebaseEvent(
                                                                'InventoryCard_navigate_to');
                                                            context.pushNamed(
                                                                StoreInventoryWidget
                                                                    .routeName);
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      const SizedBox(height: 32),
                                    ],

                                    // ───────────────────────────────────
                                    // 3. TWO-COLUMN LAYOUT
                                    // ───────────────────────────────────
                                    isPhone
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildLeftColumn(),
                                              const SizedBox(height: 28),
                                              _buildRightColumn(context),
                                            ],
                                          )
                                        : Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left 2/3
                                              Expanded(
                                                flex: 2,
                                                child: _buildLeftColumn(),
                                              ),
                                              const SizedBox(width: 24),
                                              // Right 1/3
                                              Expanded(
                                                flex: 1,
                                                child:
                                                    _buildRightColumn(context),
                                              ),
                                            ],
                                          ),

                                    const SizedBox(height: 32),

                                    const SizedBox(height: 28),

                                    _buildSectionHeader(
                                      'Outlets Network',
                                      Icons.storefront_rounded,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildOutletsSection(),

                                    // Bottom padding for scroll
                                    const SizedBox(height: 100),
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
                // Mobile bottom navbar
                if (responsiveVisibility(
                  context: context,
                  tablet: false,
                  tabletLandscape: false,
                  desktop: false,
                ))
                  MobileNavbarWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyDashboard({required bool isPhone}) {
    final ownerRef = currentUserDocument?.ownerRef;
    final activePharmacy = FFAppState().Pharm.isNotEmpty
        ? FFAppState().Pharm
        : valueOrDefault(currentUserDocument?.pharmacyName, '').isNotEmpty
            ? valueOrDefault(currentUserDocument?.pharmacyName, '')
            : '';
    final pharmacyLabel =
        activePharmacy.isNotEmpty ? activePharmacy : 'Active Pharmacy';

    return Title(
      title: 'Pharmacy Dashboard',
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
            child: WebViewAware(
              child: wrapWithModel(
                model: _model.sideNavModel2,
                updateCallback: () => safeSetState(() {}),
                child: SideNavWidget(),
              ),
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
                    model: _model.sideNavModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: SideNavWidget(),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0, -1),
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
                        child: FutureBuilder<_PharmacyDashboardData>(
                          future: _loadPharmacyDashboardData(
                            activePharmacy: activePharmacy,
                            ownerRef: ownerRef,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: const LoadingSpinnerWidget(
                                  size: 42,
                                  showLabel: false,
                                ),
                              );
                            }

                            final data = snapshot.data!;
                            final lowStockCount = data.lowStockItems;
                            final soldItems = data.totalItemsSold;
                            final inventoryValue = data.inventoryValue;
                            final deliveries = data.goodsReceived.length;
                            final movementCount = data.movements.length;
                            final nearExpiry = data.nearExpiryItems;
                            final activeSkus = data.stockItems.length;

                            return SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                isPhone ? 16 : 24,
                                18,
                                isPhone ? 16 : 24,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(isPhone ? 22 : 28),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF6D28D9),
                                          FlutterFlowTheme.of(context).primary,
                                          const Color(0xFF1D4ED8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: FlutterFlowTheme.of(context)
                                              .primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 28,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    'Pharmacy Command Center',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          color: Colors.white,
                                                          fontSize:
                                                              isPhone ? 28 : 40,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing: -1.1,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    '$pharmacyLabel is tracking credit-delivered goods, sell-through, and inventory movement in real time.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha: 0.9),
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!isPhone) ...[
                                              const SizedBox(width: 16),
                                              _buildDashboardActionButton(
                                                label: 'Open POS',
                                                icon:
                                                    Icons.point_of_sale_rounded,
                                                fillColor: Colors.white,
                                                iconColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    PointOfSalesWidget
                                                        .routeName,
                                                  );
                                                },
                                                isPrimary: false,
                                              ),
                                              const SizedBox(width: 12),
                                              _buildDashboardActionButton(
                                                label: 'Inventory',
                                                icon: Icons.inventory_2_rounded,
                                                fillColor: Colors.black,
                                                iconColor: Colors.white,
                                                textColor: Colors.white,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    PharmacyInventoryWidget
                                                        .routeName,
                                                  );
                                                },
                                                isPrimary: true,
                                              ),
                                              if (valueOrDefault(
                                                      currentUserDocument?.role,
                                                      '') ==
                                                  'Owner')
                                                const SizedBox(width: 12),
                                              if (valueOrDefault(
                                                      currentUserDocument?.role,
                                                      '') ==
                                                  'Owner')
                                                _buildDashboardActionButton(
                                                  label: 'HR Portal',
                                                  icon: Icons.badge_rounded,
                                                  fillColor: Colors.white,
                                                  iconColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  textColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  onTap: () async {
                                                    context.goNamed(
                                                      HumanResourceUniWidget
                                                          .routeName,
                                                    );
                                                  },
                                                  isPrimary: false,
                                                ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _buildStatusChip(
                                              context,
                                              icon:
                                                  Icons.local_shipping_rounded,
                                              label:
                                                  '${deliveries} goods received',
                                            ),
                                            _buildStatusChip(
                                              context,
                                              icon: Icons.trending_up_rounded,
                                              label:
                                                  '$soldItems items sold across ${data.sales.length} transactions',
                                            ),
                                            _buildStatusChip(
                                              context,
                                              icon: Icons.warning_amber_rounded,
                                              label:
                                                  '$lowStockCount low stock alerts',
                                            ),
                                            _buildStatusChip(
                                              context,
                                              icon: Icons.event_busy_rounded,
                                              label:
                                                  '$nearExpiry near expiry SKUs',
                                            ),
                                            _buildStatusChip(
                                              context,
                                              icon: Icons.sync_alt_rounded,
                                              label:
                                                  '$movementCount stock movements tracked',
                                            ),
                                            if (isPhone &&
                                                valueOrDefault(
                                                        currentUserDocument?.role,
                                                        '') ==
                                                    'Owner')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6),
                                                child:
                                                    _buildDashboardActionButton(
                                                  label: 'HR Portal',
                                                  icon: Icons.badge_rounded,
                                                  fillColor: Colors.white,
                                                  iconColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  textColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  onTap: () async {
                                                    context.goNamed(
                                                      HumanResourceUniWidget
                                                          .routeName,
                                                    );
                                                  },
                                                  isPrimary: false,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide =
                                          constraints.maxWidth >= 1180;
                                      final heroCards = [
                                        _buildPharmacyMetricCard(
                                          context,
                                          title: 'Inventory Value',
                                          value:
                                              'ZMK ${formatNumber(inventoryValue, formatType: FormatType.compact)}',
                                          subtitle:
                                              '${activeSkus} active SKUs in the pharmacy',
                                          icon: Icons.inventory_2_rounded,
                                          accent: FlutterFlowTheme.of(context)
                                              .primary,
                                          tint: const Color(0xFFF1EAFE),
                                        ),
                                        _buildPharmacyMetricCard(
                                          context,
                                          title: 'Items Sold',
                                          value: soldItems.toString(),
                                          subtitle:
                                              'Sell-through captured from POS',
                                          icon: Icons.point_of_sale_rounded,
                                          accent: const Color(0xFF10B981),
                                          tint: const Color(0xFFE8FAF1),
                                        ),
                                        _buildPharmacyMetricCard(
                                          context,
                                          title: 'Goods Received',
                                          value: deliveries.toString(),
                                          subtitle:
                                              'Credit supply deliveries recorded',
                                          icon: Icons.local_shipping_rounded,
                                          accent: const Color(0xFFF59E0B),
                                          tint: const Color(0xFFFFF7E8),
                                        ),
                                        _buildPharmacyMetricCard(
                                          context,
                                          title: 'Low Stock Alerts',
                                          value: lowStockCount.toString(),
                                          subtitle:
                                              'Items approaching reorder levels',
                                          icon: Icons.warning_amber_rounded,
                                          accent: const Color(0xFFEF4444),
                                          tint: const Color(0xFFFFE8E8),
                                        ),
                                      ];

                                      final headerRow = isWide
                                          ? Row(
                                              children: [
                                                Expanded(child: heroCards[0]),
                                                const SizedBox(width: 16),
                                                Expanded(child: heroCards[1]),
                                                const SizedBox(width: 16),
                                                Expanded(child: heroCards[2]),
                                                const SizedBox(width: 16),
                                                Expanded(child: heroCards[3]),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                for (var i = 0;
                                                    i < heroCards.length;
                                                    i++) ...[
                                                  heroCards[i],
                                                  if (i != heroCards.length - 1)
                                                    const SizedBox(height: 12),
                                                ],
                                              ],
                                            );

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          headerRow,
                                          const SizedBox(height: 24),
                                          if (isWide)
                                            Row(
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
                                                      _buildPharmacySectionHeader(
                                                        context,
                                                        title:
                                                            'Inventory Health',
                                                        subtitle:
                                                            'What needs attention right now',
                                                        icon: Icons
                                                            .medication_rounded,
                                                      ),
                                                      const SizedBox(
                                                          height: 14),
                                                      _buildPharmacyPanel(
                                                        context,
                                                        child: Column(
                                                          children: data
                                                              .stockItems
                                                              .take(6)
                                                              .map(
                                                                (stock) =>
                                                                    Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    bottom: 12,
                                                                  ),
                                                                  child:
                                                                      _buildInventoryWatchRow(
                                                                    context,
                                                                    stock:
                                                                        stock,
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildPharmacySectionHeader(
                                                        context,
                                                        title: 'Movement Pulse',
                                                        subtitle:
                                                            'Sales, deliveries, and transfers',
                                                        icon: Icons
                                                            .moving_rounded,
                                                      ),
                                                      const SizedBox(
                                                          height: 14),
                                                      _buildPharmacyPanel(
                                                        context,
                                                        child: Column(
                                                          children: [
                                                            _buildMovementSummaryRow(
                                                              context,
                                                              label: 'Sales',
                                                              value:
                                                                  '${data.sales.length}',
                                                              accent: const Color(
                                                                  0xFF10B981),
                                                            ),
                                                            _buildMovementSummaryRow(
                                                              context,
                                                              label:
                                                                  'Goods received',
                                                              value:
                                                                  '$deliveries',
                                                              accent: const Color(
                                                                  0xFFF59E0B),
                                                            ),
                                                            _buildMovementSummaryRow(
                                                              context,
                                                              label:
                                                                  'Stock movements',
                                                              value:
                                                                  '$movementCount',
                                                              accent:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            const Divider(),
                                                            const SizedBox(
                                                                height: 12),
                                                            ...data.movements
                                                                .take(4)
                                                                .map(
                                                                  (movement) =>
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      bottom:
                                                                          10,
                                                                    ),
                                                                    child:
                                                                        _buildMovementListTile(
                                                                      context,
                                                                      movement:
                                                                          movement,
                                                                    ),
                                                                  ),
                                                                ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildPharmacySectionHeader(
                                                  context,
                                                  title: 'Inventory Health',
                                                  subtitle:
                                                      'What needs attention right now',
                                                  icon:
                                                      Icons.medication_rounded,
                                                ),
                                                const SizedBox(height: 14),
                                                _buildPharmacyPanel(
                                                  context,
                                                  child: Column(
                                                    children: data.stockItems
                                                        .take(6)
                                                        .map(
                                                          (stock) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              bottom: 12,
                                                            ),
                                                            child:
                                                                _buildInventoryWatchRow(
                                                              context,
                                                              stock: stock,
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                _buildPharmacySectionHeader(
                                                  context,
                                                  title: 'Movement Pulse',
                                                  subtitle:
                                                      'Sales, deliveries, and transfers',
                                                  icon: Icons.moving_rounded,
                                                ),
                                                const SizedBox(height: 14),
                                                _buildPharmacyPanel(
                                                  context,
                                                  child: Column(
                                                    children: [
                                                      _buildMovementSummaryRow(
                                                        context,
                                                        label: 'Sales',
                                                        value:
                                                            '${data.sales.length}',
                                                        accent: const Color(
                                                            0xFF10B981),
                                                      ),
                                                      _buildMovementSummaryRow(
                                                        context,
                                                        label: 'Goods received',
                                                        value: '$deliveries',
                                                        accent: const Color(
                                                            0xFFF59E0B),
                                                      ),
                                                      _buildMovementSummaryRow(
                                                        context,
                                                        label:
                                                            'Stock movements',
                                                        value: '$movementCount',
                                                        accent:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      const Divider(),
                                                      const SizedBox(
                                                          height: 12),
                                                      ...data.movements
                                                          .take(4)
                                                          .map(
                                                            (movement) =>
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 10,
                                                              ),
                                                              child:
                                                                  _buildMovementListTile(
                                                                context,
                                                                movement:
                                                                    movement,
                                                              ),
                                                            ),
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 22),
                                          _buildPharmacySectionHeader(
                                            context,
                                            title: 'Fast Actions',
                                            subtitle:
                                                'Move from insight to action in one tap',
                                            icon: Icons.flash_on_rounded,
                                          ),
                                          const SizedBox(height: 14),
                                          LayoutBuilder(
                                            builder:
                                                (context, actionConstraints) {
                                              final actionIsWide =
                                                  actionConstraints.maxWidth >=
                                                      980;
                                              final actionCards = [
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Point of Sale',
                                                  subtitle:
                                                      'Process transactions and record sell-through',
                                                  icon: Icons
                                                      .point_of_sale_rounded,
                                                  accent: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  onTap: () {
                                                    context.pushNamed(
                                                      PointOfSalesWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Pharmacy Inventory',
                                                  subtitle:
                                                      'Track stock, batches, expiry, and availability',
                                                  icon:
                                                      Icons.inventory_2_rounded,
                                                  accent:
                                                      const Color(0xFF10B981),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      PharmacyInventoryWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Goods Received',
                                                  subtitle:
                                                      'Review deliveries and reconcile supply',
                                                  icon: Icons
                                                      .local_shipping_rounded,
                                                  accent:
                                                      const Color(0xFFF59E0B),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      GoodsReceivedWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Batches & Expiry',
                                                  subtitle:
                                                      'Protect stock with expiry visibility',
                                                  icon: Icons
                                                      .event_available_rounded,
                                                  accent:
                                                      const Color(0xFF8B5CF6),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      BatchesWidget.routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Stock Movements',
                                                  subtitle:
                                                      'See stock-in, stock-out, and transfer flow',
                                                  icon: Icons.sync_alt_rounded,
                                                  accent:
                                                      const Color(0xFF0EA5E9),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      StockMovementsWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Low Stock Alerts',
                                                  subtitle:
                                                      'Jump directly to replenishment pressure',
                                                  icon: Icons
                                                      .warning_amber_rounded,
                                                  accent:
                                                      const Color(0xFFEF4444),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      LowStockAlertsWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                                _buildPharmacyActionCard(
                                                  context,
                                                  title: 'Replenishment',
                                                  subtitle:
                                                      'Plan supply before stock-out hits',
                                                  icon: Icons.restore_rounded,
                                                  accent:
                                                      const Color(0xFFF97316),
                                                  onTap: () {
                                                    context.pushNamed(
                                                      ReplenishmentWidget
                                                          .routeName,
                                                    );
                                                  },
                                                ),
                                              ];

                                              return Wrap(
                                                spacing: 14,
                                                runSpacing: 14,
                                                children: actionCards
                                                    .map(
                                                      (card) => SizedBox(
                                                        width: actionIsWide
                                                            ? (actionConstraints
                                                                        .maxWidth -
                                                                    42) /
                                                                2
                                                            : actionConstraints
                                                                .maxWidth,
                                                        child: card,
                                                      ),
                                                    )
                                                    .toList(),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 22),
                                          _buildPharmacySectionHeader(
                                            context,
                                            title: 'Supply Watchlist',
                                            subtitle:
                                                'SKUs approaching reorder or expiry pressure',
                                            icon: Icons.visibility_rounded,
                                          ),
                                          const SizedBox(height: 14),
                                          _buildPharmacyPanel(
                                            context,
                                            child: Column(
                                              children: data.stockItems
                                                  .where((stock) =>
                                                      stock.quantity <=
                                                          (stock.hasLimitNotice()
                                                              ? stock
                                                                  .limitNotice
                                                              : 5) ||
                                                      (stock.hasExpiryDate() &&
                                                          stock.expiryDate!
                                                              .isBefore(DateTime
                                                                      .now()
                                                                  .add(const Duration(
                                                                      days:
                                                                          30)))))
                                                  .take(5)
                                                  .map(
                                                    (stock) =>
                                                        _buildInventoryWatchRow(
                                                      context,
                                                      stock: stock,
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
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

  Widget _buildPharmacyPanel(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPharmacyMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).headlineSmallFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).headlineSmallIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacySectionHeader(
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
            borderRadius: BorderRadius.circular(12),
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
                      letterSpacing: -0.4,
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

  Widget _buildPharmacyActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontWeight: FontWeight.w700,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                  const SizedBox(height: 3),
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
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ),
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

  Widget _buildMovementListTile(
    BuildContext context, {
    required StockMovementRecord movement,
  }) {
    final isInbound = movement.movementType.toLowerCase().contains('in') ||
        movement.movementType.toLowerCase().contains('receive');
    final accent =
        isInbound ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final movementLabel =
        movement.movementType.isNotEmpty ? movement.movementType : 'Movement';
    final movementTime = movement.hasCreatedAt()
        ? dateTimeFormat(
            'MMM d, h:mm a',
            movement.createdAt!,
            locale: FFLocalizations.of(context).languageCode,
          )
        : 'Recently';

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isInbound ? Icons.call_received_rounded : Icons.call_made_rounded,
            color: accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movementLabel,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
              Text(
                movement.hasReason() && movement.reason!.isNotEmpty
                    ? movement.reason!
                    : movement.hasMovementReference() &&
                            movement.movementReference!.isNotEmpty
                        ? movement.movementReference!
                        : 'Recorded stock movement',
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
        const SizedBox(width: 12),
        Text(
          movementTime,
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: FlutterFlowTheme.of(context).secondaryText,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ],
    );
  }

  Widget _buildInventoryWatchRow(
    BuildContext context, {
    required StockRecord stock,
  }) {
    final lowThreshold =
        stock.hasLimitNotice() && stock.limitNotice > 0 ? stock.limitNotice : 5;
    final isLow = stock.quantity <= lowThreshold;
    final isNearExpiry = stock.hasExpiryDate() &&
        stock.expiryDate!
            .isBefore(DateTime.now().add(const Duration(days: 30)));
    final statusColor = isLow
        ? const Color(0xFFEF4444)
        : isNearExpiry
            ? const Color(0xFFF59E0B)
            : const Color(0xFF10B981);
    final statusLabel = isLow
        ? 'Low stock'
        : isNearExpiry
            ? 'Near expiry'
            : 'Healthy';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name.isNotEmpty ? stock.name : 'Untitled item',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock.batchNumber.isNotEmpty
                      ? 'Batch ${stock.batchNumber}'
                      : stock.manufacturer.isNotEmpty
                          ? stock.manufacturer
                          : 'Tracked through pharmacy inventory',
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
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stock.quantity}',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      fontWeight: FontWeight.w800,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).labelSmallFamily,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).labelSmallIsCustom,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<_PharmacyDashboardData> _loadPharmacyDashboardData({
    required String activePharmacy,
    required DocumentReference? ownerRef,
  }) async {
    final scope = ownerRef ?? currentUserReference;

    final pharmacyList = await queryPharmacyRecordOnce(
      parent: scope,
      queryBuilder: (query) => activePharmacy.isNotEmpty
          ? query.where('Name', isEqualTo: activePharmacy)
          : query,
      singleRecord: true,
    );
    final pharmacy = pharmacyList.firstOrNull;

    final stockItems = await queryStockRecordOnce(
      parent: scope,
      queryBuilder: (query) => activePharmacy.isNotEmpty
          ? query.where('Pharmacy', isEqualTo: activePharmacy)
          : query.where('Quantity', isGreaterThan: 0),
    );

    final salesRecords = await querySalesRecordOnce(
      parent: scope,
      queryBuilder: (query) => pharmacy != null
          ? query.where('PharmaID', isEqualTo: pharmacy.reference)
          : query,
    );

    final goodsReceived = await queryGoodsReceivedRecordOnce(
      parent: scope,
      queryBuilder: (query) =>
          query.orderBy('CreatedAt', descending: true).limit(6),
    );

    final movements = await queryStockMovementRecordOnce(
      parent: scope,
      queryBuilder: (query) =>
          query.orderBy('CreatedAt', descending: true).limit(6),
    );

    final lowStockAlertCount = await queryLowStockAlertRecordCount(
      queryBuilder: (query) => pharmacy != null
          ? query.where('PharmacyId', isEqualTo: pharmacy.reference)
          : query,
    );

    final inventoryValue = stockItems.fold<double>(
      0.0,
      (sum, stock) => sum + (stock.quantity * stock.price),
    );
    final totalItemsSold =
        salesRecords.fold<int>(0, (sum, sale) => sum + sale.numberOfItems);
    final nearExpiryItems = stockItems.where((stock) {
      return stock.hasExpiryDate() &&
          stock.expiryDate!.isAfter(DateTime.now()) &&
          stock.expiryDate!
              .isBefore(DateTime.now().add(const Duration(days: 30)));
    }).length;
    final lowStockItems = stockItems.where((stock) {
      final threshold = stock.hasLimitNotice() && stock.limitNotice > 0
          ? stock.limitNotice
          : 5;
      return stock.quantity <= threshold;
    }).length;

    return _PharmacyDashboardData(
      pharmacy: pharmacy,
      stockItems: stockItems,
      sales: salesRecords,
      goodsReceived: goodsReceived,
      movements: movements,
      lowStockAlertCount: lowStockAlertCount,
      inventoryValue: inventoryValue,
      totalItemsSold: totalItemsSold,
      nearExpiryItems: nearExpiryItems,
      lowStockItems: lowStockItems,
    );
  }

  // ─── LEFT COLUMN ─────────────────────────────────────────────────────
  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Performance Analytics section
        _buildSectionHeader(
          'Performance Analytics',
          Icons.analytics_rounded,
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header
              Row(
                children: [
                  Text(
                    'Sales Revenue Trend',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleMediumFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleMediumIsCustom,
                        ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      logFirebaseEvent('HOME_PAGE_ExportReport_ON_TAP');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        'Export Report',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<SalesRecord>>(
                future: querySalesRecordOnce(
                  parent:
                      valueOrDefault(currentUserDocument?.role, '') == 'Owner'
                          ? currentUserReference
                          : currentUserDocument?.ownerRef,
                  queryBuilder: (salesRecord) =>
                      salesRecord.orderBy('Date', descending: false).limit(12),
                ),
                builder: (context, snapshot) {
                  final sales = snapshot.data ?? <SalesRecord>[];
                  final trendPoints = sales
                      .where((sale) => sale.hasDate())
                      .toList()
                    ..sort((a, b) => a.date!.compareTo(b.date!));
                  final values = trendPoints
                      .map((sale) => sale.totalAmount)
                      .toList(growable: false);
                  final labels = trendPoints
                      .map((sale) => dateTimeFormat(
                            'd/M',
                            sale.date!,
                            locale: FFLocalizations.of(context).languageCode,
                          ))
                      .toList(growable: false);

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 248,
                      child: const Center(
                        child: LoadingSpinnerWidget(
                          size: 42,
                          showLabel: false,
                        ),
                      ),
                    );
                  }

                  if (values.isEmpty) {
                    return Container(
                      height: 248,
                      alignment: Alignment.center,
                      child: Text(
                        'No revenue data available yet',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 248,
                    child: CustomPaint(
                      painter: _RealLineChartPainter(
                        values: values,
                        labels: labels,
                        lineColor: FlutterFlowTheme.of(context).primary,
                        gradientTop: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.2),
                        gradientBottom: FlutterFlowTheme.of(context)
                            .primary
                            .withValues(alpha: 0.0),
                        labelColor: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Quick Actions section
        _buildSectionHeader(
          'Quick Actions',
          Icons.bolt_rounded,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {

            final cards = <Widget>[
              _buildQuickActionCard(
                icon: Icon(Icons.point_of_sale_rounded,
                    color: FlutterFlowTheme.of(context).primary, size: 22),
                title: 'Point of Sale',
                subtitle: 'Process transactions & billing',
                accentColor: FlutterFlowTheme.of(context).primary,
                onTap: () async {
                  logFirebaseEvent('HOME_PAGE_QuickAction_POS_ON_TAP');
                  var _shouldSetState = false;
                  if (valueOrDefault(currentUserDocument?.role, '') ==
                      'Owner') {
                    logFirebaseEvent('QuickAction_POS_navigate_to');
                    context.pushNamed(PointOfSalesWidget.routeName);
                    return;
                  } else {
                    logFirebaseEvent('QuickAction_POS_firestore_query');
                    _model.staff = await queryStaffRecordOnce(
                      queryBuilder: (staffRecord) => staffRecord.where(
                        'Email',
                        isEqualTo: currentUserEmail,
                      ),
                      singleRecord: true,
                    ).then((s) => s.firstOrNull);
                    _shouldSetState = true;
                    logFirebaseEvent('QuickAction_POS_backend_call');
                    _model.pharm = await PharmacyRecord.getDocumentOnce(
                        _model.staff!.pharmId!);
                    _shouldSetState = true;
                  }
                  logFirebaseEvent('QuickAction_POS_navigate_to');
                  context.pushNamed(
                    PointOfSalesWidget.routeName,
                    queryParameters: {
                      'pharm': serializeParam(
                        _model.pharm?.name,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                  if (_shouldSetState) safeSetState(() {});
                },
              ),
              _buildQuickActionCard(
                icon: FaIcon(FontAwesomeIcons.robot,
                    color: FlutterFlowTheme.of(context).primary, size: 22),
                title: 'AI Assistant',
                subtitle: 'Smart pharmacy insights',
                accentColor: FlutterFlowTheme.of(context).primary,
                trailing: AnimatedBuilder(
                  animation: _aiDotAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _aiDotAnimation.value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                onTap: () async {
                  logFirebaseEvent('HOME_PAGE_QuickAction_AI_ON_TAP');
                  logFirebaseEvent('QuickAction_AI_navigate_to');
                  context.goNamed(AiAssistantWidget.routeName);
                },
              ),
              _buildQuickActionCard(
                icon: Icon(Icons.calculate_rounded,
                    color: FlutterFlowTheme.of(context).warning, size: 22),
                title: 'Calculators',
                subtitle: 'BMI & health calculators',
                accentColor: FlutterFlowTheme.of(context).warning,
                onTap: () async {
                  logFirebaseEvent('HOME_PAGE_QuickAction_Calc_ON_TAP');
                  logFirebaseEvent('QuickAction_Calc_navigate_to');
                  context.goNamed(BMICalcWidget.routeName);
                },
              ),
            ];

            // Wrap in IntrinsicHeight so CrossAxisAlignment.stretch works
            // inside the unbounded vertical space of the scrollable Column.
            // Without this, the cards collapse and the section renders cut off.
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── RIGHT COLUMN ────────────────────────────────────────────────────
  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Inventory Mix',
          Icons.pie_chart_rounded,
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          child: Column(
            children: [
              FutureBuilder<List<StockRecord>>(
                future: queryStockRecordOnce(
                  parent:
                      valueOrDefault(currentUserDocument?.role, '') == 'Owner'
                          ? currentUserReference
                          : currentUserDocument?.ownerRef,
                  queryBuilder: (stockRecord) =>
                      stockRecord.where('Quantity', isGreaterThan: 0),
                ),
                builder: (context, snapshot) {
                  final stocks = snapshot.data ?? <StockRecord>[];
                  final healthy = stocks.where((stock) {
                    final threshold =
                        stock.hasLimitNotice() && stock.limitNotice > 0
                            ? stock.limitNotice
                            : 5;
                    return stock.quantity > threshold &&
                        (!stock.hasExpiryDate() ||
                            stock.expiryDate!.isAfter(
                              DateTime.now().add(const Duration(days: 30)),
                            ));
                  }).length;
                  final lowStock = stocks.where((stock) {
                    final threshold =
                        stock.hasLimitNotice() && stock.limitNotice > 0
                            ? stock.limitNotice
                            : 5;
                    return stock.quantity <= threshold;
                  }).length;
                  final nearExpiry = stocks.where((stock) {
                    return stock.hasExpiryDate() &&
                        stock.expiryDate!.isAfter(DateTime.now()) &&
                        stock.expiryDate!.isBefore(
                          DateTime.now().add(const Duration(days: 30)),
                        );
                  }).length;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 320,
                      child: const Center(
                        child: LoadingSpinnerWidget(
                          size: 42,
                          showLabel: false,
                        ),
                      ),
                    );
                  }

                  if (stocks.isEmpty) {
                    return SizedBox(
                      height: 320,
                      child: Center(
                        child: Text(
                          'No inventory data available yet',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(180, 180),
                              painter: _InventoryMixPainter(
                                healthyCount: healthy,
                                lowStockCount: lowStock,
                                nearExpiryCount: nearExpiry,
                                healthyColor: const Color(0xFF10B981),
                                lowStockColor: const Color(0xFFEF4444),
                                nearExpiryColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  stocks.length.toString(),
                                  style: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .headlineMediumFamily,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        lineHeight: 1.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .headlineMediumIsCustom,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total SKUs',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 12,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLegendItem(
                        'Healthy stock',
                        healthy.toString(),
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        'Low stock',
                        lowStock.toString(),
                        const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        'Near expiry',
                        nearExpiry.toString(),
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Legend item ──────────────────────────────────────────────────────
  Widget _buildLegendItem(String label, String percent, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  fontSize: 13,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
        Text(
          percent,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ],
    );
  }

  // ─── Outlets section ─────────────────────────────────────────────────
  Widget _buildOutletsSection() {
    return wrapWithModel(
      model: _model.pharmaTableModel,
      updateCallback: () => safeSetState(() {}),
      child: PharmaTableWidget(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: Revenue trend chart from real sales data
// ─────────────────────────────────────────────────────────────────────────────
class _RealLineChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color gradientTop;
  final Color gradientBottom;
  final Color labelColor;

  _RealLineChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.gradientTop,
    required this.gradientBottom,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'No revenue data available yet',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        textDirection: dartui.TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2),
      );
      return;
    }

    final chartPadding = const EdgeInsets.fromLTRB(52, 16, 20, 44);
    final chartWidth = math.max(
      size.width - chartPadding.left - chartPadding.right,
      1.0,
    );
    final chartHeight = math.max(
      size.height - chartPadding.top - chartPadding.bottom,
      1.0,
    );
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs();
    final normalized = values
        .map((value) => range > 0 ? (value - minVal) / range : 0.5)
        .toList();

    final points = <Offset>[];
    for (int i = 0; i < normalized.length; i++) {
      final x = chartPadding.left +
          (chartWidth *
              i /
              (normalized.length - 1).clamp(1, normalized.length));
      final y =
          chartPadding.top + chartHeight - (chartHeight * normalized[i] * 0.84);
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    final fillPath = Path()
      ..moveTo(points.first.dx, chartPadding.top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      fillPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    fillPath.lineTo(points.last.dx, chartPadding.top + chartHeight);
    fillPath.close();

    final rect = Rect.fromLTWH(
      chartPadding.left,
      chartPadding.top,
      chartWidth,
      chartHeight,
    );
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [gradientTop, gradientBottom],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(fillPath, paint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Draw dots on data points
    for (final p in points) {
      canvas.drawCircle(
        p,
        4,
        Paint()..color = lineColor,
      );
      canvas.drawCircle(
        p,
        2.5,
        Paint()..color = Colors.white,
      );
    }

    final labelStyle = const TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
    );
    final maxLabelCount = math.max(2, (chartWidth / 72).floor());
    final labelStep = math.max(1, (labels.length / maxLabelCount).ceil());
    for (int i = 0; i < labels.length; i++) {
      final isLast = i == labels.length - 1;
      if (i % labelStep != 0 && !isLast) {
        continue;
      }
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: labelStyle.copyWith(color: labelColor),
        ),
        textDirection: dartui.TextDirection.ltr,
      )..layout();
      final x = chartPadding.left +
          (chartWidth * i / (labels.length - 1).clamp(1, labels.length));
      final labelY = size.height - chartPadding.bottom + 8;
      if (labelY + textPainter.height > size.height) {
        continue;
      }
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          labelY,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RealLineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.labels != labels;
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: Inventory mix donut from real stock status data
// ─────────────────────────────────────────────────────────────────────────────
class _InventoryMixPainter extends CustomPainter {
  final int healthyCount;
  final int lowStockCount;
  final int nearExpiryCount;
  final Color healthyColor;
  final Color lowStockColor;
  final Color nearExpiryColor;

  _InventoryMixPainter({
    required this.healthyCount,
    required this.lowStockCount,
    required this.nearExpiryCount,
    required this.healthyColor,
    required this.lowStockColor,
    required this.nearExpiryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final innerRadius = outerRadius * 0.62;
    final total = healthyCount + lowStockCount + nearExpiryCount;
    if (total <= 0) {
      return;
    }

    double start = -math.pi / 2;

    void drawSegment(int count, Color color) {
      if (count <= 0) return;
      final sweep = count / total * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerRadius - innerRadius
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: (outerRadius + innerRadius) / 2),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep + 0.03;
    }

    drawSegment(healthyCount, healthyColor);
    drawSegment(lowStockCount, lowStockColor);
    drawSegment(nearExpiryCount, nearExpiryColor);
  }

  @override
  bool shouldRepaint(covariant _InventoryMixPainter oldDelegate) =>
      oldDelegate.healthyCount != healthyCount ||
      oldDelegate.lowStockCount != lowStockCount ||
      oldDelegate.nearExpiryCount != nearExpiryCount;
}
