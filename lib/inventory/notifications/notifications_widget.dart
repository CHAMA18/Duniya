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
import 'notifications_model.dart';
export 'notifications_model.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({super.key});

  static String routeName = 'Notifications';
  static String routePath = '/notifications';

  @override
  State<NotificationsWidget> createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  late NotificationsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Purple Design Tokens ──
  static const Color _primary = Color(0xFFA100FF);
  static const Color _deep = Color(0xFF6A00D9);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _light = Color(0xFFE8D5FF);
  static const Color _bg = Color(0xFFF8F5FF);
  static const Color _surface = Colors.white;
  static const Color _textDark = Color(0xFF1A0533);
  static const Color _textMuted = Color(0xFF7C6E93);

  int _selectedTab = 0; // 0: Low Stock, 1: Expiring Soon, 2: All
  String _sortBy = 'Severity';

  // ── Severity Helpers ──
  String _stockSeverity(int qty, int limit) {
    if (qty <= 0) return 'Out of Stock';
    if (qty <= 2) return 'Critical';
    if (qty <= limit) return 'Low';
    return 'Warning';
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'Out of Stock':
        return const Color(0xFFDC2626);
      case 'Critical':
        return const Color(0xFFEA580C);
      case 'Low':
        return const Color(0xFFD97706);
      case 'Warning':
        return const Color(0xFF2563EB);
      default:
        return _textMuted;
    }
  }

  Color _severityBg(String severity) {
    switch (severity) {
      case 'Out of Stock':
        return const Color(0xFFFEE2E2);
      case 'Critical':
        return const Color(0xFFFFEDD5);
      case 'Low':
        return const Color(0xFFFEF3C7);
      case 'Warning':
        return const Color(0xFFDBEAFE);
      default:
        return _light;
    }
  }

  String _expirySeverity(DateTime? expiry) {
    if (expiry == null) return 'Safe';
    final now = DateTime.now();
    final diff = expiry.difference(now).inDays;
    if (diff <= 0) return 'Expired';
    if (diff <= 7) return 'This Week';
    if (diff <= 30) return 'This Month';
    if (diff <= 90) return 'This Quarter';
    return 'Safe';
  }

  Color _expiryColor(String severity) {
    switch (severity) {
      case 'Expired':
        return const Color(0xFFDC2626);
      case 'This Week':
        return const Color(0xFFEA580C);
      case 'This Month':
        return const Color(0xFFD97706);
      case 'This Quarter':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF059669);
    }
  }

  Color _expiryBg(String severity) {
    switch (severity) {
      case 'Expired':
        return const Color(0xFFFEE2E2);
      case 'This Week':
        return const Color(0xFFFFEDD5);
      case 'This Month':
        return const Color(0xFFFEF3C7);
      case 'This Quarter':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  int _severityOrder(String s) {
    switch (s) {
      case 'Out of Stock':
        return 0;
      case 'Critical':
        return 1;
      case 'Expired':
        return 1;
      case 'Low':
        return 2;
      case 'This Week':
        return 2;
      case 'Warning':
        return 3;
      case 'This Month':
        return 3;
      case 'This Quarter':
        return 4;
      default:
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NotificationsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Notifications'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── KPI Card Builder ──
  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _light.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Button Builder ──
  Widget _buildTabButton(String label, int index, int count, bool isPhone) {
    final isActive = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => safeSetState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPhone ? 12 : 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? _primary : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? _primary : _light.withOpacity(0.8),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isPhone ? 13 : 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.white : _textMuted,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withOpacity(0.25)
                        : _light.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : _primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Desktop Table Row ──
  Widget _buildDesktopRow(StockRecord stock, int index) {
    final severity = _stockSeverity(stock.quantity, stock.limitNotice);
    final expirySev = _expirySeverity(stock.expiryDate);
    final sevColor = _selectedTab == 1 ? _expiryColor(expirySev) : _severityColor(severity);
    final sevBg = _selectedTab == 1 ? _expiryBg(expirySev) : _severityBg(severity);
    final sevLabel = _selectedTab == 1 ? expirySev : severity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: index.isEven ? _surface : _bg.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: _light.withOpacity(0.4), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Severity indicator
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: sevColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          // Name
          Expanded(
            flex: 3,
            child: Text(
              stock.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: Text(
              stock.category ?? '-',
              style: const TextStyle(fontSize: 13, color: _textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Quantity
          Expanded(
            flex: 1,
            child: Text(
              '${stock.quantity}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: stock.quantity <= 0
                    ? const Color(0xFFDC2626)
                    : stock.quantity <= stock.limitNotice
                        ? const Color(0xFFD97706)
                        : _textDark,
              ),
            ),
          ),
          // Expiry
          Expanded(
            flex: 2,
            child: Text(
              stock.expiryDate != null
                  ? dateTimeFormat("yMMMd", stock.expiryDate,
                      locale: FFLocalizations.of(context).languageCode)
                  : '-',
              style: const TextStyle(fontSize: 13, color: _textMuted),
            ),
          ),
          // Severity badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: sevBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sevLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: sevColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Card ──
  Widget _buildMobileCard(StockRecord stock) {
    final severity = _stockSeverity(stock.quantity, stock.limitNotice);
    final expirySev = _expirySeverity(stock.expiryDate);
    final sevColor = _selectedTab == 1 ? _expiryColor(expirySev) : _severityColor(severity);
    final sevBg = _selectedTab == 1 ? _expiryBg(expirySev) : _severityBg(severity);
    final sevLabel = _selectedTab == 1 ? expirySev : severity;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _light.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: sevColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stock.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: sevBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sevLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: sevColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 14, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Qty: ${stock.quantity}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: stock.quantity <= 0
                            ? const Color(0xFFDC2626)
                            : stock.quantity <= stock.limitNotice
                                ? const Color(0xFFD97706)
                                : _textDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (stock.expiryDate != null) ...[
                      Icon(Icons.calendar_today, size: 12, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        dateTimeFormat("yMMMd", stock.expiryDate,
                            locale:
                                FFLocalizations.of(context).languageCode),
                        style: const TextStyle(
                            fontSize: 12, color: _textMuted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState(bool isPhone) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _light.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: _primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Clear!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No alerts matching your current filter.',
              style: TextStyle(fontSize: 14, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = responsiveVisibility(
      context: context,
      tablet: false,
      tabletLandscape: false,
      desktop: false,
    );

    return Title(
      title: 'Notifications',
      color: _primary,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: Drawer(
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
                // Sidebar (desktop)
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
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Nav
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                        tablet: false,
                        tabletLandscape: false,
                      ))
                        wrapWithModel(
                          model: _model.topNavModel,
                          updateCallback: () => safeSetState(() {}),
                          child: TopNavWidget(
                            openDrawer: () async {
                              scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                      // Page Body
                      Expanded(
                        child: AuthUserStreamWidget(
                          builder: (context) {
                            final parentRef = valueOrDefault(
                                        currentUserDocument?.role, '') ==
                                    'Owner'
                                ? currentUserReference
                                : currentUserDocument?.ownerRef;

                            return StreamBuilder<List<StockRecord>>(
                              stream: queryStockRecord(
                                parent: parentRef,
                                queryBuilder: (q) =>
                                    q.where('Quantity', isNotEqualTo: 0),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red, size: 48),
                                        const SizedBox(height: 12),
                                        Text('Something went wrong',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SpinKitRing(
                                        color: _primary, size: 48),
                                  );
                                }

                                final allStock = snapshot.data!;
                                final searchQ = _model.searchController?.text
                                        .toLowerCase() ??
                                    '';

                                // Compute KPIs
                                final outOfStock = allStock
                                    .where((s) => s.quantity <= 0)
                                    .length;
                                final critical = allStock
                                    .where((s) =>
                                        s.quantity > 0 &&
                                        s.quantity <= 2)
                                    .length;
                                final lowStock = allStock
                                    .where((s) =>
                                        s.quantity > 2 &&
                                        s.quantity <= s.limitNotice)
                                    .length;
                                final expiringThisMonth = allStock
                                    .where((s) {
                                  if (s.expiryDate == null) return false;
                                  final diff = s.expiryDate!
                                      .difference(DateTime.now())
                                      .inDays;
                                  return diff > 0 && diff <= 30;
                                }).length;

                                // Filter by tab
                                List<StockRecord> filtered;
                                if (_selectedTab == 0) {
                                  // Low Stock
                                  filtered = allStock
                                      .where((s) =>
                                          s.quantity <= s.limitNotice)
                                      .toList();
                                } else if (_selectedTab == 1) {
                                  // Expiring Soon
                                  filtered = allStock.where((s) {
                                    if (s.expiryDate == null) return false;
                                    final diff = s.expiryDate!
                                        .difference(DateTime.now())
                                        .inDays;
                                    return diff <= 90;
                                  }).toList();
                                } else {
                                  filtered = List.from(allStock);
                                }

                                // Search filter
                                if (searchQ.isNotEmpty) {
                                  filtered = filtered.where((s) {
                                    return s.name
                                            .toLowerCase()
                                            .contains(searchQ) ||
                                        (s.category ?? '')
                                            .toLowerCase()
                                            .contains(searchQ);
                                  }).toList();
                                }

                                // Sort
                                if (_sortBy == 'Severity') {
                                  filtered.sort((a, b) {
                                    final sa = _selectedTab == 1
                                        ? _expirySeverity(a.expiryDate)
                                        : _stockSeverity(
                                            a.quantity, a.limitNotice);
                                    final sb = _selectedTab == 1
                                        ? _expirySeverity(b.expiryDate)
                                        : _stockSeverity(
                                            b.quantity, b.limitNotice);
                                    return _severityOrder(sa)
                                        .compareTo(_severityOrder(sb));
                                  });
                                } else if (_sortBy == 'Name') {
                                  filtered.sort((a, b) => a.name
                                      .toLowerCase()
                                      .compareTo(b.name.toLowerCase()));
                                } else if (_sortBy == 'Quantity') {
                                  filtered.sort(
                                      (a, b) => a.quantity.compareTo(b.quantity));
                                }

                                return SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(
                                    isPhone ? 16 : 28,
                                    24,
                                    isPhone ? 16 : 28,
                                    32,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Gradient Header ──
                                      Container(
                                        padding: EdgeInsets.all(isPhone ? 20 : 28),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [_deep, _primary, _accent],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _primary.withOpacity(0.3),
                                              blurRadius: 24,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                  ),
                                                  child: const Icon(
                                                    Icons
                                                        .notifications_active_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Stock Alerts',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                          letterSpacing: -0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Monitor inventory health and expiry alerts in real-time.',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white
                                                              .withOpacity(0.85),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // ── KPI Cards ──
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final isWide =
                                              constraints.maxWidth >= 600;
                                          final cards = [
                                            _buildKpiCard(
                                              title: 'Out of Stock',
                                              value: '$outOfStock',
                                              icon: Icons
                                                  .dangerous_outlined,
                                              color: const Color(0xFFDC2626),
                                              bgColor:
                                                  const Color(0xFFFEE2E2),
                                            ),
                                            _buildKpiCard(
                                              title: 'Critical',
                                              value: '$critical',
                                              icon: Icons
                                                  .warning_amber_rounded,
                                              color: const Color(0xFFEA580C),
                                              bgColor:
                                                  const Color(0xFFFFEDD5),
                                            ),
                                            _buildKpiCard(
                                              title: 'Low Stock',
                                              value: '$lowStock',
                                              icon: Icons
                                                  .trending_down_rounded,
                                              color: const Color(0xFFD97706),
                                              bgColor:
                                                  const Color(0xFFFEF3C7),
                                            ),
                                            _buildKpiCard(
                                              title: 'Expiring Soon',
                                              value: '$expiringThisMonth',
                                              icon: Icons
                                                  .event_busy_rounded,
                                              color: const Color(0xFF2563EB),
                                              bgColor:
                                                  const Color(0xFFDBEAFE),
                                            ),
                                          ];

                                          if (isWide) {
                                            return Row(
                                              children: cards
                                                  .map((c) => Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 14),
                                                        child: Expanded(
                                                            child: c),
                                                      ))
                                                  .toList(),
                                            );
                                          }
                                          return Wrap(
                                            spacing: 14,
                                            runSpacing: 14,
                                            children: cards
                                                .map((c) => SizedBox(
                                                      width: (constraints
                                                                  .maxWidth -
                                                              14) /
                                                          2,
                                                      child: c,
                                                    ))
                                                .toList(),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // ── Tabs ──
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildTabButton(
                                                'Low Stock',
                                                0,
                                                outOfStock + critical + lowStock,
                                                isPhone),
                                            _buildTabButton(
                                                'Expiring Soon',
                                                1,
                                                expiringThisMonth,
                                                isPhone),
                                            _buildTabButton(
                                                'All Alerts',
                                                2,
                                                allStock.length,
                                                isPhone),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // ── Search + Sort Row ──
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _surface,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                    color: _light
                                                        .withOpacity(0.6)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.03),
                                                    blurRadius: 10,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TextField(
                                                controller:
                                                    _model.searchController,
                                                focusNode:
                                                    _model.searchFocusNode,
                                                onChanged: (_) =>
                                                    safeSetState(() {}),
                                                decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                      Icons.search_rounded,
                                                      color: _textMuted),
                                                  suffixIcon: (_model.searchController?.text.isNotEmpty ?? false)
                                                      ? IconButton(
                                                          icon: Icon(
                                                              Icons
                                                                  .clear_rounded,
                                                              color:
                                                                  _textMuted),
                                                          onPressed: () {
                                                            _model.searchController
                                                                ?.clear();
                                                            safeSetState(
                                                                () {});
                                                          },
                                                        )
                                                      : null,
                                                  hintText:
                                                      'Search by name or category...',
                                                  hintStyle: const TextStyle(
                                                      color: _textMuted,
                                                      fontSize: 14),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 14),
                                            decoration: BoxDecoration(
                                              color: _surface,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                  color: _light
                                                      .withOpacity(0.6)),
                                            ),
                                            child: DropdownButton<String>(
                                              value: _sortBy,
                                              underline: const SizedBox(),
                                              icon: Icon(Icons.sort_rounded,
                                                  color: _textMuted, size: 20),
                                              items: [
                                                'Severity',
                                                'Name',
                                                'Quantity',
                                              ]
                                                  .map((v) =>
                                                      DropdownMenuItem(
                                                        value: v,
                                                        child: Text(v,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color: _textDark,
                                                            )),
                                                      ))
                                                  .toList(),
                                              onChanged: (v) =>
                                                  safeSetState(
                                                      () => _sortBy = v!),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 18),

                                      // ── Content ──
                                      if (filtered.isEmpty)
                                        _buildEmptyState(isPhone)
                                      else if (isPhone)
                                        ...filtered
                                            .map((s) =>
                                                _buildMobileCard(s))
                                            .toList()
                                      else ...[
                                        // Desktop table header
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _light.withOpacity(0.3),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight:
                                                  Radius.circular(16),
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              SizedBox(width: 18),
                                              Expanded(
                                                flex: 3,
                                                child: Text('Product',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _deep,
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text('Category',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _deep,
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text('Qty',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _deep,
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text('Expiry',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _deep,
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text('Status',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _deep,
                                                      letterSpacing: 0.5,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _surface,
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(16),
                                              bottomRight:
                                                  Radius.circular(16),
                                            ),
                                            border: Border.all(
                                                color:
                                                    _light.withOpacity(0.4)),
                                          ),
                                          child: Column(
                                            children: filtered
                                                .asMap()
                                                .entries
                                                .map((e) =>
                                                    _buildDesktopRow(
                                                        e.value, e.key))
                                                .toList(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Mobile bottom nav
                      if (isPhone)
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
}
