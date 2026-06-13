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
import 'sales_vmi_model.dart';
export 'sales_vmi_model.dart';

class SalesVMIWidget extends StatefulWidget {
  const SalesVMIWidget({super.key});

  static String routeName = 'SalesVMI';
  static String routePath = '/salesVMI';

  @override
  State<SalesVMIWidget> createState() => _SalesVMIWidgetState();
}

class _SalesVMIWidgetState extends State<SalesVMIWidget> {
  late SalesVMIModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Sale line items
  List<Map<String, dynamic>> _saleLineItems = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SalesVMIModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'SalesVMI'});
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
        title: 'Sales / Dispensing',
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
                                      'Sales / Dispensing',
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
                                      onPressed: () =>
                                          _showAddSaleDialog(context),
                                      text: 'Add Sale',
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
                                Expanded(
                                  child: AuthUserStreamWidget(
                                    builder: (context) =>
                                        StreamBuilder<List<SaleRecordVMI>>(
                                      stream: querySaleRecordVMI(
                                        parent: valueOrDefault(
                                                    currentUserDocument?.role,
                                                    '') ==
                                                'Owner'
                                            ? currentUserReference
                                            : currentUserDocument?.ownerRef,
                                        queryBuilder: (saleRecordVMI) =>
                                            saleRecordVMI.orderBy('CreatedAt',
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
                                        List<SaleRecordVMI> sales =
                                            snapshot.data!;
                                        if (sales.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.point_of_sale,
                                                    size: 64.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText),
                                                SizedBox(height: 16.0),
                                                Text('No sales recorded',
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
                                          itemCount: sales.length,
                                          itemBuilder: (context, index) {
                                            SaleRecordVMI sale = sales[index];
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
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
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              sale.hasPatientRef()
                                                                  ? 'Patient: ${sale.patientRef!}'
                                                                  : 'Sale #${index + 1}',
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
                                                            SizedBox(height: 4.0),
                                                            Text(
                                                              sale.hasSaleDate()
                                                                  ? dateTimeFormat(
                                                                      'yyyy-MM-dd HH:mm',
                                                                      sale.saleDate!,
                                                                      locale: FFLocalizations.of(context).languageCode,
                                                                    )
                                                                  : '-',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        formatNumber(
                                                          sale.totalAmount,
                                                          formatType: FormatType
                                                              .decimal,
                                                          decimalType:
                                                              DecimalType
                                                                  .periodDecimal,
                                                        ),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .titleMedium
                                                            .override(
                                                              fontFamily:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumFamily,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              letterSpacing: 0.0,
                                                              useGoogleFonts:
                                                                  !FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMediumIsCustom,
                                                            ),
                                                      ),
                                                    ],
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

  void _showAddSaleDialog(BuildContext context) {
    _saleLineItems = [];
    _model.dialogPatientRefTextController ??= TextEditingController();
    _model.lineQtyTextController ??= TextEditingController();
    _model.linePriceTextController ??= TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Sale'),
              content: Container(
                width: MediaQuery.sizeOf(context).width > 600
                    ? 600
                    : double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthUserStreamWidget(
                        builder: (context) =>
                            FutureBuilder<List<PharmacyRecord>>(
                          future: queryPharmacyRecordOnce(
                            parent: valueOrDefault(
                                        currentUserDocument?.role,
                                        '') ==
                                    'Owner'
                                ? currentUserReference
                                : currentUserDocument?.ownerRef,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SpinKitRing(
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20.0);
                            }
                            return FlutterFlowDropDown<String>(
                              controller:
                                  _model.dialogPharmacyValueController ??=
                                      FormFieldController<String>(null),
                              options:
                                  snapshot.data!.map((p) => p.name).toList(),
                              onChanged: (val) => setDialogState(
                                  () => _model.dialogPharmacyValue = val),
                              width: double.infinity,
                              height: 44.0,
                              textStyle:
                                  FlutterFlowTheme.of(context).bodyMedium,
                              hintText: 'Select Pharmacy',
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderColor:
                                  FlutterFlowTheme.of(context).alternate,
                              borderRadius: 8.0,
                              elevation: 2,
                              borderWidth: 1.0,
                              margin: EdgeInsets.zero,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: _model.dialogPatientRefTextController,
                        decoration: InputDecoration(
                          labelText: 'Patient Reference',
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      SizedBox(height: 16.0),
                      Text('Line Items',
                          style: FlutterFlowTheme.of(context).titleSmall),
                      SizedBox(height: 8.0),
                      // Add line item row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: StreamBuilder<List<ProductMasterRecord>>(
                              stream: queryProductMasterRecord(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return SpinKitRing(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 16.0);
                                }
                                return FlutterFlowDropDown<String>(
                                  controller:
                                      _model.lineProductValueController ??=
                                          FormFieldController<String>(null),
                                  options: snapshot.data!
                                      .map((p) => p.name)
                                      .toList(),
                                  onChanged: (val) => setDialogState(
                                      () => _model.lineProductValue = val),
                                  width: double.infinity,
                                  height: 40.0,
                                  textStyle:
                                      FlutterFlowTheme.of(context).bodySmall,
                                  hintText: 'Product',
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  borderRadius: 8.0,
                                  elevation: 2,
                                  borderWidth: 1.0,
                                  margin: EdgeInsets.zero,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Container(
                            width: 60.0,
                            child: TextFormField(
                              controller: _model.lineQtyTextController,
                              decoration: InputDecoration(
                                hintText: 'Qty',
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8.0)),
                              ),
                              keyboardType: TextInputType.number,
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                          ),
                          SizedBox(width: 4.0),
                          Container(
                            width: 80.0,
                            child: TextFormField(
                              controller: _model.linePriceTextController,
                              decoration: InputDecoration(
                                hintText: 'Price',
                                filled: true,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(8.0)),
                              ),
                              keyboardType: TextInputType.number,
                              style: FlutterFlowTheme.of(context).bodySmall,
                            ),
                          ),
                          SizedBox(width: 4.0),
                          IconButton(
                            icon: Icon(Icons.add_circle,
                                color: FlutterFlowTheme.of(context).primary),
                            onPressed: () async {
                              if (_model.lineProductValue == null) return;
                              final products =
                                  await queryProductMasterRecordOnce();
                              final product = products.firstWhere(
                                (p) =>
                                    p.name ==
                                    _model.lineProductValue,
                                orElse: () => products.first,
                              );
                              int qty = int.tryParse(
                                      _model.lineQtyTextController?.text ??
                                          '0') ??
                                  0;
                              double price = double.tryParse(
                                      _model.linePriceTextController
                                              ?.text ??
                                          '0') ??
                                  0.0;
                              setDialogState(() {
                                _saleLineItems.add({
                                  'productId': product.reference,
                                  'productName': product.name,
                                  'quantity': qty,
                                  'sellingPrice': price,
                                  'total': qty * price,
                                });
                              });
                              _model.lineQtyTextController?.clear();
                              _model.linePriceTextController?.clear();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      // List of added items
                      ..._saleLineItems
                          .asMap()
                          .entries
                          .map((entry) {
                        int idx = entry.key;
                        var item = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['productName'],
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall),
                                Text(
                                    'x${item['quantity']} @ ${item['sellingPrice'].toStringAsFixed(2)} = ${item['total'].toStringAsFixed(2)}',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall),
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      size: 16.0,
                                      color: Color(0xFFE53E3E)),
                                  onPressed: () {
                                    setDialogState(() {
                                      _saleLineItems.removeAt(idx);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
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
                    if (_saleLineItems.isEmpty) return;
                    final ownerRef =
                        valueOrDefault(currentUserDocument?.role, '') ==
                                'Owner'
                            ? currentUserReference!
                            : currentUserDocument!.ownerRef!;

                    double totalAmount = _saleLineItems.fold(
                        0.0, (sum, item) => sum + (item['total'] as double));

                    // Create SaleVMI record
                    final saleDoc =
                        SaleRecordVMI.createDoc(ownerRef);
                    await saleDoc.set(createSaleRecordVMIData(
                      soldById: currentUserReference,
                      saleDate: getCurrentTimestamp,
                      patientRef:
                          _model.dialogPatientRefTextController?.text,
                      totalAmount: totalAmount,
                      createdAt: getCurrentTimestamp,
                    ));

                    // Create SaleItemVMI records and StockMovements
                    for (var item in _saleLineItems) {
                      final itemDoc =
                          SaleItemVMIRecord.createDoc(saleDoc);
                      await itemDoc.set(createSaleItemVMIRecordData(
                        productId: item['productId'] as DocumentReference?,
                        quantity: item['quantity'] as int,
                        sellingPrice: item['sellingPrice'] as double,
                        total: item['total'] as double,
                      ));

                      // Create StockMovement (SOLD type)
                      final movementDoc =
                          StockMovementRecord.createDoc(ownerRef);
                      await movementDoc.set(
                          createStockMovementRecordData(
                        productId:
                            item['productId'] as DocumentReference?,
                        quantity: item['quantity'] as int,
                        movementType: 'SOLD',
                        recordedById: currentUserReference,
                        createdAt: getCurrentTimestamp,
                      ));
                    }

                    _model.dialogPatientRefTextController?.clear();
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Sale recorded successfully')),
                    );
                  },
                  text: 'Record Sale',
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context)
                        .titleSmall
                        .override(
                          fontFamily: FlutterFlowTheme.of(context)
                              .titleSmallFamily,
                          color: Colors.white,
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .titleSmallIsCustom,
                        ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
