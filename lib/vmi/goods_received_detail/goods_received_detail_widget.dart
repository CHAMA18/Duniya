import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

class _GoodsReceivedDetailWidgetState extends State<GoodsReceivedDetailWidget> {
  late GoodsReceivedDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Line items state
  List<Map<String, dynamic>> _lineItems = [];
  String _existingRecordStatus = '';

  // Design tokens — Pulse purple design system
  static const Color _pulsePurple = Color(0xFF9900FF);
  static const Color _pulsePurpleDark = Color(0xFF7C3AED);

  /// Theme-aware palette — dark values mirror the app-wide Pulse dark
  /// theme (DarkModeTheme: #111827 bg, #1E1B2E surface, #F9FAFB text).
  bool _isDark = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  Color get _pulsePurpleLight =>
      _isDark ? const Color(0xFF2A2140) : Color(0xFFF3F0FF);
  Color get _bgColor =>
      _isDark ? const Color(0xFF111827) : Color(0xFFF8F9FF);
  Color get _surfaceColor =>
      _isDark ? const Color(0xFF1E1B2E) : Colors.white;
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF9FAFB) : Color(0xFF0B1C30);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF9CA3AF) : Color(0xFF64748B);
  Color get _textTertiary =>
      _isDark ? const Color(0xFF9CA3AF) : Color(0xFF94A3B8);
  Color get _borderColor =>
      _isDark ? const Color(0xFF3B3B4F) : Color(0xFFE2E8F0);
  Color get _borderHoverColor =>
      _isDark ? const Color(0xFF4B4B60) : Color(0xFFCBD5E1);

  // Semantic accents (used as accents only — never full backgrounds)
  static const Color _success = Color(0xFF16A34A);
  Color get _successBg =>
      _isDark ? const Color(0xFF16A34A).withAlpha(30) : Color(0xFFEFFDF5);
  static const Color _warning = Color(0xFFEA580C);
  Color get _warningBg =>
      _isDark ? const Color(0xFFEA580C).withAlpha(30) : Color(0xFFFFF7ED);
  static const Color _danger = Color(0xFFDC2626);
  Color get _dangerBg =>
      _isDark ? const Color(0xFFEF4444).withAlpha(30) : Color(0xFFFEF2F2);

  DocumentReference? _receiptScopeParent() {
    return AccessControl.networkWideQueryParent(context);
  }

  bool get _isPulseUser => AccessControl.isPulseUser(context);

  String get _workflowName =>
      _isPulseUser ? 'Goods Dispatched' : 'Goods Received';

  Future<List<PharmacyRecord>> _availablePharmacies() async {
    // Do not filter by NetworkStatus in Firestore. Older approved pharmacy
    // records predate that field; PharmacyRecord correctly treats a missing
    // value as active, but a Firestore equality query would exclude them.
    final pharmacies = await queryPharmacyRecordOnce(
      parent: _isPulseUser ? null : _receiptScopeParent(),
    );

    final available = _isPulseUser
        ? pharmacies
            .where((pharmacy) =>
                !pharmacy.deleted &&
                pharmacy.networkStatus.toLowerCase() == 'active' &&
                pharmacy.userID != null)
            .toList()
        : pharmacies;
    available.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return available;
  }

  Future<PharmacyRecord?> _resolveSelectedPharmacy(
      String? pharmacyPath) async {
    final path = pharmacyPath?.trim() ?? '';
    if (!RegExp(r'^User/[^/]+/Pharmacy/[^/]+$').hasMatch(path)) {
      return null;
    }

    final snapshot = await FirebaseFirestore.instance.doc(path).get();
    if (!snapshot.exists) return null;

    final pharmacy = PharmacyRecord.fromSnapshot(snapshot);
    if (_isPulseUser &&
        (pharmacy.deleted ||
            pharmacy.networkStatus.toLowerCase() != 'active' ||
            pharmacy.userID == null)) {
      return null;
    }
    return pharmacy;
  }

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
      final doc = await FirebaseFirestore.instance.doc(widget.docRef!).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _existingRecordStatus = data['Status'] as String? ?? '';
        _model.deliveryNoteTextController?.text =
            data['DeliveryNoteNumber'] as String? ?? '';
        safeSetState(() {
          _model.deliveryDate = data['DeliveryDate'] as DateTime?;
        });
        final outletRef = data['OutletId'] as DocumentReference?;
        if (outletRef != null) {
          final pharmacyDoc = await outletRef.get();
          if (pharmacyDoc.exists) {
            final pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
            final pharmacyName = pharmacyData['Name'] as String? ?? '';
            if (pharmacyName.isNotEmpty) {
              safeSetState(() {
                _model.pharmacyValue = outletRef.path;
                _model.pharmacyValueController ??=
                    FormFieldController<String>(outletRef.path);
                _model.pharmacyValueController!.value = outletRef.path;
              });
            }
          }
        }
        // Load line items subcollection
        final itemsSnapshot = await FirebaseFirestore.instance
            .doc(widget.docRef!)
            .collection('GoodsReceivedItem')
            .get();
        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();
          _lineItems.add({
            'productId': itemData['ProductId'] as DocumentReference?,
            'productName': (itemData['ProductName'] as String? ?? ''),
            'quantityDelivered': itemData['QuantityDelivered'] as int? ?? 0,
            'quantityReceived': itemData['QuantityReceived'] as int? ??
                itemData['QuantityDelivered'] as int? ??
                0,
            'batchNumber': itemData['BatchNumber'] as String? ?? '',
            'expiryDate': itemData['ExpiryDate'] as DateTime?,
            'discrepancy': itemData['Discrepancy'] as String? ?? '',
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

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────

  int get _totalDelivered => _lineItems.fold<int>(
      0, (sum, i) => sum + (i['quantityDelivered'] as int? ?? 0));

  int get _totalReceived => _lineItems.fold<int>(
      0, (sum, i) => sum + (i['quantityReceived'] as int? ?? 0));

  bool get _isPendingPulseDispatch =>
      !_isPulseUser &&
      widget.docRef != null &&
      _existingRecordStatus == 'PENDING';

  bool get _hasAnyDiscrepancy => _lineItems.any((item) {
        final delivered = item['quantityDelivered'] as int? ?? 0;
        final received = item['quantityReceived'] as int? ?? delivered;
        final discrepancy = (item['discrepancy'] as String? ?? '').trim();
        return delivered != received || discrepancy.isNotEmpty;
      });

  bool get _isFormValid {
    final note = _model.deliveryNoteTextController?.text.trim() ?? '';
    final pharmacy = (_model.pharmacyValue ?? '').trim();
    return note.isNotEmpty && pharmacy.isNotEmpty && _lineItems.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: _workflowName,
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: _bgColor,
            appBar: responsiveVisibility(
              context: context,
              tablet: false,
              tabletLandscape: false,
              desktop: false,
            )
                ? AppBar(
                    backgroundColor: _surfaceColor,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    leading: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 30.0,
                      borderWidth: 1.0,
                      buttonSize: 60.0,
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: _pulsePurple,
                        size: 30.0,
                      ),
                      onPressed: () async {
                        context.pop();
                      },
                    ),
                    title: Text(
                      _workflowName,
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    centerTitle: true,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          child: Container(
                            color: _bgColor,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth >= 900;
                                return Column(
                                  children: [
                                    // Scrollable content area
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isWide ? 32 : 16,
                                          vertical: isWide ? 28 : 16,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 1180,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildPageHeader(),
                                              SizedBox(height: 24),
                                              _buildReceiptInfoCard(isWide),
                                              SizedBox(height: 20),
                                              _buildLineItemsCard(isWide),
                                              SizedBox(height: 80),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Sticky action footer
                                    _buildStickyFooter(),
                                  ],
                                );
                              },
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

  // ─────────────────────────────────────────────────────────────────────
  // Page header (breadcrumb + title + status)
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    final isEditing = widget.docRef != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumb
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16, color: _pulsePurple),
                  SizedBox(width: 6),
                  Text(
                    'Back to $_workflowName',
                    style: TextStyle(
                      color: _pulsePurple,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 14),
        // Title row
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_pulsePurple, _pulsePurpleDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _pulsePurple.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.inbox_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Edit $_workflowName'
                      : _isPulseUser
                          ? 'Dispatch Goods'
                          : 'New Goods Receipt',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _isPulseUser
                      ? 'Ship inventory only to a registered, approved pharmacy. Pulse records the dispatch directly in that pharmacy workspace.'
                      : 'Record delivered inventory and verify quantities against the delivery note before stocking.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Section header helper (icon + title + subtitle + right slot)
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    int stepNumber = 0,
    Widget? rightSlot,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (stepNumber > 0) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _pulsePurpleLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _pulsePurple.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: TextStyle(
                  color: _pulsePurpleDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
        ],
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _pulsePurpleLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _pulsePurpleDark, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (rightSlot != null) rightSlot,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Receipt Information card
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildReceiptInfoCard(bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0B1C30).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.receipt_long_rounded,
              title:
                  _isPulseUser ? 'Dispatch Information' : 'Receipt Information',
              subtitle: _isPulseUser
                  ? 'Choose an approved pharmacy destination and dispatch details'
                  : 'Capture delivery note details and pharmacy',
              stepNumber: 1,
              rightSlot: _buildLiveBadge(
                label: 'Live',
                color: _success,
                bgColor: _successBg,
                dotColor: _success,
              ),
            ),
            SizedBox(height: 24),
            // Editable fields row
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildLabeledField(
                        label: 'Delivery Note Number',
                        isRequired: true,
                        child: _buildDeliveryNoteField(),
                      )),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildLabeledField(
                        label: _isPulseUser
                            ? 'Approved destination pharmacy'
                            : 'Pharmacy',
                        isRequired: true,
                        child: _buildPharmacyField(),
                      )),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildLabeledField(
                        label: 'Delivery Date',
                        child: _buildDeliveryDateField(),
                      )),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabeledField(
                        label: 'Delivery Note Number',
                        isRequired: true,
                        child: _buildDeliveryNoteField(),
                      ),
                      SizedBox(height: 16),
                      _buildLabeledField(
                        label: _isPulseUser
                            ? 'Approved destination pharmacy'
                            : 'Pharmacy',
                        isRequired: true,
                        child: _buildPharmacyField(),
                      ),
                      SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Delivery Date',
                        child: _buildDeliveryDateField(),
                      ),
                    ],
                  ),
            SizedBox(height: 20),
            // Divider between editable + read-only
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _borderColor.withValues(alpha: 0),
                    _borderColor,
                    _borderColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Read-only info chips
            isWide
                ? Row(
                    children: [
                      Expanded(
                          child: _buildInfoChip(
                        icon: Icons.event_available_rounded,
                        label: _isPulseUser ? 'Date Sent' : 'Date Received',
                        value: dateTimeFormat(
                          'yyyy-MM-dd HH:mm',
                          DateTime.now(),
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                      )),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildInfoChip(
                        icon: Icons.person_rounded,
                        label: _isPulseUser ? 'Sent By' : 'Received By',
                        value: currentUserDisplayName.isNotEmpty
                            ? currentUserDisplayName
                            : currentUserEmail,
                      )),
                    ],
                  )
                : Column(
                    children: [
                      _buildInfoChip(
                        icon: Icons.event_available_rounded,
                        label: _isPulseUser ? 'Date Sent' : 'Date Received',
                        value: dateTimeFormat(
                          'yyyy-MM-dd HH:mm',
                          DateTime.now(),
                          locale: FFLocalizations.of(context).languageCode,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildInfoChip(
                        icon: Icons.person_rounded,
                        label: _isPulseUser ? 'Sent By' : 'Received By',
                        value: currentUserDisplayName.isNotEmpty
                            ? currentUserDisplayName
                            : currentUserEmail,
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: _danger),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDeliveryNoteField() {
    return TextFormField(
      controller: _model.deliveryNoteTextController,
      focusNode: _model.deliveryNoteFocusNode,
      onChanged: (_) => safeSetState(() {}),
      decoration: _inputDecoration(
        hintText: 'e.g. DN-2026-001',
        icon: Icons.tag_rounded,
      ),
      style: TextStyle(
        color: _textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPharmacyField() {
    return AuthUserStreamWidget(
      builder: (context) => FutureBuilder<List<PharmacyRecord>>(
        future: _availablePharmacies(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 48,
              decoration: _inputBoxDecoration(),
              child: Center(
                child: SpinKitRing(
                  color: _pulsePurple,
                  size: 18,
                  lineWidth: 2,
                ),
              ),
            );
          }
          return Container(
            decoration: _inputBoxDecoration(),
            child: FlutterFlowDropDown<String>(
              controller: _model.pharmacyValueController ??=
                  FormFieldController<String>(null),
              options: snapshot.data!.map((p) => p.reference.path).toList(),
              optionLabels: snapshot.data!
                  .map((p) => p.address.trim().isEmpty
                      ? p.name
                      : '${p.name} · ${p.address}')
                  .toList(),
              onChanged: (val) =>
                  safeSetState(() => _model.pharmacyValue = val),
              width: double.infinity,
              height: 48,
              textStyle: TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintText: _isPulseUser
                  ? 'Select an approved pharmacy'
                  : 'Select pharmacy',
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _textSecondary,
                size: 20,
              ),
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderRadius: 10,
              elevation: 0,
              borderWidth: 0,
              margin: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
              hidesUnderline: true,
              isOverButton: false,
              isSearchable: _isPulseUser,
              isMultiSelect: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeliveryDateField() {
    final hasDate = _model.deliveryDate != null;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _model.deliveryDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2050),
        );
        if (date != null) {
          safeSetState(() {
            _model.deliveryDate = date;
          });
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        decoration: _inputBoxDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: hasDate ? _pulsePurple : _textTertiary,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                hasDate
                    ? dateTimeFormat(
                        'yyyy-MM-dd',
                        _model.deliveryDate!,
                        locale: FFLocalizations.of(context).languageCode,
                      )
                    : 'Select date',
                style: TextStyle(
                  color: hasDate ? _textPrimary : _textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Icon(icon, size: 16, color: _pulsePurpleDark),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: _textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge({
    required String label,
    required Color color,
    required Color bgColor,
    required Color dotColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Line Items card
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildLineItemsCard(bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0B1C30).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.inventory_2_outlined,
              title: 'Line Items',
              subtitle: 'Add each delivered product and verify quantities',
              stepNumber: 2,
              rightSlot: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_lineItems.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _pulsePurpleLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_lineItems.length} ${_lineItems.length == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          color: _pulsePurpleDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  SizedBox(width: 8),
                  _AddItemButton(onTap: () => _showAddLineItemDialog(context)),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_lineItems.isEmpty)
              _buildEmptyState()
            else ...[
              if (isWide) _buildColumnHeader(),
              if (isWide) SizedBox(height: 8),
              ..._lineItems.asMap().entries.map((entry) {
                return _buildLineItemRow(entry.key, entry.value, isWide);
              }),
              SizedBox(height: 16),
              _buildSummaryStrip(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 28),
          Expanded(
            flex: 4,
            child: Text(
              'PRODUCT',
              style: _columnHeaderStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'DELIVERED',
              style: _columnHeaderStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'RECEIVED',
              style: _columnHeaderStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'BATCH',
              style: _columnHeaderStyle,
            ),
          ),
          SizedBox(width: 36),
        ],
      ),
    );
  }

  static const TextStyle _columnHeaderStyle = TextStyle(
    color: Color(0xFF94A3B8),
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
  );

  Widget _buildLineItemRow(int idx, Map<String, dynamic> item, bool isWide) {
    final delivered = item['quantityDelivered'] as int? ?? 0;
    final received = item['quantityReceived'] as int? ?? delivered;
    final batchNumber = (item['batchNumber'] as String? ?? '').trim();
    final discrepancy = (item['discrepancy'] as String? ?? '').trim();
    final hasDiscrepancy = delivered != received || discrepancy.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDiscrepancy
                ? _warning.withValues(alpha: 0.35)
                : _borderColor,
          ),
        ),
        child: Stack(
          children: [
            // Left accent stripe
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: hasDiscrepancy ? _warning : _pulsePurple,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  isWide ? 16 : 12, 14, isWide ? 12 : 12, 14),
              child: isWide
                  ? _buildWideRow(idx, item, delivered, received, batchNumber,
                      discrepancy, hasDiscrepancy)
                  : _buildCompactRow(idx, item, delivered, received,
                      batchNumber, discrepancy, hasDiscrepancy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideRow(
    int idx,
    Map<String, dynamic> item,
    int delivered,
    int received,
    String batchNumber,
    String discrepancy,
    bool hasDiscrepancy,
  ) {
    return Row(
      children: [
        // Index badge
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _pulsePurpleLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${idx + 1}',
              style: TextStyle(
                color: _pulsePurpleDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        // Product info
        Expanded(
          flex: 4,
          child: FutureBuilder<ProductMasterRecord?>(
            future: item['productId'] != null
                ? (item['productId'] as DocumentReference)
                    .get()
                    .then((s) => ProductMasterRecord.fromSnapshot(s))
                : null,
            builder: (context, snapshot) {
              final productName =
                  snapshot.hasData ? snapshot.data!.name : 'Loading product...';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (discrepancy.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.report_problem_rounded,
                            size: 12, color: _warning),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            discrepancy,
                            style: TextStyle(
                              color: _warning,
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        // Delivered qty
        Expanded(
          flex: 2,
          child: _QtyChip(
            value: delivered,
            color: _textSecondary,
            bgColor: _bgColor,
          ),
        ),
        // Received qty
        Expanded(
          flex: 2,
          child: _QtyChip(
            value: received,
            color: hasDiscrepancy ? _warning : _success,
            bgColor: hasDiscrepancy ? _warningBg : _successBg,
            delta: received - delivered,
          ),
        ),
        // Batch
        Expanded(
          flex: 2,
          child: batchNumber.isEmpty
              ? Text(
                  '—',
                  style: TextStyle(color: _textTertiary, fontSize: 13),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bgColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Text(
                    batchNumber,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      // 'Roboto Mono' is not bundled in FontManifest — using
                      // an unregistered family crashes the CanvasKit text
                      // renderer on web (null typeface). Use the app font.
                      fontFamily: kAppFontFamily,
                    ),
                  ),
                ),
        ),
        // Status + delete
        Row(
          children: [
            _StatusPill(hasDiscrepancy: hasDiscrepancy),
            SizedBox(width: 8),
            _DeleteIconButton(
              onPressed: () {
                safeSetState(() {
                  _lineItems.removeAt(idx);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactRow(
    int idx,
    Map<String, dynamic> item,
    int delivered,
    int received,
    String batchNumber,
    String discrepancy,
    bool hasDiscrepancy,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _pulsePurpleLight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Center(
                child: Text(
                  '${idx + 1}',
                  style: TextStyle(
                    color: _pulsePurpleDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<ProductMasterRecord?>(
                future: item['productId'] != null
                    ? (item['productId'] as DocumentReference)
                        .get()
                        .then((s) => ProductMasterRecord.fromSnapshot(s))
                    : null,
                builder: (context, snapshot) {
                  final productName =
                      snapshot.hasData ? snapshot.data!.name : 'Loading...';
                  return Text(
                    productName,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            _StatusPill(hasDiscrepancy: hasDiscrepancy),
            SizedBox(width: 6),
            _DeleteIconButton(
              onPressed: () {
                safeSetState(() {
                  _lineItems.removeAt(idx);
                });
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniStat(
              label: 'Delivered',
              value: '$delivered',
              color: _textSecondary,
            ),
            _MiniStat(
              label: 'Received',
              value: '$received',
              color: hasDiscrepancy ? _warning : _success,
              delta: received - delivered,
            ),
            if (batchNumber.isNotEmpty)
              _MiniStat(
                label: 'Batch',
                value: batchNumber,
                color: _textPrimary,
              ),
          ],
        ),
        if (discrepancy.isNotEmpty) ...[
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _warningBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.report_problem_rounded, size: 14, color: _warning),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    discrepancy,
                    style: TextStyle(
                      color: _warning,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Empty state
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pulsePurple.withValues(alpha: 0.15),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pulsePurpleLight,
                  _pulsePurple.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_box_rounded,
              color: _pulsePurple,
              size: 36,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'No line items yet',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Add the first product delivered in this receipt to begin verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          _AddItemButton(
            onTap: () => _showAddLineItemDialog(context),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Summary strip (totals)
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildSummaryStrip() {
    final delta = _totalReceived - _totalDelivered;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize_rounded, size: 18, color: _pulsePurpleDark),
          SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 8,
              children: [
                _SummaryItem(
                  label: 'Items',
                  value: '${_lineItems.length}',
                ),
                _SummaryItem(
                  label: 'Total delivered',
                  value: '$_totalDelivered',
                ),
                _SummaryItem(
                  label: 'Total received',
                  value: '$_totalReceived',
                  color: _hasAnyDiscrepancy ? _warning : _success,
                ),
                if (delta != 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: delta < 0 ? _dangerBg : _warningBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${delta > 0 ? '+' : ''}$delta units',
                      style: TextStyle(
                        color: delta < 0 ? _danger : _warning,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (_hasAnyDiscrepancy)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: _warning),
                      SizedBox(width: 4),
                      Text(
                        'Discrepancies detected',
                        style: TextStyle(
                          color: _warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Sticky footer with actions
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildStickyFooter() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        border: Border(
          top: BorderSide(color: _borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0B1C30).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: Offset(0, -4),
            spreadRadius: -2,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          if (isWide) {
            return Row(
              children: [
                _buildFooterStatus(),
                Spacer(),
                _buildFooterActions(isWide: true),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterStatus(),
              SizedBox(height: 12),
              _buildFooterActions(isWide: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooterStatus() {
    if (_isFormValid) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _success.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            _isPulseUser && widget.docRef != null
                ? 'Awaiting confirmation from the receiving pharmacy'
                : 'Ready to confirm — ${_lineItems.length} ${_lineItems.length == 1 ? 'item' : 'items'} verified',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    // Not valid — show what's missing
    final missing = <String>[];
    if ((_model.deliveryNoteTextController?.text.trim() ?? '').isEmpty) {
      missing.add('delivery note');
    }
    if ((_model.pharmacyValue ?? '').trim().isEmpty) {
      missing.add('pharmacy');
    }
    if (_lineItems.isEmpty) {
      missing.add('line items');
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Missing: ${missing.join(", ")}',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterActions({required bool isWide}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SecondaryButton(
          label: 'Cancel',
          icon: Icons.close_rounded,
          onPressed: () => context.pop(),
        ),
        SizedBox(width: 10),
        _SecondaryButton(
          label: 'Flag Discrepancies',
          icon: Icons.flag_outlined,
          color: _warning,
          bgColor: _warningBg,
          onPressed: () => _showDiscrepancyDialog(context),
        ),
        SizedBox(width: 10),
        _PrimaryButton(
          label: _isPulseUser && widget.docRef != null
              ? 'Awaiting confirmation'
              : _isPulseUser
                  ? 'Dispatch to pharmacy'
                  : _isPendingPulseDispatch
                      ? 'Confirm delivery'
                      : 'Confirm Receipt',
          icon:
              _isPulseUser ? Icons.local_shipping_rounded : Icons.check_rounded,
          onPressed: _isPulseUser && widget.docRef != null
              ? null
              : _isFormValid
                  ? _confirmReceipt
                  : null,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Decorations
  // ─────────────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: _textTertiary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _bgColor,
      prefixIcon:
          icon != null ? Icon(icon, size: 18, color: _textTertiary) : null,
      prefixIconConstraints: BoxConstraints(minWidth: 36),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _pulsePurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _danger, width: 1.5),
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: _bgColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _borderColor),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Add Line Item dialog (redesigned)
  // ─────────────────────────────────────────────────────────────────────

  void _showAddLineItemDialog(BuildContext context) {
    _model.lineQtyTextController?.clear();
    _model.lineReceivedQtyTextController?.clear();
    _model.lineBatchTextController?.clear();
    _model.lineDiscrepancyTextController?.clear();
    _model.lineExpiryDate = null;
    _model.lineProductValue = null;
    _model.lineProductValueController = null;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: _surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with gradient
                      Container(
                        padding: EdgeInsets.fromLTRB(24, 22, 24, 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_pulsePurple, _pulsePurpleDark],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Line Item',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Select a product and record delivery details',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: Icon(Icons.close_rounded,
                                  color: Colors.white.withValues(alpha: 0.9)),
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      // Body
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product
                            _buildDialogFieldLabel('Product', isRequired: true),
                            SizedBox(height: 6),
                            StreamBuilder<List<ProductMasterRecord>>(
                              stream: queryProductMasterRecord(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 48,
                                    decoration: _inputBoxDecoration(),
                                    child: Center(
                                      child: SpinKitRing(
                                        color: _pulsePurple,
                                        size: 18,
                                        lineWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  decoration: _inputBoxDecoration(),
                                  child: FlutterFlowDropDown<String>(
                                    controller:
                                        _model.lineProductValueController ??=
                                            FormFieldController<String>(null),
                                    options: snapshot.data!
                                        .map((p) => p.name)
                                        .toList(),
                                    onChanged: (val) => setDialogState(
                                        () => _model.lineProductValue = val),
                                    width: double.infinity,
                                    height: 48,
                                    textStyle: TextStyle(
                                      color: _textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    hintText: 'Select product',
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: _textSecondary,
                                      size: 20,
                                    ),
                                    fillColor: Colors.transparent,
                                    borderColor: Colors.transparent,
                                    borderRadius: 10,
                                    elevation: 0,
                                    borderWidth: 0,
                                    margin: EdgeInsetsDirectional.fromSTEB(
                                        12, 0, 12, 0),
                                    hidesUnderline: true,
                                    isOverButton: false,
                                    isSearchable: false,
                                    isMultiSelect: false,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            // Quantity delivered + received
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDialogFieldLabel('Qty Delivered',
                                          isRequired: true),
                                      SizedBox(height: 6),
                                      TextFormField(
                                        controller:
                                            _model.lineQtyTextController,
                                        focusNode: _model.lineQtyFocusNode,
                                        decoration: _inputDecoration(
                                          hintText: '0',
                                          icon: Icons.local_shipping_rounded,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onChanged: (_) => setDialogState(() {}),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDialogFieldLabel('Qty Received'),
                                      SizedBox(height: 6),
                                      TextFormField(
                                        controller: _model
                                            .lineReceivedQtyTextController,
                                        focusNode:
                                            _model.lineReceivedQtyFocusNode,
                                        decoration: _inputDecoration(
                                          hintText: 'Auto = delivered',
                                          icon: Icons.check_circle_outline,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onChanged: (_) => setDialogState(() {}),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Discrepancy quick-check
                            _buildDiscrepancyIndicator(setDialogState),
                            SizedBox(height: 16),
                            // Batch + expiry
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDialogFieldLabel('Batch Number'),
                                      SizedBox(height: 6),
                                      TextFormField(
                                        controller:
                                            _model.lineBatchTextController,
                                        focusNode: _model.lineBatchFocusNode,
                                        decoration: _inputDecoration(
                                          hintText: 'e.g. BT-001',
                                          icon: Icons.label_outline,
                                        ),
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDialogFieldLabel('Expiry Date'),
                                      SizedBox(height: 6),
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
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 48,
                                          decoration: _inputBoxDecoration(),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.event_rounded,
                                                size: 16,
                                                color: _model.lineExpiryDate !=
                                                        null
                                                    ? _pulsePurple
                                                    : _textTertiary,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  _model.lineExpiryDate != null
                                                      ? dateTimeFormat(
                                                          'yyyy-MM-dd',
                                                          _model
                                                              .lineExpiryDate!,
                                                          locale:
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .languageCode,
                                                        )
                                                      : 'Select date',
                                                  style: TextStyle(
                                                    color:
                                                        _model.lineExpiryDate !=
                                                                null
                                                            ? _textPrimary
                                                            : _textTertiary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Discrepancy note
                            _buildDialogFieldLabel(
                                'Discrepancy Note (optional)'),
                            SizedBox(height: 6),
                            TextFormField(
                              controller: _model.lineDiscrepancyTextController,
                              focusNode: _model.lineDiscrepancyFocusNode,
                              maxLines: 2,
                              decoration: _inputDecoration(
                                hintText:
                                    'e.g. Short delivery, damaged packaging...',
                                icon: Icons.note_alt_outlined,
                              ),
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 24),
                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: _SecondaryButton(
                                    label: 'Cancel',
                                    icon: Icons.close_rounded,
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    expand: true,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _PrimaryButton(
                                    label: 'Add Item',
                                    icon: Icons.add_rounded,
                                    onPressed: _canAddItem()
                                        ? () => _onAddItem(dialogContext)
                                        : null,
                                    expand: true,
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
            );
          },
        );
      },
    );
  }

  bool _canAddItem() {
    return _model.lineProductValue != null &&
        (_model.lineQtyTextController?.text.trim().isNotEmpty ?? false);
  }

  Widget _buildDialogFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: _danger),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildDiscrepancyIndicator(StateSetter setDialogState) {
    final delivered =
        int.tryParse(_model.lineQtyTextController?.text ?? '0') ?? 0;
    final receivedStr = _model.lineReceivedQtyTextController?.text ?? '';
    final received = receivedStr.isEmpty
        ? delivered
        : (int.tryParse(receivedStr) ?? delivered);
    if (delivered == 0) return SizedBox.shrink();
    final delta = received - delivered;
    if (delta == 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _successBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _success.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: _success),
            SizedBox(width: 8),
            Text(
              'Quantities match — no discrepancy',
              style: TextStyle(
                color: _success,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: delta < 0 ? _dangerBg : _warningBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: (delta < 0 ? _danger : _warning).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded,
              size: 16, color: delta < 0 ? _danger : _warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              delta < 0
                  ? 'Short delivery — ${delta.abs()} units missing'
                  : 'Surplus — $delta extra units received',
              style: TextStyle(
                color: delta < 0 ? _danger : _warning,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAddItem(BuildContext dialogContext) async {
    if (_model.lineProductValue == null) return;
    // Find the product reference
    final products = await queryProductMasterRecordOnce();
    final product = products.firstWhere(
      (p) => p.name == _model.lineProductValue,
      orElse: () => products.first,
    );
    final deliveredQty =
        int.tryParse(_model.lineQtyTextController?.text ?? '0') ?? 0;
    final receivedQty =
        int.tryParse(_model.lineReceivedQtyTextController?.text ?? '') ??
            deliveredQty;
    safeSetState(() {
      _lineItems.add({
        'productId': product.reference,
        'productName': product.name,
        'quantityDelivered': deliveredQty,
        'quantityReceived': receivedQty,
        'batchNumber': _model.lineBatchTextController?.text ?? '',
        'expiryDate': _model.lineExpiryDate,
        'discrepancy': _model.lineDiscrepancyTextController?.text ?? '',
      });
    });
    _model.lineExpiryDate = null;
    Navigator.pop(dialogContext);
  }

  // ─────────────────────────────────────────────────────────────────────
  // Discrepancy dialog (redesigned)
  // ─────────────────────────────────────────────────────────────────────

  void _showDiscrepancyDialog(BuildContext context) {
    _model.discrepancyTextController ??= TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(24, 22, 24, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_warning, Color(0xFFC2410C)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.flag_rounded,
                              color: Colors.white, size: 22),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flag Discrepancies',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Describe any overall issues with this delivery',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close_rounded,
                              color: Colors.white.withValues(alpha: 0.9)),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDialogFieldLabel('Discrepancy Description',
                            isRequired: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: _model.discrepancyTextController,
                          focusNode: _model.discrepancyFocusNode,
                          maxLines: 4,
                          decoration: _inputDecoration(
                            hintText:
                                'e.g. Two cartons arrived damaged, supplier notified...',
                            icon: Icons.report_problem_outlined,
                          ),
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _SecondaryButton(
                                label: 'Cancel',
                                icon: Icons.close_rounded,
                                onPressed: () => Navigator.pop(dialogContext),
                                expand: true,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _PrimaryButton(
                                label: 'Submit Flag',
                                icon: Icons.flag_rounded,
                                color: _warning,
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Discrepancy flagged successfully'),
                                      backgroundColor: _warning,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                expand: true,
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
        );
      },
    );
  }

  Future<void> _confirmReceipt() async {
    if (_model.deliveryNoteTextController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter delivery note number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if ((_model.pharmacyValue ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a pharmacy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one line item'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ownerRef = _receiptScopeParent()!;
    final selectedPharmacy =
        await _resolveSelectedPharmacy(_model.pharmacyValue);
    if (selectedPharmacy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to resolve the selected pharmacy'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isPulseUser) {
      await _dispatchFromPulse(selectedPharmacy);
      return;
    }

    if (_isPendingPulseDispatch) {
      await _confirmPendingPulseDispatch();
      return;
    }

    final overallDiscrepancy =
        _model.discrepancyTextController?.text.trim() ?? '';
    final hasLineDiscrepancy = _lineItems.any((item) {
      final delivered = item['quantityDelivered'] as int? ?? 0;
      final received = item['quantityReceived'] as int? ?? delivered;
      final discrepancy = (item['discrepancy'] as String? ?? '').trim();
      return delivered != received || discrepancy.isNotEmpty;
    });
    final hasOverallDiscrepancy = overallDiscrepancy.isNotEmpty;
    final status = (hasLineDiscrepancy || hasOverallDiscrepancy)
        ? 'DISCREPANCY'
        : 'CONFIRMED';

    // Create GoodsReceived record
    final grDoc = GoodsReceivedRecord.createDoc(ownerRef);
    await grDoc.set(createGoodsReceivedRecordData(
      deliveryNoteNumber: _model.deliveryNoteTextController?.text,
      outletId: selectedPharmacy.reference,
      receivedById: currentUserReference,
      deliveryDate: _model.deliveryDate,
      receivedDate: getCurrentTimestamp,
      discrepancies: overallDiscrepancy.isEmpty ? null : overallDiscrepancy,
      status: status,
      createdAt: getCurrentTimestamp,
      updatedAt: getCurrentTimestamp,
    ));

    // Create line items, stock movements and apply the stock increase
    // (confirming a goods receipt automatically raises the pharmacy's
    // stock — matched by product name, creating missing stock docs).
    final stockByName = <String, DocumentReference>{};
    final stocks = await queryStockRecordOnce(parent: ownerRef);
    for (final s in stocks) {
      final key = s.name.trim().toLowerCase();
      if (key.isNotEmpty && !stockByName.containsKey(key)) {
        stockByName[key] = s.reference;
      }
    }

    for (var item in _lineItems) {
      final deliveredQty = item['quantityDelivered'] as int? ?? 0;
      final receivedQty = item['quantityReceived'] as int? ?? deliveredQty;
      final discrepancy = (item['discrepancy'] as String? ?? '').trim();
      // Create GoodsReceivedItem subcollection
      final itemDoc = GoodsReceivedItemRecord.createDoc(grDoc);
      await itemDoc.set(createGoodsReceivedItemRecordData(
        productId: item['productId'] as DocumentReference?,
        quantityDelivered: deliveredQty,
        quantityReceived: receivedQty,
        batchNumber: item['batchNumber'] as String?,
        expiryDate: item['expiryDate'] as DateTime?,
        discrepancy: discrepancy.isEmpty ? null : discrepancy,
      ));

      // Create StockMovement (RECEIVED type)
      final movementDoc = StockMovementRecord.createDoc(ownerRef);
      await movementDoc.set(createStockMovementRecordData(
        productId: item['productId'] as DocumentReference?,
        productName: (item['productName'] as String?)?.trim(),
        outletId: selectedPharmacy.reference,
        quantity: receivedQty,
        movementType: 'RECEIVED',
        movementReference: _model.deliveryNoteTextController?.text,
        recordedById: currentUserReference,
        createdAt: getCurrentTimestamp,
      ));

      // Apply the stock increase for this item.
      final productRef = item['productId'] as DocumentReference?;
      final productName =
          (item['productName'] as String? ?? '').trim();
      if (receivedQty > 0 && productName.isNotEmpty) {
        final key = productName.toLowerCase();
        final existing = stockByName[key];
        if (existing != null) {
          await existing.update({
            'Quantity': FieldValue.increment(receivedQty),
            'UpdatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final newStockRef = StockRecord.createDoc(ownerRef);
          stockByName[key] = newStockRef;
          await newStockRef.set(createStockRecordData(
            name: productName,
            quantity: receivedQty,
            price: 0.0,
            limitNotice: 0,
            initialQuantity: receivedQty.toDouble(),
          ));
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goods receipt confirmed and stock updated'),
        backgroundColor: _success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  Future<void> _confirmPendingPulseDispatch() async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('confirmPulseDispatch');
      await callable.call(<String, dynamic>{
        'receiptPath': widget.docRef,
        'discrepancies': _model.discrepancyTextController?.text.trim(),
        'items': _lineItems.map((item) {
          final itemRef = item['reference'] as DocumentReference?;
          return <String, dynamic>{
            'itemPath': itemRef?.path,
            'quantityReceived': item['quantityReceived'],
            'discrepancy': item['discrepancy'],
          };
        }).toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery confirmed and stock updated.'),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Unable to confirm this delivery.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _dispatchFromPulse(PharmacyRecord pharmacy) async {
    if (pharmacy.networkStatus != 'active') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Only approved active pharmacies can receive a dispatch.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('dispatchGoodsToPharmacy');
      await callable.call(<String, dynamic>{
        'pharmacyPath': pharmacy.reference.path,
        'deliveryNoteNumber': _model.deliveryNoteTextController?.text.trim(),
        'deliveryDate': _model.deliveryDate?.millisecondsSinceEpoch,
        'items': _lineItems.map((item) {
          final productRef = item['productId'] as DocumentReference?;
          return <String, dynamic>{
            'productPath': productRef?.path,
            'quantityDelivered': item['quantityDelivered'],
            'quantityReceived': item['quantityReceived'],
            'batchNumber': item['batchNumber'],
            'expiryDate':
                (item['expiryDate'] as DateTime?)?.millisecondsSinceEpoch,
            'discrepancy': item['discrepancy'],
          };
        }).toList(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Goods dispatched to ${pharmacy.name}.'),
          backgroundColor: _success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Unable to dispatch goods.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Reusable presentational widgets
// ─────────────────────────────────────────────────────────────────────────

class _AddItemButton extends StatefulWidget {
  const _AddItemButton({
    required this.onTap,
    this.isPrimary = false,
  });

  final VoidCallback onTap;
  final bool isPrimary;

  @override
  State<_AddItemButton> createState() => _AddItemButtonState();
}

class _AddItemButtonState extends State<_AddItemButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final purple = Color(0xFF9900FF);
    final purpleDark = Color(0xFF7C3AED);
    if (widget.isPrimary) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [purple, purpleDark],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: purple.withValues(alpha: _hover ? 0.4 : 0.28),
                  blurRadius: _hover ? 16 : 10,
                  offset: Offset(0, _hover ? 6 : 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Add First Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? purple : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: purple.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded,
                  color: _hover ? Colors.white : purple, size: 16),
              SizedBox(width: 6),
              Text(
                'Add Item',
                style: TextStyle(
                  color: _hover ? Colors.white : purpleDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyChip extends StatelessWidget {
  const _QtyChip({
    required this.value,
    required this.color,
    required this.bgColor,
    this.delta,
  });

  final int value;
  final Color color;
  final Color bgColor;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (delta != null && delta != 0) ...[
              SizedBox(width: 6),
              Text(
                '${delta! > 0 ? "+" : ""}$delta',
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.delta,
  });

  final String label;
  final String value;
  final Color color;
  final int? delta;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1B2E) : Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isDark ? Color(0xFF3B3B4F) : Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isDark ? Color(0xFF9CA3AF) : Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (delta != null && delta != 0) ...[
            SizedBox(width: 4),
            Text(
              '${delta! > 0 ? "+" : ""}$delta',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.hasDiscrepancy});
  final bool hasDiscrepancy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (hasDiscrepancy) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFFEA580C).withAlpha(30) : Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xFFEA580C).withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 12, color: Color(0xFFEA580C)),
            SizedBox(width: 4),
            Text(
              'DISCREPANCY',
              style: TextStyle(
                color: Color(0xFFEA580C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF16A34A).withAlpha(30) : Color(0xFFEFFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF16A34A).withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
          SizedBox(width: 4),
          Text(
            'VERIFIED',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteIconButton extends StatefulWidget {
  const _DeleteIconButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_DeleteIconButton> createState() => _DeleteIconButtonState();
}

class _DeleteIconButtonState extends State<_DeleteIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hover ? Color(0xFFFEF2F2) : Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hover
                  ? Color(0xFFDC2626).withValues(alpha: 0.3)
                  : Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            size: 15,
            color: _hover ? Color(0xFFDC2626) : Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Color(0xFF0B1C30),
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expand = false,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool expand;
  final Color? color;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? Color(0xFF9900FF);
    final dark = widget.color != null
        ? Color.lerp(widget.color, Colors.black, 0.18)!
        : Color(0xFF7C3AED);
    final enabled = widget.onPressed != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? [base, dark]
                  : [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: base.withValues(alpha: _hover ? 0.42 : 0.28),
                      blurRadius: _hover ? 16 : 10,
                      offset: Offset(0, _hover ? 6 : 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
    this.bgColor,
    this.expand = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? bgColor;
  final bool expand;

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Color(0xFF64748B);
    final bgColor = widget.bgColor ?? Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: _hover ? color.withValues(alpha: 0.08) : bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hover ? color.withValues(alpha: 0.5) : Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 15, color: color),
              SizedBox(width: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
