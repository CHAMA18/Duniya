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
import 'low_stock_alerts_model.dart';
export 'low_stock_alerts_model.dart';

class LowStockAlertsWidget extends StatefulWidget {
  const LowStockAlertsWidget({super.key});

  static String routeName = 'LowStockAlerts';
  static String routePath = '/lowStockAlerts';

  @override
  State<LowStockAlertsWidget> createState() => _LowStockAlertsWidgetState();
}

class _LowStockAlertsWidgetState extends State<LowStockAlertsWidget> {
  late LowStockAlertsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LowStockAlertsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'LowStockAlerts'});
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
        title: 'Low Stock Alerts',
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
                                      'Low Stock Alerts',
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
                                    Container(
                                      width: 150.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .statusValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'All',
                                          'ACTIVE',
                                          'ACKNOWLEDGED',
                                          'ORDERED',
                                        ],
                                        onChanged: (val) => safeSetState(
                                            () => _model.statusValue = val),
                                        width: 150.0,
                                        height: 44.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        hintText: 'Status',
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
                                Expanded(
                                  child: StreamBuilder<List<LowStockAlertRecord>>(
                                    stream: queryLowStockAlertRecord(),
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
                                      List<LowStockAlertRecord> alerts =
                                          snapshot.data!;
                                      // Filter by status
                                      if (_model.statusValue != null &&
                                          _model.statusValue != 'All') {
                                        alerts = alerts
                                            .where((a) =>
                                                a.status ==
                                                _model.statusValue)
                                            .toList();
                                      }
                                      if (alerts.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .check_circle_outline,
                                                  size: 64.0,
                                                  color: Color(0xFF38A169)),
                                              SizedBox(height: 16.0),
                                              Text('No low stock alerts',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineSmall),
                                              SizedBox(height: 4.0),
                                              Text(
                                                  'All products are above reorder levels',
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
                                                    DataColumn(label: Text('Current Stock', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Reorder Level', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Suggested Qty', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Status', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Actions', style: FlutterFlowTheme.of(context).labelSmall)),
                                                  ],
                                                  rows: alerts
                                                      .map((alert) {
                                                    ProductMasterRecord?
                                                        product = productMap[
                                                            alert.productId
                                                                ?.path];
                                                    return DataRow(cells: [
                                                      DataCell(FutureBuilder<
                                                              PharmacyRecord?>(
                                                        future: alert
                                                                .hasPharmacyId()
                                                            ? alert.pharmacyId!
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
                                                        alert.currentStock
                                                            .toString(),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(context)
                                                                      .bodyMediumFamily,
                                                              color: alert.currentStock <
                                                                      alert
                                                                          .reorderLevel
                                                                  ? Color(
                                                                      0xFFE53E3E)
                                                                  : null,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                      )),
                                                      DataCell(Text(
                                                          alert.reorderLevel
                                                              .toString(),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium)),
                                                      DataCell(Text(
                                                          alert
                                                              .suggestedQuantity
                                                              .toString(),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium)),
                                                      DataCell(
                                                          _buildAlertStatusBadge(
                                                              context,
                                                              alert.status)),
                                                      DataCell(Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (alert.status ==
                                                              'ACTIVE')
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                      right:
                                                                          4.0),
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  await alert
                                                                      .reference
                                                                      .update({
                                                                    'Status':
                                                                        'ACKNOWLEDGED',
                                                                    'UpdatedAt':
                                                                        getCurrentTimestamp,
                                                                  });
                                                                },
                                                                text:
                                                                    'Acknowledge',
                                                                options:
                                                                    FFButtonOptions(
                                                                  height:
                                                                      28.0,
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                                  color: Color(
                                                                      0xFFDD6B20),
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelSmallFamily,
                                                                        color:
                                                                            Colors.white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                      ),
                                                                  elevation:
                                                                      0.0,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                ),
                                                              ),
                                                            ),
                                                          if (alert.status ==
                                                              'ACKNOWLEDGED')
                                                            FFButtonWidget(
                                                              onPressed:
                                                                  () async {
                                                                await alert
                                                                    .reference
                                                                    .update({
                                                                  'Status':
                                                                      'ORDERED',
                                                                  'UpdatedAt':
                                                                      getCurrentTimestamp,
                                                                });
                                                              },
                                                              text:
                                                                  'Mark Ordered',
                                                              options:
                                                                  FFButtonOptions(
                                                                height: 28.0,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8.0),
                                                                color: Color(
                                                                    0xFF38A169),
                                                                textStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context).labelSmallFamily,
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                    ),
                                                                elevation: 0.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4.0),
                                                              ),
                                                            ),
                                                        ],
                                                      )),
                                                    ]);
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

  Widget _buildAlertStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'ACTIVE':
        bgColor = Color(0xFFFEE2E2);
        textColor = Color(0xFF991B1B);
        break;
      case 'ACKNOWLEDGED':
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFF92400E);
        break;
      case 'ORDERED':
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF065F46);
        break;
      default:
        bgColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF1F2937);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: textColor,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }
}
