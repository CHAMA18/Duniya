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
import 'stock_count_detail_model.dart';
export 'stock_count_detail_model.dart';

class StockCountDetailWidget extends StatefulWidget {
  const StockCountDetailWidget({
    super.key,
    this.docRef,
  });

  final String? docRef;

  static String routeName = 'StockCountDetail';
  static String routePath = '/stockCountDetail';

  @override
  State<StockCountDetailWidget> createState() =>
      _StockCountDetailWidgetState();
}

class _StockCountDetailWidgetState extends State<StockCountDetailWidget> {
  late StockCountDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Local state for count items
  List<Map<String, dynamic>> _countItems = [];
  String _currentStatus = 'DRAFT';
  DocumentReference? _existingDocRef;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StockCountDetailModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StockCountDetail'});
    _model.notesTextController ??= TextEditingController();

    if (widget.docRef != null) {
      _loadExistingCount();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadExistingCount() async {
    if (widget.docRef == null) return;
    try {
      _existingDocRef = FirebaseFirestore.instance.doc(widget.docRef!);
      final doc = await _existingDocRef!.get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        safeSetState(() {
          _currentStatus = data['Status'] as String? ?? 'DRAFT';
          _model.notesTextController?.text = data['Notes'] as String? ?? '';
        });
        // Load items subcollection
        final itemsSnapshot = await _existingDocRef!
            .collection('StockCountItem')
            .get();
        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();
          _countItems.add({
            'productId': itemData['ProductId'] as DocumentReference?,
            'systemQuantity': itemData['SystemQuantity'] as int? ?? 0,
            'countedQuantity': itemData['CountedQuantity'] as int? ?? 0,
            'variance': itemData['Variance'] as int? ?? 0,
            'reference': itemDoc.reference,
          });
        }
        safeSetState(() {});
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Stock Count Detail',
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
                      buttonSize: 60.0,
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 30.0,
                      ),
                      onPressed: () async {
                        context.pop();
                      },
                    ),
                    title: Text(
                      'Stock Count Detail',
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
                                      Text(
                                        'Stock Count Detail',
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
                                      _buildStatusBadge(context, _currentStatus),
                                    ],
                                  ),
                                  SizedBox(height: 16.0),
                                  // Select Pharmacy/Outlet
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Select Location',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(context)
                                                          .titleMediumFamily,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(context)
                                                          .titleMediumIsCustom,
                                                ),
                                          ),
                                          SizedBox(height: 12.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AuthUserStreamWidget(
                                                  builder: (context) =>
                                                      FutureBuilder<
                                                              List<
                                                                  PharmacyRecord>>(
                                                          future:
                                                              queryPharmacyRecordOnce(
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
                                                              return SpinKitRing(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                size: 20.0,
                                                              );
                                                            }
                                                            return FlutterFlowDropDown<
                                                                String>(
                                                              controller: _model
                                                                      .pharmacyValueController ??=
                                                                  FormFieldController<
                                                                          String>(
                                                                      null),
                                                              options: snapshot
                                                                  .data!
                                                                  .map((p) =>
                                                                      p.name)
                                                                  .toList(),
                                                              onChanged:
                                                                  (val) =>
                                                                      safeSetState(() =>
                                                                          _model.pharmacyValue =
                                                                              val),
                                                              width:
                                                                  double
                                                                      .infinity,
                                                              height: 44.0,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium,
                                                              hintText:
                                                                  'Select Pharmacy',
                                                              fillColor: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              borderColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .alternate,
                                                              borderRadius:
                                                                  8.0,
                                                              elevation: 2,
                                                              borderWidth: 1.0,
                                                              margin: EdgeInsets.zero,
                                                            );
                                                          }),
                                                ),
                                              ),
                                              SizedBox(width: 12.0),
                                              Expanded(
                                                child: FlutterFlowDropDown<
                                                    String>(
                                                  controller: _model
                                                          .outletValueController ??=
                                                      FormFieldController<
                                                              String>(null),
                                                  options: [
                                                    'Main Store',
                                                    'Dispensary',
                                                    'Warehouse',
                                                  ],
                                                  onChanged: (val) =>
                                                      safeSetState(() =>
                                                          _model.outletValue =
                                                              val),
                                                  width: double.infinity,
                                                  height: 44.0,
                                                  textStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium,
                                                  hintText: 'Select Outlet',
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground,
                                                  borderColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .alternate,
                                                  borderRadius: 8.0,
                                                  elevation: 2,
                                                  borderWidth: 1.0,
                                                  margin: EdgeInsets.zero,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  // Load products button
                                  if (_countItems.isEmpty)
                                    FFButtonWidget(
                                      onPressed: () => _loadProducts(),
                                      text: 'Load Products',
                                      icon: Icon(Icons.download, size: 15.0),
                                      options: FFButtonOptions(
                                        height: 44.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24.0, 0.0, 24.0, 0.0),
                                        color:
                                            FlutterFlowTheme.of(context).primary,
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
                                  SizedBox(height: 16.0),
                                  // Count items table
                                  if (_countItems.isNotEmpty) ...[
                                    Container(
                                      width: double.infinity,
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
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: SingleChildScrollView(
                                            child: DataTable(
                                              headingRowColor:
                                                  MaterialStateProperty.all(
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground),
                                              columns: [
                                                DataColumn(label: Text('Product', style: FlutterFlowTheme.of(context).labelSmall)),
                                                DataColumn(label: Text('System Qty', style: FlutterFlowTheme.of(context).labelSmall)),
                                                DataColumn(label: Text('Counted Qty', style: FlutterFlowTheme.of(context).labelSmall)),
                                                DataColumn(label: Text('Variance', style: FlutterFlowTheme.of(context).labelSmall)),
                                              ],
                                              rows: _countItems
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int idx = entry.key;
                                                var item = entry.value;
                                                int variance =
                                                    (item['countedQuantity']
                                                            as int) -
                                                        (item['systemQuantity']
                                                            as int);
                                                return DataRow(cells: [
                                                  DataCell(FutureBuilder<
                                                          ProductMasterRecord?>(
                                                    future: item['productId'] !=
                                                            null
                                                        ? (item['productId']
                                                                as DocumentReference)
                                                            .get()
                                                            .then((s) =>
                                                                ProductMasterRecord
                                                                    .fromSnapshot(
                                                                        s))
                                                        : null,
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        snapshot.hasData
                                                            ? snapshot.data!
                                                                .name
                                                            : 'Loading...',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium,
                                                      );
                                                    },
                                                  )),
                                                  DataCell(Text(
                                                      item['systemQuantity']
                                                          .toString(),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium)),
                                                  DataCell(Container(
                                                    width: 80.0,
                                                    child: TextFormField(
                                                      initialValue:
                                                          (item['countedQuantity']
                                                                  as int)
                                                              .toString(),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium,
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                        filled: true,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryBackground,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.0),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        int? parsed =
                                                            int.tryParse(
                                                                value);
                                                        if (parsed != null) {
                                                          safeSetState(() {
                                                            _countItems[idx][
                                                                    'countedQuantity'] =
                                                                parsed;
                                                            _countItems[idx][
                                                                    'variance'] =
                                                                parsed -
                                                                    (item['systemQuantity']
                                                                        as int);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  )),
                                                  DataCell(Text(
                                                    variance.toString(),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: variance == 0
                                                              ? FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText
                                                              : variance < 0
                                                                  ? Color(
                                                                      0xFFE53E3E)
                                                                  : Color(
                                                                      0xFF38A169),
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  )),
                                                ]);
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    // Notes
                                    TextFormField(
                                      controller: _model.notesTextController,
                                      focusNode: _model.notesFocusNode,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: 'Notes',
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                    ),
                                    SizedBox(height: 16.0),
                                    // Action buttons
                                    Wrap(
                                      spacing: 12.0,
                                      runSpacing: 8.0,
                                      children: [
                                        if (_currentStatus == 'DRAFT')
                                          FFButtonWidget(
                                            onPressed: () async {
                                              await _submitCount();
                                            },
                                            text: 'Submit Count',
                                            icon: Icon(Icons.send, size: 15.0),
                                            options: FFButtonOptions(
                                              height: 44.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 0.0, 24.0, 0.0),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
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
                                        if (_currentStatus == 'SUBMITTED')
                                          FFButtonWidget(
                                            onPressed: () async {
                                              await _approveCount();
                                            },
                                            text: 'Approve',
                                            icon:
                                                Icon(Icons.check, size: 15.0),
                                            options: FFButtonOptions(
                                              height: 44.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 0.0, 24.0, 0.0),
                                              color: Color(0xFF38A169),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
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
                                        if (_currentStatus == 'SUBMITTED')
                                          FFButtonWidget(
                                            onPressed: () async {
                                              await _rejectCount();
                                            },
                                            text: 'Reject',
                                            icon: Icon(Icons.close, size: 15.0),
                                            options: FFButtonOptions(
                                              height: 44.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 0.0, 24.0, 0.0),
                                              color: Color(0xFFE53E3E),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
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
                                  ],
                                  SizedBox(height: 24.0),
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'DRAFT':
        bgColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF1F2937);
        break;
      case 'SUBMITTED':
        bgColor = Color(0xFFF9FAFB);
        textColor = Color(0xFF374151);
        break;
      case 'APPROVED':
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF065F46);
        break;
      case 'REJECTED':
        bgColor = Color(0xFFFEE2E2);
        textColor = Color(0xFF991B1B);
        break;
      default:
        bgColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF1F2937);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
            ),
      ),
    );
  }

  Future<void> _loadProducts() async {
    final products = await queryProductMasterRecordOnce();
    safeSetState(() {
      _countItems = products
          .where((p) => p.isActive)
          .map((p) => {
                'productId': p.reference,
                'systemQuantity': 0,
                'countedQuantity': 0,
                'variance': 0,
              })
          .toList();
    });
    // Also load stock balances for system quantity
    final ownerRef = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;
    final balances = await queryStockBalanceRecordOnce(parent: ownerRef);
    for (var balance in balances) {
      for (var item in _countItems) {
        if (item['productId']?.path == balance.productId?.path) {
          item['systemQuantity'] = balance.closingStock;
          item['variance'] =
              (item['countedQuantity'] as int) - balance.closingStock;
        }
      }
    }
    safeSetState(() {});
  }

  Future<void> _submitCount() async {
    final ownerRef = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;

    DocumentReference countDoc;
    if (_existingDocRef != null) {
      countDoc = _existingDocRef!;
    } else {
      countDoc = StockCountRecord.createDoc(ownerRef);
    }

    await countDoc.set(createStockCountRecordData(
      countedById: currentUserReference,
      countDate: getCurrentTimestamp,
      status: 'SUBMITTED',
      notes: _model.notesTextController?.text,
      createdAt: getCurrentTimestamp,
      updatedAt: getCurrentTimestamp,
    ));

    // Save/update items
    for (var item in _countItems) {
      final itemDoc = StockCountItemRecord.createDoc(countDoc);
      await itemDoc.set(createStockCountItemRecordData(
        productId: item['productId'] as DocumentReference?,
        systemQuantity: item['systemQuantity'] as int,
        countedQuantity: item['countedQuantity'] as int,
        variance: (item['countedQuantity'] as int) -
            (item['systemQuantity'] as int),
      ));
    }

    safeSetState(() {
      _currentStatus = 'SUBMITTED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock count submitted successfully')),
    );
  }

  Future<void> _approveCount() async {
    if (_existingDocRef == null) return;
    await _existingDocRef!.update({
      'Status': 'APPROVED',
      'UpdatedAt': getCurrentTimestamp,
    });

    // Create ADJUSTMENT stock movements for variances
    final ownerRef = valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;

    for (var item in _countItems) {
      int variance =
          (item['countedQuantity'] as int) - (item['systemQuantity'] as int);
      if (variance != 0) {
        final movementDoc = StockMovementRecord.createDoc(ownerRef);
        await movementDoc.set(createStockMovementRecordData(
          productId: item['productId'] as DocumentReference?,
          quantity: variance.abs(),
          movementType: 'ADJUSTMENT',
          reason: 'Stock count adjustment',
          movementReference: _existingDocRef!.path,
          recordedById: currentUserReference,
          createdAt: getCurrentTimestamp,
        ));
      }
    }

    safeSetState(() {
      _currentStatus = 'APPROVED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock count approved')),
    );
  }

  Future<void> _rejectCount() async {
    if (_existingDocRef == null) return;
    await _existingDocRef!.update({
      'Status': 'REJECTED',
      'UpdatedAt': getCurrentTimestamp,
    });
    safeSetState(() {
      _currentStatus = 'REJECTED';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stock count rejected')),
    );
  }
}
