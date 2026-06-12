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
import 'batches_model.dart';
export 'batches_model.dart';

class BatchesWidget extends StatefulWidget {
  const BatchesWidget({super.key});

  static String routeName = 'Batches';
  static String routePath = '/batches';

  @override
  State<BatchesWidget> createState() => _BatchesWidgetState();
}

class _BatchesWidgetState extends State<BatchesWidget> {
  late BatchesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BatchesModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Batches'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _getExpiryColor(DateTime? expiryDate) {
    if (expiryDate == null) return Color(0xFFE2E8F0);
    final now = DateTime.now();
    final diff = expiryDate.difference(now).inDays;
    if (diff < 0) return Color(0xFFFED7D7); // Expired - RED
    if (diff < 90) return Color(0xFFFEEBC8); // < 3 months - ORANGE
    if (diff < 180) return Color(0xFFFEFCBF); // < 6 months - YELLOW
    return Color(0xFFC6F6D5); // Green
  }

  Color _getExpiryTextColor(DateTime? expiryDate) {
    if (expiryDate == null) return Color(0xFF2D3748);
    final now = DateTime.now();
    final diff = expiryDate.difference(now).inDays;
    if (diff < 0) return Color(0xFF822727);
    if (diff < 90) return Color(0xFF7B341E);
    if (diff < 180) return Color(0xFF744210);
    return Color(0xFF22543D);
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Batch & Expiry Tracking',
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
                                      'Batch & Expiry Tracking',
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
                                          _showAddBatchDialog(context),
                                      text: 'Add Batch',
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
                                      width: 250.0,
                                      child: TextFormField(
                                        controller:
                                            _model.searchTextController,
                                        focusNode: _model.searchFocusNode,
                                        decoration: InputDecoration(
                                          hintText: 'Search batches...',
                                          hintStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmall,
                                          prefixIcon: Icon(Icons.search,
                                              size: 18.0),
                                          filled: true,
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                            ),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium,
                                        onChanged: (value) =>
                                            safeSetState(() {}),
                                      ),
                                    ),
                                    Container(
                                      width: 180.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model
                                                .expiryStatusValueController ??=
                                            FormFieldController<String>(null),
                                        options: [
                                          'All',
                                          'Expired',
                                          '< 3 Months',
                                          '< 6 Months',
                                          'Safe',
                                        ],
                                        onChanged: (val) => safeSetState(() =>
                                            _model.expiryStatusValue = val),
                                        width: 180.0,
                                        height: 44.0,
                                        textStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium,
                                        hintText: 'Expiry Status',
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
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                Expanded(
                                  child: StreamBuilder<List<BatchRecord>>(
                                    stream: queryBatchRecord(),
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
                                      List<BatchRecord> batches =
                                          snapshot.data!;

                                      // Filter by search
                                      String? search = _model
                                          .searchTextController?.text
                                          .toLowerCase();
                                      if (search != null &&
                                          search.isNotEmpty) {
                                        batches = batches
                                            .where((b) => b.batchNumber
                                                .toLowerCase()
                                                .contains(search))
                                            .toList();
                                      }

                                      // Filter by expiry status
                                      if (_model.expiryStatusValue !=
                                              null &&
                                          _model.expiryStatusValue !=
                                              'All') {
                                        final now = DateTime.now();
                                        batches = batches.where((b) {
                                          if (!b.hasExpiryDate()) return false;
                                          final diff = b
                                              .expiryDate!
                                              .difference(now)
                                              .inDays;
                                          switch (_model
                                              .expiryStatusValue) {
                                            case 'Expired':
                                              return diff < 0;
                                            case '< 3 Months':
                                              return diff >= 0 && diff < 90;
                                            case '< 6 Months':
                                              return diff >= 0 && diff < 180;
                                            case 'Safe':
                                              return diff >= 180;
                                            default:
                                              return true;
                                          }
                                        }).toList();
                                      }

                                      if (batches.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.inventory_2_outlined,
                                                  size: 64.0,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText),
                                              SizedBox(height: 16.0),
                                              Text('No batches found',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall),
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
                                            Map<String,
                                                    ProductMasterRecord>
                                                productMap = {
                                              for (var p
                                                  in productSnapshot.data!)
                                                p.reference.path: p
                                            };

                                            return SingleChildScrollView(
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
                                                    DataColumn(label: Text('Batch Number', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Pharmacy', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Expiry Date', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Quantity', style: FlutterFlowTheme.of(context).labelSmall)),
                                                    DataColumn(label: Text('Facility', style: FlutterFlowTheme.of(context).labelSmall)),
                                                  ],
                                                  rows: batches
                                                      .map((batch) {
                                                    Color rowColor =
                                                        _getExpiryColor(
                                                            batch.expiryDate);
                                                    Color textColor =
                                                        _getExpiryTextColor(
                                                            batch.expiryDate);
                                                    return DataRow(
                                                      color:
                                                          MaterialStateProperty
                                                              .all(rowColor),
                                                      cells: [
                                                        DataCell(Text(
                                                            productMap[batch
                                                                        .productId
                                                                        ?.path]
                                                                    ?.name ??
                                                                '-',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                  color:
                                                                      textColor,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                ))),
                                                        DataCell(Text(
                                                            batch.batchNumber,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium)),
                                                        DataCell(FutureBuilder<
                                                                PharmacyRecord?>(
                                                          future: batch
                                                                  .hasPharmacyId()
                                                              ? batch.pharmacyId!
                                                                  .get()
                                                                  .then((s) =>
                                                                      PharmacyRecord.fromSnapshot(
                                                                          s))
                                                              : null,
                                                          builder:
                                                              (context, snap) {
                                                            return Text(
                                                              snap.hasData
                                                                  ? snap.data!
                                                                      .name
                                                                  : '-',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium,
                                                            );
                                                          },
                                                        )),
                                                        DataCell(Text(
                                                          batch.hasExpiryDate()
                                                              ? dateTimeFormat(
                                                                  'yyyy-MM-dd',
                                                                  batch
                                                                      .expiryDate!,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                )
                                                              : '-',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                              ),
                                                        )),
                                                        DataCell(Text(
                                                            batch.quantity
                                                                .toString(),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium)),
                                                        DataCell(Text(
                                                            batch.facilityLocation ??
                                                                '-',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium)),
                                                      ],
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          });
                                    },
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

  void _showAddBatchDialog(BuildContext context) {
    _model.dialogBatchTextController ??= TextEditingController();
    _model.dialogQtyTextController ??= TextEditingController();
    _model.dialogFacilityTextController ??= TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Batch'),
              content: Container(
                width: MediaQuery.sizeOf(context).width > 400
                    ? 400
                    : double.infinity,
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
                            controller:
                                _model.dialogProductValueController ??=
                                    FormFieldController<String>(null),
                            options: snapshot.data!
                                .map((p) => p.name)
                                .toList(),
                            onChanged: (val) => setDialogState(
                                () => _model.dialogProductValue = val),
                            width: double.infinity,
                            height: 44.0,
                            textStyle:
                                FlutterFlowTheme.of(context).bodyMedium,
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
                        controller: _model.dialogBatchTextController,
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
                              _model.dialogExpiryDate = date;
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
                            padding:
                                EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 8.0),
                                Text(
                                  _model.dialogExpiryDate != null
                                      ? dateTimeFormat(
                                          'yyyy-MM-dd',
                                          _model.dialogExpiryDate!,
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
                      SizedBox(height: 12.0),
                      TextFormField(
                        controller: _model.dialogQtyTextController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
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
                        controller: _model.dialogFacilityTextController,
                        decoration: InputDecoration(
                          labelText: 'Facility Location',
                          filled: true,
                          fillColor: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
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
                    if (_model.dialogProductValue == null) return;
                    final products =
                        await queryProductMasterRecordOnce();
                    final product = products.firstWhere(
                      (p) =>
                          p.name == _model.dialogProductValue,
                      orElse: () => products.first,
                    );
                    final ownerRef = valueOrDefault(
                                currentUserDocument?.role, '') ==
                            'Owner'
                        ? currentUserReference!
                        : currentUserDocument!.ownerRef!;
                    await BatchRecord.collection.doc().set(
                      createBatchRecordData(
                        productId: product.reference,
                        pharmacyId: ownerRef,
                        batchNumber:
                            _model.dialogBatchTextController?.text ??
                                '',
                        expiryDate: _model.dialogExpiryDate,
                        quantity: int.tryParse(_model
                                .dialogQtyTextController?.text ??
                            '0'),
                        facilityLocation: _model
                            .dialogFacilityTextController?.text,
                        createdAt: getCurrentTimestamp,
                        updatedAt: getCurrentTimestamp,
                      ),
                    );
                    // Clear form
                    _model.dialogBatchTextController?.clear();
                    _model.dialogQtyTextController?.clear();
                    _model.dialogFacilityTextController?.clear();
                    _model.dialogExpiryDate = null;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Batch added successfully')),
                    );
                  },
                  text: 'Save',
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
