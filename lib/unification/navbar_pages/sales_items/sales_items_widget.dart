import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          FFLocalizations.of(context).getText(
                                            '6iblhfc3' /* Below are the products sold */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .displaySmallFamily,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmallIsCustom,
                                              ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        constraints: BoxConstraints(
                                          maxWidth: 1170.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
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
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    phone: false,
                                                    tablet: false,
                                                    tabletLandscape: false,
                                                  ))
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          StreamBuilder<
                                                              PharmacyRecord>(
                                                            stream: PharmacyRecord
                                                                .getDocument(
                                                                    salesItemsSalesRecord
                                                                        .pharmaID!),
                                                            builder: (context,
                                                                snapshot) {
                                                              // Customize what your widget looks like when it's loading.
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        100.0,
                                                                    height:
                                                                        100.0,
                                                                    child:
                                                                        SpinKitRing(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      size:
                                                                          100.0,
                                                                    ),
                                                                  ),
                                                                );
                                                              }

                                                              final textPharmacyRecord =
                                                                  snapshot
                                                                      .data!;

                                                              return Text(
                                                                'Pharmacy Name: ${textPharmacyRecord.name}',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      fontSize:
                                                                          20.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              );
                                                            },
                                                          ),
                                                          Text(
                                                            'Date: ${dateTimeFormat(
                                                              "yMMMd",
                                                              salesItemsSalesRecord
                                                                  .date,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            )} ${dateTimeFormat(
                                                              "Hm",
                                                              salesItemsSalesRecord
                                                                  .date,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            )}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                          StreamBuilder<
                                                              UserRecord>(
                                                            stream: UserRecord
                                                                .getDocument(
                                                                    salesItemsSalesRecord
                                                                        .userID!),
                                                            builder: (context,
                                                                snapshot) {
                                                              // Customize what your widget looks like when it's loading.
                                                              if (!snapshot
                                                                  .hasData) {
                                                                return Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width:
                                                                        100.0,
                                                                    height:
                                                                        100.0,
                                                                    child:
                                                                        SpinKitRing(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      size:
                                                                          100.0,
                                                                    ),
                                                                  ),
                                                                );
                                                              }

                                                              final textUserRecord =
                                                                  snapshot
                                                                      .data!;

                                                              return Text(
                                                                'Cashier Name: ${textUserRecord.displayName}',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      fontSize:
                                                                          20.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  FFButtonWidget(
                                                    onPressed: () async {
                                                      logFirebaseEvent(
                                                          'SALES_ITEMS_REVERSE_TRANSACTION_BTN_ON_T');
                                                      var _shouldSetState =
                                                          false;
                                                      logFirebaseEvent(
                                                          'Button_alert_dialog');
                                                      var confirmDialogResponse =
                                                          await showDialog<
                                                                  bool>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (alertDialogContext) {
                                                                  return WebViewAware(
                                                                    child:
                                                                        AlertDialog(
                                                                      title: Text(
                                                                          'Reverse confirmation'),
                                                                      content: Text(
                                                                          'This action cannot be reversed'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              false),
                                                                          child:
                                                                              Text('Cancel'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () => Navigator.pop(
                                                                              alertDialogContext,
                                                                              true),
                                                                          child:
                                                                              Text('Confirm'),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ) ??
                                                              false;
                                                      if (!confirmDialogResponse) {
                                                        if (_shouldSetState)
                                                          safeSetState(() {});
                                                        return;
                                                      }
                                                      logFirebaseEvent(
                                                          'Button_firestore_query');
                                                      _model.salesItems =
                                                          await querySaleitemRecordOnce(
                                                        parent:
                                                            currentUserReference,
                                                        queryBuilder:
                                                            (saleitemRecord) =>
                                                                saleitemRecord
                                                                    .where(
                                                          'SaleID',
                                                          isEqualTo:
                                                              widget.sale,
                                                        ),
                                                      );
                                                      _shouldSetState = true;
                                                      logFirebaseEvent(
                                                          'Button_update_app_state');
                                                      FFAppState().LoopCounter =
                                                          0;
                                                      while (FFAppState()
                                                              .LoopCounter !=
                                                          _model.salesItems
                                                              ?.length) {
                                                        logFirebaseEvent(
                                                            'Button_backend_call');

                                                        await _model.salesItems!
                                                            .elementAtOrNull(
                                                                FFAppState()
                                                                    .LoopCounter)!
                                                            .stockID!
                                                            .update({
                                                          ...mapToFirestore(
                                                            {
                                                              'Quantity': FieldValue.increment(_model
                                                                  .salesItems!
                                                                  .elementAtOrNull(
                                                                      FFAppState()
                                                                          .LoopCounter)!
                                                                  .quantity),
                                                            },
                                                          ),
                                                        });
                                                        logFirebaseEvent(
                                                            'Button_backend_call');
                                                        await _model.salesItems!
                                                            .elementAtOrNull(
                                                                FFAppState()
                                                                    .LoopCounter)!
                                                            .reference
                                                            .delete();
                                                        logFirebaseEvent(
                                                            'Button_update_app_state');
                                                        FFAppState()
                                                                .LoopCounter =
                                                            FFAppState()
                                                                    .LoopCounter +
                                                                1;
                                                      }
                                                      logFirebaseEvent(
                                                          'Button_firestore_query');
                                                      _model.finee =
                                                          await queryFinanceRecordOnce(
                                                        parent:
                                                            currentUserReference,
                                                        singleRecord: true,
                                                      ).then((s) =>
                                                              s.firstOrNull);
                                                      _shouldSetState = true;
                                                      logFirebaseEvent(
                                                          'Button_backend_call');

                                                      await _model
                                                          .finee!.reference
                                                          .update({
                                                        ...mapToFirestore(
                                                          {
                                                            'Revenue': FieldValue
                                                                .increment(
                                                                    -(salesItemsSalesRecord
                                                                        .totalAmount)),
                                                          },
                                                        ),
                                                      });
                                                      logFirebaseEvent(
                                                          'Button_backend_call');
                                                      await widget.sale!
                                                          .delete();
                                                      logFirebaseEvent(
                                                          'Button_update_app_state');
                                                      FFAppState().LoopCounter =
                                                          0;
                                                      logFirebaseEvent(
                                                          'Button_navigate_to');

                                                      context.goNamed(
                                                          FinancesWidget
                                                              .routeName);

                                                      if (_shouldSetState)
                                                        safeSetState(() {});
                                                    },
                                                    text: FFLocalizations.of(
                                                            context)
                                                        .getText(
                                                      '9krie4rw' /* Reverse Transaction */,
                                                    ),
                                                    options: FFButtonOptions(
                                                      height: 40.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmallFamily,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmallIsCustom,
                                                              ),
                                                      elevation: 3.0,
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.transparent,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 16.0, 0.0, 0.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(8.0),
                                                      topRight:
                                                          Radius.circular(8.0),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(10.0, 0.0,
                                                                10.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            FFLocalizations.of(
                                                                    context)
                                                                .getText(
                                                              'cl67i69t' /* Name */,
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            FFLocalizations.of(
                                                                    context)
                                                                .getText(
                                                              'hkrv38f2' /* Quantity */,
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    -1.0, 0.0),
                                                            child: Text(
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .getText(
                                                                '57h8orky' /* Action */,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodySmallFamily,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodySmallIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              AuthUserStreamWidget(
                                                builder: (context) =>
                                                    StreamBuilder<
                                                        List<SaleitemRecord>>(
                                                  stream: querySaleitemRecord(
                                                    parent: () {
                                                      if (valueOrDefault(
                                                              currentUserDocument
                                                                  ?.role,
                                                              '') ==
                                                          'Owner') {
                                                        return currentUserReference;
                                                      } else if (valueOrDefault(
                                                              currentUserDocument
                                                                  ?.role,
                                                              '') !=
                                                          'Owner') {
                                                        return currentUserDocument
                                                            ?.ownerRef;
                                                      } else {
                                                        return currentUserDocument
                                                            ?.ownerRef;
                                                      }
                                                    }(),
                                                    queryBuilder:
                                                        (saleitemRecord) =>
                                                            saleitemRecord
                                                                .where(
                                                      'SaleID',
                                                      isEqualTo: widget.sale,
                                                    ),
                                                  ),
                                                  builder: (context, snapshot) {
                                                    // Customize what your widget looks like when it's loading.
                                                    if (!snapshot.hasData) {
                                                      return Center(
                                                        child: SizedBox(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          child: SpinKitRing(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            size: 100.0,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    List<SaleitemRecord>
                                                        listViewSaleitemRecordList =
                                                        snapshot.data!;
                                                    if (listViewSaleitemRecordList
                                                        .isEmpty) {
                                                      return Center(
                                                        child:
                                                            NoRecordComponentWidget(),
                                                      );
                                                    }

                                                    return ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      itemCount:
                                                          listViewSaleitemRecordList
                                                              .length,
                                                      itemBuilder: (context,
                                                          listViewIndex) {
                                                        final listViewSaleitemRecord =
                                                            listViewSaleitemRecordList[
                                                                listViewIndex];
                                                        return Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      1.0),
                                                          child: Container(
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      0.0,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  offset:
                                                                      Offset(
                                                                    0.0,
                                                                    1.0,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  flex: 2,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              StreamBuilder<StockRecord>(
                                                                                stream: StockRecord.getDocument(listViewSaleitemRecord.stockID!),
                                                                                builder: (context, snapshot) {
                                                                                  // Customize what your widget looks like when it's loading.
                                                                                  if (!snapshot.hasData) {
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

                                                                                  final textStockRecord = snapshot.data!;

                                                                                  return Text(
                                                                                    textStockRecord.name,
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                        ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    listViewSaleitemRecord
                                                                        .quantity
                                                                        .toString(),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            10.0),
                                                                        child:
                                                                            FFButtonWidget(
                                                                          onPressed:
                                                                              () async {
                                                                            logFirebaseEvent('SALES_ITEMS_REVERSE_TRANSACTION_BTN_ON_T');
                                                                            var _shouldSetState =
                                                                                false;
                                                                            logFirebaseEvent('Button_alert_dialog');
                                                                            var confirmDialogResponse = await showDialog<bool>(
                                                                                  context: context,
                                                                                  builder: (alertDialogContext) {
                                                                                    return WebViewAware(
                                                                                      child: AlertDialog(
                                                                                        title: Text('Reverse confirmation'),
                                                                                        content: Text('This action cannot be reversed'),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                            child: Text('Cancel'),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                            child: Text('Confirm'),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ) ??
                                                                                false;
                                                                            if (!confirmDialogResponse) {
                                                                              if (_shouldSetState)
                                                                                safeSetState(() {});
                                                                              return;
                                                                            }
                                                                            logFirebaseEvent('Button_firestore_query');
                                                                            _model.fineeCopy =
                                                                                await queryFinanceRecordOnce(
                                                                              parent: currentUserReference,
                                                                              singleRecord: true,
                                                                            ).then((s) => s.firstOrNull);
                                                                            _shouldSetState =
                                                                                true;
                                                                            logFirebaseEvent('Button_backend_call');

                                                                            await _model.fineeCopy!.reference.update({
                                                                              ...mapToFirestore(
                                                                                {
                                                                                  'Revenue': FieldValue.increment(-(listViewSaleitemRecord.totalPrice)),
                                                                                },
                                                                              ),
                                                                            });
                                                                            logFirebaseEvent('Button_backend_call');

                                                                            await salesItemsSalesRecord.reference.update({
                                                                              ...mapToFirestore(
                                                                                {
                                                                                  'Total_amount': FieldValue.increment(-(listViewSaleitemRecord.totalPrice)),
                                                                                  'NumberOfItems': FieldValue.increment(-(1)),
                                                                                },
                                                                              ),
                                                                            });
                                                                            logFirebaseEvent('Button_backend_call');

                                                                            await listViewSaleitemRecord.stockID!.update({
                                                                              ...mapToFirestore(
                                                                                {
                                                                                  'Quantity': FieldValue.increment(listViewSaleitemRecord.quantity),
                                                                                },
                                                                              ),
                                                                            });
                                                                            logFirebaseEvent('Button_backend_call');
                                                                            await listViewSaleitemRecord.reference.delete();
                                                                            logFirebaseEvent('Button_backend_call');
                                                                            _model.sale =
                                                                                await SalesRecord.getDocumentOnce(widget.sale!);
                                                                            _shouldSetState =
                                                                                true;
                                                                            if (_model.sale?.numberOfItems ==
                                                                                0) {
                                                                              logFirebaseEvent('Button_backend_call');
                                                                              await widget.sale!.delete();
                                                                            }
                                                                            logFirebaseEvent('Button_navigate_to');

                                                                            context.goNamed(
                                                                              SalesItemsWidget.routeName,
                                                                              queryParameters: {
                                                                                'sale': serializeParam(
                                                                                  widget.sale,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );

                                                                            if (_shouldSetState)
                                                                              safeSetState(() {});
                                                                          },
                                                                          text:
                                                                              FFLocalizations.of(context).getText(
                                                                            'zs90o1wc' /* Reverse Transaction */,
                                                                          ),
                                                                          options:
                                                                              FFButtonOptions(
                                                                            height:
                                                                                40.0,
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                0.0,
                                                                                24.0,
                                                                                0.0),
                                                                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).error,
                                                                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                                                                                  color: Colors.white,
                                                                                  letterSpacing: 0.0,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
                                                                                ),
                                                                            elevation:
                                                                                3.0,
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Colors.transparent,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
}
