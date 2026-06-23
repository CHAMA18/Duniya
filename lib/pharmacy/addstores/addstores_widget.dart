import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addstores_model.dart';
export 'addstores_model.dart';

class AddstoresWidget extends StatefulWidget {
  const AddstoresWidget({super.key});

  static String routeName = 'addstores';
  static String routePath = '/addstores';

  @override
  State<AddstoresWidget> createState() => _AddstoresWidgetState();
}

class _AddstoresWidgetState extends State<AddstoresWidget>
    with TickerProviderStateMixin {
  late AddstoresModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // RBAC role definitions with permissions
  static const List<Map<String, dynamic>> _rbacRoles = [
    {
      'role': 'Owner',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFF9900FF),
      'bgColor': Color(0xFFF3EAFF),
      'description': 'Full access to all features, settings, and member management',
      'permissions': [
        'Create & delete pharmacies',
        'Manage team members & RBAC',
        'Access all financial data',
        'Configure outlets',
        'Approve pending requests',
      ],
    },
    {
      'role': 'Pharmacist',
      'icon': Icons.medication_rounded,
      'color': Color(0xFF059669),
      'bgColor': Color(0xFFD1FAE5),
      'description': 'Professional dispensing, stock management, and patient care',
      'permissions': [
        'Dispense medications',
        'Manage store inventory',
        'View stock balances & batches',
        'Process sales transactions',
        'View expiry alerts',
      ],
    },
    {
      'role': 'Pharmacy Technician',
      'icon': Icons.science_rounded,
      'color': Color(0xFF2563EB),
      'bgColor': Color(0xFFDBEAFE),
      'description': 'Inventory operations, stock counts, and goods receiving',
      'permissions': [
        'Perform stock counts',
        'Receive goods',
        'Update inventory records',
        'View stock movements',
        'Manage batch records',
      ],
    },
    {
      'role': 'Outlet Manager',
      'icon': Icons.store_rounded,
      'color': Color(0xFFD97706),
      'bgColor': Color(0xFFFEF3C7),
      'description': 'Manage assigned outlet operations and outlet-level reporting',
      'permissions': [
        'Manage assigned outlet',
        'View outlet inventory',
        'Process outlet sales',
        'View outlet stock alerts',
        'Request replenishment',
      ],
    },
    {
      'role': 'Cashier',
      'icon': Icons.point_of_sale_rounded,
      'color': Color(0xFF7C3AED),
      'bgColor': Color(0xFFF3EAFF),
      'description': 'Point-of-sale transactions and receipt management',
      'permissions': [
        'Process sales & payments',
        'Generate receipts',
        'View product catalogue',
        'Apply discounts (limited)',
      ],
    },
    {
      'role': 'Staff',
      'icon': Icons.badge_rounded,
      'color': Color(0xFF6B7280),
      'bgColor': Color(0xFFF3F4F6),
      'description': 'Basic operational access with supervised permissions',
      'permissions': [
        'View product catalogue',
        'Assist with stock counts',
        'View basic reports',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddstoresModel());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => safeSetState(() {}));

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'addstores'});
    _model.pharmacyNameTextController ??= TextEditingController();
    _model.pharmacyNameFocusNode ??= FocusNode();
    _model.addressTextController ??= TextEditingController();
    _model.addressFocusNode ??= FocusNode();
    _model.phoneTextController ??= TextEditingController();
    _model.phoneFocusNode ??= FocusNode();
    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.licenseTextController ??= TextEditingController();
    _model.licenseFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── STEP INDICATOR ──────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final theme = FlutterFlowTheme.of(context);
    final steps = [
      {'label': 'Pharmacy Details', 'icon': Icons.local_pharmacy_rounded},
      {'label': 'Outlets', 'icon': Icons.store_rounded},
      {'label': 'Team & Roles', 'icon': Icons.group_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = _tabController.index == index;
          final isCompleted = _tabController.index > index;
          final step = steps[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                safeSetState(() {});
              },
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF9900FF)
                                : isCompleted
                                    ? const Color(0xFF059669)
                                    : theme.primaryBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF9900FF)
                                  : isCompleted
                                      ? const Color(0xFF059669)
                                      : theme.alternate,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded,
                                    size: 18, color: Colors.white)
                                : Icon(
                                    step['icon'] as IconData,
                                    size: 16,
                                    color: isActive
                                        ? Colors.white
                                        : theme.secondaryText,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step ${index + 1}',
                                style: theme.bodySmall?.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  useGoogleFonts: !theme.bodySmallIsCustom,
                                ),
                              ),
                              Text(
                                step['label'] as String,
                                style: theme.bodyMedium?.override(
                                  fontFamily: theme.bodyMediumFamily,
                                  fontWeight: isActive || isCompleted
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? const Color(0xFF9900FF)
                                      : isCompleted
                                          ? const Color(0xFF059669)
                                          : theme.secondaryText,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodyMediumIsCustom,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 32,
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF059669)
                            : theme.alternate.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── PHARMACY DETAILS TAB ────────────────────────────────────────────────

  Widget _buildPharmacyDetailsTab() {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9900FF), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9900FF).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Your Pharmacy',
                            style: theme.headlineMedium?.override(
                              fontFamily: theme.headlineMediumFamily,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              letterSpacing: -0.3,
                              useGoogleFonts: !theme.headlineMediumIsCustom,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Set up your pharmacy details to get started with Duniya',
                            style: theme.bodyMedium?.override(
                              fontFamily: theme.bodyMediumFamily,
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fill in the required fields below. You can add outlets and team members in the next steps.',
                          style: theme.bodySmall?.override(
                            fontFamily: theme.bodySmallFamily,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Form fields
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.alternate.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9900FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_note_rounded,
                          color: Color(0xFF9900FF), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Pharmacy Information',
                      style: theme.titleMedium?.override(
                        fontFamily: theme.titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pharmacy Name
                _buildFormField(
                  label: 'Pharmacy Name *',
                  hint: 'e.g. MediCare Pharmacy',
                  controller: _model.pharmacyNameTextController,
                  focusNode: _model.pharmacyNameFocusNode,
                  prefixIcon: Icons.local_pharmacy_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Address
                _buildFormField(
                  label: 'Address *',
                  hint: 'e.g. 123 Health Street, Lusaka',
                  controller: _model.addressTextController,
                  focusNode: _model.addressFocusNode,
                  prefixIcon: Icons.location_on_rounded,
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Row: Phone & Email
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Phone Number',
                        hint: '+260 97X XXX XXX',
                        controller: _model.phoneTextController,
                        focusNode: _model.phoneFocusNode,
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Email Address',
                        hint: 'pharmacy@example.com',
                        controller: _model.emailTextController,
                        focusNode: _model.emailFocusNode,
                        prefixIcon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // License
                _buildFormField(
                  label: 'License / Registration Number',
                  hint: 'e.g. ZAM-PH-2024-001',
                  controller: _model.licenseTextController,
                  focusNode: _model.licenseFocusNode,
                  prefixIcon: Icons.verified_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── OUTLETS TAB ─────────────────────────────────────────────────────────

  Widget _buildOutletsTab() {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacy Outlets',
                        style: theme.headlineMedium?.override(
                          fontFamily: theme.headlineMediumFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -0.3,
                          useGoogleFonts: !theme.headlineMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add dispensing points for your pharmacy branches',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_model.outletDrafts.length} added',
                    style: theme.bodySmall?.override(
                      fontFamily: theme.bodySmallFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add outlet form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: theme.alternate.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_business_rounded,
                          color: Color(0xFF7C3AED), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add New Outlet',
                      style: theme.titleMedium?.override(
                        fontFamily: theme.titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildFormField(
                        label: 'Outlet Name *',
                        hint: 'e.g. Main Branch',
                        controller: _model.outletNameTextController,
                        focusNode: _model.outletNameFocusNode,
                        prefixIcon: Icons.store_rounded,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildFormField(
                        label: 'Outlet Code *',
                        hint: 'e.g. MB-001',
                        controller: _model.outletCodeTextController,
                        focusNode: _model.outletCodeFocusNode,
                        prefixIcon: Icons.qr_code_rounded,
                        isRequired: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: 'Address',
                  hint: 'Outlet address (optional)',
                  controller: _model.outletAddressTextController,
                  focusNode: _model.outletAddressFocusNode,
                  prefixIcon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _addOutletDraft,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Outlet'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                      side: const BorderSide(
                          color: Color(0xFF7C3AED), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Outlet drafts list
          if (_model.outletDrafts.isNotEmpty) ...[
            Text(
              'Configured Outlets',
              style: theme.titleMedium?.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                useGoogleFonts: !theme.titleMediumIsCustom,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _model.outletDrafts.asMap().entries.map((entry) {
                final index = entry.key;
                final outlet = entry.value;
                return _buildOutletDraftCard(context, outlet, index);
              }).toList(),
            ),
          ],

          if (_model.outletDrafts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: theme.alternate.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.store_outlined,
                      size: 48, color: theme.secondaryText),
                  const SizedBox(height: 12),
                  Text(
                    'No outlets added yet',
                    style: theme.bodyMedium?.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add at least one outlet to enable dispensing at this pharmacy',
                    style: theme.bodySmall?.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutletDraftCard(
      BuildContext context, OutletDraft outlet, int index) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store_rounded,
                    color: Color(0xFF7C3AED), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outlet.name,
                      style: theme.bodyMedium?.override(
                        fontFamily: theme.bodyMediumFamily,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9900FF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        outlet.code,
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: const Color(0xFF9900FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.5,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    safeSetState(() {
                      _model.outletDrafts.removeAt(index);
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Color(0xFFDC2626)),
                  ),
                ),
              ),
            ],
          ),
          if (outlet.address.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 12, color: theme.secondaryText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    outlet.address,
                    style: theme.bodySmall?.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 11,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── TEAM & ROLES TAB ────────────────────────────────────────────────────

  Widget _buildTeamRolesTab() {
    final theme = FlutterFlowTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.group_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Members & RBAC',
                        style: theme.headlineMedium?.override(
                          fontFamily: theme.headlineMediumFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -0.3,
                          useGoogleFonts: !theme.headlineMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assign roles and permissions to your pharmacy team',
                        style: theme.bodyMedium?.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_model.memberDrafts.length} members',
                    style: theme.bodySmall?.override(
                      fontFamily: theme.bodySmallFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // RBAC Roles Reference Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: theme.alternate.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9900FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield_rounded,
                          color: Color(0xFF9900FF), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Available Roles & Permissions',
                      style: theme.titleMedium?.override(
                        fontFamily: theme.titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _rbacRoles.map((rbac) {
                    return Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (rbac['bgColor'] as Color)
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              (rbac['color'] as Color).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: rbac['color'] as Color,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Icon(
                                  rbac['icon'] as IconData,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rbac['role'] as String,
                                  style: theme.bodyMedium?.override(
                                    fontFamily: theme.bodyMediumFamily,
                                    fontWeight: FontWeight.w700,
                                    color: rbac['color'] as Color,
                                    fontSize: 12,
                                    useGoogleFonts: !theme.bodyMediumIsCustom,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rbac['description'] as String,
                            style: theme.bodySmall?.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              fontSize: 10,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add member form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: theme.alternate.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Color(0xFF059669), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add Team Member',
                      style: theme.titleMedium?.override(
                        fontFamily: theme.titleMediumFamily,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Full Name *',
                        hint: 'e.g. Jane Banda',
                        controller: _model.memberNameTextController,
                        focusNode: _model.memberNameFocusNode,
                        prefixIcon: Icons.person_rounded,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFormField(
                        label: 'Email *',
                        hint: 'jane@example.com',
                        controller: _model.memberEmailTextController,
                        focusNode: _model.memberEmailFocusNode,
                        prefixIcon: Icons.email_rounded,
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFormField(
                        label: 'Phone',
                        hint: '+260 97X XXX XXX',
                        controller: _model.memberPhoneTextController,
                        focusNode: _model.memberPhoneFocusNode,
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Role *',
                            style: theme.bodyMedium?.override(
                              fontFamily: theme.bodyMediumFamily,
                              fontWeight: FontWeight.w500,
                              color: theme.secondaryText,
                              fontSize: 12,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 48,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.alternate,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _model.memberDrafts.isEmpty
                                    ? 'Pharmacist'
                                    : null,
                                hint: Text(
                                  'Select role',
                                  style: theme.bodyMedium?.override(
                                    fontFamily: theme.bodyMediumFamily,
                                    color: theme.secondaryText,
                                    fontSize: 13,
                                    useGoogleFonts:
                                        !theme.bodyMediumIsCustom,
                                  ),
                                ),
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down_rounded,
                                    color: theme.secondaryText),
                                items: _rbacRoles
                                    .map((rbac) => DropdownMenuItem(
                                          value: rbac['role'] as String,
                                          child: Row(
                                            children: [
                                              Icon(
                                                  rbac['icon'] as IconData,
                                                  size: 16,
                                                  color: rbac['color']
                                                      as Color),
                                              const SizedBox(width: 8),
                                              Text(
                                                rbac['role'] as String,
                                                style: theme.bodyMedium
                                                    ?.override(
                                                  fontFamily:
                                                      theme.bodyMediumFamily,
                                                  fontSize: 13,
                                                  useGoogleFonts:
                                                      !theme
                                                          .bodyMediumIsCustom,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  safeSetState(() {
                                    _model.memberDrafts.add(TeamMemberDraft(
                                      role: val ?? 'Pharmacist',
                                    ));
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Outlet assignment (if outlets were added)
                if (_model.outletDrafts.isNotEmpty)
                  _buildOutletAssignmentDropdown(theme),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _addMemberDraft,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Add Member'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(
                          color: Color(0xFF059669), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Member drafts list
          if (_model.memberDrafts.isNotEmpty) ...[
            Text(
              'Team Members',
              style: theme.titleMedium?.override(
                fontFamily: theme.titleMediumFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                useGoogleFonts: !theme.titleMediumIsCustom,
              ),
            ),
            const SizedBox(height: 12),
            ..._model.memberDrafts.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;
              return _buildMemberDraftCard(context, member, index);
            }),
          ],

          if (_model.memberDrafts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: theme.alternate.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.group_outlined,
                      size: 48, color: theme.secondaryText),
                  const SizedBox(height: 12),
                  Text(
                    'No team members added yet',
                    style: theme.bodyMedium?.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You\'ll be assigned as Owner automatically. Add other team members here.',
                    style: theme.bodySmall?.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutletAssignmentDropdown(FlutterFlowTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to Outlet (for Outlet Manager role)',
          style: theme.bodyMedium?.override(
            fontFamily: theme.bodyMediumFamily,
            fontWeight: FontWeight.w500,
            color: theme.secondaryText,
            fontSize: 12,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.alternate, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(
                'Select outlet (optional)',
                style: theme.bodyMedium?.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.secondaryText,
                  fontSize: 13,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_rounded,
                  color: theme.secondaryText),
              items: _model.outletDrafts
                  .map((outlet) => DropdownMenuItem(
                        value: outlet.code,
                        child: Row(
                          children: [
                            const Icon(Icons.store_rounded,
                                size: 16, color: Color(0xFF7C3AED)),
                            const SizedBox(width: 8),
                            Text(
                              '${outlet.name} (${outlet.code})',
                              style: theme.bodyMedium?.override(
                                fontFamily: theme.bodyMediumFamily,
                                fontSize: 13,
                                useGoogleFonts: !theme.bodyMediumIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (val) {
                // Store the selected outlet for the next member being added
                if (val != null) {
                  final outlet = _model.outletDrafts
                      .firstWhere((o) => o.code == val);
                  safeSetState(() {
                    // Will be assigned when member is added
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberDraftCard(
      BuildContext context, TeamMemberDraft member, int index) {
    final theme = FlutterFlowTheme.of(context);
    final rbac = _rbacRoles.firstWhere(
      (r) => r['role'] == member.role,
      orElse: () => _rbacRoles.last,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.alternate.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (rbac['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty
                    ? member.name
                        .trim()
                        .split(RegExp(r'\s+'))
                        .map((p) => p.isNotEmpty ? p[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : '?',
                style: theme.bodyMedium?.override(
                  fontFamily: theme.bodyMediumFamily,
                  fontWeight: FontWeight.w700,
                  color: rbac['color'] as Color,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name.isNotEmpty ? member.name : 'Unnamed Member',
                  style: theme.bodyMedium?.override(
                    fontFamily: theme.bodyMediumFamily,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (member.email.isNotEmpty) ...[
                      Icon(Icons.email_rounded,
                          size: 11, color: theme.secondaryText),
                      const SizedBox(width: 3),
                      Text(
                        member.email,
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontSize: 11,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (member.assignedOutletName != null) ...[
                      Icon(Icons.store_rounded,
                          size: 11, color: const Color(0xFF7C3AED)),
                      const SizedBox(width: 3),
                      Text(
                        member.assignedOutletName!,
                        style: theme.bodySmall?.override(
                          fontFamily: theme.bodySmallFamily,
                          color: const Color(0xFF7C3AED),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (rbac['bgColor'] as Color).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (rbac['color'] as Color).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(rbac['icon'] as IconData,
                    size: 12, color: rbac['color'] as Color),
                const SizedBox(width: 5),
                Text(
                  member.role,
                  style: theme.bodySmall?.override(
                    fontFamily: theme.bodySmallFamily,
                    color: rbac['color'] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                safeSetState(() {
                  _model.memberDrafts.removeAt(index);
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: Color(0xFFDC2626)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SHARED FORM FIELD BUILDER ───────────────────────────────────────────

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required IconData prefixIcon,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: theme.bodyMedium?.override(
              fontFamily: theme.bodyMediumFamily,
              fontWeight: FontWeight.w500,
              color: theme.secondaryText,
              fontSize: 12,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: theme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: theme.bodyMedium?.override(
            fontFamily: theme.bodyMediumFamily,
            fontSize: 14,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodyMediumIsCustom,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.bodySmall?.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText.withValues(alpha: 0.6),
              fontSize: 13,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
            filled: true,
            fillColor: theme.primaryBackground,
            prefixIcon: Icon(prefixIcon, size: 18, color: theme.secondaryText),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.alternate, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.alternate, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: const Color(0xFF9900FF), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.error, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // ─── ACTIONS ─────────────────────────────────────────────────────────────

  void _addOutletDraft() {
    final name = _model.outletNameTextController?.text.trim() ?? '';
    final code = _model.outletCodeTextController?.text.trim() ?? '';
    final address = _model.outletAddressTextController?.text.trim() ?? '';

    if (name.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outlet name and code are required'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    safeSetState(() {
      _model.outletDrafts.add(OutletDraft(
        name: name,
        code: code,
        address: address,
      ));
      _model.outletNameTextController?.clear();
      _model.outletCodeTextController?.clear();
      _model.outletAddressTextController?.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Outlet "$name" added'),
        backgroundColor: const Color(0xFF7C3AED),
      ),
    );
  }

  void _addMemberDraft() {
    final name = _model.memberNameTextController?.text.trim() ?? '';
    final email = _model.memberEmailTextController?.text.trim() ?? '';
    final phone = _model.memberPhoneTextController?.text.trim() ?? '';

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member name and email are required'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Find the last selected role from the dropdown, default to Pharmacist
    final role = _model.memberDrafts.isNotEmpty
        ? _model.memberDrafts.last.role
        : 'Pharmacist';

    safeSetState(() {
      _model.memberDrafts.add(TeamMemberDraft(
        name: name,
        email: email,
        phone: phone,
        role: role,
      ));
      _model.memberNameTextController?.clear();
      _model.memberEmailTextController?.clear();
      _model.memberPhoneTextController?.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added as $role'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  Future<void> _savePharmacy() async {
    final name = _model.pharmacyNameTextController?.text.trim() ?? '';
    final address = _model.addressTextController?.text.trim() ?? '';

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pharmacy name and address are required'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    if (currentUserReference == null) return;

    safeSetState(() {
      _model.isSaving = true;
    });

    try {
      // 1. Create the pharmacy document
      final pharmacyRef = await PharmacyRecord.createDoc(
        currentUserReference!,
      ).set(createPharmacyRecordData(
        name: name,
        address: address,
        userID: currentUserReference,
        deleted: false,
      ));

      final pharmacyDocRef = PharmacyRecord.createDoc(currentUserReference!);

      // 2. Create outlets under the pharmacy
      for (final outlet in _model.outletDrafts) {
        await OutletRecord.createDoc(currentUserReference!).set(
          createOutletRecordData(
            name: outlet.name,
            code: outlet.code,
            address: outlet.address.isNotEmpty ? outlet.address : null,
            isActive: true,
            createdAt: getCurrentTimestamp,
            updatedAt: getCurrentTimestamp,
          ),
        );
      }

      // 3. Create PharmacyUser records for each team member with RBAC
      for (final member in _model.memberDrafts) {
        await PharmacyUserRecord.createDoc(currentUserReference!).set(
          createPharmacyUserRecordData(
            userId: null, // Will be linked when they register
            pharmacyId: pharmacyDocRef,
            outletIds: member.assignedOutletId != null
                ? [member.assignedOutletId!]
                : [],
            role: member.role,
            createdAt: getCurrentTimestamp,
          ),
        );

        // Also create a StaffRecord for the member
        await FirebaseFirestore.instance.collection('Staff').add({
          'OwnerRef': currentUserReference,
          'Name': member.name,
          'Role': member.role,
          'Email': member.email,
          'Phone': member.phone,
          'UserRef': null, // Will be linked when they register
          'PharmId': pharmacyDocRef,
          'deleted': false,
        });
      }

      // 4. Send email notifications
      _sendPharmacyCreatedEmail(
        pharmacyName: name,
        pharmacyAddress: address,
        outletCount: _model.outletDrafts.length,
        memberCount: _model.memberDrafts.length,
      );

      // 5. Send team invitation emails
      for (final member in _model.memberDrafts) {
        if (member.email.isNotEmpty) {
          _sendTeamInviteEmail(
            recipientName: member.name,
            recipientEmail: member.email,
            pharmacyName: name,
            role: member.role,
            outletName: member.assignedOutletName,
          );
        }
      }

      // 6. Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pharmacy "$name" created successfully!'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 3),
          ),
        );

        context.pushNamed(MyPharmaciesWidget.routeName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating pharmacy: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      safeSetState(() {
        _model.isSaving = false;
      });
    }
  }

  // ─── EMAIL NOTIFICATION METHODS ────────────────────────────────────────────

  static const String _emailServiceUrl = 'http://localhost:3001/api/email';

  Future<void> _sendPharmacyCreatedEmail({
    required String pharmacyName,
    required String pharmacyAddress,
    required int outletCount,
    required int memberCount,
  }) async {
    try {
      final userEmail = currentUserEmail ?? '';
      final userName = currentUserDisplayName ?? 'Pharmacy Owner';

      await http.post(
        Uri.parse('$_emailServiceUrl/pharmacy-created'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'ownerName': userName,
          'pharmacyName': pharmacyName,
          'pharmacyAddress': pharmacyAddress,
          'outletCount': outletCount,
          'memberCount': memberCount,
        }),
      );
    } catch (e) {
      debugPrint('Email notification failed (pharmacy-created): $e');
    }
  }

  Future<void> _sendTeamInviteEmail({
    required String recipientName,
    required String recipientEmail,
    required String pharmacyName,
    required String role,
    String? outletName,
  }) async {
    try {
      final invitedBy = currentUserDisplayName ?? 'Pharmacy Admin';

      await http.post(
        Uri.parse('$_emailServiceUrl/team-invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': recipientEmail,
          'recipientName': recipientName,
          'pharmacyName': pharmacyName,
          'role': role,
          'invitedBy': invitedBy,
          'outletName': outletName,
        }),
      );
    } catch (e) {
      debugPrint('Email notification failed (team-invite): $e');
    }
  }

  // ─── MAIN BUILD ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'addstores',
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
                      'Create Pharmacy',
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
                        // Step indicator
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _buildStepIndicator(),
                        ),
                        const SizedBox(height: 12),
                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPharmacyDetailsTab(),
                              _buildOutletsTab(),
                              _buildTeamRolesTab(),
                            ],
                          ),
                        ),
                        // Bottom action bar
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).secondaryBackground,
                            border: Border(
                              top: BorderSide(
                                color: FlutterFlowTheme.of(context)
                                    .alternate
                                    .withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (_tabController.index > 0)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _tabController.animateTo(
                                        _tabController.index - 1);
                                  },
                                  icon: const Icon(Icons.arrow_back_rounded,
                                      size: 16),
                                  label: const Text('Back'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    side: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .alternate,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                  ),
                                ),
                              const Spacer(),
                              if (_tabController.index < 2)
                                FilledButton.icon(
                                  onPressed: () {
                                    _tabController.animateTo(
                                        _tabController.index + 1);
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded,
                                      size: 16),
                                  label: const Text('Continue'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF9900FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                  ),
                                ),
                              if (_tabController.index == 2)
                                FilledButton.icon(
                                  onPressed:
                                      _model.isSaving ? null : _savePharmacy,
                                  icon: _model.isSaving
                                      ? Container(
                                          width: 16,
                                          height: 16,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.check_rounded,
                                          size: 18),
                                  label: Text(
                                      _model.isSaving
                                          ? 'Creating...'
                                          : 'Create Pharmacy'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF9900FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 14),
                                  ),
                                ),
                            ],
                          ),
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
}
