import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
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
    final role = valueOrDefault(currentUserDocument?.role, '');
    if (role == 'Owner') {
      return currentUserReference;
    } else {
      return currentUserDocument?.ownerRef;
    }
  }

  /// Navigate to category page with role-based logic
  Future<void> _navigateToCategory(String category) async {
    var shouldSetState = false;
    if (valueOrDefault(currentUserDocument?.role, '') == 'Owner') {
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

  /// Navigate to inventory details
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

    // Design tokens
    final primaryBlue = theme.primary;
    final primaryContainer = theme.primary.withOpacity(0.1);
    final secondaryTeal = theme.secondary;
    final surfaceBg = isDark ? const Color(0xFF1A1C2C) : const Color(0xFFF8F9FF);
    final onSurface = isDark ? const Color(0xFFEAF1FF) : const Color(0xFF0B1C30);
    final onSurfaceVariant = isDark ? const Color(0xFFC3C5D9) : const Color(0xFF434656);
    final outline = isDark ? const Color(0xFF8E90A0) : const Color(0xFF737688);
    final outlineVariant = isDark ? const Color(0xFF444656) : const Color(0xFFC3C5D9);
    final surfaceContainerLow = isDark ? const Color(0xFF252738) : const Color(0xFFEFF4FF);
    final surfaceContainerHighest = isDark ? const Color(0xFF333550) : const Color(0xFFD3E4FE);
    final glassBg = isDark ? const Color(0xFF252738).withOpacity(0.8) : Colors.white.withOpacity(0.8);
    final surfaceDim = isDark ? const Color(0xFF111328) : const Color(0xFFCBDBF5);

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
                                      glassBg,
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
                                      glassBg,
                                    ),
                                    const SizedBox(height: 24.0),

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
                                      glassBg,
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
                                      glassBg,
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
                fontFamily: 'Geist',
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
                fontFamily: 'Inter',
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
                          fontFamily: 'Geist',
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
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: outlineVariant.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_outlined, color: onSurface, size: 18.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Export',
                        style: TextStyle(
                          fontFamily: 'Inter',
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
    Color glassBg,
    Color surfaceDim,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 3;
        if (constraints.maxWidth < 900) columns = 2;
        if (constraints.maxWidth < 600) columns = 1;

        return Wrap(
          spacing: 24.0,
          runSpacing: 24.0,
          children: [
            // Card 1: Total Stock Value
            SizedBox(
              width: (constraints.maxWidth - (columns - 1) * 24.0) / columns,
              child: _buildGlassCard(
                glassBg: glassBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: primaryContainer,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(Icons.payments_outlined, color: primaryBlue, size: 20.0),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Total Stock Value',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '\$${_formatNumber(totalStockValue)}',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        height: 1.2,
                        letterSpacing: -0.02,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC2E8FF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.trending_up, color: secondaryTeal, size: 14.0),
                              SizedBox(width: 2.0),
                              Text(
                                '+2.4%',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'vs last month',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    _buildSparkline(primaryBlue),
                  ],
                ),
              ),
            ),
            // Card 2: Items Near Expiry
            SizedBox(
              width: (constraints.maxWidth - (columns - 1) * 24.0) / columns,
              child: _buildGlassCard(
                glassBg: glassBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: primaryContainer,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(Icons.warning_amber_rounded, color: primaryBlue, size: 20.0),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Items Near Expiry',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$nearExpiryCount',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 28.0,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(width: 4.0),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'SKUs',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Requires Action',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 8.0),
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(color: primaryBlue.withOpacity(0.5), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 8.0),
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(color: outlineVariant.withOpacity(0.3), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 8.0),
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(color: outlineVariant.withOpacity(0.3), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Next 30 Days',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: outline,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Card 3: Active Stock Items
            SizedBox(
              width: (constraints.maxWidth - (columns - 1) * 24.0) / columns,
              child: _buildGlassCard(
                glassBg: glassBg,
                outlineVariant: outlineVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C1FD).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(Icons.inventory_outlined, color: secondaryTeal, size: 20.0),
                        ),
                        SizedBox(width: 12.0),
                        Text(
                          'Active Stock Items',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '$totalSKUs',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '$lowStockCount low stock alerts',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: outline,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: LinearProgressIndicator(
                        value: totalSKUs > 0 ? (totalSKUs - lowStockCount) / totalSKUs : 0.0,
                        backgroundColor: surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00C1FD)),
                        minHeight: 6.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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
    Color glassBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                      fontFamily: 'Inter',
                      fontSize: 13.0,
                      color: outline,
                    ),
                    prefixIcon: Icon(Icons.search, color: outline, size: 18.0),
                    filled: true,
                    fillColor: surfaceContainerLow,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: outlineVariant.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: outlineVariant.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
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
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(color: primaryBlue.withOpacity(0.2)),
                            )
                          : null,
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'Inter',
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
                      border: Border.all(color: outlineVariant.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list, color: onSurfaceVariant, size: 16.0),
                        SizedBox(width: 4.0),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontFamily: 'Inter',
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
                  fontFamily: 'Inter',
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
                  border: Border.all(color: outlineVariant.withOpacity(0.3)),
                ),
                child: DropdownButton<String>(
                  value: _model.sortBy,
                  underline: SizedBox.shrink(),
                  isDense: true,
                  icon: Icon(Icons.expand_more, size: 16.0),
                  style: TextStyle(
                    fontFamily: 'Inter',
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

  // ===== DATA TABLE =====
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
    Color glassBg,
    Color surfaceDim,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                color: surfaceContainerLow.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(color: outlineVariant.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Product & Manufacturer',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
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
                          fontFamily: 'JetBrains Mono',
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
                          fontFamily: 'JetBrains Mono',
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
                          fontFamily: 'JetBrains Mono',
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
                          fontFamily: 'JetBrains Mono',
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
                          fontFamily: 'JetBrains Mono',
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
                        fontFamily: 'Inter',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Try adjusting your search or filter criteria',
                      style: TextStyle(
                        fontFamily: 'Inter',
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
      statusBgColor = primaryBlue.withOpacity(0.1);
    } else if (isLowStock) {
      statusColor = primaryBlue;
      statusBgColor = primaryBlue.withOpacity(0.1);
    } else {
      statusColor = secondaryTeal;
      statusBgColor = const Color(0xFF00C1FD).withOpacity(0.2);
    }

    // Progress bar color
    Color progressColor;
    if (stock.quantity <= 0) {
      progressColor = primaryBlue;
    } else if (stockPercent < 0.3) {
      progressColor = primaryBlue;
    } else {
      progressColor = const Color(0xFF00C1FD);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isOutOfStock ? primaryBlue.withOpacity(0.03) : Colors.white.withOpacity(0.95),
          border: Border(
            bottom: BorderSide(color: outlineVariant.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
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
                        color: surfaceDim.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: outlineVariant.withOpacity(0.3)),
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
                          Text(
                            stock.name.isNotEmpty ? stock.name : 'Unknown Product',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: onSurface.withOpacity(isOutOfStock ? 0.6 : 1.0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            '${stock.manufacturer.isNotEmpty ? stock.manufacturer : "Unknown"} • ${stock.category.isNotEmpty ? stock.category : "Uncategorized"}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        fontFamily: 'Inter',
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
                          fontFamily: 'JetBrains Mono',
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
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: isLowStock || isOutOfStock ? primaryBlue : onSurface,
                          ),
                        ),
                        Text(
                          'Max: ${stock.initialQuantity.toInt()}',
                          style: TextStyle(
                            fontFamily: 'Inter',
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
                        backgroundColor: surfaceDim.withOpacity(0.3),
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
                      '\$${stock.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'Val: \$${(stock.price * stock.quantity.toDouble()).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
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
                      border: isOutOfStock ? Border.all(color: primaryBlue.withOpacity(0.2)) : null,
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
                            fontFamily: 'Inter',
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            child: Text(
                              'Reorder',
                              style: TextStyle(
                                fontFamily: 'Geist',
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
    Color glassBg,
  ) {
    final startItem = ((_model.currentPage - 1) * _model.itemsPerPage) + 1;
    final endItem = (startItem + _model.itemsPerPage - 1).clamp(0, totalFiltered);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border(top: BorderSide(color: outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            totalFiltered > 0
                ? 'Showing $startItem to $endItem of $totalFiltered entries'
                : 'No entries to show',
            style: TextStyle(
              fontFamily: 'Inter',
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
                        border: Border.all(color: outlineVariant.withOpacity(0.5)),
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
                        border: Border.all(color: outlineVariant.withOpacity(0.5)),
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
                fontFamily: 'Inter',
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
        child: Text('...', style: TextStyle(fontFamily: 'Inter', fontSize: 12.0, color: onSurfaceVariant)),
      ));
    }

    return pages;
  }

  // ===== GLASS CARD =====
  Widget _buildGlassCard({required Widget child, required Color glassBg, required Color outlineVariant}) {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: outlineVariant.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
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
              color: primaryBlue.withOpacity(h),
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
