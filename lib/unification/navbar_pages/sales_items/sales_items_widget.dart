import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/rbac/rbac.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/no_record_component/no_record_component_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'sales_items_model.dart';
export 'sales_items_model.dart';

class SalesItemsWidget extends StatefulWidget {
  const SalesItemsWidget({
    super.key,
    required this.sale,
  });

  final DocumentReference? sale;

  static String routeName = 'SalesItems';
  static String routePath = '/salesItems';

  @override
  State<SalesItemsWidget> createState() => _SalesItemsWidgetState();
}

class _SalesItemsWidgetState extends State<SalesItemsWidget> {
  late SalesItemsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SalesItemsModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'SalesItems'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Guard against deep-link navigation without a `sale` query param.
    if (widget.sale == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          title: const Text('Sale items'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No sale selected',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                        useGoogleFonts: false,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Open a sale from the Sales list to view its line items.',
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return StreamBuilder<SalesRecord>(
      stream: SalesRecord.getDocument(widget.sale!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 100.0,
                height: 100.0,
                child: SpinKitRing(
                  color: FlutterFlowTheme.of(context).primary,
                  size: 100.0,
                ),
              ),
            ),
          );
        }

        final salesItemsSalesRecord = snapshot.data!;

        return Title(
            title: 'Sales',
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
                                  logFirebaseEvent(
                                      'SALES_ITEMS_Container_vsp18hmm_CALLBACK');
                                  logFirebaseEvent('TopNav_drawer');
                                  scaffoldKey.currentState!.openDrawer();
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Page header: title + transaction chip ──
                                    _pageHeader(salesItemsSalesRecord),

                                    // ── Summary hero card ──
                                    _saleSummaryCard(salesItemsSalesRecord),

                                    // ── Products card ──
                                    _productsCard(salesItemsSalesRecord),

]
                                      .divide(SizedBox(height: 16.0))
                                      .around(SizedBox(height: 16.0)),
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
            ));
      },
    );
  }
  // ═══════════════════════════════════════════════════════════════
  //  SALE DETAIL — premium layout builders
  // ═══════════════════════════════════════════════════════════════

  static const Color _accent = Color(0xFF9900FF);

  /// Page header — title plus a transaction-ID chip so the sale can be
  /// referenced from paper records.
  Widget _pageHeader(SalesRecord sale) {
    final theme = FlutterFlowTheme.of(context);
    final shortId = sale.reference.id.length >= 6
        ? sale.reference.id.substring(0, 6).toUpperCase()
        : sale.reference.id.toUpperCase();
    return Row(
      children: [
        Expanded(
          child: Text(
            'Sale Details',
            style: theme.displaySmall.override(
              fontFamily: theme.displaySmallFamily,
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              useGoogleFonts: !theme.displaySmallIsCustom,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9999.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 14.0, color: theme.primary),
              const SizedBox(width: 6.0),
              Text(
                'TXN-$shortId',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: theme.primary,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// One label/value pair with a leading icon for the summary card.
  Widget _summaryTile(IconData icon, String label, Widget value) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34.0,
          height: 34.0,
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9.0),
          ),
          child:
              Icon(icon, size: 17.0, color: theme.primary),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: theme.secondaryText,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
              const SizedBox(height: 2.0),
              value,
            ],
          ),
        ),
      ],
    );
  }

  /// Small value text used inside summary tiles.
  Widget _summaryValue(String text) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      text,
      style: theme.bodyMedium.override(
        fontFamily: theme.bodyMediumFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: theme.primaryText,
        useGoogleFonts: !theme.bodyMediumIsCustom,
      ),
    );
  }

  /// Compact loading placeholder for the summary tiles (replaces the
  /// old 100px spinners that broke the card layout while loading).
  Widget _summaryValueLoading() {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      '…',
      style: theme.bodyMedium.override(
        fontFamily: theme.bodyMediumFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: theme.secondaryText,
        useGoogleFonts: !theme.bodyMediumIsCustom,
      ),
    );
  }

  /// Payment-method badge — icon + label; Mobile Money shows the
  /// provider (Zamtel / Airtel / MTN) when recorded.
  Widget _paymentBadge(SalesRecord sale) {
    final theme = FlutterFlowTheme.of(context);
    final pm = sale.paymentMethod ?? 'Cash';
    final provider = sale.mobileMoneyProvider;

    IconData icon;
    String label;
    switch (pm) {
      case 'Card':
        icon = Icons.credit_card_rounded;
        label = 'Card';
        break;
      case 'MobileMoney':
        icon = Icons.phone_android_rounded;
        label = provider ?? 'Mobile Money';
        break;
      default:
        icon = Icons.payments_rounded;
        label = 'Cash';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9999.0),
        border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.35),
            width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: const Color(0xFF059669)),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF059669),
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  /// Summary hero card — who / when / where on the left, the money on
  /// the right. Replaces the old flat same-size "Label: value" text
  /// block that had no hierarchy.
  Widget _saleSummaryCard(SalesRecord sale) {
    final theme = FlutterFlowTheme.of(context);
    final dateText =
        '${dateTimeFormat("yMMMd", sale.date, locale: FFLocalizations.of(context).languageCode)}'
        ' · ${dateTimeFormat("Hm", sale.date, locale: FFLocalizations.of(context).languageCode)}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: transaction metadata
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<PharmacyRecord>(
                    stream: sale.pharmaID != null
                        ? PharmacyRecord.getDocument(sale.pharmaID!)
                        : null,
                    builder: (context, snapshot) {
                      if (sale.pharmaID == null) {
                        return _summaryTile(Icons.local_pharmacy_rounded,
                            'Pharmacy', _summaryValue('—'));
                      }
                      if (!snapshot.hasData) {
                        return _summaryTile(Icons.local_pharmacy_rounded,
                            'Pharmacy', _summaryValueLoading());
                      }
                      return _summaryTile(Icons.local_pharmacy_rounded,
                          'Pharmacy', _summaryValue(snapshot.data!.name));
                    },
                  ),
                  const SizedBox(height: 14.0),
                  _summaryTile(
                      Icons.schedule_rounded, 'Date', _summaryValue(dateText)),
                  const SizedBox(height: 14.0),
                  StreamBuilder<UserRecord>(
                    stream: sale.userID != null
                        ? UserRecord.getDocument(sale.userID!)
                        : null,
                    builder: (context, snapshot) {
                      if (sale.userID == null) {
                        return _summaryTile(Icons.person_rounded, 'Cashier',
                            _summaryValue('—'));
                      }
                      if (!snapshot.hasData) {
                        return _summaryTile(Icons.person_rounded, 'Cashier',
                            _summaryValueLoading());
                      }
                      return _summaryTile(Icons.person_rounded, 'Cashier',
                          _summaryValue(snapshot.data!.displayName));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24.0),
            // Right: the money
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'K ${sale.totalAmount.toStringAsFixed(2)}',
                    style: theme.titleLarge.override(
                      fontFamily: theme.titleLargeFamily,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: _accent,
                      useGoogleFonts: !theme.titleLargeIsCustom,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  _paymentBadge(sale),
                  const SizedBox(height: 8.0),
                  Text(
                    '${sale.numberOfItems} item${sale.numberOfItems == 1 ? '' : 's'} sold',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      fontSize: 12.0,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Products card — header with the whole-sale reverse action, then
  /// the item table (name, unit price, quantity, line total, per-item
  /// reverse). Replaces the old Name/Quantity/Action-only table.
  Widget _productsCard(SalesRecord sale) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header + whole-sale reverse
            Row(
              children: [
                Icon(Icons.shopping_bag_rounded,
                    size: 20.0, color: theme.primary),
                const SizedBox(width: 10.0),
                Text(
                  'Products Sold',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _reverseEntireSale(sale),
                  icon: const Icon(Icons.undo_rounded, size: 16.0),
                  label: const Text('Reverse Entire Sale'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.error,
                    side: BorderSide(color: theme.error, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Table header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PRODUCT',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.secondaryText,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'UNIT PRICE',
                      textAlign: TextAlign.right,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.secondaryText,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'QTY',
                      textAlign: TextAlign.center,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.secondaryText,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'TOTAL',
                      textAlign: TextAlign.right,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.secondaryText,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44.0),
                ],
              ),
            ),
            // Items
            AuthUserStreamWidget(
              builder: (context) => StreamBuilder<List<SaleitemRecord>>(
                stream: querySaleitemRecord(
                  parent: AccessControl.parentRef(context),
                  queryBuilder: (saleitemRecord) => saleitemRecord.where(
                    'SaleID',
                    isEqualTo: widget.sale,
                  ),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Center(
                        child: SizedBox(
                          width: 28.0,
                          height: 28.0,
                          child: SpinKitRing(
                            color: theme.primary,
                            size: 28.0,
                            lineWidth: 2.4,
                          ),
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: NoRecordComponentWidget(),
                    );
                  }
                  return Column(
                    children: [
                      for (final item in items)
                        _productRow(item, sale, items.indexOf(item) == items.length - 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One product row: med icon + name, unit price, qty badge, line
  /// total, and a compact per-item reverse (icon + tooltip) instead of
  /// the old full-width duplicate button.
  Widget _productRow(SaleitemRecord item, SalesRecord sale, bool isLast) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: theme.alternate.withValues(alpha: 0.4)),
        ),
      ),
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13.0),
      child: Row(
        children: [
          // Product
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Icon(Icons.medication_rounded,
                      size: 17.0, color: theme.primary),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: StreamBuilder<StockRecord>(
                    stream: item.stockID != null
                        ? StockRecord.getDocument(item.stockID!)
                        : null,
                    builder: (context, snapshot) {
                      if (item.stockID == null) {
                        return Text(
                          'Unknown product',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            color: theme.secondaryText,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Text(
                          '…',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Unit price
          Expanded(
            flex: 2,
            child: Text(
              'K ${item.unitPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontSize: 13.0,
                color: theme.secondaryText,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          // Qty badge
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9999.0),
                ),
                child: Text(
                  '${item.quantity}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            ),
          ),
          // Line total
          Expanded(
            flex: 2,
            child: Text(
              'K ${item.totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                fontWeight: FontWeight.w700,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          // Per-item reverse — compact icon action
          const SizedBox(width: 8.0),
          Tooltip(
            message: 'Reverse this item',
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => _reverseItem(item, sale),
              child: Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: theme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Icon(Icons.undo_rounded,
                    size: 17.0, color: theme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  REVERSAL ACTIONS (extracted from the old inline buttons)
  // ═══════════════════════════════════════════════════════════════

  /// Reverses the entire sale: restores stock for every item, deletes
  /// the item rows, decrements revenue, and deletes the sale.
  Future<void> _reverseEntireSale(SalesRecord sale) async {
    logFirebaseEvent('SALES_ITEMS_REVERSE_TRANSACTION_BTN_ON_T');
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: const Text('Reverse entire sale?'),
                content: Text(
                    'All ${sale.numberOfItems} item(s) will be returned to stock, revenue will be adjusted, and the sale will be deleted. This action cannot be reversed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, true),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
    if (!confirmed) return;

    try {
      // Query under the same parent the page displays from — the old
      // code used currentUserReference, which found zero items for
      // staff accounts and deleted the sale without restoring stock.
      final parent = AccessControl.parentRef(context) ?? currentUserReference;
      final items = await querySaleitemRecordOnce(
        parent: parent,
        queryBuilder: (saleitemRecord) => saleitemRecord.where(
          'SaleID',
          isEqualTo: widget.sale,
        ),
      );

      for (final item in items) {
        if (item.stockID != null) {
          await item.stockID!.update({
            ...mapToFirestore(
              {
                'Quantity': FieldValue.increment(item.quantity),
              },
            ),
          });
          if (parent != null) {
            await StockMovementRecord.createDoc(parent).set(
                createStockMovementRecordData(
                  productId: item.stockID,
                  quantity: item.quantity,
                  movementType: 'SALE_RETURN',
                  reason: 'Reversal of sale ${sale.reference.id}',
                  movementReference: sale.reference.id,
                  recordedById: currentUserReference,
                  createdAt: DateTime.now(),
                ));
          }
        }
        await item.reference.delete();
      }

      final finance = await queryFinanceRecordOnce(
        parent: parent,
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      if (finance != null) {
        await finance.reference.update({
          ...mapToFirestore(
            {
              'Revenue': FieldValue.increment(-(sale.totalAmount)),
            },
          ),
        });
      }

      await widget.sale!.delete();

      if (!mounted) return;
      context.goNamed(FinancesWidget.routeName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not reverse the sale. Please try again.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  /// Reverses a single line item: restores its stock, adjusts revenue
  /// and the sale totals, writes a SALE_RETURN movement, deletes the
  /// item, and deletes the sale itself when the last item is removed.
  Future<void> _reverseItem(SaleitemRecord item, SalesRecord sale) async {
    logFirebaseEvent('SALES_ITEMS_REVERSE_ITEM_BTN_ON_T');
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: const Text('Reverse this item?'),
                content: Text(
                    'This item will be returned to stock and the sale total adjusted. This action cannot be reversed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext, true),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
    if (!confirmed) return;

    try {
      final parent = AccessControl.parentRef(context) ?? currentUserReference;

      // Finance under the same parent the revenue was recorded to.
      final finance = await queryFinanceRecordOnce(
        parent: parent,
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      if (finance != null) {
        await finance.reference.update({
          ...mapToFirestore(
            {
              'Revenue': FieldValue.increment(-(item.totalPrice)),
            },
          ),
        });
      }

      await sale.reference.update({
        ...mapToFirestore(
          {
            'Total_amount': FieldValue.increment(-(item.totalPrice)),
            'NumberOfItems': FieldValue.increment(-(1)),
          },
        ),
      });

      // Stock link may be null for manually-created sale items — guard
      // before re-incrementing.
      if (item.stockID != null) {
        await item.stockID!.update({
          ...mapToFirestore(
            {
              'Quantity': FieldValue.increment(item.quantity),
            },
          ),
        });
        if (parent != null) {
          await StockMovementRecord.createDoc(parent).set(
              createStockMovementRecordData(
                productId: item.stockID,
                quantity: item.quantity,
                movementType: 'SALE_RETURN',
                reason: 'Reversal of sale ${sale.reference.id}',
                movementReference: sale.reference.id,
                recordedById: currentUserReference,
                createdAt: DateTime.now(),
              ));
        }
      }

      await item.reference.delete();

      final refreshed =
          await SalesRecord.getDocumentOnce(widget.sale!);
      if (refreshed.numberOfItems == 0) {
        await widget.sale!.delete();
      }

      if (!mounted) return;
      context.goNamed(
        SalesItemsWidget.routeName,
        queryParameters: {
          'sale': serializeParam(
            widget.sale,
            ParamType.DocumentReference,
          ),
        }.withoutNulls,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not reverse the item. Please try again.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

}
