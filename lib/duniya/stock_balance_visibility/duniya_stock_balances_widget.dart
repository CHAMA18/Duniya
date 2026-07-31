import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
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
import 'duniya_stock_balances_model.dart';
export 'duniya_stock_balances_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   DUNIYA — STOCK BALANCE VISIBILITY (Network-Wide)
///   THE most important feature for Duniya users.
///
///   Shows current stock balances by product across ALL participating
///   pharmacies. For each product × pharmacy combination, displays:
///   - Opening stock
///   - Stock received
///   - Stock dispensed/sold
///   - Stock transferred
///   - Stock adjusted
///   - Closing stock
///   - Stock value
///   - Days of stock remaining
/// ═══════════════════════════════════════════════════════════════

class DuniyaStockBalancesWidget extends StatefulWidget {
  const DuniyaStockBalancesWidget({super.key});

  static String routeName = 'DuniyaStockBalances';
  static String routePath = '/duniyaStockBalances';

  @override
  State<DuniyaStockBalancesWidget> createState() =>
      _DuniyaStockBalancesWidgetState();
}

class _DuniyaStockBalancesWidgetState
    extends State<DuniyaStockBalancesWidget> {
  late DuniyaStockBalancesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _statusFilter = 'All';
  String _sortColumn = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DuniyaStockBalancesModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'DuniyaStockBalances'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Out':
        return const Color(0xFFEF4444);
      case 'Critical':
        return const Color(0xFFF97316);
      case 'Low':
        return const Color(0xFFF59E0B);
      case 'Healthy':
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Out':
        return const Color(0xFFFEE2E2);
      case 'Critical':
        return const Color(0xFFFFEDD5);
      case 'Low':
        return const Color(0xFFFEF3C7);
      case 'Healthy':
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  String _stockStatus(int closing, int reorder) {
    if (closing <= 0) return 'Out';
    if (reorder <= 0) return 'Healthy';
    if (closing < reorder) return 'Critical';
    if (closing < reorder * 2) return 'Low';
    return 'Healthy';
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

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Stock Balance Visibility — Duniya',
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
                                _buildFilterBar(),
                                const SizedBox(height: 16.0),
                                _buildStatusPills(),
                                const SizedBox(height: 16.0),
                                _buildStockTable(),
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
                'Stock Balance Visibility',
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
                  Icons.visibility_rounded,
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
                      'Stock Balance Visibility',
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
                      'Real-time stock balances across every participating pharmacy. Track opening, received, dispensed, transferred, adjusted, and closing stock by product — with stock value and days of stock remaining.',
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
                _heroAction(Icons.download_rounded, 'Export', () => _showToast('Exporting network stock balances…')),
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
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.white.withAlpha(50), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
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
          // Search
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
                suffixIcon:
                    (_model.searchTextController?.text ?? '').isNotEmpty
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
          // Reset
          if ((_model.searchTextController?.text ?? '').isNotEmpty ||
              _model.pharmacyFilter != null ||
              _statusFilter != 'All')
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                _model.pharmacyFilter = null;
                _model.pharmacyFilterController?.reset();
                setState(() => _statusFilter = 'All');
              },
              icon: Icon(Icons.restart_alt_rounded, size: 16.0),
              label: Text('Reset',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  )),
            ),
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
      ('All', theme.primary, theme.primaryBackground),
      ('Healthy', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
      ('Low', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
      ('Critical', const Color(0xFFF97316), const Color(0xFFFFEDD5)),
      ('Out', const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pills.map((p) {
          final (label, fg, bg) = p;
          final selected = _statusFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => safeSetState(() => _statusFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: selected ? fg : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                      color: selected ? fg : theme.alternate, width: 1.0),
                ),
                child: Text(label,
                    style: TextStyle(
                      color: selected ? Colors.white : theme.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STOCK TABLE — THE CORE FEATURE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStockTable() {
    final theme = FlutterFlowTheme.of(context);

    // Fetch ALL pharmacies across the network using collectionGroup
    return StreamBuilder<List<PharmacyRecord>>(
      stream: queryPharmacyRecord(),
      builder: (context, pharmacySnapshot) {
        if (!pharmacySnapshot.hasData) {
          return _buildLoadingState();
        }

        final allPharmacies = pharmacySnapshot.data!
            .where((p) => !p.deleted && p.networkStatus != 'rejected')
            .toList();

        if (allPharmacies.isEmpty) {
          return _buildEmptyState();
        }

        // For each pharmacy, fetch its stock balances
        return FutureBuilder<List<ProductMasterRecord>>(
          future: queryProductMasterRecordOnce(),
          builder: (context, productSnapshot) {
            if (!productSnapshot.hasData) {
              return _buildLoadingState();
            }

            final productMap = <String, ProductMasterRecord>{};
            for (var p in productSnapshot.data!) {
              productMap[p.reference.path] = p;
            }

            return Column(
              children: allPharmacies.map((pharmacy) {
                return _buildPharmacySection(
                    pharmacy, productMap, theme);
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildPharmacySection(
    PharmacyRecord pharmacy,
    Map<String, ProductMasterRecord> productMap,
    FlutterFlowTheme theme,
  ) {
    final isPending = pharmacy.networkStatus == 'pending_approval';

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
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
          // Pharmacy header
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
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.primary, theme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: Colors.white, size: 20.0),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                      if (pharmacy.address.isNotEmpty)
                        Text(
                          pharmacy.address,
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
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Stock balances for this pharmacy
          _buildPharmacyStockRows(pharmacy, productMap, theme),
        ],
      ),
    );
  }

  Widget _buildPharmacyStockRows(
    PharmacyRecord pharmacy,
    Map<String, ProductMasterRecord> productMap,
    FlutterFlowTheme theme,
  ) {
    // Fetch stock balances for this pharmacy's owner
    final ownerRef = pharmacy.userID;
    if (ownerRef == null) {
      return _buildNoDataRow(theme, 'No owner linked to this pharmacy');
    }

    return StreamBuilder<List<StockBalanceRecord>>(
      stream: queryStockBalanceRecord(parent: ownerRef),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SpinKitRing(color: theme.primary, size: 24.0),
            ),
          );
        }

        final balances = snapshot.data!;
        double totalValue = 0.0;
        int healthyCount = 0;
        int lowCount = 0;
        int criticalCount = 0;
        int outCount = 0;

        // Build rows
        final rows = <Widget>[];
        final search = _model.searchTextController?.text.toLowerCase() ?? '';

        for (var balance in balances) {
          final product = productMap[balance.productId?.path];
          if (product == null) continue;

          // Search filter
          if (search.isNotEmpty &&
              !product.name.toLowerCase().contains(search) &&
              !product.sku.toLowerCase().contains(search)) {
            continue;
          }

          final status = _stockStatus(
              balance.closingStock, product.reorderLevel);

          // Status filter
          if (_statusFilter != 'All' && _statusFilter != status) {
            continue;
          }

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

          rows.add(_buildStockRow(balance, product, status, theme));
        }

        if (rows.isEmpty) {
          return _buildNoDataRow(theme,
              search.isNotEmpty
                  ? 'No products match your search'
                  : 'No stock balances recorded yet');
        }

        return Column(
          children: [
            // KPI summary row
            _buildPharmacyKpiRow(
                totalValue, healthyCount, lowCount, criticalCount, outCount, theme),
            // Column headers
            _buildColumnHeaders(theme),
            // Data rows
            ...rows,
            // Total footer
            _buildTotalFooter(totalValue, theme),
          ],
        );
      },
    );
  }

  Widget _buildPharmacyKpiRow(
      double totalValue,
      int healthy,
      int low,
      int critical,
      int out,
      FlutterFlowTheme theme) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      color: theme.primaryBackground,
      child: Row(
        children: [
          _miniKpi('Total Value', 'ZMK ${formatNumber(totalValue, formatType: FormatType.compact)}',
              Icons.account_balance_wallet_rounded, theme.primary, theme),
          const SizedBox(width: 16.0),
          _miniKpi('Healthy', '$healthy', Icons.check_circle_rounded,
              const Color(0xFF10B981), theme),
          const SizedBox(width: 16.0),
          _miniKpi('Low', '$low', Icons.warning_amber_rounded,
              const Color(0xFFF59E0B), theme),
          const SizedBox(width: 16.0),
          _miniKpi('Critical', '$critical', Icons.error_outline_rounded,
              const Color(0xFFF97316), theme),
          const SizedBox(width: 16.0),
          _miniKpi('Out', '$out', Icons.cancel_rounded,
              const Color(0xFFEF4444), theme),
        ],
      ),
    );
  }

  Widget _miniKpi(
      String label, String value, IconData icon, Color color, FlutterFlowTheme theme) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 14.0),
          const SizedBox(width: 6.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      color: theme.primaryText,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders(FlutterFlowTheme theme) {
    final headers = [
      ('Product', 3),
      ('Opening', 1),
      ('Received', 1),
      ('Dispensed', 1),
      ('Transferred', 1),
      ('Adjusted', 1),
      ('Closing', 1),
      ('Value', 1),
      ('Days Rem.', 1),
      ('Status', 1),
    ];

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate, width: 1.0),
        ),
      ),
      child: Row(
        children: headers
            .map((h) => Expanded(
                  flex: h.$2,
                  child: Text(h.$1,
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      )),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStockRow(
    StockBalanceRecord balance,
    ProductMasterRecord product,
    String status,
    FlutterFlowTheme theme,
  ) {
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.alternate.withAlpha(60), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Product
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: theme.alternate, width: 1.0),
                  ),
                  child: Icon(Icons.medication_rounded,
                      color: theme.primary, size: 16.0),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: TextStyle(
                            color: theme.primaryText,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis),
                      if (product.sku.isNotEmpty)
                        Text('SKU: ${product.sku}',
                            style: TextStyle(
                              color: theme.secondaryText,
                              fontSize: 10.0,
                            )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Opening
          Expanded(
            flex: 1,
            child: Text('${balance.openingStock}',
                style: TextStyle(color: theme.secondaryText, fontSize: 12.0),
                textAlign: TextAlign.center),
          ),
          // Received
          Expanded(
            flex: 1,
            child: Text('${balance.stockReceived}',
                style: TextStyle(
                    color: balance.stockReceived > 0
                        ? const Color(0xFF10B981)
                        : theme.secondaryText,
                    fontSize: 12.0,
                    fontWeight: balance.stockReceived > 0 ? FontWeight.w600 : FontWeight.w400),
                textAlign: TextAlign.center),
          ),
          // Dispensed
          Expanded(
            flex: 1,
            child: Text('${balance.stockDispensed}',
                style: TextStyle(
                    color: balance.stockDispensed > 0
                        ? const Color(0xFFEF4444)
                        : theme.secondaryText,
                    fontSize: 12.0,
                    fontWeight: balance.stockDispensed > 0 ? FontWeight.w600 : FontWeight.w400),
                textAlign: TextAlign.center),
          ),
          // Transferred
          Expanded(
            flex: 1,
            child: Text('${balance.stockTransferred}',
                style: TextStyle(color: theme.secondaryText, fontSize: 12.0),
                textAlign: TextAlign.center),
          ),
          // Adjusted
          Expanded(
            flex: 1,
            child: Text('${balance.stockAdjusted}',
                style: TextStyle(color: theme.secondaryText, fontSize: 12.0),
                textAlign: TextAlign.center),
          ),
          // Closing (bold + colored)
          Expanded(
            flex: 1,
            child: Text('${balance.closingStock}',
                style: TextStyle(
                    color: statusColor,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ),
          // Value
          Expanded(
            flex: 1,
            child: Text(
                formatNumber(balance.stockValue,
                    formatType: FormatType.compact),
                style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          // Days remaining
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 12.0,
                    color: balance.daysOfStockRemaining < 7
                        ? const Color(0xFFEF4444)
                        : balance.daysOfStockRemaining < 14
                            ? const Color(0xFFF59E0B)
                            : theme.secondaryText),
                const SizedBox(width: 2.0),
                Text('${balance.daysOfStockRemaining.toStringAsFixed(0)}d',
                    style: TextStyle(
                        color: balance.daysOfStockRemaining < 7
                            ? const Color(0xFFEF4444)
                            : balance.daysOfStockRemaining < 14
                                ? const Color(0xFFF59E0B)
                                : theme.primaryText,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Status badge
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalFooter(double totalValue, FlutterFlowTheme theme) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Total Stock Value: ',
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              )),
          Text(
              'ZMK ${formatNumber(totalValue, formatType: FormatType.decimal, decimalType: DecimalType.periodDecimal)}',
              style: TextStyle(
                color: theme.primary,
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }

  Widget _buildNoDataRow(FlutterFlowTheme theme, String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                color: theme.secondaryText, size: 32.0),
            const SizedBox(height: 8.0),
            Text(message, style: theme.bodySmall),
          ],
        ),
      ),
    );
  }

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
          Text('Loading network stock balances…',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              )),
          const SizedBox(height: 6.0),
          Text('Fetching stock data from all participating pharmacies',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              )),
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
            child: const Icon(Icons.visibility_rounded,
                color: Colors.white, size: 40.0),
          ),
          const SizedBox(height: 24.0),
          Text('No pharmacies on the network yet',
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                useGoogleFonts: !theme.headlineSmallIsCustom,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          Text(
              'Once pharmacies register and are approved, their stock balances will appear here in real-time.',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              )),
        ],
      ),
    );
  }
}
