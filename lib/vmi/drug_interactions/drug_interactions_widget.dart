import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'drug_interactions_model.dart';
export 'drug_interactions_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// DRUG INTERACTION ALERTS
// Flag dangerous drug combinations at POS dispensing
// ═══════════════════════════════════════════════════════════════════════

class DrugInteractionsWidget extends StatefulWidget {
  const DrugInteractionsWidget({super.key});

  static String routeName = 'DrugInteractions';
  static String routePath = '/drug-interactions';

  @override
  State<DrugInteractionsWidget> createState() => _DrugInteractionsWidgetState();
}

// ── Severity enum ──
enum InteractionSeverity { critical, warning, caution, info }

// ── Mock data model for drug interactions ──
class DrugInteraction {
  final String drugA;
  final String drugB;
  final String description;
  final InteractionSeverity severity;
  final String interactionType;
  final DateTime flaggedAt;
  final String? flaggedBy;

  DrugInteraction({
    required this.drugA,
    required this.drugB,
    required this.description,
    required this.severity,
    required this.interactionType,
    required this.flaggedAt,
    this.flaggedBy,
  });

  String get pair => '$drugA + $drugB';
}

// ── Mock rule for the rules database ──
class InteractionRule {
  final String id;
  final String drugA;
  final String drugB;
  final InteractionSeverity severity;
  final String interactionType;
  final String description;
  final bool isActive;

  InteractionRule({
    required this.id,
    required this.drugA,
    required this.drugB,
    required this.severity,
    required this.interactionType,
    required this.description,
    required this.isActive,
  });
}

