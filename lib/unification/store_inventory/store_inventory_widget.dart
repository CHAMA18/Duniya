import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/tool_button/tool_button_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'store_inventory_model.dart';
export 'store_inventory_model.dart';

class StoreInventoryWidget extends StatefulWidget {
  const StoreInventoryWidget({super.key});

  static String routeName = 'StoreInventory';
  static String routePath = '/storeInventory';

  @override
  State<StoreInventoryWidget> createState() => _StoreInventoryWidgetState();
}

class _StoreInventoryWidgetState extends State<StoreInventoryWidget> {
  late StoreInventoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoreInventoryModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StoreInventory'});
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
        title: 'StoreInventory',
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
                                  'STORE_INVENTORY_Container_4620f2yu_CALLB');
                              logFirebaseEvent('TopNav_drawer');
                              scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 20.0, 0.0, 0.0),
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'nf5modj3' /* Store Inventory */,
                                    ),
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
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      18.0, 0.0, 0.0, 0.0),
                                  child: AuthUserStreamWidget(
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
                                            stockRecord.where(
                                          'Quantity',
                                          isGreaterThanOrEqualTo: 1,
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 100.0,
                                              ),
                                            ),
                                          );
                                        }
                                        List<StockRecord>
                                            dropDownStockRecordList =
                                            snapshot.data!;

                                        return FlutterFlowDropDown<String>(
                                          controller: _model
                                                  .dropDownValueController ??=
                                              FormFieldController<String>(null),
                                          options: dropDownStockRecordList
                                              .map((e) => e.batchNumber)
                                              .toList(),
                                          onChanged: (val) async {
                                            safeSetState(() =>
                                                _model.dropDownValue = val);
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_DropDown_b4yyvb2i_ON_FOR');
                                            var _shouldSetState = false;
                                            logFirebaseEvent(
                                                'DropDown_firestore_query');
                                            _model.drug =
                                                await queryStockRecordOnce(
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
                                              queryBuilder: (stockRecord) =>
                                                  stockRecord.where(
                                                'BatchNumber',
                                                isEqualTo: _model.dropDownValue,
                                              ),
                                              singleRecord: true,
                                            ).then((s) => s.firstOrNull);
                                            _shouldSetState = true;
                                            if (_model.dropDownValue == null ||
                                                _model.dropDownValue == '') {
                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            }
                                            logFirebaseEvent(
                                                'DropDown_navigate_to');

                                            context.pushNamed(
                                              InventoryDetailsWidget.routeName,
                                              queryParameters: {
                                                'stock': serializeParam(
                                                  _model.drug?.reference,
                                                  ParamType.DocumentReference,
                                                ),
                                              }.withoutNulls,
                                            );

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          width: 959.0,
                                          height: 50.0,
                                          searchHintTextStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                          searchTextStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .bodyMedium
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMediumFamily,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMediumIsCustom,
                                              ),
                                          hintText: FFLocalizations.of(context)
                                              .getText(
                                            'oyzhw1w9' /* Search batch number */,
                                          ),
                                          searchHintText:
                                              FFLocalizations.of(context)
                                                  .getText(
                                            'jub34g5j' /* Search for an item... */,
                                          ),
                                          icon: Icon(
                                            Icons.search_sharp,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          elevation: 2.0,
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          borderWidth: 2.0,
                                          borderRadius: 8.0,
                                          margin:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 4.0, 16.0, 4.0),
                                          hidesUnderline: true,
                                          isOverButton: true,
                                          isSearchable: true,
                                          isMultiSelect: false,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 20.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_elm8hojo_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Medicine',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff1 =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm1 =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff1!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Medicine',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm1?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Prescription Medicine',
                                              toolIcon: Icon(
                                                Icons.spoke,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_411thmy9_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Nutrition Suppliments',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff2 =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm2 =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff2!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Nutrition Suppliments',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm1?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Nutrition Suppliments',
                                              toolIcon: Icon(
                                                Icons.medication,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_ggwy2xcm_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Mother and Babycare',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff3 =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm3 =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff3!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Mother and Babycare',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm3?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Mother and Babycare',
                                              toolIcon: Icon(
                                                Icons
                                                    .baby_changing_station_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_7ydy6bob_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Veterinary Products',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff4 =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm4 =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff4!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Veterinary Products',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm4?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Veterinary Products',
                                              toolIcon: Icon(
                                                Icons.cruelty_free_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_hh3er4ef_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Beauty Care',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff5 =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm5 =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff5!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Beauty Care',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm5?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel5,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Beauty\nCare',
                                              toolIcon: Icon(
                                                Icons.face_2_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            logFirebaseEvent(
                                                'STORE_INVENTORY_Container_ulx1dji1_ON_TA');
                                            var _shouldSetState = false;
                                            if (valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner') {
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Personal Care',
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );

                                              if (_shouldSetState)
                                                safeSetState(() {});
                                              return;
                                            } else {
                                              logFirebaseEvent(
                                                  'ToolButton_firestore_query');
                                              _model.staff =
                                                  await queryStaffRecordOnce(
                                                queryBuilder: (staffRecord) =>
                                                    staffRecord.where(
                                                  'Email',
                                                  isEqualTo: currentUserEmail,
                                                ),
                                                singleRecord: true,
                                              ).then((s) => s.firstOrNull);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_backend_call');
                                              _model.pharm =
                                                  await PharmacyRecord
                                                      .getDocumentOnce(_model
                                                          .staff1!.pharmId!);
                                              _shouldSetState = true;
                                              logFirebaseEvent(
                                                  'ToolButton_navigate_to');

                                              context.pushNamed(
                                                InventoryCategoryWidget
                                                    .routeName,
                                                queryParameters: {
                                                  'category': serializeParam(
                                                    'Personal Care',
                                                    ParamType.String,
                                                  ),
                                                  'pharmacy': serializeParam(
                                                    _model.pharm1?.name,
                                                    ParamType.String,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            }

                                            if (_shouldSetState)
                                              safeSetState(() {});
                                          },
                                          child: wrapWithModel(
                                            model: _model.toolButtonModel6,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ToolButtonWidget(
                                              toolName: 'Personal\nCare',
                                              toolIcon: Icon(
                                                Icons.dry_cleaning_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 40.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                          .divide(SizedBox(width: 20.0))
                                          .around(SizedBox(width: 20.0)),
                                    ),
                                  ),
                                ),
                              ],
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
  }
}
