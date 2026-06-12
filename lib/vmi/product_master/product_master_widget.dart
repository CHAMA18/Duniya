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
import 'product_master_model.dart';
export 'product_master_model.dart';

class ProductMasterWidget extends StatefulWidget {
  const ProductMasterWidget({super.key});

  static String routeName = 'ProductMaster';
  static String routePath = '/productMaster';

  @override
  State<ProductMasterWidget> createState() => _ProductMasterWidgetState();
}

class _ProductMasterWidgetState extends State<ProductMasterWidget> {
  late ProductMasterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductMasterModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'ProductMaster'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
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
        title: 'Product Catalogue',
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
                                      'Product Catalogue',
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
                                      onPressed: () => _showAddProductDialog(context),
                                      text: 'Add Product',
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
                                        controller: _model.searchTextController,
                                        focusNode: _model.searchFocusNode,
                                        decoration: InputDecoration(
                                          hintText: 'Search products...',
                                          hintStyle: FlutterFlowTheme.of(context).bodySmall,
                                          prefixIcon: Icon(Icons.search, size: 18.0),
                                          filled: true,
                                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate, width: 1.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate, width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                            borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 1.0),
                                          ),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                        onChanged: (value) => safeSetState(() {}),
                                      ),
                                    ),
                                    Container(
                                      width: 180.0,
                                      child: FlutterFlowDropDown<String>(
                                        controller: _model.categoryValueController ??= FormFieldController<String>(null),
                                        options: ['Antibiotics', 'Analgesics', 'Antipyretics', 'Antimalarials', 'Vitamins', 'Cardiovascular', 'Respiratory', 'Gastrointestinal', 'Dermatology', 'Other'],
                                        onChanged: (val) => safeSetState(() => _model.categoryValue = val),
                                        width: 180.0,
                                        height: 44.0,
                                        textStyle: FlutterFlowTheme.of(context).bodyMedium,
                                        hintText: 'Category',
                                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                        borderColor: FlutterFlowTheme.of(context).alternate,
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
                                  child: StreamBuilder<List<ProductMasterRecord>>(
                                    stream: queryProductMasterRecord(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SpinKitRing(
                                            color: FlutterFlowTheme.of(context).primary,
                                            size: 40.0,
                                          ),
                                        );
                                      }
                                      List<ProductMasterRecord> products = snapshot.data!;
                                      // Filter by search
                                      String? search = _model.searchTextController?.text.toLowerCase();
                                      if (search != null && search.isNotEmpty) {
                                        products = products.where((p) =>
                                          p.name.toLowerCase().contains(search) ||
                                          (p.genericName ?? '').toLowerCase().contains(search) ||
                                          (p.sku).toLowerCase().contains(search)
                                        ).toList();
                                      }
                                      // Filter by category
                                      if (_model.categoryValue != null) {
                                        products = products.where((p) => p.category == _model.categoryValue).toList();
                                      }
                                      if (products.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.medication, size: 64.0, color: FlutterFlowTheme.of(context).secondaryText),
                                              SizedBox(height: 16.0),
                                              Text('No products found', style: FlutterFlowTheme.of(context).headlineSmall),
                                            ],
                                          ),
                                        );
                                      }
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: SingleChildScrollView(
                                          child: DataTable(
                                            headingRowColor: MaterialStateProperty.all(FlutterFlowTheme.of(context).primaryBackground),
                                            columns: [
                                              DataColumn(label: Text('Name', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Generic', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Brand', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Strength', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Dosage', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Pack Size', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('SKU', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Category', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Cost', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Sell', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Min', style: FlutterFlowTheme.of(context).labelSmall)),
                                              DataColumn(label: Text('Reorder', style: FlutterFlowTheme.of(context).labelSmall)),
                                            ],
                                            rows: products.map((product) => DataRow(cells: [
                                              DataCell(Text(product.name, style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.genericName ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.brandName ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.strength ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.dosageForm ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.packSize ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.sku, style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.category ?? '-', style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.costPrice.toStringAsFixed(2), style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.sellingPrice.toStringAsFixed(2), style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.minimumStockLevel.toString(), style: FlutterFlowTheme.of(context).bodyMedium)),
                                              DataCell(Text(product.reorderLevel.toString(), style: FlutterFlowTheme.of(context).bodyMedium)),
                                            ])).toList(),
                                          ),
                                        ),
                                      );
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

  void _showAddProductDialog(BuildContext context) {
    _model.nameTextController ??= TextEditingController();
    _model.genericNameTextController ??= TextEditingController();
    _model.brandNameTextController ??= TextEditingController();
    _model.strengthTextController ??= TextEditingController();
    _model.dosageFormTextController ??= TextEditingController();
    _model.packSizeTextController ??= TextEditingController();
    _model.skuTextController ??= TextEditingController();
    _model.costPriceTextController ??= TextEditingController();
    _model.sellingPriceTextController ??= TextEditingController();
    _model.minStockTextController ??= TextEditingController();
    _model.reorderLevelTextController ??= TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Container(
            width: MediaQuery.sizeOf(context).width > 600 ? 600 : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(_model.nameTextController!, 'Product Name *'),
                  SizedBox(height: 8.0),
                  _buildDialogTextField(_model.genericNameTextController!, 'Generic Name'),
                  SizedBox(height: 8.0),
                  _buildDialogTextField(_model.brandNameTextController!, 'Brand Name'),
                  SizedBox(height: 8.0),
                  Row(children: [
                    Expanded(child: _buildDialogTextField(_model.strengthTextController!, 'Strength')),
                    SizedBox(width: 8.0),
                    Expanded(child: _buildDialogTextField(_model.dosageFormTextController!, 'Dosage Form')),
                  ]),
                  SizedBox(height: 8.0),
                  Row(children: [
                    Expanded(child: _buildDialogTextField(_model.packSizeTextController!, 'Pack Size')),
                    SizedBox(width: 8.0),
                    Expanded(child: _buildDialogTextField(_model.skuTextController!, 'SKU *')),
                  ]),
                  SizedBox(height: 8.0),
                  FlutterFlowDropDown<String>(
                    controller: _model.dialogCategoryValueController ??= FormFieldController<String>(null),
                    options: ['Antibiotics', 'Analgesics', 'Antipyretics', 'Antimalarials', 'Vitamins', 'Cardiovascular', 'Respiratory', 'Gastrointestinal', 'Dermatology', 'Other'],
                    onChanged: (val) => safeSetState(() => _model.dialogCategoryValue = val),
                    width: double.infinity,
                    height: 44.0,
                    textStyle: FlutterFlowTheme.of(context).bodyMedium,
                    hintText: 'Category',
                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    borderColor: FlutterFlowTheme.of(context).alternate,
                    borderRadius: 8.0,
                    elevation: 2,
                    borderWidth: 1.0,
                    margin: EdgeInsets.zero,
                  ),
                  SizedBox(height: 8.0),
                  Row(children: [
                    Expanded(child: _buildDialogTextField(_model.costPriceTextController!, 'Cost Price', isNumber: true)),
                    SizedBox(width: 8.0),
                    Expanded(child: _buildDialogTextField(_model.sellingPriceTextController!, 'Selling Price', isNumber: true)),
                  ]),
                  SizedBox(height: 8.0),
                  Row(children: [
                    Expanded(child: _buildDialogTextField(_model.minStockTextController!, 'Min Stock', isNumber: true)),
                    SizedBox(width: 8.0),
                    Expanded(child: _buildDialogTextField(_model.reorderLevelTextController!, 'Reorder Level', isNumber: true)),
                  ]),
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
                if (_model.nameTextController?.text.isEmpty ?? true) return;
                await ProductMasterRecord.collection.doc().set(
                  createProductMasterRecordData(
                    name: _model.nameTextController?.text,
                    genericName: _model.genericNameTextController?.text,
                    brandName: _model.brandNameTextController?.text,
                    strength: _model.strengthTextController?.text,
                    dosageForm: _model.dosageFormTextController?.text,
                    packSize: _model.packSizeTextController?.text,
                    sku: _model.skuTextController?.text,
                    category: _model.dialogCategoryValue,
                    costPrice: double.tryParse(_model.costPriceTextController?.text ?? '0'),
                    sellingPrice: double.tryParse(_model.sellingPriceTextController?.text ?? '0'),
                    minimumStockLevel: int.tryParse(_model.minStockTextController?.text ?? '0'),
                    reorderLevel: int.tryParse(_model.reorderLevelTextController?.text ?? '0'),
                    isActive: true,
                    createdAt: getCurrentTimestamp,
                    updatedAt: getCurrentTimestamp,
                  ),
                );
                // Clear form
                _model.nameTextController?.clear();
                _model.genericNameTextController?.clear();
                _model.brandNameTextController?.clear();
                _model.strengthTextController?.clear();
                _model.dosageFormTextController?.clear();
                _model.packSizeTextController?.clear();
                _model.skuTextController?.clear();
                _model.costPriceTextController?.clear();
                _model.sellingPriceTextController?.clear();
                _model.minStockTextController?.clear();
                _model.reorderLevelTextController?.clear();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product added successfully')),
                );
              },
              text: 'Save',
              options: FFButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      color: Colors.white,
                      letterSpacing: 0.0,
                      useGoogleFonts: !FlutterFlowTheme.of(context).titleSmallIsCustom,
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

  Widget _buildDialogTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: FlutterFlowTheme.of(context).bodyMedium,
    );
  }
}
