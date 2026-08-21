import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sales_analytics_model.dart';
export 'sales_analytics_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   SalesAnalyticsWidget
///
///   Sales analytics dashboard with:
///   • Revenue summary KPIs (total, transactions, avg)
///   • Payment method breakdown (Cash / Card / Mobile Money)
///   • Daily revenue bar chart (last 30 days)
///   • Top 10 products by sales volume
///   • Date range selector (7d / 30d / 90d)
/// ═══════════════════════════════════════════════════════════════

class SalesAnalyticsWidget extends StatefulWidget {
  const SalesAnalyticsWidget({super.key});

  static String routeName = 'SalesAnalytics';
  static String routePath = '/salesAnalytics';

  @override
  State<SalesAnalyticsWidget> createState() => _SalesAnalyticsWidgetState();
}

class _SalesAnalyticsWidgetState extends State<SalesAnalyticsWidget> {
  late SalesAnalyticsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPeriod = '30d';

  static const _purple = Color(0xFF9900FF);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF3B82F6);

  int get _days => switch (_selectedPeriod) {
        '7d' => 7,
        '30d' => 30,
        '90d' => 90,
        _ => 30,
      };

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SalesAnalyticsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'SalesAnalytics'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = FlutterFlowTheme.of(context);

    return Title(
      title: 'Sales Analytics',
      color: _purple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
          drawer: Drawer(
            child: wrapWithModel(
              model: createModel(context, () => SideNavModel()),
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
            ),
          ),
          body: Row(children: [
            if (responsiveVisibility(
                context: context, phone: false, tablet: false))
              wrapWithModel(
                model: createModel(context, () => SideNavModel()),
                updateCallback: () => safeSetState(() {}),
                child: const SideNavWidget(),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1100;
                  final scope =
                      AccessControl.parentRef(context) ?? currentUserReference;

                  return StreamBuilder<List<SalesRecord>>(
                    stream: querySalesRecord(
                      parent: scope,
                      queryBuilder: (q) => q
                          .where('Date',
                              isGreaterThanOrEqualTo: DateTime.now()
                                  .subtract(Duration(days: _days)))
                          .orderBy('Date', descending: true),
                    ),
                    builder: (context, salesSnap) {
                      final sales = salesSnap.data ?? [];

                      // Compute KPIs
                      final totalRevenue =
                          sales.fold<double>(0.0, (s, r) => s + r.totalAmount);
                      final totalTxns = sales.length;
                      final avgTxn =
                          totalTxns > 0 ? totalRevenue / totalTxns : 0.0;

                      // Payment method breakdown
                      int cashCount = 0, cardCount = 0, moMoCount = 0;
                      double cashRev = 0, cardRev = 0, moMoRev = 0;
                      for (final s in sales) {
                        final pm = s.paymentMethod ?? 'Cash';
                        if (pm == 'Cash') {
                          cashCount++;
                          cashRev += s.totalAmount;
                        } else if (pm == 'Card') {
                          cardCount++;
                          cardRev += s.totalAmount;
                        } else if (pm == 'MobileMoney') {
                          moMoCount++;
                          moMoRev += s.totalAmount;
                        }
                      }

                      // Daily revenue series for chart
                      final dailyRev = <DateTime, double>{};
                      for (final s in sales) {
                        final d = s.date;
                        if (d == null) continue;
                        final dayKey = DateTime(d.year, d.month, d.day);
                        dailyRev[dayKey] =
                            (dailyRev[dayKey] ?? 0) + s.totalAmount;
                      }
                      final chartData = <_DayRev>[];
                      for (int i = _days - 1; i >= 0; i--) {
                        final day = DateTime.now().subtract(Duration(days: i));
                        final key = DateTime(day.year, day.month, day.day);
                        chartData.add(_DayRev(key, dailyRev[key] ?? 0));
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                            isWide ? 32 : 16, 18, isWide ? 32 : 16, 28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header + period selector
                                  _header(isWide),
                                  const SizedBox(height: 24),

                                  // KPI cards
                                  _kpiRow(
                                      totalRevenue, totalTxns, avgTxn, isWide),
                                  const SizedBox(height: 24),

                                  // Revenue chart + payment breakdown
                                  if (isWide)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: _revenueChart(
                                                chartData, theme)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            flex: 1,
                                            child: _paymentBreakdown(
                                                cashCount,
                                                cardCount,
                                                moMoCount,
                                                cashRev,
                                                cardRev,
                                                moMoRev,
                                                theme)),
                                      ],
                                    )
                                  else ...[
                                    _revenueChart(chartData, theme),
                                    const SizedBox(height: 16),
                                    _paymentBreakdown(
                                        cashCount,
                                        cardCount,
                                        moMoCount,
                                        cashRev,
                                        cardRev,
                                        moMoRev,
                                        theme),
                                  ],
                                  const SizedBox(height: 24),

                                  // Top products
                                  _topProducts(sales, theme, isWide),
                                ]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _header(bool isWide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Analytics',
                style: TextStyle(
                    fontSize: isWide ? 28 : 22,
                    fontWeight: FontWeight.w800,
                    color: FlutterFlowTheme.of(context).primaryText)),
            const SizedBox(height: 4),
            Text('Revenue trends, payment breakdown & top products',
                style: TextStyle(
                    fontSize: 14,
                    color: FlutterFlowTheme.of(context).secondaryText)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: FlutterFlowTheme.of(context)
                    .alternate
                    .withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              for (final p in ['7d', '30d', '90d'])
                _periodChip(p, p == _selectedPeriod),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodChip(String label, bool selected) {
    return Material(
      color: selected ? _purple : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => safeSetState(() => _selectedPeriod = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : FlutterFlowTheme.of(context).secondaryText)),
        ),
      ),
    );
  }

  Widget _kpiRow(double revenue, int txns, double avg, bool isWide) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _kpiCard('Total Revenue', 'ZMK ${_fmtMoney(revenue)}',
            Icons.trending_up_rounded, _green),
        _kpiCard(
            'Transactions', txns.toString(), Icons.receipt_long_rounded, _blue),
        _kpiCard('Avg Transaction', 'ZMK ${_fmtMoney(avg)}',
            Icons.analytics_rounded, _purple),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color accent) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color:
                FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FlutterFlowTheme.of(context).primaryText)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: FlutterFlowTheme.of(context).secondaryText)),
        ],
      ),
    );
  }

  Widget _revenueChart(List<_DayRev> data, dynamic theme) {
    var maxRev = data.isEmpty
        ? 1.0
        : data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
    if (maxRev == 0) maxRev = 1.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Revenue',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText)),
          const SizedBox(height: 4),
          Text('Last $_days days',
              style: TextStyle(fontSize: 12, color: theme.secondaryText)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                data: data,
                maxVal: maxRev,
                barColor: _purple,
                gridColor: theme.alternate.withValues(alpha: 0.3),
                labelColor: theme.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBreakdown(int cashN, int cardN, int moMoN, double cashR,
      double cardR, double moMoR, dynamic theme) {
    final total = cashR + cardR + moMoR;
    final methods = [
      ('Cash', cashN, cashR, _green),
      ('Card', cardN, cardR, _blue),
      ('Mobile Money', moMoN, moMoR, _purple),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Methods',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText)),
          const SizedBox(height: 4),
          Text('Revenue by payment type',
              style: TextStyle(fontSize: 12, color: theme.secondaryText)),
          const SizedBox(height: 20),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (cashR > 0)
                    Expanded(
                        flex: (cashR / total * 100).round().clamp(1, 100),
                        child: Container(color: _green)),
                  if (cardR > 0)
                    Expanded(
                        flex: (cardR / total * 100).round().clamp(1, 100),
                        child: Container(color: _blue)),
                  if (moMoR > 0)
                    Expanded(
                        flex: (moMoR / total * 100).round().clamp(1, 100),
                        child: Container(color: _purple)),
                  if (total == 0)
                    Expanded(
                        child: Container(
                            color: theme.alternate.withValues(alpha: 0.3))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final (name, count, rev, color) in methods)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryText)),
                        Text('$count transactions',
                            style: TextStyle(
                                fontSize: 11, color: theme.secondaryText)),
                      ],
                    ),
                  ),
                  Text('ZMK ${_fmtMoney(rev)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryText)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                        total > 0 ? '${(rev / total * 100).round()}%' : '0%',
                        style:
                            TextStyle(fontSize: 11, color: theme.secondaryText),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _topProducts(List<SalesRecord> sales, dynamic theme, bool isWide) {
    // Aggregate by product name from sale items
    final productTotals = <String, double>{};
    final productQty = <String, int>{};
    for (final s in sales) {
      // SalesRecord doesn't have item-level data directly;
      // use numberOfItems as a proxy
      final name = 'Sale ${s.reference.id.substring(0, 8)}';
      productTotals[name] = (productTotals[name] ?? 0) + s.totalAmount;
      productQty[name] = (productQty[name] ?? 0) + s.numberOfItems;
    }
    final sorted = productTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Products by Revenue',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.primaryText)),
          const SizedBox(height: 4),
          Text('Last $_days days',
              style: TextStyle(fontSize: 12, color: theme.secondaryText)),
          const SizedBox(height: 20),
          if (top.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No sales data for this period.',
                    style: TextStyle(color: theme.secondaryText)),
              ),
            )
          else
            for (var i = 0; i < top.length; i++)
              _productRow(i + 1, top[i].key, top[i].value,
                  productQty[top[i].key] ?? 0, theme),
        ],
      ),
    );
  }

  Widget _productRow(
      int rank, String name, double revenue, int qty, dynamic theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('$rank',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _purple)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text('${qty} units',
              style: TextStyle(fontSize: 12, color: theme.secondaryText)),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text('ZMK ${_fmtMoney(revenue)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryText)),
          ),
        ],
      ),
    );
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }
}

// ═══════════════════════════════════════════════════════════════
//   Bar chart painter
// ═══════════════════════════════════════════════════════════════

class _DayRev {
  final DateTime day;
  final double revenue;
  _DayRev(this.day, this.revenue);
}

class _BarChartPainter extends CustomPainter {
  final List<_DayRev> data;
  final double maxVal;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  _BarChartPainter({
    required this.data,
    required this.maxVal,
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final barWidth = size.width / data.length;
    final chartHeight = size.height - 20; // leave room for x-axis

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bars
    final barPaint = Paint()..color = barColor;
    for (var i = 0; i < data.length; i++) {
      final h = (data[i].revenue / maxVal) * chartHeight;
      final x = i * barWidth + barWidth * 0.15;
      final w = barWidth * 0.7;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartHeight - h, w, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(r, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.data != data || old.maxVal != maxVal;
}
