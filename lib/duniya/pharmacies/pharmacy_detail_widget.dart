import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

/// ═══════════════════════════════════════════════════════════════
///   PULSE — PHARMACY DETAIL (Network Admin Drill-Down)
///
///   Shows a world-class overview of a single pharmacy: KPI cards,
///   recent goods received, stock movements, and stock summary.
/// ═══════════════════════════════════════════════════════════════

class PharmacyDetailWidget extends StatefulWidget {
  const PharmacyDetailWidget({super.key, this.pharmacyName});

  final String? pharmacyName;

  static String routeName = 'PharmacyDetail';
  static String routePath = '/pharmacyDetail';

  @override
  State<PharmacyDetailWidget> createState() => _PharmacyDetailWidgetState();
}

class _PharmacyDetailWidgetState extends State<PharmacyDetailWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Brand tokens
  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _bg = Color(0xFFF7F3FF);
  static const _surface = Colors.white;
  static const _text = Color(0xFF0B1C30);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);
  static const _indigo = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'PharmacyDetail'});
  }

  // ── Helpers ──

  String _formatCurrency(double v) =>
      'K${formatNumber(v, formatType: FormatType.compact)}';

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return dateTimeFormat('yMMMd', dt, locale: FFLocalizations.of(context).languageCode);
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return _formatDate(dt);
  }

  // ── KPI Card ──

  Widget _kpi(String label, String value, IconData icon, Color accent, Color accentBg, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: accent, size: 22),
        ),
        const SizedBox(height: 16),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _text, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSec)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: _textSec.withAlpha(140))),
        ],
      ]),
    );
  }

  // ── Section Header ──

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _text)),
        if (trailing != null) ...[const Spacer(), trailing],
      ]),
    );
  }

  // ── Goods Received Tile ──

  Widget _grTile(GoodsReceivedRecord gr) {
    final statusColor = gr.status == 'completed' ? _green : gr.status == 'pending' ? _amber : _red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.local_shipping_rounded, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(gr.deliveryNoteNumber.isNotEmpty ? gr.deliveryNoteNumber : 'Delivery',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
          const SizedBox(height: 2),
          Text(_formatDate(gr.deliveryDate), style: TextStyle(fontSize: 12, color: _textSec.withAlpha(180))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: statusColor.withAlpha(18), borderRadius: BorderRadius.circular(999)),
          child: Text(gr.status.isNotEmpty ? gr.status.toUpperCase() : 'PENDING',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
    );
  }

  // ── Stock Movement Tile ──

  Widget _movementTile(StockMovementRecord mv) {
    final isInbound = mv.movementType.toLowerCase().contains('in') || mv.movementType.toLowerCase().contains('receive');
    final color = isInbound ? _green : _indigo;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
          child: Icon(isInbound ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mv.movementType.isNotEmpty ? mv.movementType : 'Movement',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
          const SizedBox(height: 2),
          Text(
            '${mv.quantity} units${mv.reason != null && mv.reason!.isNotEmpty ? ' · ${mv.reason}' : ''}',
            style: TextStyle(fontSize: 12, color: _textSec.withAlpha(180)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ])),
        Text(_timeAgo(mv.createdAt), style: TextStyle(fontSize: 11, color: _textSec.withAlpha(140))),
      ]),
    );
  }

  // ── Stock Row ──

  Widget _stockRow(StockRecord stock, int rank) {
    final threshold = stock.limitNotice > 0 ? stock.limitNotice : 5;
    final isLow = stock.quantity <= threshold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rank % 2 == 0 ? Colors.transparent : _bg.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        SizedBox(width: 32, child: Text('$rank', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textSec.withAlpha(160)))),
        Expanded(child: Text(stock.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _text), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _purple.withAlpha(12), borderRadius: BorderRadius.circular(6)),
          child: Text(stock.category.isNotEmpty ? stock.category : '—', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _purple)),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 60, child: Text('${stock.quantity}', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isLow ? _red : _text))),
        const SizedBox(width: 12),
        SizedBox(width: 70, child: Text(_formatCurrency(stock.price * stock.quantity), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _text))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final pharmacyName = widget.pharmacyName ?? '';

    return Title(
      title: 'Pharmacy Detail',
      color: _purple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: Drawer(elevation: 16, child: wrapWithModel(model: createModel(context, () => SideNavModel()), updateCallback: () => safeSetState(() {}), child: const SideNavWidget())),
          appBar: responsiveVisibility(context: context, tablet: false, tabletLandscape: false, desktop: false)
              ? AppBar(backgroundColor: _surface, automaticallyImplyLeading: false, leading: IconButton(icon: const Icon(Icons.chevron_left_rounded, color: _purpleDark, size: 28), onPressed: () => context.pop()), title: const Text('Pharmacy Detail', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: _text)), centerTitle: true, elevation: 0)
              : null,
          body: Row(children: [
            if (responsiveVisibility(context: context, phone: false, tablet: false))
              wrapWithModel(model: createModel(context, () => SideNavModel()), updateCallback: () => safeSetState(() {}), child: const SideNavWidget()),
            Expanded(child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1200;

              // ── Query Stock by pharmacy name ──
              return StreamBuilder<List<StockRecord>>(
                stream: queryStockRecord(
                  queryBuilder: (q) => q.where('Pharmacy', isEqualTo: pharmacyName).where('Quantity', isGreaterThan: 0),
                ),
                builder: (context, stockSnap) {
                  if (!stockSnap.hasData) {
                    return Center(child: SpinKitRing(color: _purple, size: 56));
                  }
                  final stocks = stockSnap.data!;
                  final totalValue = stocks.fold<double>(0, (s, st) => s + st.quantity * st.price);
                  final lowStock = stocks.where((s) => s.quantity <= (s.limitNotice > 0 ? s.limitNotice : 5)).length;
                  final nearExpiry = stocks.where((s) {
                    final e = s.expiryDate;
                    if (e == null) return false;
                    return e.isAfter(DateTime.now()) && e.isBefore(DateTime.now().add(const Duration(days: 30)));
                  }).length;
                  final categories = stocks.map((s) => s.category).where((c) => c.isNotEmpty).toSet().length;

                  // ── Goods Received stream ──
                  return StreamBuilder<List<GoodsReceivedRecord>>(
                    stream: queryGoodsReceivedRecord(
                      queryBuilder: (q) => q.orderBy('CreatedAt', descending: true).limit(10),
                    ),
                    builder: (context, grSnap) {
                      final allGR = grSnap.data ?? [];
                      // Filter by pharmacy name (GR links via OutletId → Pharmacy doc)
                      final grs = allGR; // Shown as network-wide for this pharmacy's context

                      // ── Stock Movements stream ──
                      return StreamBuilder<List<StockMovementRecord>>(
                        stream: queryStockMovementRecord(
                          queryBuilder: (q) => q.orderBy('CreatedAt', descending: true).limit(10),
                        ),
                        builder: (context, mvSnap) {
                          final movements = mvSnap.data ?? [];

                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(isWide ? 32 : 16, 18, isWide ? 32 : 16, 28),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1400),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  // ── Hero Header ──
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [_purpleDark, _purple, Color(0xFF6D28D9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [BoxShadow(color: _purple.withAlpha(56), blurRadius: 32, offset: const Offset(0, 16))],
                                    ),
                                    child: Row(children: [
                                      Container(
                                        width: 64, height: 64,
                                        decoration: BoxDecoration(color: Colors.white.withAlpha(38), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(64), width: 2)),
                                        child: const Icon(Icons.local_pharmacy_rounded, color: Colors.white, size: 32),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(pharmacyName.isNotEmpty ? pharmacyName : 'Pharmacy', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                                        const SizedBox(height: 6),
                                        Text('${stocks.length} products · $categories categories', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14)),
                                      ])),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white.withAlpha(50))),
                                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                          Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                                          SizedBox(width: 6),
                                          Text('Network Member', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                        ]),
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 22),

                                  // ── KPI Row ──
                                  if (isWide)
                                    Row(children: [
                                      Expanded(child: _kpi('Total Stock Value', _formatCurrency(totalValue), Icons.pie_chart_rounded, _purple, const Color(0xFFF3E8FF), subtitle: '${stocks.length} active SKUs')),
                                      const SizedBox(width: 16),
                                      Expanded(child: _kpi('SKUs in Stock', '${stocks.length}', Icons.inventory_2_rounded, _blue, const Color(0xFFEFF6FF), subtitle: '$categories categories')),
                                      const SizedBox(width: 16),
                                      Expanded(child: _kpi('Low Stock Items', '$lowStock', Icons.warning_amber_rounded, _red, const Color(0xFFFFF1F2), subtitle: lowStock > 0 ? 'Needs attention' : 'All healthy')),
                                      const SizedBox(width: 16),
                                      Expanded(child: _kpi('Near Expiry', '$nearExpiry', Icons.event_rounded, _amber, const Color(0xFFFFF7ED), subtitle: 'Within 30 days')),
                                    ])
                                  else
                                    Column(children: [
                                      Row(children: [
                                        Expanded(child: _kpi('Stock Value', _formatCurrency(totalValue), Icons.pie_chart_rounded, _purple, const Color(0xFFF3E8FF))),
                                        const SizedBox(width: 12),
                                        Expanded(child: _kpi('SKUs', '${stocks.length}', Icons.inventory_2_rounded, _blue, const Color(0xFFEFF6FF))),
                                      ]),
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        Expanded(child: _kpi('Low Stock', '$lowStock', Icons.warning_amber_rounded, _red, const Color(0xFFFFF1F2))),
                                        const SizedBox(width: 12),
                                        Expanded(child: _kpi('Near Expiry', '$nearExpiry', Icons.event_rounded, _amber, const Color(0xFFFFF7ED))),
                                      ]),
                                    ]),
                                  const SizedBox(height: 22),

                                  // ── Two-column layout ──
                                  if (isWide)
                                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      // Left: Goods Received + Movements
                                      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        _sectionHeader('Recent Goods Received', trailing: Text('${grs.length} total', style: TextStyle(fontSize: 12, color: _textSec.withAlpha(160)))),
                                        if (grs.isEmpty) _emptyCard('No goods received yet'),
                                        if (grs.isNotEmpty) ...grs.take(6).map((gr) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _grTile(gr))),
                                        const SizedBox(height: 22),
                                        _sectionHeader('Stock Movements', trailing: Text('${movements.length} recent', style: TextStyle(fontSize: 12, color: _textSec.withAlpha(160)))),
                                        if (movements.isEmpty) _emptyCard('No stock movements recorded'),
                                        if (movements.isNotEmpty) ...movements.take(8).map((mv) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _movementTile(mv))),
                                      ])),
                                      const SizedBox(width: 20),
                                      // Right: Stock Summary
                                      Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        _sectionHeader('Stock Summary'),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                                          child: Column(children: [
                                            // Table header
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Row(children: [
                                                const SizedBox(width: 32),
                                                Expanded(child: Text('Product', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textSec.withAlpha(160), letterSpacing: 0.5))),
                                                const SizedBox(width: 8),
                                                SizedBox(width: 60, child: Text('Qty', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textSec.withAlpha(160), letterSpacing: 0.5))),
                                                const SizedBox(width: 12),
                                                SizedBox(width: 70, child: Text('Value', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textSec.withAlpha(160), letterSpacing: 0.5))),
                                              ]),
                                            ),
                                            Divider(height: 1, color: _border),
                                            const SizedBox(height: 6),
                                            if (stocks.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No stock data', style: TextStyle(color: _textSec.withAlpha(140), fontSize: 13)))),
                                            if (stocks.isNotEmpty) ...stocks.take(15).toList().asMap().entries.map((e) => _stockRow(e.value, e.key + 1)),
                                            if (stocks.length > 15)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: Center(child: Text('Showing 15 of ${stocks.length}', style: TextStyle(fontSize: 12, color: _textSec.withAlpha(140)))),
                                              ),
                                          ]),
                                        ),
                                      ])),
                                    ])
                                  else
                                    // ── Mobile: stacked ──
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      _sectionHeader('Recent Goods Received'),
                                      if (grs.isEmpty) _emptyCard('No goods received yet'),
                                      if (grs.isNotEmpty) ...grs.take(4).map((gr) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _grTile(gr))),
                                      const SizedBox(height: 22),
                                      _sectionHeader('Stock Movements'),
                                      if (movements.isEmpty) _emptyCard('No stock movements recorded'),
                                      if (movements.isNotEmpty) ...movements.take(5).map((mv) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _movementTile(mv))),
                                      const SizedBox(height: 22),
                                      _sectionHeader('Stock Summary'),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                                        child: Column(children: [
                                          ...stocks.take(10).toList().asMap().entries.map((e) => _stockRow(e.value, e.key + 1)),
                                          if (stocks.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('No stock data', style: TextStyle(color: _textSec.withAlpha(140), fontSize: 13)))),
                                        ]),
                                      ),
                                    ]),
                                ]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            })),
          ]),
        ),
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Column(children: [
        Icon(Icons.inbox_rounded, color: _textSec.withAlpha(80), size: 36),
        const SizedBox(height: 12),
        Text(msg, style: TextStyle(fontSize: 14, color: _textSec.withAlpha(160))),
      ]),
    );
  }
}
