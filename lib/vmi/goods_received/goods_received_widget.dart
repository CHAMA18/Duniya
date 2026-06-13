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
import 'goods_received_model.dart';
export 'goods_received_model.dart';

class GoodsReceivedWidget extends StatefulWidget {
  const GoodsReceivedWidget({super.key});

  static String routeName = 'GoodsReceived';
  static String routePath = '/goodsReceived';

  @override
  State<GoodsReceivedWidget> createState() => _GoodsReceivedWidgetState();
}

class _GoodsReceivedWidgetState extends State<GoodsReceivedWidget> {
  late GoodsReceivedModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoodsReceivedModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'GoodsReceived'});
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
        title: 'Goods Received',
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
                                      'Goods Received',
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
                                        context.pushNamed(
                                            GoodsReceivedDetailWidget
                                                .routeName);
                                      },
                                      text: 'Add Receipt',
                                      icon: Icon(Icons.add, size: 15.0),
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
                                // Filters
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
                                          'PENDING',
                                          'CONFIRMED',
                                          'DISCREPANCY',
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
                                  child: AuthUserStreamWidget(
                                    builder: (context) =>
                                        StreamBuilder<List<GoodsReceivedRecord>>(
                                      stream: queryGoodsReceivedRecord(
                                        parent: valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner'
                                            ? currentUserReference
                                            : currentUserDocument?.ownerRef,
                                        queryBuilder: (goodsReceivedRecord) =>
                                            goodsReceivedRecord.orderBy(
                                                'CreatedAt',
                                                descending: true),
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
                                        List<GoodsReceivedRecord> receipts =
                                            snapshot.data!;
                                        // Filter by status
                                        if (_model.statusValue != null &&
                                            _model.statusValue != 'All') {
                                          receipts = receipts
                                              .where((r) =>
                                                  r.status ==
                                                  _model.statusValue)
                                              .toList();
                                        }
                                        if (receipts.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.inbox_outlined,
                                                    size: 64.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText),
                                                SizedBox(height: 16.0),
                                                Text('No receipts found',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .headlineSmall),
                                              ],
                                            ),
                                          );
                                        }
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: receipts.length,
                                          itemBuilder:
                                              (context, index) {
                                            GoodsReceivedRecord receipt =
                                                receipts[index];
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: InkWell(
                                                splashColor:
                                                    Colors.transparent,
                                                focusColor:
                                                    Colors.transparent,
                                                hoverColor:
                                                    Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    GoodsReceivedDetailWidget
                                                        .routeName,
                                                    pathParameters: {
                                                      'docRef': receipt
                                                          .reference.path,
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                receipt
                                                                    .deliveryNoteNumber,
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context).titleMediumFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                    ),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      4.0),
                                                              Text(
                                                                receipt.hasDeliveryDate()
                                                                    ? dateTimeFormat(
                                                                        'yyyy-MM-dd',
                                                                        receipt.deliveryDate!,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      )
                                                                    : 'No date',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        _buildStatusBadge(
                                                            context,
                                                            receipt.status),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'CONFIRMED':
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF065F46);
        break;
      case 'PENDING':
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFF92400E);
        break;
      case 'DISCREPANCY':
        bgColor = Color(0xFFFEE2E2);
        textColor = Color(0xFF991B1B);
        break;
      default:
        bgColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF1F2937);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: textColor,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }
}
