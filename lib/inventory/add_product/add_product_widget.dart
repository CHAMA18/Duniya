import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'add_product_model.dart';
export 'add_product_model.dart';

class AddProductWidget extends StatefulWidget {
  const AddProductWidget({
    super.key,
    this.pharm,
  });

  final String? pharm;

  static String routeName = 'AddProduct';
  static String routePath = '/addProduct';

  @override
  State<AddProductWidget> createState() => _AddProductWidgetState();
}

class _AddProductWidgetState extends State<AddProductWidget> {
  late AddProductModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddProductModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AddProduct'});
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.priceTextController ??= TextEditingController();
    _model.priceFocusNode ??= FocusNode();

    _model.ouantityTextController ??= TextEditingController();
    _model.ouantityFocusNode ??= FocusNode();

    _model.incomTextController ??= TextEditingController();
    _model.incomFocusNode ??= FocusNode();

    _model.batchTextController ??= TextEditingController();
    _model.batchFocusNode ??= FocusNode();

    _model.limitTextController ??= TextEditingController();
    _model.limitFocusNode ??= FocusNode();

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
        title: 'AddProduct',
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
                            'ADD_PRODUCT_chevron_left_rounded_ICN_ON_');
                        logFirebaseEvent('IconButton_navigate_back');
                        context.pop();
                      },
                    ),
                    title: Text(
                      FFLocalizations.of(context).getText(
                        'akov1y9x' /* Add Product */,
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
                    child: FutureBuilder<ApiCallResponse>(
                      future: DrugsCall.call(),
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
                        // Shared theme handle for the premium layout below.
                        // (The DrugsCall response previously gated the form
                        // behind an API call whose data was never used.)
                        final theme = FlutterFlowTheme.of(context);

                        // ── Premium redesign — matches the Pulse-side
                        // Product Master dialog design system: gradient
                        // hero header, icon-chip section labels, premium
                        // fields with icons, two-column rows, action bar.
                        return Column(
                          children: [
                            wrapWithModel(
                              model: _model.topNavModel,
                              updateCallback: () => safeSetState(() {}),
                              child: TopNavWidget(
                                openDrawer: () async {},
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24.0),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 720.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                            color: theme.alternate
                                                .withValues(alpha: 0.4)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.primary
                                                .withValues(alpha: 0.10),
                                            blurRadius: 40.0,
                                            offset: const Offset(0, 14),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildGradientHeader(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      28.0,
                                                      24.0,
                                                      28.0,
                                                      8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildSectionLabel(
                                                      'Product Details',
                                                      Icons
                                                          .medication_rounded),
                                                  const SizedBox(height: 12.0),
                                                  _buildPremiumField(
                                                    controller: _model
                                                        .emailAddressTextController!,
                                                    focusNode: _model
                                                        .emailAddressFocusNode,
                                                    label: 'Item Name',
                                                    hint: 'e.g. Paracetamol',
                                                    icon: Icons
                                                        .medication_rounded,
                                                    isRequired: true,
                                                  ),
                                                  const SizedBox(height: 14.0),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            _buildPremiumDropdown(
                                                          label: 'Category',
                                                          value: _model
                                                              .categoryValue,
                                                          items: const [
                                                            'Medicine',
                                                            'Nutrition Suppliments',
                                                            'Mother and Babycare',
                                                            'Veterinary Products',
                                                            'Beauty Care',
                                                            'Personal Care',
                                                          ],
                                                          onChanged: (v) =>
                                                              safeSetState(() =>
                                                                  _model.categoryValue =
                                                                      v),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 14.0),
                                                      Expanded(
                                                        child: _buildPharmacyDropdown(
                                                            theme),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 24.0),
                                                  _buildSectionLabel(
                                                      'Stock & Pricing',
                                                      Icons
                                                          .payments_rounded),
                                                  const SizedBox(height: 12.0),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            _buildPremiumField(
                                                          controller: _model
                                                              .priceTextController!,
                                                          focusNode: _model
                                                              .priceFocusNode,
                                                          label:
                                                              'Unit Price (ZMK)',
                                                          hint: 'e.g. 50.00',
                                                          icon: Icons
                                                              .sell_rounded,
                                                          isNumber: true,
                                                          isRequired: true,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 14.0),
                                                      Expanded(
                                                        child:
                                                            _buildPremiumField(
                                                          controller: _model
                                                              .ouantityTextController!,
                                                          focusNode: _model
                                                              .ouantityFocusNode,
                                                          label: 'Quantity',
                                                          hint: 'e.g. 5000',
                                                          icon: Icons
                                                              .inventory_rounded,
                                                          isNumber: true,
                                                          isRequired: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 14.0),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: _buildDatePicker(
                                                            theme),
                                                      ),
                                                      const SizedBox(
                                                          width: 14.0),
                                                      Expanded(
                                                        child:
                                                            _buildPremiumField(
                                                          controller: _model
                                                              .incomTextController!,
                                                          focusNode: _model
                                                              .incomFocusNode,
                                                          label:
                                                              'Cost of Purchase (delivery etc)',
                                                          hint:
                                                              'e.g. 1500.00',
                                                          icon: Icons
                                                              .local_shipping_rounded,
                                                          isNumber: true,
                                                          isRequired: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 14.0),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            _buildPremiumField(
                                                          controller: _model
                                                              .batchTextController!,
                                                          focusNode: _model
                                                              .batchFocusNode,
                                                          label:
                                                              'Batch Number',
                                                          hint:
                                                              'e.g. BT-2026-014',
                                                          icon: Icons
                                                              .qr_code_rounded,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 14.0),
                                                      Expanded(
                                                        child:
                                                            _buildPremiumField(
                                                          controller: _model
                                                              .limitTextController!,
                                                          focusNode: _model
                                                              .limitFocusNode,
                                                          label:
                                                              'Low Stock Alert Level',
                                                          hint: 'e.g. 20',
                                                          icon: Icons
                                                              .notifications_active_rounded,
                                                          isNumber: true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _buildActionBar(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
  // ═══════════════════════════════════════════════════════════════
  //  PREMIUM DESIGN SYSTEM — mirrors the Pulse-side Product Master
  //  dialog: gradient hero, icon-chip section labels, premium fields.
  // ═══════════════════════════════════════════════════════════════

  static const Color _pulsePurple = Color(0xFF9900FF);
  static const Color _pulsePurpleDark = Color(0xFF7C3AED);
  static const Color _pulsePurpleDeep = Color(0xFF6D28D9);

  /// Gradient hero header — identical styling to the Product Master
  /// dialog header so both sides of the app share one design language.
  Widget _buildGradientHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 24.0, 20.0, 20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_pulsePurple, _pulsePurpleDark, _pulsePurpleDeep],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1.0),
            ),
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 26.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Product',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Add a new product to your pharmacy inventory',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section label with icon chip (matches Product Master).
  Widget _buildSectionLabel(String title, IconData icon) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: _pulsePurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 15.0, color: _pulsePurple),
        ),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: theme.primaryText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Premium text field (matches Product Master).
  Widget _buildPremiumField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    String? hint,
    IconData? icon,
    bool isNumber = false,
    bool isRequired = false,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                letterSpacing: 0.2,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 3.0),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: theme.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              color: theme.secondaryText,
            ),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                    child: Icon(icon,
                        size: 18.0,
                        color: _pulsePurple.withValues(alpha: 0.6)),
                  )
                : null,
            prefixIconConstraints: icon != null
                ? const BoxConstraints(minWidth: 42.0, minHeight: 0)
                : null,
            filled: true,
            fillColor: theme.primaryBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: theme.alternate, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
                  BorderSide(color: theme.alternate, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _pulsePurple, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  /// Premium dropdown (matches Product Master category dropdown).
  Widget _buildPremiumDropdown({
    required String label,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kAppFontFamily,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: theme.secondaryText,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: value != null
                  ? _pulsePurple.withValues(alpha: 0.4)
                  : theme.alternate,
              width: value != null ? 1.5 : 1.0,
            ),
            color: theme.primaryBackground,
          ),
          child: DropdownButtonFormField<String>(
            key: ValueKey('addProduct_${label}_dropdown'),
            initialValue: value,
            isExpanded: true,
            items: items
                .map((label) => DropdownMenuItem<String>(
                      value: label,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryText,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Please select...',
              hintStyle: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13.0,
                color: theme.secondaryText,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
              border: InputBorder.none,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _pulsePurple.withValues(alpha: 0.6),
              size: 22.0,
            ),
            elevation: 2,
            dropdownColor: theme.secondaryBackground,
          ),
        ),
      ],
    );
  }

  /// Pharmacy dropdown — premium-styled, streams real pharmacies.
  Widget _buildPharmacyDropdown(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pharmacy',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3.0),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        StreamBuilder<List<PharmacyRecord>>(
          stream: queryPharmacyRecord(
            parent: AccessControl.networkWideQueryParent(context),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 48.0,
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: theme.alternate),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  'Loading pharmacies…',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.0,
                      color: theme.secondaryText),
                ),
              );
            }
            final pharmacies = snapshot.data!;
            // Keep the current selection valid against the live list.
            if (_model.pharmValue != null &&
                !pharmacies.any((p) => p.name == _model.pharmValue)) {
              _model.pharmValue = null;
            }
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _model.pharmValue != null
                      ? _pulsePurple.withValues(alpha: 0.4)
                      : theme.alternate,
                  width: _model.pharmValue != null ? 1.5 : 1.0,
                ),
                color: theme.primaryBackground,
              ),
              child: DropdownButtonFormField<String>(
                key: const ValueKey('addProduct_pharmacy_dropdown'),
                initialValue: _model.pharmValue,
                isExpanded: true,
                items: pharmacies
                    .map((p) => DropdownMenuItem<String>(
                          value: p.name,
                          child: Text(
                            p.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryText,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) =>
                    safeSetState(() => _model.pharmValue = v),
                decoration: InputDecoration(
                  hintText: 'Please select...',
                  hintStyle: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.0,
                      color: theme.secondaryText),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 13.0),
                  border: InputBorder.none,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _pulsePurple.withValues(alpha: 0.6),
                  size: 22.0,
                ),
                elevation: 2,
                dropdownColor: theme.secondaryBackground,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Expiration date picker — premium-styled trigger tile.
  Widget _buildDatePicker(FlutterFlowTheme theme) {
    final picked = _model.datePicked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Expiration Date',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.secondaryText,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 3.0),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _model.datePicked ??
                  DateTime.now().add(const Duration(days: 365)),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: _pulsePurple,
                      ),
                ),
                child: child!,
              ),
            );
            if (pickedDate != null) {
              safeSetState(() => _model.datePicked = pickedDate);
            }
          },
          child: Container(
            height: 48.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: picked != null
                    ? _pulsePurple.withValues(alpha: 0.4)
                    : theme.alternate,
                width: picked != null ? 1.5 : 1.0,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
            child: Row(
              children: [
                Icon(Icons.event_rounded,
                    size: 18.0, color: _pulsePurple.withValues(alpha: 0.6)),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    picked != null
                        ? dateTimeFormat('yMMMd', picked,
                            locale: FFLocalizations.of(context).languageCode)
                        : 'Select Date',
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.5,
                      fontWeight:
                          picked != null ? FontWeight.w500 : FontWeight.w400,
                      color: picked != null
                          ? theme.primaryText
                          : theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Action bar — validation hint + Save button (matches Product
  /// Master's bar with the border-top separator).
  Widget _buildActionBar() {
    final theme = FlutterFlowTheme.of(context);

    final nameFilled =
        (_model.emailAddressTextController?.text ?? '').trim().isNotEmpty;
    final categoryOk = _model.categoryValue != null;
    final pharmOk =
        (_model.pharmValue ?? '').isNotEmpty;
    final priceOk =
        double.tryParse(_model.priceTextController?.text ?? '') != null;
    final qtyOk =
        int.tryParse(_model.ouantityTextController?.text ?? '') != null;
    final dateOk = _model.datePicked != null;
    final costOk =
        double.tryParse(_model.incomTextController?.text ?? '') != null;
    final canSave = nameFilled &&
        categoryOk &&
        pharmOk &&
        priceOk &&
        qtyOk &&
        dateOk &&
        costOk;

    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 12.0, 28.0, 20.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          top: BorderSide(color: theme.alternate.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              canSave ? 'Ready to save' : 'Complete the required fields (*)',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: canSave ? const Color(0xFF059669) : theme.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          OutlinedButton(
            onPressed: () => context.safePop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.secondaryText,
              side: BorderSide(color: theme.alternate, width: 1.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 13.0),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12.0),
          FilledButton.icon(
            onPressed: canSave ? _saveProduct : null,
            style: FilledButton.styleFrom(
              backgroundColor: _pulsePurple,
              disabledBackgroundColor: theme.alternate.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 28.0, vertical: 13.0),
            ),
            icon: const Icon(Icons.check_circle_rounded, size: 18.0),
            label: const Text(
              'Save Product',
              style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Persists the new stock record (logic unchanged from the original
  /// nested-if flow — extracted for readability).
  Future<void> _saveProduct() async {
    var shouldSetState = false;
    try {
      await StockRecord.createDoc(AccessControl.parentRef(context) ??
              currentUserReference!)
          .set(createStockRecordData(
            name: _model.emailAddressTextController?.text,
            quantity:
                int.tryParse(_model.ouantityTextController?.text ?? ''),
            expiryDate: _model.datePicked,
            category: _model.categoryValue,
            price: double.tryParse(_model.priceTextController?.text ?? ''),
            costOfGoods: double.tryParse(_model.incomTextController?.text ?? ''),
            pharmacy: _model.pharmValue,
            batchNumber: _model.batchTextController?.text ?? '',
            initialQuantity: double.tryParse(
                _model.ouantityTextController?.text ?? '0'),
            limitNotice: int.tryParse(_model.limitTextController?.text ?? '0'),
          ));

      // Update the finance record with the purchase cost (same
      // create-or-increment behaviour as the original flow).
      final finance = await queryFinanceRecordOnce(
        parent: currentUserReference,
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      shouldSetState = true;
      final cost =
          double.tryParse(_model.incomTextController?.text ?? '0') ?? 0.0;
      if (finance?.revenue == null) {
        await FinanceRecord.createDoc(currentUserReference!)
            .set(createFinanceRecordData(costOfGoods: cost));
      } else if (finance != null) {
        await finance.reference.update({
          ...mapToFirestore(
            {'CostOfGoods': FieldValue.increment(cost)},
          ),
        });
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (alertDialogContext) => WebViewAware(
          child: AlertDialog(
            title: const Text('New Stock Added'),
            content:
                Text('New stock has been added to ${_model.pharmValue}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      );

      if (!mounted) return;
      context.goNamed(
        InventoryCategoryWidget.routeName,
        queryParameters: {
          'category': serializeParam(
            _model.categoryValue,
            ParamType.String,
          ),
        }.withoutNulls,
      );
    } finally {
      if (shouldSetState && mounted) safeSetState(() {});
    }
  }

}
