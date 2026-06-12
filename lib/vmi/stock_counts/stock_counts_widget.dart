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
import 'stock_counts_model.dart';
export 'stock_counts_model.dart';

class StockCountsWidget extends StatefulWidget {
  const StockCountsWidget({super.key});

  static String routeName = 'StockCounts';
  static String routePath = '/stockCounts';

  @override
  State<StockCountsWidget> createState() => _StockCountsWidgetState();
}

class _StockCountsWidgetState extends State<StockCountsWidget> {
  late StockCountsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StockCountsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StockCounts'});
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
        title: 'Stock Counts',
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
                                      'Stock Counts',
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
                                            StockCountDetailWidget
                                                .routeName);
                                      },
                                      text: 'New Count',
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
                                Wrap(
                                  spacing: 12.0,
                                  runSpacing: 8.0,
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .statusValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'All',
                                          'DRAFT',
                                          'SUBMITTED',
                                          'APPROVED',
                                          'REJECTED',
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
                                        StreamBuilder<List<StockCountRecord>>(
                                      stream: queryStockCountRecord(
                                        parent: valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner'
                                            ? currentUserReference
                                            : currentUserDocument?.ownerRef,
                                        queryBuilder: (stockCountRecord) =>
                                            stockCountRecord.orderBy(
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
                                        List<StockCountRecord> counts =
                                            snapshot.data!;
                                        // Filter by status
                                        if (_model.statusValue != null &&
                                            _model.statusValue != 'All') {
                                          counts = counts
                                              .where((c) =>
                                                  c.status ==
                                                  _model.statusValue)
                                              .toList();
                                        }
                                        if (counts.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.fact_check_outlined,
                                                    size: 64.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText),
                                                SizedBox(height: 16.0),
                                                Text('No stock counts found',
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
                                          itemCount: counts.length,
                                          itemBuilder: (context, index) {
                                            StockCountRecord count =
                                                counts[index];
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  context.pushNamed(
                                                    StockCountDetailWidget
                                                        .routeName,
                                                    pathParameters: {
                                                      'docRef': count
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
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Stock Count #${index + 1}',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                                height: 4.0),
                                                            Text(
                                                              count.hasCountDate()
                                                                  ? dateTimeFormat(
                                                                      'yyyy-MM-dd',
                                                                      count.countDate!,
                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                    )
                                                                  : '-',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                        _buildStatusBadge(
                                                            context,
                                                            count.status),
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
      case 'DRAFT':
        bgColor = Color(0xFFE2E8F0);
        textColor = Color(0xFF2D3748);
        break;
      case 'SUBMITTED':
        bgColor = Color(0xFFBEE3F8);
        textColor = Color(0xFF2A4365);
        break;
      case 'APPROVED':
        bgColor = Color(0xFFC6F6D5);
        textColor = Color(0xFF22543D);
        break;
      case 'REJECTED':
        bgColor = Color(0xFFFED7D7);
        textColor = Color(0xFF822727);
        break;
      default:
        bgColor = Color(0xFFE2E8F0);
        textColor = Color(0xFF2D3748);
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
