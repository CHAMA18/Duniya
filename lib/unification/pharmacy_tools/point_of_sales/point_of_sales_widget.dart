import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import '/unification/cart/cart_widget.dart';
import '/unification/components/counter/counter_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
  bool _seededDefaultPharmacy = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PointOfSalesModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PointOfSales'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  DocumentReference? _pharmacyScopeParent() {
    return valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef ?? currentUserReference;
  }

  DocumentReference? _stockScopeParent() {
    return valueOrDefault(currentUserDocument?.role, '') == 'Owner'
        ? currentUserReference
        : currentUserDocument?.ownerRef ?? currentUserReference;
  }

  String _effectivePharmacyName([List<PharmacyRecord>? pharmacies]) {
    final selected = _model.pharmacyDropDownValue?.trim() ?? '';
    if (selected.isNotEmpty) {
      return selected;
    }

    final requested = widget.pharm?.trim() ?? '';
    if (requested.isNotEmpty) {
      return requested;
    }

    final userPharmacy =
        valueOrDefault(currentUserDocument?.pharmacyName, '').trim();
    if (userPharmacy.isNotEmpty) {
      return userPharmacy;
    }

    return pharmacies?.firstOrNull?.name ?? '';
  }

  DocumentReference? _effectivePharmacyReference(
    List<PharmacyRecord> pharmacies,
    String pharmacyName,
  ) {
    return pharmacies
        .firstWhereOrNull((p) => p.name == pharmacyName)
        ?.reference;
  }

  void _seedPharmacySelection(List<PharmacyRecord> pharmacies) {
    if (_seededDefaultPharmacy || pharmacies.isEmpty) {
      return;
    }

    final resolved = _effectivePharmacyName(pharmacies);
    final target = pharmacies.firstWhereOrNull((p) => p.name == resolved) ??
        pharmacies.firstOrNull;
    if (target == null) {
      return;
    }

    _seededDefaultPharmacy = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _model.pharmacyDropDownValue = target.name;
        _model.pharmacyDropDownValueController ??=
            FormFieldController<String>(target.name);
        _model.pharmacyDropDownValueController!.value = target.name;
      });

      FFAppState().updateCartStruct(
        (e) => e
          ..displayName = []
          ..quantity = []
          ..price = []
          ..pharmId = target.reference,
      );
      FFAppState().update(() {});
    });
  }

  void _handlePharmacySelected(
    String? pharmacyName,
    List<PharmacyRecord> pharmacies,
  ) {
    setState(() {
      _model.pharmacyDropDownValue = pharmacyName;
    });

    final selectedRef = pharmacyName == null
        ? null
        : _effectivePharmacyReference(pharmacies, pharmacyName);

    FFAppState().updateCartStruct(
      (e) => e
        ..displayName = []
        ..quantity = []
        ..price = []
        ..pharmId = selectedRef,
    );
    FFAppState().update(() {});
  }

  List<StockRecord> _filterStocks(List<StockRecord> stocks) {
    return stocks.where((stock) {
      final search = _searchQuery.trim().toLowerCase();
      final matchesSearch = search.isEmpty ||
          stock.name.toLowerCase().contains(search) ||
          stock.manufacturer.toLowerCase().contains(search) ||
          stock.category.toLowerCase().contains(search) ||
          stock.batchNumber.toLowerCase().contains(search);
      final matchesCategory =
          _selectedCategory == 'All' || stock.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int _lowStockThreshold(StockRecord stock) {
    return stock.limitNotice > 0 ? stock.limitNotice : 5;
  }

  bool _isLowStock(StockRecord stock) {
    return stock.quantity <= _lowStockThreshold(stock);
  }

  bool _isNearExpiry(StockRecord stock) {
    final expiry = stock.expiryDate;
    if (expiry == null) {
      return false;
    }
    final now = DateTime.now();
    return expiry.isAfter(now) &&
        expiry.isBefore(now.add(const Duration(days: 30)));
  }

  IconData _stockIcon(StockRecord stock) {
    switch (stock.category) {
      case 'Medicine':
        return Icons.medication_rounded;
      case 'Nutrition Suppliments':
        return Icons.spa_rounded;
      case 'Veterinary Products':
        return Icons.pets_rounded;
      case 'Beauty Care':
        return Icons.face_retouching_natural_rounded;
      case 'Mother and Babycare':
        return Icons.baby_changing_station_rounded;
      case 'Personal Care':
        return Icons.sanitizer_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  Color _accentForStock(StockRecord stock) {
    if (_isLowStock(stock)) {
      return const Color(0xFFEF4444);
    }
    if (_isNearExpiry(stock)) {
      return const Color(0xFFF59E0B);
    }
    return FlutterFlowTheme.of(context).primary;
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineLargeFamily,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineLargeIsCustom,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context)
                  .secondaryBackground
                  .withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context)
                    .alternate
                    .withValues(alpha: 0.75),
          ),
        ),
        child: Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: selected
                    ? Colors.white
                    : FlutterFlowTheme.of(context).primaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 12,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, StockRecord stock) {
    final accent = _accentForStock(stock);
    final quantity = stock.quantity;
    final title = stock.name.isNotEmpty ? stock.name : 'Untitled item';
    final subtitle =
        stock.manufacturer.isNotEmpty ? stock.manufacturer : stock.category;
    final expiryText = stock.hasExpiryDate()
        ? dateTimeFormat(
            'yMMMd',
            stock.expiryDate!,
            locale: FFLocalizations.of(context).languageCode,
          )
        : 'No expiry set';

    return Container(
      constraints: const BoxConstraints(minHeight: 270),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _stockIcon(stock),
                    color: accent,
                    size: 26,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isLowStock(stock)
                        ? const Color(0xFFFFF1F2)
                        : _isNearExpiry(stock)
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFE8FAF1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _isLowStock(stock)
                        ? 'Low stock'
                        : _isNearExpiry(stock)
                            ? 'Expiring'
                            : 'Healthy',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: _isLowStock(stock)
                              ? const Color(0xFFEF4444)
                              : _isNearExpiry(stock)
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleLargeIsCustom,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoPill(
                  context,
                  icon: Icons.badge_outlined,
                  text:
                      stock.category.isNotEmpty ? stock.category : 'Inventory',
                ),
                _buildInfoPill(
                  context,
                  icon: Icons.event_rounded,
                  text: expiryText,
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZMK ${formatNumber(
                        stock.price,
                        formatType: FormatType.compact,
                      )}',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .headlineSmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .headlineSmallIsCustom,
                              ),
                    ),
                    Text(
                      '$quantity in stock',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ],
                ),
                CounterWidget(
                  key: Key('pos_counter_${stock.reference.id}'),
                  parameter1: stock.name,
                  parameter3: stock.price,
                  productQuantity: stock.quantity,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color:
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleLargeIsCustom,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another pharmacy, clear the search, or switch categories to reveal available stock.',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isWide, String activePharmacy) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).primary.withValues(alpha: 0.98),
            const Color(0xFF6D28D9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Point of Sale',
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).displaySmallFamily,
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .displaySmallIsCustom,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track sold items, dispense from live stock, and keep every pharmacy transaction tied to the right location.',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            color: Colors.white.withValues(alpha: 0.88),
                            lineHeight: 1.5,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 20),
                FFButtonWidget(
                  onPressed: () async {
                    scaffoldKey.currentState?.openEndDrawer();
                  },
                  text: 'Checkout',
                  icon: const Icon(Icons.shopping_bag_rounded, size: 18),
                  options: FFButtonOptions(
                    height: 48,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 0.0),
                    color: Colors.white,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoPill(
                context,
                icon: Icons.storefront_rounded,
                text: activePharmacy.isEmpty
                    ? 'Select a pharmacy'
                    : activePharmacy,
              ),
              _buildInfoPill(
                context,
                icon: Icons.local_shipping_rounded,
                text: 'Live stock and dispensing',
              ),
              _buildInfoPill(
                context,
                icon: Icons.lock_rounded,
                text: 'Linked to the active pharmacy scope',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorCard(
    BuildContext context,
    List<PharmacyRecord> pharmacies, {
    required bool isWide,
  }) {
    final activeName = _effectivePharmacyName(pharmacies);
    final activeRecord = _effectivePharmacyReference(pharmacies, activeName);
    final dropdownEnabled =
        valueOrDefault(currentUserDocument?.role, '') == 'Owner';

    final dropdown = FlutterFlowDropDown<String>(
      controller: _model.pharmacyDropDownValueController ??=
          FormFieldController<String>(
              _model.pharmacyDropDownValue ?? activeName),
      options: pharmacies.map((e) => e.name).toList(),
      onChanged: dropdownEnabled
          ? (val) => _handlePharmacySelected(val, pharmacies)
          : null,
      width: isWide ? 380 : double.infinity,
      height: 52,
      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
          ),
      hintText: activeName.isNotEmpty ? activeName : 'Choose a pharmacy',
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: FlutterFlowTheme.of(context).secondaryText,
        size: 24.0,
      ),
      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      elevation: 0.0,
      borderColor: FlutterFlowTheme.of(context).alternate,
      borderWidth: 1.0,
      borderRadius: 16.0,
      margin: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      hidesUnderline: true,
      disabled: !dropdownEnabled,
      isSearchable: false,
      isMultiSelect: false,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.75),
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacy scope',
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleMediumIsCustom,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Every stock lookup and basket action is tied to this location.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                dropdown,
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withValues(
                          alpha: 0.08,
                        ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeName.isEmpty
                            ? 'No pharmacy selected'
                            : activeName,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleMediumFamily,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .titleMediumIsCustom,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeRecord == null
                            ? 'Waiting for scope data'
                            : 'Ready for checkout',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pharmacy scope',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 8),
                dropdown,
              ],
            ),
    );
  }

  Widget _buildCashierSidebar(
    BuildContext context,
    List<StockRecord> allStocks,
    List<StockRecord> visibleStocks,
    String activePharmacyName,
  ) {
    final subtotal = functions.cartTotal(
      FFAppState().Cart.price.toList(),
      FFAppState().Cart.quantity.toList(),
    );
    final cartCount = FFAppState().Cart.displayName.length;
    final lowStockCount = allStocks.where(_isLowStock).length;
    final nearExpiryCount = allStocks.where(_isNearExpiry).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withValues(
                        alpha: 0.1,
                      ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.point_of_sale_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashier view',
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).titleMediumFamily,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .titleMediumIsCustom,
                          ),
                    ),
                    Text(
                      activePharmacyName.isEmpty
                          ? 'No pharmacy selected'
                          : activePharmacyName,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildStatRow(
            context,
            dotColor: FlutterFlowTheme.of(context).primary,
            label: 'Cart items',
            value: cartCount.toString(),
          ),
          _buildStatRow(
            context,
            dotColor: const Color(0xFFEF4444),
            label: 'Low stock items',
            value: lowStockCount.toString(),
          ),
          _buildStatRow(
            context,
            dotColor: const Color(0xFFF59E0B),
            label: 'Near expiry',
            value: nearExpiryCount.toString(),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  FlutterFlowTheme.of(context).primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basket subtotal',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ZMK ${subtotal.toStringAsFixed(2)}',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).headlineMediumFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        useGoogleFonts: !FlutterFlowTheme.of(context)
                            .headlineMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  visibleStocks.isEmpty
                      ? 'No visible stock matches your current search.'
                      : '${visibleStocks.length} products ready for dispensing.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FFButtonWidget(
            onPressed: () async {
              scaffoldKey.currentState?.openEndDrawer();
            },
            text: 'Open checkout drawer',
            options: FFButtonOptions(
              width: double.infinity,
              height: 48,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleSmallIsCustom,
                  ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required Color dotColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).titleMediumIsCustom,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final isWide = MediaQuery.sizeOf(context).width >= 1200;

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
          backgroundColor: const Color(0xFFF7F3FF),
          endDrawer: SizedBox(
            width: 380.0,
            child: Drawer(
              elevation: 16.0,
              child: WebViewAware(
                child: wrapWithModel(
                  model: _model.cartModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const CartWidget(),
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
                      context.pop();
                    },
                  ),
                  title: Text(
                    FFLocalizations.of(context).getText(
                      '73rf8gql' /* Point of Sale */,
                    ),
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).headlineMediumFamily,
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
          body: AuthUserStreamWidget(
            builder: (context) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final pharmaciesParent = _pharmacyScopeParent();
                  final stockParent = _stockScopeParent();
                  final activePharmacyName = _effectivePharmacyName();

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 24 : 16,
                      18,
                      isWide ? 24 : 16,
                      28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!responsiveVisibility(
                          context: context,
                          phone: false,
                          tablet: false,
                        )) ...[
                          Row(
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  context.pushNamed(HomeWidget.routeName);
                                },
                                text: 'Back',
                                icon: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 15.0,
                                ),
                                options: FFButtonOptions(
                                  height: 42.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsets.zero,
                                  iconColor:
                                      FlutterFlowTheme.of(context).secondary,
                                  color: Colors.white,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                              ),
                              Text(
                                'Point of Sale',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .displaySmallFamily,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w800,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .displaySmallIsCustom,
                                    ),
                              ),
                            ].divide(const SizedBox(width: 16.0)),
                          ),
                          const SizedBox(height: 18),
                        ],
                        _buildHeader(context, isWide, activePharmacyName),
                        const SizedBox(height: 18),
                        StreamBuilder<List<PharmacyRecord>>(
                          stream: queryPharmacyRecord(parent: pharmaciesParent),
                          builder: (context, pharmacySnapshot) {
                            if (!pharmacySnapshot.hasData) {
                              return Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 76,
                                    height: 76,
                                    child: SpinKitRing(
                                      color: Color(0xFF7C3AED),
                                      size: 76,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final pharmacies = pharmacySnapshot.data!;
                            _seedPharmacySelection(pharmacies);
                            final resolvedPharmacyName =
                                _effectivePharmacyName(pharmacies);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSelectorCard(
                                  context,
                                  pharmacies,
                                  isWide: isWide,
                                ),
                                const SizedBox(height: 18),
                                StreamBuilder<List<StockRecord>>(
                                  stream: resolvedPharmacyName.isEmpty
                                      ? Stream<List<StockRecord>>.value(
                                          <StockRecord>[],
                                        )
                                      : queryStockRecord(
                                          parent: stockParent,
                                          queryBuilder: (stockRecord) =>
                                              stockRecord
                                                  .where(
                                                    'Pharmacy',
                                                    isEqualTo:
                                                        resolvedPharmacyName,
                                                  )
                                                  .where(
                                                    'Quantity',
                                                    isGreaterThan: 0,
                                                  ),
                                        ),
                                  builder: (context, stockSnapshot) {
                                    if (!stockSnapshot.hasData) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 60),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 76,
                                            height: 76,
                                            child: SpinKitRing(
                                              color: Color(0xFF7C3AED),
                                              size: 76,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final allStocks = stockSnapshot.data!;
                                    _model.pharmCopy2 =
                                        pharmacies.firstWhereOrNull((p) =>
                                            p.name == resolvedPharmacyName);
                                    final visibleStocks =
                                        _filterStocks(allStocks);
                                    final totalValue = allStocks.fold<double>(
                                      0.0,
                                      (sum, stock) =>
                                          sum + (stock.quantity * stock.price),
                                    );
                                    final lowStockCount =
                                        allStocks.where(_isLowStock).length;
                                    final nearExpiryCount =
                                        allStocks.where(_isNearExpiry).length;
                                    final cartCount =
                                        FFAppState().Cart.displayName.length;
                                    final subtotal = functions.cartTotal(
                                      FFAppState().Cart.price.toList(),
                                      FFAppState().Cart.quantity.toList(),
                                    );

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isWide)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildMetricCard(
                                                  context: context,
                                                  label: 'Total stock value',
                                                  value: 'ZMK ${formatNumber(
                                                    totalValue,
                                                    formatType:
                                                        FormatType.compact,
                                                  )}',
                                                  subtitle:
                                                      '${allStocks.length} active SKUs in scope',
                                                  icon: Icons.bar_chart_rounded,
                                                  iconBackground:
                                                      const Color(0xFFF3E8FF),
                                                  iconColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              Expanded(
                                                child: _buildMetricCard(
                                                  context: context,
                                                  label: 'Cart items',
                                                  value: cartCount.toString(),
                                                  subtitle:
                                                      'Products waiting for checkout',
                                                  icon: Icons
                                                      .shopping_bag_rounded,
                                                  iconBackground:
                                                      const Color(0xFFE8FAF1),
                                                  iconColor:
                                                      const Color(0xFF10B981),
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              Expanded(
                                                child: _buildMetricCard(
                                                  context: context,
                                                  label: 'Low stock alerts',
                                                  value:
                                                      lowStockCount.toString(),
                                                  subtitle:
                                                      'Items below reorder thresholds',
                                                  icon: Icons
                                                      .warning_amber_rounded,
                                                  iconBackground:
                                                      const Color(0xFFFFF1F2),
                                                  iconColor:
                                                      const Color(0xFFEF4444),
                                                ),
                                              ),
                                              const SizedBox(width: 18),
                                              Expanded(
                                                child: _buildMetricCard(
                                                  context: context,
                                                  label: 'Near expiry',
                                                  value: nearExpiryCount
                                                      .toString(),
                                                  subtitle:
                                                      'Batch review within 30 days',
                                                  icon: Icons.event_rounded,
                                                  iconBackground:
                                                      const Color(0xFFFFF7ED),
                                                  iconColor:
                                                      const Color(0xFFF59E0B),
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Column(
                                            children: [
                                              _buildMetricCard(
                                                context: context,
                                                label: 'Total stock value',
                                                value: 'ZMK ${formatNumber(
                                                  totalValue,
                                                  formatType:
                                                      FormatType.compact,
                                                )}',
                                                subtitle:
                                                    '${allStocks.length} active SKUs in scope',
                                                icon: Icons.bar_chart_rounded,
                                                iconBackground:
                                                    const Color(0xFFF3E8FF),
                                                iconColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                              const SizedBox(height: 16),
                                              _buildMetricCard(
                                                context: context,
                                                label: 'Cart items',
                                                value: cartCount.toString(),
                                                subtitle:
                                                    'Products waiting for checkout',
                                                icon:
                                                    Icons.shopping_bag_rounded,
                                                iconBackground:
                                                    const Color(0xFFE8FAF1),
                                                iconColor:
                                                    const Color(0xFF10B981),
                                              ),
                                              const SizedBox(height: 16),
                                              _buildMetricCard(
                                                context: context,
                                                label: 'Low stock alerts',
                                                value: lowStockCount.toString(),
                                                subtitle:
                                                    'Items below reorder thresholds',
                                                icon:
                                                    Icons.warning_amber_rounded,
                                                iconBackground:
                                                    const Color(0xFFFFF1F2),
                                                iconColor:
                                                    const Color(0xFFEF4444),
                                              ),
                                              const SizedBox(height: 16),
                                              _buildMetricCard(
                                                context: context,
                                                label: 'Near expiry',
                                                value:
                                                    nearExpiryCount.toString(),
                                                subtitle:
                                                    'Batch review within 30 days',
                                                icon: Icons.event_rounded,
                                                iconBackground:
                                                    const Color(0xFFFFF7ED),
                                                iconColor:
                                                    const Color(0xFFF59E0B),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 18),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate
                                                      .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (isWide)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 52,
                                                        child: TextField(
                                                          onChanged: (value) {
                                                            safeSetState(() {
                                                              _searchQuery =
                                                                  value;
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'Search stock, brand, batch, or category...',
                                                            prefixIcon:
                                                                const Icon(Icons
                                                                    .search_rounded),
                                                            filled: true,
                                                            fillColor: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                              ),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .alternate,
                                                              ),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                width: 1.6,
                                                              ),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        18,
                                                                    vertical:
                                                                        16),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    FFButtonWidget(
                                                      onPressed: () async {
                                                        scaffoldKey.currentState
                                                            ?.openEndDrawer();
                                                      },
                                                      text:
                                                          'Checkout: ZMK ${subtotal.toStringAsFixed(2)}',
                                                      options: FFButtonOptions(
                                                        height: 52,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(22.0,
                                                                0.0, 22.0, 0.0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                Column(
                                                  children: [
                                                    TextField(
                                                      onChanged: (value) {
                                                        safeSetState(() {
                                                          _searchQuery = value;
                                                        });
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Search stock, brand, batch, or category...',
                                                        prefixIcon: const Icon(
                                                            Icons
                                                                .search_rounded),
                                                        filled: true,
                                                        fillColor: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                          ),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            width: 1.6,
                                                          ),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 18,
                                                                vertical: 16),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    FFButtonWidget(
                                                      onPressed: () async {
                                                        scaffoldKey.currentState
                                                            ?.openEndDrawer();
                                                      },
                                                      text:
                                                          'Checkout: ZMK ${subtotal.toStringAsFixed(2)}',
                                                      options: FFButtonOptions(
                                                        width: double.infinity,
                                                        height: 52,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmallFamily,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmallIsCustom,
                                                                ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 14),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 10,
                                                children: [
                                                  _buildFilterChip(
                                                    context: context,
                                                    label: 'All',
                                                    selected:
                                                        _selectedCategory ==
                                                            'All',
                                                    onTap: () => safeSetState(
                                                      () => _selectedCategory =
                                                          'All',
                                                    ),
                                                  ),
                                                  ...[
                                                    'Medicine',
                                                    'Nutrition Suppliments',
                                                    'Veterinary Products',
                                                    'Beauty Care',
                                                    'Mother and Babycare',
                                                    'Personal Care'
                                                  ].map(
                                                    (label) => _buildFilterChip(
                                                      context: context,
                                                      label: label,
                                                      selected:
                                                          _selectedCategory ==
                                                              label,
                                                      onTap: () =>
                                                          safeSetState(() {
                                                        _selectedCategory =
                                                            label;
                                                      }),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        if (isWide)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: visibleStocks.isEmpty
                                                    ? _buildEmptyState(
                                                        context,
                                                        title: allStocks.isEmpty
                                                            ? 'No stock found for this pharmacy'
                                                            : 'No items match the current search',
                                                      )
                                                    : GridView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        itemCount: visibleStocks
                                                            .length,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 18,
                                                          mainAxisSpacing: 18,
                                                          childAspectRatio:
                                                              0.92,
                                                        ),
                                                        itemBuilder:
                                                            (context, index) {
                                                          final stock =
                                                              visibleStocks[
                                                                  index];
                                                          return _buildProductCard(
                                                              context, stock);
                                                        },
                                                      ),
                                              ),
                                              const SizedBox(width: 18),
                                              Expanded(
                                                flex: 1,
                                                child: _buildCashierSidebar(
                                                  context,
                                                  allStocks,
                                                  visibleStocks,
                                                  resolvedPharmacyName,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Column(
                                            children: [
                                              visibleStocks.isEmpty
                                                  ? _buildEmptyState(
                                                      context,
                                                      title: allStocks.isEmpty
                                                          ? 'No stock found for this pharmacy'
                                                          : 'No items match the current search',
                                                    )
                                                  : GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          visibleStocks.length,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 1,
                                                        crossAxisSpacing: 16,
                                                        mainAxisSpacing: 16,
                                                        childAspectRatio: 1.55,
                                                      ),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final stock =
                                                            visibleStocks[
                                                                index];
                                                        return _buildProductCard(
                                                            context, stock);
                                                      },
                                                    ),
                                              const SizedBox(height: 18),
                                              _buildCashierSidebar(
                                                context,
                                                allStocks,
                                                visibleStocks,
                                                resolvedPharmacyName,
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
