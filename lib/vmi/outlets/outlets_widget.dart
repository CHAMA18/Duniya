import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
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
import 'outlets_model.dart';
export 'outlets_model.dart';

class OutletsWidget extends StatefulWidget {
  const OutletsWidget({super.key});

  static String routeName = 'Outlets';
  static String routePath = '/outlets';

  @override
  State<OutletsWidget> createState() => _OutletsWidgetState();
}

class _OutletsWidgetState extends State<OutletsWidget> {
  late OutletsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OutletsModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Outlets'});
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'Pharmacy Outlets',
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
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pharmacy Outlets',
                                      style: FlutterFlowTheme.of(context)
                                          .displaySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .displaySmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .displaySmallIsCustom,
                                          ),
                                    ),
                                    FFButtonWidget(
                                      onPressed: () =>
                                          _showAddOutletDialog(context),
                                      text: 'Add Outlet',
                                      icon: Icon(Icons.add, size: 15.0),
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.0),
                                // Pharmacy dropdown
                                AuthUserStreamWidget(
                                  builder: (context) =>
                                      FutureBuilder<List<PharmacyRecord>>(
                                    future: queryPharmacyRecordOnce(
                                      parent: valueOrDefault(
                                                  currentUserDocument?.role,
                                                  '') ==
                                              'Owner'
                                          ? currentUserReference
                                          : currentUserDocument?.ownerRef,
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container(
                                          width: 180.0,
                                          height: 44.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(
                                                      context)
                                                  .alternate,
                                            ),
                                          ),
                                          child: Center(
                                            child: SpinKitRing(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 20.0,
                                            ),
                                          ),
                                        );
                                      }
                                      List<PharmacyRecord> pharmacies =
                                          snapshot.data!;
                                      // Set default pharmacy
                                      if (_model.pharmacyValue == null &&
                                          pharmacies.isNotEmpty) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          safeSetState(() {
                                            _model.pharmacyValue =
                                                pharmacies.first.name;
                                          });
                                        });
                                      }
                                      return Container(
                                        width: 250.0,
                                        child: FlutterFlowDropDown<String>(
                                          controller: _model
                                                  .pharmacyValueController ??=
                                              FormFieldController<String>(
                                                  _model.pharmacyValue),
                                          options: pharmacies
                                              .map((p) => p.name)
                                              .toList(),
                                          onChanged: (val) => safeSetState(
                                              () => _model.pharmacyValue =
                                                  val),
                                          width: 250.0,
                                          height: 44.0,
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium,
                                          hintText: 'Select Pharmacy',
                                          fillColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          borderColor:
                                              FlutterFlowTheme.of(context)
                                                  .alternate,
                                          borderRadius: 8.0,
                                          elevation: 2,
                                          borderWidth: 1.0,
                                          margin: EdgeInsets.zero,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                // Outlets list
                                Expanded(
                                  child: AuthUserStreamWidget(
                                    builder: (context) =>
                                        _model.pharmacyValue != null
                                            ? StreamBuilder<
                                                    List<OutletRecord>>(
                                                stream:
                                                    queryOutletRecord(
                                                  parent: valueOrDefault(
                                                              currentUserDocument
                                                                  ?.role,
                                                              '') ==
                                                          'Owner'
                                                      ? currentUserReference
                                                      : currentUserDocument
                                                          ?.ownerRef,
                                                ),
                                                builder:
                                                    (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Center(
                                                      child: SpinKitRing(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 40.0,
                                                      ),
                                                    );
                                                  }
                                                  List<OutletRecord> outlets =
                                                      snapshot.data!;
                                                  if (outlets.isEmpty) {
                                                    return Center(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons
                                                              .store_outlined,
                                                              size: 64.0,
                                                              color: FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondaryText),
                                                          SizedBox(
                                                              height: 16.0),
                                                          Text(
                                                              'No outlets found',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .headlineSmall),
                                                          SizedBox(
                                                              height: 8.0),
                                                          Text(
                                                              'Add an outlet to get started',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        outlets.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      OutletRecord outlet =
                                                          outlets[index];
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 8.0),
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            border:
                                                                Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .alternate,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        outlet
                                                                            .name,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).titleMediumFamily,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).titleMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              4.0),
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              outlet.code,
                                                                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 8.0),
                                                                          if (outlet.hasAddress())
                                                                            Text(
                                                                              outlet.address!,
                                                                              style: FlutterFlowTheme.of(context).bodySmall,
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // Status indicator
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                          vertical:
                                                                              4.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: outlet
                                                                            .isActive
                                                                        ? Color(
                                                                            0xFFC6F6D5)
                                                                        : Color(
                                                                            0xFFFED7D7),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12.0),
                                                                  ),
                                                                  child: Text(
                                                                    outlet.isActive
                                                                        ? 'Active'
                                                                        : 'Inactive',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodySmallFamily,
                                                                          color: outlet.isActive
                                                                              ? Color(0xFF22543D)
                                                                              : Color(0xFF822727),
                                                                          fontSize:
                                                                              11.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
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
                                                })
                                            : Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.store_outlined,
                                                        size: 64.0,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryText),
                                                    SizedBox(height: 16.0),
                                                    Text(
                                                        'Select a pharmacy to view outlets',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium),
                                                  ],
                                                ),
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  void _showAddOutletDialog(BuildContext context) {
    _model.nameTextController ??= TextEditingController();
    _model.codeTextController ??= TextEditingController();
    _model.addressTextController ??= TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add Outlet'),
          content: Container(
            width: MediaQuery.sizeOf(context).width > 400 ? 400 : double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _model.nameTextController,
                    decoration: InputDecoration(
                      labelText: 'Outlet Name *',
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context)
                          .secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.codeTextController,
                    decoration: InputDecoration(
                      labelText: 'Outlet Code *',
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context)
                          .secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    controller: _model.addressTextController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context)
                          .secondaryBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            FFButtonWidget(
              onPressed: () async {
                if (_model.nameTextController?.text.isEmpty ?? true) return;
                if (_model.codeTextController?.text.isEmpty ?? true) return;

                final ownerRef =
                    valueOrDefault(currentUserDocument?.role, '') ==
                            'Owner'
                        ? currentUserReference!
                        : currentUserDocument!.ownerRef!;

                await OutletRecord.createDoc(ownerRef).set(
                  createOutletRecordData(
                    name: _model.nameTextController?.text,
                    code: _model.codeTextController?.text,
                    address: _model.addressTextController?.text,
                    isActive: true,
                    createdAt: getCurrentTimestamp,
                    updatedAt: getCurrentTimestamp,
                  ),
                );

                // Clear form
                _model.nameTextController?.clear();
                _model.codeTextController?.clear();
                _model.addressTextController?.clear();
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Outlet added successfully')),
                );
              },
              text: 'Save',
              options: FFButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(
                    16.0, 0.0, 16.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context)
                    .titleSmall
                    .override(
                      fontFamily: FlutterFlowTheme.of(context)
                          .titleSmallFamily,
                      color: Colors.white,
                      letterSpacing: 0.0,
                      useGoogleFonts: !FlutterFlowTheme.of(context)
                          .titleSmallIsCustom,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        );
      },
    );
  }
}
