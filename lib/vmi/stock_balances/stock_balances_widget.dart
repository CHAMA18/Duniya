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

class _StockBalancesWidgetState extends State<StockBalancesWidget> {
  late StockBalancesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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

  Color _getRowColor(int closingStock, int reorderLevel) {
    if (closingStock < reorderLevel) {
      return Color(0xFFFFF5F5); // Red
    } else if (closingStock < (reorderLevel * 2)) {
      return Color(0xFFFFFBEB); // Yellow
    } else {
      return Color(0xFFF0FFF4); // Green
    }
  }

  Color _getRowTextColor(int closingStock, int reorderLevel) {
    if (closingStock < reorderLevel) {
      return Color(0xFFC53030);
    } else if (closingStock < (reorderLevel * 2)) {
      return Color(0xFFB7791F);
    } else {
      return Color(0xFF276749);
    }
  }

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
                          alignment: AlignmentDirectional(0.0, -1.0),
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
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Page title
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Stock Balances',
                                      style: FlutterFlowTheme.of(context)
                                          .displaySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .displaySmallIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                // Filters Row
                                Wrap(
                                  spacing: 12.0,
                                  runSpacing: 8.0,
                                  alignment: WrapAlignment.start,
                                  children: [
                                    // Search Bar
                                    Container(
                                      width: 250.0,
                                      child: TextFormField(
                                        controller:
                                            _model.searchTextController,
                                        focusNode: _model.searchFocusNode,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText: 'Search products...',
                                          hintStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall,
                                          prefixIcon: Icon(
                                            Icons.search,
                                            size: 18.0,
                                          ),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        onChanged: (value) =>
                                            safeSetState(() {}),
                                      ),
                                    ),
                                    // Pharmacy Dropdown
                                    AuthUserStreamWidget(
                                      builder: (context) =>
                                          FutureBuilder<List<PharmacyRecord>>(
                                        future: queryPharmacyRecordOnce(
                                          parent: valueOrDefault(
                                                      currentUserDocument
                                                          ?.role,
                                                      '') ==
                                                  'Owner'
                                              ? currentUserReference
                                              : currentUserDocument
                                                  ?.ownerRef,
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container(
                                              width: 180.0,
                                              height: 44.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                ),
                                              ),
                                              child: Center(
                                                child: SpinKitRing(
                                                  color:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  size: 20.0,
                                                ),
                                              ),
                                            );
                                          }
                                          List<PharmacyRecord> pharmacies =
                                              snapshot.data!;
                                          return Container(
                                            width: 180.0,
                                            child:
                                                FlutterFlowDropDown<String>(
                                              controller: _model
                                                  .pharmacyValueController ??= FormFieldController<
                                                          String>(
                                                      null),
                                              options: pharmacies
                                                  .map((p) => p.name)
                                                  .toList(),
                                              onChanged: (val) =>
                                                  safeSetState(() =>
                                                      _model.pharmacyValue =
                                                          val),
                                              width: 180.0,
                                              height: 44.0,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium,
                                              hintText: 'All Pharmacies',
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderColor:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              borderRadius: 8.0,
                                              elevation: 2,
                                              borderWidth: 1.0,
                                              margin: EdgeInsets.zero,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Period Dropdown
                                    Container(
                                      width: 150.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .periodValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'Current Month',
                                          'Last Month',
                                          'Last 3 Months',
                                          'Current Year',
                                        ],
                                        onChanged: (val) => safeSetState(
                                            () => _model.periodValue = val),
                                        width: 150.0,
                                        height: 44.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        hintText: 'Period',
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderColor: FlutterFlowTheme.of(context)
                                            .alternate,
                                        borderRadius: 8.0,
                                        elevation: 2,
                                        borderWidth: 1.0,
                                        margin: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                // Data Table
                                Expanded(
                                  child: AuthUserStreamWidget(
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
                                          return Center(
                                            child: SpinKitRing(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 40.0,
                                            ),
                                          );
                                        }
                                        List<StockBalanceRecord> balances =
                                            snapshot.data!;
                                        // Filter by search
                                        String? search =
                                            _model.searchTextController?.text
                                                .toLowerCase();
                                        // We need to resolve product names; show the table
                                        return FutureBuilder<
                                                List<ProductMasterRecord>>(
                                            future:
                                                queryProductMasterRecordOnce(),
                                            builder: (context,
                                                productSnapshot) {
                                              if (!productSnapshot.hasData) {
                                                return Center(
                                                  child: SpinKitRing(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    size: 40.0,
                                                  ),
                                                );
                                              }
                                              Map<String, ProductMasterRecord>
                                                  productMap = {
                                                for (var p
                                                    in productSnapshot.data!)
                                                  p.reference.path: p
                                              };

                                              // Build display rows
                                              List<
                                                  _StockBalanceRow> rows = [];
                                              double totalValue = 0.0;

                                              for (var balance in balances) {
                                                ProductMasterRecord? product =
                                                    productMap[balance
                                                        .productId?.path];
                                                if (product == null) continue;
                                                // Apply search filter
                                                if (search != null &&
                                                    search.isNotEmpty &&
                                                    !product.name
                                                        .toLowerCase()
                                                        .contains(search)) {
                                                  continue;
                                                }
                                                rows.add(_StockBalanceRow(
                                                  balance: balance,
                                                  product: product,
                                                ));
                                                totalValue +=
                                                    balance.stockValue;
                                              }

                                              if (rows.isEmpty) {
                                                return Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .inventory_2_outlined,
                                                        size: 64.0,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryText,
                                                      ),
                                                      SizedBox(height: 16.0),
                                                      Text(
                                                        'No stock balances found',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }

                                              return Column(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection: Axis
                                                          .horizontal,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: DataTable(
                                                          headingRowColor:
                                                              MaterialStateProperty
                                                                  .all(FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground),
                                                          dataRowMinHeight:
                                                              40.0,
                                                          dataRowMaxHeight:
                                                              56.0,
                                                          columns: [
                                                            DataColumn(
                                                                label: Text(
                                                                    'Product Name',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Opening',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Received',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Dispensed',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Transferred',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Adjusted',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Closing',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Value',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Days Rem.',
                                                                    style: FlutterFlowTheme.of(context).labelSmall)),
                                                          ],
                                                          rows: rows
                                                              .map((row) {
                                                            int closing = row
                                                                .balance
                                                                .closingStock;
                                                            int reorder = row
                                                                .product
                                                                .reorderLevel;
                                                            Color rowColor =
                                                                _getRowColor(
                                                                    closing,
                                                                    reorder);
                                                            Color textColor =
                                                                _getRowTextColor(
                                                                    closing,
                                                                    reorder);
                                                            return DataRow(
                                                              color:
                                                                  MaterialStateProperty
                                                                      .all(
                                                                          rowColor),
                                                              cells: [
                                                                DataCell(Text(
                                                                    row.product
                                                                        .name,
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              textColor,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ))),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .openingStock
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .stockReceived
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .stockDispensed
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .stockTransferred
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .stockAdjusted
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    closing
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ))),
                                                                DataCell(Text(
                                                                    formatNumber(
                                                                      row.balance
                                                                          .stockValue,
                                                                      formatType:
                                                                          FormatType
                                                                              .decimal,
                                                                      decimalType:
                                                                          DecimalType
                                                                              .periodDecimal,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                DataCell(Text(
                                                                    row.balance
                                                                        .daysOfStockRemaining
                                                                        .toStringAsFixed(
                                                                            1),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium)),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // Total value footer
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      border: Border(
                                                        top: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          width: 2.0,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            'Total Stock Value: ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(context)
                                                                          .titleMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                          ),
                                                          Text(
                                                            formatNumber(
                                                              totalValue,
                                                              formatType:
                                                                  FormatType
                                                                      .decimal,
                                                              decimalType:
                                                                  DecimalType
                                                                      .periodDecimal,
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleMedium
                                                                .override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(context)
                                                                          .titleMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(context)
                                                                          .titleMediumIsCustom,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
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
        ));
  }
}

class _StockBalanceRow {
  final StockBalanceRecord balance;
  final ProductMasterRecord product;
  _StockBalanceRow({required this.balance, required this.product});
}
