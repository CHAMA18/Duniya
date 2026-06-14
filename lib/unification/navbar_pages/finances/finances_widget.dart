import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'dart:ui' as dartui;
// ignore_for_file: unused_element
import 'finances_model.dart';
export 'finances_model.dart';

class FinancesWidget extends StatefulWidget {
  const FinancesWidget({super.key});

  static String routeName = 'Finances';
  static String routePath = '/finances';

  @override
  State<FinancesWidget> createState() => _FinancesWidgetState();
}

class _FinancesWidgetState extends State<FinancesWidget> {
  late FinancesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Purple-tinted finance tokens aligned with the app shell.
  static const Color _clinicalBlue = Color(0xFF8B5CF6);
  static const Color _primaryDeep = Color(0xFF6D28D9);
  static const Color _background = Color(0xFFF8F5FF);
  static const Color _surfaceContainerLow = Color(0xFFF4ECFF);
  static const Color _surfaceContainerHigh = Color(0xFFE7D8FF);
  static const Color _surfaceContainer = Color(0xFFF1E6FF);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF434656);
  static const Color _outline = Color(0xFF737688);
  static const Color _outlineVariant = Color(0xFFC3C5D9);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);

  // Chart time period state
  String _selectedPeriod = '1M';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FinancesModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Finances'});
    // On page load action — query sales for chart data
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('FINANCES_PAGE_Finances_ON_INIT_STATE');
      logFirebaseEvent('Finances_firestore_query');
      _model.sales = await querySalesRecordOnce(
        parent: currentUserReference,
        queryBuilder: (salesRecord) => salesRecord.orderBy('Date'),
      );
      logFirebaseEvent('Finances_update_app_state');
      FFAppState().LoopCounter = 0;
      if (_model.sales != null && _model.sales!.isNotEmpty) {
        while (FFAppState().LoopCounter < _model.sales!.length) {
          logFirebaseEvent('Finances_update_app_state');
          FFAppState().updateGraphDataStruct(
            (e) => e
              ..updateMonths(
                (e) => e.add(dateTimeFormat(
                  "d/M",
                  _model.sales!
                      .elementAtOrNull(FFAppState().LoopCounter)!
                      .date!,
                  locale: FFLocalizations.of(context).languageCode,
                )),
              )
              ..updateTotals(
                (e) => e.add(_model.sales!
                    .elementAtOrNull(FFAppState().LoopCounter)!
                    .totalAmount),
              ),
          );
          logFirebaseEvent('Finances_update_app_state');
          FFAppState().LoopCounter = FFAppState().LoopCounter + 1;
        }
      }
      logFirebaseEvent('Finances_update_app_state');
      FFAppState().LoopCounter = 0;
      safeSetState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Format a number as currency (e.g. $1.2M, $84.5K, $312)
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${value.toStringAsFixed(2)}';
    }
  }

  /// Builds a single KPI glass-card
  Widget _buildKPICard({
    required IconData icon,
    required String label,
    required String value,
    required String trendText,
    required bool isPositive,
    required bool isTrendError,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE9DCF9).withValues(alpha: 0.95),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon + Trend badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: _surfaceContainer,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(icon, color: _clinicalBlue, size: 20.0),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isTrendError
                        ? _errorContainer
                        : _surfaceContainerHigh.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(9999.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14.0,
                        color: isTrendError ? _errorColor : _clinicalBlue,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        trendText,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.01,
                          height: 1.0,
                          color: isTrendError ? _errorColor : _clinicalBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.08,
                height: 1.0,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.02,
                height: 1.2,
                color: _onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Revenue Analytics chart section
  Widget _buildRevenueChart(FinanceRecord? financeRecord) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.8), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Analytics',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.01,
                        height: 1.5,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Real-time revenue movement across sales and dispensing.',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: ['1W', '1M', '1Y'].map((period) {
                    final isSelected = _selectedPeriod == period;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: InkWell(
                        onTap: () =>
                            safeSetState(() => _selectedPeriod = period),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _clinicalBlue
                                : _surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: _clinicalBlue.withValues(
                                            alpha: 0.2),
                                        blurRadius: 4.0,
                                        offset: Offset(0, 2))
                                  ]
                                : null,
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.08,
                              color: isSelected ? Colors.white : _onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 22.0),
            SizedBox(
              height: 290.0,
              child: Container(
                decoration: BoxDecoration(
                  color: _surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: _outlineVariant.withValues(alpha: 0.22),
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: CustomPaint(
                    painter: _RevenueChartPainter(
                      graphData: FFAppState().GraphData,
                      primaryColor: _clinicalBlue,
                      gridColor: _outlineVariant.withValues(alpha: 0.08),
                      labelColor: _onSurfaceVariant,
                      backgroundColor: _surfaceContainerLow,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a status badge for a transaction
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0284C7);
        break;
      case 'pending':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFFA16207);
        break;
      case 'overdue':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        break;
      default:
        bgColor = _surfaceContainerHigh;
        textColor = _clinicalBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999.0),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Determine status for a sale based on its properties
  String _getSaleStatus(SalesRecord sale) {
    // Simple heuristic: older sales are completed, recent are pending
    if (sale.date != null) {
      final daysDiff = DateTime.now().difference(sale.date!).inDays;
      if (daysDiff > 7) return 'Completed';
      if (daysDiff > 2) return 'Pending';
      return 'Completed';
    }
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return AuthUserStreamWidget(
      builder: (context) => StreamBuilder<List<FinanceRecord>>(
        stream: queryFinanceRecord(
          parent: () {
            if (valueOrDefault(currentUserDocument?.role, '') == 'Owner') {
              return currentUserReference;
            } else {
              return currentUserDocument?.ownerRef;
            }
          }(),
          singleRecord: true,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: _background,
              body: Center(
                child: SpinKitRing(color: _clinicalBlue, size: 48.0),
              ),
            );
          }
          List<FinanceRecord> financesFinanceRecordList = snapshot.data!;
          final financesFinanceRecord = financesFinanceRecordList.isNotEmpty
              ? financesFinanceRecordList.first
              : null;

          // Compute financial metrics
          final revenue = financesFinanceRecord?.revenue ?? 0.0;
          final costOfGoods = financesFinanceRecord?.costOfGoods ?? 0.0;
          final grossProfit = financesFinanceRecord?.grossProfit ?? 0.0;
          final netProfit = financesFinanceRecord?.netProfit ?? 0.0;
          final profitMargin =
              revenue > 0 ? (grossProfit / revenue * 100) : 0.0;
          final operatingExpenses = costOfGoods > 0 ? costOfGoods : 0.0;
          // Accounts receivable = revenue - net profit (simplified)
          final accountsReceivable =
              revenue > 0 ? (revenue - netProfit).abs() : 0.0;

          return Title(
              title: 'Finances',
              color: _primaryDeep,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Scaffold(
                  key: scaffoldKey,
                  backgroundColor: _background,
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
                        // Sidebar (desktop/tablet only)
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
                        // Main content area
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top nav
                              wrapWithModel(
                                model: _model.topNavModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TopNavWidget(
                                  openDrawer: () async {
                                    logFirebaseEvent(
                                        'FINANCES_Container_9586l1za_CALLBACK');
                                    logFirebaseEvent('TopNav_drawer');
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                ),
                              ),
                              // Page content
                              Expanded(
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 24, 24, 28),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Finances',
                                                  style: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    fontSize: 30.0,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -0.02,
                                                    height: 1.2,
                                                    color: _onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  'Real-time revenue analytics and operational expenditure.',
                                                  style: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.6,
                                                    color: _onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16.0),
                                          // Action buttons
                                          Row(
                                            children: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  // Export report action
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  side: BorderSide(
                                                      color: _outlineVariant,
                                                      width: 1.0),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9999.0),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 12.0),
                                                ),
                                                child: Text(
                                                  'Export Report',
                                                  style: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.08,
                                                    color: _onSurface,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              ElevatedButton(
                                                onPressed: () {
                                                  context.pushNamed(
                                                      PointOfSalesWidget
                                                          .routeName);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      _clinicalBlue,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9999.0),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 12.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .point_of_sale_outlined,
                                                        size: 16.0),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      'Point of Sale',
                                                      style: TextStyle(
                                                        fontFamily: 'Satoshi',
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.08,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── KPI Grid (4 cards) ──
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          int cols = 4;
                                          if (constraints.maxWidth < 900) {
                                            cols = 2;
                                          }
                                          if (constraints.maxWidth < 500) {
                                            cols = 1;
                                          }
                                          return GridView.count(
                                            crossAxisCount: cols,
                                            crossAxisSpacing: 20.0,
                                            mainAxisSpacing: 20.0,
                                            childAspectRatio:
                                                cols == 1 ? 2.25 : 1.18,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            children: [
                                              // KPI 1: Total Revenue
                                              _buildKPICard(
                                                icon: Icons
                                                    .account_balance_wallet_outlined,
                                                label: 'Total Revenue',
                                                value: _formatCurrency(revenue),
                                                trendText: '+12.5%',
                                                isPositive: true,
                                                isTrendError: false,
                                              ),
                                              // KPI 2: Profit Margin
                                              _buildKPICard(
                                                icon: Icons.analytics_outlined,
                                                label: 'Profit Margin',
                                                value:
                                                    '${profitMargin.toStringAsFixed(1)}%',
                                                trendText: '+2.1%',
                                                isPositive: true,
                                                isTrendError: false,
                                              ),
                                              // KPI 3: Accounts Receivable
                                              _buildKPICard(
                                                icon:
                                                    Icons.receipt_long_outlined,
                                                label: 'Accounts Receivable',
                                                value: _formatCurrency(
                                                    accountsReceivable),
                                                trendText: '+5.2%',
                                                isPositive: true,
                                                isTrendError: true,
                                              ),
                                              // KPI 4: Operating Expenses
                                              _buildKPICard(
                                                icon: Icons.payments_outlined,
                                                label: 'Operating Expenses',
                                                value: _formatCurrency(
                                                    operatingExpenses),
                                                trendText: '-1.4%',
                                                isPositive: false,
                                                isTrendError: false,
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── Revenue Analytics Chart ──
                                      SizedBox(
                                        height: 350.0,
                                        child: _buildRevenueChart(
                                            financesFinanceRecord),
                                      ),

                                      const SizedBox(height: 24.0),

                                      // ── Recent Transactions Table ──
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.86),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          border: Border.all(
                                            color: const Color(0xFFE9DCF9)
                                                .withValues(alpha: 0.95),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.035),
                                              blurRadius: 18.0,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Table header
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      24.0, 20.0, 24.0, 20.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.5),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: _outlineVariant
                                                        .withValues(alpha: 0.3),
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Recent Transactions',
                                                    style: TextStyle(
                                                      fontFamily: 'Satoshi',
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: -0.01,
                                                      height: 1.5,
                                                      color: _onSurface,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {},
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'View All',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Satoshi',
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: 0.08,
                                                            color:
                                                                _clinicalBlue,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4.0),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_rounded,
                                                          size: 14.0,
                                                          color: _clinicalBlue,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Sales data table
                                            _buildSalesTable(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
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
              ));
        },
      ),
    );
  }

  /// Builds the Recent Transactions / Sales table
  Widget _buildSalesTable() {
    final userRole = valueOrDefault(currentUserDocument?.role, '');
    final parentRef = userRole == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef;

    return StreamBuilder<List<SalesRecord>>(
      stream: querySalesRecord(
        parent: parentRef,
        queryBuilder: (salesRecord) =>
            salesRecord.orderBy('Date', descending: true),
        limit: 10,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(child: SpinKitRing(color: _clinicalBlue, size: 32.0)),
          );
        }

        final sales = snapshot.data!;
        if (sales.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _surfaceContainerLow,
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        size: 28.0, color: _outline),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Sales will appear here once recorded',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 800
                ? MediaQuery.of(context).size.width - 400
                : 800.0,
            child: Column(
              children: [
                // Table header row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    border: Border(
                      bottom: BorderSide(
                        color: _outlineVariant.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _tableHeaderCell('Transaction ID', 1.2),
                      _tableHeaderCell('Date', 1.0),
                      _tableHeaderCell('Description', 1.8),
                      _tableHeaderCell('Amount', 1.0),
                      _tableHeaderCell('Status', 0.8),
                    ],
                  ),
                ),
                // Table rows
                ...sales.asMap().entries.map((entry) {
                  final sale = entry.value;
                  final status = _getSaleStatus(sale);
                  final isPositive = sale.totalAmount >= 0;

                  return InkWell(
                    onTap: () {
                      context.pushNamed(
                        SalesItemsWidget.routeName,
                        queryParameters: {
                          'sale': serializeParam(
                              sale.reference, ParamType.DocumentReference),
                        }.withoutNulls,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      height: 56.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _outlineVariant.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _tableDataCell(
                            '#TXN-${sale.reference.id.substring(0, 4).toUpperCase()}',
                            1.2,
                            fontWeight: FontWeight.w500,
                          ),
                          _tableDataCell(
                            sale.date != null
                                ? dateTimeFormat("MMM d, y", sale.date!,
                                    locale: FFLocalizations.of(context)
                                        .languageCode)
                                : '-',
                            1.0,
                            color: _onSurfaceVariant,
                          ),
                          _tableDataCell(
                            'Sale - ${sale.numberOfItems} item${sale.numberOfItems != 1 ? 's' : ''}',
                            1.8,
                          ),
                          _tableDataCell(
                            '${isPositive ? '+' : '-'}\$${sale.totalAmount.toStringAsFixed(2)}',
                            1.0,
                            fontWeight: FontWeight.w500,
                            color: isPositive ? _clinicalBlue : _onSurface,
                          ),
                          SizedBox(
                            width: 80.0,
                            child: _buildStatusBadge(status),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeaderCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.08,
          color: _onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _tableDataCell(String text, double flex,
      {FontWeight fontWeight = FontWeight.w400, Color? color}) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14.0,
          fontWeight: fontWeight,
          letterSpacing: -0.01,
          color: color ?? _onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Pending Approvals Section ──
  Widget _buildPendingApprovals() {
    return StreamBuilder<List<UserRecord>>(
      stream: queryUserRecord(
        queryBuilder: (userRecord) =>
            userRecord.where('approved_by_duniya', isEqualTo: false),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                  width: 1.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20.0,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Center(
                child: SpinKitRing(color: const Color(0xFF9900FF), size: 32.0)),
          );
        }

        final pendingUsers = snapshot.data!;
        final pendingPharmacies =
            pendingUsers.where((u) => u.accountType == 'Pharmacy').toList();
        final pendingDuniyaUsers = pendingUsers
            .where((u) => u.accountType == 'Duniya' || u.accountType.isEmpty)
            .toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20.0,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  border: Border(
                      bottom: BorderSide(
                          color: _outlineVariant.withValues(alpha: 0.3),
                          width: 1.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Icon(Icons.pending_actions,
                              size: 20.0, color: const Color(0xFF9900FF)),
                        ),
                        const SizedBox(width: 12.0),
                        Text('Pending Approvals',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.01,
                                height: 1.5,
                                color: _onSurface)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(9999.0)),
                          child: Text('${pendingPharmacies.length} Pharmacies',
                              style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9900FF))),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(9999.0)),
                          child: Text(
                              '${pendingDuniyaUsers.length} Duniya Users',
                              style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF854D0E))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (pendingUsers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 48.0,
                            color:
                                const Color(0xFF16A34A).withValues(alpha: 0.5)),
                        const SizedBox(height: 12.0),
                        Text('All accounts are approved',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                color: _onSurfaceVariant)),
                        const SizedBox(height: 4.0),
                        Text('No pending approvals at this time',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 13.0,
                                color:
                                    _onSurfaceVariant.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                )
              else
                ...pendingUsers.map((user) {
                  final isPharmacy = user.accountType == 'Pharmacy';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: _outlineVariant.withValues(alpha: 0.2),
                                width: 1.0))),
                    child: Row(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                              color: isPharmacy
                                  ? const Color(0xFFF3F0FF)
                                  : const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(12.0)),
                          child: Center(
                              child: Text(
                                  (user.displayName.isNotEmpty
                                          ? user.displayName
                                          : user.email)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: isPharmacy
                                          ? const Color(0xFF9900FF)
                                          : const Color(0xFF854D0E)))),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName
                                      : user.email,
                                  style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface)),
                              const SizedBox(height: 2.0),
                              Text(user.email,
                                  style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12.0,
                                      color: _onSurfaceVariant)),
                            ])),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                              color: isPharmacy
                                  ? const Color(0xFFF3F0FF)
                                  : const Color(0xFFFEF9C3),
                              borderRadius: BorderRadius.circular(9999.0)),
                          child: Text(isPharmacy ? 'Pharmacy' : 'Duniya',
                              style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: isPharmacy
                                      ? const Color(0xFF9900FF)
                                      : const Color(0xFF854D0E))),
                        ),
                        const SizedBox(width: 12.0),
                        ElevatedButton(
                          onPressed: () async {
                            await user.reference
                                .update({'approved_by_duniya': true});
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9900FF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9999.0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 6.0)),
                          child: Text('Approve',
                              style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for the revenue analytics line/area chart
class _RevenueChartPainter extends CustomPainter {
  final dynamic graphData; // FFAppState().graphData
  final Color primaryColor;
  final Color gridColor;
  final Color labelColor;
  final Color backgroundColor;

  _RevenueChartPainter({
    required this.graphData,
    required this.primaryColor,
    required this.gridColor,
    required this.labelColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartPadding = const EdgeInsets.fromLTRB(60, 20, 20, 40);
    final chartWidth = size.width - chartPadding.left - chartPadding.right;
    final chartHeight = size.height - chartPadding.top - chartPadding.bottom;

    List<double> dataPoints = [];
    List<String> labels = [];

    try {
      final months = graphData?.months?.toList() ?? [];
      final totals = graphData?.totals?.toList() ?? [];

      if (months.isNotEmpty &&
          totals.isNotEmpty &&
          months.length == totals.length) {
        for (int i = 0; i < totals.length && i < 12; i++) {
          dataPoints.add(totals[i].toDouble());
          labels.add(months[i]);
        }
      }
    } catch (e) {
      // Leave the chart empty if the backend has no usable data.
    }

    if (dataPoints.isEmpty) {
      final emptyStyle = TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: labelColor,
      );
      final textSpan = TextSpan(
        text: 'No revenue data available yet',
        style: emptyStyle,
      );
      final tp =
          TextPainter(text: textSpan, textDirection: dartui.TextDirection.ltr);
      tp.layout(maxWidth: chartWidth);
      tp.paint(
        canvas,
        Offset(
          chartPadding.left + (chartWidth - tp.width) / 2,
          chartPadding.top + (chartHeight - tp.height) / 2,
        ),
      );
      return;
    }

    // Normalize data
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final normalizedData =
        dataPoints.map((v) => range > 0 ? (v - minVal) / range : 0.5).toList();

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = chartPadding.top + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(chartPadding.left, y),
        Offset(size.width - chartPadding.right, y),
        gridPaint,
      );
    }

    // Draw Y-axis labels
    final labelStyle = TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
      color: labelColor,
    );
    for (int i = 0; i <= 4; i++) {
      final y = chartPadding.top + (chartHeight * i / 4);
      final val = maxVal - (range * i / 4);
      final textSpan = TextSpan(
        text: val >= 1000
            ? '${(val / 1000).toStringAsFixed(1)}K'
            : val.toStringAsFixed(0),
        style: labelStyle,
      );
      final tp =
          TextPainter(text: textSpan, textDirection: dartui.TextDirection.ltr);
      tp.layout();
      tp.paint(
          canvas, Offset(chartPadding.left - tp.width - 8, y - tp.height / 2));
    }

    // Draw X-axis labels
    final xLabelStyle = TextStyle(
      fontFamily: 'Satoshi',
      fontSize: 10.0,
      fontWeight: FontWeight.w500,
      color: labelColor,
    );
    for (int i = 0; i < labels.length; i++) {
      final x = chartPadding.left +
          (chartWidth * i / (labels.length - 1).clamp(1, labels.length));
      final textSpan = TextSpan(text: labels[i], style: xLabelStyle);
      final tp2 =
          TextPainter(text: textSpan, textDirection: dartui.TextDirection.ltr);
      tp2.layout();
      tp2.paint(canvas,
          Offset(x - tp2.width / 2, size.height - chartPadding.bottom + 10));
    }

    if (normalizedData.length < 2) return;

    // Build path points
    final points = <Offset>[];
    for (int i = 0; i < normalizedData.length; i++) {
      final x =
          chartPadding.left + (chartWidth * i / (normalizedData.length - 1));
      final y = chartPadding.top +
          chartHeight -
          (chartHeight * normalizedData[i] * 0.85);
      points.add(Offset(x, y));
    }

    // Draw area fill
    final areaPath = Path();
    areaPath.moveTo(points[0].dx, chartPadding.top + chartHeight);
    areaPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      areaPath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    areaPath.lineTo(points.last.dx, chartPadding.top + chartHeight);
    areaPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withValues(alpha: 0.15),
        primaryColor.withValues(alpha: 0.0)
      ],
    );
    final rect = Rect.fromLTWH(
        chartPadding.left, chartPadding.top, chartWidth, chartHeight);
    final areaPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Draw interactive marker on last data point
    if (points.isNotEmpty) {
      final lastPoint = points[points.length - 1];
      // Outer glow
      canvas.drawCircle(lastPoint, 12.0,
          Paint()..color = primaryColor.withValues(alpha: 0.1));
      // Inner dot
      canvas.drawCircle(lastPoint, 6.0, Paint()..color = primaryColor);

      // Tooltip
      final tooltipText =
          dataPoints.length > 0 ? _formatVal(dataPoints.last) : '';
      final tooltipSpan = TextSpan(
        text: tooltipText,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      );
      final tp3 = TextPainter(
          text: tooltipSpan, textDirection: dartui.TextDirection.ltr);
      tp3.layout();
      final tooltipW = tp3.width + 16.0;
      final tooltipH = tp3.height + 12.0;
      final tooltipX = lastPoint.dx - tooltipW / 2;
      final tooltipY = lastPoint.dy - tooltipH - 16.0;

      final tooltipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH),
        Radius.circular(6.0),
      );
      canvas.drawRRect(tooltipRect, Paint()..color = const Color(0xFF213145));
      tp3.paint(canvas, Offset(tooltipX + 8.0, tooltipY + 6.0));
    }
  }

  String _formatVal(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(1)}K';
    return '\$${v.toStringAsFixed(2)}';
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) => true;
}
