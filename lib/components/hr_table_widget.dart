import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/item_action_options_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/no_record_component/no_record_component_widget.dart';
import '/unification/components/shimmer_loading_card/shimmer_loading_card_widget.dart';
import '/index.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'hr_table_model.dart';
export 'hr_table_model.dart';

class HrTableWidget extends StatefulWidget {
  const HrTableWidget({super.key, this.searchQuery = ''});

  final String searchQuery;

  @override
  State<HrTableWidget> createState() => _HrTableWidgetState();
}

class _HrTableWidgetState extends State<HrTableWidget> {
  late HrTableModel _model;

  ({String label, Color color, IconData icon}) _invitationPresentation(
    StaffRecord staff,
  ) {
    switch (staff.invitationStatus) {
      case 'sending':
        return (
          label: 'Sending',
          color: const Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
        );
      case 'sent':
        return (
          label: 'Sent',
          color: const Color(0xFF2563EB),
          icon: Icons.mark_email_read_outlined,
        );
      case 'delivered':
        return (
          label: 'Delivered',
          color: const Color(0xFF10B981),
          icon: Icons.mail_outline_rounded,
        );
      case 'opened':
        return (
          label: 'Opened',
          color: const Color(0xFF7C3AED),
          icon: Icons.visibility_outlined,
        );
      case 'clicked':
        return (
          label: 'Viewed',
          color: const Color(0xFF7C3AED),
          icon: Icons.open_in_new_rounded,
        );
      case 'accepted':
        return (
          label: 'Active',
          color: const Color(0xFF10B981),
          icon: Icons.verified_rounded,
        );
      case 'delayed':
        return (
          label: 'Delayed',
          color: const Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
        );
      case 'bounced':
      case 'complained':
      case 'failed':
        return (
          label: 'Invite failed',
          color: const Color(0xFFEF4444),
          icon: Icons.error_outline_rounded,
        );
      default:
        return (
          label: 'Not invited',
          color: FlutterFlowTheme.of(context).secondaryText,
          icon: Icons.person_outline_rounded,
        );
    }
  }

