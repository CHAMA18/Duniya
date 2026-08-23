import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'purchase_orders_model.dart';
export 'purchase_orders_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   PULSE — PURCHASE ORDER AUTOMATION (World-Class Design)
///   Stripe-quality billing dashboard UX: hero header, KPI cards,
///   auto-generate panel, smart status filters, PO cards with
///   fulfillment progress, inline actions, and create-PO form.
/// ═══════════════════════════════════════════════════════════════

class PurchaseOrdersWidget extends StatefulWidget {
  const PurchaseOrdersWidget({super.key});

  static String routeName = 'PurchaseOrders';
  static String routePath = '/purchase-orders';

  @override
  State<PurchaseOrdersWidget> createState() => _PurchaseOrdersWidgetState();
}

class _PurchaseOrdersWidgetState extends State<PurchaseOrdersWidget>
    with TickerProviderStateMixin {
  late PurchaseOrdersModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── STATUS FILTER ──
  String _statusFilter = 'All';
  final List<String> _statusTabs = [
    'All',
    'Draft',
    'Pending Approval',
    'Approved',
    'Ordered',
    'Delivered',
  ];

  // ── AUTO-GENERATE PANEL STATE ──
  bool _isScanning = false;
  bool _showAutoPanel = false;
  List<_ReorderItem> _reorderItems = [];

  // ── CREATE PO MODAL ──
  int? _editingIndex;
  String? _selectedSupplier;
  List<_PoLineItem> _lineItems = [];

  /// Real dropdown options, loaded from Firestore in [_loadCatalogOptions]
  /// — replaces the previous hardcoded demo suppliers/products.
  List<String> _supplierOptions = [];
  List<String> _productOptions = [];

  /// Loads real supplier names and in-stock product names for the
  /// Create-PO dropdowns. Falls back silently to empty lists (the
  /// form still allows manual use) when queries fail.
  Future<void> _loadCatalogOptions() async {
    try {
      final stocks = await queryStockRecordOnce(
        parent: AccessControl.isPulseUser(context)
            ? null
            : AccessControl.parentRef(context) ?? currentUserReference,
      );
      final supplierNames = <String>{};
      try {
        final suppliers = await querySupplierRecordOnce();
        for (final s in suppliers) {
          final n = s.name.trim();
          if (n.isNotEmpty) supplierNames.add(n);
        }
      } catch (_) {
        // Supplier collection unavailable — product-master suppliers
        // are still added below.
      }
      try {
        final products = await queryProductMasterRecordOnce();
        for (final p in products) {
          final n = (p.supplier ?? '').trim();
          if (n.isNotEmpty) supplierNames.add(n);
        }
      } catch (_) {
        // Ignore — stock-derived suppliers still populate.
      }
      final productNames = <String>{};
      for (final s in stocks) {
        final n = s.name.trim();
        if (n.isNotEmpty) productNames.add(n);
      }
      if (!mounted) return;
      safeSetState(() {
        _supplierOptions = supplierNames.toList()..sort();
        _productOptions = productNames.toList()..sort();
      });
    } catch (_) {
      // Options stay empty; the Create-PO form remains usable.
    }
  }

  // ── KPI CACHE ──
  int _kpiPendingApproval = 0;
  int _kpiInTransit = 0;
  int _kpiDeliveredMonth = 0;
  double _kpiTotalValueMonth = 0.0;

  // ── LOCAL PO LIST (session-scoped; created via the panels below) ──
  late List<_PurchaseOrder> _purchaseOrders;

  // ── ANIMATION ──
  late AnimationController _progressAnimController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PurchaseOrdersModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PurchaseOrders'});

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimController.forward();

    _purchaseOrders = <_PurchaseOrder>[];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
      _loadCatalogOptions();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }



  // ═══════════════════════════════════════════════════════════════
  //   STATUS HELPERS
  // ═══════════════════════════════════════════════════════════════

  Color _statusColor(String status) {
    switch (status) {
      case 'Draft':
        return const Color(0xFF6B7280);
      case 'Pending Approval':
        return const Color(0xFFF59E0B);
      case 'Approved':
        return const Color(0xFF2563EB);
      case 'Ordered':
        return const Color(0xFF6366F1);
      case 'Delivered':
        return const Color(0xFF10B981);
      case 'Cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Draft':
        return const Color(0xFFF3F4F6);
      case 'Pending Approval':
        return const Color(0xFFFEF3C7);
      case 'Approved':
        return const Color(0xFFDBEAFE);
      case 'Ordered':
        return const Color(0xFFE0E7FF);
      case 'Delivered':
        return const Color(0xFFD1FAE5);
      case 'Cancelled':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Draft':
        return Icons.edit_note_rounded;
      case 'Pending Approval':
        return Icons.schedule_rounded;
      case 'Approved':
        return Icons.check_circle_outline_rounded;
      case 'Ordered':
        return Icons.local_shipping_rounded;
      case 'Delivered':
        return Icons.task_alt_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //   UTILITY HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'K${value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ═══════════════════════════════════════════════════════════════
  //   AUTO-GENERATE: SCAN REORDER LEVELS
  // ═══════════════════════════════════════════════════════════════

  /// Scans the REAL inventory for items whose current quantity is
  /// at or below their configured reorder level (LimitNotice) and
  /// builds reorder suggestions from live Firestore data:
  ///
  ///  * Stock scope mirrors the rest of the app — Pulse network
  ///    users scan every pharmacy, pharmacy users scan their own
  ///    stock collection.
  ///  * Only items WITH a configured reorder level are considered;
  ///    healthy or unconfigured stock never appears in the list.
  ///  * Preferred supplier and unit cost come from the matching
  ///    Product Master record (matched by product name); the last
  ///    known stock price is the fallback.
  ///  * Suggested quantity uses a min/max replenishment policy:
  ///    order up to twice the reorder level.
  Future<void> _scanReorderLevels() async {
    safeSetState(() => _isScanning = true);
    final stopwatch = Stopwatch()..start();
    try {
      final stocks = await queryStockRecordOnce(
        parent: AccessControl.isPulseUser(context)
            ? null
            : AccessControl.parentRef(context) ?? currentUserReference,
      );
      final products = await queryProductMasterRecordOnce();
      final byName = <String, ProductMasterRecord>{};
      for (final p in products) {
        final key = p.name.toLowerCase().trim();
        if (key.isNotEmpty) byName[key] = p;
      }

      final items = <_ReorderItem>[];
      for (final s in stocks) {
        final reorder = s.limitNotice;
        if (reorder <= 0) continue; // no reorder point configured
        if (s.quantity > reorder) continue; // still above the point
        final name = s.name.trim();
        if (name.isEmpty) continue;
        final product = byName[name.toLowerCase()];
        final supplier = (product?.supplier ?? '').trim();
        final unitCost = (product != null && product.costPrice > 0)
            ? product.costPrice
            : s.price;
        // Min/max policy: order up to 2x the reorder level.
        final suggested = (reorder * 2 - s.quantity).clamp(1, 1000000);
        items.add(_ReorderItem(
          product: name,
          currentStock: s.quantity,
          reorderLevel: reorder,
          suggestedQty: suggested,
          preferredSupplier:
              supplier.isNotEmpty ? supplier : 'No preferred supplier',
          unitCost: unitCost,
        ));
      }
      // Most critical (lowest stock ratio) first.
      items.sort((a, b) => (a.currentStock / a.reorderLevel)
          .compareTo(b.currentStock / b.reorderLevel));

      // Keep the scan animation visible for a beat even when the
      // queries return quickly, so the flow still reads as a scan.
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 700) {
        await Future.delayed(Duration(milliseconds: 700 - elapsed));
      }
      if (!mounted) return;
      safeSetState(() {
        _reorderItems = items;
        _isScanning = false;
        _showAutoPanel = true;
      });
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _isScanning = false);
      _showToast('Could not scan inventory levels. Please try again.',
          isError: true);
    }
  }

  void _generatePoFromReorder() {
    // Group by supplier
    final bySupplier = <String, List<_ReorderItem>>{};
    for (final item in _reorderItems) {
      bySupplier.putIfAbsent(item.preferredSupplier, () => []).add(item);
    }
    int newCount = 0;
    for (final entry in bySupplier.entries) {
      final totalValue = entry.value.fold<double>(
        0.0,
        (sum, item) => sum + item.suggestedQty * item.unitCost,
      );
      _purchaseOrders.insert(
        0,
        _PurchaseOrder(
          poNumber: 'PO-2024-${0049 + newCount}',
          supplier: entry.key,
          itemCount: entry.value.length,
          totalValue: totalValue,
          status: 'Draft',
          createdDate: DateTime.now(),
          requestedBy: 'Auto-generated',
          fulfillment: 0.0,
          items: entry.value.map((i) => i.product).toList(),
        ),
      );
      newCount++;
    }
    _reorderItems.clear();
    safeSetState(() {
      _showAutoPanel = false;
      _kpiPendingApproval += 0; // Draft, not pending
    });
    _showToast('${newCount} draft PO(s) generated from reorder scan');
  }

  // ═══════════════════════════════════════════════════════════════
  //   PO ACTIONS
  // ═══════════════════════════════════════════════════════════════

  void _submitForApproval(int index) {
    safeSetState(() {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(
        status: 'Pending Approval',
      );
    });
    _showToast('PO ${_purchaseOrders[index].poNumber} submitted for approval');
  }

  void _approvePo(int index) {
    safeSetState(() {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(
        status: 'Approved',
      );
      _kpiPendingApproval--;
    });
    _showToast('PO ${_purchaseOrders[index].poNumber} approved');
  }

  void _rejectPo(int index) {
    safeSetState(() {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(
        status: 'Cancelled',
      );
      _kpiPendingApproval--;
    });
    _showToast('PO ${_purchaseOrders[index].poNumber} rejected', isError: true);
  }

  void _markAsOrdered(int index) {
    safeSetState(() {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(
        status: 'Ordered',
        fulfillment: 0.1,
      );
      _kpiInTransit++;
    });
    _showToast('PO ${_purchaseOrders[index].poNumber} marked as ordered');
  }

  void _markAsDelivered(int index) {
    safeSetState(() {
      _purchaseOrders[index] = _purchaseOrders[index].copyWith(
        status: 'Delivered',
        fulfillment: 1.0,
      );
      _kpiInTransit--;
      _kpiDeliveredMonth++;
    });
    _showToast(
        'PO ${_purchaseOrders[index].poNumber} delivered — update goods received');
  }

  Future<void> _deletePo(int index) async {
    final po = _purchaseOrders[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete purchase order?'),
        content: Text(
          'This will permanently remove ${po.poNumber}. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    safeSetState(() => _purchaseOrders.removeAt(index));
    _showToast('${po.poNumber} deleted');
  }

  // ═══════════════════════════════════════════════════════════════
  //   CREATE PO HELPERS
  // ═══════════════════════════════════════════════════════════════

  void _clearCreatePoForm() {
    for (final controller in _model.lineQtyControllers) {
      controller.dispose();
    }
    for (final controller in _model.linePriceControllers) {
      controller.dispose();
    }
    _model.lineQtyControllers.clear();
    _model.linePriceControllers.clear();
    _lineItems.clear();
    _selectedSupplier = null;
    _editingIndex = null;
  }

  Future<void> _openCreatePoDialog({int? editingIndex}) async {
    _clearCreatePoForm();

    if (editingIndex != null) {
      final po = _purchaseOrders[editingIndex];
      _editingIndex = editingIndex;
      _selectedSupplier = po.supplier;
      _lineItems = po.items
          .map((product) => _PoLineItem(
                product: product,
                quantity: 1,
                unitPrice:
                    po.itemCount == 0 ? 0.0 : po.totalValue / po.itemCount,
              ))
          .toList();
      for (final item in _lineItems) {
        _model.lineQtyControllers
            .add(TextEditingController(text: item.quantity.toString()));
        _model.linePriceControllers.add(
            TextEditingController(text: item.unitPrice.toStringAsFixed(2)));
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 24.0,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 820.0,
            maxHeight: MediaQuery.sizeOf(dialogContext).height - 48.0,
          ),
          child: SingleChildScrollView(
            child: _buildCreatePoPanel(),
          ),
        ),
      ),
    );

    if (!mounted) return;
    _clearCreatePoForm();
    safeSetState(() {});
  }

  void _addLineItem() {
    _lineItems.add(_PoLineItem(
      product: '',
      quantity: 1,
      unitPrice: 0.0,
    ));
    _model.lineQtyControllers.add(TextEditingController(text: '1'));
    _model.linePriceControllers.add(TextEditingController(text: '0.00'));
    safeSetState(() {});
  }

  void _startEditing(int index) {
    _openCreatePoDialog(editingIndex: index);
  }

  void _removeLineItem(int index) {
    _lineItems.removeAt(index);
    _model.lineQtyControllers[index].dispose();
    _model.linePriceControllers[index].dispose();
    _model.lineQtyControllers.removeAt(index);
    _model.linePriceControllers.removeAt(index);
    safeSetState(() {});
  }

  double _calculateLineTotal() {
    double total = 0.0;
    for (int i = 0; i < _lineItems.length; i++) {
      final qty = int.tryParse(_model.lineQtyControllers[i].text) ?? 0;
      final price = double.tryParse(_model.linePriceControllers[i].text) ?? 0.0;
      total += qty * price;
    }
    return total;
  }

  void _savePo({bool submit = false}) {
    if (_selectedSupplier == null || _selectedSupplier!.isEmpty) {
      _showToast('Please select a supplier', isError: true);
      return;
    }
    if (_lineItems.isEmpty) {
      _showToast('Add at least one line item', isError: true);
      return;
    }
    final total = _calculateLineTotal();
    final updatedPo = _PurchaseOrder(
      poNumber: _editingIndex == null
          ? 'PO-2024-${0049 + _purchaseOrders.length}'
          : _purchaseOrders[_editingIndex!].poNumber,
      supplier: _selectedSupplier!,
      itemCount: _lineItems.length,
      totalValue: total,
      status: submit ? 'Pending Approval' : 'Draft',
      createdDate: _editingIndex == null
          ? DateTime.now()
          : _purchaseOrders[_editingIndex!].createdDate,
      requestedBy: _editingIndex == null
          ? 'Manual'
          : _purchaseOrders[_editingIndex!].requestedBy,
      fulfillment: 0.0,
      items: _lineItems
          .map((i) => i.product.isEmpty ? 'Item' : i.product)
          .toList(),
    );
    if (_editingIndex == null) {
      _purchaseOrders.insert(0, updatedPo);
    } else {
      _purchaseOrders[_editingIndex!] = updatedPo;
    }
    _clearCreatePoForm();
    safeSetState(() {
      if (submit) _kpiPendingApproval++;
    });
    Navigator.of(context).pop();
    _showToast(
        submit ? 'PO created and submitted for approval' : 'Draft PO saved');
  }

  // ═══════════════════════════════════════════════════════════════
  //   MAIN BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final canView =
        AccessControl.hasPermission(context, Permission.purchaseOrdersView);
    final canCreate =
        AccessControl.hasPermission(context, Permission.purchaseOrdersCreate);
    final canApprove =
        AccessControl.hasPermission(context, Permission.purchaseOrdersApprove);
    final canEdit =
        AccessControl.hasPermission(context, Permission.purchaseOrdersEdit);
    final canDelete =
        AccessControl.hasPermission(context, Permission.purchaseOrdersDelete);

    if (!canView) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: Text(
            'You do not have permission to view purchase orders.',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
      );
    }

    return Title(
      title: 'Purchase Orders',
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
                // ── SIDE NAV (desktop) ──
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
                // ── MAIN CONTENT ──
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── TOP NAV ──
                      Align(
                        alignment: const AlignmentDirectional(0.0, -1.0),
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
                      // ── SCROLLABLE BODY ──
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 8.0, 24.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. HERO HEADER
                              _buildHeroHeader(canCreate),
                              const SizedBox(height: 24.0),

                              // 2. SUMMARY STATS
                              _buildSummaryStats(),
                              const SizedBox(height: 24.0),

                              // 3. AUTO-GENERATE PANEL (RBAC-gated)
                              if (canCreate) ...[
                                _buildAutoGeneratePanel(),
                                const SizedBox(height: 24.0),
                              ],

                              // 4. STATUS FILTER TABS
                              _buildStatusTabs(),
                              const SizedBox(height: 16.0),

                              // 5. PO LIST
                              _buildPoList(
                                  canApprove, canEdit, canCreate, canDelete),
                            ],
                          ),
                        ),
                      ),
                      // ── MOBILE NAV ──
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   1. HERO HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader(bool canCreate) {
    final theme = FlutterFlowTheme.of(context);
    final now = DateTime.now();
    final lastUpdated =
        '${now.day}/${now.month}/${now.year} · ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(28.0, 24.0, 28.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, theme.secondary],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(40),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Inventory',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Purchase Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purchase Orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Automate procurement. POs are generated when stock hits reorder level and routed to preferred suppliers — approve, track, and fulfill.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Hero action buttons
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              )) ...[
                if (canCreate)
                  _heroAction(Icons.add_rounded, 'Create PO', () {
                    _openCreatePoDialog();
                  }),
                const SizedBox(width: 8.0),
                _heroAction(Icons.auto_mode_rounded, 'Auto-Generate',
                    _scanReorderLevels),
                const SizedBox(width: 8.0),
                _heroAction(Icons.refresh_rounded, 'Refresh', () {
                  safeSetState(() {});
                }),
              ],
            ],
          ),
          const SizedBox(height: 16.0),
          // Live indicator
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _kpiPendingApproval > 0
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: [
                    BoxShadow(
                      color: (_kpiPendingApproval > 0
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF34D399))
                          .withAlpha(120),
                      blurRadius: 8.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Live · $lastUpdated · ${_purchaseOrders.where((p) => p.status == 'Pending Approval').length} pending approval',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Mobile action row
          if (responsiveVisibility(
            context: context,
            tabletLandscape: false,
            desktop: false,
          )) ...[
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                if (canCreate)
                  _heroAction(Icons.add_rounded, 'Create PO', () {
                    _openCreatePoDialog();
                  }),
                _heroAction(Icons.auto_mode_rounded, 'Auto-Generate',
                    _scanReorderLevels),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
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

  // ═══════════════════════════════════════════════════════════════
  //   2. SUMMARY STATS (4 KPI CARDS)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSummaryStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossCount = 4;
        double available = constraints.maxWidth;
        if (available < 1100) crossCount = 2;
        if (available < 600) crossCount = 1;

        final cardWidth = (available - 16.0 * (crossCount - 1)) / crossCount;

        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Pending Approval',
                value: '$_kpiPendingApproval',
                icon: Icons.schedule_rounded,
                accentColor: const Color(0xFFF59E0B),
                accentBg: const Color(0xFFFEF3C7),
                delta: _kpiPendingApproval > 0 ? 'Action needed' : 'All clear',
                deltaPositive: _kpiPendingApproval == 0,
                deltaIsNeutral: _kpiPendingApproval == 0,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'In Transit',
                value: '$_kpiInTransit',
                icon: Icons.local_shipping_rounded,
                accentColor: const Color(0xFF6366F1),
                accentBg: const Color(0xFFE0E7FF),
                delta: _kpiInTransit > 0 ? 'On the way' : 'None in transit',
                deltaPositive: true,
                deltaIsNeutral: _kpiInTransit == 0,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Delivered This Month',
                value: '$_kpiDeliveredMonth',
                icon: Icons.task_alt_rounded,
                accentColor: const Color(0xFF10B981),
                accentBg: const Color(0xFFD1FAE5),
                delta: _kpiDeliveredMonth > 0 ? 'Received' : 'None yet',
                deltaPositive: true,
                deltaIsNeutral: _kpiDeliveredMonth == 0,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                label: 'Total PO Value',
                value: _formatCurrency(_kpiTotalValueMonth),
                icon: Icons.account_balance_wallet_rounded,
                accentColor: const Color(0xFF9900FF),
                accentBg: const Color(0xFFF3F0FF),
                delta: 'This month',
                deltaPositive: true,
                deltaIsNeutral: true,
                isLargeValue: true,
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   3. AUTO-GENERATE PANEL
  // ═══════════════════════════════════════════════════════════════

  Widget _buildAutoGeneratePanel() {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9900FF).withAlpha(15),
                  const Color(0xFFF3F0FF).withAlpha(30),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.auto_mode_rounded,
                    color: Color(0xFF9900FF),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-Generate Purchase Orders',
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                      Text(
                        'Scan inventory for items below reorder level and generate POs for preferred suppliers',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scan button
                if (!_isScanning && !_showAutoPanel)
                  ElevatedButton.icon(
                    onPressed: _scanReorderLevels,
                    icon: const Icon(Icons.radar_rounded, size: 16.0),
                    label: const Text('Scan Reorder Levels'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9900FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Scanning state
          if (_isScanning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  SpinKitRing(
                    color: theme.primary,
                    size: 40.0,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Scanning inventory levels…',
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Comparing current stock against reorder points',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ),
            ),
          // Results
          if (_showAutoPanel && _reorderItems.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  // Result count
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '${_reorderItems.length} items below reorder level',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  // Reorder items list
                  ..._reorderItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final stockRatio = item.currentStock / item.reorderLevel;
                    return Container(
                      margin: EdgeInsets.only(top: idx == 0 ? 0.0 : 8.0),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 12.0, 16.0, 12.0),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: theme.alternate, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          // Stock level indicator
                          Column(
                            children: [
                              SizedBox(
                                width: 40.0,
                                height: 40.0,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: 1.0,
                                      strokeWidth: 3.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.alternate,
                                      ),
                                    ),
                                    CircularProgressIndicator(
                                      value: stockRatio.clamp(0.0, 1.0),
                                      strokeWidth: 3.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xFFEF4444),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${(stockRatio * 100).round()}%',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12.0),
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product,
                                  style: theme.bodyMedium.override(
                                    fontFamily: theme.bodyMediumFamily,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !theme.bodyMediumIsCustom,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  'Stock: ${item.currentStock} / Reorder: ${item.reorderLevel} → Suggest: ${item.suggestedQty} units',
                                  style: theme.bodySmall.override(
                                    fontFamily: theme.bodySmallFamily,
                                    color: theme.secondaryText,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !theme.bodySmallIsCustom,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Supplier badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F0FF),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              item.preferredSupplier,
                              style: const TextStyle(
                                color: Color(0xFF9900FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Unit cost
                          Text(
                            _formatCurrency(item.unitCost),
                            style: theme.bodyMedium.override(
                              fontFamily: theme.bodyMediumFamily,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodyMediumIsCustom,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16.0),
                  // Generate PO button
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _generatePoFromReorder,
                        icon:
                            const Icon(Icons.shopping_cart_rounded, size: 16.0),
                        label: const Text('Generate PO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9900FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      TextButton(
                        onPressed: () {
                          safeSetState(() {
                            _showAutoPanel = false;
                            _reorderItems.clear();
                          });
                        },
                        child: Text(
                          'Dismiss',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Empty scan result — real inventory had nothing below its
          // reorder levels. (Previously this state was unreachable
          // because the scan returned hardcoded demo items.)
          if (_showAutoPanel && _reorderItems.isEmpty)
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.0),
                  border:
                      Border.all(color: const Color(0xFFA7F3D0), width: 1.0),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF059669), size: 32.0),
                    const SizedBox(height: 12.0),
                    Text(
                      'All stock is above reorder levels',
                      style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'No products need reordering right now. Only items with a '
                      'configured reorder level that have fallen to or below it '
                      'appear here.',
                      textAlign: TextAlign.center,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: const Color(0xFF047857),
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    TextButton(
                      onPressed: () => safeSetState(() {
                        _showAutoPanel = false;
                      }),
                      child: Text(
                        'Dismiss',
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: const Color(0xFF047857),
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   4. CREATE PO PANEL
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCreatePoPanel() {
    final theme = FlutterFlowTheme.of(context);
    // Real supplier + product options loaded from Firestore (see
    // [_loadCatalogOptions]); falls back to a helpful hint when the
    // workspace has none yet.
    final suppliers = _supplierOptions;
    final products = _productOptions;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
            color: const Color(0xFF9900FF).withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9900FF).withAlpha(15),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Container(
            width: double.infinity,
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9900FF).withAlpha(20),
                  const Color(0xFFF3F0FF).withAlpha(40),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    color: Color(0xFF9900FF),
                    size: 20.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _editingIndex == null
                        ? 'Create Purchase Order'
                        : 'Edit Purchase Order',
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleMediumIsCustom,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: theme.secondaryText),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.primaryBackground,
                    minimumSize: const Size(32.0, 32.0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier dropdown
                Text(
                  'Supplier',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                const SizedBox(height: 6.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: theme.primaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: theme.alternate, width: 1.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSupplier,
                      hint: Text(
                        suppliers.isEmpty
                            ? 'No suppliers yet — add suppliers first'
                            : 'Select supplier…',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                      isExpanded: true,
                      items: suppliers
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          safeSetState(() => _selectedSupplier = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Line items header
                Row(
                  children: [
                    Text(
                      'Line Items',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _addLineItem,
                      icon: const Icon(Icons.add_rounded, size: 16.0),
                      label: const Text('Add Item'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF9900FF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                // Line items rows
                if (_lineItems.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: theme.alternate.withAlpha(128), width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            color: theme.secondaryText, size: 32.0),
                        const SizedBox(height: 8.0),
                        Text(
                          'No items added yet',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._lineItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  return Container(
                    margin: EdgeInsets.only(top: idx == 0 ? 0.0 : 8.0),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        12.0, 10.0, 12.0, 10.0),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: theme.alternate, width: 1.0),
                    ),
                    child: Row(
                      children: [
                        // Product selector
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: theme.secondaryBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: theme.alternate.withAlpha(128),
                                  width: 1.0),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _lineItems[idx].product.isEmpty
                                    ? null
                                    : _lineItems[idx].product,
                                hint: Text(
                                  products.isEmpty
                                      ? 'No stock items yet'
                                      : 'Product…',
                                  style: TextStyle(
                                      fontSize: 12, color: theme.secondaryText),
                                ),
                                isExpanded: true,
                                items: products
                                    .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(p,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (val) => safeSetState(() =>
                                    _lineItems[idx] = _lineItems[idx]
                                        .copyWith(product: val ?? '')),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Quantity
                        SizedBox(
                          width: 70.0,
                          child: TextField(
                            controller: _model.lineQtyControllers[idx],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              labelStyle: TextStyle(
                                  fontSize: 10, color: theme.secondaryText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: theme.alternate, width: 1.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (_) => safeSetState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Unit price
                        SizedBox(
                          width: 90.0,
                          child: TextField(
                            controller: _model.linePriceControllers[idx],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Unit Price',
                              labelStyle: TextStyle(
                                  fontSize: 10, color: theme.secondaryText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(
                                    color: theme.alternate, width: 1.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: (_) => safeSetState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        // Line total
                        Text(
                          _formatCurrency(
                            (int.tryParse(
                                        _model.lineQtyControllers[idx].text) ??
                                    0) *
                                (double.tryParse(_model
                                        .linePriceControllers[idx].text) ??
                                    0.0),
                          ),
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        // Remove
                        IconButton(
                          onPressed: () => _removeLineItem(idx),
                          icon: Icon(Icons.delete_outline_rounded,
                              color: const Color(0xFFEF4444), size: 18.0),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(28.0, 28.0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Totals section
                if (_lineItems.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 12.0, 16.0, 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total: ',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                        Text(
                          _formatCurrency(_calculateLineTotal()),
                          style: theme.headlineMedium.override(
                            fontFamily: theme.headlineMediumFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 20.0,
                            color: const Color(0xFF9900FF),
                            letterSpacing: -0.3,
                            useGoogleFonts: !theme.headlineMediumIsCustom,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_lineItems.length} item${_lineItems.length == 1 ? '' : 's'}',
                          style: theme.bodySmall.override(
                            fontFamily: theme.bodySmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Action buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _savePo(submit: true),
                        icon: const Icon(Icons.send_rounded, size: 16.0),
                        label: const Text('Submit for Approval'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9900FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      OutlinedButton.icon(
                        onPressed: () => _savePo(submit: false),
                        icon: const Icon(Icons.save_rounded, size: 16.0),
                        label: const Text('Save as Draft'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: const BorderSide(color: Color(0xFF6B7280)),
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   5. STATUS FILTER TABS (STICKY)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusTabs() {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 4.0, 4.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusTabs.map((tab) {
            final isActive = _statusFilter == tab;
            final count = tab == 'All'
                ? _purchaseOrders.length
                : _purchaseOrders.where((p) => p.status == tab).length;

            Color tabColor;
            if (isActive) {
              tabColor = tab == 'All' ? theme.primary : _statusColor(tab);
            } else {
              tabColor = Colors.transparent;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => safeSetState(() => _statusFilter = tab),
                  borderRadius: BorderRadius.circular(10.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isActive ? tabColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab,
                          style: TextStyle(
                            color:
                                isActive ? Colors.white : theme.secondaryText,
                            fontSize: 13,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withAlpha(30)
                                : theme.primaryBackground,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color:
                                  isActive ? Colors.white : theme.secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   6. PURCHASE ORDERS LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPoList(
      bool canApprove, bool canEdit, bool canCreate, bool canDelete) {
    final theme = FlutterFlowTheme.of(context);

    // Filter
    var filtered = _statusFilter == 'All'
        ? _purchaseOrders
        : _purchaseOrders.where((p) => p.status == _statusFilter).toList();

    // Search
    final query = (_model.searchTextController?.text ?? '').toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p.poNumber.toLowerCase().contains(query) ||
              p.supplier.toLowerCase().contains(query) ||
              p.items.any((i) => i.toLowerCase().contains(query)))
          .toList();
    }

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                color: theme.secondaryText, size: 48.0),
            const SizedBox(height: 16.0),
            Text(
              'No purchase orders found',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _statusFilter == 'All'
                  ? 'Create a new PO or auto-generate from reorder levels'
                  : 'No ${_statusFilter.toLowerCase()} purchase orders',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.asMap().entries.map((entry) {
        final idx = _purchaseOrders.indexOf(entry.value);
        final po = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          child:
              _buildPoCard(po, idx, canApprove, canEdit, canCreate, canDelete),
        );
      }).toList(),
    );
  }

  Widget _buildPoCard(_PurchaseOrder po, int idx, bool canApprove, bool canEdit,
      bool canCreate, bool canDelete) {
    final theme = FlutterFlowTheme.of(context);
    final statusCol = _statusColor(po.status);
    final statusBg = _statusBgColor(po.status);
    final statusIcn = _statusIcon(po.status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: po.status == 'Cancelled'
              ? const Color(0xFFEF4444).withAlpha(40)
              : theme.alternate,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(6),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card top row
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
            child: Row(
              children: [
                // PO number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            po.poNumber,
                            style: theme.titleMedium.override(
                              fontFamily: theme.titleMediumFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.titleMediumIsCustom,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcn, size: 12.0, color: statusCol),
                                const SizedBox(width: 4.0),
                                Text(
                                  po.status,
                                  style: TextStyle(
                                    color: statusCol,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        po.supplier,
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(po.totalValue),
                      style: theme.headlineMedium.override(
                        fontFamily: theme.headlineMediumFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.0,
                        letterSpacing: -0.3,
                        useGoogleFonts: !theme.headlineMediumIsCustom,
                      ),
                    ),
                    Text(
                      '${po.itemCount} item${po.itemCount == 1 ? '' : 's'}',
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Fulfillment progress bar (for Ordered status)
          if (po.status == 'Ordered' && po.fulfillment > 0.0) ...[
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Fulfillment',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.0,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(po.fulfillment * 100).round()}%',
                        style: TextStyle(
                          color: const Color(0xFF6366F1),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: AnimatedBuilder(
                      animation: _progressAnimController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: po.fulfillment * _progressAnimController.value,
                          minHeight: 6.0,
                          backgroundColor: const Color(0xFFE0E7FF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Delivered checkmark bar
          if (po.status == 'Delivered') ...[
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 0.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 14.0),
                  const SizedBox(width: 6.0),
                  Text(
                    'Fully received',
                    style: TextStyle(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom row: meta + actions
          Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(20.0, 12.0, 20.0, 16.0),
            child: Row(
              children: [
                // Meta info
                Icon(Icons.calendar_today_outlined,
                    color: theme.secondaryText, size: 12.0),
                const SizedBox(width: 4.0),
                Text(
                  _formatDate(po.createdDate),
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                const SizedBox(width: 12.0),
                Icon(Icons.person_outline_rounded,
                    color: theme.secondaryText, size: 12.0),
                const SizedBox(width: 4.0),
                Text(
                  po.requestedBy,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                const Spacer(),
                // Action buttons
                ..._buildPoActions(
                    po, idx, canApprove, canEdit, canCreate, canDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPoActions(_PurchaseOrder po, int idx, bool canApprove,
      bool canEdit, bool canCreate, bool canDelete) {
    final theme = FlutterFlowTheme.of(context);
    final actions = <Widget>[];

    Widget _actionChip(
        IconData icon, String label, Color color, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: color.withAlpha(40), width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 13.0, color: color),
                  const SizedBox(width: 4.0),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    switch (po.status) {
      case 'Draft':
        if (canEdit) {
          actions.add(_actionChip(
            Icons.edit_rounded,
            'Edit',
            const Color(0xFF6B7280),
            () => _startEditing(idx),
          ));
        }
        if (canCreate) {
          actions.add(_actionChip(
            Icons.send_rounded,
            'Submit',
            const Color(0xFFF59E0B),
            () => _submitForApproval(idx),
          ));
        }
        break;
      case 'Pending Approval':
        if (canApprove) {
          actions.add(_actionChip(
            Icons.check_rounded,
            'Approve',
            const Color(0xFF10B981),
            () => _approvePo(idx),
          ));
        }
        if (canApprove) {
          actions.add(_actionChip(
            Icons.close_rounded,
            'Reject',
            const Color(0xFFEF4444),
            () => _rejectPo(idx),
          ));
        }
        break;
      case 'Approved':
        if (canEdit) {
          actions.add(_actionChip(
            Icons.local_shipping_rounded,
            'Mark Ordered',
            const Color(0xFF6366F1),
            () => _markAsOrdered(idx),
          ));
        }
        break;
      case 'Ordered':
        if (canEdit) {
          actions.add(_actionChip(
            Icons.task_alt_rounded,
            'Mark Delivered',
            const Color(0xFF10B981),
            () => _markAsDelivered(idx),
          ));
        }
        break;
    }

    if (canDelete) {
      actions.add(_actionChip(
        Icons.delete_outline_rounded,
        'Delete',
        const Color(0xFFEF4444),
        () => _deletePo(idx),
      ));
    }

    return actions;
  }
}

// ═══════════════════════════════════════════════════════════════
//   KPI CARD
// ═══════════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentBg,
    required this.delta,
    required this.deltaPositive,
    this.deltaIsNeutral = false,
    this.isLargeValue = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color accentBg;
  final String delta;
  final bool deltaPositive;
  final bool deltaIsNeutral;
  final bool isLargeValue;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(6),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: accentColor, size: 18.0),
              ),
              const Spacer(),
              if (!deltaIsNeutral)
                Icon(
                  deltaPositive
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  size: 14.0,
                  color: deltaPositive
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            label,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.headlineMedium.override(
              fontFamily: theme.headlineMediumFamily,
              fontWeight: FontWeight.w700,
              fontSize: isLargeValue ? 18.0 : 22.0,
              letterSpacing: isLargeValue ? -0.3 : -0.5,
              useGoogleFonts: !theme.headlineMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: deltaIsNeutral
                  ? theme.primaryBackground
                  : (deltaPositive
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2)),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              delta,
              style: TextStyle(
                color: deltaIsNeutral
                    ? theme.secondaryText
                    : (deltaPositive
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444)),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   DATA MODELS
// ═══════════════════════════════════════════════════════════════

class _PurchaseOrder {
  final String poNumber;
  final String supplier;
  final int itemCount;
  final double totalValue;
  final String status;
  final DateTime createdDate;
  final String requestedBy;
  final double fulfillment;
  final List<String> items;

  _PurchaseOrder({
    required this.poNumber,
    required this.supplier,
    required this.itemCount,
    required this.totalValue,
    required this.status,
    required this.createdDate,
    required this.requestedBy,
    required this.fulfillment,
    required this.items,
  });

  _PurchaseOrder copyWith({
    String? status,
    double? fulfillment,
  }) {
    return _PurchaseOrder(
      poNumber: poNumber,
      supplier: supplier,
      itemCount: itemCount,
      totalValue: totalValue,
      status: status ?? this.status,
      createdDate: createdDate,
      requestedBy: requestedBy,
      fulfillment: fulfillment ?? this.fulfillment,
      items: items,
    );
  }
}

class _ReorderItem {
  final String product;
  final int currentStock;
  final int reorderLevel;
  final int suggestedQty;
  final String preferredSupplier;
  final double unitCost;

  _ReorderItem({
    required this.product,
    required this.currentStock,
    required this.reorderLevel,
    required this.suggestedQty,
    required this.preferredSupplier,
    required this.unitCost,
  });
}

class _PoLineItem {
  final String product;
  final int quantity;
  final double unitPrice;

  _PoLineItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  _PoLineItem copyWith({
    String? product,
    int? quantity,
    double? unitPrice,
  }) {
    return _PoLineItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
