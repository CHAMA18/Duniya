import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'stock_movements_model.dart';
export 'stock_movements_model.dart';

class StockMovementsWidget extends StatefulWidget {
  const StockMovementsWidget({super.key});

  static String routeName = 'StockMovements';
  static String routePath = '/stockMovements';

  @override
  State<StockMovementsWidget> createState() => _StockMovementsWidgetState();
}

class _StockMovementsWidgetState extends State<StockMovementsWidget> {
  late StockMovementsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPeriod = '24h';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StockMovementsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StockMovements'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    // Design tokens
    final surfaceBg = theme.primaryBackground;
    final cardBg = theme.secondaryBackground;
    final onSurface = theme.primaryText;
    final onSurfaceVariant = theme.secondaryText;
    final outlineVariant = theme.lineColor;
    final primaryColor = theme.primary;

    return Title(
      title: 'Stock Movements',
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
                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ═══ HEADER ═══
                              _buildPageHeader(
                                  context,
                                  theme,
                                  primaryColor,
                                  onSurface,
                                  onSurfaceVariant,
                                  outlineVariant,
                                  cardBg),
                              SizedBox(height: 24.0),

                              // ═══ EXECUTIVE METRICS (4 cards) ═══
                              _buildMetricCards(
                                  context,
                                  theme,
                                  primaryColor,
                                  onSurface,
                                  onSurfaceVariant,
                                  outlineVariant,
                                  cardBg),
                              SizedBox(height: 24.0),

                              // ═══ MAIN CONTENT: Analytics + Ledger ═══
                              // Analytics Chart
                              _buildAnalyticsChart(
                                  context,
                                  theme,
                                  primaryColor,
                                  onSurface,
                                  onSurfaceVariant,
                                  outlineVariant,
                                  cardBg),
                              SizedBox(height: 24.0),

                              // Movement Ledger Table
                              AuthUserStreamWidget(
                                builder: (context) =>
                                    StreamBuilder<List<StockMovementRecord>>(
                                  stream: queryStockMovementRecord(
                                    parent: valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference
                                        : currentUserDocument?.ownerRef,
                                    queryBuilder: (stockMovementRecord) =>
                                        stockMovementRecord.orderBy('CreatedAt',
                                            descending: true),
                                  ),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return _buildLoadingCard(
                                          cardBg, outlineVariant, theme);
                                    }
                                    List<StockMovementRecord> movements =
                                        snapshot.data!;
                                    // Apply filter
                                    if (_model.movementTypeValue != null &&
                                        _model.movementTypeValue != 'All') {
                                      movements = movements
                                          .where((m) =>
                                              m.movementType ==
                                              _model.movementTypeValue)
                                          .toList();
                                    }
                                    return FutureBuilder<
                                        List<ProductMasterRecord>>(
                                      future: queryProductMasterRecordOnce(),
                                      builder: (context, productSnapshot) {
                                        if (!productSnapshot.hasData) {
                                          return _buildLoadingCard(
                                              cardBg, outlineVariant, theme);
                                        }
                                        Map<String, ProductMasterRecord>
                                            productMap = {
                                          for (var p in productSnapshot.data!)
                                            p.reference.path: p
                                        };
                                        return _buildMovementLedger(
                                          context,
                                          movements,
                                          productMap,
                                          theme,
                                          primaryColor,
                                          onSurface,
                                          onSurfaceVariant,
                                          outlineVariant,
                                          cardBg,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 32.0),
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

  // ═══════════════════════════════════════════════════════════
  // PAGE HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildPageHeader(
    BuildContext context,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    return Card(
      elevation: 0,
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildHeaderLeft(
                      theme, primaryColor, onSurface, onSurfaceVariant),
                  _buildHeaderActions(context, theme, primaryColor, onSurface,
                      onSurfaceVariant, outlineVariant, cardBg),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderLeft(
                    theme, primaryColor, onSurface, onSurfaceVariant),
                SizedBox(height: 16.0),
                _buildHeaderActions(context, theme, primaryColor, onSurface,
                    onSurfaceVariant, outlineVariant, cardBg),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderLeft(FlutterFlowTheme theme, Color primaryColor,
      Color onSurface, Color onSurfaceVariant) {
    return Row(
      children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(Icons.swap_horiz, color: primaryColor, size: 22.0),
        ),
        SizedBox(width: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Movements',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: onSurface,
                letterSpacing: -0.02,
              ),
            ),
            Text(
              'Real-time tracking of all clinical inventory transitions.',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderActions(
    BuildContext context,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.end,
      children: [
        // Movement Type filter
        Container(
          width: 180.0,
          height: 44.0,
          child: FlutterFlowDropDown<String>(
            controller: _model.movementTypeValueController ??=
                FormFieldController<String>(null),
            options: ['All', 'RECEIVED', 'SOLD', 'TRANSFERRED', 'ADJUSTMENT'],
            onChanged: (val) =>
                safeSetState(() => _model.movementTypeValue = val),
            width: 180.0,
            height: 44.0,
            textStyle: theme.bodyMedium,
            hintText: 'Movement Type',
            fillColor: cardBg,
            borderColor: outlineVariant,
            borderRadius: 8.0,
            elevation: 2,
            borderWidth: 1.0,
            margin: EdgeInsets.zero,
          ),
        ),
        // Pharmacy filter
        AuthUserStreamWidget(
          builder: (context) => FutureBuilder<List<PharmacyRecord>>(
            future: queryPharmacyRecordOnce(
              parent: valueOrDefault(currentUserDocument?.role, '') == 'Owner'
                  ? currentUserReference
                  : currentUserDocument?.ownerRef,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: 180.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: outlineVariant),
                  ),
                  child: Center(
                      child: SpinKitRing(color: primaryColor, size: 16.0)),
                );
              }
              return Container(
                width: 180.0,
                height: 44.0,
                child: FlutterFlowDropDown<String>(
                  controller: _model.pharmacyValueController ??=
                      FormFieldController<String>(null),
                  options: snapshot.data!.map((p) => p.name).toList(),
                  onChanged: (val) =>
                      safeSetState(() => _model.pharmacyValue = val),
                  width: 180.0,
                  height: 44.0,
                  textStyle: theme.bodyMedium,
                  hintText: 'All Pharmacies',
                  fillColor: cardBg,
                  borderColor: outlineVariant,
                  borderRadius: 8.0,
                  elevation: 2,
                  borderWidth: 1.0,
                  margin: EdgeInsets.zero,
                ),
              );
            },
          ),
        ),
        // Add Movement button
        FFButtonWidget(
          onPressed: () => _showAddMovementDialog(context),
          text: 'Add Movement',
          icon: Icon(Icons.add, size: 16.0),
          options: FFButtonOptions(
            height: 44.0,
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
            color: primaryColor,
            textStyle: theme.titleSmall.override(
              fontFamily: theme.titleSmallFamily,
              color: Colors.white,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.titleSmallIsCustom,
            ),
            elevation: 0.0,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EXECUTIVE METRIC CARDS
  // ═══════════════════════════════════════════════════════════
  Widget _buildMetricCards(
    BuildContext context,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    final metrics = [
      _MetricData(
        icon: Icons.timeline,
        label: 'TOTAL MOVEMENTS (24H)',
        value: '1,248',
        detail: '+12.4% vs yesterday',
        detailIcon: Icons.trending_up,
        detailColor: primaryColor,
        accentColor: primaryColor.withValues(alpha: 0.08),
      ),
      _MetricData(
        icon: Icons.login,
        label: 'INCOMING STOCK',
        value: '452',
        detail: 'Pending verification: 24',
        detailIcon: Icons.info_outline,
        detailColor: primaryColor,
        accentColor: const Color(0xFF00C1FD).withValues(alpha: 0.08),
      ),
      _MetricData(
        icon: Icons.logout,
        label: 'OUTGOING STOCK',
        value: '680',
        detail: 'Mostly prescriptions',
        detailIcon: null,
        detailColor: onSurfaceVariant,
        accentColor: primaryColor.withValues(alpha: 0.06),
      ),
      _MetricData(
        icon: Icons.sync_alt,
        label: 'INTERNAL TRANSFERS',
        value: '116',
        detail: 'In transit: 12',
        detailIcon: Icons.local_shipping,
        detailColor: primaryColor,
        accentColor: theme.error.withValues(alpha: 0.06),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 4;
        if (constraints.maxWidth < 900) columns = 2;
        if (constraints.maxWidth < 500) columns = 1;

        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: metrics.map((m) {
            final width =
                (constraints.maxWidth - (columns - 1) * 16.0) / columns;
            return SizedBox(
              width: width,
              child: _buildMetricCard(m, theme, onSurface, onSurfaceVariant,
                  outlineVariant, cardBg),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricCard(
    _MetricData m,
    FlutterFlowTheme theme,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    return Card(
      elevation: 2.0,
      color: cardBg,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + icon
            Row(
              children: [
                Icon(m.icon, size: 14.0, color: onSurfaceVariant),
                SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    m.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.08,
                      color: onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            // Value
            Text(
              m.value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
                color: onSurface,
                letterSpacing: -0.04,
                height: 1.1,
              ),
            ),
            SizedBox(height: 8.0),
            // Detail
            Row(
              children: [
                if (m.detailIcon != null) ...[
                  Icon(m.detailIcon, size: 12.0, color: m.detailColor),
                  SizedBox(width: 4.0),
                ],
                Flexible(
                  child: Text(
                    m.detail,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: m.detailColor,
                      letterSpacing: -0.01,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ANALYTICS CHART
  // ═══════════════════════════════════════════════════════════
  Widget _buildAnalyticsChart(
    BuildContext context,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    return Card(
      elevation: 2.0,
      color: cardBg,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: outlineVariant.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: primaryColor, size: 20.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Movement Analytics',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        letterSpacing: -0.01,
                      ),
                    ),
                  ],
                ),
                // Period tabs
                Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: ['24h', '7d', '30d'].map((period) {
                      final isActive = _selectedPeriod == period;
                      return GestureDetector(
                        onTap: () =>
                            safeSetState(() => _selectedPeriod = period),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isActive ? cardBg : Colors.transparent,
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 2,
                                        offset: Offset(0, 1))
                                  ]
                                : null,
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11.0,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              letterSpacing: 0.08,
                              color: isActive ? onSurface : onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Bar chart
          Container(
            height: 220.0,
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: _buildBarChart(
                primaryColor, outlineVariant, onSurface, onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Color primaryColor, Color outlineVariant,
      Color onSurface, Color onSurfaceVariant) {
    final bars = [
      _BarData(height: 0.40, value: '120', isHighlight: false),
      _BarData(height: 0.60, value: '180', isHighlight: false),
      _BarData(height: 0.30, value: '90', isHighlight: false),
      _BarData(height: 0.80, value: '240', isHighlight: false),
      _BarData(height: 0.50, value: '150', isHighlight: true),
      _BarData(height: 0.70, value: '210', isHighlight: false),
      _BarData(height: 0.45, value: '135', isHighlight: false),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: bars.map((bar) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: constraints.maxHeight * bar.height * 0.85,
                      decoration: BoxDecoration(
                        color: bar.isHighlight
                            ? primaryColor
                            : outlineVariant.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(3.0)),
                        boxShadow: bar.isHighlight
                            ? [
                                BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2))
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MOVEMENT LEDGER TABLE
  // ═══════════════════════════════════════════════════════════
  Widget _buildMovementLedger(
    BuildContext context,
    List<StockMovementRecord> movements,
    Map<String, ProductMasterRecord> productMap,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
    Color cardBg,
  ) {
    if (movements.isEmpty) {
      return _buildEmptyState(theme, onSurfaceVariant);
    }

    // Pagination
    const pageSize = 10;
    final totalPages = (movements.length / pageSize).ceil();
    _model.currentPage ??= 1;
    final start = (_model.currentPage! - 1) * pageSize;
    final end = start + pageSize > movements.length
        ? movements.length
        : start + pageSize;
    final pageMovements = movements.sublist(start, end);

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2.0,
        color: cardBg,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: outlineVariant.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: primaryColor, size: 20.0),
                  SizedBox(width: 8.0),
                  Text(
                    'Movement Ledger',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                      letterSpacing: -0.01,
                    ),
                  ),
                ],
              ),
            ),
            // Table
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: _buildTable(
                      pageMovements,
                      productMap,
                      theme,
                      primaryColor,
                      onSurface,
                      onSurfaceVariant,
                      outlineVariant,
                    ),
                  ),
                );
              },
            ),
            // Pagination footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: outlineVariant.withValues(alpha: 0.2)),
                ),
                color: theme.primaryBackground.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${start + 1} to $end of ${movements.length} entries',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      color: onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      // Prev button
                      GestureDetector(
                        onTap: _model.currentPage! > 1
                            ? () => safeSetState(
                                  () => _model.currentPage =
                                      _model.currentPage! - 1,
                                )
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            color: _model.currentPage! > 1
                                ? null
                                : Colors.transparent,
                          ),
                          child: Icon(
                            Icons.chevron_left,
                            size: 16.0,
                            color: _model.currentPage! > 1
                                ? onSurfaceVariant
                                : onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      // Page numbers
                      ...List.generate(totalPages.clamp(1, 5), (i) {
                        final page = i + 1;
                        final isActive = page == _model.currentPage;
                        return GestureDetector(
                          onTap: () =>
                              safeSetState(() => _model.currentPage = page),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color:
                                  isActive ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              '$page',
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12.0,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color:
                                    isActive ? Colors.white : onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Next button
                      GestureDetector(
                        onTap: _model.currentPage! < totalPages
                            ? () => safeSetState(
                                  () => _model.currentPage =
                                      _model.currentPage! + 1,
                                )
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16.0,
                            color: _model.currentPage! < totalPages
                                ? onSurfaceVariant
                                : onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(
    List<StockMovementRecord> movements,
    Map<String, ProductMasterRecord> productMap,
    FlutterFlowTheme theme,
    Color primaryColor,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
  ) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(theme.primaryBackground),
      headingRowHeight: 44.0,
      dataRowMinHeight: 56.0,
      dataRowMaxHeight: 56.0,
      columnSpacing: 16.0,
      horizontalMargin: 24.0,
      columns: [
        DataColumn(
            label: Text('Date/Time', style: _headerStyle(onSurfaceVariant))),
        DataColumn(
            label: Text('Product', style: _headerStyle(onSurfaceVariant))),
        DataColumn(label: Text('Type', style: _headerStyle(onSurfaceVariant))),
        DataColumn(
            label: Text('Quantity', style: _headerStyle(onSurfaceVariant))),
        DataColumn(
            label: Text('Source / Destination',
                style: _headerStyle(onSurfaceVariant))),
        DataColumn(
            label: Text('Status', style: _headerStyle(onSurfaceVariant))),
      ],
      rows: movements.map((movement) {
        ProductMasterRecord? product = productMap[movement.productId?.path];
        final mType = movement.movementType;
        return DataRow(
          cells: [
            // Date/Time
            DataCell(Text(
              dateTimeFormat('MMM dd, hh:mm a', movement.createdAt,
                  locale: FFLocalizations.of(context).languageCode),
              style: _cellStyle(onSurfaceVariant),
            )),
            // Product with icon
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Icon(_getProductIcon(product?.name),
                      color: primaryColor, size: 16.0),
                ),
                SizedBox(width: 8.0),
                Flexible(
                    child: Text(
                  product?.name ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                  style: _cellStyle(onSurface, weight: FontWeight.w500),
                )),
              ],
            )),
            // Type
            DataCell(_buildTypeBadge(mType, primaryColor, onSurfaceVariant)),
            // Quantity
            DataCell(Text(
              '${mType == 'RECEIVED' ? '+' : '-'}${movement.quantity}',
              style: _cellStyle(
                mType == 'RECEIVED' ? primaryColor : onSurface,
                weight: FontWeight.w500,
              ),
            )),
            // Source/Destination
            DataCell(Text(
              movement.movementReference ?? movement.reason ?? '-',
              style: _cellStyle(onSurfaceVariant),
            )),
            // Status
            DataCell(_buildStatusBadge(
                mType, primaryColor, onSurfaceVariant, outlineVariant)),
          ],
        );
      }).toList(),
    );
  }

  TextStyle _headerStyle(Color color) => TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08,
        color: color,
      );

  TextStyle _cellStyle(Color color, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 13.0,
        fontWeight: weight,
        letterSpacing: -0.01,
        color: color,
      );

  Widget _buildTypeBadge(
      String type, Color primaryColor, Color onSurfaceVariant) {
    IconData icon;
    Color color;
    String label;
    switch (type) {
      case 'RECEIVED':
        icon = Icons.login;
        color = primaryColor;
        label = 'Incoming';
        break;
      case 'SOLD':
        icon = Icons.logout;
        color = onSurfaceVariant;
        label = 'Outgoing';
        break;
      case 'TRANSFERRED':
        icon = Icons.sync_alt;
        color = primaryColor;
        label = 'Transfer';
        break;
      case 'ADJUSTMENT':
        icon = Icons.tune;
        color = const Color(0xFFF59E0B);
        label = 'Adjustment';
        break;
      default:
        icon = Icons.swap_horiz;
        color = onSurfaceVariant;
        label = type;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.0, color: color),
        SizedBox(width: 4.0),
        Text(label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: color,
            )),
      ],
    );
  }

  Widget _buildStatusBadge(String type, Color primaryColor,
      Color onSurfaceVariant, Color outlineVariant) {
    // COMPLETED for RECEIVED/SOLD/ADJUSTMENT, IN TRANSIT for TRANSFERRED
    if (type == 'TRANSFERRED') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text('IN TRANSIT',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.04,
              color: onSurfaceVariant,
            )),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text('COMPLETED',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.04,
            color: primaryColor,
          )),
    );
  }

  IconData _getProductIcon(String? name) {
    if (name == null) return Icons.medication;
    final lower = name.toLowerCase();
    if (lower.contains('caps') || lower.contains('tablet'))
      return Icons.vaccines;
    if (lower.contains('susp') ||
        lower.contains('syrup') ||
        lower.contains('liquid')) return Icons.medication_liquid;
    if (lower.contains('cream') || lower.contains('oint')) return Icons.healing;
    if (lower.contains('inject')) return Icons.vaccines;
    if (lower.contains('gauze') ||
        lower.contains('pad') ||
        lower.contains('bandage')) return Icons.healing;
    return Icons.medication;
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState(FlutterFlowTheme theme, Color onSurfaceVariant) {
    return Card(
      elevation: 2.0,
      color: theme.secondaryBackground,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: theme.lineColor.withValues(alpha: 0.3), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        height: 300.0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz,
                  size: 64.0, color: onSurfaceVariant.withValues(alpha: 0.4)),
              SizedBox(height: 16.0),
              Text(
                'No stock movements found',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Add a movement to get started.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.0,
                  color: onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LOADING STATE
  // ═══════════════════════════════════════════════════════════
  Widget _buildLoadingCard(
      Color cardBg, Color outlineVariant, FlutterFlowTheme theme) {
    return Card(
      elevation: 2.0,
      color: cardBg,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: outlineVariant.withValues(alpha: 0.3), width: 0.5),
      ),
      margin: EdgeInsets.zero,
      child: Container(
        height: 300.0,
        child: Center(child: SpinKitRing(color: theme.primary, size: 32.0)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ADD MOVEMENT DIALOG (retained from original)
  // ═══════════════════════════════════════════════════════════
  void _showAddMovementDialog(BuildContext context) {
    _model.dialogQtyTextController ??= TextEditingController();
    _model.dialogReasonTextController ??= TextEditingController();
    _model.dialogReferenceTextController ??= TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Stock Movement'),
          content: Container(
            width:
                MediaQuery.sizeOf(context).width > 500 ? 500 : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<List<ProductMasterRecord>>(
                    stream: queryProductMasterRecord(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SpinKitRing(
                            color: FlutterFlowTheme.of(context).primary,
                            size: 20.0);
                      }
                      return FlutterFlowDropDown<String>(
                        controller: _model.dialogProductValueController ??=
                            FormFieldController<String>(null),
                        options: snapshot.data!.map((p) => p.name).toList(),
                        onChanged: (val) =>
                            safeSetState(() => _model.dialogProductValue = val),
                        width: double.infinity,
                        height: 44.0,
                        textStyle: FlutterFlowTheme.of(context).bodyMedium,
                        hintText: 'Select Product',
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        borderColor: FlutterFlowTheme.of(context).alternate,
                        borderRadius: 8.0,
                        elevation: 2,
                        borderWidth: 1.0,
                        margin: EdgeInsets.zero,
                      );
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogQtyTextController,
                    focusNode: _model.dialogQtyFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    keyboardType: TextInputType.number,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  FlutterFlowDropDown<String>(
                    controller: _model.dialogMovementTypeValueController ??=
                        FormFieldController<String>(null),
                    options: ['RECEIVED', 'SOLD', 'TRANSFERRED', 'ADJUSTMENT'],
                    onChanged: (val) => safeSetState(
                        () => _model.dialogMovementTypeValue = val),
                    width: double.infinity,
                    height: 44.0,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium,
                    hintText: 'Movement Type',
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    borderColor: FlutterFlowTheme.of(context).alternate,
                    borderRadius: 8.0,
                    elevation: 2,
                    borderWidth: 1.0,
                    margin: EdgeInsets.zero,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogReasonTextController,
                    focusNode: _model.dialogReasonFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Reason (optional)',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogReferenceTextController,
                    focusNode: _model.dialogReferenceFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Reference (optional)',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FFButtonWidget(
              onPressed: () async {
                final products = await queryProductMasterRecordOnce();
                final product = products.firstWhere(
                  (p) => p.name == _model.dialogProductValue,
                  orElse: () => products.first,
                );
                final ownerRef =
                    valueOrDefault(currentUserDocument?.role, '') == 'Owner'
                        ? currentUserReference!
                        : currentUserDocument!.ownerRef!;
                await StockMovementRecord.createDoc(ownerRef)
                    .set(createStockMovementRecordData(
                  productId: product.reference,
                  quantity: int.tryParse(
                          _model.dialogQtyTextController?.text ?? '0') ??
                      0,
                  movementType: _model.dialogMovementTypeValue,
                  reason: _model.dialogReasonTextController?.text,
                  movementReference: _model.dialogReferenceTextController?.text,
                  recordedById: currentUserReference,
                  createdAt: getCurrentTimestamp,
                ));
                _model.dialogQtyTextController?.clear();
                _model.dialogReasonTextController?.clear();
                _model.dialogReferenceTextController?.clear();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Stock movement recorded successfully')),
                );
              },
              text: 'Save',
              options: FFButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      color: Colors.white,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DATA HELPERS
// ═══════════════════════════════════════════════════════════
class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final IconData? detailIcon;
  final Color detailColor;
  final Color accentColor;
  _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.detailIcon,
    required this.detailColor,
    required this.accentColor,
  });
}

class _BarData {
  final double height;
  final String value;
  final bool isHighlight;
  _BarData(
      {required this.height, required this.value, required this.isHighlight});
}
