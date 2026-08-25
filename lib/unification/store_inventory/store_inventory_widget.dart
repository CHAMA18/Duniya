import '/auth/firebase_auth/auth_util.dart';
import '/rbac/rbac.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/import_inventory_dialog/import_inventory_dialog_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'store_inventory_model.dart';
export 'store_inventory_model.dart';

class StoreInventoryWidget extends StatefulWidget {
  const StoreInventoryWidget({super.key});

  static String routeName = 'StoreInventory';
  static String routePath = '/storeInventory';

  @override
  State<StoreInventoryWidget> createState() => _StoreInventoryWidgetState();
}

class _StoreInventoryWidgetState extends State<StoreInventoryWidget> {
  late StoreInventoryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // ── BULK SELECTION ──
  // Document ids of the stock rows ticked for a bulk delete. Kept as ids
  // (not references) so pagination/searching never orphans a selection.
  final Set<String> _selectedStockIds = {};
  bool _isBulkDeleting = false;

  bool get _canDeleteStock =>
      AccessControl.hasPermission(context, Permission.inventoryDelete);

  /// Delete every selected stock row in chunked Firestore batches (400
  /// ops per batch — safely under the 500-op limit), then clear the
  /// selection. Guarded by a destructive-action confirmation dialog.
  Future<void> _deleteSelectedStock() async {
    if (_selectedStockIds.isEmpty) return;

    final count = _selectedStockIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded,
                color: Color(0xFFDC2626), size: 26),
            const SizedBox(width: 10),
            Expanded(
                child: Text('Delete $count '
                    '${count == 1 ? 'item' : 'items'}?')),
          ],
        ),
        content: Text(
          'The selected ${count == 1 ? 'product entry will be permanently removed'
              : 'product entries will be permanently removed'} '
          'from your store inventory. This cannot be undone.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    safeSetState(() => _isBulkDeleting = true);
    try {
      final ids = _selectedStockIds.toList();
      const chunkSize = 400;
      for (var i = 0; i < ids.length; i += chunkSize) {
        final chunk = ids.sublist(
            i, (i + chunkSize).clamp(0, ids.length));
        final batch = FirebaseFirestore.instance.batch();
        for (final id in chunk) {
          batch.delete(FirebaseFirestore.instance.doc(id));
        }
        await batch.commit();
      }
      if (!mounted) return;
      _selectedStockIds.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count == 1
              ? 'Deleted 1 item from your inventory.'
              : 'Deleted $count items from your inventory.'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some items could not be deleted: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)),
        ),
      );
    } finally {
      if (mounted) safeSetState(() => _isBulkDeleting = false);
    }
  }

  // Category filter options
  final List<String> _categories = [
    'All Categories',
    'Medicine',
    'Nutrition Supplements',
    'Mother and Babycare',
    'Veterinary Products',
    'Beauty Care',
    'Personal Care',
  ];

  // Sort options
  final List<String> _sortOptions = [
    'Stock Level (Low to High)',
    'Product Name (A-Z)',
    'Value (High to Low)',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StoreInventoryModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StoreInventory'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Get the parent reference based on user role
  DocumentReference? _getParentRef() {
    return AccessControl.parentRef(context);
  }

  /// Navigate to category page with role-based logic
  Future<void> _navigateToCategory(String category) async {
    var shouldSetState = false;
    if (AccessControl.isOwner(context)) {
      context.pushNamed(
        InventoryCategoryWidget.routeName,
        queryParameters: {
          'category': serializeParam(category, ParamType.String),
        }.withoutNulls,
      );
    } else {
      final staff = await queryStaffRecordOnce(
        queryBuilder: (q) => q.where('Email', isEqualTo: currentUserEmail),
        singleRecord: true,
      ).then((s) => s.firstOrNull);
      shouldSetState = true;
      if (staff?.pharmId != null) {
        final pharm = await PharmacyRecord.getDocumentOnce(staff!.pharmId!);
        shouldSetState = true;
        if (mounted) {
          context.pushNamed(
            InventoryCategoryWidget.routeName,
            queryParameters: {
              'category': serializeParam(category, ParamType.String),
              'pharmacy': serializeParam(pharm.name, ParamType.String),
            }.withoutNulls,
          );
        }
      }
    }
    if (shouldSetState) safeSetState(() {});
  }

  /// Show the spreadsheet import dialog.
  void _showImportDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ImportInventoryDialogWidget(
        onComplete: (importedCount) {
          if (importedCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  importedCount == 1
                      ? 'Imported 1 item to your inventory.'
                      : 'Imported $importedCount items to your inventory.',
                ),
                backgroundColor: const Color(0xFF059669),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
            );
            safeSetState(() {});
          }
        },
      ),
    );
  }

  /// Navigate to inventory details
  /// Inline editor for a product entry (stock record) — edits name,
  /// manufacturer, category, batch, price and quantity directly from
  /// the inventory table without navigating away. Writes via
  /// reference.update so Firestore streams refresh the table row
  /// automatically; a StockMovement audit row records the change.
  Future<void> _showEditStockDialog(StockRecord stock) async {
    final theme = FlutterFlowTheme.of(context);

    final nameController = TextEditingController(text: stock.name);
    final manufacturerController =
        TextEditingController(text: stock.manufacturer);
    final categoryController = TextEditingController(text: stock.category);
    final batchController = TextEditingController(text: stock.batchNumber);
    final priceController =
        TextEditingController(text: stock.price.toStringAsFixed(2));
    final qtyController = TextEditingController(text: '${stock.quantity}');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primary, theme.secondary],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit Product Entry',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Update details — changes are audited',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.8), size: 20),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _editField('Product name', nameController, 'e.g. Amoxicillin 500mg'),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _editField(
                              'Manufacturer', manufacturerController, 'e.g. Shalina')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _editField(
                              'Category', categoryController, 'e.g. Antibiotics')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _editField(
                              'Batch number', batchController, 'e.g. BT-2026-14')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _editField('Unit price (ZMK)', priceController, '0.00',
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _editField('Quantity in stock', qtyController, '0',
                      isNumber: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel',
                  style: TextStyle(color: theme.secondaryText)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newQty = int.tryParse(qtyController.text.trim());
                final newPrice = double.tryParse(priceController.text.trim());

                if (newName.isEmpty || newQty == null || newPrice == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'A name, a whole-number quantity and a numeric price are required.')),
                  );
                  return;
                }

                try {
                  // Only write fields that actually changed — keeps the
                  // Firestore update minimal and the audit precise.
                  final changes = <String, dynamic>{
                    'Name': newName,
                    'Quantity': newQty,
                    'Price': newPrice,
                  };
                  final newManufacturer = manufacturerController.text.trim();
                  final newCategory = categoryController.text.trim();
                  final newBatch = batchController.text.trim();
                  if (newManufacturer != stock.manufacturer) {
                    changes['Manufacturer'] = newManufacturer;
                  }
                  if (newCategory != stock.category) {
                    changes['Category'] = newCategory;
                  }
                  if (newBatch != stock.batchNumber) {
                    changes['BatchNumber'] = newBatch;
                  }

                  await stock.reference.update(changes);

                  // Audit trail — an ADJUSTMENT movement whenever the
                  // quantity changes, so the ledger explains the delta.
                  if (newQty != stock.quantity) {
                    final scope = stock.reference.path
                        .split('/')
                        .take(2)
                        .join('/');
                    try {
                      await StockMovementRecord.createDoc(
                              FirebaseFirestore.instance.doc(scope))
                          .set(createStockMovementRecordData(
                        productId: stock.reference,
                        productName: newName,
                        quantity: newQty - stock.quantity,
                        movementType: 'ADJUSTMENT',
                        reason:
                            'Inventory edit: quantity ${stock.quantity} → $newQty',
                        movementReference: stock.reference.id,
                        recordedById: currentUserReference,
                        createdAt: DateTime.now(),
                      ));
                    } catch (_) {
                      // The stock update already succeeded; the audit row
                      // is best-effort.
                    }
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Could not save the changes. Try again.')),
                  );
                }
              },
              child: const Text('Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    manufacturerController.dispose();
    categoryController.dispose();
    batchController.dispose();
    priceController.dispose();
    qtyController.dispose();

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product entry updated'),
          backgroundColor: theme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _editField(String label, TextEditingController controller, String hint,
      {bool isNumber = false}) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.secondaryText,
              useGoogleFonts: !theme.labelMediumIsCustom,
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType:
              isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: theme.secondaryText, fontSize: 12.5),
            filled: true,
            fillColor: theme.primaryBackground,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.alternate),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.alternate),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(DocumentReference stockRef) {
    context.pushNamed(
      InventoryDetailsWidget.routeName,
      queryParameters: {
        'stock': serializeParam(stockRef, ParamType.DocumentReference),
      }.withoutNulls,
    );
  }

  /// Determine stock status from a stock record
  String _getStockStatus(StockRecord stock) {
    if (stock.quantity <= 0) return 'Out of Stock';
    if (stock.limitNotice > 0 && stock.quantity <= stock.limitNotice) return 'Low Stock';
    if (stock.initialQuantity > 0 && stock.quantity < (stock.initialQuantity * 0.3)) return 'Low Stock';
    return 'In Stock';
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Medicine':
        return Icons.medication_outlined;
      case 'Nutrition Supplements':
        return Icons.local_pharmacy_outlined;
      case 'Mother and Babycare':
        return Icons.baby_changing_station_outlined;
      case 'Veterinary Products':
        return Icons.pets_outlined;
      case 'Beauty Care':
        return Icons.face_outlined;
      case 'Personal Care':
        return Icons.spa_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design tokens — Black + White theme
    final primaryBlue = theme.primary; // Black
    final primaryContainer = theme.primary.withValues(alpha: 0.08);
    final secondaryTeal = theme.secondary; // Gray 700
    final surfaceBg = theme.primaryBackground; // White in light, gray-900 in dark
    final onSurface = theme.primaryText;
    final onSurfaceVariant = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);
    final outline = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151);
    final outlineVariant = theme.lineColor;
    final surfaceContainerLow = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final surfaceContainerHighest = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final cardBg = theme.secondaryBackground; // White cards
    final surfaceDim = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);

    return Title(
      title: 'Store Inventory',
      color: theme.primary.withAlpha(0XFF),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: surfaceBg,
          drawer: Drawer(
            elevation: 16.0,
            child: WebViewAware(
              child: wrapWithModel(
                model: _model.sideNavModel2,
                updateCallback: () => safeSetState(() {}),
                child: SideNavWidget(),
              ),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Sidebar
                if (responsiveVisibility(
                  context: context,
                  phone: false,
                  tablet: false,
                ))
                  wrapWithModel(
                    model: _model.sideNavModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: SideNavWidget(),
                  ),
                // Main Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Navigation
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ),
                      // Content Area
                      Expanded(
                        child: AuthUserStreamWidget(
                          builder: (context) =>
                              StreamBuilder<List<StockRecord>>(
                            stream: queryStockRecord(
                              parent: _getParentRef(),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 80.0,
                                    height: 80.0,
                                    child: SpinKitRing(
                                      color: primaryBlue,
                                      size: 80.0,
                                    ),
                                  ),
                                );
                              }

                              List<StockRecord> allStock = snapshot.data!;

                              // Apply search filter
                              List<StockRecord> filteredStock = allStock;
                              if (_model.searchQuery.isNotEmpty) {
                                final query = _model.searchQuery.toLowerCase();
                                filteredStock = filteredStock
                                    .where((s) =>
                                        s.name.toLowerCase().contains(query) ||
                                        s.batchNumber.toLowerCase().contains(query) ||
                                        s.manufacturer.toLowerCase().contains(query) ||
                                        s.category.toLowerCase().contains(query))
                                    .toList();
                              }

                              // Apply category filter
                              if (_model.selectedCategory != 'All Categories') {
                                filteredStock = filteredStock
                                    .where((s) => s.category == _model.selectedCategory)
                                    .toList();
                              }

                              // Apply sorting
                              switch (_model.sortBy) {
                                case 'Product Name (A-Z)':
                                  filteredStock.sort((a, b) => a.name.compareTo(b.name));
                                  break;
                                case 'Value (High to Low)':
                                  filteredStock.sort((a, b) =>
                                      (b.price * b.quantity.toDouble())
                                          .compareTo(a.price * a.quantity.toDouble()));
                                  break;
                                case 'Stock Level (Low to High)':
                                default:
                                  filteredStock.sort((a, b) => a.quantity.compareTo(b.quantity));
                                  break;
                              }

                              // Compute summary metrics
                              double totalStockValue = allStock.fold(
                                  0.0, (sum, s) => sum + (s.price * s.quantity.toDouble()));
                              int nearExpiryCount = allStock.where((s) {
                                if (s.expiryDate == null) return false;
                                final daysLeft = s.expiryDate!.difference(DateTime.now()).inDays;
                                return daysLeft >= 0 && daysLeft <= 30;
                              }).length;
                              int lowStockCount = allStock
                                  .where((s) => _getStockStatus(s) == 'Low Stock')
                                  .length;

                              // Pagination
                              int totalPages =
                                  (filteredStock.length / _model.itemsPerPage).ceil();
                              if (totalPages < 1) totalPages = 1;
                              if (_model.currentPage > totalPages) {
                                _model.currentPage = 1;
                              }
                              int startIndex = (_model.currentPage - 1) * _model.itemsPerPage;
                              int endIndex = (startIndex + _model.itemsPerPage).clamp(0, filteredStock.length);
                              List<StockRecord> pageStock =
                                  filteredStock.sublist(startIndex, endIndex.clamp(0, filteredStock.length));

                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ===== PAGE HEADER =====
                                    _buildPageHeader(context, onSurface, onSurfaceVariant,
                                        primaryBlue, outlineVariant, primaryContainer),
                                    const SizedBox(height: 24.0),

                                    // ===== EXECUTIVE SUMMARY CARDS =====
                                    _buildSummaryCards(
                                      context,
                                      totalStockValue,
                                      nearExpiryCount,
                                      lowStockCount,
                                      allStock.length,
                                      primaryBlue,
                                      primaryContainer,
                                      secondaryTeal,
                                      onSurface,
                                      onSurfaceVariant,
                                      outline,
                                      outlineVariant,
                                      surfaceContainerLow,
                                      surfaceContainerHighest,
                                      cardBg,
                                      surfaceDim,
                                    ),
                                    const SizedBox(height: 24.0),

                                    // ===== FILTERS BAR =====
                                    _buildFiltersBar(
                                      context,
                                      primaryBlue,
                                      onSurface,
                                      onSurfaceVariant,
                                      outline,
                                      outlineVariant,
                                      surfaceContainerLow,
                                      cardBg,
                                    ),
                                    const SizedBox(height: 24.0),

                                    // ===== BULK SELECTION ACTION BAR =====
                                    // Appears only while at least one row is
                                    // ticked — offers select-all-page and
                                    // the destructive bulk delete.
                                    if (_canDeleteStock &&
                                        _selectedStockIds.isNotEmpty)
                                      _buildBulkActionBar(
                                        context,
                                        pageStock,
                                        primaryBlue,
                                        onSurface,
                                        outlineVariant,
                                        cardBg,
                                      ),
                                    if (_canDeleteStock &&
                                        _selectedStockIds.isNotEmpty)
                                      const SizedBox(height: 16.0),

                                    // ===== DATA TABLE =====
                                    _buildDataTable(
                                      context,
                                      pageStock,
                                      filteredStock.length,
                                      primaryBlue,
                                      primaryContainer,
                                      secondaryTeal,
                                      onSurface,
                                      onSurfaceVariant,
                                      outline,
                                      outlineVariant,
                                      surfaceContainerLow,
                                      surfaceContainerHighest,
                                      cardBg,
                                      surfaceDim,
                                    ),
                                    const SizedBox(height: 16.0),

                                    // ===== PAGINATION =====
                                    _buildPagination(
                                      context,
                                      totalPages,
                                      filteredStock.length,
                                      primaryBlue,
                                      onSurface,
                                      onSurfaceVariant,
                                      outline,
                                      outlineVariant,
                                      surfaceContainerLow,
                                      cardBg,
                                    ),
                                    const SizedBox(height: 32.0),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
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

  // ===== PAGE HEADER =====
  Widget _buildPageHeader(
    BuildContext context,
    Color onSurface,
    Color onSurfaceVariant,
    Color primaryBlue,
    Color outlineVariant,
    Color primaryContainer,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16.0,
      runSpacing: 12.0,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Inventory',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 32.0,
                fontWeight: FontWeight.w600,
                color: onSurface,
                height: 1.2,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Manage and track your primary pharmacy stock.',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Product Button
            Material(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => _navigateToCategory('Medicine'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Import Button — opens the spreadsheet import dialog
            Material(
              color: const Color(0xFFA100FF),
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => _showImportDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_file_outlined, color: Colors.white, size: 18.0),
                      const SizedBox(width: 8.0),
                      const Text(
                        'Import',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Export Button
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => downloadInventoryTemplate(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_outlined, color: onSurface, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Template',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== EXECUTIVE SUMMARY CARDS =====
  Widget _buildSummaryCards(
    BuildContext context,
    double totalStockValue,
    int nearExpiryCount,
    int lowStockCount,
    int totalSKUs,
    Color primaryBlue,
    Color primaryContainer,
    Color secondaryTeal,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color surfaceContainerHighest,
    Color cardBg,
    Color surfaceDim,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        return GestureDetector(
          onTap: () async {
            logFirebaseEvent('STORE_INVENTORY_POS_HERO_ON_TAP');
            logFirebaseEvent('StoreInventory_navigate_to');
            context.goNamed(
              SalesVMIWidget.routeName,
              queryParameters: {
                'pharmacy': serializeParam(
                  FFAppState().Pharm,
                  ParamType.String,
                ),
              }.withoutNulls,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
            FFAppState().SelectedPage = 'Point Of Sale';
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue,
                  primaryBlue.withValues(alpha: 0.82),
                  Color(0xFF6C3CE1), // Accent purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 24.0,
                  spreadRadius: 4.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40.0 : 24.0,
                vertical: isWide ? 36.0 : 28.0,
              ),
              child: isWide
                  ? Row(
                      children: [
                        // Left: POS icon + branding
                        Container(
                          width: 72.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.point_of_sale_rounded,
                            color: Colors.white,
                            size: 38.0,
                          ),
                        ),
                        SizedBox(width: 28.0),
                        // Center: Title + description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Text(
                                      'POINT OF SALE',
                                      style: TextStyle(
                                        fontFamily: kAppFontFamily,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Start Selling & Dispensing',
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Quick sales, prescriptions, and dispensing — all in one place. Tap to begin a transaction.',
                                style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24.0),
                        // Right: Quick stats + CTA
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStatChip(
                                  icon: Icons.inventory_2_outlined,
                                  label: '$totalSKUs items',
                                  value: 'In Stock',
                                ),
                                SizedBox(width: 12.0),
                                _buildStatChip(
                                  icon: Icons.payments_outlined,
                                  label: 'ZMK ${_formatNumber(totalStockValue)}',
                                  value: 'Stock Value',
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Open POS',
                                    style: TextStyle(
                                      fontFamily: kAppFontFamily,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: primaryBlue,
                                    size: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile layout
                        Row(
                          children: [
                            Container(
                              width: 56.0,
                              height: 56.0,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.point_of_sale_rounded,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      'POINT OF SALE',
                                      style: TextStyle(
                                        fontFamily: kAppFontFamily,
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Start Selling & Dispensing',
                                    style: TextStyle(
                                      fontFamily: kAppFontFamily,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          'Quick sales, prescriptions, and dispensing — all in one place. Tap to begin a transaction.',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            _buildStatChip(
                              icon: Icons.inventory_2_outlined,
                              label: '$totalSKUs items',
                              value: 'In Stock',
                            ),
                            SizedBox(width: 10.0),
                            _buildStatChip(
                              icon: Icons.payments_outlined,
                              label: 'ZMK ${_formatNumber(totalStockValue)}',
                              value: 'Value',
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Open POS',
                                  style: TextStyle(
                                    fontFamily: kAppFontFamily,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBlue,
                                  ),
                                ),
                                SizedBox(width: 6.0),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: primaryBlue,
                                  size: 18.0,
                                ),
                              ],
                            ),
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

  /// Small stat chip used inside the POS hero card
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 16.0),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== FILTERS BAR =====
  Widget _buildFiltersBar(
    BuildContext context,
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.0,
        runSpacing: 8.0,
        children: [
          // Left: Search + Category filters
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: [
              // Search field
              SizedBox(
                width: 220.0,
                height: 36.0,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    safeSetState(() {
                      _model.searchQuery = val;
                      _model.currentPage = 1;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search inventory, SKU, or batch...',
                    hintStyle: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.0,
                      color: outline,
                    ),
                    prefixIcon: Icon(Icons.search, color: outline, size: 18.0),
                    filled: true,
                    fillColor: surfaceContainerLow,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: primaryBlue.withValues(alpha: 0.5)),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    color: onSurface,
                  ),
                ),
              ),
              SizedBox(width: 4.0),
              // Category filter chips
              ..._categories.map((cat) {
                final isSelected = _model.selectedCategory == cat;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6.0),
                    onTap: () {
                      safeSetState(() {
                        _model.selectedCategory = cat;
                        _model.currentPage = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                            )
                          : null,
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? primaryBlue : onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Filter button
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(6.0),
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, color: onSurfaceVariant, size: 16.0),
                        SizedBox(width: 4.0),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Right: Sort dropdown
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by:',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: outline,
                ),
              ),
              SizedBox(width: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
                ),
                child: DropdownButton<String>(
                  value: _model.sortBy,
                  underline: SizedBox.shrink(),
                  isDense: true,
                  icon: Icon(Icons.expand_more, size: 16.0),
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: onSurface,
                  ),
                  items: _sortOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Text(opt),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      safeSetState(() {
                        _model.sortBy = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== BULK SELECTION ACTION BAR =====
  // Shown while rows are ticked: select-all-page toggle, live count,
  // destructive bulk delete and clear-selection.
  Widget _buildBulkActionBar(
    BuildContext context,
    List<StockRecord> pageStock,
    Color primaryBlue,
    Color onSurface,
    Color outlineVariant,
    Color cardBg,
  ) {
    final allPageSelected =
        pageStock.isNotEmpty && pageStock.every((s) => _selectedStockIds.contains(s.reference.path));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.checklist_rounded, color: primaryBlue, size: 20.0),
          const SizedBox(width: 10.0),
          Text(
            '${_selectedStockIds.length} selected',
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            'across all pages',
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 12.0,
              color: onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          // Select-all-page toggle
          TextButton.icon(
            onPressed: () {
              safeSetState(() {
                if (allPageSelected) {
                  for (final s in pageStock) {
                    _selectedStockIds.remove(s.reference.path);
                  }
                } else {
                  for (final s in pageStock) {
                    _selectedStockIds.add(s.reference.path);
                  }
                }
              });
            },
            icon: Icon(
              allPageSelected
                  ? Icons.deselect_rounded
                  : Icons.select_all_rounded,
              size: 18.0,
            ),
            label: Text(allPageSelected
                ? 'Deselect page'
                : 'Select page (${pageStock.length})'),
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue,
              textStyle: const TextStyle(
                  fontFamily: kAppFontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8.0),
          // Bulk delete
          _isBulkDeleting
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onPressed: _deleteSelectedStock,
                  icon: const Icon(Icons.delete_outline, size: 18.0),
                  label: const Text('Delete Selected'),
                ),
          const SizedBox(width: 8.0),
          IconButton(
            tooltip: 'Clear selection',
            onPressed: () => safeSetState(() => _selectedStockIds.clear()),
            icon: Icon(Icons.close_rounded,
                color: onSurface.withValues(alpha: 0.6), size: 20.0),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    List<StockRecord> pageStock,
    int totalFiltered,
    Color primaryBlue,
    Color primaryContainer,
    Color secondaryTeal,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color surfaceContainerHighest,
    Color cardBg,
    Color surfaceDim,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            // Table header
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: surfaceContainerLow.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  // Bulk-select checkbox column (only for users who may
                  // delete — the column powers the multi-delete flow).
                  if (_canDeleteStock)
                    SizedBox(
                      width: 56.0,
                      child: Center(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: pageStock.isNotEmpty &&
                                  pageStock.every((s) => _selectedStockIds
                                      .contains(s.reference.path)),
                              tristate: false,
                              onChanged: (checked) {
                                safeSetState(() {
                                  if (checked == true) {
                                    for (final s in pageStock) {
                                      _selectedStockIds
                                          .add(s.reference.path);
                                    }
                                  } else {
                                    for (final s in pageStock) {
                                      _selectedStockIds
                                          .remove(s.reference.path);
                                    }
                                  }
                                });
                              },
                              activeColor: primaryBlue,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Product & Manufacturer',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'SKU / Batch',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Stock Level',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Unit Price',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Status',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Actions',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                          letterSpacing: 0.08,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Table body
            if (pageStock.isEmpty)
              Container(
                padding: EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48.0, color: outlineVariant),
                    SizedBox(height: 16.0),
                    Text(
                      'No stock items found',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Try adjusting your search or filter criteria',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: outline,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...pageStock.map((stock) => _buildTableRow(
                    stock,
                    primaryBlue,
                    primaryContainer,
                    secondaryTeal,
                    onSurface,
                    onSurfaceVariant,
                    outline,
                    outlineVariant,
                    surfaceContainerLow,
                    surfaceContainerHighest,
                    surfaceDim,
                  )),
          ],
        ),
      ),
    );
  }

  // ===== TABLE ROW =====
  Widget _buildTableRow(
    StockRecord stock,
    Color primaryBlue,
    Color primaryContainer,
    Color secondaryTeal,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color surfaceContainerHighest,
    Color surfaceDim,
  ) {
    final status = _getStockStatus(stock);
    final isOutOfStock = status == 'Out of Stock';
    final isLowStock = status == 'Low Stock';
    final stockPercent = stock.initialQuantity > 0
        ? (stock.quantity / stock.initialQuantity).clamp(0.0, 1.0)
        : (stock.quantity > 0 ? 1.0 : 0.0);

    // Status colors
    Color statusColor;
    Color statusBgColor;
    if (isOutOfStock) {
      statusColor = primaryBlue;
      statusBgColor = primaryBlue.withValues(alpha: 0.1);
    } else if (isLowStock) {
      statusColor = primaryBlue;
      statusBgColor = primaryBlue.withValues(alpha: 0.1);
    } else {
      statusColor = secondaryTeal;
      statusBgColor = primaryBlue.withValues(alpha: 0.08);
    }

    // Progress bar color
    Color progressColor;
    if (stock.quantity <= 0) {
      progressColor = primaryBlue;
    } else if (stockPercent < 0.3) {
      progressColor = primaryBlue;
    } else {
      progressColor = primaryBlue;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isOutOfStock ? primaryBlue.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.95),
          border: Border(
            bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          children: [
            // Row checkbox for bulk selection
            if (_canDeleteStock)
              SizedBox(
                width: 56.0,
                child: Center(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value:
                            _selectedStockIds.contains(stock.reference.path),
                        onChanged: (checked) {
                          safeSetState(() {
                            if (checked == true) {
                              _selectedStockIds.add(stock.reference.path);
                            } else {
                              _selectedStockIds.remove(stock.reference.path);
                            }
                          });
                        },
                        activeColor: primaryBlue,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
              ),
            // Product & Manufacturer
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: surfaceDim.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        _getCategoryIcon(stock.category),
                        color: outline,
                        size: 20.0,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full name on hover (tooltip) + up to two
                          // display lines before ellipsis — long
                          // pharmacy product names no longer clip
                          // mid-word in the table.
                          Tooltip(
                            message: stock.name.isNotEmpty
                                ? stock.name
                                : 'Unknown Product',
                            waitDuration: const Duration(milliseconds: 400),
                            child: Text(
                              stock.name.isNotEmpty
                                  ? stock.name
                                  : 'Unknown Product',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                                color: onSurface.withValues(
                                    alpha: isOutOfStock ? 0.6 : 1.0),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Tooltip(
                            message:
                                '${stock.manufacturer.isNotEmpty ? stock.manufacturer : "Unknown"} • ${stock.category.isNotEmpty ? stock.category : "Uncategorized"}',
                            waitDuration: const Duration(milliseconds: 400),
                            child: Text(
                              '${stock.manufacturer.isNotEmpty ? stock.manufacturer : "Unknown"} • ${stock.category.isNotEmpty ? stock.category : "Uncategorized"}',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                color: outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SKU / Batch
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.batchNumber.isNotEmpty ? stock.batchNumber : 'N/A',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    if (stock.batchNumber.isNotEmpty)
                      Text(
                        'B-${stock.batchNumber.hashCode.abs().toRadixString(16).toUpperCase().padLeft(5, '0').substring(0, 5)}',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Stock Level
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${stock.quantity} units',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: isLowStock || isOutOfStock ? primaryBlue : onSurface,
                          ),
                        ),
                        Text(
                          'Max: ${stock.initialQuantity.toInt()}',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: stockPercent,
                        backgroundColor: surfaceDim.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 6.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Unit Price
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ZMK ${stock.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'Val: ZMK ${(stock.price * stock.quantity.toDouble()).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status badge
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6.0),
                      border: isOutOfStock ? Border.all(color: primaryBlue.withValues(alpha: 0.2)) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.0,
                          height: 6.0,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          status,
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Actions
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isOutOfStock)
                      Material(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(4.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4.0),
                          onTap: () => _navigateToDetails(stock.reference),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            child: Text(
                              'Reorder',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4.0),
                          onTap: () => _navigateToDetails(stock.reference),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Tooltip(
                              message: 'Restock',
                              child: Icon(Icons.add_shopping_cart_outlined, color: primaryBlue, size: 18.0),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4.0),
                          onTap: () => _navigateToDetails(stock.reference),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Tooltip(
                              message: 'View Details',
                              child: Icon(Icons.visibility_outlined, color: onSurfaceVariant, size: 18.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Edit — available on EVERY row so product entries
                    // can be corrected directly from the inventory table.
                    const SizedBox(width: 4.0),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4.0),
                        onTap: () => _showEditStockDialog(stock),
                        child: Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Tooltip(
                            message: 'Edit product entry',
                            child: Icon(Icons.edit_outlined, color: primaryBlue, size: 18.0),
                          ),
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
    );
  }

  // ===== PAGINATION =====
  Widget _buildPagination(
    BuildContext context,
    int totalPages,
    int totalFiltered,
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color outlineVariant,
    Color surfaceContainerLow,
    Color cardBg,
  ) {
    final startItem = ((_model.currentPage - 1) * _model.itemsPerPage) + 1;
    final endItem = (startItem + _model.itemsPerPage - 1).clamp(0, totalFiltered);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border(top: BorderSide(color: outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            totalFiltered > 0
                ? 'Showing $startItem to $endItem of $totalFiltered entries'
                : 'No entries to show',
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: outline,
            ),
          ),
          if (totalPages > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Previous
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: _model.currentPage > 1
                        ? () => safeSetState(() => _model.currentPage--)
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 16.0,
                        color: _model.currentPage > 1 ? onSurface : outline,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.0),
                ..._buildPageNumbers(totalPages, primaryBlue, onSurface, onSurfaceVariant),
                SizedBox(width: 4.0),
                // Next
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4.0),
                    onTap: _model.currentPage < totalPages
                        ? () => safeSetState(() => _model.currentPage++)
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 16.0,
                        color: _model.currentPage < totalPages ? onSurface : outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages, Color primaryBlue, Color onSurface, Color onSurfaceVariant) {
    List<Widget> pages = [];
    int current = _model.currentPage;
    int start = (current - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    if (end - start < 4) start = (end - 4).clamp(1, totalPages);

    for (int i = start; i <= end && i <= totalPages; i++) {
      final isCurrent = i == current;
      pages.add(Material(
        color: isCurrent ? primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: () => safeSetState(() => _model.currentPage = i),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: isCurrent
                ? BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(4.0))
                : null,
            child: Text(
              '$i',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
                color: isCurrent ? Colors.white : onSurfaceVariant,
              ),
            ),
          ),
        ),
      ));
    }

    if (end < totalPages) {
      pages.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('...', style: TextStyle(fontFamily: kAppFontFamily, fontSize: 12.0, color: onSurfaceVariant)),
      ));
    }

    return pages;
  }

  // ===== CARD =====
  Widget _buildGlassCard({required Widget child, required Color cardBg, required Color outlineVariant}) {
    // Using Container instead of Card — Container reliably responds to
    // CrossAxisAlignment.stretch constraints from IntrinsicHeight Row,
    // guaranteeing all cards in the same row have exactly the same height.
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: child,
      ),
    );
  }

  // ===== SPARKLINE =====
  Widget _buildSparkline(Color primaryBlue) {
    final heights = [0.3, 0.45, 0.4, 0.6, 0.55, 0.8, 1.0];
    return Row(
      children: heights.map((h) {
        return Expanded(
          child: Container(
            height: 40.0 * h,
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: h),
              borderRadius: BorderRadius.vertical(top: Radius.circular(2.0)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===== FORMAT NUMBER =====
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
