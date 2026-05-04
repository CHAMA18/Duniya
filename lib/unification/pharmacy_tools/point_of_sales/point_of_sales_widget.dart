import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/cart/cart_widget.dart';
import '/unification/components/counter/counter_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'point_of_sales_model.dart';
export 'point_of_sales_model.dart';

class PointOfSalesWidget extends StatefulWidget {
  const PointOfSalesWidget({
    super.key,
    this.pharm,
  });

  final String? pharm;

  static String routeName = 'PointOfSales';
  static String routePath = '/pointOfSales';

  @override
  State<PointOfSalesWidget> createState() => _PointOfSalesWidgetState();
}

class _PointOfSalesWidgetState extends State<PointOfSalesWidget> {
  late PointOfSalesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PointOfSalesModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PointOfSales'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('POINT_OF_SALES_PointOfSales_ON_INIT_STAT');
      logFirebaseEvent('PointOfSales_firestore_query');
      _model.pharmCopy2 = await queryPharmacyRecordOnce(
        parent: currentUserReference,
        queryBuilder: (pharmacyRecord) => pharmacyRecord.where(
          'Name',
          isEqualTo: _model.pharmacyDropDownValue,
        ),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      logFirebaseEvent('PointOfSales_update_app_state');
      FFAppState().updateCartStruct(
        (e) => e
          ..displayName = []
          ..quantity = []
          ..price = []
          ..pharmId = _model.pharmCopy2?.reference,
      );
      FFAppState().update(() {});
    });

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

    return Title(
        title: 'PointOfSales',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            endDrawer: Container(
              width: 350.0,
              child: Drawer(
                elevation: 16.0,
                child: WebViewAware(
                  child: wrapWithModel(
                    model: _model.cartModel,
                    updateCallback: () => safeSetState(() {}),
                    child: CartWidget(),
                  ),
                ),
              ),
            ),
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
                            'POINT_OF_SALES_chevron_left_rounded_ICN_');
                        logFirebaseEvent('IconButton_navigate_back');
                        context.pop();
                      },
                    ),
                    title: Text(
                      FFLocalizations.of(context).getText(
                        '73rf8gql' /* Point of Sale */,
                      ),
                      style:
                          FlutterFlowTheme.of(context).headlineMedium.override(
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (responsiveVisibility(
                    context: context,
                    phone: false,
                    tablet: false,
                  ))
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FFButtonWidget(
                            onPressed: () async {
                              logFirebaseEvent(
                                  'POINT_OF_SALES_PAGE_BACK_BTN_ON_TAP');
                              logFirebaseEvent('Button_navigate_to');

                              context.pushNamed(HomeWidget.routeName);
                            },
                            text: FFLocalizations.of(context).getText(
                              'a9rlna7d' /* Back */,
                            ),
                            icon: Icon(
                              Icons.chevron_left_rounded,
                              size: 15.0,
                            ),
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconColor: FlutterFlowTheme.of(context).secondary,
                              color: Colors.transparent,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleSmallIsCustom,
                                  ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'ykvei3pa' /* Point of Sale */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .displaySmall
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .displaySmallFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .displaySmallIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 30.0)),
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 0.0,
                                      runSpacing: 16.0,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      direction: Axis.horizontal,
                                      runAlignment: WrapAlignment.start,
                                      verticalDirection: VerticalDirection.down,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AuthUserStreamWidget(
                                              builder: (context) =>
                                                  StreamBuilder<
                                                      List<PharmacyRecord>>(
                                                stream: queryPharmacyRecord(
                                                  parent: currentUserReference,
                                                )..listen((snapshot) {
                                                    List<PharmacyRecord>
                                                        pharmacyDropDownPharmacyRecordList =
                                                        snapshot;
                                                    if (_model.pharmacyDropDownPreviousSnapshot !=
                                                            null &&
                                                        !const ListEquality(
                                                                PharmacyRecordDocumentEquality())
                                                            .equals(
                                                                pharmacyDropDownPharmacyRecordList,
                                                                _model
                                                                    .pharmacyDropDownPreviousSnapshot)) {
                                                      () async {
                                                        logFirebaseEvent(
                                                            'POINT_OF_SALES_PharmacyDropDown_ON_DATA_');
                                                        logFirebaseEvent(
                                                            'PharmacyDropDown_firestore_query');
                                                        _model.pharmCopy =
                                                            await queryPharmacyRecordOnce(
                                                          parent:
                                                              currentUserReference,
                                                          queryBuilder:
                                                              (pharmacyRecord) =>
                                                                  pharmacyRecord
                                                                      .where(
                                                            'Name',
                                                            isEqualTo: _model
                                                                .pharmacyDropDownValue,
                                                          ),
                                                          singleRecord: true,
                                                        ).then((s) =>
                                                                s.firstOrNull);
                                                        logFirebaseEvent(
                                                            'PharmacyDropDown_update_app_state');
                                                        FFAppState()
                                                            .updateCartStruct(
                                                          (e) => e
                                                            ..displayName = []
                                                            ..quantity = []
                                                            ..price = []
                                                            ..pharmId = _model
                                                                .pharmCopy
                                                                ?.reference,
                                                        );
                                                        FFAppState()
                                                            .update(() {});

                                                        safeSetState(() {});
                                                      }();
                                                    }
                                                    _model.pharmacyDropDownPreviousSnapshot =
                                                        snapshot;
                                                  }),
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
                                                  List<PharmacyRecord>
                                                      pharmacyDropDownPharmacyRecordList =
                                                      snapshot.data!;

                                                  return FlutterFlowDropDown<
                                                      String>(
                                                    controller: _model
                                                            .pharmacyDropDownValueController ??=
                                                        FormFieldController<
                                                            String>(
                                                      _model.pharmacyDropDownValue ??=
                                                          widget.pharm !=
                                                                      null &&
                                                                  widget.pharm !=
                                                                      ''
                                                              ? widget.pharm
                                                              : pharmacyDropDownPharmacyRecordList
                                                                  .firstOrNull
                                                                  ?.name,
                                                    ),
                                                    options:
                                                        pharmacyDropDownPharmacyRecordList
                                                            .map((e) => e.name)
                                                            .toList(),
                                                    onChanged: (val) async {
                                                      safeSetState(() => _model
                                                              .pharmacyDropDownValue =
                                                          val);
                                                      logFirebaseEvent(
                                                          'POINT_OF_SALES_PharmacyDropDown_ON_FORM_');
                                                      logFirebaseEvent(
                                                          'PharmacyDropDown_firestore_query');
                                                      _model.pharm =
                                                          await queryPharmacyRecordOnce(
                                                        parent:
                                                            currentUserReference,
                                                        queryBuilder:
                                                            (pharmacyRecord) =>
                                                                pharmacyRecord
                                                                    .where(
                                                          'Name',
                                                          isEqualTo: _model
                                                              .pharmacyDropDownValue,
                                                        ),
                                                        singleRecord: true,
                                                      ).then((s) =>
                                                              s.firstOrNull);
                                                      logFirebaseEvent(
                                                          'PharmacyDropDown_update_app_state');
                                                      FFAppState()
                                                          .updateCartStruct(
                                                        (e) => e
                                                          ..displayName = []
                                                          ..quantity = []
                                                          ..price = []
                                                          ..pharmId = _model
                                                              .pharm?.reference,
                                                      );
                                                      FFAppState()
                                                          .update(() {});

                                                      safeSetState(() {});
                                                    },
                                                    width: MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            1100.0
                                                        ? 200.0
                                                        : 400.0,
                                                    height: 50.0,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                              letterSpacing:
                                                                  0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumIsCustom,
                                                            ),
                                                    hintText: widget.pharm !=
                                                                null &&
                                                            widget.pharm != ''
                                                        ? widget.pharm
                                                        : pharmacyDropDownPharmacyRecordList
                                                            .firstOrNull?.name,
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 24.0,
                                                    ),
                                                    fillColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                    elevation: 2.0,
                                                    borderColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .alternate,
                                                    borderWidth: 0.0,
                                                    borderRadius: 8.0,
                                                    margin:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 4.0,
                                                                16.0, 4.0),
                                                    hidesUnderline: true,
                                                    disabled: valueOrDefault(
                                                            currentUserDocument
                                                                ?.role,
                                                            '') !=
                                                        'Owner',
                                                    isSearchable: false,
                                                    isMultiSelect: false,
                                                  );
                                                },
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                        FFButtonWidget(
                                          onPressed: () async {
                                            logFirebaseEvent(
                                                'POINT_OF_SALES_PAGE_BUTTON_BTN_ON_TAP');
                                            logFirebaseEvent('Button_drawer');
                                            scaffoldKey.currentState!
                                                .openEndDrawer();
                                          },
                                          text:
                                              'Checkout: K${functions.cartTotal(FFAppState().Cart.price.toList(), FFAppState().Cart.quantity.toList()).toString()}',
                                          options: FFButtonOptions(
                                            height: 40.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 0.0, 24.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallFamily,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      letterSpacing: 0.0,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmallIsCustom,
                                                    ),
                                            borderSide: BorderSide(
                                              color: Colors.transparent,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1.0,
                                color: FlutterFlowTheme.of(context).accent4,
                              ),
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AuthUserStreamWidget(
                                      builder: (context) =>
                                          StreamBuilder<List<StockRecord>>(
                                        stream: queryStockRecord(
                                          parent: () {
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              return currentUserReference;
                                            } else if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') !=
                                                'Owner') {
                                              return currentUserDocument
                                                  ?.ownerRef;
                                            } else {
                                              return currentUserDocument
                                                  ?.ownerRef;
                                            }
                                          }(),
                                          queryBuilder: (stockRecord) =>
                                              stockRecord
                                                  .where(
                                                    'Pharmacy',
                                                    isEqualTo: widget.pharm !=
                                                                null &&
                                                            widget.pharm != ''
                                                        ? widget.pharm
                                                        : _model.pharmacyDropDownValue !=
                                                                ''
                                                            ? widget.pharm !=
                                                                        null &&
                                                                    widget.pharm !=
                                                                        ''
                                                                ? widget.pharm
                                                                : _model
                                                                    .pharmacyDropDownValue
                                                            : null,
                                                  )
                                                  .where(
                                                    'Quantity',
                                                    isGreaterThan: 1,
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  size: 100.0,
                                                ),
                                              ),
                                            );
                                          }
                                          List<StockRecord>
                                              wrapStockRecordList =
                                              snapshot.data!;

                                          return Wrap(
                                            spacing: 16.0,
                                            runSpacing: 16.0,
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            direction: Axis.horizontal,
                                            runAlignment: WrapAlignment.start,
                                            verticalDirection:
                                                VerticalDirection.down,
                                            clipBehavior: Clip.none,
                                            children: List.generate(
                                                wrapStockRecordList.length,
                                                (wrapIndex) {
                                              final wrapStockRecord =
                                                  wrapStockRecordList[
                                                      wrapIndex];
                                              return Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                                .width >
                                                            1100.0
                                                        ? 250.0
                                                        : double.infinity,
                                                height: 250.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent4,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Stack(
                                                            children: [
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Medicine')
                                                                Icon(
                                                                  Icons.spoke,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Nutrition Suppliments')
                                                                Icon(
                                                                  Icons
                                                                      .medication_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Veterinary Products')
                                                                Icon(
                                                                  Icons
                                                                      .cruelty_free_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Beauty Care')
                                                                Icon(
                                                                  Icons
                                                                      .face_2_sharp,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Mother and Babycare')
                                                                Icon(
                                                                  Icons
                                                                      .baby_changing_station_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                              if (wrapStockRecord
                                                                      .category ==
                                                                  'Personal Care')
                                                                Icon(
                                                                  Icons
                                                                      .dry_cleaning_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 24.0,
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            wrapStockRecord
                                                                .name,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .headlineMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineMediumIsCustom,
                                                                ),
                                                          ),
                                                          Text(
                                                            '${formatNumber(
                                                              wrapStockRecord
                                                                  .price,
                                                              formatType:
                                                                  FormatType
                                                                      .decimal,
                                                              decimalType:
                                                                  DecimalType
                                                                      .periodDecimal,
                                                              currency: 'K',
                                                            )} Exp: ${dateTimeFormat(
                                                              "yMMMd",
                                                              wrapStockRecord
                                                                  .expiryDate,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            )}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    1.0, 1.0),
                                                            child:
                                                                CounterWidget(
                                                              key: Key(
                                                                  'Key89a_${wrapIndex}_of_${wrapStockRecordList.length}'),
                                                              parameter1:
                                                                  wrapStockRecord
                                                                      .name,
                                                              parameter3:
                                                                  wrapStockRecord
                                                                      .price,
                                                              productQuantity:
                                                                  wrapStockRecord
                                                                      .quantity,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ].divide(SizedBox(height: 10.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