class _DrugInteractionsWidgetState extends State<DrugInteractionsWidget>
    with TickerProviderStateMixin {
  late DrugInteractionsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Duniya Purple design tokens ──
  static const Color _duniyaPurple = Color(0xFF9900FF);
  static const Color _duniyaPurpleLight = Color(0xFFF3F0FF);
  static const Color _duniyaPurpleDark = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF8F9FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0B1C30);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  // ── Severity colour system ──
  // Critical — Red
  static const Color _criticalBg = Color(0xFFFEE2E2);
  static const Color _criticalText = Color(0xFF991B1B);
  static const Color _criticalBadge = Color(0xFFDC2626);
  // Warning — Amber
  static const Color _warningBg = Color(0xFFFEF3C7);
  static const Color _warningText = Color(0xFF92400E);
  static const Color _warningBadge = Color(0xFFF59E0B);
  // Caution — Blue
  static const Color _cautionBg = Color(0xFFE0F2FE);
  static const Color _cautionText = Color(0xFF1E40AF);
  static const Color _cautionBadge = Color(0xFF2563EB);
  // Info — Gray
  static const Color _infoBg = Color(0xFFF3F4F6);
  static const Color _infoText = Color(0xFF374151);
  static const Color _infoBadge = Color(0xFF6B7280);

  // ── Interaction checker state ──
  List<DrugInteraction> _checkerResults = [];
  bool _checkerLoading = false;

  // ── Animation controllers ──
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DrugInteractionsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'DrugInteractions'});
    _model.drugATextController ??= TextEditingController();
    _model.drugAFocusNode ??= FocusNode();
    _model.drugBTextController ??= TextEditingController();
    _model.drugBFocusNode ??= FocusNode();
    _model.alertSearchTextController ??= TextEditingController();
    _model.alertSearchFocusNode ??= FocusNode();

    // Count-up animation
    _countUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countUpAnimation = CurvedAnimation(
      parent: _countUpController,
      curve: Curves.easeOutCubic,
    );
    _countUpController.forward();
  }

  @override
  void dispose() {
    _model.dispose();
    _countUpController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOCK DATA — 15+ realistic drug interactions
  // ═══════════════════════════════════════════════════════════════════

  List<DrugInteraction> get _mockAlerts {
    final now = DateTime.now();
    return [
      DrugInteraction(
        drugA: 'Warfarin',
        drugB: 'Aspirin',
        description: 'Increased bleeding risk — concurrent use significantly raises haemorrhage probability',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(minutes: 12)),
        flaggedBy: 'Dr. Okafor',
      ),
      DrugInteraction(
        drugA: 'Metformin',
        drugB: 'Alcohol',
        description: 'Lactic acidosis risk — alcohol potentiates metformin\'s effect on lactate metabolism',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(hours: 1)),
        flaggedBy: 'Pharm. Adeyemi',
      ),
      DrugInteraction(
        drugA: 'Lisinopril',
        drugB: 'Potassium Supplement',
        description: 'Hyperkalemia risk — ACE inhibitors reduce potassium excretion',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(hours: 2)),
        flaggedBy: 'Dr. Mensah',
      ),
      DrugInteraction(
        drugA: 'Ibuprofen',
        drugB: 'Lisinopril',
        description: 'Reduced antihypertensive efficacy — NSAIDs counteract ACE inhibitor effects',
        severity: InteractionSeverity.warning,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(hours: 3)),
        flaggedBy: 'Pharm. Bello',
      ),
      DrugInteraction(
        drugA: 'Amoxicillin',
        drugB: 'Methotrexate',
        description: 'Methotrexate toxicity — reduced renal clearance increases serum levels',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(hours: 4)),
        flaggedBy: 'Dr. Nkosi',
      ),
      DrugInteraction(
        drugA: 'Ciprofloxacin',
        drugB: 'Theophylline',
        description: 'Theophylline toxicity — CYP1A2 inhibition raises serum theophylline 30–50%',
        severity: InteractionSeverity.warning,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(hours: 5)),
        flaggedBy: 'Pharm. Osei',
      ),
      DrugInteraction(
        drugA: 'Omeprazole',
        drugB: 'Clopidogrel',
        description: 'Reduced clopidogrel activation — CYP2C19 inhibition diminishes antiplatelet effect',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(hours: 6)),
        flaggedBy: 'Dr. Kamau',
      ),
      DrugInteraction(
        drugA: 'Amlodipine',
        drugB: 'Simvastatin',
        description: 'Rhabdomyolysis risk — amlodipine inhibits simvastatin metabolism (limit 20mg)',
        severity: InteractionSeverity.warning,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(hours: 8)),
        flaggedBy: 'Pharm. Dube',
      ),
      DrugInteraction(
        drugA: 'Spironolactone',
        drugB: 'Lisinopril',
        description: 'Hyperkalemia risk — dual RAAS blockade with potassium-sparing diuretic',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(hours: 10)),
        flaggedBy: 'Dr. Okafor',
      ),
      DrugInteraction(
        drugA: 'Carbamazepine',
        drugB: 'Lamotrigine',
        description: 'Reduced lamotrigine levels — carbamazepine induces glucuronidation',
        severity: InteractionSeverity.caution,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(days: 1, hours: 2)),
        flaggedBy: 'Pharm. Adeyemi',
      ),
      DrugInteraction(
        drugA: 'Fluconazole',
        drugB: 'Warfarin',
        description: 'Enhanced anticoagulant effect — fluconazole inhibits warfarin metabolism',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(days: 1, hours: 5)),
        flaggedBy: 'Dr. Mensah',
      ),
      DrugInteraction(
        drugA: 'Tetracycline',
        drugB: 'Calcium Supplement',
        description: 'Reduced absorption — divalent cations chelate tetracycline (separate by 2h)',
        severity: InteractionSeverity.caution,
        interactionType: 'Pharmaceutic',
        flaggedAt: now.subtract(const Duration(days: 1, hours: 8)),
        flaggedBy: 'Pharm. Bello',
      ),
      DrugInteraction(
        drugA: 'Lithium',
        drugB: 'Ibuprofen',
        description: 'Lithium toxicity — NSAIDs reduce renal lithium clearance',
        severity: InteractionSeverity.critical,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(days: 2)),
        flaggedBy: 'Dr. Nkosi',
      ),
      DrugInteraction(
        drugA: 'Digoxin',
        drugB: 'Amiodarone',
        description: 'Digoxin toxicity — amiodarone reduces digoxin clearance by 30%',
        severity: InteractionSeverity.warning,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(days: 2, hours: 6)),
        flaggedBy: 'Pharm. Osei',
      ),
      DrugInteraction(
        drugA: 'Phenytoin',
        drugB: 'Folic Acid',
        description: 'Reduced phenytoin levels — folic acid accelerates phenytoin metabolism',
        severity: InteractionSeverity.info,
        interactionType: 'Pharmacokinetic',
        flaggedAt: now.subtract(const Duration(days: 3)),
        flaggedBy: 'Dr. Kamau',
      ),
      DrugInteraction(
        drugA: 'Alendronate',
        drugB: 'Calcium Supplement',
        description: 'Reduced absorption — take alendronate 30 min before calcium',
        severity: InteractionSeverity.info,
        interactionType: 'Pharmaceutic',
        flaggedAt: now.subtract(const Duration(days: 3, hours: 4)),
        flaggedBy: 'Pharm. Dube',
      ),
      DrugInteraction(
        drugA: 'Trimethoprim',
        drugB: 'Potassium Supplement',
        description: 'Hyperkalemia risk — trimethoprim acts like amiloride on distal tubule',
        severity: InteractionSeverity.warning,
        interactionType: 'Pharmacodynamic',
        flaggedAt: now.subtract(const Duration(days: 4)),
        flaggedBy: 'Dr. Okafor',
      ),
    ];
  }

  List<InteractionRule> get _mockRules {
    return [
      InteractionRule(id: 'R-001', drugA: 'Warfarin', drugB: 'Aspirin', severity: InteractionSeverity.critical, interactionType: 'Pharmacodynamic', description: 'Increased bleeding risk', isActive: true),
      InteractionRule(id: 'R-002', drugA: 'Metformin', drugB: 'Alcohol', severity: InteractionSeverity.critical, interactionType: 'Pharmacodynamic', description: 'Lactic acidosis risk', isActive: true),
      InteractionRule(id: 'R-003', drugA: 'Lisinopril', drugB: 'Potassium Supplement', severity: InteractionSeverity.critical, interactionType: 'Pharmacodynamic', description: 'Hyperkalemia risk', isActive: true),
      InteractionRule(id: 'R-004', drugA: 'Omeprazole', drugB: 'Clopidogrel', severity: InteractionSeverity.critical, interactionType: 'Pharmacokinetic', description: 'Reduced clopidogrel activation', isActive: true),
      InteractionRule(id: 'R-005', drugA: 'Ciprofloxacin', drugB: 'Theophylline', severity: InteractionSeverity.warning, interactionType: 'Pharmacokinetic', description: 'Theophylline toxicity', isActive: true),
      InteractionRule(id: 'R-006', drugA: 'Amlodipine', drugB: 'Simvastatin', severity: InteractionSeverity.warning, interactionType: 'Pharmacokinetic', description: 'Rhabdomyolysis risk', isActive: false),
      InteractionRule(id: 'R-007', drugA: 'Tetracycline', drugB: 'Calcium Supplement', severity: InteractionSeverity.caution, interactionType: 'Pharmaceutic', description: 'Reduced absorption', isActive: true),
      InteractionRule(id: 'R-008', drugA: 'Phenytoin', drugB: 'Folic Acid', severity: InteractionSeverity.info, interactionType: 'Pharmacokinetic', description: 'Reduced phenytoin levels', isActive: true),
    ];
  }

  // ── Severity helpers ──
  Color _severityBg(InteractionSeverity s) {
    switch (s) {
      case InteractionSeverity.critical: return _criticalBg;
      case InteractionSeverity.warning: return _warningBg;
      case InteractionSeverity.caution: return _cautionBg;
      case InteractionSeverity.info: return _infoBg;
    }
  }

  Color _severityText(InteractionSeverity s) {
    switch (s) {
      case InteractionSeverity.critical: return _criticalText;
      case InteractionSeverity.warning: return _warningText;
      case InteractionSeverity.caution: return _cautionText;
      case InteractionSeverity.info: return _infoText;
    }
  }

  Color _severityBadge(InteractionSeverity s) {
    switch (s) {
      case InteractionSeverity.critical: return _criticalBadge;
      case InteractionSeverity.warning: return _warningBadge;
      case InteractionSeverity.caution: return _cautionBadge;
      case InteractionSeverity.info: return _infoBadge;
    }
  }

  IconData _severityIcon(InteractionSeverity s) {
    switch (s) {
      case InteractionSeverity.critical: return Icons.dangerous_outlined;
      case InteractionSeverity.warning: return Icons.warning_amber_rounded;
      case InteractionSeverity.caution: return Icons.info_outline;
      case InteractionSeverity.info: return Icons.lightbulb_outline;
    }
  }

  String _severityLabel(InteractionSeverity s) {
    switch (s) {
      case InteractionSeverity.critical: return 'CRITICAL';
      case InteractionSeverity.warning: return 'WARNING';
      case InteractionSeverity.caution: return 'CAUTION';
      case InteractionSeverity.info: return 'INFO';
    }
  }

  // ── Interaction checker simulation ──
  void _runInteractionCheck() {
    final drugA = _model.drugATextController?.text.trim() ?? '';
    final drugB = _model.drugBTextController?.text.trim() ?? '';
    if (drugA.isEmpty || drugB.isEmpty) return;

    safeSetState(() => _checkerLoading = true);

    // Simulate API lookup delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final allAlerts = _mockAlerts;
      final results = allAlerts.where((a) {
        final aMatch = a.drugA.toLowerCase() == drugA.toLowerCase() ||
            a.drugB.toLowerCase() == drugA.toLowerCase();
        final bMatch = a.drugA.toLowerCase() == drugB.toLowerCase() ||
            a.drugB.toLowerCase() == drugB.toLowerCase();
        return aMatch && bMatch;
      }).toList();

      // If no exact match, generate a hypothetical result
      if (results.isEmpty) {
        results.add(DrugInteraction(
          drugA: drugA,
          drugB: drugB,
          description: 'No known interaction in database — manual review recommended for this combination',
          severity: InteractionSeverity.info,
          interactionType: 'Unknown',
          flaggedAt: DateTime.now(),
          flaggedBy: null,
        ));
      }

      safeSetState(() {
        _checkerResults = results;
        _checkerLoading = false;
      });
    });
  }

  // ── Date formatting ──
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Drug Interaction Alerts',
      color: _duniyaPurple,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: _bgColor,
          drawer: Drawer(
            elevation: 16.0,
            child: wrapWithModel(
              model: _model.sideNavModel2,
              updateCallback: () => safeSetState(() {}),
              child: SideNavWidget(),
            ),
          ),
          body: SafeArea(
            top: true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // ── Sidebar (desktop/tablet) ──
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
                // ── Main content area ──
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top nav
                      wrapWithModel(
                        model: _model.topNavModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TopNavWidget(
                          openDrawer: () async {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                      ),
                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Page Header ──
                              _buildPageHeader(context),
                              const SizedBox(height: 28.0),

                              // ── RBAC Guard ──
                              AuthUserStreamWidget(
                                builder: (context) {
                                  if (!AccessControl.hasPermission(context,
                                      Permission.drugInteractionsView)) {
                                    return _buildNoAccessState();
                                  }
                                  return _buildDashboardContent(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Mobile navbar
                      if (responsiveVisibility(
                        context: context,
                        tablet: false,
                        desktop: true,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: wrapWithModel(
                            model: _model.mobileNavbarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: MobileNavbarWidget(),
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

  // ═══════════════════════════════════════════════════════════════════
  // PAGE HEADER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPageHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: _duniyaPurpleLight,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(Icons.shield_outlined,
                        color: _duniyaPurple, size: 24.0),
                  ),
                  const SizedBox(width: 14.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drug Interaction Alerts',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.02,
                          height: 1.2,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Flag dangerous drug combinations at POS dispensing',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // ── Severity legend ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _legendDot(_criticalBadge, 'Critical'),
              const SizedBox(width: 12.0),
              _legendDot(_warningBadge, 'Warning'),
              const SizedBox(width: 12.0),
              _legendDot(_cautionBadge, 'Caution'),
              const SizedBox(width: 12.0),
              _legendDot(_infoBadge, 'Info'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6.0),
        Text(label,
            style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                color: _textSecondary)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD CONTENT (post-RBAC)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDashboardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 4: Summary Stats (top row) ──
        _buildSummaryStats(context),
        const SizedBox(height: 28.0),

        // ── Section 1: Interaction Checker Panel ──
        _buildInteractionChecker(context),
        const SizedBox(height: 28.0),

        // ── Section 2: Recent Alerts ──
        _buildRecentAlerts(context),
        const SizedBox(height: 28.0),

        // ── Section 3: Rules Database (RBAC-gated) ──
        AuthUserStreamWidget(
          builder: (context) {
            if (AccessControl.hasPermission(context,
                Permission.drugInteractionsManageRules)) {
              return _buildRulesDatabase(context);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 4: SUMMARY STATS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSummaryStats(BuildContext context) {
    final alerts = _mockAlerts;
    final criticalCount = alerts.where((a) => a.severity == InteractionSeverity.critical).length;
    final today = DateTime.now();
    final todayChecks = alerts.where((a) => today.difference(a.flaggedAt).inHours < 24).length;

    // Find most common drug pair
    final pairCounts = <String, int>{};
    for (final a in alerts) {
      final key = a.pair;
      pairCounts[key] = (pairCounts[key] ?? 0) + 1;
    }
    final mostCommonPair = pairCounts.entries.isEmpty
        ? 'N/A'
        : pairCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final animatedValue = _countUpAnimation.value;

    return Row(
      children: [
        Expanded(child: _buildStatCard(
          icon: Icons.search_rounded,
          iconBg: _duniyaPurpleLight,
          iconColor: _duniyaPurple,
          title: 'Checks Today',
          value: (todayChecks * animatedValue).round().toString(),
          subtitle: 'Interaction queries run',
          accentColor: _duniyaPurple,
        )),
        const SizedBox(width: 16.0),
        Expanded(child: _buildStatCard(
          icon: Icons.dangerous_outlined,
          iconBg: _criticalBg,
          iconColor: _criticalBadge,
          title: 'Critical Alerts',
          value: (criticalCount * animatedValue).round().toString(),
          subtitle: 'Require immediate review',
          accentColor: _criticalBadge,
        )),
        const SizedBox(width: 16.0),
        Expanded(child: _buildStatCard(
          icon: Icons.link_rounded,
          iconBg: _cautionBg,
          iconColor: _cautionBadge,
          title: 'Most Common Pair',
          value: mostCommonPair,
          subtitle: 'Highest alert frequency',
          accentColor: _cautionBadge,
          isText: true,
        )),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color accentColor,
    bool isText = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: iconColor, size: 18.0),
              ),
              const SizedBox(width: 10.0),
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: isText ? 16.0 : 28.0,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: -0.02,
              )),
          const SizedBox(height: 4.0),
          Text(subtitle,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              )),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 1: INTERACTION CHECKER PANEL
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildInteractionChecker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.science_outlined,
                    color: _duniyaPurple, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text('Interaction Checker',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  )),
              const Spacer(),
              Text('Enter two drugs to check for interactions',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13.0,
                    color: _textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 20.0),

          // Search fields row
          Row(
            children: [
              // Drug A
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drug A',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        )),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: _model.drugATextController,
                      focusNode: _model.drugAFocusNode,
                      decoration: InputDecoration(
                        hintText: 'e.g. Warfarin',
                        hintStyle: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          color: _textSecondary.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.medication_outlined,
                            color: _duniyaPurple, size: 20.0),
                        filled: true,
                        fillColor: _bgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: _duniyaPurple, width: 1.5),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14.0,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              // Plus icon
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: _duniyaPurpleLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: _duniyaPurple, size: 20.0),
                ),
              ),
              const SizedBox(width: 16.0),
              // Drug B
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Drug B',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        )),
                    const SizedBox(height: 6.0),
                    TextField(
                      controller: _model.drugBTextController,
                      focusNode: _model.drugBFocusNode,
                      decoration: InputDecoration(
                        hintText: 'e.g. Aspirin',
                        hintStyle: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          color: _textSecondary.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(Icons.medication_outlined,
                            color: _duniyaPurple, size: 20.0),
                        filled: true,
                        fillColor: _bgColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: _duniyaPurple, width: 1.5),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14.0,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16.0),
              // Check button
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: SizedBox(
                  height: 46.0,
                  child: ElevatedButton.icon(
                    onPressed: _checkerLoading ? null : _runInteractionCheck,
                    icon: _checkerLoading
                        ? SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.shield_outlined, size: 18.0),
                    label: Text('Check',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _duniyaPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Results
          if (_checkerResults.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check Results',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: _textSecondary,
                      )),
                  const SizedBox(height: 12.0),
                  ..._checkerResults.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildInteractionResultCard(r),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractionResultCard(DrugInteraction interaction) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: _severityBg(interaction.severity),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _severityBadge(interaction.severity).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Severity icon
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: _severityBadge(interaction.severity).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_severityIcon(interaction.severity),
                color: _severityBadge(interaction.severity), size: 20.0),
          ),
          const SizedBox(width: 14.0),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(interaction.pair,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: _severityText(interaction.severity),
                        )),
                    const SizedBox(width: 10.0),
                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _severityBadge(interaction.severity),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(_severityLabel(interaction.severity),
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          )),
                    ),
                    const SizedBox(width: 8.0),
                    // Interaction type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(interaction.interactionType,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary,
                            letterSpacing: 0.3,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(interaction.description,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: _severityText(interaction.severity).withOpacity(0.8),
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 2: RECENT ALERTS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRecentAlerts(BuildContext context) {
    final alerts = _mockAlerts;
    final searchQuery = _model.alertSearchTextController?.text.toLowerCase() ?? '';
    final severityFilter = _model.severityFilterValue;

    List<DrugInteraction> filtered = alerts;
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((a) =>
        a.pair.toLowerCase().contains(searchQuery) ||
        a.description.toLowerCase().contains(searchQuery) ||
        a.interactionType.toLowerCase().contains(searchQuery)
      ).toList();
    }
    if (severityFilter != null && severityFilter != 'All') {
      filtered = filtered.where((a) =>
        _severityLabel(a.severity) == severityFilter
      ).toList();
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _criticalBg,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.notifications_active_outlined,
                    color: _criticalBadge, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text('Recent Alerts',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  )),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text('${filtered.length} alerts',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: _duniyaPurple,
                    )),
              ),
              const Spacer(),
              // Search
              SizedBox(
                width: 220.0,
                height: 38.0,
                child: TextField(
                  controller: _model.alertSearchTextController,
                  focusNode: _model.alertSearchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search alerts...',
                    hintStyle: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      color: _textSecondary.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(Icons.search, color: _textSecondary, size: 18.0),
                    filled: true,
                    fillColor: _bgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: _duniyaPurple, width: 1.5),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13.0,
                    color: _textPrimary,
                  ),
                  onChanged: (val) => safeSetState(() {}),
                ),
              ),
              const SizedBox(width: 12.0),
              // Severity filter dropdown
              SizedBox(
                width: 140.0,
                height: 38.0,
                child: FlutterFlowDropDown<String>(
                  controller: _model.severityFilterController,
                  options: const ['All', 'CRITICAL', 'WARNING', 'CAUTION', 'INFO'],
                  onChanged: (val) => safeSetState(() {
                    _model.severityFilterValue = val;
                  }),
                  width: 140.0,
                  height: 38.0,
                  textStyle: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13.0,
                    color: _textPrimary,
                  ),
                  hintText: 'Severity',
                  icon: Icon(Icons.filter_list, color: _textSecondary, size: 16.0),
                  fillColor: _bgColor,
                  elevation: 0,
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  borderRadius: 10.0,
                  margin: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Alert cards
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 48.0),
                    const SizedBox(height: 12.0),
                    Text('No interactions match your filter',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14.0,
                          color: _textSecondary,
                        )),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildAlertCard(alert),
            )),
        ],
      ),
    );
  }

  Widget _buildAlertCard(DrugInteraction alert) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _severityBadge(alert.severity).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Severity indicator bar
          Container(
            width: 4.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: _severityBadge(alert.severity),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(width: 14.0),
          // Icon
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: _severityBg(alert.severity),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(_severityIcon(alert.severity),
                color: _severityBadge(alert.severity), size: 22.0),
          ),
          const SizedBox(width: 14.0),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(alert.pair,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        )),
                    const SizedBox(width: 10.0),
                    // Severity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _severityBadge(alert.severity),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(_severityLabel(alert.severity),
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          )),
                    ),
                    const SizedBox(width: 8.0),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _duniyaPurpleLight,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(alert.interactionType,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w500,
                            color: _duniyaPurple,
                            letterSpacing: 0.3,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(alert.description,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 14.0),
          // Meta column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatDate(alert.flaggedAt),
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  )),
              const SizedBox(height: 4.0),
              if (alert.flaggedBy != null)
                Text(alert.flaggedBy!,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary.withOpacity(0.7),
                    )),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // SECTION 3: RULES DATABASE (RBAC-gated)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRulesDatabase(BuildContext context) {
    final rules = _mockRules;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.rule_rounded,
                    color: _duniyaPurple, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text('Rules Database',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                  )),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text('${rules.length} rules',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: _duniyaPurple,
                    )),
              ),
              const Spacer(),
              // Add rule button
              SizedBox(
                height: 36.0,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Add Rule — coming soon'),
                        backgroundColor: _duniyaPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16.0),
                  label: Text('Add Rule',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _duniyaPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Row(
              children: [
                _tableHeaderCell('ID', 70.0),
                _tableHeaderCell('Drug A', 110.0),
                _tableHeaderCell('Drug B', 110.0),
                _tableHeaderCell('Severity', 90.0),
                _tableHeaderCell('Type', 120.0),
                _tableHeaderCell('Description', null),
                _tableHeaderCell('Status', 80.0),
                _tableHeaderCell('Actions', 90.0),
              ],
            ),
          ),

          // Table rows
          ...rules.asMap().entries.map((entry) {
            final i = entry.key;
            final rule = entry.value;
            final isLast = i == rules.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: i.isOdd ? _bgColor : _surfaceColor,
                borderRadius: isLast
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      )
                    : BorderRadius.zero,
                border: Border(
                  bottom: BorderSide(color: _borderColor.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  // ID
                  SizedBox(
                    width: 70.0,
                    child: Text(rule.id,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        )),
                  ),
                  // Drug A
                  SizedBox(
                    width: 110.0,
                    child: Text(rule.drugA,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        )),
                  ),
                  // Drug B
                  SizedBox(
                    width: 110.0,
                    child: Text(rule.drugB,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        )),
                  ),
                  // Severity
                  SizedBox(
                    width: 90.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _severityBadge(rule.severity),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(_severityLabel(rule.severity),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          )),
                    ),
                  ),
                  // Type
                  SizedBox(
                    width: 120.0,
                    child: Text(rule.interactionType,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                        )),
                  ),
                  // Description
                  Expanded(
                    child: Text(rule.description,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: _textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  // Status
                  SizedBox(
                    width: 80.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: rule.isActive ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(rule.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                              color: rule.isActive ? Colors.green : Colors.grey,
                            )),
                      ],
                    ),
                  ),
                  // Actions
                  SizedBox(
                    width: 90.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconActionButton(
                          icon: Icons.edit_outlined,
                          color: _duniyaPurple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Edit ${rule.id} — coming soon'),
                                backgroundColor: _duniyaPurple,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8.0),
                        _iconActionButton(
                          icon: Icons.delete_outline,
                          color: _criticalBadge,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Delete ${rule.id} — coming soon'),
                                backgroundColor: _criticalBadge,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeaderCell(String label, double? width) {
    final child = Text(label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          color: _textSecondary,
          letterSpacing: 0.5,
        ));
    if (width == null) {
      return Expanded(child: child);
    }
    return SizedBox(width: width, child: child);
  }

  Widget _iconActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16.0),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // NO ACCESS STATE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNoAccessState() {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.0,
              height: 72.0,
              decoration: BoxDecoration(
                color: _duniyaPurpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline,
                  color: _duniyaPurple, size: 36.0),
            ),
            const SizedBox(height: 20.0),
            Text('Access Restricted',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 8.0),
            Text(
                'You don\'t have permission to view drug interaction alerts.\nContact your administrator for access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14.0,
                    color: _textSecondary,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }
}
