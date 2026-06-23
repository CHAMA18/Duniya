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
  const SalesVMIWidget({
    super.key,
    this.pharmacy,
  });

  final String? pharmacy;

  static String routeName = 'SalesVMI';
  static String routePath = '/salesVMI';

  @override
  State<SalesVMIWidget> createState() => _SalesVMIWidgetState();
}

class _SalesVMIWidgetState extends State<SalesVMIWidget> {
  late SalesVMIModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _saleLineItems = [];

  // ── Purple Design Tokens ──
  static const Color _primary = Color(0xFFA100FF);
  static const Color _deep = Color(0xFF6A00D9);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _light = Color(0xFFE8D5FF);
  static const Color _bg = Color(0xFFF8F5FF);
  static const Color _surface = Colors.white;
  static const Color _textDark = Color(0xFF1A0533);
  static const Color _textMuted = Color(0xFF7C6E93);

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

  // ── KPI Card Builder ──
  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _light.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sale Card Builder ──
  Widget _buildSaleCard(SaleRecordVMI sale, int index, bool isPhone) {
    final hasPatient = sale.hasPatientRef();
    final dateStr = sale.hasSaleDate()
        ? dateTimeFormat('yMMMd', sale.saleDate!,
            locale: FFLocalizations.of(context).languageCode)
        : '-';
    final timeStr = sale.hasSaleDate()
        ? dateTimeFormat('jm', sale.saleDate!,
            locale: FFLocalizations.of(context).languageCode)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _light.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Order number badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_deep, _primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPatient
                      ? 'Patient: ${sale.patientRef!}'
                      : 'Sale #${index + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                      ),
                    ),
                    if (timeStr.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ZMK ${formatNumber(
                sale.totalAmount,
                formatType: FormatType.compact,
              )}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState(bool isPhone) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_light, Color(0xFFF3E8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.point_of_sale_rounded,
                color: _primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Sales Recorded Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start by recording your first sale.\nTap "New Sale" to begin dispensing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => _showAddSaleDialog(context),
              text: 'Record Your First Sale',
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
              options: FFButtonOptions(
                height: 48,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                color: _primary,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                elevation: 0,
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = responsiveVisibility(
      context: context,
      tablet: false,
      tabletLandscape: false,
      desktop: false,
    );

    return Title(
      title: 'Sales / Dispensing',
      color: _primary,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: Drawer(
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
                // Sidebar (desktop)
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
                // Main content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Nav
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
                            openDrawer: () async {
                              scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                        ),
                      // Page Body
                      Expanded(
                        child: AuthUserStreamWidget(
                          builder: (context) {
                            final parentRef = valueOrDefault(
                                        currentUserDocument?.role, '') ==
                                    'Owner'
                                ? currentUserReference
                                : currentUserDocument?.ownerRef;

                            return StreamBuilder<List<SaleRecordVMI>>(
                              stream: querySaleRecordVMI(
                                parent: parentRef,
                                queryBuilder: (q) => q.orderBy('CreatedAt',
                                    descending: true),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red, size: 48),
                                        const SizedBox(height: 12),
                                        const Text('Something went wrong',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16)),
                                      ],
                                    ),
                                  );
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SpinKitRing(
                                        color: _primary, size: 48),
                                  );
                                }

                                final sales = snapshot.data!;

                                // Compute KPIs
                                final totalSales = sales.length;
                                double totalRevenue = sales.fold(
                                    0.0,
                                    (sum, s) =>
                                        sum + s.totalAmount);
                                final today = DateTime.now();
                                final todaySales = sales.where((s) {
                                  if (s.saleDate == null) return false;
                                  return s.saleDate!.year == today.year &&
                                      s.saleDate!.month == today.month &&
                                      s.saleDate!.day == today.day;
                                }).length;
                                double todayRevenue = sales
                                    .where((s) {
                                      if (s.saleDate == null) return false;
                                      return s.saleDate!.year ==
                                              today.year &&
                                          s.saleDate!.month == today.month &&
                                          s.saleDate!.day == today.day;
                                    })
                                    .fold(0.0,
                                        (sum, s) => sum + s.totalAmount);
                                double avgSale = totalSales > 0
                                    ? totalRevenue / totalSales
                                    : 0.0;

                                return SingleChildScrollView(
                                  padding: EdgeInsets.fromLTRB(
                                    isPhone ? 16 : 28,
                                    24,
                                    isPhone ? 16 : 28,
                                    32,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Gradient Header ──
                                      Container(
                                        padding: EdgeInsets.all(
                                            isPhone ? 20 : 28),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              _deep,
                                              _primary,
                                              _accent
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _primary.withOpacity(0.3),
                                              blurRadius: 24,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Sales & Dispensing',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.white,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Track pharmacy sales, dispensing records, and revenue at a glance.',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            FFButtonWidget(
                                              onPressed: () =>
                                                  _showAddSaleDialog(context),
                                              text: 'New Sale',
                                              icon: const Icon(
                                                  Icons.add_rounded,
                                                  size: 18),
                                              options: FFButtonOptions(
                                                height: 44,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        20, 0, 20, 0),
                                                color: Colors.white,
                                                textStyle: const TextStyle(
                                                  color: _primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                                elevation: 0,
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // ── KPI Cards ──
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          int cols = 5;
                                          if (constraints.maxWidth < 1200) {
                                            cols = 3;
                                          }
                                          if (constraints.maxWidth < 800) {
                                            cols = 2;
                                          }
                                          if (constraints.maxWidth < 520) {
                                            cols = 1;
                                          }
                                          final cards = [
                                            _buildKpiCard(
                                              title: 'Total Revenue',
                                              value:
                                                  'ZMK ${formatNumber(totalRevenue, formatType: FormatType.compact)}',
                                              icon: Icons
                                                  .account_balance_wallet_rounded,
                                              color: const Color(0xFF059669),
                                              bgColor:
                                                  const Color(0xFFD1FAE5),
                                            ),
                                            _buildKpiCard(
                                              title: 'Total Sales',
                                              value: '$totalSales',
                                              icon: Icons
                                                  .receipt_long_rounded,
                                              color: _primary,
                                              bgColor: _light.withOpacity(0.5),
                                            ),
                                            _buildKpiCard(
                                              title: 'Today\'s Sales',
                                              value: '$todaySales',
                                              icon: Icons
                                                  .today_outlined,
                                              color: const Color(0xFF10B981),
                                              bgColor:
                                                  const Color(0xFFD1FAE5),
                                            ),
                                            _buildKpiCard(
                                              title: 'Today\'s Revenue',
                                              value:
                                                  'ZMK ${formatNumber(todayRevenue, formatType: FormatType.compact)}',
                                              icon: Icons.today_rounded,
                                              color: const Color(0xFF2563EB),
                                              bgColor:
                                                  const Color(0xFFDBEAFE),
                                            ),
                                            _buildKpiCard(
                                              title: 'Average Sale',
                                              value:
                                                  'ZMK ${formatNumber(avgSale, formatType: FormatType.compact)}',
                                              icon: Icons
                                                  .trending_up_rounded,
                                              color: const Color(0xFFD97706),
                                              bgColor:
                                                  const Color(0xFFFEF3C7),
                                            ),
                                          ];

                                          return SizedBox(
                                            width: double.infinity,
                                            child: GridView.count(
                                              crossAxisCount: cols,
                                              crossAxisSpacing: 14,
                                              mainAxisSpacing: 14,
                                              childAspectRatio:
                                                  cols == 1 ? 2.4 : 1.18,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: cards,
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // ── Sales List Section ──
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: _surface,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: _light.withOpacity(0.5)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 14,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        color: _light
                                                            .withOpacity(0.4),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .receipt_long_outlined,
                                                        color: _primary,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Recent Sales',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _textDark,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (!isPhone)
                                                  FFButtonWidget(
                                                    onPressed: () =>
                                                        _showAddSaleDialog(
                                                            context),
                                                    text: 'New Sale',
                                                    icon: const Icon(
                                                        Icons.add_rounded,
                                                        size: 16),
                                                    options: FFButtonOptions(
                                                      height: 38,
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(16, 0,
                                                              16, 0),
                                                      color: _primary,
                                                      textStyle:
                                                          const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                      ),
                                                      elevation: 0,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 18),
                                            if (sales.isEmpty)
                                              _buildEmptyState(isPhone)
                                            else
                                              ...sales
                                                  .asMap()
                                                  .entries
                                                  .map((e) =>
                                                      _buildSaleCard(
                                                          e.value,
                                                          e.key,
                                                          isPhone)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Mobile bottom nav
                      if (isPhone)
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
      ),
    );
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_deep, _primary]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_shopping_cart_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Record New Sale',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _textDark)),
                ],
              ),
              content: Container(
                width:
                    MediaQuery.sizeOf(context).width > 600
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
                                  color: _primary, size: 20.0);
                            }
                            return FlutterFlowDropDown<String>(
                              controller:
                                  _model.dialogPharmacyValueController ??=
                                      FormFieldController<String>(null),
                              options: snapshot.data!
                                  .map((p) => p.name)
                                  .toList(),
                              onChanged: (val) => setDialogState(
                                  () => _model.dialogPharmacyValue = val),
                              width: double.infinity,
                              height: 48.0,
                              textStyle: const TextStyle(
                                  fontSize: 14, color: _textDark),
                              hintText: 'Select Pharmacy',
                              fillColor: _bg,
                              borderColor: _light,
                              borderRadius: 12.0,
                              elevation: 2,
                              borderWidth: 1.0,
                              margin: EdgeInsets.zero,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _model.dialogPatientRefTextController,
                        decoration: InputDecoration(
                          labelText: 'Patient Reference',
                          prefixIcon: const Icon(Icons.person_outline,
                              color: _primary),
                          filled: true,
                          fillColor: _bg,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _light),
                          ),
                        ),
                        style: const TextStyle(
                            fontSize: 14, color: _textDark),
                      ),
                      const SizedBox(height: 20),
                      const Text('Line Items',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              fontSize: 15)),
                      const SizedBox(height: 8),
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
                                      color: _primary, size: 16.0);
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
                                  textStyle: const TextStyle(
                                      fontSize: 12, color: _textDark),
                                  hintText: 'Product',
                                  fillColor: _bg,
                                  borderColor: _light,
                                  borderRadius: 10.0,
                                  elevation: 2,
                                  borderWidth: 1.0,
                                  margin: EdgeInsets.zero,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 60.0,
                            child: TextFormField(
                              controller: _model.lineQtyTextController,
                              decoration: InputDecoration(
                                hintText: 'Qty',
                                filled: true,
                                fillColor: _bg,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _light),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 12, color: _textDark),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 80.0,
                            child: TextFormField(
                              controller: _model.linePriceTextController,
                              decoration: InputDecoration(
                                hintText: 'Price',
                                filled: true,
                                fillColor: _bg,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: _light),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  fontSize: 12, color: _textDark),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: _primary),
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
                      const SizedBox(height: 8),
                      // List of added items
                      ..._saleLineItems
                          .asMap()
                          .entries
                          .map((entry) {
                        int idx = entry.key;
                        var item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _light.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item['productName'],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _textDark),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                    'x${item['quantity']} @ ZMK ${item['sellingPrice'].toStringAsFixed(2)} = ZMK ${item['total'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: _textMuted)),
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline,
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
                  child: const Text('Cancel',
                      style: TextStyle(color: _textMuted)),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    if (_saleLineItems.isEmpty) return;
                    // Null-safe owner ref resolution — prevents crash
                    // when currentUserDocument or ownerRef is null.
                    final userDoc = currentUserDocument;
                    final DocumentReference ownerRef;
                    if (userDoc == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'User profile not loaded yet. Please try again in a moment.')),
                      );
                      return;
                    }
                    if (valueOrDefault(userDoc.role, '') == 'Owner') {
                      final ref = currentUserReference;
                      if (ref == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Unable to identify your account.')),
                        );
                        return;
                      }
                      ownerRef = ref;
                    } else {
                      final ref = userDoc.ownerRef;
                      if (ref == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'No owner pharmacy is linked to your account. Please contact your administrator.')),
                        );
                        return;
                      }
                      ownerRef = ref;
                    }

                    double totalAmount = _saleLineItems.fold(
                        0.0, (sum, item) => sum + (item['total'] as double));

                    // Create SaleVMI record
                    final saleDoc = SaleRecordVMI.createDoc(ownerRef);
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
                      await movementDoc.set(createStockMovementRecordData(
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
                    height: 44.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20.0, 0.0, 20.0, 0.0),
                    color: _primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                    ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(14.0),
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
