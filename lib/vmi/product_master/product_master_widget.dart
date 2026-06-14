import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
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

  // Design tokens from the HTML source
  static const Color _clinicalBlue = Color(0xFF0052FF);
  static const Color _primaryDeep = Color(0xFF003EC7);
  static const Color _navy900 = Color(0xFF0A192F);
  static const Color _background = Color(0xFFF8F9FF);
  static const Color _surface = Color(0xFFF8F9FF);
  static const Color _surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color _surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color _surfaceContainerHighest = Color(0xFFD3E4FE);
  static const Color _onSurface = Color(0xFF0B1C30);
  static const Color _onSurfaceVariant = Color(0xFF434656);
  static const Color _outline = Color(0xFF737688);
  static const Color _outlineVariant = Color(0xFFC3C5D9);
  static const Color _errorColor = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _primaryFixed = Color(0xFFDDE1FF);

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
      return _clinicalBlue.withValues(alpha: 0.08);
    }
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return const Color(0xFF006688).withValues(alpha: 0.08);
    }
    if (cat.contains('analgesic') || cat.contains('antipyretic')) {
      return const Color(0xFFF59E0B).withValues(alpha: 0.08);
    }
    return _clinicalBlue.withValues(alpha: 0.06);
  }

  Color _getProductIconFg(ProductMasterRecord product) {
    final cat = (product.category ?? '').toLowerCase();
    if (cat.contains('vitamin') || cat.contains('supplement')) {
      return const Color(0xFF006688);
    }
    return _clinicalBlue;
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
                              color: _clinicalBlue,
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
          color: isSelected ? _clinicalBlue : _surface,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : Border.all(color: _outlineVariant, width: 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _clinicalBlue.withValues(alpha: 0.2),
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
        isLowStock ? _errorColor : _clinicalBlue;

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
                        '\$${product.sellingPrice.toStringAsFixed(2)}',
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
                              color: _clinicalBlue,
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
        color: _primaryDeep,
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
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showAddProductDialog(context),
                                      icon: const Icon(Icons.add, size: 18.0),
                                      label: Text(
                                        'Add Product',
                                        style: TextStyle(
                                          fontFamily: 'Satoshi',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _clinicalBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
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
                                            color: _clinicalBlue,
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
                        'Cost Price', '\$${product.costPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _detailValueBox('Selling Price',
                        '\$${product.sellingPrice.toStringAsFixed(2)}'),
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

  // Add Product Dialog (preserving backend logic)
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
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: _clinicalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.add_circle_outline,
                    color: _clinicalBlue, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Add Product',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: _navy900,
                ),
              ),
            ],
          ),
          content: Container(
            width: MediaQuery.sizeOf(context).width > 600
                ? 600
                : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                      _model.nameTextController!, 'Product Name *'),
                  const SizedBox(height: 10.0),
                  _buildDialogTextField(
                      _model.genericNameTextController!, 'Generic Name'),
                  const SizedBox(height: 10.0),
                  _buildDialogTextField(
                      _model.brandNameTextController!, 'Brand Name'),
                  const SizedBox(height: 10.0),
                  Row(children: [
                    Expanded(
                        child: _buildDialogTextField(
                            _model.strengthTextController!, 'Strength')),
                    const SizedBox(width: 10.0),
                    Expanded(
                        child: _buildDialogTextField(
                            _model.dosageFormTextController!, 'Dosage Form')),
                  ]),
                  const SizedBox(height: 10.0),
                  Row(children: [
                    Expanded(
                        child: _buildDialogTextField(
                            _model.packSizeTextController!, 'Pack Size')),
                    const SizedBox(width: 10.0),
                    Expanded(
                        child: _buildDialogTextField(
                            _model.skuTextController!, 'SKU *')),
                  ]),
                  const SizedBox(height: 10.0),
                  FlutterFlowDropDown<String>(
                    controller: _model.dialogCategoryValueController ??=
                        FormFieldController<String>(null),
                    options: [
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
                    onChanged: (val) =>
                        safeSetState(() => _model.dialogCategoryValue = val),
                    width: double.infinity,
                    height: 48.0,
                    textStyle: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: _onSurface,
                    ),
                    hintText: 'Category',
                    fillColor: _surface,
                    borderColor: _outlineVariant,
                    borderRadius: 10.0,
                    elevation: 2,
                    borderWidth: 1.0,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10.0),
                  Row(children: [
                    Expanded(
                        child: _buildDialogTextField(
                            _model.costPriceTextController!, 'Cost Price',
                            isNumber: true)),
                    const SizedBox(width: 10.0),
                    Expanded(
                        child: _buildDialogTextField(
                            _model.sellingPriceTextController!, 'Selling Price',
                            isNumber: true)),
                  ]),
                  const SizedBox(height: 10.0),
                  Row(children: [
                    Expanded(
                        child: _buildDialogTextField(
                            _model.minStockTextController!, 'Min Stock',
                            isNumber: true)),
                    const SizedBox(width: 10.0),
                    Expanded(
                        child: _buildDialogTextField(
                            _model.reorderLevelTextController!, 'Reorder Level',
                            isNumber: true)),
                  ]),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  color: _onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_model.nameTextController?.text.isEmpty ?? true) return;
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
                // Clear form
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
                    content: Text('Product added successfully'),
                    backgroundColor: _clinicalBlue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _clinicalBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: _onSurfaceVariant,
        ),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _outlineVariant, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _outlineVariant, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: _clinicalBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: _onSurface,
      ),
    );
  }
}
