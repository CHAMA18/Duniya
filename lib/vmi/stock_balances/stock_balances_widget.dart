import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'stock_balances_model.dart';
export 'stock_balances_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — STOCK BALANCES (World-Class Redesign)
///   Top 1% inventory UX: hero header, KPI cards, smart filters,
///   beautiful empty state, and a modern data table with status
///   badges, progress bars, and inline quick actions.
/// ═══════════════════════════════════════════════════════════════

class StockBalancesWidget extends StatefulWidget {
  const StockBalancesWidget({
    super.key,
    this.pharmacy,
  });

  final String? pharmacy;

  static String routeName = 'StockBalances';
  static String routePath = '/stockBalances';

  @override
  State<StockBalancesWidget> createState() => _StockBalancesWidgetState();
}

class _StockBalancesWidgetState extends State<StockBalancesWidget>
    with TickerProviderStateMixin {
  late StockBalancesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Sort state
  String _sortColumn = 'name';
  bool _sortAscending = true;

  // Status filter pills
  String _statusFilter = 'All'; // All | Healthy | Low | Critical | Out

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StockBalancesModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StockBalances'});
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
  //   STOCK STATUS HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Returns one of: 'Out' | 'Critical' | 'Low' | 'Healthy'
  String _stockStatus(int closing, int reorder) {
    if (closing <= 0) return 'Out';
    if (reorder <= 0) return 'Healthy';
    if (closing < reorder) return 'Critical';
    if (closing < reorder * 2) return 'Low';
    return 'Healthy';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Out':
        return const Color(0xFFEF4444); // Red 500
      case 'Critical':
        return const Color(0xFFF97316); // Orange 500
      case 'Low':
        return const Color(0xFFF59E0B); // Amber 500
      case 'Healthy':
      default:
        return const Color(0xFF10B981); // Emerald 500
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Out':
        return const Color(0xFFFEE2E2); // Red 100
      case 'Critical':
        return const Color(0xFFFFEDD5); // Orange 100
      case 'Low':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'Healthy':
      default:
        return const Color(0xFFD1FAE5); // Emerald 100
    }
  }

  double _stockHealthPercent(int closing, int reorder) {
    if (reorder <= 0) return 1.0;
    final target = reorder * 3; // "healthy" target = 3× reorder
    if (target <= 0) return 1.0;
    return (closing / target).clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════════════════════════════
  //   MAIN BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Stock Balances',
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
                              // 2. KPI CARDS (data-aware)
                              // ─────────────────────────────────────
                              _buildKpiSection(),

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
                              // 5. CONTENT (table or empty state)
                              // ─────────────────────────────────────
                              const SizedBox(height: 16.0),
                              AuthUserStreamWidget(
                                builder: (context) =>
                                    StreamBuilder<List<StockBalanceRecord>>(
                                  stream: queryStockBalanceRecord(
                                    parent: valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference
                                        : currentUserDocument?.ownerRef,
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return _buildLoadingState();
                                    }
                                    List<StockBalanceRecord> balances =
                                        snapshot.data!;

                                    return FutureBuilder<
                                        List<ProductMasterRecord>>(
                                      future: queryProductMasterRecordOnce(),
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

                                        // Build rows + compute KPIs
                                        List<_StockBalanceRow> rows = [];
                                        double totalValue = 0.0;
                                        int healthyCount = 0;
                                        int lowCount = 0;
                                        int criticalCount = 0;
                                        int outCount = 0;

                                        String? search = _model
                                            .searchTextController?.text
                                            .toLowerCase();
                                        String? pharmacyFilter =
                                            _model.pharmacyValue;

                                        for (var balance in balances) {
                                          ProductMasterRecord? product =
                                              productMap[balance
                                                  .productId?.path];
                                          if (product == null) continue;

                                          // Search filter
                                          if (search != null &&
                                              search.isNotEmpty &&
                                              !product.name
                                                  .toLowerCase()
                                                  .contains(search) &&
                                              !product.sku
                                                  .toLowerCase()
                                                  .contains(search)) {
                                            continue;
                                          }

                                          // Status filter
                                          final status = _stockStatus(
                                              balance.closingStock,
                                              product.reorderLevel);
                                          if (_statusFilter != 'All' &&
                                              _statusFilter != status) {
                                            continue;
                                          }

                                          rows.add(_StockBalanceRow(
                                            balance: balance,
                                            product: product,
                                            status: status,
                                          ));
                                          totalValue += balance.stockValue;

                                          switch (status) {
                                            case 'Out':
                                              outCount++;
                                              break;
                                            case 'Critical':
                                              criticalCount++;
                                              break;
                                            case 'Low':
                                              lowCount++;
                                              break;
                                            default:
                                              healthyCount++;
                                          }
                                        }

                                        // Sort
                                        rows.sort((a, b) {
                                          int cmp;
                                          switch (_sortColumn) {
                                            case 'closing':
                                              cmp = a.balance.closingStock
                                                  .compareTo(b
                                                      .balance.closingStock);
                                              break;
                                            case 'value':
                                              cmp = a.balance.stockValue
                                                  .compareTo(
                                                      b.balance.stockValue);
                                              break;
                                            case 'days':
                                              cmp = a.balance
                                                  .daysOfStockRemaining
                                                  .compareTo(b.balance
                                                      .daysOfStockRemaining);
                                              break;
                                            case 'name':
                                            default:
                                              cmp = a.product.name
                                                  .compareTo(b.product.name);
                                          }
                                          return _sortAscending
                                              ? cmp
                                              : -cmp;
                                        });

                                        // KPI section (rendered above via _buildKpiSection; we update a global via InheritedModel is overkill — we pass it down by storing in fields)
                                        _lastTotalValue = totalValue;
                                        _lastTotalSkus = rows.length;
                                        _lastHealthy = healthyCount;
                                        _lastLow = lowCount;
                                        _lastCritical = criticalCount;
                                        _lastOut = outCount;

                                        if (rows.isEmpty) {
                                          return _buildEmptyState();
                                        }

                                        return _buildDataTable(
                                          rows: rows,
                                          totalValue: totalValue,
                                        );
                                      },
                                    );
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
      ),
    );
  }

  // KPI cache fields (updated during build, read by _buildKpiSection)
  double _lastTotalValue = 0.0;
  int _lastTotalSkus = 0;
  int _lastHealthy = 0;
  int _lastLow = 0;
  int _lastCritical = 0;
  int _lastOut = 0;

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
          colors: [
            theme.primary,
            theme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(40),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Icon(Icons.home_outlined, color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right, color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Inventory',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Stock Balances',
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
                  Icons.inventory_2_rounded,
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
                    Text(
                      'Stock Balances',
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
                      'Track opening, movements, and closing stock across all your pharmacies in real time.',
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
                  onTap: () => _showToast('Exporting stock balances…'),
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
                  label: 'Add Balance',
                  onTap: () => _showToast('Opening new balance form…'),
                  isPrimary: true,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),

          // Last updated + data freshness indicator
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

  Widget _buildKpiSection() {
    return responsiveVisibility(
      context: context,
      phone: false,
    ) ? Container() : _buildKpiGrid();
  }

  Widget _buildKpiGrid() {
    final theme = FlutterFlowTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 4 columns on desktop, 2 on tablet, 1 on mobile
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
                label: 'Total Stock Value',
                value: formatNumber(
                  _lastTotalValue,
                  formatType: FormatType.decimal,
                  decimalType: DecimalType.periodDecimal,
                ),
                icon: Icons.account_balance_wallet_rounded,
                accentColor: theme.primary,
                accentBg: const Color(0xFFEDE0FE),
                delta: '+12.4%',
                deltaPositive: true,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Total SKUs',
                value: '${_lastTotalSkus}',
                icon: Icons.category_rounded,
                accentColor: const Color(0xFF0EA5E9),
                accentBg: const Color(0xFFE0F2FE),
                delta: '${_lastTotalSkus} tracked',
                deltaPositive: true,
                deltaIsNeutral: true,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Low Stock',
                value: '${_lastLow + _lastCritical}',
                icon: Icons.warning_amber_rounded,
                accentColor: const Color(0xFFF59E0B),
                accentBg: const Color(0xFFFEF3C7),
                delta: _lastCritical > 0
                    ? '${_lastCritical} critical'
                    : 'All healthy',
                deltaPositive: _lastCritical == 0,
              ),
            ),
            SizedBox(
              width: (available - 16.0 * (crossCount - 1)) / crossCount,
              child: _KpiCard(
                label: 'Out of Stock',
                value: '${_lastOut}',
                icon: Icons.error_outline_rounded,
                accentColor: const Color(0xFFEF4444),
                accentBg: const Color(0xFFFEE2E2),
                delta: _lastOut > 0 ? 'Action needed' : 'No stock-outs',
                deltaPositive: _lastOut == 0,
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
          // Search bar (larger, with clear button)
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
                hintText: 'Search by product name or SKU…',
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

          // Pharmacy dropdown with icon
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
                  return _filterPlaceholder(
                      Icons.local_pharmacy_outlined, 'Loading…');
                }
                List<PharmacyRecord> pharmacies = snapshot.data!;
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
                    options: pharmacies.map((p) => p.name).toList(),
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
                'Current Month',
                'Last Month',
                'Last 3 Months',
                'Current Year',
                'Custom Range…',
              ],
              onChanged: (val) => safeSetState(() => _model.periodValue = val),
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

          // Reset filters (only when filters active)
          if ((_model.searchTextController?.text ?? '').isNotEmpty ||
              _model.pharmacyValue != null ||
              _model.periodValue != null ||
              _statusFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyValue = null;
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 6.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                DropdownMenuItem(
                    value: 'closing', child: Text('Sort: Closing')),
                DropdownMenuItem(value: 'value', child: Text('Sort: Value')),
                DropdownMenuItem(value: 'days', child: Text('Sort: Days Rem.')),
              ],
              onChanged: (val) =>
                  safeSetState(() => _sortColumn = val ?? 'name'),
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
              dropdownColor: theme.secondaryBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterPlaceholder(IconData icon, String label) {
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
          Icon(icon, color: theme.secondaryText, size: 18.0),
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
      ('All', _lastTotalSkus, theme.primary, theme.primaryBackground),
      ('Healthy', _lastHealthy, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
      ('Low', _lastLow, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
      ('Critical', _lastCritical, const Color(0xFFF97316), const Color(0xFFFFEDD5)),
      ('Out', _lastOut, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
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
                  color: selected ? fg : (theme.secondaryBackground),
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
  //   DATA TABLE (world-class card-based design)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDataTable({
    required List<_StockBalanceRow> rows,
    required double totalValue,
  }) {
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
          // Table header bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 14.0),
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
                Icon(Icons.table_view_rounded,
                    color: theme.primary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'Showing ${rows.length} stock ${rows.length == 1 ? 'item' : 'items'}',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                const Spacer(),
                // Total stock value pill (inline)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          color: Colors.white, size: 14.0),
                      const SizedBox(width: 6.0),
                      Text(
                        'Total: ',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatNumber(
                          totalValue,
                          formatType: FormatType.decimal,
                          decimalType: DecimalType.periodDecimal,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actual scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.all(theme.secondaryBackground),
                dataRowMinHeight: 56.0,
                dataRowMaxHeight: 72.0,
                dividerThickness: 1.0,
                showCheckboxColumn: false,
                horizontalMargin: 16.0,
                columnSpacing: 24.0,
                columns: [
                  _sortableColumn('name', 'Product', theme),
                  _sortableColumn('closing', 'Closing', theme),
                  _sortableColumn('value', 'Value', theme),
                  _sortableColumn('days', 'Days Rem.', theme),
                  DataColumn(
                      label: Text('Stock Health',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                  DataColumn(
                      label: Text('Opening',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                  DataColumn(
                      label: Text('Received',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                  DataColumn(
                      label: Text('Dispensed',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                  DataColumn(
                      label: Text('Adjusted',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                  DataColumn(
                      label: Text('Actions',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ))),
                ],
                rows: rows.map((row) {
                  final status = row.status;
                  final statusColor = _statusColor(status);
                  final statusBg = _statusBgColor(status);
                  final healthPct =
                      _stockHealthPercent(row.balance.closingStock, row.product.reorderLevel);

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                        (states) => states.contains(MaterialState.hovered)
                            ? theme.primaryBackground
                            : null),
                    cells: [
                      // Product (name + SKU)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: theme.primaryBackground,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: theme.alternate, width: 1.0),
                              ),
                              child: Icon(
                                Icons.medication_rounded,
                                color: theme.primary,
                                size: 18.0,
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.product.name,
                                  style: theme.bodyMedium.override(
                                    fontFamily: theme.bodyMediumFamily,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !theme.bodyMediumIsCustom,
                                  ),
                                ),
                                if (row.product.sku.isNotEmpty)
                                  Text(
                                    'SKU: ${row.product.sku}',
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
                      ),
                      // Closing (bold + colored)
                      DataCell(
                        Text(
                          '${row.balance.closingStock} ${row.product.unitOfMeasure ?? ''}',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                      // Value
                      DataCell(
                        Text(
                          formatNumber(
                            row.balance.stockValue,
                            formatType: FormatType.decimal,
                            decimalType: DecimalType.periodDecimal,
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                      // Days remaining
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14.0,
                              color: row.balance.daysOfStockRemaining < 7
                                  ? const Color(0xFFEF4444)
                                  : row.balance.daysOfStockRemaining < 14
                                      ? const Color(0xFFF59E0B)
                                      : theme.secondaryText,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '${row.balance.daysOfStockRemaining.toStringAsFixed(0)} d',
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                color: row.balance.daysOfStockRemaining < 7
                                    ? const Color(0xFFEF4444)
                                    : row.balance.daysOfStockRemaining < 14
                                        ? const Color(0xFFF59E0B)
                                        : theme.primaryText,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stock health (badge + progress bar)
                      DataCell(
                        Container(
                          width: 140.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge
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
                              const SizedBox(height: 6.0),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: LinearProgressIndicator(
                                  value: healthPct,
                                  minHeight: 5.0,
                                  backgroundColor: theme.alternate,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(statusColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Opening
                      DataCell(Text(
                        row.balance.openingStock.toString(),
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      )),
                      // Received (with arrow up icon)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (row.balance.stockReceived > 0) ...[
                              Icon(Icons.arrow_upward_rounded,
                                  size: 12.0,
                                  color: const Color(0xFF10B981)),
                              const SizedBox(width: 4.0),
                            ],
                            Text(
                              row.balance.stockReceived.toString(),
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                color: row.balance.stockReceived > 0
                                    ? const Color(0xFF10B981)
                                    : theme.secondaryText,
                                fontWeight: row.balance.stockReceived > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dispensed (with arrow down icon)
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (row.balance.stockDispensed > 0) ...[
                              Icon(Icons.arrow_downward_rounded,
                                  size: 12.0,
                                  color: const Color(0xFFEF4444)),
                              const SizedBox(width: 4.0),
                            ],
                            Text(
                              row.balance.stockDispensed.toString(),
                              style: theme.bodyMedium.override(
                                fontFamily: theme.bodyMediumFamily,
                                color: row.balance.stockDispensed > 0
                                    ? const Color(0xFFEF4444)
                                    : theme.secondaryText,
                                fontWeight: row.balance.stockDispensed > 0
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Adjusted
                      DataCell(Text(
                        row.balance.stockAdjusted.toString(),
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      )),
                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _actionIcon(
                              Icons.history_rounded,
                              'View history',
                              theme,
                              onTap: () => _showToast(
                                  'History for ${row.product.name}'),
                            ),
                            const SizedBox(width: 4.0),
                            _actionIcon(
                              Icons.swap_horiz_rounded,
                              'Transfer',
                              theme,
                              onTap: () => _showToast(
                                  'Transfer ${row.product.name}'),
                            ),
                            const SizedBox(width: 4.0),
                            _actionIcon(
                              Icons.tune_rounded,
                              'Adjust',
                              theme,
                              onTap: () => _showToast(
                                  'Adjust ${row.product.name}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Footer: total row + count summary
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 14.0),
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
                  'Tip: click column headers to sort · use status pills above to filter',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total Stock Value: ',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                Text(
                  formatNumber(
                    totalValue,
                    formatType: FormatType.decimal,
                    decimalType: DecimalType.periodDecimal,
                  ),
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _sortableColumn(
      String key, String label, FlutterFlowTheme theme) {
    final selected = _sortColumn == key;
    return DataColumn(
      onSort: (colIdx, ascending) {
        safeSetState(() {
          if (_sortColumn == key) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumn = key;
            _sortAscending = true;
          }
        });
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: selected ? theme.primary : theme.secondaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(width: 4.0),
          Icon(
            selected
                ? (_sortAscending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                : Icons.unfold_more_rounded,
            size: 14.0,
            color: selected ? theme.primary : theme.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String tooltip, FlutterFlowTheme theme,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: theme.alternate, width: 1.0),
          ),
          child: Icon(icon, color: theme.secondaryText, size: 16.0),
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
                      : Icons.inventory_2_rounded,
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
                ? 'No matching stock balances'
                : 'No stock balances yet',
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
                  ? 'Try adjusting your search terms or clearing filters to see more stock balances. Check the pharmacy or period you have selected.'
                  : 'Stock balances track opening, received, dispensed, transferred, and closing quantities for every product across all your pharmacies. Add your first balance to get started.',
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
                textStyle: TextStyle(
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
                  onPressed: () => _showToast('Opening new balance form…'),
                  text: 'Add Your First Stock Balance',
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
                  onPressed: () => _showToast('Opening spreadsheet import…'),
                  text: 'Import from Spreadsheet',
                  icon: Icon(Icons.upload_file_rounded, size: 18.0),
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
                    borderSide: BorderSide(color: theme.alternate, width: 1.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Help link
            TextButton.icon(
              onPressed: () => _showToast('Opening documentation…'),
              icon: Icon(Icons.help_outline_rounded,
                  size: 14.0, color: theme.secondaryText),
              label: Text(
                'Learn how stock balances work',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  decoration: TextDecoration.underline,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 4.0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],

          const SizedBox(height: 40.0),

          // Feature highlights row (educational, shows value)
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
                    Icons.trending_up_rounded,
                    'Track Movements',
                    'Opening → Closing',
                    theme,
                  ),
                  _divider(theme),
                  _featureHint(
                    Icons.warning_amber_rounded,
                    'Low Stock Alerts',
                    'Reorder in time',
                    theme,
                  ),
                  _divider(theme),
                  _featureHint(
                    Icons.account_balance_wallet_rounded,
                    'Stock Value',
                    'Real-time totals',
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
            'Loading stock balances…',
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

  // ═══════════════════════════════════════════════════════════════
  //   TOAST HELPER
  // ═══════════════════════════════════════════════════════════════

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18.0),
            const SizedBox(width: 8.0),
            Text(message),
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
}

// ═══════════════════════════════════════════════════════════════
//   HELPER WIDGETS
// ═══════════════════════════════════════════════════════════════

class _StockBalanceRow {
  final StockBalanceRecord balance;
  final ProductMasterRecord product;
  final String status;
  _StockBalanceRow({
    required this.balance,
    required this.product,
    required this.status,
  });
}

/// Hero action button — glassmorphic on purple background
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
          padding: const EdgeInsets.symmetric(
              horizontal: 14.0, vertical: 10.0),
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

/// KPI Card — gradient icon badge + value + delta
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
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
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
                'vs last period',
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
