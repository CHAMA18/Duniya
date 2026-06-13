import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// FontAwesome import removed - using Material icons instead
import 'vmi_dashboard_model.dart';
export 'vmi_dashboard_model.dart';

class VMIDashboardWidget extends StatefulWidget {
  const VMIDashboardWidget({super.key});

  static String routeName = 'VMIDashboard';
  static String routePath = '/vmiDashboard';

  @override
  State<VMIDashboardWidget> createState() => _VMIDashboardWidgetState();
}

class _VMIDashboardWidgetState extends State<VMIDashboardWidget> {
  late VMIDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VMIDashboardModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'VMIDashboard'});
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
        title: 'VMI Dashboard',
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
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'VMI Dashboard',
                                            style: FlutterFlowTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmallFamily,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmallIsCustom,
                                                ),
                                          ),
                                          if (responsiveVisibility(
                                            context: context,
                                            phone: false,
                                          ))
                                            Text(
                                              'Vendor Managed Inventory overview',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmallFamily,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmallIsCustom,
                                                      ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // KPI Cards Row
                                  AuthUserStreamWidget(
                                    builder: (context) => Wrap(
                                      spacing: 16.0,
                                      runSpacing: 12.0,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      direction: Axis.horizontal,
                                      runAlignment: WrapAlignment.start,
                                      verticalDirection: VerticalDirection.down,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Total Pharmacies Card
                                        FutureBuilder<int>(
                                          future: queryPharmacyRecordCount(
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
                                              return ShimmerLoadingCardWidget();
                                            }
                                            int count = snapshot.data!;
                                            return _buildKPICard(
                                              context,
                                              icon: Icons.business,
                                              iconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              title: 'Total Pharmacies',
                                              value: count.toString(),
                                            );
                                          },
                                        ),
                                        // Total Products Card
                                        StreamBuilder<
                                                List<ProductMasterRecord>>(
                                            stream:
                                                queryProductMasterRecord(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return ShimmerLoadingCardWidget();
                                              }
                                              int count =
                                                  snapshot.data!.length;
                                              return _buildKPICard(
                                                context,
                                                icon: Icons.medication_outlined,
                                                iconColor:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                title: 'Total Products',
                                                value: count.toString(),
                                              );
                                            }),
                                        // Low Stock Alerts Card
                                        StreamBuilder<
                                                List<LowStockAlertRecord>>(
                                            stream:
                                                queryLowStockAlertRecord(
                                              queryBuilder: (alertRecord) =>
                                                  alertRecord.where('Status',
                                                      isEqualTo: 'ACTIVE'),
                                            ),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return ShimmerLoadingCardWidget();
                                              }
                                              int count =
                                                  snapshot.data!.length;
                                              return _buildKPICard(
                                                context,
                                                icon: Icons.warning_amber_outlined,
                                                iconColor: FlutterFlowTheme.of(context).error,
                                                title: 'Low Stock Alerts',
                                                value: count.toString(),
                                              );
                                            }),
                                        // Pending Deliveries Card
                                        StreamBuilder<
                                                List<GoodsReceivedRecord>>(
                                            stream:
                                                queryGoodsReceivedRecord(
                                              parent: valueOrDefault(
                                                          currentUserDocument
                                                              ?.role,
                                                          '') ==
                                                      'Owner'
                                                  ? currentUserReference
                                                  : currentUserDocument
                                                      ?.ownerRef,
                                              queryBuilder:
                                                  (goodsReceivedRecord) =>
                                                      goodsReceivedRecord.where(
                                                          'Status',
                                                          isEqualTo:
                                                              'PENDING'),
                                            ),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return ShimmerLoadingCardWidget();
                                              }
                                              int count =
                                                  snapshot.data!.length;
                                              return _buildKPICard(
                                                context,
                                                icon: Icons.local_shipping_outlined,
                                                iconColor:
                                                    FlutterFlowTheme.of(context).warning,
                                                title: 'Pending Deliveries',
                                                value: count.toString(),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  // Two column layout for charts and alerts
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Stock by Pharmacy Chart
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Stock Value by Pharmacy',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMediumIsCustom,
                                                      ),
                                                ),
                                                SizedBox(height: 16.0),
                                                AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      StreamBuilder<
                                                              List<
                                                                  PharmacyRecord>>(
                                                          stream:
                                                              queryPharmacyRecord(
                                                            parent: valueOrDefault(
                                                                        currentUserDocument
                                                                            ?.role,
                                                                        '') ==
                                                                    'Owner'
                                                                ? currentUserReference
                                                                : currentUserDocument
                                                                    ?.ownerRef,
                                                          ),
                                                          builder:
                                                              (context,
                                                                  snapshot) {
                                                            if (!snapshot
                                                                .hasData) {
                                                              return Center(
                                                                child:
                                                                    SpinKitRing(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 40.0,
                                                                ),
                                                              );
                                                            }
                                                            List<PharmacyRecord>
                                                                pharmacies =
                                                                snapshot.data!;
                                                            if (pharmacies
                                                                .isEmpty) {
                                                              return Center(
                                                                child: Text(
                                                                  'No pharmacies found',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium,
                                                                ),
                                                              );
                                                            }
                                                            return Container(
                                                              height: 200.0,
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: pharmacies
                                                                    .asMap()
                                                                    .entries
                                                                    .map(
                                                                        (entry) {
                                                                  int index =
                                                                      entry.key;
                                                                  PharmacyRecord
                                                                      pharmacy =
                                                                      entry
                                                                          .value;
                                                                  // Simple bar chart placeholder
                                                                  double
                                                                      barHeight =
                                                                      (100.0 +
                                                                          (index *
                                                                              30.0) %
                                                                              80.0);
                                                                  return Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                barHeight,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primary.withAlpha(((0.4 + (index * 0.15)).clamp(0.0, 1.0) * 255).round()),
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 4.0),
                                                                          Text(
                                                                            pharmacy.name,
                                                                            style:
                                                                                FlutterFlowTheme.of(context).bodySmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                    ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            );
                                                          }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.0),
                                      // Low Stock Alert Summary
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Low Stock Alerts',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
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
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: FlutterFlowTheme.of(context).error,
                                                      size: 20.0,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12.0),
                                                StreamBuilder<
                                                        List<
                                                            LowStockAlertRecord>>(
                                                    stream:
                                                        queryLowStockAlertRecord(
                                                      queryBuilder: (alertRecord) =>
                                                          alertRecord.where(
                                                              'Status',
                                                              isEqualTo:
                                                                  'ACTIVE'),
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SpinKitRing(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            size: 30.0,
                                                          ),
                                                        );
                                                      }
                                                      List<LowStockAlertRecord>
                                                          alerts =
                                                          snapshot.data!;
                                                      if (alerts.isEmpty) {
                                                        return Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    24.0),
                                                            child: Text(
                                                              'No active alerts',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: alerts
                                                            .take(5)
                                                            .map((alert) =>
                                                                FutureBuilder<
                                                                    ProductMasterRecord?>(
                                                                  future: alert
                                                                      .productId
                                                                      ?.get()
                                                                      .then((s) =>
                                                                          ProductMasterRecord
                                                                              .fromSnapshot(s)),
                                                                  builder:
                                                                      (context,
                                                                          productSnapshot) {
                                                                    return Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              bottom:
                                                                                  8.0),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            double.infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Color(0xFFFFF5F5),
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Color(0xFFFEE2E2),
                                                                            width:
                                                                                1.0,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(8.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  productSnapshot.hasData ? productSnapshot.data!.name : 'Loading...',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        letterSpacing: 0.0,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '${alert.currentStock} / ${alert.reorderLevel}',
                                                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                      fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                                      color: FlutterFlowTheme.of(context).error,
                                                                                      letterSpacing: 0.0,
                                                                                      useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                                    ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ))
                                                            .toList(),
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.0),
                                  // Recent Stock Movements
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                'Recent Stock Movements',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMediumIsCustom,
                                                        ),
                                              ),
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  context.pushNamed(
                                                      StockMovementsWidget
                                                          .routeName);
                                                },
                                                text: 'View All',
                                                options: FFButtonOptions(
                                                  height: 32.0,
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(12.0, 0.0,
                                                              12.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.0),
                                          AuthUserStreamWidget(
                                            builder: (context) =>
                                                StreamBuilder<
                                                        List<
                                                            StockMovementRecord>>(
                                                    stream:
                                                        queryStockMovementRecord(
                                                      parent: valueOrDefault(
                                                                  currentUserDocument
                                                                      ?.role,
                                                                  '') ==
                                                              'Owner'
                                                          ? currentUserReference
                                                          : currentUserDocument
                                                              ?.ownerRef,
                                                      queryBuilder:
                                                          (stockMovementRecord) =>
                                                              stockMovementRecord
                                                                  .orderBy(
                                                                      'CreatedAt',
                                                                      descending:
                                                                          true),
                                                      limit: 10,
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Center(
                                                          child: SpinKitRing(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            size: 30.0,
                                                          ),
                                                        );
                                                      }
                                                      List<StockMovementRecord>
                                                          movements =
                                                          snapshot.data!;
                                                      if (movements.isEmpty) {
                                                        return Center(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    24.0),
                                                            child: Text(
                                                              'No stock movements yet',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      return SingleChildScrollView(
                                                        scrollDirection: Axis
                                                            .horizontal,
                                                        child: DataTable(
                                                          headingRowColor:
                                                              MaterialStateProperty
                                                                  .all(FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground),
                                                          dataRowColor:
                                                              MaterialStateProperty
                                                                  .all(FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground),
                                                          columns: [
                                                            DataColumn(
                                                                label: Text(
                                                                    'Date',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Product',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Type',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Qty',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall)),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Reason',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall)),
                                                          ],
                                                          rows: movements
                                                              .map((movement) =>
                                                                  DataRow(
                                                                    cells: [
                                                                      DataCell(Text(
                                                                          dateTimeFormat(
                                                                            'yyyy-MM-dd',
                                                                            movement.createdAt,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                      DataCell(FutureBuilder<ProductMasterRecord?>(
                                                                        future: movement.productId?.get().then((s) => ProductMasterRecord.fromSnapshot(s)),
                                                                        builder: (context, snap) => Text(snap.hasData ? snap.data!.name : '...', style: FlutterFlowTheme.of(context).bodyMedium),
                                                                      )),
                                                                      DataCell(_buildMovementBadge(context, movement.movementType)),
                                                                      DataCell(Text(movement.quantity.toString(), style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                      DataCell(Text(movement.reason ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                                                    ],
                                                                  ))
                                                              .toList(),
                                                        ),
                                                      );
                                                    }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildKPICard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      width: MediaQuery.sizeOf(context).width > 1100.0
          ? 300.0
          : double.infinity,
      height: 120.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.0,
              ),
            ),
            SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).displaySmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context)
                                .displaySmallIsCustom,
                      ),
                ),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context)
                                .bodySmallIsCustom,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementBadge(BuildContext context, String type) {
    Color bgColor;
    Color textColor;
    switch (type) {
      case 'RECEIVED':
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF065F46);
        break;
      case 'SOLD':
        bgColor = Color(0xFFF9FAFB);
        textColor = Color(0xFF374151);
        break;
      case 'TRANSFERRED':
        bgColor = Color(0xFFF9FAFB);
        textColor = Color(0xFF374151);
        break;
      case 'ADJUSTMENT':
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFF92400E);
        break;
      default:
        bgColor = FlutterFlowTheme.of(context).alternate;
        textColor = Color(0xFF1F2937);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        type,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: textColor,
              fontSize: 10.0,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }
}
