import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/damaged_stock/damaged_stock_widget.dart';
import '/unification/components/sale_details/sale_details_widget.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/switch_pharm_stock/switch_pharm_stock_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'inventory_details_model.dart';
export 'inventory_details_model.dart';

/// Product Detail page — redesigned for world-class UI.
///
/// Layout:
/// 1. Breadcrumb (Inventory / Products / {name})
/// 2. Hero header (title + stock status badge + metadata chips + action buttons)
/// 3. Finances section (4 responsive stat cards with semantic icons)
/// 4. Recent Transactions card (purple table header, zebra rows, hover, ID
///    truncation, formatted dates, empty state, View All link)
/// 5. Damaged Goods card (consistent purple table header, empty state with
///    "All goods accounted for")
///
/// Visual: brand-purple accent throughout, soft elevation shadows, staggered
/// fade-up entry animation on stat cards, responsive breakpoints at 600 / 1000.
class InventoryDetailsWidget extends StatefulWidget {
  const InventoryDetailsWidget({
    super.key,
    required this.stock,
  });

  final DocumentReference? stock;

  static String routeName = 'InventoryDetails';
  static String routePath = '/inventoryDetails';

  @override
  State<InventoryDetailsWidget> createState() => _InventoryDetailsWidgetState();
}

class _InventoryDetailsWidgetState extends State<InventoryDetailsWidget>
    with TickerProviderStateMixin {
  late InventoryDetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _entryController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InventoryDetailsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'InventoryDetails'});

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entryController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StockRecord>(
      stream: StockRecord.getDocument(widget.stock!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: _buildLoadingBody(context),
          );
        }
        final stock = snapshot.data!;

        return Title(
          title: '${stock.name} • Product Details',
          color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              appBar: responsiveVisibility(
                context: context,
                tablet: false,
                tabletLandscape: false,
                desktop: false,
              )
                  ? AppBar(
                      backgroundColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      automaticallyImplyLeading: false,
                      leading: FlutterFlowIconButton(
                        borderColor: Colors.transparent,
                        borderRadius: 30.0,
                        borderWidth: 1.0,
                        buttonSize: 60.0,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: FlutterFlowTheme.of(context).secondary,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          logFirebaseEvent(
                              'INVENTORY_DETAILS_chevron_left_rounded_I');
                          logFirebaseEvent('IconButton_navigate_back');
                          context.pop();
                        },
                      ),
                      title: Text(
                        '${stock.name} Details',
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: FlutterFlowTheme.of(context)
                                  .headlineMediumFamily,
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .headlineMediumIsCustom,
                            ),
                      ),
                      actions: [],
                      centerTitle: true,
                      elevation: 0.0,
                    )
                  : null,
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
                          if (responsiveVisibility(
                            context: context,
                            phone: false,
                            tablet: false,
                            tabletLandscape: false,
                          ))
                            wrapWithModel(
                              model: _model.topNavModel,
                              updateCallback: () => safeSetState(() {}),
                              child: TopNavWidget(openDrawer: () async {}),
                            ),
                          Expanded(
                            child: FadeTransition(
                              opacity: _fade,
                              child: SingleChildScrollView(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 20.0, 24.0, 40.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                    ))
                                      _buildBreadcrumb(context, stock),
                                    if (responsiveVisibility(
                                      context: context,
                                      phone: false,
                                    ))
                                      const SizedBox(height: 16.0),
                                    _buildHeader(context, stock),
                                    const SizedBox(height: 32.0),
                                    _buildSectionTitle(context, 'Finances'),
                                    const SizedBox(height: 12.0),
                                    _buildFinancesSection(context, stock),
                                    const SizedBox(height: 32.0),
                                    _buildRecentTransactionsCard(
                                        context, stock),
                                    const SizedBox(height: 32.0),
                                    _buildDamagedGoodsCard(context, stock),
                                  ],
                                ),
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
      },
    );
  }

  // ===== Loading state =====
  Widget _buildLoadingBody(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 100.0,
        height: 100.0,
        child: SpinKitRing(
          color: FlutterFlowTheme.of(context).primary,
          size: 100.0,
        ),
      ),
    );
  }

  // ===== Breadcrumb =====
  Widget _buildBreadcrumb(BuildContext context, StockRecord stock) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            logFirebaseEvent('INVENTORY_DETAILS_breadcrumb_inventory');
            context.goNamed('StoreInventory');
          },
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(
              'Inventory',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        ),
        Icon(Icons.chevron_right_rounded, size: 16.0, color: theme.secondaryText),
        InkWell(
          onTap: () async {
            logFirebaseEvent('INVENTORY_DETAILS_breadcrumb_products');
            context.goNamed('StoreInventory');
          },
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: Text(
              'Products',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        ),
        Icon(Icons.chevron_right_rounded, size: 16.0, color: theme.secondaryText),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240.0),
            child: Text(
              stock.name,
              overflow: TextOverflow.ellipsis,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.primaryText,
                fontSize: 13.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===== Header =====
  Widget _buildHeader(BuildContext context, StockRecord stock) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 760.0;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroTitle(context, stock),
              const SizedBox(height: 10.0),
              _buildStatusBadge(context, stock),
              const SizedBox(height: 16.0),
              _buildMetadataChips(context, stock),
              const SizedBox(height: 20.0),
              _buildActionButtons(context, stock, wrap: true),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroTitle(context, stock),
                  const SizedBox(height: 10.0),
                  _buildStatusBadge(context, stock),
                  const SizedBox(height: 16.0),
                  _buildMetadataChips(context, stock),
                ],
              ),
            ),
            const SizedBox(width: 24.0),
            _buildActionButtons(context, stock, wrap: false),
          ],
        );
      },
    );
  }

  Widget _buildHeroTitle(BuildContext context, StockRecord stock) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      stock.name,
      style: theme.displaySmall.override(
        fontFamily: theme.displaySmallFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        useGoogleFonts: !theme.displaySmallIsCustom,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, StockRecord stock) {
    final theme = FlutterFlowTheme.of(context);
    final current = stock.quantity;
    final initial = stock.initialQuantity.toInt();
    Color bg, fg, dot;
    String label;
    if (current == 0) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      dot = const Color(0xFFDC2626);
      label = 'Out of Stock';
    } else if (initial > 0 && current <= (initial * 0.2).round()) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
      dot = const Color(0xFFF59E0B);
      label = 'Low Stock';
    } else {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
      dot = const Color(0xFF16A34A);
      label = 'In Stock';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: fg,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChips(BuildContext context, StockRecord stock) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _metaChip(
          context,
          icon: Icons.inventory_2_outlined,
          label: 'Batch Number',
          value: stock.batchNumber,
        ),
        _metaChip(
          context,
          icon: Icons.event_outlined,
          label: 'Expiry Date',
          value: dateTimeFormat(
            'yMMMd',
            stock.expiryDate,
            locale: FFLocalizations.of(context).languageCode,
          ),
        ),
        _metaChip(
          context,
          icon: Icons.local_pharmacy_outlined,
          label: 'Pharmacy',
          value: stock.pharmacy,
        ),
      ],
    );
  }

  Widget _metaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: theme.secondaryText),
          const SizedBox(width: 6.0),
          Text(
            '$label:',
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: theme.secondaryText,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(width: 4.0),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200.0),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: theme.labelSmall.override(
                fontFamily: theme.labelSmallFamily,
                color: theme.primaryText,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.labelSmallIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Action Buttons =====
  Widget _buildActionButtons(
    BuildContext context,
    StockRecord stock, {
    required bool wrap,
  }) {
    final specs = <_ActionButtonSpec>[
      _ActionButtonSpec(
        label: 'Edit Product',
        icon: Icons.edit_rounded,
        variant: _ButtonVariant.primary,
        onPressed: () async {
          logFirebaseEvent('INVENTORY_DETAILS_edit_product_btn');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Edit Product form coming soon'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: FlutterFlowTheme.of(context).primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      _ActionButtonSpec(
        label: 'Switch Pharmacy',
        icon: Icons.swap_horiz_rounded,
        variant: _ButtonVariant.outlined,
        onPressed: () async {
          logFirebaseEvent('INVENTORY_DETAILS_switch_pharmacy_btn');
          await showDialog(
            context: context,
            builder: (dialogContext) => Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              alignment: AlignmentDirectional(0.0, 0.0)
                  .resolve(Directionality.of(context)),
              child: WebViewAware(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(dialogContext).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: SwitchPharmStockWidget(stockId: widget.stock!),
                ),
              ),
            ),
          );
        },
      ),
      _ActionButtonSpec(
        label: 'Report Damage',
        icon: Icons.warning_amber_rounded,
        variant: _ButtonVariant.ghostDanger,
        onPressed: () async {
          logFirebaseEvent('INVENTORY_DETAILS_report_damage_btn');
          await showDialog(
            context: context,
            builder: (dialogContext) => Dialog(
              elevation: 0,
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              alignment: AlignmentDirectional(0.0, 0.0)
                  .resolve(Directionality.of(context)),
              child: WebViewAware(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(dialogContext).unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: DamagedStockWidget(stockId: widget.stock!),
                ),
              ),
            ),
          );
        },
      ),
    ];

    final theme = FlutterFlowTheme.of(context);
    final items = specs
        .map((s) => _buildActionButton(context, s, theme))
        .toList();

    if (wrap) {
      return Wrap(spacing: 10.0, runSpacing: 10.0, children: items);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: items
          .map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: b,
              ))
          .toList(),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    _ActionButtonSpec spec,
    FlutterFlowTheme theme,
  ) {
    Color bg, fg, border, shadow;
    double elevation;
    switch (spec.variant) {
      case _ButtonVariant.primary:
        bg = theme.primary;
        fg = Colors.white;
        border = Colors.transparent;
        shadow = theme.primary.withAlpha(60);
        elevation = 2.0;
        break;
      case _ButtonVariant.outlined:
        bg = Colors.transparent;
        fg = theme.primary;
        border = theme.primary.withAlpha(140);
        shadow = Colors.transparent;
        elevation = 0.0;
        break;
      case _ButtonVariant.ghostDanger:
        bg = Colors.transparent;
        fg = theme.error;
        border = theme.error.withAlpha(80);
        shadow = Colors.transparent;
        elevation = 0.0;
        break;
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8.0),
      elevation: elevation,
      shadowColor: shadow,
      child: InkWell(
        onTap: spec.onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: border, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(spec.icon, size: 16.0, color: fg),
              const SizedBox(width: 8.0),
              Text(
                spec.label,
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: fg,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Section title =====
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      title,
      style: theme.displaySmall.override(
        fontFamily: theme.displaySmallFamily,
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.displaySmallIsCustom,
      ),
    );
  }

  // ===== Finances section =====
  Widget _buildFinancesSection(BuildContext context, StockRecord stock) {
    final theme = FlutterFlowTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const spacing = 12.0;

        final cards = <Widget>[
          _buildFinanceCard(
            context,
            label: 'Initial Quantity',
            value: stock.initialQuantity.toInt().toString(),
            icon: Icons.inventory_2_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconFg: theme.primary,
            delayMs: 0,
          ),
          _buildFinanceCard(
            context,
            label: 'Current Quantity',
            value: stock.quantity.toString(),
            icon: Icons.layers_rounded,
            iconBg: const Color(0xFFF5F3FF),
            iconFg: theme.primary,
            delayMs: 50,
          ),
          FutureBuilder<int>(
            future: querySaleitemRecordCount(
              queryBuilder: (saleitemRecord) =>
                  saleitemRecord.where('StockID', isEqualTo: widget.stock),
            ),
            builder: (context, snapshot) {
              final waiting = snapshot.connectionState ==
                  ConnectionState.waiting;
              return _buildFinanceCard(
                context,
                label: 'Total Sales',
                value: waiting ? '—' : (snapshot.data ?? 0).toString(),
                icon: Icons.receipt_long_rounded,
                iconBg: const Color(0xFFF5F3FF),
                iconFg: theme.primary,
                delayMs: 100,
              );
            },
          ),
          _buildFinanceCard(
            context,
            label: 'Damaged Reports',
            value: stock.damagedGoods.toInt().toString(),
            icon: Icons.warning_amber_rounded,
            iconBg: const Color(0xFFFFE4E6),
            iconFg: const Color(0xFFE11D48),
            delayMs: 150,
          ),
        ];

        if (width < 600.0) {
          return Column(
            children: cards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: spacing),
                      child: c,
                    ))
                .toList(),
          );
        }
        if (width < 1000.0) {
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: cards
                .map((c) => SizedBox(
                      width: (width - spacing) / 2.0,
                      child: c,
                    ))
                .toList(),
          );
        }
        return Row(
          children: cards
              .expand((c) => [Expanded(child: c), const SizedBox(width: spacing)])
              .toList()
            ..removeLast(),
        );
      },
    );
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required int delayMs,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0.0, (1.0 - v) * 8.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: theme.primary.withAlpha(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B21A8).withAlpha(15),
              blurRadius: 16.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: iconFg, size: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              label,
              style: theme.labelMedium.override(
                fontFamily: theme.labelMediumFamily,
                color: theme.secondaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.labelMediumIsCustom,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: theme.displaySmall.override(
                fontFamily: theme.displaySmallFamily,
                fontSize: 28.0,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                useGoogleFonts: !theme.displaySmallIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Recent Transactions card =====
  Widget _buildRecentTransactionsCard(
    BuildContext context,
    StockRecord stock,
  ) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, 'Recent Transactions'),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Full sales history coming soon'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: theme.labelMedium.override(
                        fontFamily: theme.labelMediumFamily,
                        color: theme.primary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelMediumIsCustom,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 14.0, color: theme.primary),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: theme.alternate, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B21A8).withAlpha(15),
                blurRadius: 16.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              children: [
                _buildTableHeaderRow(
                  context,
                  columns: ['Sales ID', 'Pharmacy', 'Items', 'Date'],
                  flexes: const [2, 2, 1, 2],
                  centerFlex: const [2, 3],
                ),
                AuthUserStreamWidget(
                  builder: (context) => PagedListView<
                      DocumentSnapshot<Object?>?, SaleitemRecord>(
                    pagingController: _model.setListViewController1(
                      SaleitemRecord.collection(
                              AccessControl.parentRef(context) ??
                                  currentUserReference)
                          .where('StockID', isEqualTo: widget.stock),
                      parent: AccessControl.parentRef(context),
                    ),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    reverse: false,
                    scrollDirection: Axis.vertical,
                    builderDelegate:
                        PagedChildBuilderDelegate<SaleitemRecord>(
                      firstPageProgressIndicatorBuilder: (_) =>
                          _buildTableLoading(context),
                      newPageProgressIndicatorBuilder: (_) =>
                          _buildTableLoading(context),
                      noItemsFoundIndicatorBuilder: (_) => _buildEmptyState(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: 'No sales yet',
                        subtitle:
                            'Sales for this product will appear here once recorded',
                      ),
                      itemBuilder: (context, _, listViewIndex) {
                        final listViewSaleitemRecord = _model
                            .listViewPagingController1!
                            .itemList![listViewIndex];
                        final rowBg = listViewIndex.isEven
                            ? theme.secondaryBackground
                            : const Color(0xFFFAFAFC);
                        return Container(
                          color: rowBg,
                          child: StreamBuilder<SalesRecord>(
                            stream: SalesRecord.getDocument(
                                listViewSaleitemRecord.saleID!),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return _buildRowShimmer(context, rowBg);
                              }
                              final sale = snapshot.data!;
                              return SaleDetailsWidget(
                                key: Key('Key3v0_${listViewIndex}_of_${_model
                                    .listViewPagingController1!
                                    .itemList!
                                    .length}'),
                                parameter1:
                                    listViewSaleitemRecord.quantity.toString(),
                                parameter2: sale.date!.toIso8601String(),
                                saleId: listViewSaleitemRecord.stockID!.id,
                                pharmacy: sale.pharmaID!,
                                rowBg: rowBg,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderRow(
    BuildContext context, {
    required List<String> columns,
    required List<int> flexes,
    List<int> centerFlex = const [],
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: List.generate(columns.length, (i) {
          final center = centerFlex.contains(i);
          return Expanded(
            flex: flexes[i],
            child: Text(
              columns[i],
              textAlign: center ? TextAlign.center : TextAlign.left,
              style: theme.labelMedium.override(
                fontFamily: theme.labelMediumFamily,
                color: Colors.white,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                useGoogleFonts: !theme.labelMediumIsCustom,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTableLoading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: ShimmerLoadingCardWidget(),
    );
  }

  Widget _buildRowShimmer(BuildContext context, Color bg) {
    return Container(
      color: bg,
      padding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: ShimmerLoadingCardWidget(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40.0,
            color: iconColor ?? theme.secondaryText.withAlpha(140),
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.primaryText,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Damaged Goods card =====
  Widget _buildDamagedGoodsCard(BuildContext context, StockRecord stock) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Damaged Goods'),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: theme.alternate, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B21A8).withAlpha(15),
                blurRadius: 16.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              children: [
                _buildTableHeaderRow(
                  context,
                  columns: ['#', 'Quantity', 'Description'],
                  flexes: const [1, 1, 4],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AuthUserStreamWidget(
                    builder: (context) =>
                        StreamBuilder<List<DamagedStockRecord>>(
                      stream: queryDamagedStockRecord(
                        parent: AccessControl.parentRef(context),
                        queryBuilder: (damagedStockRecord) =>
                            damagedStockRecord.where(
                          'StockId',
                          isEqualTo: widget.stock,
                        ),
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            width: double.infinity,
                            height: 50.0,
                            color: theme.secondaryBackground,
                            child: ShimmerLoadingCardWidget(),
                          );
                        }
                        final list = snapshot.data!;
                        if (list.isEmpty) {
                          return _buildEmptyState(
                            context,
                            icon: Icons.verified_rounded,
                            iconColor: const Color(0xFF16A34A),
                            title: 'All goods accounted for',
                            subtitle:
                                'No damaged items reported for this product',
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1.0, color: theme.alternate),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final rowBg = index.isEven
                                ? theme.secondaryBackground
                                : const Color(0xFFFAFAFC);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12.0),
                              color: rowBg,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${index + 1}',
                                      style: theme.bodyMedium.override(
                                        fontFamily: theme.bodyMediumFamily,
                                        color: theme.primaryText,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !theme.bodyMediumIsCustom,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      item.quantity.toString(),
                                      style: theme.bodyMedium.override(
                                        fontFamily: theme.bodyMediumFamily,
                                        color: theme.primaryText,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !theme.bodyMediumIsCustom,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.description,
                                      style: theme.bodyMedium.override(
                                        fontFamily: theme.bodyMediumFamily,
                                        color: theme.primaryText,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !theme.bodyMediumIsCustom,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Action button spec =====
enum _ButtonVariant { primary, outlined, ghostDanger }

class _ActionButtonSpec {
  final String label;
  final IconData icon;
  final _ButtonVariant variant;
  final Future<void> Function() onPressed;

  const _ActionButtonSpec({
    required this.label,
    required this.icon,
    required this.variant,
    required this.onPressed,
  });
}