  Widget _buildInvitationStatus(StaffRecord staff) {
    final presentation = _invitationPresentation(staff);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: presentation.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(presentation.icon, size: 13, color: presentation.color),
          const SizedBox(width: 4),
          Text(
            presentation.label,
            style: FlutterFlowTheme.of(context).labelSmall.override(
              fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
              color: presentation.color,
              fontWeight: FontWeight.w700,
              useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HrTableModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FlutterFlowTheme.of(context).primary,
                    FlutterFlowTheme.of(context).secondary,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  0.0,
                  16.0,
                  0.0,
                  16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(width: 20),
                    Text(
                      'STAFF NAME',
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                        fontFamily: FlutterFlowTheme.of(
                          context,
                        ).labelMediumFamily,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        useGoogleFonts: !FlutterFlowTheme.of(
                          context,
                        ).labelMediumIsCustom,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'NAME & INVITATION',
                        style: FlutterFlowTheme.of(context).labelMedium
                            .override(
                              fontFamily: FlutterFlowTheme.of(
                                context,
                              ).labelMediumFamily,
                              color: Colors.white,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              useGoogleFonts: !FlutterFlowTheme.of(
                                context,
                              ).labelMediumIsCustom,
                            ),
                      ),
                    ),
                    if (responsiveVisibility(
                      context: context,
                      phone: false,
                      tablet: false,
                    ))
                      Expanded(
                        flex: 1,
                        child: Text(
                          'ROLE',
                          style: FlutterFlowTheme.of(context).bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(
                                  context,
                                ).bodyMediumFamily,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                useGoogleFonts: !FlutterFlowTheme.of(
                                  context,
                                ).bodyMediumIsCustom,
                              ),
                        ),
                      ),
                    if (responsiveVisibility(
                      context: context,
                      phone: false,
                      tablet: false,
                      tabletLandscape: false,
                    ))
                      Expanded(
                        flex: 1,
                        child: Text(
                          'PHONE',
                          style: FlutterFlowTheme.of(context).bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(
                                  context,
                                ).bodyMediumFamily,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                useGoogleFonts: !FlutterFlowTheme.of(
                                  context,
                                ).bodyMediumIsCustom,
                              ),
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'ASSIGNED PHARMACY',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FlutterFlowTheme.of(
                            context,
                          ).bodyMediumFamily,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          useGoogleFonts: !FlutterFlowTheme.of(
                            context,
                          ).bodyMediumIsCustom,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                      child: Text(
                        'ACTIONS',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: FlutterFlowTheme.of(
                            context,
                          ).bodyMediumFamily,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          useGoogleFonts: !FlutterFlowTheme.of(
                            context,
                          ).bodyMediumIsCustom,
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(width: 10.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AuthUserStreamWidget(
                builder: (context) => StreamBuilder<List<StaffRecord>>(
                  stream: queryStaffRecord(
                    queryBuilder: (staffRecord) => staffRecord
                        .where('OwnerRef', isEqualTo: currentUserReference)
                        .where('deleted', isEqualTo: false),
                  ),
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Container(
                        width: double.infinity,
                        height: 50.0,
                        child: ShimmerLoadingCardWidget(),
                      );
                    }
                    List<StaffRecord> listViewStaffRecordList = snapshot.data!;
                    final normalizedQuery = widget.searchQuery
                        .trim()
                        .toLowerCase();
                    if (normalizedQuery.isNotEmpty) {
                      listViewStaffRecordList = listViewStaffRecordList.where((
                        staff,
                      ) {
                        final searchBlob = [
                          staff.name,
                          staff.role,
                          staff.phone,
                          staff.email,
                        ].join(' ').toLowerCase();
                        return searchBlob.contains(normalizedQuery);
                      }).toList();
                    }
                    if (listViewStaffRecordList.isEmpty) {
                      return NoRecordComponentWidget();
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: listViewStaffRecordList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.0),
                      itemBuilder: (context, listViewIndex) {
                        final listViewStaffRecord =
                            listViewStaffRecordList[listViewIndex];
                        return StreamBuilder<PharmacyRecord>(
                          stream: PharmacyRecord.getDocument(
                            listViewStaffRecord.pharmId!,
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return Center(
                                child: SizedBox(
                                  width: 100.0,
                                  height: 100.0,
                                  child: SpinKitRing(
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 100.0,
                                  ),
                                ),
                              );
                            }

                            final containerPharmacyRecord = snapshot.data!;

                            return Container(
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      logFirebaseEvent(
                                        'HR_TABLE_COMP_Row_odheg2o8_ON_TAP',
                                      );
                                      logFirebaseEvent('Row_navigate_to');

                                      context.pushNamed(
                                        StaffDetailsWidget.routeName,
                                        queryParameters: {
                                          'staff': serializeParam(
                                            listViewStaffRecord.reference,
                                            ParamType.DocumentReference,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 30.0,
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              listViewStaffRecord.name
                                                      .trim()
                                                      .isNotEmpty
                                                  ? listViewStaffRecord.name
                                                        .trim()
                                                        .split(RegExp(r'\s+'))
                                                        .map(
                                                          (part) =>
                                                              part.isNotEmpty
                                                              ? part[0]
                                                              : '',
                                                        )
                                                        .take(2)
                                                        .join()
                                                        .toUpperCase()
                                                  : 'HR',
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).labelSmall.override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).labelSmallFamily,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).primary,
                                                    fontWeight: FontWeight.w700,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                          context,
                                                        ).labelSmallIsCustom,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                listViewStaffRecord.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).labelMedium.override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                            context,
                                                          ).labelMediumFamily,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                            context,
                                                          ).labelMediumIsCustom,
                                                    ),
                                              ),
                                              _buildInvitationStatus(
                                                listViewStaffRecord,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                        ))
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              listViewStaffRecord.role,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMediumFamily,
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).secondaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMediumIsCustom,
                                                  ),
                                            ),
                                          ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                          tabletLandscape: false,
                                        ))
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              listViewStaffRecord.phone,
                                              style:
                                                  FlutterFlowTheme.of(
                                                    context,
                                                  ).bodyMedium.override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMediumFamily,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                          context,
                                                        ).bodyMediumIsCustom,
                                                  ),
                                            ),
                                          ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            containerPharmacyRecord.name,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMediumFamily,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) => Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  0.0,
                                                  0.0,
                                                  8.0,
                                                  0.0,
                                                ),
                                            child: FlutterFlowIconButton(
                                              borderRadius: 20.0,
                                              borderWidth: 1.0,
                                              buttonSize: 40.0,
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryText,
                                                size: 24.0,
                                              ),
                                              onPressed: () async {
                                                logFirebaseEvent(
                                                  'HR_TABLE_COMP_more_vert_ICN_ON_TAP',
                                                );
                                                logFirebaseEvent(
                                                  'IconButton_alert_dialog',
                                                );
                                                await showAlignedDialog(
                                                  context: context,
                                                  isGlobal: false,
                                                  avoidOverflow: false,
                                                  targetAnchor:
                                                      AlignmentDirectional(
                                                        1.0,
                                                        0.0,
                                                      ).resolve(
                                                        Directionality.of(
                                                          context,
                                                        ),
                                                      ),
                                                  followerAnchor:
                                                      AlignmentDirectional(
                                                        1.0,
                                                        0.0,
                                                      ).resolve(
                                                        Directionality.of(
                                                          context,
                                                        ),
                                                      ),
                                                  builder: (dialogContext) {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: WebViewAware(
                                                        child: ItemActionOptionsWidget(
                                                          editCallback: () async {
                                                            logFirebaseEvent(
                                                              '_navigate_to',
                                                            );

                                                            context.pushNamed(
                                                              ViewUserWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'staffRef': serializeParam(
                                                                  listViewStaffRecord
                                                                      .reference,
                                                                  ParamType
                                                                      .DocumentReference,
                                                                ),
                                                              }.withoutNulls,
                                                            );
                                                          },
                                                          deleteCallback: () async {
                                                            logFirebaseEvent(
                                                              '_backend_call',
                                                            );

                                                            await listViewStaffRecord
                                                                .reference
                                                                .update(
                                                                  createStaffRecordData(
                                                                    deleted:
                                                                        true,
                                                                  ),
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 10.0)),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1.0,
                                    color: FlutterFlowTheme.of(
                                      context,
                                    ).alternate.withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
