import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/item_action_options_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/no_record_component/no_record_component_widget.dart';
import '/unification/components/sale_item_details/sale_item_details_widget.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'pharmacy_inventory_model.dart';
export 'pharmacy_inventory_model.dart';

class PharmacyInventoryWidget extends StatefulWidget {
  const PharmacyInventoryWidget({
    super.key,
    required this.pharmacy,
  });

  final String? pharmacy;

  static String routeName = 'PharmacyInventory';
  static String routePath = '/pharmacyInventory';

  @override
  State<PharmacyInventoryWidget> createState() =>
      _PharmacyInventoryWidgetState();
}

class _PharmacyInventoryWidgetState extends State<PharmacyInventoryWidget> {
  late PharmacyInventoryModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmacyInventoryModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PharmacyInventory'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FinanceRecord>>(
      stream: queryFinanceRecord(
        parent: currentUserReference,
        singleRecord: true,
      ),
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
        List<FinanceRecord> pharmacyInventoryFinanceRecordList = snapshot.data!;
        final pharmacyInventoryFinanceRecord =
            pharmacyInventoryFinanceRecordList.isNotEmpty
                ? pharmacyInventoryFinanceRecordList.first
                : null;

        return Title(
            title: 'PharmacyInventory',
            color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
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
                                'PHARMACY_INVENTORY_chevron_left_rounded_');
                            logFirebaseEvent('IconButton_navigate_back');
                            context.pop();
                          },
                        ),
                        title: Text(
                          '${widget.pharmacy} Details',
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
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
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                              tabletLandscape: false,
                            ))
                              wrapWithModel(
                                model: _model.topNavModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TopNavWidget(
                                  openDrawer: () async {},
                                ),
                              ),
                            Expanded(
                              child: AuthUserStreamWidget(
                                builder: (context) =>
                                    StreamBuilder<List<PharmacyRecord>>(
                                  stream: queryPharmacyRecord(
                                    parent: valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference
                                        : currentUserDocument?.ownerRef,
                                    queryBuilder: (pharmacyRecord) =>
                                        pharmacyRecord.where(
                                      'Name',
                                      isEqualTo: widget.pharmacy,
                                    ),
                                    singleRecord: true,
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 100.0,
                                          height: 100.0,
                                          child: SpinKitRing(
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            size: 100.0,
                                          ),
                                        ),
                                      );
                                    }
                                    List<PharmacyRecord>
                                        mainContentPharmacyRecordList =
                                        snapshot.data!;
                                    final mainContentPharmacyRecord =
                                        mainContentPharmacyRecordList.isNotEmpty
                                            ? mainContentPharmacyRecordList
                                                .first
                                            : null;

                                    return SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 20.0, 20.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (responsiveVisibility(
                                                  context: context,
                                                  phone: false,
                                                ))
                                                  Text(
                                                    '${widget.pharmacy} Pharmacy Details',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 20.0, 20.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (responsiveVisibility(
                                                  context: context,
                                                  phone: false,
                                                ))
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'tyoj0smo' /* Finances */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(-1.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 4.0),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  12.0,
                                                                  0.0,
                                                                  12.0),
                                                      child: Container(
                                                        height: 120.0,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 270.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                child: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .moneyBill,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 32.0,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getText(
                                                                        'bvfok7qx' /* Total Income */,
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelMediumFamily,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                4.0,
                                                                                4.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              'ZMK ${() {
                                                                                if (pharmacyInventoryFinanceRecord?.revenue == null) {
                                                                                  return '0';
                                                                                } else if (pharmacyInventoryFinanceRecord?.revenue != null) {
                                                                                  return pharmacyInventoryFinanceRecord?.revenue.toString();
                                                                                } else {
                                                                                  return pharmacyInventoryFinanceRecord?.revenue.toString();
                                                                                }
                                                                              }()}',
                                                                              style: FlutterFlowTheme.of(context).displaySmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).displaySmallFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).displaySmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  12.0,
                                                                  0.0,
                                                                  12.0),
                                                      child: Container(
                                                        height: 120.0,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 270.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                child: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .arrowDown,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                                  size: 32.0,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getText(
                                                                        'gori8ocp' /* Total Expenses */,
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelMediumFamily,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                4.0,
                                                                                4.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              'ZMK ${() {
                                                                                if (pharmacyInventoryFinanceRecord?.costOfGoods == null) {
                                                                                  return '0';
                                                                                } else if (pharmacyInventoryFinanceRecord?.costOfGoods != null) {
                                                                                  return pharmacyInventoryFinanceRecord?.costOfGoods.toString();
                                                                                } else {
                                                                                  return pharmacyInventoryFinanceRecord?.costOfGoods.toString();
                                                                                }
                                                                              }()}',
                                                                              style: FlutterFlowTheme.of(context).displaySmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).displaySmallFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).displaySmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  12.0,
                                                                  0.0,
                                                                  12.0),
                                                      child: Container(
                                                        height: 120.0,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: 270.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .tag_faces_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2,
                                                                  size: 32.0,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getText(
                                                                        'hhj431k9' /* Total Profit */,
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).labelMediumFamily,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                4.0,
                                                                                4.0,
                                                                                0.0),
                                                                            child:
                                                                                Text(
                                                                              'ZMK ${functions.grossProfit(pharmacyInventoryFinanceRecord?.revenue, pharmacyInventoryFinanceRecord?.costOfGoods).toString()}',
                                                                              style: FlutterFlowTheme.of(context).displaySmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).displaySmallFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).displaySmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                      .divide(
                                                          SizedBox(width: 16.0))
                                                      .addToStart(
                                                          SizedBox(width: 16.0))
                                                      .addToEnd(SizedBox(
                                                          width: 16.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 20.0, 20.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (responsiveVisibility(
                                                  context: context,
                                                  phone: false,
                                                ))
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      't6udpaep' /* Transaction History */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                constraints: BoxConstraints(
                                                  maxWidth: double.infinity,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
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
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 40.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    8.0),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      0.0,
                                                                      10.0,
                                                                      0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child: Text(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getText(
                                                                    'gkqn2iwq' /* Sales ID */,
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodySmallFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                              if (responsiveVisibility(
                                                                context:
                                                                    context,
                                                                phone: false,
                                                              ))
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    FFLocalizations.of(
                                                                            context)
                                                                        .getText(
                                                                      'iem923no' /* Pharmacy */,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              if (responsiveVisibility(
                                                                context:
                                                                    context,
                                                                phone: false,
                                                              ))
                                                                Expanded(
                                                                  child: Text(
                                                                    FFLocalizations.of(
                                                                            context)
                                                                        .getText(
                                                                      '5vkp7484' /* Number of items */,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                child: Text(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getText(
                                                                    'jvqpwcdo' /* Date */,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodySmallFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getText(
                                                                    'aw42yc84' /* Total Amount */,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodySmallFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  16.0),
                                                          child: PagedListView<
                                                              DocumentSnapshot<
                                                                  Object?>?,
                                                              SalesRecord>(
                                                            pagingController: _model
                                                                .setListViewController1(
                                                                    SalesRecord.collection(valueOrDefault(currentUserDocument?.role, '') ==
                                                                                'Owner'
                                                                            ? currentUserReference
                                                                            : currentUserDocument
                                                                                ?.ownerRef)
                                                                        .where(
                                                                      'PharmaID',
                                                                      isEqualTo:
                                                                          mainContentPharmacyRecord
                                                                              ?.reference,
                                                                    ),
                                                                    parent: valueOrDefault(currentUserDocument?.role, '') ==
                                                                            'Owner'
                                                                        ? currentUserReference
                                                                        : currentUserDocument
                                                                            ?.ownerRef),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shrinkWrap: true,
                                                            reverse: false,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            builderDelegate:
                                                                PagedChildBuilderDelegate<
                                                                    SalesRecord>(
                                                              // Customize what your widget looks like when it's loading the first page.
                                                              firstPageProgressIndicatorBuilder:
                                                                  (_) => Center(
                                                                child: SizedBox(
                                                                  width: 100.0,
                                                                  height: 100.0,
                                                                  child:
                                                                      SpinKitRing(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 100.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              // Customize what your widget looks like when it's loading another page.
                                                              newPageProgressIndicatorBuilder:
                                                                  (_) => Center(
                                                                child: SizedBox(
                                                                  width: 100.0,
                                                                  height: 100.0,
                                                                  child:
                                                                      SpinKitRing(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    size: 100.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              noItemsFoundIndicatorBuilder:
                                                                  (_) =>
                                                                      NoRecordComponentWidget(),
                                                              itemBuilder: (context,
                                                                  _,
                                                                  listViewIndex) {
                                                                final listViewSalesRecord = _model
                                                                        .listViewPagingController1!
                                                                        .itemList![
                                                                    listViewIndex];
                                                                return Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          1.0),
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        100.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              0.0,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            1.0,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    child: StreamBuilder<
                                                                        PharmacyRecord>(
                                                                      stream: PharmacyRecord.getDocument(
                                                                          listViewSalesRecord
                                                                              .pharmaID!),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        // Customize what your widget looks like when it's loading.
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return Center(
                                                                            child:
                                                                                SizedBox(
                                                                              width: 100.0,
                                                                              height: 100.0,
                                                                              child: SpinKitRing(
                                                                                color: FlutterFlowTheme.of(context).primary,
                                                                                size: 100.0,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }

                                                                        final saleItemDetailsPharmacyRecord =
                                                                            snapshot.data!;

                                                                        return InkWell(
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            logFirebaseEvent('PHARMACY_INVENTORY_Container_dvitdhv7_ON');
                                                                            logFirebaseEvent('saleItemDetails_navigate_to');

                                                                            context.pushNamed(
                                                                              SalesItemsWidget.routeName,
                                                                              queryParameters: {
                                                                                'sale': serializeParam(
                                                                                  listViewSalesRecord.reference,
                                                                                  ParamType.DocumentReference,
                                                                                ),
                                                                              }.withoutNulls,
                                                                            );
                                                                          },
                                                                          child:
                                                                              SaleItemDetailsWidget(
                                                                            key:
                                                                                Key('Keydvi_${listViewIndex}_of_${_model.listViewPagingController1!.itemList!.length}'),
                                                                            parameter1:
                                                                                listViewSalesRecord.numberOfItems.toString(),
                                                                            parameter2:
                                                                                dateTimeFormat(
                                                                              "d/M h:mm a",
                                                                              listViewSalesRecord.date!,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            parameter3:
                                                                                listViewSalesRecord.totalAmount.toString(),
                                                                            saleId:
                                                                                listViewSalesRecord.reference.id,
                                                                            pharmacy:
                                                                                saleItemDetailsPharmacyRecord.name,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 20.0, 20.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (responsiveVisibility(
                                                  context: context,
                                                  phone: false,
                                                ))
                                                  Text(
                                                    FFLocalizations.of(context)
                                                        .getText(
                                                      'dxcazz1h' /* Inventory */,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .displaySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .displaySmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .displaySmallIsCustom,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 0.0, 0.0, 12.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                8.0),
                                                        topRight:
                                                            Radius.circular(
                                                                8.0),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  16.0,
                                                                  0.0,
                                                                  16.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Text(
                                                            FFLocalizations.of(
                                                                    context)
                                                                .getText(
                                                              'gko3yy4b' /*   */,
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMediumIsCustom,
                                                                ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .getText(
                                                                'm2zctyns' /* Name */,
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .labelMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .labelMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                          if (responsiveVisibility(
                                                            context: context,
                                                            phone: false,
                                                            tablet: false,
                                                          ))
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                FFLocalizations.of(
                                                                        context)
                                                                    .getText(
                                                                  'fa6mj3ba' /* Quantity */,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                          if (responsiveVisibility(
                                                            context: context,
                                                            phone: false,
                                                            tablet: false,
                                                            tabletLandscape:
                                                                false,
                                                          ))
                                                            Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                FFLocalizations.of(
                                                                        context)
                                                                    .getText(
                                                                  'uhitxcmc' /* Expiry Date */,
                                                                ),
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .getText(
                                                                'ddrsrxs2' /* Price */,
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        16.0,
                                                                        0.0),
                                                            child: Text(
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .getText(
                                                                'x1u0c9hd' /* Actions */,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 10.0)),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    child: StreamBuilder<
                                                        List<StockRecord>>(
                                                      stream: queryStockRecord(
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
                                                            (stockRecord) =>
                                                                stockRecord
                                                                    .where(
                                                                      'Quantity',
                                                                      isGreaterThan:
                                                                          1,
                                                                    )
                                                                    .where(
                                                                      'Pharmacy',
                                                                      isEqualTo:
                                                                          widget
                                                                              .pharmacy,
                                                                    ),
                                                      ),
                                                      builder:
                                                          (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Container(
                                                            width:
                                                                double.infinity,
                                                            height: 50.0,
                                                            child:
                                                                ShimmerLoadingCardWidget(),
                                                          );
                                                        }
                                                        List<StockRecord>
                                                            listViewStockRecordList =
                                                            snapshot.data!;

                                                        return ListView
                                                            .separated(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemCount:
                                                              listViewStockRecordList
                                                                  .length,
                                                          separatorBuilder: (_,
                                                                  __) =>
                                                              SizedBox(
                                                                  height: 10.0),
                                                          itemBuilder: (context,
                                                              listViewIndex) {
                                                            final listViewStockRecord =
                                                                listViewStockRecordList[
                                                                    listViewIndex];
                                                            return Container(
                                                              decoration:
                                                                  BoxDecoration(),
                                                              child: InkWell(
                                                                splashColor: Colors
                                                                    .transparent,
                                                                focusColor: Colors
                                                                    .transparent,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap:
                                                                    () async {
                                                                  logFirebaseEvent(
                                                                      'PHARMACY_INVENTORY_Column_tfxx6h5w_ON_TA');
                                                                  logFirebaseEvent(
                                                                      'Column_navigate_to');

                                                                  context
                                                                      .pushNamed(
                                                                    InventoryDetailsWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'stock':
                                                                          serializeParam(
                                                                        listViewStockRecord
                                                                            .reference,
                                                                        ParamType
                                                                            .DocumentReference,
                                                                      ),
                                                                    }.withoutNulls,
                                                                  );
                                                                },
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            listViewStockRecord.name,
                                                                            style: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).labelMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        if (responsiveVisibility(
                                                                          context:
                                                                              context,
                                                                          phone:
                                                                              false,
                                                                          tablet:
                                                                              false,
                                                                        ))
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(
                                                                              listViewStockRecord.quantity.toString(),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        if (responsiveVisibility(
                                                                          context:
                                                                              context,
                                                                          phone:
                                                                              false,
                                                                          tablet:
                                                                              false,
                                                                          tabletLandscape:
                                                                              false,
                                                                        ))
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(
                                                                              dateTimeFormat(
                                                                                "yMMMd",
                                                                                listViewStockRecord.expiryDate!,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text(
                                                                            formatNumber(
                                                                              listViewStockRecord.price,
                                                                              formatType: FormatType.decimal,
                                                                              decimalType: DecimalType.periodDecimal,
                                                                              currency: 'ZMK',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        Builder(
                                                                          builder: (context) =>
                                                                              FlutterFlowIconButton(
                                                                            borderColor:
                                                                                Colors.transparent,
                                                                            borderRadius:
                                                                                20.0,
                                                                            borderWidth:
                                                                                1.0,
                                                                            buttonSize:
                                                                                40.0,
                                                                            icon:
                                                                                Icon(
                                                                              Icons.more_vert,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              size: 24.0,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              logFirebaseEvent('PHARMACY_INVENTORY_more_vert_ICN_ON_TAP');
                                                                              logFirebaseEvent('IconButton_alert_dialog');
                                                                              await showAlignedDialog(
                                                                                context: context,
                                                                                isGlobal: false,
                                                                                avoidOverflow: false,
                                                                                targetAnchor: AlignmentDirectional(1.0, 0.0).resolve(Directionality.of(context)),
                                                                                followerAnchor: AlignmentDirectional(1.0, 0.0).resolve(Directionality.of(context)),
                                                                                builder: (dialogContext) {
                                                                                  return Material(
                                                                                    color: Colors.transparent,
                                                                                    child: WebViewAware(
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(dialogContext).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: ItemActionOptionsWidget(
                                                                                          editCallback: () async {
                                                                                            logFirebaseEvent('_navigate_to');

                                                                                            context.pushNamed(
                                                                                              ItemDetailsWidget.routeName,
                                                                                              queryParameters: {
                                                                                                'item': serializeParam(
                                                                                                  listViewStockRecord.reference,
                                                                                                  ParamType.DocumentReference,
                                                                                                ),
                                                                                              }.withoutNulls,
                                                                                            );
                                                                                          },
                                                                                          deleteCallback: () async {
                                                                                            logFirebaseEvent('_backend_call');

                                                                                            await listViewStockRecord.reference.update(createStockRecordData(
                                                                                              quantity: 0,
                                                                                            ));
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 10.0)),
                                                                    ),
                                                                    Divider(
                                                                      thickness:
                                                                          1.0,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .alternate,
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
                                        ],
                                      ),
                                    );
                                  },
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
