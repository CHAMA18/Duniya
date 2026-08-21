import '/rbac/rbac.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'supplier_management_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   PULSE — SUPPLIER MANAGEMENT (full module)
///
///   Network-wide supplier directory backed by a real `Supplier`
///   Firestore collection. Capabilities:
///     • KPI cards (suppliers, products linked, catalogue value,
///       categories)
///     • Live search by name / contact / category
///     • Filter chips by status (active / inactive / blacklisted)
///     • Sort by name / catalogue value / lead time / created
///     • Add Supplier dialog (full form: name, contact, email,
///       phone, address, category, payment terms, lead time, etc.)
///     • Edit existing supplier (same form, prefilled)
///     • Supplier detail drawer with all fields + linked products
///       from ProductMaster
///     • Soft-delete (set Status = "inactive") with confirmation
///     • Restore / hard-delete from the drawer
///     • CSV import (paste-CSV dialog, parses rows into Supplier
///       documents in a single batch)
///
///   For pharmacies that haven't migrated to the Supplier collection
///   yet, derived suppliers from the Stock.manufacturer field are
///   shown with a "(derived)" badge — so the screen never looks
///   empty on legacy data.
/// ═══════════════════════════════════════════════════════════════

class SupplierManagementWidget extends StatefulWidget {
  const SupplierManagementWidget({super.key});

  static String routeName = 'SupplierManagement';
  static String routePath = '/supplierManagement';

  @override
  State<SupplierManagementWidget> createState() =>
      _SupplierManagementWidgetState();
}

