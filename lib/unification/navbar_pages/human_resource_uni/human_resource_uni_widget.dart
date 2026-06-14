import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/hr_table_widget.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'human_resource_uni_model.dart';
export 'human_resource_uni_model.dart';

class _HumanResourcesData {
  const _HumanResourcesData({
    required this.totalStaff,
    required this.linkedStaff,
    required this.pharmacies,
    required this.outlets,
  });

  final int totalStaff;
  final int linkedStaff;
  final int pharmacies;
  final int outlets;
}

class HumanResourceUniWidget extends StatefulWidget {
  const HumanResourceUniWidget({super.key});

  static String routeName = 'HumanResourceUni';
  static String routePath = '/humanResourceUni';

  @override
  State<HumanResourceUniWidget> createState() => _HumanResourceUniWidgetState();
}

class _HumanResourceUniWidgetState extends State<HumanResourceUniWidget> {
  late HumanResourceUniModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HumanResourceUniModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'HumanResourceUni'});
    SchedulerBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<_HumanResourcesData> _loadMetrics() async {
    final staff = await queryStaffRecordOnce(
      queryBuilder: (query) => query
          .where('OwnerRef', isEqualTo: currentUserReference)
          .where('deleted', isEqualTo: false),
    );
    final pharmacies = await queryPharmacyRecordCount(
      parent: currentUserReference,
    );
    final outlets = await queryOutletRecordCount(
      parent: currentUserReference,
    );

    final linkedStaff = staff.where((item) => item.hasPharmId()).length;

    return _HumanResourcesData(
      totalStaff: staff.length,
      linkedStaff: linkedStaff,
      pharmacies: pharmacies,
      outlets: outlets,
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required String helper,
    required IconData icon,
    required Color tint,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 148),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: tint, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).titleLargeFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).titleLargeIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  helper,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => safeSetState(() {}),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  hintText: 'Search staff by name, role, phone, or email...',
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                      ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => safeSetState(() => _searchController.clear()),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageChrome({
    required bool isPhone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Human Resources',
                    style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).displaySmallFamily,
                          fontSize: isPhone ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.9,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .displaySmallIsCustom,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Orchestrate your clinical workforce with surgical precision.',
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FFButtonWidget(
              onPressed: () async {
                context.pushNamed(AddUserWidget.routeName);
              },
              text: 'Add New Staff',
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              options: FFButtonOptions(
                height: 44,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(22.0, 0.0, 22.0, 0.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                color: Colors.black,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleSmallIsCustom,
                    ),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(14.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = responsiveVisibility(
      context: context,
      tablet: false,
      tabletLandscape: false,
      desktop: false,
    );

    return Title(
      title: 'Human Resources',
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
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<_HumanResourcesData>(
                          future: _loadMetrics(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: const LoadingSpinnerWidget(
                                  size: 42,
                                  showLabel: false,
                                ),
                              );
                            }

                            final data = snapshot.data!;

                            final cards = [
                              _buildMetricCard(
                                context: context,
                                label: 'Active Staff',
                                value: data.totalStaff.toString(),
                                helper: 'Current roster entries',
                                icon: Icons.badge_rounded,
                                tint: FlutterFlowTheme.of(context).primary,
                              ),
                              _buildMetricCard(
                                context: context,
                                label: 'Linked Staff',
                                value: data.linkedStaff.toString(),
                                helper: 'Assigned to a pharmacy',
                                icon: Icons.verified_user_rounded,
                                tint: const Color(0xFF10B981),
                              ),
                              _buildMetricCard(
                                context: context,
                                label: 'Pharmacies',
                                value: data.pharmacies.toString(),
                                helper: 'Network locations available',
                                icon: Icons.local_pharmacy_rounded,
                                tint: const Color(0xFFF59E0B),
                              ),
                              _buildMetricCard(
                                context: context,
                                label: 'Outlets',
                                value: data.outlets.toString(),
                                helper: 'Operational locations in scope',
                                icon: Icons.store_mall_directory_rounded,
                                tint: const Color(0xFF8B5CF6),
                              ),
                            ];

                            return SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                isPhone ? 16 : 24,
                                18,
                                isPhone ? 16 : 24,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPageChrome(isPhone: isPhone),
                                  Column(
                                    children: [
                                      for (var i = 0;
                                          i < cards.length;
                                          i++) ...[
                                        cards[i],
                                        if (i != cards.length - 1)
                                          const SizedBox(height: 14),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _buildSearchBar(),
                                  const SizedBox(height: 18),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .alternate
                                            .withValues(alpha: 0.7),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.03),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: HrTableWidget(
                                      searchQuery: _searchController.text,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
}
