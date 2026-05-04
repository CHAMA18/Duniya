import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/components/empty_cart_widget.dart';
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
                                                                  'K${priceItem.toString()}',
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
                                    'K${functions.cartTotal(FFAppState().Cart.price.toList(), FFAppState().Cart.quantity.toList()).toString()}',
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
                              logFirebaseEvent('Button_backend_call');

                              var salesRecordReference = SalesRecord.createDoc(
                                  valueOrDefault(
                                              currentUserDocument?.role, '') ==
                                          'Owner'
                                      ? currentUserReference!
                                      : currentUserDocument!.ownerRef!);
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
                                ownerRef: valueOrDefault(
                                            currentUserDocument?.role, '') ==
                                        'Owner'
                                    ? currentUserReference
                                    : currentUserDocument?.ownerRef,
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
                                    ownerRef: valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference
                                        : currentUserDocument?.ownerRef,
                                  ),
                                  salesRecordReference);
                              logFirebaseEvent('Button_firestore_query');
                              _model.fine = await queryFinanceRecordOnce(
                                parent: valueOrDefault(
                                            currentUserDocument?.role, '') ==
                                        'Owner'
                                    ? currentUserReference
                                    : currentUserDocument?.ownerRef,
                                singleRecord: true,
                              ).then((s) => s.firstOrNull);
                              if (_model.fine?.revenue == null) {
                                logFirebaseEvent('Button_backend_call');

                                await FinanceRecord.createDoc(valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference!
                                        : currentUserDocument!.ownerRef!)
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

                              logFirebaseEvent('Button_backend_call');
                              _model.pharm =
                                  await PharmacyRecord.getDocumentOnce(
                                      FFAppState().Cart.pharmId!);
                              while (FFAppState().LoopCounter !=
                                  FFAppState().Cart.displayName.length) {
                                logFirebaseEvent('Button_firestore_query');
                                _model.stock = await queryStockRecordOnce(
                                  parent: valueOrDefault(
                                              currentUserDocument?.role, '') ==
                                          'Owner'
                                      ? currentUserReference
                                      : currentUserDocument?.ownerRef,
                                  queryBuilder: (stockRecord) => stockRecord
                                      .where(
                                        'Name',
                                        isEqualTo: FFAppState()
                                            .Cart
                                            .displayName
                                            .elementAtOrNull(
                                                FFAppState().LoopCounter),
                                      )
                                      .where(
                                        'Pharmacy',
                                        isEqualTo: _model.pharm?.name,
                                      ),
                                  singleRecord: true,
                                ).then((s) => s.firstOrNull);
                                logFirebaseEvent('Button_backend_call');

                                await SaleitemRecord.createDoc(valueOrDefault(
                                                currentUserDocument?.role,
                                                '') ==
                                            'Owner'
                                        ? currentUserReference!
                                        : currentUserDocument!.ownerRef!)
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
                                if (_model.stock!.quantity <=
                                    (_model.stock?.limitNotice != null
                                        ? _model.stock!.limitNotice
                                        : 5)) {
                                  if (valueOrDefault(
                                          currentUserDocument?.role, '') ==
                                      'Owner') {
                                    logFirebaseEvent('Button_backend_call');
                                    _model.ownerCall = await SendEmailCall.call(
                                      toEmail: currentUserEmail,
                                      subject: 'Limited Stock notice',
                                      content:
                                          ' We would like to notify you that, as of right now, just  ${_model.stock?.quantity.toString()} of ${_model.stock?.name} is left in stock, below the needed amount.  We advise checking your inventory and making any necessary adjustments to future orders in the interim. Please contact our customer support staff at [Customer Support Email/Phone Number] if you have any questions or need assistance. We respect your continued relationship and are grateful for your understanding.',
                                    );

                                    logFirebaseEvent('Button_alert_dialog');
                                    await showDialog(
                                      context: context,
                                      builder: (alertDialogContext) {
                                        return WebViewAware(
                                          child: AlertDialog(
                                            title: Text('low stock'),
                                            content: Text('very low stock'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    alertDialogContext),
                                                child: Text('Ok'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                                          ' We would like to notify you that, as of right now, just  ${_model.stock?.quantity.toString()} of ${_model.stock?.name} is left in stock, below the needed amount.  We advise checking your inventory and making any necessary adjustments to future orders in the interim. Please contact our customer support staff at [Customer Support Email/Phone Number] if you have any questions or need assistance. We respect your continued relationship and are grateful for your understanding.',
                                    );
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
                                  backgroundColor: Color(0xFF36AC7D),
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
