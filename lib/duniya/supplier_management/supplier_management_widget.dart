import '/rbac/rbac.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ═══════════════════════════════════════════════════════════════
///   PULSE — SUPPLIER MANAGEMENT
///
///   Network-wide supplier directory. Lists all suppliers across
///   every pharmacy on the Pulse network with search and stats.
/// ═══════════════════════════════════════════════════════════════

class SupplierManagementWidget extends StatefulWidget {
  const SupplierManagementWidget({super.key});

  static String routeName = 'SupplierManagement';
  static String routePath = '/supplierManagement';

  @override
  State<SupplierManagementWidget> createState() =>
      _SupplierManagementWidgetState();
}

class _SupplierManagementWidgetState extends State<SupplierManagementWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _bg = Color(0xFFF7F3FF);
  static const _surface = Colors.white;
  static const _text = Color(0xFF0B1C30);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF3B82F6);
  static const _amber = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'SupplierManagement'});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AccessControl.isDuniyaUser(context)) {
        context.goNamed(HomeWidget.routeName);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Supplier Management',
      color: _purple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: Drawer(
            elevation: 16,
            child: wrapWithModel(
              model: createModel(context, () => SideNavModel()),
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
            ),
          ),
          appBar: responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false,
          )
              ? AppBar(
                  backgroundColor: _surface,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: _purpleDark, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text('Supplier Management',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _text)),
                  centerTitle: true,
                  elevation: 0,
                )
              : null,
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
                  final isWide = constraints.maxWidth >= 1200;

                  // Query all pharmacies to extract supplier data from stock
                  return StreamBuilder<List<PharmacyRecord>>(
                    stream: queryPharmacyRecord(
                      queryBuilder: (q) =>
                          q.where('NetworkStatus', isEqualTo: 'active'),
                    ),
                    builder: (context, pharmacySnap) {
                      final pharmacies = pharmacySnap.data ?? [];

                      return StreamBuilder<List<StockRecord>>(
                        stream: queryStockRecord(
                          queryBuilder: (q) =>
                              q.where('Quantity', isGreaterThan: 0),
                        ),
                        builder: (context, stockSnap) {
                          final stocks = stockSnap.data ?? [];

                          // Extract unique suppliers from stock manufacturers
                          final supplierMap = <String, _SupplierInfo>{};
                          for (final stock in stocks) {
                            final name = stock.manufacturer.isNotEmpty
                                ? stock.manufacturer
                                : 'Unknown Supplier';
                            if (!supplierMap.containsKey(name)) {
                              supplierMap[name] = _SupplierInfo(
                                name: name,
                                pharmacyCount: 0,
                                productCount: 0,
                                totalValue: 0,
                                categories: <String>{},
                              );
                            }
                            final info = supplierMap[name]!;
                            info.productCount++;
                            info.totalValue += stock.price * stock.quantity;
                            info.categories.add(stock.category);
                          }

                          // Count pharmacies per supplier
                          for (final stock in stocks) {
                            final name = stock.manufacturer.isNotEmpty
                                ? stock.manufacturer
                                : 'Unknown Supplier';
                            final info = supplierMap[name];
                            if (info != null && stock.pharmacy.isNotEmpty) {
                              // Track unique pharmacies per supplier
                              if (!info.pharmacyNames
                                  .contains(stock.pharmacy)) {
                                info.pharmacyNames.add(stock.pharmacy);
                                info.pharmacyCount++;
                              }
                            }
                          }

                          final suppliers = supplierMap.values.toList()
                            ..sort(
                                (a, b) => b.totalValue.compareTo(a.totalValue));

                          final filtered = _searchQuery.isEmpty
                              ? suppliers
                              : suppliers
                                  .where((s) => s.name
                                      .toLowerCase()
                                      .contains(
                                          _searchQuery.toLowerCase()))
                                  .toList();

                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                                isWide ? 32 : 16,
                                18,
                                isWide ? 32 : 16,
                                28),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1400),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Hero Header ──
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(28),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              _purpleDark,
                                              _purple,
                                              Color(0xFF6D28D9)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _purple.withAlpha(56),
                                              blurRadius: 32,
                                              offset: const Offset(0, 16),
                                            ),
                                          ],
                                        ),
                                        child: Row(children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withAlpha(38),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withAlpha(64),
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                                Icons.business_rounded,
                                                color: Colors.white,
                                                size: 32),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Supplier Management',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${suppliers.length} suppliers across ${pharmacies.length} pharmacies',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withAlpha(200),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                      const SizedBox(height: 22),

                                      // ── KPI Row ──
                                      if (isWide)
                                        Row(children: [
                                          Expanded(
                                              child: _kpi(
                                                  'Total Suppliers',
                                                  '${suppliers.length}',
                                                  Icons.business_rounded,
                                                  _purple,
                                                  const Color(0xFFF3E8FF))),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _kpi(
                                                  'Total Products',
                                                  '${stocks.length}',
                                                  Icons.inventory_2_rounded,
                                                  _blue,
                                                  const Color(0xFFEFF6FF))),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _kpi(
                                                  'Total Stock Value',
                                                  'K${formatNumber(stocks.fold<double>(0, (s, st) => s + st.quantity * st.price), formatType: FormatType.compact)}',
                                                  Icons.pie_chart_rounded,
                                                  _green,
                                                  const Color(0xFFECFDF5))),
                                          const SizedBox(width: 16),
                                          Expanded(
                                              child: _kpi(
                                                  'Categories',
                                                  '${suppliers.expand((s) => s.categories).toSet().length}',
                                                  Icons.category_rounded,
                                                  _amber,
                                                  const Color(0xFFFFF7ED))),
                                        ])
                                      else
                                        Column(children: [
                                          Row(children: [
                                            Expanded(
                                                child: _kpi(
                                                    'Suppliers',
                                                    '${suppliers.length}',
                                                    Icons.business_rounded,
                                                    _purple,
                                                    const Color(0xFFF3E8FF))),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: _kpi(
                                                    'Products',
                                                    '${stocks.length}',
                                                    Icons
                                                        .inventory_2_rounded,
                                                    _blue,
                                                    const Color(
                                                        0xFFEFF6FF))),
                                          ]),
                                          const SizedBox(height: 12),
                                          Row(children: [
                                            Expanded(
                                                child: _kpi(
                                                    'Stock Value',
                                                    'K${formatNumber(stocks.fold<double>(0, (s, st) => s + st.quantity * st.price), formatType: FormatType.compact)}',
                                                    Icons
                                                        .pie_chart_rounded,
                                                    _green,
                                                    const Color(
                                                        0xFFECFDF5))),
                                            const SizedBox(width: 12),
                                            Expanded(
                                                child: _kpi(
                                                    'Categories',
                                                    '${suppliers.expand((s) => s.categories).toSet().length}',
                                                    Icons.category_rounded,
                                                    _amber,
                                                    const Color(
                                                        0xFFFFF7ED))),
                                          ]),
                                        ]),
                                      const SizedBox(height: 22),

                                      // ── Search Bar ──
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _surface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: _border),
                                        ),
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: (v) => safeSetState(
                                              () => _searchQuery = v),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search suppliers by name...',
                                            prefixIcon: const Icon(
                                                Icons.search_rounded),
                                            filled: true,
                                            fillColor: _bg.withAlpha(120),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                  color: _border),
                                            ),
                                            enabledBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                  color: _border),
                                            ),
                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                  color: _purple,
                                                  width: 1.5),
                                            ),
                                            contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 16,
                                                    vertical: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),

                                      // ── Supplier Table ──
                                      if (filtered.isEmpty)
                                        _emptyCard(
                                            'No suppliers found matching your search.')
                                      else
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _surface,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: _border),
                                          ),
                                          child: Column(children: [
                                            // Table header
                                            Padding(
                                              padding:
                                                  const EdgeInsets
                                                      .fromLTRB(
                                                      18, 14, 18, 10),
                                              child: Row(children: [
                                                const SizedBox(
                                                    width: 40),
                                                Expanded(
                                                    flex: 3,
                                                    child: _tableHeader(
                                                        'Supplier')),
                                                Expanded(
                                                    flex: 2,
                                                    child: _tableHeader(
                                                        'Pharmacies')),
                                                Expanded(
                                                    flex: 2,
                                                    child: _tableHeader(
                                                        'Products')),
                                                if (isWide) ...[
                                                  Expanded(
                                                      flex: 2,
                                                      child: _tableHeader(
                                                          'Categories')),
                                                  Expanded(
                                                      flex: 2,
                                                      child: _tableHeader(
                                                          'Stock Value',
                                                          align:
                                                              TextAlign
                                                                  .right)),
                                                ],
                                              ]),
                                            ),
                                            Divider(
                                                height: 1,
                                                color: _border),
                                            // Rows
                                            ...filtered
                                                .asMap()
                                                .entries
                                                .map((e) =>
                                                    _supplierRow(
                                                        e.value,
                                                        e.key + 1,
                                                        isWide)),
                                          ]),
                                        ),
                                    ]),
                              ),
                            ),
                          );
                        },
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

  Widget _kpi(String label, String value, IconData icon, Color accent,
      Color accentBg) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 16),
            Text(value,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _text,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSec)),
          ]),
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Text(text,
        textAlign: align,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _textSec.withAlpha(160),
            letterSpacing: 0.5));
  }

  Widget _supplierRow(_SupplierInfo supplier, int rank, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: rank % 2 == 0 ? Colors.transparent : _bg.withAlpha(60),
      ),
      child: Row(children: [
        // Rank + Name
        SizedBox(
            width: 40,
            child: Text('$rank',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textSec.withAlpha(140)))),
        Expanded(
          flex: 3,
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _purple.withAlpha(14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_shipping_rounded,
                  color: _purple, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(supplier.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
        Expanded(
            flex: 2,
            child: Text('${supplier.pharmacyCount}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _text))),
        Expanded(
            flex: 2,
            child: Text('${supplier.productCount}',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _text))),
        if (isWide) ...[
          Expanded(
              flex: 2,
              child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: supplier.categories
                      .take(2)
                      .map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _purple.withAlpha(12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(c,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _purple.withAlpha(180)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList())),
          Expanded(
              flex: 2,
              child: Text(
                  'K${formatNumber(supplier.totalValue, formatType: FormatType.compact)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _text))),
        ],
      ]),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Icon(Icons.business_outlined, color: _textSec.withAlpha(80), size: 48),
        const SizedBox(height: 16),
        Text(msg,
            style:
                TextStyle(fontSize: 15, color: _textSec.withAlpha(160))),
      ]),
    );
  }
}

/// Internal supplier aggregation model.
class _SupplierInfo {
  final String name;
  int pharmacyCount;
  int productCount;
  double totalValue;
  Set<String> categories;
  final Set<String> pharmacyNames = {};

  _SupplierInfo({
    required this.name,
    required this.pharmacyCount,
    required this.productCount,
    required this.totalValue,
    required this.categories,
  });
}
