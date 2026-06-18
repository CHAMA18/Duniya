import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'manage_pharmacy_model.dart';
export 'manage_pharmacy_model.dart';

class ManagePharmacyWidget extends StatefulWidget {
  const ManagePharmacyWidget({
    super.key,
    this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyRef,
  });

  static String routeName = 'ManagePharmacy';
  static String routePath = '/managePharmacy';

  final String? pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyRef;

  @override
  State<ManagePharmacyWidget> createState() => _ManagePharmacyWidgetState();
}

class _ManagePharmacyWidgetState extends State<ManagePharmacyWidget>
    with TickerProviderStateMixin {
  late ManagePharmacyModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Data lists
  List<StockRecord> _inventory = [];
  List<StockBalanceRecord> _stockBalances = [];
  List<StockMovementRecord> _stockMovements = [];
  List<BatchRecord> _batches = [];
  List<ReplenishmentRecord> _replenishments = [];
  List<LowStockAlertRecord> _lowStockAlerts = [];
  List<OutletRecord> _outlets = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ManagePharmacyModel());
    _tabController = TabController(length: 7, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        safeSetState(() {
          _model.activeTabIndex = _tabController.index;
        });
      }
    });

    FFAppState().SelectedPage = 'My Pharmacies';

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _loadAllData();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  DocumentReference? _pharmacyParent() {
    return valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef;
  }

  Future<void> _loadAllData() async {
    try {
      safeSetState(() => _isLoading = true);
      final parent = _pharmacyParent();
      final pharmName = widget.pharmacyName ?? '';

      // Load all data in parallel
      final results = await Future.wait([
        // Store Inventory - filtered by pharmacy name
        queryStockRecordOnce(
          parent: parent,
          queryBuilder: (q) => q.where('Pharmacy', isEqualTo: pharmName),
        ),
        // Stock Balances
        queryStockBalanceRecordOnce(parent: parent),
        // Stock Movements
        queryStockMovementRecordOnce(parent: parent),
        // Batches - top-level collection
        queryBatchRecordOnce(),
        // Replenishments - top-level collection
        queryReplenishmentRecordOnce(),
        // Low Stock Alerts - top-level collection
        queryLowStockAlertRecordOnce(),
        // Outlets - subcollection under User
        queryOutletRecordOnce(parent: parent),
      ]);

      safeSetState(() {
        _inventory = results[0] as List<StockRecord>;
        _stockBalances = results[1] as List<StockBalanceRecord>;
        _stockMovements = results[2] as List<StockMovementRecord>;
        _batches = results[3] as List<BatchRecord>;
        _replenishments = results[4] as List<ReplenishmentRecord>;
        _lowStockAlerts = results[5] as List<LowStockAlertRecord>;
        _outlets = results[6] as List<OutletRecord>;
        _isLoading = false;
      });
    } catch (e) {
      safeSetState(() => _isLoading = false);
    }
  }

  // ── KPI COMPUTATIONS ──────────────────────────────────────────────────

  int get _totalItems => _inventory.length;
  int get _totalQuantity => _inventory.fold(0, (sum, s) => sum + s.quantity);
  double get _totalValue =>
      _inventory.fold(0.0, (sum, s) => sum + (s.price * s.quantity));
  int get _lowStockCount => _lowStockAlerts.length;
  int get _expiringBatches {
    final now = DateTime.now();
    final thirtyDays = now.add(const Duration(days: 30));
    return _batches
        .where((b) => b.expiryDate != null && b.expiryDate!.isBefore(thirtyDays))
        .length;
  }

  int get _pendingReplenishments =>
      _replenishments.where((r) => r.suggestedOrderQty > 0).length;

  // ── BUILD ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final pharmName = widget.pharmacyName ?? 'Pharmacy';
    final pharmAddress = widget.pharmacyAddress ?? '';

    return Title(
      title: 'Manage $pharmName',
      color: theme.primary.withAlpha(0xFF),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: theme.primaryBackground,
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
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ),
                      // ── MAIN CONTENT ──────────────────────────────────
                      Expanded(
                        child: _isLoading
                            ? Center(child: LoadingSpinnerWidget())
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeroHeader(theme, pharmName, pharmAddress),
                                    const SizedBox(height: 24),
                                    _buildKPICards(theme),
                                    const SizedBox(height: 28),
                                    _buildTabSection(theme),
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
      ),
    );
  }

  // ── HERO HEADER ────────────────────────────────────────────────────────

  Widget _buildHeroHeader(FlutterFlowTheme theme, String name, String address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_pharmacy_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.headlineMedium?.override(
                    fontFamily: theme.headlineMediumFamily,
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    useGoogleFonts: !theme.headlineMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      address.isNotEmpty ? address : 'No address set',
                      style: theme.bodyMedium?.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Active',
                  style: theme.bodySmall?.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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

  // ── KPI CARDS ──────────────────────────────────────────────────────────

  Widget _buildKPICards(FlutterFlowTheme theme) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 12.0;
      final cardWidth = (constraints.maxWidth - (spacing * 4)) / 5;
      final showCompact = constraints.maxWidth < 900;

      final kpis = [
        _KPIData(
          title: 'Total Items',
          value: '$_totalItems',
          subtitle: 'Products in store',
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF3E8FF),
        ),
        _KPIData(
          title: 'Stock Qty',
          value: _totalQuantity.toString(),
          subtitle: 'Units available',
          icon: Icons.cases_rounded,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFDBEAFE),
        ),
        _KPIData(
          title: 'Stock Value',
          value: 'ZMK ${_totalValue.toStringAsFixed(0)}',
          subtitle: 'Total inventory value',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF059669),
          bgColor: const Color(0xFFD1FAE5),
        ),
        _KPIData(
          title: 'Low Stock',
          value: '$_lowStockCount',
          subtitle: 'Items below reorder',
          icon: Icons.warning_amber_rounded,
          color: _lowStockCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
          bgColor: _lowStockCount > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
        ),
        _KPIData(
          title: 'Expiring Soon',
          value: '$_expiringBatches',
          subtitle: 'Batches within 30 days',
          icon: Icons.event_busy_rounded,
          color: _expiringBatches > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
          bgColor: _expiringBatches > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
        ),
      ];

      if (showCompact) {
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: kpis.map((kpi) => _buildKPICard(theme, kpi, 160)).toList(),
        );
      }

      return Row(
        children: kpis
            .asMap()
            .entries
            .map((entry) {
              final isLast = entry.key == kpis.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : spacing),
                  child: _buildKPICard(theme, entry.value, cardWidth),
                ),
              );
            })
            .toList(),
      );
    });
  }

  Widget _buildKPICard(FlutterFlowTheme theme, _KPIData kpi, double width) {
    return Container(
      constraints: BoxConstraints(minWidth: width.clamp(140, 260)),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kpi.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            kpi.value,
            style: theme.headlineMedium?.override(
              fontFamily: theme.headlineMediumFamily,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              useGoogleFonts: !theme.headlineMediumIsCustom,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            kpi.title,
            style: theme.bodyMedium?.override(
              fontFamily: theme.bodyMediumFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            kpi.subtitle,
            style: theme.bodySmall?.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 11,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB SECTION ────────────────────────────────────────────────────────

  Widget _buildTabSection(FlutterFlowTheme theme) {
    final tabs = [
      _TabData(label: 'Store Inventory', icon: Icons.inventory_2_rounded),
      _TabData(label: 'Stock Balances', icon: Icons.scale_rounded),
      _TabData(label: 'Stock Movements', icon: Icons.swap_horiz_rounded),
      _TabData(label: 'Batch & Expiry', icon: Icons.batch_prediction_rounded),
      _TabData(label: 'Replenishment', icon: Icons.autorenew_rounded),
      _TabData(label: 'Low Stock Alerts', icon: Icons.notification_important_rounded),
      _TabData(label: 'Outlets', icon: Icons.store_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab bar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.alternate.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: theme.primary,
            unselectedLabelColor: theme.secondaryText,
            labelStyle: theme.bodyMedium?.override(
              fontFamily: theme.bodyMediumFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
            unselectedLabelStyle: theme.bodyMedium?.override(
              fontFamily: theme.bodyMediumFamily,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
            indicatorColor: theme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tabs: tabs
                .map((tab) => Tab(
                      height: 44,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tab.icon, size: 16),
                          const SizedBox(width: 6),
                          Text(tab.label),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        // Tab content
        SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInventoryTab(theme),
              _buildStockBalancesTab(theme),
              _buildStockMovementsTab(theme),
              _buildBatchExpiryTab(theme),
              _buildReplenishmentTab(theme),
              _buildLowStockAlertsTab(theme),
              _buildOutletsTab(theme),
            ],
          ),
        ),
      ],
    );
  }

  // ── SECTION HEADER HELPER ──────────────────────────────────────────────

  Widget _buildSectionHeader(FlutterFlowTheme theme, String title, IconData icon,
      {Widget? trailing, String? count}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.titleMedium?.override(
              fontFamily: theme.titleMediumFamily,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.2,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count,
              style: theme.bodySmall?.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── EMPTY STATE HELPER ─────────────────────────────────────────────────

  Widget _buildEmptyState(FlutterFlowTheme theme, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.alternate.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.secondaryText, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.bodyMedium?.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DATA TABLE CARD HELPER ─────────────────────────────────────────────

  Widget _buildDataTableCard(FlutterFlowTheme theme, {required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(FlutterFlowTheme theme, List<String> columns, List<double> widths) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.primaryBackground.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: theme.alternate.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: List.generate(columns.length, (i) {
          return SizedBox(
            width: widths[i],
            child: Text(
              columns[i],
              style: theme.bodySmall?.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.5,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTableRow(FlutterFlowTheme theme, List<Widget> cells, {bool isLast = false, Color? accentColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: theme.alternate.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(children: cells),
    );
  }

  // ── STATUS BADGE ───────────────────────────────────────────────────────

  Widget _buildStatusBadge(FlutterFlowTheme theme, String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.bodySmall?.override(
          fontFamily: theme.bodySmallFamily,
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.bodySmallIsCustom,
        ),
      ),
    );
  }

  // ━━ TAB 1: STORE INVENTORY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildInventoryTab(FlutterFlowTheme theme) {
    if (_inventory.isEmpty) {
      return _buildEmptyState(theme, 'No inventory items found', Icons.inventory_2_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Store Inventory',
          Icons.inventory_2_rounded,
          count: '${_inventory.length} items',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Product', 'Category', 'Qty', 'Price', 'Batch', 'Status'],
                [200, 120, 80, 100, 120, 100],
              ),
              ..._inventory.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isLow = item.quantity <= item.limitNotice && item.limitNotice > 0;
                return _buildTableRow(
                  theme,
                  isLast: idx == _inventory.length - 1,
                  accentColor: isLow ? const Color(0xFFDC2626) : null,
                  [
                    // Product name
                    SizedBox(
                      width: 200,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: (isLow ? const Color(0xFFDC2626) : theme.primary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              size: 16,
                              color: isLow ? const Color(0xFFDC2626) : theme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.bodyMedium?.override(
                                fontFamily: theme.bodyMediumFamily,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category
                    SizedBox(
                      width: 120,
                      child: Text(
                        item.category,
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Qty
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${item.quantity}',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w700,
                          color: isLow ? const Color(0xFFDC2626) : null,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    // Price
                    SizedBox(
                      width: 100,
                      child: Text(
                        'ZMK ${item.price.toStringAsFixed(2)}',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    // Batch
                    SizedBox(
                      width: 120,
                      child: Text(
                        item.batchNumber.isNotEmpty ? item.batchNumber : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    // Status
                    SizedBox(
                      width: 100,
                      child: isLow
                          ? _buildStatusBadge(theme, 'Low Stock', const Color(0xFFDC2626), const Color(0xFFFEE2E2))
                          : _buildStatusBadge(theme, 'In Stock', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ━━ TAB 2: STOCK BALANCES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildStockBalancesTab(FlutterFlowTheme theme) {
    if (_stockBalances.isEmpty) {
      return _buildEmptyState(theme, 'No stock balance records found', Icons.scale_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Stock Balances',
          Icons.scale_rounded,
          count: '${_stockBalances.length} records',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Period', 'Opening', 'Received', 'Dispensed', 'Closing', 'Value', 'DOS'],
                [100, 90, 90, 90, 90, 100, 80],
              ),
              ..._stockBalances.asMap().entries.map((entry) {
                final idx = entry.key;
                final bal = entry.value;
                return _buildTableRow(
                  theme,
                  isLast: idx == _stockBalances.length - 1,
                  [
                    SizedBox(
                      width: 100,
                      child: Text(
                        bal.period.isNotEmpty ? bal.period : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text('${bal.openingStock}', style: theme.bodySmall?.override(
                        fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      )),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text('${bal.stockReceived}', style: theme.bodySmall?.override(
                        fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                        color: const Color(0xFF059669), useGoogleFonts: !theme.bodySmallIsCustom,
                      )),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text('${bal.stockDispensed}', style: theme.bodySmall?.override(
                        fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                        color: const Color(0xFF2563EB), useGoogleFonts: !theme.bodySmallIsCustom,
                      )),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${bal.closingStock}',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'ZMK ${bal.stockValue.toStringAsFixed(2)}',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: _buildDOSBadge(theme, bal.daysOfStockRemaining),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDOSBadge(FlutterFlowTheme theme, double dos) {
    if (dos <= 7) {
      return _buildStatusBadge(theme, '${dos.toStringAsFixed(0)}d', const Color(0xFFDC2626), const Color(0xFFFEE2E2));
    } else if (dos <= 30) {
      return _buildStatusBadge(theme, '${dos.toStringAsFixed(0)}d', const Color(0xFFD97706), const Color(0xFFFEF3C7));
    }
    return _buildStatusBadge(theme, '${dos.toStringAsFixed(0)}d', const Color(0xFF059669), const Color(0xFFD1FAE5));
  }

  // ━━ TAB 3: STOCK MOVEMENTS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildStockMovementsTab(FlutterFlowTheme theme) {
    if (_stockMovements.isEmpty) {
      return _buildEmptyState(theme, 'No stock movement records found', Icons.swap_horiz_outlined);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Stock Movements',
          Icons.swap_horiz_rounded,
          count: '${_stockMovements.length} movements',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Date', 'Type', 'Quantity', 'Reference', 'Reason', 'Status'],
                [110, 120, 90, 140, 180, 100],
              ),
              ..._stockMovements.asMap().entries.map((entry) {
                final idx = entry.key;
                final mov = entry.value;
                return _buildTableRow(
                  theme,
                  isLast: idx == _stockMovements.length - 1,
                  [
                    SizedBox(
                      width: 110,
                      child: Text(
                        mov.createdAt != null
                            ? '${mov.createdAt!.day}/${mov.createdAt!.month}/${mov.createdAt!.year}'
                            : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: _buildMovementTypeBadge(theme, mov.movementType),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${mov.quantity}',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        mov.movementReference?.isNotEmpty == true ? mov.movementReference! : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: Text(
                        mov.reason?.isNotEmpty == true ? mov.reason! : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: _buildStatusBadge(theme, 'Recorded', const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMovementTypeBadge(FlutterFlowTheme theme, String type) {
    switch (type.toLowerCase()) {
      case 'in':
      case 'received':
      case 'receipt':
        return _buildStatusBadge(theme, type, const Color(0xFF059669), const Color(0xFFD1FAE5));
      case 'out':
      case 'dispensed':
      case 'sale':
        return _buildStatusBadge(theme, type, const Color(0xFF2563EB), const Color(0xFFDBEAFE));
      case 'transfer':
        return _buildStatusBadge(theme, type, const Color(0xFF7C3AED), const Color(0xFFF3E8FF));
      case 'adjustment':
        return _buildStatusBadge(theme, type, const Color(0xFFD97706), const Color(0xFFFEF3C7));
      default:
        return _buildStatusBadge(theme, type, theme.secondaryText, theme.alternate.withValues(alpha: 0.2));
    }
  }

  // ━━ TAB 4: BATCH & EXPIRY ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildBatchExpiryTab(FlutterFlowTheme theme) {
    if (_batches.isEmpty) {
      return _buildEmptyState(theme, 'No batch records found', Icons.batch_prediction_outlined);
    }

    final now = DateTime.now();
    final thirtyDays = now.add(const Duration(days: 30));
    final ninetyDays = now.add(const Duration(days: 90));

    // Sort batches by expiry date (soonest first)
    final sortedBatches = List<BatchRecord>.from(_batches)
      ..sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Batch & Expiry Tracking',
          Icons.batch_prediction_rounded,
          count: '${_batches.length} batches',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Batch No.', 'Quantity', 'Expiry Date', 'Days Left', 'Location', 'Status'],
                [130, 90, 120, 100, 150, 110],
              ),
              ...sortedBatches.asMap().entries.map((entry) {
                final idx = entry.key;
                final batch = entry.value;
                final expiry = batch.expiryDate;
                final daysLeft = expiry != null ? expiry.difference(now).inDays : null;
                final isExpired = daysLeft != null && daysLeft < 0;
                final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft <= 30;
                final isNearExpiry = daysLeft != null && daysLeft > 30 && daysLeft <= 90;

                Color statusColor;
                Color statusBg;
                String statusLabel;
                if (isExpired) {
                  statusColor = const Color(0xFFDC2626);
                  statusBg = const Color(0xFFFEE2E2);
                  statusLabel = 'Expired';
                } else if (isExpiringSoon) {
                  statusColor = const Color(0xFFD97706);
                  statusBg = const Color(0xFFFEF3C7);
                  statusLabel = 'Expiring Soon';
                } else if (isNearExpiry) {
                  statusColor = const Color(0xFF2563EB);
                  statusBg = const Color(0xFFDBEAFE);
                  statusLabel = 'Near Expiry';
                } else {
                  statusColor = const Color(0xFF059669);
                  statusBg = const Color(0xFFD1FAE5);
                  statusLabel = 'Valid';
                }

                return _buildTableRow(
                  theme,
                  isLast: idx == sortedBatches.length - 1,
                  [
                    SizedBox(
                      width: 130,
                      child: Text(
                        batch.batchNumber.isNotEmpty ? batch.batchNumber : '-',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${batch.quantity}',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        expiry != null
                            ? '${expiry.day}/${expiry.month}/${expiry.year}'
                            : 'N/A',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: isExpired ? const Color(0xFFDC2626) : null,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: daysLeft != null
                          ? Text(
                              isExpired ? '${daysLeft.abs()}d overdue' : '$daysLeft days',
                              style: theme.bodySmall?.override(
                                fontFamily: theme.bodySmallFamily,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodySmallIsCustom,
                              ),
                            )
                          : Text('-', style: theme.bodySmall?.override(
                              fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            )),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        batch.facilityLocation?.isNotEmpty == true ? batch.facilityLocation! : '-',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: _buildStatusBadge(theme, statusLabel, statusColor, statusBg),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ━━ TAB 5: REPLENISHMENT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildReplenishmentTab(FlutterFlowTheme theme) {
    if (_replenishments.isEmpty) {
      return _buildEmptyState(theme, 'No replenishment recommendations', Icons.autorenew_outlined);
    }

    // Sort by suggested order qty descending (most urgent first)
    final sorted = List<ReplenishmentRecord>.from(_replenishments)
      ..sort((a, b) => b.suggestedOrderQty.compareTo(a.suggestedOrderQty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Replenishment Recommendations',
          Icons.autorenew_rounded,
          count: '${_pendingReplenishments} pending',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Product', 'Avg Weekly Sales', 'Current Stock', 'Target Level', 'Suggested Qty', 'Urgency'],
                [200, 130, 120, 120, 120, 110],
              ),
              ...sorted.asMap().entries.map((entry) {
                final idx = entry.key;
                final rep = entry.value;
                final deficit = rep.targetStockLevel - rep.currentStock;
                final urgencyRatio = rep.currentStock > 0
                    ? rep.currentStock / rep.targetStockLevel
                    : 0.0;

                Color urgencyColor;
                Color urgencyBg;
                String urgencyLabel;
                if (urgencyRatio < 0.2) {
                  urgencyColor = const Color(0xFFDC2626);
                  urgencyBg = const Color(0xFFFEE2E2);
                  urgencyLabel = 'Critical';
                } else if (urgencyRatio < 0.5) {
                  urgencyColor = const Color(0xFFD97706);
                  urgencyBg = const Color(0xFFFEF3C7);
                  urgencyLabel = 'High';
                } else {
                  urgencyColor = const Color(0xFF2563EB);
                  urgencyBg = const Color(0xFFDBEAFE);
                  urgencyLabel = 'Moderate';
                }

                return _buildTableRow(
                  theme,
                  isLast: idx == sorted.length - 1,
                  [
                    SizedBox(
                      width: 200,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.shopping_cart_rounded, size: 16, color: urgencyColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Product',
                              style: theme.bodyMedium?.override(
                                fontFamily: theme.bodyMediumFamily,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: Text(
                        '${rep.averageWeeklySales.toStringAsFixed(1)}/wk',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${rep.currentStock} units',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w700,
                          color: urgencyRatio < 0.2 ? const Color(0xFFDC2626) : null,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${rep.targetStockLevel} units',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${rep.suggestedOrderQty}',
                          style: theme.bodyMedium?.override(
                            fontFamily: theme.bodyMediumFamily,
                            color: const Color(0xFF7C3AED),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: _buildStatusBadge(theme, urgencyLabel, urgencyColor, urgencyBg),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ━━ TAB 6: LOW STOCK ALERTS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildLowStockAlertsTab(FlutterFlowTheme theme) {
    if (_lowStockAlerts.isEmpty) {
      return _buildEmptyState(theme, 'No low stock alerts - all items are well stocked!', Icons.check_circle_outline);
    }

    // Sort by urgency (most critical first)
    final sorted = List<LowStockAlertRecord>.from(_lowStockAlerts)
      ..sort((a, b) {
        // Critical first, then Warning, then Info
        final order = {'Critical': 0, 'Warning': 1, 'Info': 2};
        final aOrder = order[a.status] ?? 3;
        final bOrder = order[b.status] ?? 3;
        return aOrder.compareTo(bOrder);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Low Stock Alerts',
          Icons.notification_important_rounded,
          count: '${_lowStockAlerts.length} alerts',
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTableCard(
            theme,
            children: [
              _buildTableHeader(
                theme,
                ['Product', 'Current Stock', 'Reorder Level', 'Deficit', 'Suggested Qty', 'Alert Level'],
                [200, 120, 120, 100, 120, 110],
              ),
              ...sorted.asMap().entries.map((entry) {
                final idx = entry.key;
                final alert = entry.value;
                final deficit = alert.reorderLevel - alert.currentStock;

                Color alertColor;
                Color alertBg;
                IconData alertIcon;
                switch (alert.status.toLowerCase()) {
                  case 'critical':
                    alertColor = const Color(0xFFDC2626);
                    alertBg = const Color(0xFFFEE2E2);
                    alertIcon = Icons.error_rounded;
                    break;
                  case 'warning':
                    alertColor = const Color(0xFFD97706);
                    alertBg = const Color(0xFFFEF3C7);
                    alertIcon = Icons.warning_rounded;
                    break;
                  default:
                    alertColor = const Color(0xFF2563EB);
                    alertBg = const Color(0xFFDBEAFE);
                    alertIcon = Icons.info_rounded;
                }

                return _buildTableRow(
                  theme,
                  isLast: idx == sorted.length - 1,
                  [
                    SizedBox(
                      width: 200,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: alertBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(alertIcon, size: 16, color: alertColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Product',
                              style: theme.bodyMedium?.override(
                                fontFamily: theme.bodyMediumFamily,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.0,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${alert.currentStock} units',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w700,
                          color: alertColor,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${alert.reorderLevel} units',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily, letterSpacing: 0.0,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          deficit > 0 ? '-$deficit' : '0',
                          style: theme.bodySmall?.override(
                            fontFamily: theme.bodySmallFamily,
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '+${alert.suggestedQuantity} units',
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: _buildStatusBadge(theme, alert.status, alertColor, alertBg),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ━━ TAB 7: OUTLETS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildOutletsTab(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          theme,
          'Pharmacy Outlets',
          Icons.store_rounded,
          count: '${_outlets.length} outlets',
          trailing: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              height: 34,
              child: OutlinedButton.icon(
                onPressed: () => _showAddOutletDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Outlet'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primary,
                  side: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  textStyle: theme.bodySmall?.override(
                    fontFamily: theme.bodySmallFamily,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_outlets.isEmpty)
          _buildEmptyState(theme, 'No outlets configured yet', Icons.store_outlined)
        else
          Expanded(
            child: _buildDataTableCard(
              theme,
              children: [
                _buildTableHeader(
                  theme,
                  ['Outlet Name', 'Code', 'Address', 'Status', 'Created', 'Actions'],
                  [200, 120, 200, 110, 120, 100],
                ),
                ..._outlets.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final outlet = entry.value;
                  return _buildTableRow(
                    theme,
                    isLast: idx == _outlets.length - 1,
                    [
                      // Name
                      SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: (outlet.isActive
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF6B7280))
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.store_rounded,
                                size: 16,
                                color: outlet.isActive
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                outlet.name,
                                style: theme.bodyMedium?.override(
                                  fontFamily: theme.bodyMediumFamily,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodyMediumIsCustom,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Code
                      SizedBox(
                        width: 120,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            outlet.code,
                            style: theme.bodySmall?.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ),
                      ),
                      // Address
                      SizedBox(
                        width: 200,
                        child: Text(
                          outlet.hasAddress() ? outlet.address! : '-',
                          style: theme.bodySmall?.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status
                      SizedBox(
                        width: 110,
                        child: outlet.isActive
                            ? _buildStatusBadge(theme, 'Active', const Color(0xFF059669), const Color(0xFFD1FAE5))
                            : _buildStatusBadge(theme, 'Inactive', const Color(0xFF6B7280), const Color(0xFFF3F4F6)),
                      ),
                      // Created
                      SizedBox(
                        width: 120,
                        child: Text(
                          outlet.createdAt != null
                              ? '${outlet.createdAt!.day}/${outlet.createdAt!.month}/${outlet.createdAt!.year}'
                              : '-',
                          style: theme.bodySmall?.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ),
                      // Actions
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIconActionButton(
                              theme: theme,
                              icon: outlet.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                              color: outlet.isActive ? const Color(0xFF059669) : const Color(0xFF6B7280),
                              onTap: () => _toggleOutletStatus(outlet),
                            ),
                            const SizedBox(width: 6),
                            _buildIconActionButton(
                              theme: theme,
                              icon: Icons.delete_outline_rounded,
                              color: const Color(0xFFDC2626),
                              onTap: () => _deleteOutlet(outlet),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIconActionButton({
    required FlutterFlowTheme theme,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  void _showAddOutletDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_rounded, color: Color(0xFF7C3AED), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Add Outlet',
                style: FlutterFlowTheme.of(context).titleLarge?.override(
                  fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width > 440 ? 440 : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Outlet Name *',
                      prefixIcon: const Icon(Icons.label_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Outlet Code *',
                      prefixIcon: const Icon(Icons.qr_code_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: const Icon(Icons.location_on_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty || codeController.text.isEmpty) return;
                final ownerRef = _pharmacyParent();
                if (ownerRef == null) return;
                await OutletRecord.createDoc(ownerRef).set(
                  createOutletRecordData(
                    name: nameController.text,
                    code: codeController.text,
                    address: addressController.text.isNotEmpty ? addressController.text : null,
                    isActive: true,
                    createdAt: getCurrentTimestamp,
                    updatedAt: getCurrentTimestamp,
                  ),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Outlet added successfully')),
                );
                await _loadAllData();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleOutletStatus(OutletRecord outlet) async {
    await outlet.reference.update({
      'IsActive': !outlet.isActive,
      'UpdatedAt': DateTime.now(),
    });
    await _loadAllData();
  }

  Future<void> _deleteOutlet(OutletRecord outlet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Outlet'),
        content: Text('Are you sure you want to delete "${outlet.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await outlet.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlet deleted')),
      );
      await _loadAllData();
    }
  }
}

// ── DATA CLASSES ──────────────────────────────────────────────────────────

class _KPIData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _KPIData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _TabData {
  final String label;
  final IconData icon;

  const _TabData({required this.label, required this.icon});
}
