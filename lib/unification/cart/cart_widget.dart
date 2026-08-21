import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/empty_cart_widget.dart';
import '/rbac/rbac.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'cart_model.dart';
export 'cart_model.dart';

class CartWidget extends StatefulWidget {
  const CartWidget({super.key});

  @override
  State<CartWidget> createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  late CartModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CartModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<StockRecord?> _resolveStockForSale({
    required String productName,
    required String pharmacyName,
    required bool allowSinglePharmacyFallback,
  }) async {
    final candidates = await queryStockRecordOnce(
      parent: AccessControl.parentRef(context) ?? currentUserReference,
      queryBuilder: (stockRecord) => stockRecord.where(
        'Name',
        isEqualTo: productName,
      ),
    );
    final available = candidates.where((stock) => stock.quantity > 0).toList();
    final normalizedPharmacyName = pharmacyName.trim().toLowerCase();

    return available.firstWhereOrNull(
          (stock) =>
              stock.pharmacy.trim().toLowerCase() == normalizedPharmacyName,
        ) ??
        available.firstWhereOrNull((stock) => stock.pharmacy.trim().isEmpty) ??
        (allowSinglePharmacyFallback ? available.firstOrNull : null);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Material(
        color: Colors.transparent,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: 500.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'oairr9eo' /* Checkout */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineMediumFamily,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 30.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineMediumIsCustom,
                                ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.close,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              logFirebaseEvent('CART_COMP_close_ICN_ON_TAP');
                              logFirebaseEvent(
                                  'IconButton_close_dialog_drawer_etc');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          if (FFAppState().Cart.displayName.length > 0)
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          final name =
                                                              FFAppState()
                                                                  .Cart
                                                                  .displayName
                                                                  .toList();

                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children:
                                                                List.generate(
                                                                    name.length,
                                                                    (nameIndex) {
                                                              final nameItem =
                                                                  name[
                                                                      nameIndex];
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  nameItem,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              );
                                                            }),
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final quantity =
                                                              FFAppState()
                                                                  .Cart
                                                                  .quantity
                                                                  .toList();

                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: List.generate(
                                                                quantity.length,
                                                                (quantityIndex) {
                                                              final quantityItem =
                                                                  quantity[
                                                                      quantityIndex];
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  'x${quantityItem.toString()}',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              );
                                                            }),
                                                          );
                                                        },
                                                      ),
                                                      Builder(
                                                        builder: (context) {
                                                          final price =
                                                              FFAppState()
                                                                  .Cart
                                                                  .price
                                                                  .toList();

                                                          return Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children:
                                                                List.generate(
                                                                    price
                                                                        .length,
                                                                    (priceIndex) {
                                                              final priceItem =
                                                                  price[
                                                                      priceIndex];
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            12.0),
                                                                child: Text(
                                                                  'ZMK ${priceItem.toString()}',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              );
                                                            }),
                                                          );
                                                        },
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 10.0)),
                                                  ),
                                                ],
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
                          if (FFAppState().Cart.displayName.length == 0)
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: wrapWithModel(
                                model: _model.emptyCartModel,
                                updateCallback: () => safeSetState(() {}),
                                child: EmptyCartWidget(),
                              ),
                            ),
                        ],
                      ),
                    ].divide(SizedBox(height: 10.0)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Divider(
                      thickness: 1.0,
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 16.0, 0.0, 16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    FFLocalizations.of(context).getText(
                                      'cl53afp8' /* Total */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMediumFamily,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .headlineMediumIsCustom,
                                        ),
                                  ),
                                  Text(
                                    'ZMK ${functions.cartTotal(FFAppState().Cart.price.toList(), FFAppState().Cart.quantity.toList()).toString()}',
                                    style: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .headlineMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .headlineMediumIsCustom,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              logFirebaseEvent('CART_COMP_PAY_BTN_ON_TAP');
                              final cart = FFAppState().Cart;
                              final cartParent =
                                  AccessControl.parentRef(context) ??
                                      currentUserReference;
                              if (cartParent == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your account is not ready to complete a sale.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (cart.pharmId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Select a pharmacy before completing the sale.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              _model.pharm =
                                  await PharmacyRecord.getDocumentOnce(
                                      cart.pharmId!);
                              final scopedPharmacies =
                                  await queryPharmacyRecordOnce(
                                      parent: cartParent);
                              final allowSinglePharmacyFallback =
                                  scopedPharmacies.length == 1;
                              final resolvedStocks = <StockRecord>[];
                              for (var index = 0;
                                  index < cart.displayName.length;
                                  index++) {
                                final requestedQuantity =
                                    cart.quantity.elementAtOrNull(index) ?? 0;
                                final productName =
                                    cart.displayName.elementAtOrNull(index) ??
                                        '';
                                if (requestedQuantity <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Set a quantity for $productName before completing the sale.'),
                                    ),
                                  );
                                  return;
                                }

                                final stock = await _resolveStockForSale(
                                  productName: productName,
                                  pharmacyName:
                                      _model.pharm?.name ?? cart.pharmName,
                                  allowSinglePharmacyFallback:
                                      allowSinglePharmacyFallback,
                                );
                                if (stock == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '$productName is no longer available in the selected pharmacy.'),
                                    ),
                                  );
                                  return;
                                }
                                if (stock.quantity < requestedQuantity) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Only ${stock.quantity} of $productName is available.'),
                                    ),
                                  );
                                  return;
                                }
                                resolvedStocks.add(stock);
                              }

                              FFAppState().LoopCounter = 0;
                              logFirebaseEvent('Button_backend_call');

                              var salesRecordReference =
                                  SalesRecord.createDoc(cartParent);
                              await salesRecordReference
                                  .set(createSalesRecordData(
                                date: getCurrentTimestamp,
                                totalAmount: functions.cartTotal(
                                    FFAppState().Cart.price.toList(),
                                    FFAppState().Cart.quantity.toList()),
                                numberOfItems:
                                    FFAppState().Cart.displayName.length,
                                userID: currentUserReference,
                                pharmaID: FFAppState().Cart.pharmId,
                                ownerRef: AccessControl.parentRef(context) ??
                                    currentUserReference,
                              ));
                              _model.sales = SalesRecord.getDocumentFromData(
                                  createSalesRecordData(
                                    date: getCurrentTimestamp,
                                    totalAmount: functions.cartTotal(
                                        FFAppState().Cart.price.toList(),
                                        FFAppState().Cart.quantity.toList()),
                                    numberOfItems:
                                        FFAppState().Cart.displayName.length,
                                    userID: currentUserReference,
                                    pharmaID: FFAppState().Cart.pharmId,
                                    ownerRef:
                                        AccessControl.parentRef(context) ??
                                            currentUserReference,
                                  ),
                                  salesRecordReference);
                              logFirebaseEvent('Button_firestore_query');
                              _model.fine = await queryFinanceRecordOnce(
                                parent: AccessControl.parentRef(context) ??
                                    currentUserReference,
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);
                              if (_model.fine?.revenue == null) {
                                logFirebaseEvent('Button_backend_call');

                                await FinanceRecord.createDoc(
                                        (AccessControl.parentRef(context) ??
                                            currentUserReference)!)
                                    .set(createFinanceRecordData(
                                  revenue: functions.cartTotal(
                                      FFAppState().Cart.price.toList(),
                                      FFAppState().Cart.quantity.toList()),
                                ));
                              } else {
                                logFirebaseEvent('Button_backend_call');

                                await _model.fine!.reference.update({
                                  ...mapToFirestore(
                                    {
                                      'Revenue': FieldValue.increment(
                                          functions.cartTotal(
                                              FFAppState().Cart.price.toList(),
                                              FFAppState()
                                                  .Cart
                                                  .quantity
                                                  .toList())),
                                    },
                                  ),
                                });
                              }

                              while (FFAppState().LoopCounter !=
                                  FFAppState().Cart.displayName.length) {
                                _model.stock = resolvedStocks
                                    .elementAtOrNull(FFAppState().LoopCounter);
                                logFirebaseEvent('Button_backend_call');

                                await SaleitemRecord.createDoc(cartParent)
                                    .set(createSaleitemRecordData(
                                  quantity: FFAppState()
                                      .Cart
                                      .quantity
                                      .elementAtOrNull(
                                          FFAppState().LoopCounter),
                                  unitPrice: FFAppState()
                                      .Cart
                                      .price
                                      .elementAtOrNull(
                                          FFAppState().LoopCounter),
                                  stockID: _model.stock?.reference,
                                  saleID: _model.sales?.reference,
                                ));
                                logFirebaseEvent('Button_backend_call');

                                await _model.stock!.reference.update({
                                  ...mapToFirestore(
                                    {
                                      'Quantity': FieldValue.increment(
                                          -(FFAppState()
                                              .Cart
                                              .quantity
                                              .elementAtOrNull(
                                                  FFAppState().LoopCounter)!)),
                                    },
                                  ),
                                });
                                // Compute the post-decrement remaining quantity
                                // BEFORE the threshold check. The Firestore write
                                // above decrements Quantity server-side via
                                // FieldValue.increment(-sold), but the local
                                // cached _model.stock.quantity still reflects
                                // the pre-sale value. Using the cached value
                                // for the threshold check meant the alert:
                                //   • MISSED the case where pre-sale was above
                                //     threshold but post-sale is below it
                                //     (e.g. 6 in stock, sell 4 → 2 left, should
                                //     fire but the cached 6 > threshold = 5
                                //     meant no alert)
                                //   • ALSO missed showing the user what the
                                //     current state actually is — the alert
                                //     said "very low stock" without telling
                                //     the user what was left or what the
                                //     threshold even was.
                                final _soldQty =
                                    FFAppState().Cart.quantity.elementAtOrNull(
                                            FFAppState().LoopCounter) ??
                                        0;
                                final _remaining =
                                    _model.stock!.quantity - _soldQty;
                                final _threshold =
                                    (_model.stock?.hasLimitNotice() == true
                                            ? _model.stock!.limitNotice
                                            : 5);
                                if (_remaining <= _threshold) {
                                  String? _notifiedEmail;
                                  if (AccessControl.isOwner(context)) {
                                    logFirebaseEvent('Button_backend_call');
                                    _model.ownerCall = await SendEmailCall.call(
                                      toEmail: currentUserEmail,
                                      subject: 'Limited Stock notice',
                                      content:
                                          ' We would like to notify you that, as of right now, just  ${_remaining.toString()} of ${_model.stock?.name} is left in stock, below the needed amount.  We advise checking your inventory and making any necessary adjustments to future orders in the interim. Please contact our customer support staff at [Customer Support Email/Phone Number] if you have any questions or need assistance. We respect your continued relationship and are grateful for your understanding.',
                                    );
                                    _notifiedEmail = currentUserEmail;

                                    logFirebaseEvent('Button_alert_dialog');
                                    await _showStockLevelNotice(
                                      context: context,
                                      productName:
                                          _model.stock?.name ?? 'this product',
                                      remainingQty: _remaining,
                                      threshold: _threshold,
                                      notifiedEmail: _notifiedEmail,
                                    );
                                  } else {
                                    logFirebaseEvent('Button_backend_call');
                                    _model.owner =
                                        await UserRecord.getDocumentOnce(
                                            currentUserDocument!.ownerRef!);
                                    logFirebaseEvent('Button_backend_call');
                                    _model.apiResult0v5 =
                                        await SendEmailCall.call(
                                      toEmail: _model.owner?.email,
                                      subject: 'Limited Stock notice',
                                      content:
                                          ' We would like to notify you that, as of right now, just  ${_remaining.toString()} of ${_model.stock?.name} is left in stock, below the needed amount.  We advise checking your inventory and making any necessary adjustments to future orders in the interim. Please contact our customer support staff at [Customer Support Email/Phone Number] if you have any questions or need assistance. We respect your continued relationship and are grateful for your understanding.',
                                    );
                                    _notifiedEmail = _model.owner?.email;
                                  }
                                }
                                logFirebaseEvent('Button_update_app_state');
                                FFAppState().LoopCounter =
                                    FFAppState().LoopCounter + 1;
                                safeSetState(() {});
                              }
                              logFirebaseEvent(
                                  'Button_close_dialog_drawer_etc');
                              Navigator.pop(context);
                              logFirebaseEvent('Button_show_snack_bar');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Transaction successful',
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 4000),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).success,
                                ),
                              );

                              safeSetState(() {});
                            },
                            text: FFLocalizations.of(context).getText(
                              '37thmxt4' /* Pay */,
                            ),
                            options: FFButtonOptions(
                              height: 40.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .titleSmallFamily,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .titleSmallIsCustom,
                                  ),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//   StockLevelNoticeDialog
