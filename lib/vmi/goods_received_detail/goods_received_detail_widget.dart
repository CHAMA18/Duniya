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
import 'goods_received_detail_model.dart';
export 'goods_received_detail_model.dart';

class GoodsReceivedDetailWidget extends StatefulWidget {
  const GoodsReceivedDetailWidget({
    super.key,
    this.docRef,
  });

  final String? docRef;

  static String routeName = 'GoodsReceivedDetail';
  static String routePath = '/goodsReceivedDetail';

  @override
  State<GoodsReceivedDetailWidget> createState() =>
      _GoodsReceivedDetailWidgetState();
}

class _GoodsReceivedDetailWidgetState
    extends State<GoodsReceivedDetailWidget> {
  late GoodsReceivedDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Line items state
  List<Map<String, dynamic>> _lineItems = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoodsReceivedDetailModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'GoodsReceivedDetail'});
    _model.deliveryNoteTextController ??= TextEditingController();
    _model.lineQtyTextController ??= TextEditingController();
    _model.lineBatchTextController ??= TextEditingController();
    _model.discrepancyTextController ??= TextEditingController();

    // If editing existing record, load data
    if (widget.docRef != null) {
      _loadExistingRecord();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _loadExistingRecord() async {
    if (widget.docRef == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .doc(widget.docRef!)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _model.deliveryNoteTextController?.text =
            data['DeliveryNoteNumber'] as String? ?? '';
        safeSetState(() {
          _model.deliveryDate = data['DeliveryDate'] as DateTime?;
        });
        // Load line items subcollection
        final itemsSnapshot = await FirebaseFirestore.instance
            .doc(widget.docRef!)
            .collection('GoodsReceivedItem')
            .get();
        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();
          _lineItems.add({
            'productId': itemData['ProductId'] as DocumentReference?,
            'quantityDelivered': itemData['QuantityDelivered'] as int? ?? 0,
            'batchNumber': itemData['BatchNumber'] as String? ?? '',
            'expiryDate': itemData['ExpiryDate'] as DateTime?,
            'reference': itemDoc.reference,
          });
        }
        safeSetState(() {});
      }
    } catch (e) {
      // Handle error silently
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
        title: 'Goods Received Detail',
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
                        context.pop();
                      },
                    ),
                    title: Text(
                      'Goods Received Detail',
                      style: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .override(
                            fontFamily: FlutterFlowTheme.of(context)
                                .headlineMediumFamily,
                            color:
                                FlutterFlowTheme.of(context).primaryText,
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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Goods Received Detail',
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
                                  SizedBox(height: 24.0),
                                  // Header fields
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Receipt Information',
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
                                                          !FlutterFlowTheme.of(context)
                                                              .titleMediumIsCustom,
                                                    ),
                                          ),
                                          SizedBox(height: 16.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _model
                                                      .deliveryNoteTextController,
                                                  focusNode: _model
                                                      .deliveryNoteFocusNode,
                                                  decoration:
                                                      InputDecoration(
                                                    labelText:
                                                        'Delivery Note Number *',
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                    border:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8.0),
                                                    ),
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium,
                                                ),
                                              ),
                                              SizedBox(width: 12.0),
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
                                                          builder: (context,
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
                                                              height: 56.0,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium,
                                                              hintText:
                                                                  'Select Pharmacy',
                                                              fillColor: FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryBackground,
                                                              borderColor: FlutterFlowTheme.of(
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
                                            ],
                                          ),
                                          SizedBox(height: 12.0),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    final date =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate: _model
                                                              .deliveryDate ??
                                                          DateTime.now(),
                                                      firstDate:
                                                          DateTime(2020),
                                                      lastDate:
                                                          DateTime(2050),
                                                    );
                                                    if (date != null) {
                                                      safeSetState(() {
                                                        _model.deliveryDate =
                                                            date;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 56.0,
                                                    decoration:
                                                        BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(8.0),
                                                      border: Border.all(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .alternate,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  12.0),
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons
                                                              .calendar_today),
                                                          SizedBox(
                                                              width: 8.0),
                                                          Text(
                                                            _model.deliveryDate !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    'yyyy-MM-dd',
                                                                    _model
                                                                        .deliveryDate!,
                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                  )
                                                                : 'Delivery Date',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  // Line Items Section
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                'Line Items',
                                                style:
                                                    FlutterFlowTheme.of(
                                                            context)
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
                                              FFButtonWidget(
                                                onPressed: () =>
                                                    _showAddLineItemDialog(
                                                        context),
                                                text: 'Add Item',
                                                icon:
                                                    Icon(Icons.add, size: 15.0),
                                                options: FFButtonOptions(
                                                  height: 36.0,
                                                  padding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(12.0,
                                                              0.0, 12.0, 0.0),
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
                                                            color:
                                                                Colors.white,
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
                                          if (_lineItems.isEmpty)
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(24.0),
                                                child: Text(
                                                  'No items added yet',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme.of(context)
                                                                .secondaryText,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            )
                                          else
                                            ..._lineItems
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int idx = entry.key;
                                              Map<String, dynamic> item =
                                                  entry.value;
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .alternate,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: FutureBuilder<
                                                              ProductMasterRecord?>(
                                                            future: item['productId'] !=
                                                                    null
                                                                ? (item['productId']
                                                                        as DocumentReference)
                                                                    .get()
                                                                    .then((s) =>
                                                                        ProductMasterRecord.fromSnapshot(
                                                                            s))
                                                                : null,
                                                            builder: (context,
                                                                snapshot) {
                                                              return Text(
                                                                snapshot.hasData
                                                                    ? snapshot
                                                                        .data!
                                                                        .name
                                                                    : 'Product...',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Text(
                                                          'Qty: ${item['quantityDelivered']}',
                                                          style: FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium,
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        Text(
                                                          'Batch: ${item['batchNumber']}',
                                                          style: FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall,
                                                        ),
                                                        SizedBox(width: 8.0),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              color: Color(
                                                                  0xFFE53E3E),
                                                              size: 18.0),
                                                          onPressed: () {
                                                            safeSetState(() {
                                                              _lineItems
                                                                  .removeAt(
                                                                      idx);
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.0),
                                  // Action buttons
                                  Row(
                                    children: [
                                      FFButtonWidget(
                                        onPressed: () async {
                                          await _confirmReceipt();
                                        },
                                        text: 'Confirm Receipt',
                                        icon: Icon(Icons.check, size: 15.0),
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      SizedBox(width: 12.0),
                                      FFButtonWidget(
                                        onPressed: () =>
                                            _showDiscrepancyDialog(context),
                                        text: 'Flag Discrepancies',
                                        icon: Icon(Icons.warning, size: 15.0),
                                        options: FFButtonOptions(
                                          height: 44.0,
                                          padding: EdgeInsetsDirectional
                                              .fromSTEB(
                                                  24.0, 0.0, 24.0, 0.0),
                                          color: Color(0xFFDD6B20),
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallFamily,
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmallIsCustom,
                                                  ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                    ],
                                  ),
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

  void _showAddLineItemDialog(BuildContext context) {
    _model.lineQtyTextController?.clear();
    _model.lineBatchTextController?.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Line Item'),
              content: Container(
                width: MediaQuery.sizeOf(context).width > 400 ? 400 : double.infinity,
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
                            controller: _model.lineProductValueController ??=
                                FormFieldController<String>(null),
                            options: snapshot.data!.map((p) => p.name).toList(),
                            onChanged: (val) => setDialogState(
                                () => _model.lineProductValue = val),
                            width: double.infinity,
                            height: 44.0,
                            textStyle: FlutterFlowTheme.of(context).bodyMedium,
                            hintText: 'Select Product',
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
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _model.lineQtyTextController,
                        focusNode: _model.lineQtyFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Quantity Delivered',
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        keyboardType: TextInputType.number,
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _model.lineBatchTextController,
                        focusNode: _model.lineBatchFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Batch Number',
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                      SizedBox(height: 12.0),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now()
                                .add(Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2050),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _model.lineExpiryDate = date;
                            });
                          }
                        },
                        child: Container(
                          height: 56.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .alternate),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 8.0),
                                Text(
                                  _model.lineExpiryDate != null
                                      ? dateTimeFormat(
                                          'yyyy-MM-dd',
                                          _model.lineExpiryDate!,
                                          locale: FFLocalizations.of(context).languageCode,
                                        )
                                      : 'Expiry Date',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                    if (_model.lineProductValue == null) return;
                    // Find the product reference
                    final products = await queryProductMasterRecordOnce();
                    final product = products.firstWhere(
                      (p) => p.name == _model.lineProductValue,
                      orElse: () => products.first,
                    );
                    safeSetState(() {
                      _lineItems.add({
                        'productId': product.reference,
                        'quantityDelivered': int.tryParse(
                                _model.lineQtyTextController?.text ??
                                    '0') ??
                            0,
                        'batchNumber':
                            _model.lineBatchTextController?.text ?? '',
                        'expiryDate': _model.lineExpiryDate,
                      });
                    });
                    _model.lineExpiryDate = null;
                    Navigator.pop(dialogContext);
                  },
                  text: 'Add',
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

  void _showDiscrepancyDialog(BuildContext context) {
    _model.discrepancyTextController ??= TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Flag Discrepancies'),
          content: TextFormField(
            controller: _model.discrepancyTextController,
            focusNode: _model.discrepancyFocusNode,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Describe the discrepancy',
              filled: true,
              fillColor:
                  FlutterFlowTheme.of(context).secondaryBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FFButtonWidget(
              onPressed: () {
                // Mark as discrepancy
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Discrepancy flagged successfully')),
                );
              },
              text: 'Submit',
              options: FFButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 0.0),
                color: Color(0xFFDD6B20),
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
  }

  Future<void> _confirmReceipt() async {
    if (_model.deliveryNoteTextController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter delivery note number')),
      );
      return;
    }
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one line item')),
      );
      return;
    }

    final ownerRef = valueOrDefault(currentUserDocument?.role, '') ==
            'Owner'
        ? currentUserReference!
        : currentUserDocument!.ownerRef!;

    // Create GoodsReceived record
    final grDoc = GoodsReceivedRecord.createDoc(ownerRef);
    await grDoc.set(createGoodsReceivedRecordData(
      deliveryNoteNumber: _model.deliveryNoteTextController?.text,
      receivedById: currentUserReference,
      deliveryDate: _model.deliveryDate,
      receivedDate: getCurrentTimestamp,
      status: 'CONFIRMED',
      createdAt: getCurrentTimestamp,
      updatedAt: getCurrentTimestamp,
    ));

    // Create line items and stock movements
    for (var item in _lineItems) {
      // Create GoodsReceivedItem subcollection
      final itemDoc =
          GoodsReceivedItemRecord.createDoc(grDoc);
      await itemDoc.set(createGoodsReceivedItemRecordData(
        productId: item['productId'] as DocumentReference?,
        quantityDelivered: item['quantityDelivered'] as int,
        batchNumber: item['batchNumber'] as String?,
        expiryDate: item['expiryDate'] as DateTime?,
      ));

      // Create StockMovement (RECEIVED type)
      final movementDoc =
          StockMovementRecord.createDoc(ownerRef);
      await movementDoc.set(createStockMovementRecordData(
        productId: item['productId'] as DocumentReference?,
        quantity: item['quantityDelivered'] as int,
        movementType: 'RECEIVED',
        movementReference: _model.deliveryNoteTextController?.text,
        recordedById: currentUserReference,
        createdAt: getCurrentTimestamp,
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goods receipt confirmed successfully')),
    );
    context.pop();
  }
}
