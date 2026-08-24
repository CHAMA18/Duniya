import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'sales_vmi_model.dart';
export 'sales_vmi_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   POINT OF SALE — transactional sales & dispensing screen
///
///   Replaces the old dashboard + dialog approach with a direct POS:
///   left panel = product browser (search + tap-to-add grid),
///   right panel = cart with live total + one-tap checkout,
///   below = compact recent-sales strip.
/// ═══════════════════════════════════════════════════════════════
class SalesVMIWidget extends StatefulWidget {
  const SalesVMIWidget({super.key, this.pharmacy});

  final String? pharmacy;

  static String routeName = 'SalesVMI';
  static String routePath = '/salesVMI';

  @override
  State<SalesVMIWidget> createState() => _SalesVMIWidgetState();
}

class _SalesVMIWidgetState extends State<SalesVMIWidget> {
  late SalesVMIModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color _primary = Color(0xFFA100FF);
  static const Color _deep = Color(0xFF6A00D9);
  static const Color _light = Color(0xFFE8D5FF);
  static const Color _bg = Color(0xFFF8F5FF);
  static const Color _surface = Colors.white;
  static const Color _textDark = Color(0xFF1A0533);
  static const Color _textMuted = Color(0xFF7C6E93);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);
  static const Color _amber = Color(0xFFF59E0B);

  final _searchController = TextEditingController();
  final _patientController = TextEditingController();
  String _searchQuery = '';
  List<StockRecord> _stockItems = [];
  bool _stockLoaded = false;
  bool _completing = false;

  // ── Payment method selection ──
  // 'Cash' | 'Card' | 'Mobile Money'; for Mobile Money the provider
  // is one of 'Zamtel Money' | 'Airtel Money' | 'MTN Money'. Persisted
  // on the SaleRecordVMI (paymentMethod + mobileMoneyProvider).
  String _paymentMethod = 'Cash';
  String? _mobileMoneyProvider;

  /// Cart: same shape as the old _saleLineItems so the save logic
  /// (SaleRecordVMI, SaleItemVMI, StockMovement, stock decrement) is
  /// reused unchanged.
  final List<Map<String, dynamic>> _cart = [];

  double get _cartTotal =>
      _cart.fold(0.0, (sum, item) => sum + (item['total'] as double));
  int get _cartItems => _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SalesVMIModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'SalesVMI'});
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        _searchQuery = _searchController.text;
        safeSetState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Removed: an empty `safeSetState(() {})` before `_loadStock()`.
      // An empty setState on the first frame triggers a full widget-tree
      // rebuild right after mount — which re-fires any inline FutureBuilders
      // and produces a visible "flash" of the loading state. _loadStock()
      // calls safeSetState itself when the stock query completes, so the
      // empty setState here was redundant and harmful.
      _loadStock();
    });
  }

  Future<void> _loadStock() async {
    try {
      final ownerRef = AccessControl.networkWideQueryParent(context);
      final stocks = await queryStockRecordOnce(parent: ownerRef);
      stocks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (!mounted) return;
      safeSetState(() {
        _stockItems = stocks;
        _stockLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _stockLoaded = true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _patientController.dispose();
    _model.dispose();
    super.dispose();
  }

  // ── Cart actions ────────────────────────────────────────────

  void _addToCart(StockRecord stock) {
    final name = stock.name.trim();
    if (name.isEmpty) return;
    final existing = _cart.indexWhere((item) =>
        (item['productName'] as String).toLowerCase() == name.toLowerCase());
    if (existing >= 0) {
      final item = _cart[existing];
      final currentQty = (item['quantity'] as int);
      final newQty = currentQty + 1;
      // Clamp to available stock so users can't add more than what is on hand
      if (newQty > stock.quantity) {
        _toast(
            'Only ${stock.quantity} of "${name}" is available in stock.',
            isError: true);
        return;
      }
      final price = item['sellingPrice'] as double;
      _cart[existing] = {
        ...item,
        'quantity': newQty,
        'total': newQty * price,
      };
    } else {
      if (stock.quantity < 1) {
        _toast('"$name" is out of stock.', isError: true);
        return;
      }
      _cart.add({
        'productId': stock.reference,
        'productName': name,
        'quantity': 1,
        'sellingPrice': stock.price > 0 ? stock.price : 0.0,
        'total': stock.price > 0 ? stock.price : 0.0,
      });
    }
    safeSetState(() {});
  }

  void _changeQty(int index, int delta) {
    if (index < 0 || index >= _cart.length) return;
    final item = _cart[index];
    var qty = (item['quantity'] as int) + delta;
    if (qty < 1) {
      _cart.removeAt(index);
    } else {
      // Lookup the live stock record for this cart item — if the requested
      // qty exceeds what's on hand, clamp + warn (prevents stock going negative)
      final productName = (item['productName'] as String).toLowerCase();
      StockRecord? stockMatch;
      for (final s in _stockItems) {
        if (s.name.trim().toLowerCase() == productName) {
          stockMatch = s;
          break;
        }
      }
      if (stockMatch != null && qty > stockMatch.quantity) {
        _toast(
            'Only ${stockMatch.quantity} of "${item['productName']}" is available.',
            isError: true);
        return;
      }
      final price = item['sellingPrice'] as double;
      _cart[index] = {
        ...item,
        'quantity': qty,
        'total': qty * price,
      };
    }
    safeSetState(() {});
  }

  void _removeFromCart(int index) {
    _cart.removeAt(index);
    safeSetState(() {});
  }

  // ── Complete sale ──────────────────────────────────────────

  Future<void> _completeSale() async {
    if (_cart.isEmpty || _completing) return;

    // Payment validation — a Mobile Money sale must name its provider
    // before the transaction is committed.
    if (_paymentMethod == 'Mobile Money' && _mobileMoneyProvider == null) {
      _toast('Select the mobile money provider (Zamtel, Airtel or MTN).',
          isError: true);
      return;
    }
    safeSetState(() => _completing = true);

    try {
      DocumentReference? ownerRef;
      if (AccessControl.isPulseUser(context)) {
        ownerRef = currentUserReference;
      } else {
        ownerRef = AccessControl.networkWideQueryParent(context);
      }
      if (ownerRef == null) {
        _toast('Unable to identify your account.', isError: true);
        safeSetState(() => _completing = false);
        return;
      }

      // Pre-flight: re-validate stock availability for every cart item.
      // Refuse to commit the sale if any item's requested qty exceeds the
      // live stock on hand — prevents silent negative-stock writes.
      final stockByName = <String, StockRecord>{};
      for (final s in _stockItems) {
        final key = s.name.trim().toLowerCase();
        if (key.isNotEmpty && !stockByName.containsKey(key)) {
          stockByName[key] = s;
        }
      }
      for (final item in _cart) {
        final productName = (item['productName'] as String).trim();
        final soldQty = item['quantity'] as int;
        final stock = stockByName[productName.toLowerCase()];
        if (stock == null) {
          _toast(
              'No stock record found for "$productName". Sale aborted.',
              isError: true);
          safeSetState(() => _completing = false);
          return;
        }
        if (soldQty > stock.quantity) {
          _toast(
              'Only ${stock.quantity} of "$productName" is available. Sale aborted.',
              isError: true);
          safeSetState(() => _completing = false);
          return;
        }
      }

      final totalAmount = _cartTotal;

      // Create SaleVMI record
      final saleDoc = SaleRecordVMI.createDoc(ownerRef);
      await saleDoc.set(createSaleRecordVMIData(
        soldById: currentUserReference,
        saleDate: DateTime.now(),
        patientRef: _patientController.text.trim().isEmpty
            ? null
            : _patientController.text.trim(),
        totalAmount: totalAmount,
        // Payment capture — method is always set (defaults to Cash);
        // provider is only recorded for Mobile Money transactions.
        paymentMethod: _paymentMethod,
        mobileMoneyProvider:
            _paymentMethod == 'Mobile Money' ? _mobileMoneyProvider : null,
        createdAt: DateTime.now(),
      ));

      for (final item in _cart) {
        final itemDoc = SaleItemVMIRecord.createDoc(saleDoc);
        await itemDoc.set(createSaleItemVMIRecordData(
          productId: item['productId'] as DocumentReference?,
          quantity: item['quantity'] as int,
          sellingPrice: item['sellingPrice'] as double,
          total: item['total'] as double,
        ));

        final movementDoc = StockMovementRecord.createDoc(ownerRef);
        await movementDoc.set(createStockMovementRecordData(
          productId: item['productId'] as DocumentReference?,
          productName: (item['productName'] as String?)?.trim(),
          quantity: item['quantity'] as int,
          movementType: 'SOLD',
          recordedById: currentUserReference,
          createdAt: DateTime.now(),
        ));

        // Reduce stock — guaranteed non-null by pre-flight check above
        final productName = (item['productName'] as String).trim();
        final soldQty = item['quantity'] as int;
        final stockRef = stockByName[productName.toLowerCase()]!.reference;
        await stockRef.update({
          'Quantity': FieldValue.increment(-soldQty),
          'UpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Clear cart + reload stock
      _cart.clear();
      _patientController.clear();
      await _loadStock();
      if (!mounted) return;
      safeSetState(() => _completing = false);
      _toast('Sale completed — stock updated');
    } catch (_) {
      if (!mounted) return;
      safeSetState(() => _completing = false);
      _toast('Could not complete the sale. Please try again.', isError: true);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: isError ? _red : _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _fmtCurrency(double v) =>
      'K${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Point of Sale',
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
              child: const SideNavWidget(),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Row(
              children: [
                if (responsiveVisibility(
                    context: context, phone: false, tablet: false))
                  wrapWithModel(
                    model: _model.sideNavModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const SideNavWidget(),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      if (responsiveVisibility(
                          context: context,
                          tablet: false,
                          tabletLandscape: false,
                          desktop: false))
                        wrapWithModel(
                          model: _model.topNavModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const TopNavWidget(
                            openDrawer: null,
                          ),
                        ),
                      Expanded(child: _buildPosBody()),
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

  // ── POS body ────────────────────────────────────────────────

  Widget _buildPosBody() {
    final isWide = MediaQuery.sizeOf(context).width >= 1000;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildProductBrowser()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildCart()),
              ],
            )
          else
            Column(
              children: [
                _buildProductBrowser(),
                const SizedBox(height: 16),
                _buildCart(),
              ],
            ),
          const SizedBox(height: 20),
          _buildRecentSales(),
        ],
      ),
    );
  }

  // ── Header + KPI strip ─────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_deep, _primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.point_of_sale_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Point of Sale',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text('Record sales and dispense medicines instantly.',
                    style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12.5)),
              ],
            ),
          ),
          // Cart badge
          if (_cart.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_rounded,
                      color: _deep, size: 16),
                  const SizedBox(width: 6),
                  Text('$_cartItems item${_cartItems == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: _deep,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(_fmtCurrency(_cartTotal),
                      style: const TextStyle(
                          color: _deep,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Product browser ─────────────────────────────────────────

  Widget _buildProductBrowser() {
    final filtered = _searchQuery.isEmpty
        ? _stockItems
        : _stockItems
            .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products to add to cart…',
                hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: _textMuted, size: 20),
                filled: true,
                fillColor: _bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primary, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          // Product grid
          if (!_stockLoaded)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: SpinKitRing(color: _primary, size: 32)),
            )
          else if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 40, color: _textMuted),
                    const SizedBox(height: 12),
                    Text(
                      _stockItems.isEmpty
                          ? 'No stock items found'
                          : 'No products match your search',
                      style: TextStyle(color: _textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 10.0;
                  const minW = 160.0;
                  var cols = ((constraints.maxWidth + gap) / (minW + gap)).floor();
                  if (cols < 1) cols = 1;
                  final w = (constraints.maxWidth - (cols - 1) * gap) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: filtered
                        .map((s) => SizedBox(
                              width: w,
                              child: _productChip(s),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _productChip(StockRecord s) {
    final inCart = _cart.any((item) =>
        (item['productName'] as String).toLowerCase() ==
        s.name.toLowerCase());
    final outOfStock = s.quantity <= 0;
    final price = s.price > 0 ? s.price : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: outOfStock ? null : () => _addToCart(s),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: outOfStock ? _bg : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: inCart ? _primary : _border,
              width: inCart ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: outOfStock ? Colors.grey.shade200 : _light,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      size: 16,
                      color: outOfStock ? Colors.grey : _deep,
                    ),
                  ),
                  const Spacer(),
                  if (outOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _red.withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('OUT',
                          style: TextStyle(
                              color: _red, fontSize: 8, fontWeight: FontWeight.w700)),
                    )
                  else
                    Text('${s.quantity}',
                        style: TextStyle(
                            color: _textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: outOfStock ? _textMuted : _textDark),
              ),
              const SizedBox(height: 4),
              Text(
                price > 0 ? _fmtCurrency(price) : 'No price',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: outOfStock ? _textMuted : _primary),
              ),
              if (inCart)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: _primary),
                      const SizedBox(width: 4),
                      Text('In cart',
                          style: TextStyle(
                              color: _primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cart panel ──────────────────────────────────────────────

  Widget _buildCart() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _primary.withAlpha(8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_rounded,
                    color: _primary, size: 18),
                const SizedBox(width: 8),
                const Text('Cart',
                    style: TextStyle(
                        color: _textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_cart.isNotEmpty)
                  Text('${_cartItems} item${_cartItems == 1 ? '' : 's'}',
                      style: TextStyle(color: _textMuted, fontSize: 12)),
              ],
            ),
          ),
          // Line items
          if (_cart.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.add_shopping_cart_rounded,
                        size: 36, color: _textMuted),
                    const SizedBox(height: 12),
                    Text('Tap a product to add it to the cart.',
                        style: TextStyle(color: _textMuted, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.42),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _cart.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: _border),
                itemBuilder: (context, i) {
                  final item = _cart[i];
                  final qty = item['quantity'] as int;
                  final price = item['sellingPrice'] as double;
                  final total = item['total'] as double;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['productName'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        // Qty controls
                        Container(
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _qtyBtn(Icons.remove_rounded,
                                  () => _changeQty(i, -1)),
                              Text('$qty',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              _qtyBtn(Icons.add_rounded,
                                  () => _changeQty(i, 1)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 70,
                          child: Text(
                            _fmtCurrency(total),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _primary),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeFromCart(i),
                          icon: Icon(Icons.close_rounded,
                              size: 16, color: _textMuted),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 28, minHeight: 28),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          // Patient ref + total + checkout
          if (_cart.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _patientController,
                decoration: InputDecoration(
                  hintText: 'Patient / customer ref (optional)',
                  hintStyle: TextStyle(color: _textMuted, fontSize: 12),
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      size: 18, color: _textMuted),
                  filled: true,
                  fillColor: _bg,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
            // ── Payment method selector ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: _buildPaymentSelector(),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Total',
                          style: TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(_fmtCurrency(_cartTotal),
                          style: const TextStyle(
                              color: _textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _completing ? null : _completeSale,
                      icon: _completing
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_rounded, size: 20),
                      label: Text(
                          _completing ? 'Completing…' : 'Complete Sale',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Payment method selector ────────────────────────────────
  // Cash | Card | Mobile Money chips; choosing Mobile Money reveals
  // a provider row with the Zamtel / Airtel / MTN brand logos.

  static const _paymentMethods = ['Cash', 'Card', 'Mobile Money'];
  static const _mobileProviders = [
    ('Zamtel Money', 'assets/images/payment/zamtel_money.png'),
    ('Airtel Money', 'assets/images/payment/airtel_money.png'),
    ('MTN Money', 'assets/images/payment/mtn_money.png'),
  ];

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 15, color: _primary),
              const SizedBox(width: 6),
              Text('Payment method',
                  style: TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final method in _paymentMethods) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () => safeSetState(() {
                      _paymentMethod = method;
                      if (method != 'Mobile Money') {
                        _mobileMoneyProvider = null;
                      } else {
                        _mobileMoneyProvider ??= _mobileProviders.first.$1;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _paymentMethod == method
                            ? _primary
                            : _surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _paymentMethod == method
                              ? _primary
                              : _border,
                          width: _paymentMethod == method ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            method == 'Cash'
                                ? Icons.payments_rounded
                                : method == 'Card'
                                    ? Icons.credit_card_rounded
                                    : Icons.phone_android_rounded,
                            size: 14,
                            color: _paymentMethod == method
                                ? Colors.white
                                : _textMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              method,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _paymentMethod == method
                                    ? Colors.white
                                    : _textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (method != _paymentMethods.last) const SizedBox(width: 6),
              ],
            ],
          ),
          // Mobile money provider row — only when Mobile Money selected
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _paymentMethod == 'Mobile Money'
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox(width: double.infinity, height: 0),
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  for (final (provider, logo) in _mobileProviders) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => safeSetState(
                            () => _mobileMoneyProvider = provider),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _mobileMoneyProvider == provider
                                  ? _primary
                                  : _border,
                              width:
                                  _mobileMoneyProvider == provider ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  logo,
                                  height: 22,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.phone_android_rounded,
                                      size: 20,
                                      color: _textMuted),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: _mobileMoneyProvider == provider
                                      ? _primary
                                      : _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (provider != _mobileProviders.last.$1)
                      const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: _primary),
      ),
    );
  }

  // ── Recent sales strip ──────────────────────────────────────

  Widget _buildRecentSales() {
    return AuthUserStreamWidget(
      builder: (context) {
        final ownerRef = AccessControl.networkWideQueryParent(context);
        return StreamBuilder<List<SaleRecordVMI>>(
          stream: querySaleRecordVMI(
            parent: ownerRef,
            queryBuilder: (q) => q.orderBy('CreatedAt', descending: true),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final sales = snapshot.data!.take(5).toList();
            if (sales.isEmpty) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: _primary, size: 18),
                      const SizedBox(width: 8),
                      const Text('Recent Sales',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...sales.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: _green.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: _green, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.patientRef?.isNotEmpty == true
                                        ? 'Patient: ${s.patientRef}'
                                        : 'Walk-in sale',
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: _textDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    s.hasCreatedAt()
                                        ? dateTimeFormat('MMM dd, HH:mm',
                                            s.createdAt!,
                                            locale: FFLocalizations.of(context)
                                                .languageCode)
                                        : '',
                                    style: TextStyle(
                                        fontSize: 11, color: _textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _fmtCurrency(s.totalAmount),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _primary),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