//
//   Contextual replacement for the broken "low stock / very low
//   stock / Ok" AlertDialog previously shown after a checkout.
//
//   Now shows:
//     • Product name in the header
//     • Remaining quantity (post-decrement)
//     • Reorder threshold
//     • Amber (warning) or red (critical) accent based on remaining
//       vs threshold — < 40% of threshold = critical
//     • Notification sent confirmation (if notifiedEmail != null)
//     • Action buttons: "View inventory" (jumps to POS inventory tab)
//       and "OK, got it" (acknowledge)
//
//   Returns 'inventory' or 'ok' depending on which button was tapped.
// ═══════════════════════════════════════════════════════════════

Future<String?> _showStockLevelNotice({
  required BuildContext context,
  required String productName,
  required int remainingQty,
  required int threshold,
  String? notifiedEmail,
}) async {
  final isCritical = threshold > 0 &&
      remainingQty <= (threshold * 0.4).floor();
  final accent = isCritical
      ? const Color(0xFFEF4444)
      : const Color(0xFFF59E0B);

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => WebViewAware(
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          width: 480,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(ctx).secondaryBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 2),
                    ),
                    child: Icon(
                        isCritical
                            ? Icons.error_outline_rounded
                            : Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCritical
                                ? 'Critical stock level'
                                : 'Stock level notice',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            productName,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]),
                  ),
                ]),
              ),
              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stat row
                      Row(children: [
                        Expanded(
                          child: _noticeMiniStat(
                            ctx: ctx,
                            label: 'Remaining',
                            value: '$remainingQty units',
                            accent: accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _noticeMiniStat(
                            ctx: ctx,
                            label: 'Reorder threshold',
                            value: '$threshold units',
                          ),
                        ),
                      ]),
                      const SizedBox(height: 18),
                      // Explanation
                      RichText(
                        text: TextSpan(
                          style: FlutterFlowTheme.of(ctx).bodyMedium.override(
                                fontFamily:
                                    FlutterFlowTheme.of(ctx).bodyMediumFamily,
                                fontSize: 14,
                                color:
                                    FlutterFlowTheme.of(ctx).primaryText,
                                letterSpacing: 0,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                useGoogleFonts: !FlutterFlowTheme.of(ctx)
                                    .bodyMediumIsCustom,
                              ),
                          children: [
                            const TextSpan(
                                text: 'After this sale, '),
                            TextSpan(
                                text: productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            TextSpan(
                                text: isCritical
                                    ? ' has dropped to $remainingQty units — below ${((threshold * 0.4).floor())} units, which is 40% of the reorder threshold. Replenish urgently to avoid stockouts.'
                                    : ' has $remainingQty units remaining — at or below the reorder threshold of $threshold units. Consider reordering soon.'),
                          ],
                        ),
                      ),
                      // Notification confirmation
                      if (notifiedEmail != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.30)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.mark_email_read_outlined,
                                color: Color(0xFF10B981), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Replenishment notice sent to $notifiedEmail',
                                style: FlutterFlowTheme.of(ctx)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(ctx)
                                          .bodySmallFamily,
                                      fontSize: 12,
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts: !FlutterFlowTheme.of(ctx)
                                          .bodySmallIsCustom,
                                    ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ]),
              ),
              // ── Footer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: FlutterFlowTheme.of(ctx)
                            .alternate
                            .withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, 'inventory'),
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('View inventory'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, 'ok'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('OK, got it'),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _noticeMiniStat({
  required BuildContext ctx,
  required String label,
  required String value,
  Color? accent,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: FlutterFlowTheme.of(ctx).primaryBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: accent?.withValues(alpha: 0.25) ??
              FlutterFlowTheme.of(ctx).alternate.withValues(alpha: 0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: FlutterFlowTheme.of(ctx).titleLarge.override(
                fontFamily: FlutterFlowTheme.of(ctx).titleLargeFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accent ?? FlutterFlowTheme.of(ctx).primaryText,
                useGoogleFonts:
                    !FlutterFlowTheme.of(ctx).titleLargeIsCustom,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: FlutterFlowTheme.of(ctx).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(ctx).bodySmallFamily,
                fontSize: 11,
                color: FlutterFlowTheme.of(ctx).secondaryText,
                useGoogleFonts:
                    !FlutterFlowTheme.of(ctx).bodySmallIsCustom,
              ),
        ),
      ],
    ),
  );
}
