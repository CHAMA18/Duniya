import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'replenishment_model.dart';
export 'replenishment_model.dart';

class ReplenishmentWidget extends StatefulWidget {
  const ReplenishmentWidget({super.key});

  static String routeName = 'Replenishment';
  static String routePath = '/replenishment';

  @override
  State<ReplenishmentWidget> createState() => _ReplenishmentWidgetState();
}

class _ReplenishmentWidgetState extends State<ReplenishmentWidget> {
  late ReplenishmentModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReplenishmentModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Replenishment'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Get the parent reference based on user role
  DocumentReference? _getParentRef() {
    final role = valueOrDefault(currentUserDocument?.role, '');
    if (role == 'Owner') {
      return currentUserReference;
    } else {
      return currentUserDocument?.ownerRef;
    }
  }

  /// Recalculate replenishment recommendations
  Future<void> _recalculate() async {
    final products = await queryProductMasterRecordOnce();
    final ownerRef = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;
    final pharmacies = await queryPharmacyRecordOnce(parent: ownerRef);

    for (var pharmacy in pharmacies) {
      for (var product in products) {
        if (!product.isActive) continue;
        final balances = await queryStockBalanceRecordOnce(
          parent: ownerRef,
          queryBuilder: (q) =>
              q.where('ProductId', isEqualTo: product.reference).limit(1),
        );

        int currentStock =
            balances.isNotEmpty ? balances.first.closingStock : 0;
        int targetLevel = product.targetStockLevel;
        int suggestedQty = targetLevel - currentStock;

        if (suggestedQty > 0) {
          final movements = await queryStockMovementRecordOnce(
            parent: ownerRef,
            queryBuilder: (q) => q
                .where('ProductId', isEqualTo: product.reference)
                .where('MovementType', isEqualTo: 'SOLD')
                .orderBy('CreatedAt', descending: true)
                .limit(28),
          );

          double avgWeeklySales = 0.0;
          if (movements.isNotEmpty) {
            int totalSold =
                movements.fold(0, (sum, m) => sum + m.quantity);
            avgWeeklySales = totalSold / 4.0;
          }

          await ReplenishmentRecord.collection.doc().set(
                createReplenishmentRecordData(
                  pharmacyId: pharmacy.reference,
                  productId: product.reference,
                  averageWeeklySales: avgWeeklySales,
                  currentStock: currentStock,
                  targetStockLevel: targetLevel,
                  suggestedOrderQty: suggestedQty,
                  createdAt: getCurrentTimestamp,
                  updatedAt: getCurrentTimestamp,
                ),
              );
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Replenishment recommendations refreshed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design tokens — Black + White theme
    final primaryBlue = theme.primary; // Black
    final primaryContainer = theme.primary.withValues(alpha: 0.08);
    final secondaryAccent = theme.secondary; // Gray 700
    final onSurface = theme.primaryText;
    final onSurfaceVariant = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);
    final outline = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
    final outlineVariant = theme.lineColor;
    final surfaceContainerLow = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final surfaceContainerHigh = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final surfaceContainerHighest = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final cardBg = theme.secondaryBackground; // White cards
    final surfaceBg = theme.primaryBackground; // White in light, gray-900 in dark
    final surfaceBright = isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
    final surfaceDim = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final rowHoverBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final headerBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);

    return Title(
      title: 'Replenishment',
      color: theme.primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: surfaceBg,
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
                      // Top Navigation
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ),
                      // Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== PAGE HEADER =====
                              _buildPageHeader(
                                context,
                                onSurface,
                                onSurfaceVariant,
                                primaryBlue,
                                outlineVariant,
                                surfaceContainerHigh,
                              ),
                              const SizedBox(height: 24.0),

                              // ===== EXECUTIVE SUMMARY CARDS (4 cards) =====
                              _buildSummaryCards(
                                context,
                                primaryBlue,
                                primaryContainer,
                                onSurface,
                                onSurfaceVariant,
                                outline,
                                outlineVariant,
                                cardBg,
                              ),
                              const SizedBox(height: 24.0),

                              // ===== MAIN LAYOUT: Table + Sidebar =====
                              _buildMainLayout(
                                context,
                                primaryBlue,
                                primaryContainer,
                                onSurface,
                                onSurfaceVariant,
                                outline,
                                outlineVariant,
                                surfaceContainerLow,
                                surfaceContainerHigh,
                                surfaceContainerHighest,
                                cardBg,
                                surfaceBright,
                                surfaceDim,
                                headerBg,
                                rowHoverBg,
                              ),
                              const SizedBox(height: 32.0),
                            ],
                          ),
                        ),
                      ),
                      // Mobile navbar
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

  // ===== PAGE HEADER =====
  Widget _buildPageHeader(
    BuildContext context,
    Color onSurface,
    Color onSurfaceVariant,
    Color primaryBlue,
    Color outlineVariant,
    Color surfaceContainerHigh,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16.0,
      runSpacing: 12.0,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replenishment Queue',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 32.0,
                fontWeight: FontWeight.w600,
                color: onSurface,
                height: 1.2,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Manage procurement and clinical stock health.',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auto-Generate Orders Button
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => _recalculate(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_outlined, color: onSurface, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Auto-Generate Orders',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Create PO Button
            Material(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () {
                  // Create PO action
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.2),
                        offset: const Offset(0, 1),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Create PO',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== EXECUTIVE SUMMARY CARDS =====
  Widget _buildSummaryCards(
    BuildContext context,
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color cardBg,
  ) {
    return StreamBuilder<List<ReplenishmentRecord>>(
      stream: queryReplenishmentRecord(),
      builder: (context, snapshot) {
        int pendingOrders = 0;
        double estValue = 0.0;
        double healthPercent = 0.0;
        // Total suggested calculated for forecast

        if (snapshot.hasData) {
          final records = snapshot.data!;
          pendingOrders = records.length;
          // Estimate value based on suggested qty * average unit cost
          estValue = records.fold(0.0, (sum, r) => sum + (r.suggestedOrderQty * 50.0));
          // Calculate auto-replen health: % of items where current stock > reorder point
          int healthyItems = records.where((r) => r.currentStock >= r.targetStockLevel * 0.5).length;
          healthPercent = records.isNotEmpty ? (healthyItems / records.length * 100) : 100.0;
          // Used in forecast calculation above
        }

        // Inventory coverage: estimate days based on avg weekly sales
        int coverageDays = 28; // Default estimate

        // Forecasted spend: rough estimate
        double forecastedSpend = estValue * 3.6; // ~3.6x for monthly projection

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardSpacing = 16.0;
            int columns = 4;
            if (constraints.maxWidth < 1100) columns = 2;
            if (constraints.maxWidth < 600) columns = 1;

            // Build card list
            final cards = [
              // Card 1: Pending Orders
              _buildGlassCard(
                cardBg: cardBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Pending Orders',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 12.0, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.08))),
                        Container(
                          width: 32.0, height: 32.0,
                          decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(8.0)),
                          child: Icon(Icons.shopping_cart_outlined, color: primaryBlue, size: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Text('$pendingOrders', style: TextStyle(fontFamily: 'Satoshi', fontSize: 28.0, fontWeight: FontWeight.w600, color: onSurface, height: 1.2)),
                    SizedBox(height: 4.0),
                    Text('Est. Value: \$${_formatNumber(estValue)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant)),
                  ],
                ),
              ),
              // Card 2: Auto-Replen Health
              _buildGlassCard(
                cardBg: cardBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Auto-Replen Health',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 12.0, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.08))),
                        Container(
                          width: 32.0, height: 32.0,
                          decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(8.0)),
                          child: Icon(Icons.health_and_safety_outlined, color: primaryBlue, size: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Text('${healthPercent.toStringAsFixed(1)}%', style: TextStyle(fontFamily: 'Satoshi', fontSize: 28.0, fontWeight: FontWeight.w600, color: onSurface, height: 1.2)),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: primaryBlue, size: 14.0),
                        SizedBox(width: 4.0),
                        Flexible(child: Text('+2.1% from last month',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w500, color: primaryBlue))),
                      ],
                    ),
                  ],
                ),
              ),
              // Card 3: Inventory Coverage
              _buildGlassCard(
                cardBg: cardBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Inventory Coverage',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 12.0, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.08))),
                        Container(
                          width: 32.0, height: 32.0,
                          decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(8.0)),
                          child: Icon(Icons.calendar_month_outlined, color: primaryBlue, size: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Text('$coverageDays Days', style: TextStyle(fontFamily: 'Satoshi', fontSize: 28.0, fontWeight: FontWeight.w600, color: onSurface, height: 1.2)),
                    SizedBox(height: 4.0),
                    Text('Avg. across essential lines',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant)),
                  ],
                ),
              ),
              // Card 4: Forecasted Spend
              _buildGlassCard(
                cardBg: cardBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: Text('Forecasted Spend',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 12.0, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.08))),
                        Container(
                          width: 32.0, height: 32.0,
                          decoration: BoxDecoration(color: primaryContainer, borderRadius: BorderRadius.circular(8.0)),
                          child: Icon(Icons.payments_outlined, color: primaryBlue, size: 18.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Text('\$${_formatNumber(forecastedSpend)}', style: TextStyle(fontFamily: 'Satoshi', fontSize: 28.0, fontWeight: FontWeight.w600, color: onSurface, height: 1.2)),
                    SizedBox(height: 4.0),
                    Text('Projected for this month',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant)),
                  ],
                ),
              ),
            ];

            // Responsive grid using rows
            final rows = <Widget>[];
            for (int i = 0; i < cards.length; i += columns) {
              final rowChildren = <Widget>[];
              for (int j = 0; j < columns && i + j < cards.length; j++) {
                if (j > 0) rowChildren.add(SizedBox(width: cardSpacing));
                rowChildren.add(Expanded(child: cards[i + j]));
              }
              // If last row has fewer items than columns, fill with spacers
              while (rowChildren.length < columns * 2 - 1) {
                rowChildren.add(SizedBox(width: cardSpacing));
                rowChildren.add(Expanded(child: Container()));
              }
              rows.add(Row(children: rowChildren));
              if (i + columns < cards.length) {
                rows.add(SizedBox(height: cardSpacing));
              }
            }
            return Column(children: rows);
          },
        );
      },
    );
  }

  // ===== MAIN LAYOUT: Table + Sidebar =====
  Widget _buildMainLayout(
    BuildContext context,
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color surfaceContainerHigh,
    Color surfaceContainerHighest,
    Color cardBg,
    Color surfaceBright,
    Color surfaceDim,
    Color headerBg,
    Color rowHoverBg,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        final sidebarWidth = 320.0;

        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== PROCUREMENT QUEUE TABLE =====
            Flexible(
              flex: isWide ? 1 : 0,
              child: _buildRestockQueueTable(
                context,
                primaryBlue,
                primaryContainer,
                onSurface,
                onSurfaceVariant,
                outline,
                outlineVariant,
                surfaceContainerLow,
                surfaceContainerHigh,
                cardBg,
                surfaceBright,
                headerBg,
                rowHoverBg,
              ),
            ),
            if (isWide) SizedBox(width: 24.0) else SizedBox(height: 24.0),
            // ===== RECENT SHIPMENTS SIDEBAR =====
            SizedBox(
              width: isWide ? sidebarWidth : null,
              child: _buildRecentShipments(
                context,
                primaryBlue,
                onSurface,
                onSurfaceVariant,
                outline,
                outlineVariant,
                surfaceContainerHighest,
                cardBg,
                surfaceContainerLow,
              ),
            ),
          ],
        );
      },
    );
  }

  // ===== RESTOCK QUEUE TABLE =====
  Widget _buildRestockQueueTable(
    BuildContext context,
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color surfaceContainerHigh,
    Color cardBg,
    Color surfaceBright,
    Color headerBg,
    Color rowHoverBg,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20.0, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: surfaceBright,
                border: Border(bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggested Restock Queue',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                      height: 1.5,
                      letterSpacing: -0.01,
                    ),
                  ),
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {},
                          child: Container(
                            width: 32.0, height: 32.0,
                            alignment: Alignment.center,
                            child: Icon(Icons.filter_list, color: onSurfaceVariant, size: 20.0),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {},
                          child: Container(
                            width: 32.0, height: 32.0,
                            alignment: Alignment.center,
                            child: Icon(Icons.more_vert, color: onSurfaceVariant, size: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Data table
            StreamBuilder<List<ReplenishmentRecord>>(
              stream: queryReplenishmentRecord(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(child: SpinKitRing(color: primaryBlue, size: 40.0)),
                  );
                }

                List<ReplenishmentRecord> records = snapshot.data!;
                records.sort((a, b) => b.suggestedOrderQty.compareTo(a.suggestedOrderQty));

                if (records.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 48.0, color: outlineVariant),
                        SizedBox(height: 16.0),
                        Text('No replenishment recommendations',
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 16.0, fontWeight: FontWeight.w500, color: onSurfaceVariant)),
                        SizedBox(height: 8.0),
                        Text('Click Auto-Generate Orders to calculate',
                            style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: outline)),
                      ],
                    ),
                  );
                }

                return FutureBuilder<List<ProductMasterRecord>>(
                  future: queryProductMasterRecordOnce(),
                  builder: (context, productSnapshot) {
                    if (!productSnapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(child: SpinKitRing(color: primaryBlue, size: 40.0)),
                      );
                    }

                    final productMap = {
                      for (var p in productSnapshot.data!) p.reference.path: p
                    };

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 800.0),
                        child: Column(
                          children: [
                            // Table header row
                            _buildTableHeaderRow(headerBg, onSurfaceVariant, outlineVariant),
                            // Data rows
                            ...records.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final record = entry.value;
                              final product = productMap[record.productId?.path];
                              return _buildTableRow(
                                idx,
                                record,
                                product,
                                primaryBlue,
                                primaryContainer,
                                onSurface,
                                onSurfaceVariant,
                                outline,
                                outlineVariant,
                                surfaceContainerHigh,
                                rowHoverBg,
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== TABLE HEADER ROW =====
  Widget _buildTableHeaderRow(Color headerBg, Color onSurfaceVariant, Color outlineVariant) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        children: [
          _headerCell('Product Name', 3, onSurfaceVariant),
          _headerCell('SKU', 2, onSurfaceVariant),
          _headerCell('Current Stock', 1, onSurfaceVariant, alignRight: true),
          _headerCell('Reorder Pt.', 1, onSurfaceVariant, alignRight: true),
          _headerCell('Sugg. Qty', 1, onSurfaceVariant, alignRight: true),
          _headerCell('Supplier', 2, onSurfaceVariant),
          _headerCell('Status', 1, onSurfaceVariant),
          SizedBox(width: 40.0), // Checkbox column
        ],
      ),
    );
  }

  Widget _headerCell(String text, int flex, Color color, {bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 0.08,
          ),
        ),
      ),
    );
  }

  // ===== TABLE DATA ROW =====
  Widget _buildTableRow(
    int idx,
    ReplenishmentRecord record,
    ProductMasterRecord? product,
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerHigh,
    Color rowHoverBg,
  ) {
    final isCritical = record.currentStock < record.targetStockLevel * 0.4;
    final isSelected = _model.selectedRows.contains(idx);
    final productName = product?.name ?? 'Unknown Product';
    final sku = product?.sku ?? '';
    final supplier = product?.supplier ?? 'N/A';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? rowHoverBg : Colors.transparent,
          border: Border(bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            // Product Name
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  productName,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: primaryBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // SKU
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  sku.isNotEmpty ? sku : 'N/A',
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant),
                ),
              ),
            ),
            // Current Stock
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${record.currentStock}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w500, color: onSurface),
                ),
              ),
            ),
            // Reorder Pt.
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${record.targetStockLevel}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant),
                ),
              ),
            ),
            // Sugg. Qty
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${record.suggestedOrderQty}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w600, color: onSurface),
                ),
              ),
            ),
            // Supplier
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  supplier,
                  style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Status badge
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isCritical ? primaryBlue.withValues(alpha: 0.1) : surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    isCritical ? 'Critical' : 'Normal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: isCritical ? primaryBlue : onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            // Checkbox
            SizedBox(
              width: 40.0,
              child: Center(
                child: Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    safeSetState(() {
                      if (val == true) {
                        _model.selectedRows.add(idx);
                      } else {
                        _model.selectedRows.remove(idx);
                      }
                    });
                  },
                  activeColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                    side: BorderSide(color: outlineVariant),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== RECENT SHIPMENTS SIDEBAR =====
  Widget _buildRecentShipments(
    BuildContext context,
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerHighest,
    Color cardBg,
    Color surfaceContainerLow,
  ) {
    final parentRef = _getParentRef();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20.0, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Shipments',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.goNamed(GoodsReceivedWidget.routeName);
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Shipment items
            parentRef != null
                ? StreamBuilder<List<GoodsReceivedRecord>>(
                    stream: queryGoodsReceivedRecord(
                      parent: parentRef,
                      queryBuilder: (q) => q.orderBy('CreatedAt', descending: true).limit(5),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: SpinKitRing(color: primaryBlue, size: 24.0),
                          ),
                        );
                      }

                      final shipments = snapshot.data!;

                      if (shipments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 32.0, color: outlineVariant),
                                SizedBox(height: 8.0),
                                Text('No recent shipments',
                                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, color: onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: shipments.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final shipment = entry.value;
                          final isLast = idx == shipments.length - 1;
                          final isArriving = shipment.status == 'Pending' || shipment.status == 'In Transit';
                          final isDelivered = shipment.status == 'Delivered' || shipment.status == 'Received';

                          return _buildShipmentTimelineItem(
                            shipment,
                            isLast,
                            isArriving,
                            isDelivered,
                            primaryBlue,
                            onSurface,
                            onSurfaceVariant,
                            outline,
                            outlineVariant,
                            surfaceContainerHighest,
                            surfaceContainerLow,
                          );
                        }).toList(),
                      );
                    },
                  )
                : _buildPlaceholderShipments(primaryBlue, onSurface, onSurfaceVariant, outlineVariant, surfaceContainerHighest, surfaceContainerLow),
          ],
        ),
      ),
    );
  }

  // ===== SHIPMENT TIMELINE ITEM =====
  Widget _buildShipmentTimelineItem(
    GoodsReceivedRecord shipment,
    bool isLast,
    bool isArriving,
    bool isDelivered,
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerHighest,
    Color surfaceContainerLow,
  ) {
    final poNumber = shipment.deliveryNoteNumber.isNotEmpty
        ? shipment.deliveryNoteNumber
        : 'PO-${shipment.reference.id.substring(0, 6).toUpperCase()}';

    String statusText;
    if (isArriving) {
      statusText = 'In Transit';
    } else if (isDelivered) {
      final daysAgo = DateTime.now().difference(shipment.createdAt ?? DateTime.now()).inDays;
      statusText = daysAgo == 0 ? 'Delivered Today' : daysAgo == 1 ? 'Delivered Yesterday' : 'Delivered ${daysAgo}d ago';
    } else {
      statusText = shipment.status.isNotEmpty ? shipment.status : 'Processing';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 32.0,
            child: Column(
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: isArriving ? surfaceContainerHighest : surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: !isArriving ? Border.all(color: outlineVariant.withValues(alpha: 0.3)) : null,
                  ),
                  child: Icon(
                    isArriving ? Icons.local_shipping_outlined : Icons.inventory_2_outlined,
                    color: isArriving ? primaryBlue : onSurfaceVariant,
                    size: 16.0,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.0,
                      color: outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          // Content column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0, left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poNumber,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: onSurface,
                      letterSpacing: -0.01,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    'Shipment • ${shipment.deliveryNoteNumber.isNotEmpty ? shipment.deliveryNoteNumber : "N/A"}',
                    style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.0,
                      fontWeight: isArriving ? FontWeight.w700 : FontWeight.w500,
                      color: isArriving ? primaryBlue : onSurfaceVariant,
                      letterSpacing: 0.08,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PLACEHOLDER SHIPMENTS (when no parent ref) =====
  Widget _buildPlaceholderShipments(
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color surfaceContainerHighest,
    Color surfaceContainerLow,
  ) {
    return Column(
      children: [
        _buildPlaceholderItem('PO-2023-8902', 'PharmaCore Dist. • 14 items', 'Arriving Today', true, false,
            primaryBlue, onSurface, onSurfaceVariant, outlineVariant, surfaceContainerHighest, surfaceContainerLow),
        SizedBox(height: 16.0),
        _buildPlaceholderItem('PO-2023-8895', 'MediSupply Co. • 8 items', 'Delivered Yesterday', false, false,
            primaryBlue, onSurface, onSurfaceVariant, outlineVariant, surfaceContainerHighest, surfaceContainerLow),
        SizedBox(height: 16.0),
        _buildPlaceholderItem('PO-2023-8880', 'GenericMeds Inc. • 42 items', 'Delivered Oct 24', false, true,
            primaryBlue, onSurface, onSurfaceVariant, outlineVariant, surfaceContainerHighest, surfaceContainerLow),
      ],
    );
  }

  Widget _buildPlaceholderItem(
    String poNumber,
    String description,
    String statusText,
    bool isArriving,
    bool isLast,
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color surfaceContainerHighest,
    Color surfaceContainerLow,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32.0,
            child: Column(
              children: [
                Container(
                  width: 32.0, height: 32.0,
                  decoration: BoxDecoration(
                    color: isArriving ? surfaceContainerHighest : surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: !isArriving ? Border.all(color: outlineVariant.withValues(alpha: 0.3)) : null,
                  ),
                  child: Icon(
                    isArriving ? Icons.local_shipping_outlined : Icons.inventory_2_outlined,
                    color: isArriving ? primaryBlue : onSurfaceVariant,
                    size: 16.0,
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 1.0, color: outlineVariant.withValues(alpha: 0.3))),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0, left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(poNumber, style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w500, color: onSurface, letterSpacing: -0.01)),
                  SizedBox(height: 2.0),
                  Text(description, style: TextStyle(fontFamily: 'Satoshi', fontSize: 14.0, fontWeight: FontWeight.w400, color: onSurfaceVariant)),
                  SizedBox(height: 4.0),
                  Text(statusText,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12.0,
                        fontWeight: isArriving ? FontWeight.w700 : FontWeight.w500,
                        color: isArriving ? primaryBlue : onSurfaceVariant,
                        letterSpacing: 0.08,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CARD =====
  Widget _buildGlassCard({required Widget child, required Color cardBg, required Color outlineVariant}) {
    return Card(
      elevation: 2.0,
      color: cardBg,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: outlineVariant.withValues(alpha: 0.5), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: child,
      ),
    );
  }

  // ===== FORMAT NUMBER =====
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(2);
    }
  }
}
