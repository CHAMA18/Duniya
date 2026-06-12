import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
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
import 'package:webviewx_plus/webviewx_plus.dart';
import 'stock_movements_model.dart';
export 'stock_movements_model.dart';

class StockMovementsWidget extends StatefulWidget {
  const StockMovementsWidget({super.key});

  static String routeName = 'StockMovements';
  static String routePath = '/stockMovements';

  @override
  State<StockMovementsWidget> createState() => _StockMovementsWidgetState();
}

class _StockMovementsWidgetState extends State<StockMovementsWidget> {
  late StockMovementsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StockMovementsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StockMovements'});
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
        title: 'Stock Movements',
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
                                      'Stock Movements',
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
                                        _showAddMovementDialog(context);
                                      },
                                      text: 'Add Movement',
                                      icon: Icon(Icons.add, size: 15.0),
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding: EdgeInsetsDirectional
                                            .fromSTEB(0.0, 0.0, 0.0, 0.0),
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
                                    Container(
                                      width: 180.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .movementTypeValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'All',
                                          'RECEIVED',
                                          'SOLD',
                                          'TRANSFERRED',
                                          'ADJUSTMENT',
                                        ],
                                        onChanged: (val) => safeSetState(
                                            () => _model.movementTypeValue =
                                                val),
                                        width: 180.0,
                                        height: 44.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        hintText: 'Movement Type',
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
                                // Table
                                Expanded(
                                  child: AuthUserStreamWidget(
                                    builder: (context) =>
                                        StreamBuilder<List<StockMovementRecord>>(
                                      stream: queryStockMovementRecord(
                                        parent: valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner'
                                            ? currentUserReference
                                            : currentUserDocument?.ownerRef,
                                        queryBuilder: (stockMovementRecord) =>
                                            stockMovementRecord.orderBy(
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
                                        List<StockMovementRecord> movements =
                                            snapshot.data!;
                                        // Apply filters
                                        if (_model.movementTypeValue !=
                                                null &&
                                            _model.movementTypeValue !=
                                                'All') {
                                          movements = movements
                                              .where((m) =>
                                                  m.movementType ==
                                                  _model.movementTypeValue)
                                              .toList();
                                        }
                                        if (movements.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.swap_horiz,
                                                  size: 64.0,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'No stock movements found',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .headlineSmall,
                                                ),
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
                                              Map<String, ProductMasterRecord>
                                                  productMap = {
                                                for (var p
                                                    in productSnapshot.data!)
                                                  p.reference.path: p
                                              };
                                              return SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: SingleChildScrollView(
                                                  child: DataTable(
                                                    headingRowColor:
                                                        MaterialStateProperty
                                                            .all(FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground),
                                                    columns: [
                                                      DataColumn(label: Text('Date', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Product', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Pharmacy', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Type', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Quantity', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Reason', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Reference', style: FlutterFlowTheme.of(context).labelSmall)),
                                                      DataColumn(label: Text('Recorded By', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    ],
                                                    rows: movements
                                                        .map((movement) {
                                                      ProductMasterRecord?
                                                          product = productMap[
                                                              movement
                                                                  .productId
                                                                  ?.path];
                                                      return DataRow(cells: [
                                                        DataCell(Text(
                                                            dateTimeFormat(
                                                              'yyyy-MM-dd',
                                                              movement.createdAt,
                                                              locale: FFLocalizations.of(context).languageCode,
                                                            ),
                                                            style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(Text(
                                                            product?.name ??
                                                                'Unknown',
                                                            style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(Text('-',
                                                            style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(_buildMovementBadge(context, movement.movementType)),
                                                        DataCell(Text(movement.quantity.toString(), style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(Text(movement.reason ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(Text(movement.movementReference ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                                        DataCell(Text('-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                                      ]);
                                                    }).toList(),
                                                  ),
                                                ),
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

  Widget _buildMovementBadge(BuildContext context, String type) {
    Color bgColor;
    Color textColor;
    switch (type) {
      case 'RECEIVED':
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF065F46);
        break;
      case 'SOLD':
        bgColor = Color(0xFFEDE9FE);
        textColor = Color(0xFF6D28D9);
        break;
      case 'TRANSFERRED':
        bgColor = Color(0xFFEDE9FE);
        textColor = Color(0xFF6D28D9);
        break;
      case 'ADJUSTMENT':
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFF92400E);
        break;
      default:
        bgColor = Color(0xFFE9D5FF);
        textColor = Color(0xFF6B21A8);
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

  void _showAddMovementDialog(BuildContext context) {
    _model.dialogQtyTextController ??= TextEditingController();
    _model.dialogReasonTextController ??= TextEditingController();
    _model.dialogReferenceTextController ??= TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Stock Movement'),
          content: Container(
            width: MediaQuery.sizeOf(context).width > 500 ? 500 : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<List<ProductMasterRecord>>(
                    stream: queryProductMasterRecord(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SpinKitRing(
                            color: FlutterFlowTheme.of(context).primary,
                            size: 20.0);
                      }
                      return FlutterFlowDropDown<String>(
                        controller: _model.dialogProductValueController ??=
                            FormFieldController<String>(null),
                        options: snapshot.data!.map((p) => p.name).toList(),
                        onChanged: (val) =>
                            safeSetState(() => _model.dialogProductValue = val),
                        width: double.infinity,
                        height: 44.0,
                        textStyle: FlutterFlowTheme.of(context).bodyMedium,
                        hintText: 'Select Product',
                        fillColor: FlutterFlowTheme.of(context)
                            .secondaryBackground,
                        borderColor: FlutterFlowTheme.of(context).alternate,
                        borderRadius: 8.0,
                        elevation: 2,
                        borderWidth: 1.0,
                        margin: EdgeInsets.zero,
                      );
                    },
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogQtyTextController,
                    focusNode: _model.dialogQtyFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  FlutterFlowDropDown<String>(
                    controller:
                        _model.dialogMovementTypeValueController ??=
                            FormFieldController<String>(null),
                    options: ['RECEIVED', 'SOLD', 'TRANSFERRED', 'ADJUSTMENT'],
                    onChanged: (val) => safeSetState(
                        () => _model.dialogMovementTypeValue = val),
                    width: double.infinity,
                    height: 44.0,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium,
                    hintText: 'Movement Type',
                    fillColor:
                        FlutterFlowTheme.of(context).secondaryBackground,
                    borderColor: FlutterFlowTheme.of(context).alternate,
                    borderRadius: 8.0,
                    elevation: 2,
                    borderWidth: 1.0,
                    margin: EdgeInsets.zero,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogReasonTextController,
                    focusNode: _model.dialogReasonFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Reason (optional)',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.dialogReferenceTextController,
                    focusNode: _model.dialogReferenceFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Reference (optional)',
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FFButtonWidget(
              onPressed: () async {
                // Find the product reference
                final products = await queryProductMasterRecordOnce();
                final product = products.firstWhere(
                  (p) => p.name == _model.dialogProductValue,
                  orElse: () => products.first,
                );
                final ownerRef = valueOrDefault(
                            currentUserDocument?.role, '') ==
                        'Owner'
                    ? currentUserReference!
                    : currentUserDocument!.ownerRef!;
                // Create the StockMovement record
                await StockMovementRecord.createDoc(ownerRef).set(
                    createStockMovementRecordData(
                      productId: product.reference,
                      quantity: int.tryParse(
                              _model.dialogQtyTextController?.text ?? '0') ??
                          0,
                      movementType: _model.dialogMovementTypeValue,
                      reason: _model.dialogReasonTextController?.text,
                      movementReference: _model.dialogReferenceTextController?.text,
                      recordedById: currentUserReference,
                      createdAt: getCurrentTimestamp,
                    ));
                // Clear form
                _model.dialogQtyTextController?.clear();
                _model.dialogReasonTextController?.clear();
                _model.dialogReferenceTextController?.clear();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stock movement recorded successfully')),
                );
              },
              text: 'Save',
              options: FFButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleSmallFamily,
                      color: Colors.white,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        );
      },
    );
  }
}
