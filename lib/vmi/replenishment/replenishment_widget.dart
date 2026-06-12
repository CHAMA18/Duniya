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

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Replenishment Recommendations',
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
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Replenishment Recommendations',
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
                                    FFButtonWidget(
                                      onPressed: () async {
                                        await _recalculate();
                                      },
                                      text: 'Refresh',
                                      icon: Icon(Icons.refresh, size: 15.0),
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                // Pharmacy filter
                                Wrap(
                                  spacing: 12.0,
                                  runSpacing: 8.0,
                                  children: [
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
                                          return Container(
                                            width: 180.0,
                                            child:
                                                FlutterFlowDropDown<String>(
                                              controller: _model
                                                      .pharmacyValueController ??=
                                                  FormFieldController<
                                                          String>(null),
                                              options: snapshot.data!
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
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                Expanded(
                                  child: StreamBuilder<List<ReplenishmentRecord>>(
                                    stream: queryReplenishmentRecord(),
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
                                      List<ReplenishmentRecord> records =
                                          snapshot.data!;
                                      // Sort by suggested quantity (highest first)
                                      records.sort((a, b) => b
                                          .suggestedOrderQty
                                          .compareTo(a.suggestedOrderQty));
                                      if (records.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .shopping_cart_outlined,
                                                  size: 64.0,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText),
                                              SizedBox(height: 16.0),
                                              Text(
                                                  'No replenishment recommendations',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineSmall),
                                              SizedBox(height: 4.0),
                                              Text(
                                                  'Click Refresh to calculate',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium),
                                            ],
                                          ),
                                        );
                                      }
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
                                            Map<String,
                                                    ProductMasterRecord>
                                                productMap = {
                                              for (var p
                                                  in productSnapshot.data!)
                                                p.reference.path: p
                                            };
                                            return SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: SingleChildScrollView(
                                                child: DataTable(
                                                  headingRowColor:
                                                      MaterialStateProperty.all(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground),
                                                  columns: [
                                                    DataColumn(label: Text('Pharmacy', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Product', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Avg Weekly Sales', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Current Stock', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Target Level', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Suggested Order', style: FlutterFlowTheme.of(context).labelSmall)),
                                                  ],
                                                  rows: records
                                                      .map((record) {
                                                    ProductMasterRecord?
                                                        product = productMap[
                                                            record.productId
                                                                ?.path];
                                                    // Highlight high suggestion
                                                    Color? rowColor;
                                                    if (record.suggestedOrderQty >
                                                        0) {
                                                      rowColor = record.suggestedOrderQty >
                                                              record.targetStockLevel /
                                                                  2
                                                          ? Color(
                                                              0xFFFFF5F5)
                                                          : Color(
                                                              0xFFFFFBEB);
                                                    }
                                                    return DataRow(
                                                      color: rowColor != null
                                                          ? MaterialStateProperty
                                                              .all(rowColor)
                                                          : null,
                                                      cells: [
                                                        DataCell(FutureBuilder<
                                                                PharmacyRecord?>(
                                                          future: record
                                                                  .hasPharmacyId()
                                                              ? record.pharmacyId!
                                                                  .get()
                                                                  .then((s) =>
                                                                      PharmacyRecord.fromSnapshot(
                                                                          s))
                                                              : null,
                                                          builder:
                                                              (context, snap) {
                                                            return Text(
                                                              snap.hasData
                                                                  ? snap.data!
                                                                      .name
                                                                  : '-',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium,
                                                            );
                                                          },
                                                        )),
                                                        DataCell(Text(
                                                            product?.name ??
                                                                '-',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium)),
                                                        DataCell(Text(
                                                          record.averageWeeklySales
                                                              .toStringAsFixed(
                                                                  1),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        )),
                                                        DataCell(Text(
                                                          record.currentStock
                                                              .toString(),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        )),
                                                        DataCell(Text(
                                                          record.targetStockLevel
                                                              .toString(),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium,
                                                        )),
                                                        DataCell(Text(
                                                          record.suggestedOrderQty
                                                              .toString(),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    FlutterFlowTheme.of(context)
                                                                        .bodyMediumFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                        )),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          });
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
        ));
  }

  Future<void> _recalculate() async {
    // Get current products and stock balances
    final products = await queryProductMasterRecordOnce();
    final ownerRef = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;
    final pharmacies = await queryPharmacyRecordOnce(parent: ownerRef);

    for (var pharmacy in pharmacies) {
      for (var product in products) {
        if (!product.isActive) continue;
        // Get current stock balance
        final balances = await queryStockBalanceRecordOnce(
          parent: ownerRef,
          queryBuilder: (q) => q
              .where('ProductId', isEqualTo: product.reference)
              .limit(1),
        );

        int currentStock =
            balances.isNotEmpty ? balances.first.closingStock : 0;
        int targetLevel = product.targetStockLevel;
        int suggestedQty = targetLevel - currentStock;

        if (suggestedQty > 0) {
          // Calculate avg weekly sales from recent SOLD movements
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
            // Approximate weeks
            avgWeeklySales = totalSold / 4.0;
          }

          // Upsert replenishment record
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Replenishment recommendations refreshed')),
    );
  }
}