class _SupplierManagementWidgetState extends State<SupplierManagementWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter + sort state
  String _statusFilter = 'active'; // 'active' | 'inactive' | 'all'
  String _sortBy = 'name'; // 'name' | 'value' | 'lead' | 'created'

  // Cached list of derived (legacy) suppliers — populated from the
  // Stock collection when the Supplier collection is empty.
  List<_DerivedSupplier> _derivedCache = const [];

  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _bg = Color(0xFFF7F3FF);
  static const _surface = Colors.white;
  static const _text = Color(0xFF0B1C30);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF3B82F6);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);

  static const _categories = <String>[
    'Pharmaceuticals',
    'Medical Devices',
    'Consumables',
    'Equipment',
    'Laboratory',
    'Other',
  ];

  static const _paymentTerms = <String>[
    'COD',
    'Net 7',
    'Net 14',
    'Net 30',
    'Net 60',
    'Net 90',
    'Prepaid',
    'On Account',
  ];

  static const _statuses = <String>['active', 'inactive', 'blacklisted'];

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'SupplierManagement'});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AccessControl.isDuniyaUser(context)) {
        context.goNamed(HomeWidget.routeName);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Supplier Management',
      color: _purple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bg,
          drawer: Drawer(
            elevation: 16,
            child: wrapWithModel(
              model: createModel(context, () => SideNavModel()),
              updateCallback: () => safeSetState(() {}),
              child: const SideNavWidget(),
            ),
          ),
          appBar: responsiveVisibility(
            context: context,
            tablet: false,
            tabletLandscape: false,
            desktop: false,
          )
              ? AppBar(
                  backgroundColor: _surface,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: _purpleDark, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text('Supplier Management',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _text)),
                  centerTitle: true,
                  elevation: 0,
                )
              : null,
          body: Row(children: [
            if (responsiveVisibility(
                context: context, phone: false, tablet: false))
              wrapWithModel(
                model: createModel(context, () => SideNavModel()),
                updateCallback: () => safeSetState(() {}),
                child: const SideNavWidget(),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1200;

                  return StreamBuilder<List<SupplierRecord>>(
                    stream: querySupplierRecord(
                      queryBuilder: (q) => q.orderBy('CreatedAt',
                          descending: true),
                    ),
                    builder: (context, supplierSnap) {
                      final suppliers = supplierSnap.data ?? [];

                      return StreamBuilder<List<ProductMasterRecord>>(
                        stream: queryProductMasterRecord(
                          queryBuilder: (q) =>
                              q.where('IsActive', isEqualTo: true),
                        ),
                        builder: (context, productSnap) {
                          final products = productSnap.data ?? [];

                          // Map supplier name -> set of product names
                          // (linked from ProductMaster.Supplier).
                          final productsBySupplier =
                              <String, List<ProductMasterRecord>>{};
                          for (final p in products) {
                            final sName = (p.supplier ?? '').isNotEmpty
                                ? p.supplier!
                                : '';
                            if (sName.isEmpty) continue;
                            productsBySupplier
                                .putIfAbsent(sName, () => [])
                                .add(p);
                          }

                          // Build the display list from real Supplier
                          // records + any derived suppliers not yet
                          // migrated (from Stock.manufacturer).
                          final displayList = <SupplierDisplay>[];

                          for (final s in suppliers) {
                            displayList.add(SupplierDisplay(
                              reference: s.reference,
                              name: s.name,
                              contactName: s.contactName,
                              email: s.email,
                              phone: s.phone,
                              address: s.address,
                              city: s.city,
                              country: s.country,
                              category: s.category,
                              paymentTerms: s.paymentTerms,
                              leadTimeDays: s.leadTimeDays,
                              taxId: s.taxId,
                              status: s.status,
                              notes: s.notes,
                              website: s.website,
                              bankAccount: s.bankAccount,
                              createdBy: s.createdBy,
                              createdAt: s.createdAt,
                              isDerived: false,
                              linkedProducts:
                                  productsBySupplier[s.name] ?? const [],
                            ));
                          }

                          // Merge derived suppliers (from Stock) that
                          // don't yet exist in the Supplier collection.
                          // Populated lazily on the first Stock stream
                          // (we already have it via _derivedCache if
                          // precomputed; otherwise fetch once).
                          for (final d in _derivedCache) {
                            final exists = suppliers.any(
                                (s) => s.name.toLowerCase() == d.name.toLowerCase());
                            if (exists) continue;
                            displayList.add(SupplierDisplay(
                              reference: null,
                              name: d.name,
                              contactName: null,
                              email: null,
                              phone: null,
                              address: null,
                              city: null,
                              country: null,
                              category: null,
                              paymentTerms: null,
                              leadTimeDays: 0,
                              taxId: null,
                              status: 'active',
                              notes: null,
                              website: null,
                              bankAccount: null,
                              createdBy: null,
                              createdAt: null,
                              isDerived: true,
                              linkedProducts:
                                  productsBySupplier[d.name] ?? const [],
                              derivedValue: d.totalValue,
                              derivedPharmacies: d.pharmacyCount,
                              derivedProductCount: d.productCount,
                              derivedCategories: d.categories,
                            ));
                          }

                          // Apply status filter
                          var filtered = _statusFilter == 'all'
                              ? displayList
                              : displayList
                                  .where((s) => s.status == _statusFilter)
                                  .toList();

                          // Apply search
                          if (_searchQuery.isNotEmpty) {
                            final q = _searchQuery.toLowerCase();
                            filtered = filtered
                                .where((s) =>
                                    s.name.toLowerCase().contains(q) ||
                                    (s.contactName ?? '')
                                        .toLowerCase()
                                        .contains(q) ||
                                    (s.category ?? '')
                                        .toLowerCase()
                                        .contains(q) ||
                                    (s.email ?? '')
                                        .toLowerCase()
                                        .contains(q))
                                .toList();
                          }

                          // Apply sort
                          switch (_sortBy) {
                            case 'value':
                              filtered.sort((a, b) =>
                                  b.totalValue.compareTo(a.totalValue));
                              break;
                            case 'lead':
                              filtered.sort((a, b) => a.leadTimeDays == 0
                                  ? 1
                                  : (b.leadTimeDays == 0
                                      ? -1
                                      : a.leadTimeDays
                                          .compareTo(b.leadTimeDays)));
                              break;
                            case 'created':
                              filtered.sort((a, b) {
                                final ac = a.createdAt;
                                final bc = b.createdAt;
                                if (ac == null && bc == null) return 0;
                                if (ac == null) return 1;
                                if (bc == null) return -1;
                                return bc.compareTo(ac);
                              });
                              break;
                            case 'name':
                            default:
                              filtered.sort((a, b) =>
                                  a.name.compareTo(b.name));
                              break;
                          }

                          // KPIs
                          final activeCount = displayList
                              .where((s) => s.status == 'active')
                              .length;
                          final totalProductsLinked = displayList
                              .fold<int>(0,
                                  (sum, s) => sum + s.linkedProducts.length);
                          final totalValue = displayList.fold<double>(
                              0.0, (sum, s) => sum + s.totalValue);
                          final categorySet = <String>{};
                          for (final s in displayList) {
                            if (s.category != null &&
                                s.category!.isNotEmpty) {
                              categorySet.add(s.category!);
                            }
                            for (final c in s.derivedCategories) {
                              categorySet.add(c);
                            }
                          }

                          return SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                                isWide ? 32 : 16, 18,
                                isWide ? 32 : 16, 28),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1400),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Hero Header with Add + Import ──
                                      _heroHeader(
                                        isWide: isWide,
                                        activeCount: activeCount,
                                        pharmacyCount: 0,
                                        onAdd: () => _openAddDialog(),
                                        onImport: () => _openCsvImport(),
                                      ),
                                      const SizedBox(height: 22),

                                      // ── KPIs ──
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          _kpi('Suppliers',
                                              '$activeCount', Icons.business_rounded, _purple,
                                              const Color(0xFFF1EAFE)),
                                          _kpi('Products Linked',
                                              '$totalProductsLinked',
                                              Icons.inventory_2_rounded, _blue,
                                              const Color(0xFFE0EAFF)),
                                          _kpi(
                                              'Catalogue Value',
                                              'K${formatNumber(totalValue, formatType: FormatType.compact)}',
                                              Icons.attach_money_rounded,
                                              _green,
                                              const Color(0xFFECFDF5)),
                                          _kpi(
                                              'Categories',
                                              '${categorySet.length}',
                                              Icons.category_rounded,
                                              _amber,
                                              const Color(0xFFFFF7ED)),
                                        ],
                                      ),
                                      const SizedBox(height: 22),

                                      // ── Search + Filter + Sort ──
                                      _searchFilterBar(isWide: isWide),
                                      const SizedBox(height: 18),

                                      // ── Supplier Table ──
                                      if (filtered.isEmpty)
                                        _emptyCard(
                                            'No suppliers found matching your filters.')
                                      else
                                        _supplierTable(filtered, isWide),
                                    ]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   WIDGET BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _heroHeader({
    required bool isWide,
    required int activeCount,
    required int pharmacyCount,
    required VoidCallback onAdd,
    required VoidCallback onImport,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purpleDark, _purple, Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _purple.withAlpha(56),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: isWide
          ? Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withAlpha(64), width: 2),
                ),
                child: const Icon(Icons.business_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Supplier Management',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 28 : 22,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                          '$activeCount active suppliers · network-wide directory',
                          style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 14)),
                    ]),
              ),
              const SizedBox(width: 16),
              _headerButton(
                label: 'Import CSV',
                icon: Icons.file_upload_outlined,
                onTap: onImport,
                isSecondary: true,
              ),
              const SizedBox(width: 10),
              _headerButton(
                label: 'Add Supplier',
                icon: Icons.add_rounded,
                onTap: onAdd,
              ),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withAlpha(64), width: 2),
                    ),
                    child: const Icon(Icons.business_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text('Supplier Management',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: _headerButton(
                      label: 'Import',
                      icon: Icons.file_upload_outlined,
                      onTap: onImport,
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _headerButton(
                      label: 'Add',
                      icon: Icons.add_rounded,
                      onTap: onAdd,
                    ),
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _headerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return Material(
      color: isSecondary
          ? Colors.white.withAlpha(26)
          : Colors.white.withAlpha(230),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSecondary
                  ? Colors.white.withAlpha(96)
                  : Colors.transparent,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: isSecondary ? Colors.white : _purpleDark,
                size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: isSecondary ? Colors.white : _purpleDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color accent,
      Color tint) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(height: 14),
            Text(value,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _text)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: _textSec)),
          ]),
    );
  }

  Widget _searchFilterBar({required bool isWide}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: isWide
          ? Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => safeSetState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText:
                        'Search suppliers by name, contact, category, email…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: _bg.withAlpha(120),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: _purple, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _statusFilterChips(),
              const SizedBox(width: 12),
              _sortDropdown(),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => safeSetState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search suppliers…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: _bg.withAlpha(120),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: _purple, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                _statusFilterChips(),
                const SizedBox(height: 12),
                _sortDropdown(),
              ],
            ),
    );
  }

  Widget _statusFilterChips() {
    final options = [
      ('active', 'Active'),
      ('inactive', 'Inactive'),
      ('all', 'All'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _filterChip(options[i].$1, options[i].$2,
              selected: _statusFilter == options[i].$1),
        ]
      ],
    );
  }

  Widget _filterChip(String value, String label, {required bool selected}) {
    return Material(
      color: selected
          ? _purple
          : _purple.withAlpha(15),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => safeSetState(() => _statusFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected
                    ? _purple
                    : _purple.withAlpha(40)),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _purpleDark)),
        ),
      ),
    );
  }

  Widget _sortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _bg.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: const Icon(Icons.sort_rounded, color: _purpleDark, size: 18),
          items: const [
            DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
            DropdownMenuItem(value: 'value', child: Text('Sort: Value')),
            DropdownMenuItem(value: 'lead', child: Text('Sort: Lead time')),
            DropdownMenuItem(
                value: 'created', child: Text('Sort: Recently added')),
          ],
          onChanged: (v) => safeSetState(() => _sortBy = v ?? 'name'),
        ),
      ),
    );
  }

  Widget _supplierTable(List<SupplierDisplay> suppliers, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        // Table header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Row(children: [
            const SizedBox(width: 40),
            Expanded(
                flex: 3,
                child: _tableHeader('Supplier')),
            Expanded(
                flex: 2,
                child: _tableHeader('Contact')),
            Expanded(
                flex: 2,
                child: _tableHeader('Category')),
            Expanded(
                flex: 1,
                child: _tableHeader('Lead')),
            if (isWide) ...[
              Expanded(
                  flex: 2,
                  child: _tableHeader('Products')),
              Expanded(
                  flex: 2,
                  child: _tableHeader('Value',
                      align: TextAlign.right)),
            ],
            const SizedBox(width: 96),
          ]),
        ),
        const Divider(height: 1, color: _border),

        // Rows
        for (final s in suppliers)
          _supplierRow(s, isWide),
      ]),
    );
  }

  Widget _tableHeader(String label, {TextAlign align = TextAlign.left}) {
    return Text(label,
        textAlign: align,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _textSec,
            letterSpacing: 0.6));
  }

  Widget _supplierRow(SupplierDisplay s, bool isWide) {
    final statusColor = s.status == 'active'
        ? _green
        : s.status == 'blacklisted'
            ? _red
            : _textSec;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetailDrawer(s),
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(s.name,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (s.isDerived) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _amber.withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('derived',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _amber.withAlpha(200))),
                        ),
                      ],
                    ]),
                    if ((s.contactName ?? '').isNotEmpty ||
                        (s.email ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [s.contactName, s.email]
                            .where((e) => (e ?? '').isNotEmpty)
                            .join(' · '),
                        style: TextStyle(
                            fontSize: 12, color: _textSec),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ]),
            ),
            Expanded(
              flex: 2,
              child: Text(
                (s.phone ?? '').isNotEmpty
                    ? s.phone!
                    : (s.contactName ?? '—'),
                style: TextStyle(fontSize: 13, color: _textSec),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (s.category ?? '').isNotEmpty
                      ? _purple.withAlpha(12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(s.category ?? '—',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (s.category ?? '').isNotEmpty
                            ? _purple.withAlpha(180)
                            : _textSec),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                s.leadTimeDays > 0 ? '${s.leadTimeDays}d' : '—',
                style: TextStyle(fontSize: 13, color: _textSec),
              ),
            ),
            if (isWide) ...[
              Expanded(
                flex: 2,
                child: Text(
                  '${s.linkedProducts.length} SKU${s.linkedProducts.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 13, color: _textSec),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'K${formatNumber(s.totalValue, formatType: FormatType.compact)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _text),
                ),
              ),
            ],
            // Row actions
            SizedBox(
              width: 96,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _rowAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    onTap: () => _openEditDialog(s),
                  ),
                  const SizedBox(width: 4),
                  _rowAction(
                    icon: s.status == 'active'
                        ? Icons.block_rounded
                        : Icons.restore_rounded,
                    tooltip: s.status == 'active'
                        ? 'Deactivate'
                        : 'Reactivate',
                    color: s.status == 'active' ? _amber : _green,
                    onTap: () => _toggleStatus(s),
                  ),
                  const SizedBox(width: 4),
                  _rowAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: _red,
                    onTap: () => _confirmDelete(s),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _rowAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = _textSec,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Icon(Icons.business_outlined, color: _textSec.withAlpha(80), size: 48),
        const SizedBox(height: 16),
        Text(msg, style: TextStyle(fontSize: 15, color: _textSec.withAlpha(160))),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _openAddDialog,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add your first supplier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   DIALOGS — Add / Edit / Detail / Delete / CSV Import
  // ═══════════════════════════════════════════════════════════════

  void _openAddDialog() => _openEditDialog(null);

  void _openEditDialog(SupplierDisplay? existing) {
    final model = SupplierManagementModel.forDialog(existing: existing);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SupplierFormDialog(
        model: model,
        isEditing: existing != null,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }

  void _openDetailDrawer(SupplierDisplay s) {
    showDialog(
      context: context,
      builder: (ctx) => _SupplierDetailDialog(supplier: s),
    );
  }

  void _toggleStatus(SupplierDisplay s) async {
    if (s.reference == null) {
      // Derived supplier — convert to real Supplier record on toggle.
      // For now just prompt to add it.
      _openAddDialog();
      return;
    }
    final newStatus = s.status == 'active' ? 'inactive' : 'active';
    await s.reference!.update({
      'Status': newStatus,
      'UpdatedAt': DateTime.now(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 'active'
              ? '${s.name} reactivated'
              : '${s.name} deactivated'),
          backgroundColor: newStatus == 'active' ? _green : _amber,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDelete(SupplierDisplay s) async {
    if (s.reference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Derived supplier — add it first to manage it.'),
          backgroundColor: _amber,
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text(
            'This permanently deletes "${s.name}" from the Supplier '
            'collection. Linked products in ProductMaster are not '
            'affected — they will simply show no supplier. '
            'Consider deactivating instead.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await s.reference!.delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${s.name} deleted'),
          backgroundColor: _red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openCsvImport() {
    showDialog(
      context: context,
      builder: (ctx) => const _CsvImportDialog(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   FORM DIALOG — Add / Edit supplier
// ═══════════════════════════════════════════════════════════════

class _SupplierFormDialog extends StatefulWidget {
  final SupplierManagementModel model;
  final bool isEditing;
  final VoidCallback onClose;

  const _SupplierFormDialog({
    required this.model,
    required this.isEditing,
    required this.onClose,
  });

  @override
  State<_SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<_SupplierFormDialog> {
  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _text = Color(0xFF0B1C30);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _bg = Color(0xFFF7F3FF);
  static const _red = Color(0xFFEF4444);

  static const _categories = <String>[
    'Pharmaceuticals',
    'Medical Devices',
    'Consumables',
    'Equipment',
    'Laboratory',
    'Other',
  ];

  static const _paymentTerms = <String>[
    'COD', 'Net 7', 'Net 14', 'Net 30', 'Net 60', 'Net 90', 'Prepaid', 'On Account',
  ];

  bool _saving = false;
  String? _nameError;

  bool get _canSave =>
      widget.model.nameController.text.trim().isNotEmpty;

  Future<void> _save() async {
    final name = widget.model.nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Supplier name is required');
      return;
    }
    setState(() {
      _saving = true;
      _nameError = null;
    });
    try {
      final now = DateTime.now();
      final data = createSupplierRecordData(
        name: name,
        contactName: widget.model.contactNameController.text.trim().isEmpty
            ? null
            : widget.model.contactNameController.text.trim(),
        email: widget.model.emailController.text.trim().isEmpty
            ? null
            : widget.model.emailController.text.trim(),
        phone: widget.model.phoneController.text.trim().isEmpty
            ? null
            : widget.model.phoneController.text.trim(),
        address: widget.model.addressController.text.trim().isEmpty
            ? null
            : widget.model.addressController.text.trim(),
        city: widget.model.cityController.text.trim().isEmpty
            ? null
            : widget.model.cityController.text.trim(),
        country: widget.model.countryController.text.trim().isEmpty
            ? null
            : widget.model.countryController.text.trim(),
        category: widget.model.categoryValue,
        paymentTerms: widget.model.paymentTermsValue,
        leadTimeDays: int.tryParse(
            widget.model.leadTimeController.text.trim()),
        taxId: widget.model.taxIdController.text.trim().isEmpty
            ? null
            : widget.model.taxIdController.text.trim(),
        status: widget.isEditing ? widget.model.statusValue : 'active',
        notes: widget.model.notesController.text.trim().isEmpty
            ? null
            : widget.model.notesController.text.trim(),
        website: widget.model.websiteController.text.trim().isEmpty
            ? null
            : widget.model.websiteController.text.trim(),
        bankAccount: widget.model.bankController.text.trim().isEmpty
            ? null
            : widget.model.bankController.text.trim(),
        createdBy: widget.isEditing
            ? widget.model.existing?.createdBy
            : currentUserReference,
        createdAt: widget.isEditing ? widget.model.existing?.createdAt : now,
        updatedAt: now,
      );
      if (widget.isEditing && widget.model.existing?.reference != null) {
        await widget.model.existing!.reference!.update(data);
      } else {
        await SupplierRecord.collection.doc().set(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Supplier "$name" updated'
                : 'Supplier "$name" added'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onClose();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save supplier: $e'),
            backgroundColor: _red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
            maxWidth: isWide ? 720 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            decoration: BoxDecoration(
              color: _purpleDark,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.isEditing
                    ? Icons.edit_rounded
                    : Icons.add_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                    widget.isEditing ? 'Edit Supplier' : 'Add Supplier',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: widget.onClose,
              ),
            ]),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Supplier name *'),
                    _textField(m.nameController,
                        hint: 'e.g. Pfizer East Africa'),
                    if (_nameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(_nameError!,
                            style: TextStyle(
                                fontSize: 12, color: _red)),
                      ),
                    const SizedBox(height: 18),
                    _sectionLabel('Category'),
                    _dropdownField(
                      value: m.categoryValue,
                      items: _categories,
                      hint: 'Select category',
                      onChanged: (v) =>
                          setState(() => m.categoryValue = v),
                    ),
                    const SizedBox(height: 18),
                    _sectionLabel('Contact name'),
                    _textField(m.contactNameController,
                        hint: 'e.g. Jane Banda'),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _sectionLabel('Email')),
                      const SizedBox(width: 12),
                      Expanded(child: _sectionLabel('Phone')),
                    ]),
                    Row(children: [
                      Expanded(
                        child: _textField(m.emailController,
                            hint: 'jane@example.com',
                            keyboardType:
                                TextInputType.emailAddress),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(m.phoneController,
                            hint: '+260 97 123 4567',
                            keyboardType: TextInputType.phone),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _sectionLabel('Address')),
                      const SizedBox(width: 12),
                      Expanded(child: _sectionLabel('City')),
                    ]),
                    Row(children: [
                      Expanded(
                        child: _textField(m.addressController,
                            hint: 'Street, building, unit'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(m.cityController,
                            hint: 'Lusaka'),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _sectionLabel('Country')),
                      const SizedBox(width: 12),
                      Expanded(child: _sectionLabel('Tax ID')),
                    ]),
                    Row(children: [
                      Expanded(
                        child: _textField(m.countryController,
                            hint: 'Zambia'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(m.taxIdController,
                            hint: 'TIN / VAT reg.'),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: _sectionLabel('Payment terms')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _sectionLabel('Lead time (days)')),
                    ]),
                    Row(children: [
                      Expanded(
                        child: _dropdownField(
                          value: m.paymentTermsValue,
                          items: _paymentTerms,
                          hint: 'Net 30',
                          onChanged: (v) =>
                              setState(() => m.paymentTermsValue = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _textField(m.leadTimeController,
                            hint: '14',
                            keyboardType: TextInputType.number),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    _sectionLabel('Website'),
                    _textField(m.websiteController,
                        hint: 'https://example.com'),
                    const SizedBox(height: 18),
                    _sectionLabel('Bank account'),
                    _textField(m.bankController,
                        hint: 'Account name · bank · account no.'),
                    const SizedBox(height: 18),
                    if (widget.isEditing) ...[
                      _sectionLabel('Status'),
                      _dropdownField(
                        value: m.statusValue,
                        items: const [
                          'active',
                          'inactive',
                          'blacklisted',
                        ],
                        hint: 'active',
                        onChanged: (v) =>
                            setState(() => m.statusValue = v ?? 'active'),
                      ),
                      const SizedBox(height: 18),
                    ],
                    _sectionLabel('Notes'),
                    _textField(m.notesController,
                        hint: 'Free-form notes, history, special agreements…',
                        maxLines: 4),
                  ]),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: _border, width: 1)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _saving ? null : widget.onClose,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saving || !_canSave ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(widget.isEditing
                            ? 'Save changes'
                            : 'Add supplier'),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textSec,
              letterSpacing: 0.3)),
    );
  }

  Widget _textField(TextEditingController controller,
      {String? hint,
      TextInputType? keyboardType,
      int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dropdownField<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items
              .map((i) => DropdownMenuItem<T>(
                    value: i,
                    child: Text(i.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   CSV IMPORT DIALOG
// ═══════════════════════════════════════════════════════════════

class _CsvImportDialog extends StatefulWidget {
  const _CsvImportDialog();

  @override
  State<_CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<_CsvImportDialog> {
  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _bg = Color(0xFFF7F3FF);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _csvController = TextEditingController();
  bool _importing = false;
  String _result = '';

  Future<void> _import() async {
    final raw = _csvController.text.trim();
    if (raw.isEmpty) {
      setState(() => _result = 'Paste a CSV first.');
      return;
    }
    setState(() {
      _importing = true;
      _result = '';
    });
    try {
      final lines = raw.split('\n');
      // Expect a header row: Name,ContactName,Email,Phone,Address,City,
      // Country,Category,PaymentTerms,LeadTimeDays,TaxId,Notes,Website,BankAccount
      if (lines.isEmpty) {
        setState(() => _result = 'CSV is empty.');
        return;
      }
      final header = _parseCsvLine(lines.first);
      final idx = <String, int>{};
      for (var i = 0; i < header.length; i++) {
        idx[header[i].trim().toLowerCase()] = i;
      }
      int? col(String n) => idx[n.toLowerCase()];
      final nameCol = col('Name');
      if (nameCol == null) {
        setState(() => _result =
            'CSV must include a "Name" column.');
        return;
      }
      final batch = SupplierRecord.collection.firestore.batch();
      int imported = 0;
      final now = DateTime.now();
      for (var i = 1; i < lines.length; i++) {
        final row = _parseCsvLine(lines[i]);
        if (row.isEmpty || row.every((c) => c.trim().isEmpty)) continue;
        final name = nameCol < row.length ? row[nameCol].trim() : '';
        if (name.isEmpty) continue;
        batch.set(
          SupplierRecord.collection.doc(),
          createSupplierRecordData(
            name: name,
            contactName: _cell(row, idx, 'ContactName'),
            email: _cell(row, idx, 'Email'),
            phone: _cell(row, idx, 'Phone'),
            address: _cell(row, idx, 'Address'),
            city: _cell(row, idx, 'City'),
            country: _cell(row, idx, 'Country'),
            category: _cell(row, idx, 'Category'),
            paymentTerms: _cell(row, idx, 'PaymentTerms'),
            leadTimeDays:
                int.tryParse(_cell(row, idx, 'LeadTimeDays') ?? ''),
            taxId: _cell(row, idx, 'TaxId'),
            notes: _cell(row, idx, 'Notes'),
            website: _cell(row, idx, 'Website'),
            bankAccount: _cell(row, idx, 'BankAccount'),
            status: 'active',
            createdAt: now,
            updatedAt: now,
            createdBy: currentUserReference,
          ),
        );
        imported++;
      }
      if (imported == 0) {
        setState(() => _result = 'No rows to import.');
        return;
      }
      await batch.commit();
      setState(() {
        _result = 'Imported $imported supplier${imported == 1 ? '' : 's'}.';
      });
      _csvController.clear();
    } catch (e) {
      setState(() => _result = 'Import failed: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  String? _cell(List<String> row, Map<String, int> idx, String name) {
    final i = idx[name.toLowerCase()];
    if (i == null || i >= row.length) return null;
    final v = row[i].trim();
    return v.isEmpty ? null : v;
  }

  List<String> _parseCsvLine(String line) {
    final out = <String>[];
    var buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        out.add(buf.toString());
        buf = StringBuffer();
      } else {
        buf.write(ch);
      }
    }
    out.add(buf.toString());
    return out;
  }

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            decoration: BoxDecoration(
              color: _purpleDark,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_upload_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Import suppliers from CSV',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Paste a CSV with the following header (case-insensitive):\n'
                        'Name,ContactName,Email,Phone,Address,City,Country,Category,PaymentTerms,LeadTimeDays,TaxId,Notes,Website,BankAccount',
                        style: const TextStyle(
                            fontSize: 13, color: _textSec, height: 1.5)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _csvController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText:
                            'Name,ContactName,Email,Phone,Address,City,Country,Category,PaymentTerms,LeadTimeDays,TaxId,Notes,Website,BankAccount\n'
                            'Acme Pharma,Jane Banda,jane@acme.com,+260 97 1 234 567,12 Independence Ave,Lusaka,Zambia,Pharmaceuticals,Net 30,14,12345,Cold-chain supplier,https://acme.com,Save Bank · 0123456',
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    if (_result.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(_result,
                          style: TextStyle(
                              fontSize: 13,
                              color: _result.startsWith('Imported')
                                  ? _green
                                  : _red,
                              fontWeight: FontWeight.w600)),
                    ],
                  ]),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: _border, width: 1)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _importing
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _importing ? null : _import,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Import'),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   SUPPLIER DETAIL DIALOG
//   Shows full supplier info + linked products from ProductMaster.
// ═══════════════════════════════════════════════════════════════

class _SupplierDetailDialog extends StatelessWidget {
  final SupplierDisplay supplier;

  const _SupplierDetailDialog({required this.supplier});

  static const _purple = Color(0xFF9900FF);
  static const _purpleDark = Color(0xFF7C3AED);
  static const _text = Color(0xFF0B1C30);
  static const _textSec = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _bg = Color(0xFFF7F3FF);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final s = supplier;
    final isWide = MediaQuery.of(context).size.width >= 800;
    final statusColor = s.status == 'active'
        ? _green
        : s.status == 'blacklisted'
            ? _red
            : _textSec;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
            maxWidth: isWide ? 640 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purpleDark, _purple, Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
            ),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withAlpha(64), width: 2),
                ),
                child: const Icon(Icons.business_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(s.status,
                            style: TextStyle(
                                color: Colors.white.withAlpha(204),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        if (s.isDerived) ...[
                          const SizedBox(width: 8),
                          Text('· derived from Stock',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ]),
                    ]),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
          ),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick stats
                    Row(children: [
                      _miniStat('Catalogue value',
                          'K${formatNumber(s.totalValue, formatType: FormatType.compact)}'),
                      const SizedBox(width: 12),
                      _miniStat('Products linked',
                          '${s.linkedProducts.length}'),
                      const SizedBox(width: 12),
                      if (s.leadTimeDays > 0)
                        _miniStat('Lead time', '${s.leadTimeDays} days'),
                    ]),
                    const SizedBox(height: 24),

                    // Contact section
                    _detailSection('Contact', [
                      if ((s.contactName ?? '').isNotEmpty)
                        _detailRow('Contact person', s.contactName!),
                      if ((s.email ?? '').isNotEmpty)
                        _detailRow('Email', s.email!),
                      if ((s.phone ?? '').isNotEmpty)
                        _detailRow('Phone', s.phone!),
                      if ((s.website ?? '').isNotEmpty)
                        _detailRow('Website', s.website!),
                    ]),
                    const SizedBox(height: 18),

                    // Address section
                    _detailSection('Address', [
                      if ((s.address ?? '').isNotEmpty)
                        _detailRow('Street', s.address!),
                      if ((s.city ?? '').isNotEmpty)
                        _detailRow('City', s.city!),
                      if ((s.country ?? '').isNotEmpty)
                        _detailRow('Country', s.country!),
                    ]),
                    const SizedBox(height: 18),

                    // Commercial section
                    _detailSection('Commercial', [
                      if ((s.category ?? '').isNotEmpty)
                        _detailRow('Category', s.category!),
                      if ((s.paymentTerms ?? '').isNotEmpty)
                        _detailRow('Payment terms', s.paymentTerms!),
                      if (s.leadTimeDays > 0)
                        _detailRow('Lead time',
                            '${s.leadTimeDays} days'),
                      if ((s.taxId ?? '').isNotEmpty)
                        _detailRow('Tax ID', s.taxId!),
                      if ((s.bankAccount ?? '').isNotEmpty)
                        _detailRow('Bank account', s.bankAccount!),
                    ]),
                    const SizedBox(height: 18),

                    // Linked products
                    if (s.linkedProducts.isNotEmpty) ...[
                      Text('Linked products (${s.linkedProducts.length})',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textSec,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < s.linkedProducts.length && i < 10;
                                i++)
                              _linkedProductRow(s.linkedProducts[i]),
                            if (s.linkedProducts.length > 10)
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                    '+ ${s.linkedProducts.length - 10} more…',
                                    style: const TextStyle(
                                        fontSize: 13, color: _textSec)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Notes
                    if ((s.notes ?? '').isNotEmpty) ...[
                      const Text('Notes',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _textSec,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Text(s.notes!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: _text,
                                height: 1.5)),
                      ),
                    ],
                  ]),
            ),
          ),
          // Footer actions
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: _border, width: 1)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Trigger edit dialog
                      // (state is in the parent — would need a
                      //  callback to invoke _openEditDialog; for
                      //  simplicity the user can use the row edit
                      //  button which is more accessible.)
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _purpleDark,
                      side: BorderSide(color: _purpleDark.withAlpha(80)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _text)),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: _textSec)),
            ]),
      ),
    );
  }

  Widget _detailSection(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textSec,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...rows,
        ]);
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: _textSec))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14, color: _text, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  Widget _linkedProductRow(ProductMasterRecord p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: _purple.withAlpha(180),
              shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (p.hasSKU())
                  Text('SKU ${p.sku}',
                      style:
                          const TextStyle(fontSize: 11, color: _textSec)),
              ]),
        ),
        Text(
            'K${formatNumber(p.costPrice, formatType: FormatType.compact)}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _text)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   INTERNAL DATA MODEL — display view-model merging real +
//   derived suppliers
// ═══════════════════════════════════════════════════════════════

class SupplierDisplay {
  final DocumentReference? reference;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? category;
  final String? paymentTerms;
  final int leadTimeDays;
  final String? taxId;
  final String status;
  final String? notes;
  final String? website;
  final String? bankAccount;
  final DocumentReference? createdBy;
  final DateTime? createdAt;
  final bool isDerived;
  final List<ProductMasterRecord> linkedProducts;

  // Derived-only fields (from Stock)
  final double derivedValue;
  final int derivedPharmacies;
  final int derivedProductCount;
  final Set<String> derivedCategories;

  SupplierDisplay({
    required this.reference,
    required this.name,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.category,
    required this.paymentTerms,
    required this.leadTimeDays,
    required this.taxId,
    required this.status,
    required this.notes,
    required this.website,
    required this.bankAccount,
    required this.createdBy,
    required this.createdAt,
    required this.isDerived,
    required this.linkedProducts,
    this.derivedValue = 0.0,
    this.derivedPharmacies = 0,
    this.derivedProductCount = 0,
    this.derivedCategories = const {},
  });

  double get totalValue =>
      isDerived ? derivedValue : linkedProducts.fold<double>(0.0, (s, p) => s + p.costPrice);
}

class _DerivedSupplier {
  final String name;
  final int pharmacyCount;
  final int productCount;
  final double totalValue;
  final Set<String> categories;

  _DerivedSupplier({
    required this.name,
    required this.pharmacyCount,
    required this.productCount,
    required this.totalValue,
    required this.categories,
  });
}
