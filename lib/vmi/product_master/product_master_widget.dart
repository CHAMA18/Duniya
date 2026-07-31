import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:typed_data';
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

  // ── Duniya Purple design tokens ──
  static const Color _duniyaPurple = Color(0xFF9900FF);
  static const Color _duniyaPurpleDark = Color(0xFF7C3AED);
  static const Color _duniyaPurpleDeep = Color(0xFF6D28D9);
  static const Color _duniyaPurpleLight = Color(0xFFF3F0FF);
  static const Color _navy900 = Color(0xFF0A192F);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _surface = Color(0xFFF8F9FF);
  static const Color _surfaceContainerLow = Color(0xFFF3F0FF);
  static const Color _surfaceContainerHigh = Color(0xFFE9D5FF);
  static const Color _surfaceContainerHighest = Color(0xFFDDD6FE);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF434656);
  static const Color _outline = Color(0xFF737688);
  static const Color _outlineVariant = Color(0xFFC3C5D9);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _primaryFixed = Color(0xFFF3E8FF);

  // Category filter state
  String _selectedCategory = 'All Products';

  final List<Map<String, String>> _categories = [
    {'label': 'All Products', 'icon': 'category'},
    {'label': 'Prescription (Rx)', 'icon': 'prescriptions'},
    {'label': 'Over-the-Counter', 'icon': 'medication'},
    {'label': 'Supplements', 'icon': 'fitness_center'},
    {'label': 'Medical Supplies', 'icon': 'medical_services'},
  ];

  // Map Firestore categories to filter categories
  String _mapToFilterCategory(String? firestoreCategory) {
    if (firestoreCategory == null) return 'Other';
    final cat = firestoreCategory.toLowerCase();
    if (cat.contains('antibiotic') || cat.contains('cardiovascular') ||
        cat.contains('respiratory') || cat.contains('antimalarial')) {
      return 'Prescription (Rx)';
    }
    if (cat.contains('analgesic') || cat.contains('antipyretic')) {
      return 'Over-the-Counter';
    }
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return 'Supplements';
    }
    if (cat.contains('dermatology') || cat.contains('supply') ||
        cat.contains('medical')) {
      return 'Medical Supplies';
    }
    return 'Other';
  }

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

  /// Returns the appropriate icon for a product based on its category/dosage
  IconData _getProductIcon(ProductMasterRecord product) {
    final cat = (product.category ?? '').toLowerCase();
    final dosage = (product.dosageForm ?? '').toLowerCase();
    if (cat.contains('antibiotic') || dosage.contains('capsule')) {
      return Icons.medication;
    }
    if (cat.contains('vaccine') || dosage.contains('injection')) {
      return Icons.vaccines;
    }
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return Icons.fitness_center;
    }
    if (cat.contains('dermatology') || dosage.contains('cream')) {
      return Icons.healing;
    }
    if (dosage.contains('tablet') || dosage.contains('pill')) {
      return Icons.grid_view;
    }
    return Icons.medication_outlined;
  }

  /// Returns a background tint color for product icon containers based on category
  Color _getProductIconBg(ProductMasterRecord product) {
    final cat = (product.category ?? '').toLowerCase();
    if (cat.contains('antibiotic')) {
      return _duniyaPurple.withValues(alpha: 0.08);
    }
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return const Color(0xFF7C3AED).withValues(alpha: 0.08);
    }
    if (cat.contains('analgesic') || cat.contains('antipyretic')) {
      return const Color(0xFFD97706).withValues(alpha: 0.08);
    }
    return _duniyaPurple.withValues(alpha: 0.06);
  }

  Color _getProductIconFg(ProductMasterRecord product) {
    final cat = (product.category ?? '').toLowerCase();
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return const Color(0xFF7C3AED);
    }
    return _duniyaPurple;
  }

  /// Builds the glass-panel search/filter bar
  Widget _buildSearchFilterBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _navy900.withValues(alpha: 0.05),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.2),
            BlendMode.srcOver,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar with barcode scanner icon
                Container(
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: _outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: _onSurfaceVariant,
                          size: 22.0,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _model.searchTextController,
                          focusNode: _model.searchFocusNode,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: _onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Scan barcode or search by generic name, brand, or SKU...',
                            hintStyle: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: _onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          onChanged: (value) => safeSetState(() {}),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: TextButton(
                          onPressed: () => _showAddProductDialog(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Advanced',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: _duniyaPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                // Category filter buttons (horizontal scroll)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['label'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _buildCategoryButton(
                          label: cat['label']!,
                          isSelected: isSelected,
                          onTap: () =>
                              safeSetState(() => _selectedCategory = cat['label']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single category filter button
  Widget _buildCategoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? _duniyaPurple : _surface,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : Border.all(color: _outlineVariant, width: 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _duniyaPurple.withValues(alpha: 0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : _onSurface,
          ),
        ),
      ),
    );
  }

  /// Builds a single product card (glass-panel style)
  Widget _buildProductCard(ProductMasterRecord product) {
    // Determine stock status
    final minStock = product.minimumStockLevel;
    final isLowStock = minStock > 0 && minStock <= 10;
    final stockLabel = isLowStock ? 'Low: $minStock left' : '$minStock in stock';
    final stockBgColor =
        isLowStock ? _errorContainer : _surfaceContainerHigh;
    final stockTextColor =
        isLowStock ? _errorColor : _duniyaPurple;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: _navy900.withValues(alpha: 0.05),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            // Navigate to product detail or show detail dialog
            _showProductDetailDialog(context, product);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stock badge (top-right)
                Stack(
                  children: [
                    // Product icon area
                    Container(
                      height: 120.0,
                      decoration: BoxDecoration(
                        color: _surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Container(
                          width: 56.0,
                          height: 56.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getProductIconBg(product),
                          ),
                          child: Icon(
                            _getProductIcon(product),
                            color: _getProductIconFg(product),
                            size: 28.0,
                          ),
                        ),
                      ),
                    ),
                    // Stock badge
                    Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: stockBgColor,
                          borderRadius: BorderRadius.circular(9999.0),
                        ),
                        child: Text(
                          stockLabel,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.01,
                            height: 1.0,
                            color: stockTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                // Product name
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01,
                    height: 1.5,
                    color: _onSurface,
                  ),
                ),
                // Product description (dosage + pack size)
                Text(
                  '${product.dosageForm ?? '-'} • ${product.packSize ?? '-'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: _onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // Price + Add button row
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: _outlineVariant.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ZMK ${product.sellingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.01,
                          height: 1.0,
                          color: _onSurface,
                        ),
                      ),
                      SizedBox(
                        width: 32.0,
                        height: 32.0,
                        child: Material(
                          color: _surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(9999.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9999.0),
                            onTap: () => _showAddProductDialog(context),
                            child: Icon(
                              Icons.add,
                              size: 16.0,
                              color: _duniyaPurple,
                            ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 991;
    final isTablet = screenWidth >= 600 && screenWidth < 991;

    // Grid columns based on screen width
    int gridColumns = 2;
    if (isDesktop) {
      gridColumns = 4;
    } else if (isTablet) {
      gridColumns = 3;
    }

    return Title(
        title: 'Product Catalogue',
        color: _duniyaPurpleDeep,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: _background,
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
                  // Sidebar (desktop/tablet only)
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
                  // Main content area
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top nav
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
                        // Content body
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row + Add Product button
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Product Catalogue',
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.02,
                                            color: _navy900,
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          'Browse and manage your product master data',
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w400,
                                            color: _onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Download a pre-formatted Excel
                                        // template so users know exactly
                                        // which columns to include. The
                                        // template includes an example row
                                        // and an Instructions sheet.
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              downloadInventoryTemplate(),
                                          icon: const Icon(
                                              Icons.download_rounded,
                                              size: 18.0),
                                          label: Text(
                                            'Download Template',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: _duniyaPurple,
                                            side: BorderSide(
                                                color: _duniyaPurple
                                                    .withValues(alpha: 0.4),
                                                width: 1.4),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18.0,
                                                vertical: 12.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        OutlinedButton.icon(
                                          onPressed: () =>
                                              _importFromSpreadsheet(context),
                                          icon: const Icon(
                                              Icons.upload_file_rounded,
                                              size: 18.0),
                                          label: Text(
                                            'Import Excel',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: _duniyaPurple,
                                            side: BorderSide(
                                                color: _duniyaPurple
                                                    .withValues(alpha: 0.4),
                                                width: 1.4),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18.0,
                                                vertical: 12.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showAddProductDialog(context),
                                          icon:
                                              const Icon(Icons.add, size: 18.0),
                                          label: Text(
                                            'Add Product',
                                            style: TextStyle(
                                              fontFamily: 'Satoshi',
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _duniyaPurple,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 12.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),

                                // Search & Filter bar (glass-panel)
                                _buildSearchFilterBar(),
                                const SizedBox(height: 16.0),

                                // Product Grid
                                Expanded(
                                  child: StreamBuilder<
                                      List<ProductMasterRecord>>(
                                    stream: queryProductMasterRecord(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SpinKitRing(
                                            color: _duniyaPurple,
                                            size: 40.0,
                                          ),
                                        );
                                      }

                                      List<ProductMasterRecord> products =
                                          snapshot.data!;

                                      // Filter by search
                                      String? search = _model
                                          .searchTextController?.text
                                          .toLowerCase();
                                      if (search != null &&
                                          search.isNotEmpty) {
                                        products = products
                                            .where((p) =>
                                                p.name.toLowerCase().contains(
                                                    search) ||
                                                (p.genericName ?? '')
                                                    .toLowerCase()
                                                    .contains(search) ||
                                                (p.brandName ?? '')
                                                    .toLowerCase()
                                                    .contains(search) ||
                                                (p.sku)
                                                    .toLowerCase()
                                                    .contains(search))
                                            .toList();
                                      }

                                      // Filter by category
                                      if (_selectedCategory !=
                                          'All Products') {
                                        products = products
                                            .where((p) =>
                                                _mapToFilterCategory(
                                                    p.category) ==
                                                _selectedCategory)
                                            .toList();
                                      }

                                      if (products.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 80.0,
                                                height: 80.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _surfaceContainerLow,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .medication_liquid_outlined,
                                                  size: 36.0,
                                                  color: _outline,
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Text(
                                                'No products found',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: _onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Try adjusting your search or add a new product',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: _onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        padding: const EdgeInsets.only(
                                            bottom: 24.0),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: gridColumns,
                                          crossAxisSpacing: 16.0,
                                          mainAxisSpacing: 16.0,
                                          childAspectRatio:
                                              isDesktop ? 0.72 : 0.68,
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          return _buildProductCard(
                                              products[index]);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Mobile bottom nav
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

  /// Show product detail dialog when a card is tapped
  void _showProductDetailDialog(
      BuildContext context, ProductMasterRecord product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
          actionsPadding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
          title: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getProductIconBg(product),
                ),
                child: Icon(
                  _getProductIcon(product),
                  color: _getProductIconFg(product),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: _navy900,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Generic Name', product.genericName ?? '-'),
              _detailRow('Brand', product.brandName ?? '-'),
              _detailRow('Strength', product.strength ?? '-'),
              _detailRow('Dosage Form', product.dosageForm ?? '-'),
              _detailRow('Pack Size', product.packSize ?? '-'),
              _detailRow('SKU', product.sku),
              _detailRow('Category', product.category ?? '-'),
              const Divider(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: _detailValueBox(
                        'Cost Price', 'ZMK ${product.costPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _detailValueBox('Selling Price',
                        'ZMK ${product.sellingPrice.toStringAsFixed(2)}'),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: _detailValueBox('Min Stock',
                        '${product.minimumStockLevel}'),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _detailValueBox(
                        'Reorder Level', '${product.reorderLevel}'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: _onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: _onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
                color: _onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailValueBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Excel / CSV Spreadsheet Import
  // ──────────────────────────────────────────────────────────────────────

  /// Column name aliases → normalized schema key. Supports many common
  /// spreadsheet headers so users don't have to match our schema exactly.
  static const Map<String, String> _columnAliases = {
    'name': 'Name',
    'product': 'Name',
    'product name': 'Name',
    'item': 'Name',
    'description': 'Name',
    'generic': 'GenericName',
    'generic name': 'GenericName',
    'genericname': 'GenericName',
    'brand': 'BrandName',
    'brand name': 'BrandName',
    'brandname': 'BrandName',
    'manufacturer': 'BrandName',
    'strength': 'Strength',
    'concentration': 'Strength',
    'dosage': 'DosageForm',
    'dosage form': 'DosageForm',
    'dosageform': 'DosageForm',
    'form': 'DosageForm',
    'pack': 'PackSize',
    'pack size': 'PackSize',
    'packsize': 'PackSize',
    'unit': 'UnitOfMeasure',
    'uom': 'UnitOfMeasure',
    'unit of measure': 'UnitOfMeasure',
    'sku': 'SKU',
    'code': 'SKU',
    'barcode': 'SKU',
    'category': 'Category',
    'type': 'Category',
    'supplier': 'Supplier',
    'vendor': 'Supplier',
    'cost': 'CostPrice',
    'cost price': 'CostPrice',
    'costprice': 'CostPrice',
    'buy price': 'CostPrice',
    'selling': 'SellingPrice',
    'selling price': 'SellingPrice',
    'sellingprice': 'SellingPrice',
    'price': 'SellingPrice',
    'retail': 'SellingPrice',
    'minimum stock': 'MinimumStockLevel',
    'min stock': 'MinimumStockLevel',
    'minimumstocklevel': 'MinimumStockLevel',
    'reorder': 'ReorderLevel',
    'reorder level': 'ReorderLevel',
    'reorderlevel': 'ReorderLevel',
  };

  String? _resolveColumn(String? raw) {
    if (raw == null) return null;
    final key = raw.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _columnAliases[key] ?? _columnAliases[key.replaceAll(r' ', '')];
  }

  double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final cleaned = v
        .toString()
        .replaceAll(RegExp(r'[^0-9.\-]'), '')
        .trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  int? _parseInt(dynamic v) {
    final d = _parseDouble(v);
    return d?.round();
  }

  String? _parseString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Entry point for the Import Excel button.
  Future<void> _importFromSpreadsheet(BuildContext context) async {
    logFirebaseEvent('PRODUCT_CATALOGUE_ImportExcel_ON_TAP');

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled — no error toast.
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes ??
          (file.path != null
              ? await _readFileBytes(file.path!)
              : null);

      if (bytes == null) {
        _showImportToast(
          context,
          success: false,
          message: 'Could not read the selected file.',
        );
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      List<List<dynamic>> rows;

      if (ext == 'csv') {
        final decoded = utf8.decode(bytes, allowMalformed: true);
        rows = const CsvToListConverter(
          eol: '\n',
          shouldParseNumbers: false,
        ).convert(decoded);
      } else {
        // xlsx / xls
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables.keys.isEmpty
            ? null
            : excel.tables[excel.tables.keys.first];
        if (sheet == null) {
          _showImportToast(
            context,
            success: false,
            message: 'The spreadsheet appears to be empty.',
          );
          return;
        }
        rows = sheet.rows
            .map((row) => row.map((cell) => cell?.value).toList())
            .toList();
      }

      if (rows.isEmpty) {
        _showImportToast(
          context,
          success: false,
          message: 'No rows found in the spreadsheet.',
        );
        return;
      }

      // Build column index map from header row.
      final header = rows.first;
      final colIndex = <String, int>{};
      for (var i = 0; i < header.length; i++) {
        final resolved = _resolveColumn(header[i]?.toString());
        if (resolved != null && !colIndex.containsKey(resolved)) {
          colIndex[resolved] = i;
        }
      }

      String? cellVal(List<dynamic> row, String key) {
        final idx = colIndex[key];
        if (idx == null || idx >= row.length) return null;
        return _parseString(row[idx]);
      }

      // Confirm with the user before writing.
      final dataRows = rows.skip(1).where((r) {
        // Skip fully empty rows.
        return r.any((c) =>
            c != null && c.toString().trim().isNotEmpty);
      }).toList();

      if (dataRows.isEmpty) {
        _showImportToast(
          context,
          success: false,
          message: 'No product rows found after the header.',
        );
        return;
      }

      final confirmed = await _showImportConfirmDialog(
        context,
        fileName: file.name,
        rowCount: dataRows.length,
        detectedColumns: colIndex.keys.toList(),
      );

      if (!confirmed) return;

      // Show a progress overlay.
      _showImportProgressDialog(context, total: dataRows.length);

      int imported = 0;
      int skipped = 0;
      final batch = ProductMasterRecord.collection.firestore.batch();
      final now = DateTime.now();

      for (final row in dataRows) {
        final name = cellVal(row, 'Name');
        final sku = cellVal(row, 'SKU');
        // Name + SKU are required to match the manual add form.
        if (name == null || name.isEmpty || sku == null || sku.isEmpty) {
          skipped++;
          continue;
        }

        batch.set(
          ProductMasterRecord.collection.doc(),
          createProductMasterRecordData(
            name: name,
            genericName: cellVal(row, 'GenericName'),
            brandName: cellVal(row, 'BrandName'),
            strength: cellVal(row, 'Strength'),
            dosageForm: cellVal(row, 'DosageForm'),
            packSize: cellVal(row, 'PackSize'),
            unitOfMeasure: cellVal(row, 'UnitOfMeasure'),
            sku: sku,
            category: cellVal(row, 'Category'),
            supplier: cellVal(row, 'Supplier'),
            costPrice: _parseDouble(_rawCell(row, colIndex, 'CostPrice')),
            sellingPrice: _parseDouble(_rawCell(row, colIndex, 'SellingPrice')),
            minimumStockLevel:
                _parseInt(_rawCell(row, colIndex, 'MinimumStockLevel')),
            reorderLevel: _parseInt(_rawCell(row, colIndex, 'ReorderLevel')),
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
        imported++;
      }

      await batch.commit();

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      _showImportToast(
        context,
        success: true,
        message: imported == 0
            ? 'No rows imported (each row needs a Name and SKU).'
            : 'Imported $imported product${imported == 1 ? '' : 's'}'
                '${skipped > 0 ? ' · $skipped skipped' : ''}.',
      );
    } catch (e) {
      if (mounted) {
        // Dismiss progress dialog if open.
        Navigator.of(context, rootNavigator: true).maybePop();
        _showImportToast(
          context,
          success: false,
          message: 'Import failed: ${e.toString()}',
        );
      }
    }
  }

  dynamic _rawCell(
    List<dynamic> row,
    Map<String, int> colIndex,
    String key,
  ) {
    final idx = colIndex[key];
    if (idx == null || idx >= row.length) return null;
    return row[idx];
  }

  Future<Uint8List> _readFileBytes(String path) async {
    // file_picker on web provides bytes directly; this is a fallback.
    throw UnsupportedError('File bytes are required for web import.');
  }

  void _showImportToast(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: success ? _duniyaPurple : _errorColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  void _showImportProgressDialog(BuildContext context, {required int total}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SpinKitRing(
                    color: _duniyaPurple,
                    size: 48.0,
                    lineWidth: 3.0,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Importing products…',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: _navy900,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    'Processing $total row${total == 1 ? '' : 's'} from your spreadsheet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      color: _onSurfaceVariant,
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

  Future<bool> _showImportConfirmDialog(
    BuildContext context, {
    required String fileName,
    required int rowCount,
    required List<String> detectedColumns,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _duniyaPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.table_view_rounded,
                          color: _duniyaPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Confirm Import',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: _navy900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'File: $fileName',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$rowCount product row${rowCount == 1 ? '' : 's'} will be added to your catalogue.',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected columns (${detectedColumns.length})',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            color: _onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: detectedColumns
                              .map(
                                (c) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _outlineVariant,
                                    ),
                                  ),
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                      color: _onSurface,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: _onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Each row needs a Name and SKU to be imported.',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11.5,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _onSurfaceVariant,
                          side: BorderSide(
                              color: _outlineVariant, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22.0, vertical: 13.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          'Import $rowCount',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _duniyaPurple,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: _duniyaPurple.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 13.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // ── World-Class Add Product Dialog ──
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

    final isWide = MediaQuery.sizeOf(context).width > 700;

    showDialog(
      context: context,
      barrierColor: Color(0xFF0A192F).withValues(alpha: 0.6),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 720 : double.infinity,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.92,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: _duniyaPurpleDeep.withValues(alpha: 0.15),
                      blurRadius: 60.0,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Gradient Header ──
                      _buildDialogGradientHeader(),

                      // ── Form Body ──
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section: Product Identity
                              _buildSectionLabel('Product Identity', Icons.tag_rounded),
                              const SizedBox(height: 12.0),
                              _buildPremiumField(
                                controller: _model.nameTextController!,
                                label: 'Product Name',
                                hint: 'e.g. Amoxicillin 500mg',
                                icon: Icons.medication_rounded,
                                isRequired: true,
                              ),
                              const SizedBox(height: 14.0),
                              Row(children: [
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.genericNameTextController!,
                                    label: 'Generic Name',
                                    hint: 'e.g. Amoxicillin',
                                    icon: Icons.science_rounded,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.brandNameTextController!,
                                    label: 'Brand Name',
                                    hint: 'e.g. Amoxil',
                                    icon: Icons.branding_watermark_rounded,
                                  ),
                                ),
                              ]),

                              const SizedBox(height: 24.0),

                              // Section: Formulation Details
                              _buildSectionLabel('Formulation', Icons.grain_rounded),
                              const SizedBox(height: 12.0),
                              Row(children: [
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.strengthTextController!,
                                    label: 'Strength',
                                    hint: 'e.g. 500mg',
                                    icon: Icons.fitness_center_rounded,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.dosageFormTextController!,
                                    label: 'Dosage Form',
                                    hint: 'e.g. Capsule',
                                    icon: Icons.category_rounded,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 14.0),
                              Row(children: [
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.packSizeTextController!,
                                    label: 'Pack Size',
                                    hint: 'e.g. 100',
                                    icon: Icons.inventory_2_rounded,
                                    isNumber: true,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.skuTextController!,
                                    label: 'SKU',
                                    hint: 'e.g. AMX-500-CAP',
                                    icon: Icons.qr_code_rounded,
                                    isRequired: true,
                                  ),
                                ),
                              ]),

                              const SizedBox(height: 14.0),

                              // Category - Premium Dropdown
                              _buildPremiumCategoryDropdown(setDialogState),

                              const SizedBox(height: 24.0),

                              // Section: Pricing
                              _buildSectionLabel('Pricing', Icons.payments_rounded),
                              const SizedBox(height: 12.0),
                              Row(children: [
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.costPriceTextController!,
                                    label: 'Cost Price',
                                    hint: '0.00',
                                    icon: Icons.arrow_downward_rounded,
                                    isNumber: true,
                                    prefix: 'ZMK',
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.sellingPriceTextController!,
                                    label: 'Selling Price',
                                    hint: '0.00',
                                    icon: Icons.arrow_upward_rounded,
                                    isNumber: true,
                                    prefix: 'ZMK',
                                  ),
                                ),
                              ]),

                              // Margin indicator
                              const SizedBox(height: 10.0),
                              _buildMarginIndicator(),

                              const SizedBox(height: 24.0),

                              // Section: Inventory Control
                              _buildSectionLabel('Inventory Control', Icons.warehouse_rounded),
                              const SizedBox(height: 12.0),
                              Row(children: [
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.minStockTextController!,
                                    label: 'Min Stock Level',
                                    hint: '0',
                                    icon: Icons.trending_down_rounded,
                                    isNumber: true,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: _buildPremiumField(
                                    controller: _model.reorderLevelTextController!,
                                    label: 'Reorder Level',
                                    hint: '0',
                                    icon: Icons.autorenew_rounded,
                                    isNumber: true,
                                  ),
                                ),
                              ]),

                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),

                      // ── Action Bar ──
                      _buildDialogActionBar(dialogContext),
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

  // ── Gradient header for dialog ──
  Widget _buildDialogGradientHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _duniyaPurple,
            _duniyaPurpleDark,
            _duniyaPurpleDeep,
          ],
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0),
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 26.0),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Fill in the product details to add to your catalogue',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
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

  // ── Section label with icon ──
  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28.0,
          height: 28.0,
          decoration: BoxDecoration(
            color: _duniyaPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 15.0, color: _duniyaPurple),
        ),
        const SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
            color: _duniyaPurpleDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Container(
            height: 1.0,
            color: _outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  // ── Premium text field with icon, hint, and validation ──
  Widget _buildPremiumField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool isNumber = false,
    bool isRequired = false,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: _onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 3.0),
              Text(
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
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: _onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              color: _outline,
            ),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                    child: Icon(icon, size: 18.0, color: _duniyaPurple.withValues(alpha: 0.6)),
                  )
                : null,
            prefixIconConstraints: icon != null
                ? const BoxConstraints(minWidth: 42.0, minHeight: 0)
                : null,
            prefixText: prefix,
            prefixStyle: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: _duniyaPurpleDark,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFE),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _outlineVariant.withValues(alpha: 0.6), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _outlineVariant.withValues(alpha: 0.6), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: _duniyaPurple, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.2),
            ),
          ),
          onChanged: (_) => safeSetState(() {}),
        ),
      ],
    );
  }

  // ── Premium category dropdown ──
  Widget _buildPremiumCategoryDropdown(StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: _onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _model.dialogCategoryValue != null
                  ? _duniyaPurple.withValues(alpha: 0.4)
                  : _outlineVariant.withValues(alpha: 0.6),
              width: _model.dialogCategoryValue != null ? 1.5 : 1.0,
            ),
            color: const Color(0xFFFAFAFE),
          ),
          child: FlutterFlowDropDown<String>(
            controller: _model.dialogCategoryValueController ??=
                FormFieldController<String>(null),
            options: const [
              'Antibiotics',
              'Analgesics',
              'Antipyretics',
              'Antimalarials',
              'Vitamins',
              'Cardiovascular',
              'Respiratory',
              'Gastrointestinal',
              'Dermatology',
              'Other'
            ],
            onChanged: (val) {
              setDialogState(() => _model.dialogCategoryValue = val);
            },
            width: double.infinity,
            height: 48.0,
            textStyle: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: _model.dialogCategoryValue != null ? _onSurface : _outline,
            ),
            hintText: 'Select a category',
            fillColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderRadius: 12.0,
            elevation: 4,
            borderWidth: 0.0,
            margin: EdgeInsets.zero,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _duniyaPurple,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Live margin indicator ──
  Widget _buildMarginIndicator() {
    final cost = double.tryParse(_model.costPriceTextController?.text ?? '') ?? 0;
    final selling = double.tryParse(_model.sellingPriceTextController?.text ?? '') ?? 0;
    final margin = selling > 0 && cost > 0 ? ((selling - cost) / selling * 100) : 0.0;
    final hasData = cost > 0 && selling > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: hasData
            ? (margin >= 30
                ? const Color(0xFFECFDF5)
                : margin >= 15
                    ? Color(0xFFFFFBEB)
                    : margin > 0
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF5F3FF))
            : const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: hasData
              ? (margin >= 30
                  ? const Color(0xFFA7F3D0)
                  : margin >= 15
                      ? const Color(0xFFFDE68A)
                      : margin > 0
                          ? const Color(0xFFFECACA)
                          : _outlineVariant.withValues(alpha: 0.3))
              : _outlineVariant.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasData
                ? (margin >= 30
                    ? Icons.trending_up_rounded
                    : margin >= 15
                        ? Icons.trending_flat_rounded
                        : margin > 0
                            ? Icons.trending_down_rounded
                            : Icons.info_outline_rounded)
                : Icons.info_outline_rounded,
            size: 16.0,
            color: hasData
                ? (margin >= 30
                    ? const Color(0xFF059669)
                    : margin >= 15
                        ? const Color(0xFFD97706)
                        : margin > 0
                            ? const Color(0xFFDC2626)
                            : _onSurfaceVariant)
                : _onSurfaceVariant,
          ),
          const SizedBox(width: 8.0),
          Text(
            hasData
                ? 'Profit Margin: ${margin.toStringAsFixed(1)}%  (ZMK ${(selling - cost).toStringAsFixed(2)} per unit)'
                : 'Enter cost and selling price to see margin',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: hasData
                  ? (margin >= 30
                      ? const Color(0xFF059669)
                      : margin >= 15
                          ? const Color(0xFFD97706)
                          : margin > 0
                              ? const Color(0xFFDC2626)
                              : _onSurfaceVariant)
                  : _onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action bar with premium buttons ──
  Widget _buildDialogActionBar(BuildContext dialogContext) {
    final nameEmpty = _model.nameTextController?.text.isEmpty ?? true;
    final skuEmpty = _model.skuTextController?.text.isEmpty ?? true;
    final canSave = !nameEmpty && !skuEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 12.0, 28.0, 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _outlineVariant.withValues(alpha: 0.5), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Required fields hint
          Expanded(
            child: Text(
              canSave ? 'Ready to save' : 'Product Name and SKU are required',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: canSave ? const Color(0xFF059669) : _onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Cancel button
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: OutlinedButton.styleFrom(
              foregroundColor: _onSurfaceVariant,
              side: BorderSide(color: _outlineVariant, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 13.0),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Save button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: canSave
                  ? () async {
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
                              costPrice: double.tryParse(
                                  _model.costPriceTextController?.text ?? '0'),
                              sellingPrice: double.tryParse(
                                  _model.sellingPriceTextController?.text ?? '0'),
                              minimumStockLevel: int.tryParse(
                                  _model.minStockTextController?.text ?? '0'),
                              reorderLevel: int.tryParse(
                                  _model.reorderLevelTextController?.text ?? '0'),
                              isActive: true,
                              createdAt: getCurrentTimestamp,
                              updatedAt: getCurrentTimestamp,
                            ),
                          );
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
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.0),
                              const SizedBox(width: 10.0),
                              Text('Product added successfully'),
                            ],
                          ),
                          backgroundColor: _duniyaPurple,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check_rounded, size: 18.0),
              label: Text(
                'Save Product',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canSave ? _duniyaPurple : _outlineVariant,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _outlineVariant.withValues(alpha: 0.4),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                elevation: canSave ? 4.0 : 0,
                shadowColor: _duniyaPurple.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 13.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
