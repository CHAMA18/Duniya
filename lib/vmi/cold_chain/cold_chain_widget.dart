import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cold_chain_model.dart';
export 'cold_chain_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// COLD CHAIN MONITORING
// Monitor temperature-sensitive storage units, track excursions,
// manage sensors, and ensure product integrity.
// ═══════════════════════════════════════════════════════════════════════

class ColdChainWidget extends StatefulWidget {
  const ColdChainWidget({super.key});

  static String routeName = 'ColdChain';
  static String routePath = '/cold-chain';

  @override
  State<ColdChainWidget> createState() => _ColdChainWidgetState();
}

// ── Temperature status enum ──
enum TempStatus { normal, warning, critical, offline }

// ── Storage unit type ──
enum StorageUnitType { fridge, freezer, room }

// ── Mock data: Storage Unit ──
class StorageUnit {
  final String id;
  final String name;
  final StorageUnitType type;
  final double currentTemp;
  final double minRange;
  final double maxRange;
  final TempStatus status;
  final String sensorId;
  final int sensorBattery;
  final DateTime lastReading;
  final DateTime? calibrationDate;
  final List<double> last24h; // mini chart data (24 hourly points)
  final List<String> products;

  StorageUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.currentTemp,
    required this.minRange,
    required this.maxRange,
    required this.status,
    required this.sensorId,
    required this.sensorBattery,
    required this.lastReading,
    this.calibrationDate,
    required this.last24h,
    required this.products,
  });

  bool get inRange => currentTemp >= minRange && currentTemp <= maxRange;
}

// ── Mock data: Temperature Alert ──
class TempAlert {
  final String id;
  final String unitName;
  final String severity;
  final double recordedTemp;
  final double expectedMax;
  final Duration duration;
  final List<String> affectedProducts;
  final DateTime startedAt;
  bool acknowledged;

  TempAlert({
    required this.id,
    required this.unitName,
    required this.severity,
    required this.recordedTemp,
    required this.expectedMax,
    required this.duration,
    required this.affectedProducts,
    required this.startedAt,
    this.acknowledged = false,
  });
}

// ── Mock data: Sensor ──
class Sensor {
  final String id;
  final String? assignedUnit;
  final String model;
  final DateTime calibrationDate;
  final int batteryLevel;
  final bool isActive;

  Sensor({
    required this.id,
    this.assignedUnit,
    required this.model,
    required this.calibrationDate,
    required this.batteryLevel,
    required this.isActive,
  });
}

class _ColdChainWidgetState extends State<ColdChainWidget>
    with TickerProviderStateMixin {
  late ColdChainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Pulse Purple design tokens ──
  static const Color _pulsePurple = Color(0xFF9900FF);
  static const Color _pulsePurpleLight = Color(0xFFF3F0FF);
  static const Color _pulsePurpleDark = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF8F9FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0B1C30);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  // ── Temperature status colours ──
  static const Color _normalColor = Color(0xFF10B981);
  static const Color _normalBg = Color(0xFFD1FAE5);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _warningBg = Color(0xFFFEF3C7);
  static const Color _criticalColor = Color(0xFFEF4444);
  static const Color _criticalBg = Color(0xFFFEE2E2);
  static const Color _offlineColor = Color(0xFF9CA3AF);
  static const Color _offlineBg = Color(0xFFF3F4F6);

  // ── Animation controller for pulsing dots ──
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Mock storage units ──
  final List<StorageUnit> _storageUnits = [];
  final List<TempAlert> _alerts = [];
  final List<Sensor> _sensors = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ColdChainModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'ColdChain'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    // Pulsing animation for alert dots
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadMockData();
  }

  @override
  void dispose() {
    _model.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Mock Data ──
  void _loadMockData() {
    final now = DateTime.now();
    _storageUnits.addAll([
      StorageUnit(
        id: 'u1',
        name: 'Fridge A – Vaccines',
        type: StorageUnitType.fridge,
        currentTemp: 3.2,
        minRange: 2.0,
        maxRange: 8.0,
        status: TempStatus.normal,
        sensorId: 'SN-001',
        sensorBattery: 92,
        lastReading: now.subtract(Duration(minutes: 5)),
        calibrationDate: now.add(Duration(days: 45)),
        last24h: [
          3.0,
          3.1,
          3.2,
          3.1,
          3.3,
          3.2,
          3.4,
          3.3,
          3.2,
          3.1,
          3.0,
          3.2,
          3.3,
          3.4,
          3.2,
          3.1,
          3.0,
          3.2,
          3.3,
          3.2,
          3.1,
          3.2,
          3.3,
          3.2
        ],
        products: ['BCG Vaccine', 'OPV', 'Hep B'],
      ),
      StorageUnit(
        id: 'u2',
        name: 'Fridge B – Insulin',
        type: StorageUnitType.fridge,
        currentTemp: 7.8,
        minRange: 2.0,
        maxRange: 8.0,
        status: TempStatus.warning,
        sensorId: 'SN-002',
        sensorBattery: 67,
        lastReading: now.subtract(Duration(minutes: 3)),
        calibrationDate: now.add(Duration(days: 12)),
        last24h: [
          5.2,
          5.4,
          5.8,
          6.1,
          6.3,
          6.5,
          6.8,
          7.0,
          7.1,
          7.2,
          7.3,
          7.4,
          7.5,
          7.3,
          7.4,
          7.5,
          7.6,
          7.7,
          7.5,
          7.6,
          7.7,
          7.8,
          7.6,
          7.8
        ],
        products: ['Insulin Glargine', 'Insulin Lispro'],
      ),
      StorageUnit(
        id: 'u3',
        name: 'Freezer A – MMR',
        type: StorageUnitType.freezer,
        currentTemp: -18.5,
        minRange: -25.0,
        maxRange: -15.0,
        status: TempStatus.normal,
        sensorId: 'SN-003',
        sensorBattery: 88,
        lastReading: now.subtract(Duration(minutes: 2)),
        calibrationDate: now.add(Duration(days: 90)),
        last24h: [
          -18.0,
          -18.2,
          -18.3,
          -18.5,
          -18.4,
          -18.3,
          -18.5,
          -18.6,
          -18.4,
          -18.5,
          -18.3,
          -18.2,
          -18.4,
          -18.5,
          -18.6,
          -18.5,
          -18.4,
          -18.3,
          -18.5,
          -18.6,
          -18.4,
          -18.5,
          -18.3,
          -18.5
        ],
        products: ['MMR Vaccine', 'Varicella Vaccine'],
      ),
      StorageUnit(
        id: 'u4',
        name: 'Freezer B – Frozen Products',
        type: StorageUnitType.freezer,
        currentTemp: -12.0,
        minRange: -25.0,
        maxRange: -15.0,
        status: TempStatus.critical,
        sensorId: 'SN-004',
        sensorBattery: 34,
        lastReading: now.subtract(Duration(minutes: 8)),
        calibrationDate: now.subtract(Duration(days: 5)),
        last24h: [
          -20.0,
          -19.5,
          -18.8,
          -17.5,
          -16.2,
          -15.8,
          -15.0,
          -14.5,
          -14.0,
          -13.8,
          -13.5,
          -13.2,
          -13.0,
          -12.8,
          -12.5,
          -12.3,
          -12.0,
          -12.2,
          -12.0,
          -11.8,
          -12.0,
          -12.1,
          -12.0,
          -12.0
        ],
        products: ['Pfizer COVID-19', 'Meningococcal ACWY'],
      ),
      StorageUnit(
        id: 'u5',
        name: 'Room Store – Oral Rehydration',
        type: StorageUnitType.room,
        currentTemp: 24.5,
        minRange: 15.0,
        maxRange: 30.0,
        status: TempStatus.normal,
        sensorId: 'SN-005',
        sensorBattery: 95,
        lastReading: now.subtract(Duration(minutes: 1)),
        calibrationDate: now.add(Duration(days: 120)),
        last24h: [
          23.0,
          23.2,
          23.5,
          23.8,
          24.0,
          24.2,
          24.5,
          24.3,
          24.2,
          24.0,
          23.8,
          23.5,
          23.2,
          23.5,
          23.8,
          24.0,
          24.2,
          24.5,
          24.3,
          24.5,
          24.3,
          24.2,
          24.4,
          24.5
        ],
        products: ['ORS Sachets', 'Zinc Tablets', 'Vitamin A'],
      ),
      StorageUnit(
        id: 'u6',
        name: 'Fridge C – Lab Reagents',
        type: StorageUnitType.fridge,
        currentTemp: 4.5,
        minRange: 2.0,
        maxRange: 8.0,
        status: TempStatus.normal,
        sensorId: 'SN-006',
        sensorBattery: 78,
        lastReading: now.subtract(Duration(minutes: 4)),
        calibrationDate: now.add(Duration(days: 60)),
        last24h: [
          4.0,
          4.1,
          4.2,
          4.3,
          4.2,
          4.1,
          4.0,
          4.2,
          4.3,
          4.4,
          4.5,
          4.4,
          4.3,
          4.2,
          4.1,
          4.3,
          4.4,
          4.5,
          4.4,
          4.3,
          4.5,
          4.4,
          4.3,
          4.5
        ],
        products: ['Rapid Test Kits', 'HbA1c Reagent'],
      ),
      StorageUnit(
        id: 'u7',
        name: 'Fridge D – Blood Products',
        type: StorageUnitType.fridge,
        currentTemp: 9.5,
        minRange: 2.0,
        maxRange: 6.0,
        status: TempStatus.critical,
        sensorId: 'SN-007',
        sensorBattery: 45,
        lastReading: now.subtract(Duration(minutes: 6)),
        calibrationDate: now.add(Duration(days: 30)),
        last24h: [
          4.0,
          4.5,
          5.0,
          5.5,
          6.0,
          6.5,
          7.0,
          7.5,
          8.0,
          8.5,
          8.8,
          9.0,
          9.2,
          9.0,
          9.3,
          9.5,
          9.3,
          9.2,
          9.5,
          9.4,
          9.5,
          9.3,
          9.4,
          9.5
        ],
        products: ['Whole Blood', 'Plasma', 'Platelets'],
      ),
      StorageUnit(
        id: 'u8',
        name: 'Room Store 2 – Topicals',
        type: StorageUnitType.room,
        currentTemp: 28.5,
        minRange: 15.0,
        maxRange: 25.0,
        status: TempStatus.warning,
        sensorId: 'SN-008',
        sensorBattery: 15,
        lastReading: now.subtract(Duration(hours: 1)),
        calibrationDate: now.add(Duration(days: 75)),
        last24h: [
          22.0,
          22.5,
          23.0,
          23.5,
          24.0,
          24.5,
          25.0,
          25.5,
          26.0,
          26.5,
          27.0,
          27.5,
          27.8,
          28.0,
          28.2,
          28.5,
          28.3,
          28.0,
          28.2,
          28.5,
          28.3,
          28.4,
          28.5,
          28.5
        ],
        products: ['Hydrocortisone Cream', 'Clotrimazole'],
      ),
      StorageUnit(
        id: 'u9',
        name: 'Fridge E – Diluents',
        type: StorageUnitType.fridge,
        currentTemp: 5.0,
        minRange: 2.0,
        maxRange: 8.0,
        status: TempStatus.normal,
        sensorId: 'SN-009',
        sensorBattery: 82,
        lastReading: now.subtract(Duration(minutes: 7)),
        calibrationDate: now.add(Duration(days: 55)),
        last24h: [
          4.8,
          4.9,
          5.0,
          5.1,
          5.0,
          4.9,
          4.8,
          5.0,
          5.1,
          5.2,
          5.0,
          4.9,
          5.0,
          5.1,
          5.0,
          4.9,
          5.0,
          5.1,
          5.0,
          5.1,
          5.0,
          4.9,
          5.0,
          5.0
        ],
        products: ['Sterile Water', 'NaCl 0.9%'],
      ),
      StorageUnit(
        id: 'u10',
        name: 'Freezer C – Polio',
        type: StorageUnitType.freezer,
        currentTemp: 0.0,
        minRange: -25.0,
        maxRange: -15.0,
        status: TempStatus.offline,
        sensorId: 'SN-010',
        sensorBattery: 0,
        lastReading: now.subtract(Duration(hours: 3)),
        calibrationDate: now.subtract(Duration(days: 30)),
        last24h: List.filled(24, -20.0),
        products: ['OPV Bulk', 'IPV'],
      ),
    ]);

    _alerts.addAll([
      TempAlert(
        id: 'a1',
        unitName: 'Freezer B – Frozen Products',
        severity: 'Critical',
        recordedTemp: -12.0,
        expectedMax: -15.0,
        duration: Duration(hours: 4, minutes: 32),
        affectedProducts: ['Pfizer COVID-19', 'Meningococcal ACWY'],
        startedAt: now.subtract(Duration(hours: 4, minutes: 32)),
      ),
      TempAlert(
        id: 'a2',
        unitName: 'Fridge D – Blood Products',
        severity: 'Critical',
        recordedTemp: 9.5,
        expectedMax: 6.0,
        duration: Duration(hours: 2, minutes: 15),
        affectedProducts: ['Whole Blood', 'Plasma', 'Platelets'],
        startedAt: now.subtract(Duration(hours: 2, minutes: 15)),
      ),
      TempAlert(
        id: 'a3',
        unitName: 'Fridge B – Insulin',
        severity: 'Warning',
        recordedTemp: 7.8,
        expectedMax: 8.0,
        duration: Duration(minutes: 45),
        affectedProducts: ['Insulin Glargine', 'Insulin Lispro'],
        startedAt: now.subtract(Duration(minutes: 45)),
      ),
      TempAlert(
        id: 'a4',
        unitName: 'Room Store 2 – Topicals',
        severity: 'Warning',
        recordedTemp: 28.5,
        expectedMax: 25.0,
        duration: Duration(hours: 1, minutes: 10),
        affectedProducts: ['Hydrocortisone Cream', 'Clotrimazole'],
        startedAt: now.subtract(Duration(hours: 1, minutes: 10)),
      ),
    ]);

    _sensors.addAll([
      Sensor(
          id: 'SN-001',
          assignedUnit: 'Fridge A – Vaccines',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 45)),
          batteryLevel: 92,
          isActive: true),
      Sensor(
          id: 'SN-002',
          assignedUnit: 'Fridge B – Insulin',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 12)),
          batteryLevel: 67,
          isActive: true),
      Sensor(
          id: 'SN-003',
          assignedUnit: 'Freezer A – MMR',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 90)),
          batteryLevel: 88,
          isActive: true),
      Sensor(
          id: 'SN-004',
          assignedUnit: 'Freezer B – Frozen Products',
          model: 'TempTale4',
          calibrationDate: now.subtract(Duration(days: 5)),
          batteryLevel: 34,
          isActive: true),
      Sensor(
          id: 'SN-005',
          assignedUnit: 'Room Store – Oral Rehydration',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 120)),
          batteryLevel: 95,
          isActive: true),
      Sensor(
          id: 'SN-006',
          assignedUnit: 'Fridge C – Lab Reagents',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 60)),
          batteryLevel: 78,
          isActive: true),
      Sensor(
          id: 'SN-007',
          assignedUnit: 'Fridge D – Blood Products',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 30)),
          batteryLevel: 45,
          isActive: true),
      Sensor(
          id: 'SN-008',
          assignedUnit: 'Room Store 2 – Topicals',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 75)),
          batteryLevel: 15,
          isActive: true),
      Sensor(
          id: 'SN-009',
          assignedUnit: 'Fridge E – Diluents',
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 55)),
          batteryLevel: 82,
          isActive: true),
      Sensor(
          id: 'SN-010',
          assignedUnit: 'Freezer C – Polio',
          model: 'TempTale4',
          calibrationDate: now.subtract(Duration(days: 30)),
          batteryLevel: 0,
          isActive: false),
      Sensor(
          id: 'SN-011',
          assignedUnit: null,
          model: 'TempTale4',
          calibrationDate: now.add(Duration(days: 180)),
          batteryLevel: 100,
          isActive: false),
    ]);
  }

  // ── Status helpers ──
  Color _statusColor(TempStatus s) {
    switch (s) {
      case TempStatus.normal:
        return _normalColor;
      case TempStatus.warning:
        return _warningColor;
      case TempStatus.critical:
        return _criticalColor;
      case TempStatus.offline:
        return _offlineColor;
    }
  }

  Color _statusBg(TempStatus s) {
    switch (s) {
      case TempStatus.normal:
        return _normalBg;
      case TempStatus.warning:
        return _warningBg;
      case TempStatus.critical:
        return _criticalBg;
      case TempStatus.offline:
        return _offlineBg;
    }
  }

  String _statusLabel(TempStatus s) {
    switch (s) {
      case TempStatus.normal:
        return 'Normal';
      case TempStatus.warning:
        return 'Warning';
      case TempStatus.critical:
        return 'Critical';
      case TempStatus.offline:
        return 'Offline';
    }
  }

  IconData _unitTypeIcon(StorageUnitType t) {
    switch (t) {
      case StorageUnitType.fridge:
        return Icons.kitchen;
      case StorageUnitType.freezer:
        return Icons.ac_unit;
      case StorageUnitType.room:
        return Icons.meeting_room;
    }
  }

  String _unitTypeLabel(StorageUnitType t) {
    switch (t) {
      case StorageUnitType.fridge:
        return 'Fridge';
      case StorageUnitType.freezer:
        return 'Freezer';
      case StorageUnitType.room:
        return 'Room';
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Cold Chain Monitoring',
      color: _pulsePurple,
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
                // Sidebar (desktop/tablet)
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
                // Main content area
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
                              _buildPageHeader(),
                              const SizedBox(height: 28.0),

                              // ── RBAC Guard ──
                              AuthUserStreamWidget(
                                builder: (context) {
                                  if (!AccessControl.hasPermission(
                                      context, Permission.coldChainView)) {
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

  // ── Page Header ──
  Widget _buildPageHeader() {
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
                      color: _pulsePurpleLight,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(Icons.thermostat,
                        color: _pulsePurple, size: 24.0),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Cold Chain Monitoring',
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 32.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.02,
                      height: 1.2,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.only(left: 46.0),
                child: Text(
                  'Monitor temperature-sensitive storage, track excursions, and ensure product integrity.',
                  style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── No Access State ──
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
                color: _pulsePurpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, color: _pulsePurple, size: 36.0),
            ),
            const SizedBox(height: 20.0),
            Text('Access Restricted',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            const SizedBox(height: 8.0),
            Text(
                "You don't have permission to view cold chain monitoring.\nContact your administrator for access.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }

  // ── Dashboard Content ──
  Widget _buildDashboardContent(BuildContext context) {
    final canViewAlerts =
        AccessControl.hasPermission(context, Permission.coldChainViewAlerts);
    final canManageSensors =
        AccessControl.hasPermission(context, Permission.coldChainManageSensors);

    // Summary stats
    final monitoredUnits = _storageUnits.length;
    final inRange =
        _storageUnits.where((u) => u.status == TempStatus.normal).length;
    final tempAlerts = _storageUnits
        .where((u) =>
            u.status == TempStatus.warning || u.status == TempStatus.critical)
        .length;
    final lastReading = _storageUnits.isEmpty
        ? null
        : _storageUnits
            .map((u) => u.lastReading)
            .reduce((a, b) => a.isAfter(b) ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Summary Stats ──
        _buildSummaryStats(monitoredUnits, inRange, tempAlerts, lastReading),
        const SizedBox(height: 28.0),

        // ── Section 2: Temperature Monitoring Grid ──
        _buildTemperatureGrid(),
        const SizedBox(height: 28.0),

        // ── Section 3: Active Alerts ──
        if (canViewAlerts) ...[
          _buildActiveAlerts(),
          const SizedBox(height: 28.0),
        ],

        // ── Section 4: Sensor Management ──
        if (canManageSensors) _buildSensorManagement(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 1: Summary Stats
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSummaryStats(
      int monitored, int inRange, int alerts, DateTime? lastReading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardSpacing = 16.0;
        double minCardWidth = 180.0;
        int cols = (constraints.maxWidth / (minCardWidth + cardSpacing))
            .clamp(1, 4)
            .toInt();
        double cardWidth =
            (constraints.maxWidth - cardSpacing * (cols - 1)) / cols;

        return Wrap(
          spacing: cardSpacing,
          runSpacing: cardSpacing,
          children: [
            SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  title: 'Monitored Units',
                  value: monitored.toString(),
                  icon: Icons.sensors,
                  bgColor: _pulsePurpleLight,
                  iconColor: _pulsePurple,
                  textColor: _pulsePurpleDark,
                )),
            SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  title: 'In Range',
                  value: inRange.toString(),
                  icon: Icons.check_circle,
                  bgColor: _pulsePurpleLight,
                  iconColor: _pulsePurple,
                  textColor: _pulsePurpleDark,
                )),
            SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  title: 'Temperature Alerts',
                  value: alerts.toString(),
                  icon: Icons.warning_amber_rounded,
                  bgColor: _pulsePurpleLight,
                  iconColor: _pulsePurple,
                  textColor: _pulsePurpleDark,
                )),
            SizedBox(
                width: cardWidth,
                child: _buildStatCard(
                  title: 'Last Reading',
                  value: lastReading == null
                      ? 'No data'
                      : _formatTimeAgo(lastReading),
                  icon: Icons.schedule,
                  bgColor: _pulsePurpleLight,
                  iconColor: _pulsePurple,
                  textColor: _pulsePurpleDark,
                )),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, size: 20.0, color: iconColor),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 2: Temperature Monitoring Grid
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTemperatureGrid() {
    // Filter by search
    final searchQuery = _model.searchTextController?.text.toLowerCase() ?? '';
    List<StorageUnit> filtered = _storageUnits.where((u) {
      if (searchQuery.isNotEmpty) {
        return u.name.toLowerCase().contains(searchQuery) ||
            u.sensorId.toLowerCase().contains(searchQuery);
      }
      return true;
    }).toList();

    // Sort: critical first, then warning, then offline, then normal
    final statusOrder = {
      TempStatus.critical: 0,
      TempStatus.warning: 1,
      TempStatus.offline: 2,
      TempStatus.normal: 3
    };
    filtered.sort((a, b) =>
        (statusOrder[a.status] ?? 4).compareTo(statusOrder[b.status] ?? 4));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Temperature Monitoring',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
            // Search field
            SizedBox(
              width: 260.0,
              child: TextField(
                controller: _model.searchTextController,
                focusNode: _model.searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search units...',
                  hintStyle: TextStyle(
                      fontFamily: kAppFontFamily,
                      color: _textSecondary,
                      fontSize: 14.0),
                  prefixIcon:
                      Icon(Icons.search, color: _pulsePurple, size: 20.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: _borderColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: _pulsePurple, width: 2.0)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 10.0),
                  filled: true,
                  fillColor: _surfaceColor,
                ),
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textPrimary),
                onChanged: (val) => safeSetState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        // Grid of storage unit cards
        LayoutBuilder(
          builder: (context, constraints) {
            if (filtered.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    Icon(Icons.thermostat_auto_outlined,
                        size: 44.0, color: _pulsePurple),
                    const SizedBox(height: 12.0),
                    Text(
                      _storageUnits.isEmpty
                          ? 'No storage units configured'
                          : 'No storage units match your search',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      _storageUnits.isEmpty
                          ? 'Connect a temperature sensor to begin monitoring your cold chain.'
                          : 'Try a different unit name or sensor ID.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13.0,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            double cardSpacing = 16.0;
            double minCardWidth = 340.0;
            int cols = (constraints.maxWidth / (minCardWidth + cardSpacing))
                .clamp(1, 3)
                .toInt();
            double cardWidth =
                (constraints.maxWidth - cardSpacing * (cols - 1)) / cols;

            return Wrap(
              spacing: cardSpacing,
              runSpacing: cardSpacing,
              children: filtered
                  .map((unit) => SizedBox(
                        width: cardWidth,
                        child: _buildStorageUnitCard(unit),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageUnitCard(StorageUnit unit) {
    final color = _statusColor(unit.status);
    final bgColor = _statusBg(unit.status);
    final isAlert =
        unit.status == TempStatus.warning || unit.status == TempStatus.critical;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
            color: isAlert ? color.withValues(alpha: 0.4) : _borderColor,
            width: isAlert ? 2.0 : 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Unit name + status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(_unitTypeIcon(unit.type), size: 18.0, color: color),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(unit.name,
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              // Status badge with pulsing dot for alerts
              _buildStatusBadge(unit.status, isAlert),
            ],
          ),
          const SizedBox(height: 16.0),

          // Row 2: Current temperature (big number)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${unit.currentTemp.toStringAsFixed(1)}°C',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 28.0,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.0)),
              const SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                    'Range: ${unit.minRange.toStringAsFixed(0)}°C to ${unit.maxRange.toStringAsFixed(0)}°C',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        color: _textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Row 3: Mini 24h chart
          _buildMiniChart(unit, color),
          const SizedBox(height: 12.0),

          // Row 4: Sensor info
          Row(
            children: [
              Icon(Icons.sensors, size: 14.0, color: _textSecondary),
              const SizedBox(width: 4.0),
              Text(unit.sensorId,
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 11.0,
                      color: _textSecondary)),
              const Spacer(),
              Icon(Icons.battery_std,
                  size: 14.0,
                  color: unit.sensorBattery < 25
                      ? _criticalColor
                      : _textSecondary),
              const SizedBox(width: 4.0),
              Text('${unit.sensorBattery}%',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 11.0,
                      color: unit.sensorBattery < 25
                          ? _criticalColor
                          : _textSecondary)),
              const SizedBox(width: 12.0),
              Icon(Icons.access_time, size: 14.0, color: _textSecondary),
              const SizedBox(width: 4.0),
              Text(_formatTimeAgo(unit.lastReading),
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 11.0,
                      color: _textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TempStatus status, bool isAlert) {
    final color = _statusColor(status);
    final bgColor = _statusBg(status);
    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999.0),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAlert)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          color.withValues(alpha: _pulseAnimation.value * 0.6),
                      blurRadius: 6.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              ),
            )
          else
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
                  fontFamily: kAppFontFamily,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Mini 24h sparkline chart using CustomPainter ──
  Widget _buildMiniChart(StorageUnit unit, Color accentColor) {
    return SizedBox(
      height: 48.0,
      child: CustomPaint(
        painter: _SparklinePainter(
          data: unit.last24h,
          minRange: unit.minRange,
          maxRange: unit.maxRange,
          lineColor: accentColor,
          rangeColor: _normalColor.withValues(alpha: 0.1),
          outOfRangeColor: _criticalColor.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 3: Active Alerts
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildActiveAlerts() {
    final unacknowledged = _alerts.where((a) => !a.acknowledged).toList();
    final acknowledged = _alerts.where((a) => a.acknowledged).toList();

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              color: _pulsePurple.withValues(alpha: 0.06),
              border:
                  Border(bottom: BorderSide(color: _borderColor, width: 1.0)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: _pulsePurple, size: 20.0),
                const SizedBox(width: 10.0),
                Text('Active Temperature Alerts',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: unacknowledged.isNotEmpty ? _criticalBg : _normalBg,
                    borderRadius: BorderRadius.circular(9999.0),
                  ),
                  child: Text('${unacknowledged.length} active',
                      style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: unacknowledged.isNotEmpty
                              ? _criticalColor
                              : _normalColor)),
                ),
              ],
            ),
          ),

          // Alert rows
          if (_alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48.0, color: _normalColor),
                    const SizedBox(height: 12.0),
                    Text('No active alerts — all units in range',
                        style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 14.0,
                            color: _textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...unacknowledged.map((alert) => _buildAlertRow(alert)),
          ...acknowledged.map((alert) => _buildAlertRow(alert)),
        ],
      ),
    );
  }

  Widget _buildAlertRow(TempAlert alert) {
    final isCritical = alert.severity == 'Critical';
    final color = isCritical ? _criticalColor : _warningColor;
    final bgColor = isCritical ? _criticalBg : _warningBg;

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 14.0),
      decoration: BoxDecoration(
        color:
            alert.acknowledged ? Colors.white : bgColor.withValues(alpha: 0.4),
        border: Border(
            bottom: BorderSide(
                color: _borderColor.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          // Pulsing indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: alert.acknowledged ? _offlineColor : color,
                shape: BoxShape.circle,
                boxShadow: alert.acknowledged
                    ? null
                    : [
                        BoxShadow(
                          color: color.withValues(
                              alpha: _pulseAnimation.value * 0.5),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ],
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          // Severity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(alert.severity,
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
          const SizedBox(width: 14.0),
          // Unit name + temp
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.unitName,
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                const SizedBox(height: 2.0),
                Text(
                    'Recorded: ${alert.recordedTemp.toStringAsFixed(1)}°C (max: ${alert.expectedMax.toStringAsFixed(1)}°C)',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 11.0,
                        color: _textSecondary)),
              ],
            ),
          ),
          // Duration
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_formatDuration(alert.duration),
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const SizedBox(height: 2.0),
                Text('Duration',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 10.0,
                        color: _textSecondary)),
              ],
            ),
          ),
          // Affected products
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${alert.affectedProducts.length} products affected',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary)),
                const SizedBox(height: 2.0),
                Text(alert.affectedProducts.join(', '),
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 10.0,
                        color: _textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Acknowledge button
          if (!alert.acknowledged)
            ElevatedButton(
              onPressed: () {
                safeSetState(() => alert.acknowledged = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pulsePurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              ),
              child: Text('Acknowledge',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600)),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: _normalBg,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text('Acknowledged',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: _normalColor)),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 4: Sensor Management
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSensorManagement() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
            decoration: BoxDecoration(
              color: _pulsePurple.withValues(alpha: 0.06),
              border:
                  Border(bottom: BorderSide(color: _borderColor, width: 1.0)),
            ),
            child: Row(
              children: [
                Icon(Icons.settings_input_antenna,
                    color: _pulsePurple, size: 20.0),
                const SizedBox(width: 10.0),
                Text('Sensor Management',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showRegisterSensorDialog(context),
                  icon: Icon(Icons.add, size: 16.0),
                  label: Text('Register Sensor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pulsePurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999.0)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                  ),
                ),
              ],
            ),
          ),

          // Table header
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
            decoration: BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: _borderColor, width: 1.0)),
            ),
            child: Row(
              children: [
                _sensorHeaderCell('Sensor ID', 1.2),
                _sensorHeaderCell('Assigned Unit', 2.0),
                _sensorHeaderCell('Model', 0.8),
                _sensorHeaderCell('Calibration', 1.0),
                _sensorHeaderCell('Battery', 0.7),
                _sensorHeaderCell('Status', 0.7),
              ],
            ),
          ),

          // Sensor rows
          ..._sensors.map((sensor) => _buildSensorRow(sensor)),
        ],
      ),
    );
  }

  Widget _sensorHeaderCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(text,
          style: TextStyle(
              fontFamily: kAppFontFamily,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
              letterSpacing: 0.04)),
    );
  }

  Widget _buildSensorRow(Sensor sensor) {
    final calDays = sensor.calibrationDate.difference(DateTime.now()).inDays;
    final calColor = calDays < 0
        ? _criticalColor
        : calDays < 30
            ? _warningColor
            : _normalColor;
    final battColor = sensor.batteryLevel < 20
        ? _criticalColor
        : sensor.batteryLevel < 50
            ? _warningColor
            : _normalColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: _borderColor.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        children: [
          // Sensor ID
          Expanded(
            flex: 12,
            child: Text(sensor.id,
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
          ),
          // Assigned unit
          Expanded(
            flex: 20,
            child: Text(sensor.assignedUnit ?? 'Unassigned',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    color: sensor.assignedUnit != null
                        ? _textPrimary
                        : _textSecondary)),
          ),
          // Model
          Expanded(
            flex: 8,
            child: Text(sensor.model,
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    color: _textSecondary)),
          ),
          // Calibration date
          Expanded(
            flex: 10,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 14.0, color: calColor),
                const SizedBox(width: 6.0),
                Text(calDays < 0 ? 'Overdue' : '${calDays}d',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: calColor)),
              ],
            ),
          ),
          // Battery
          Expanded(
            flex: 7,
            child: Row(
              children: [
                Icon(Icons.battery_std, size: 14.0, color: battColor),
                const SizedBox(width: 4.0),
                Text('${sensor.batteryLevel}%',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: battColor)),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 7,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: sensor.isActive ? _normalBg : _offlineBg,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(sensor.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: sensor.isActive ? _normalColor : _offlineColor)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Register Sensor Dialog ──
  void _showRegisterSensorDialog(BuildContext context) {
    _model.dialogSensorIdTextController?.clear();
    _model.dialogUnitNameTextController?.clear();
    _model.dialogSensorTypeValue = null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _pulsePurpleLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.add_circle, color: _pulsePurple, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Text('Register New Sensor',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _model.dialogSensorIdTextController,
                  decoration: InputDecoration(
                    labelText: 'Sensor ID',
                    labelStyle: TextStyle(
                        fontFamily: kAppFontFamily, color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: _pulsePurple, width: 2.0)),
                    prefixIcon:
                        Icon(Icons.sensors, color: _pulsePurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _model.dialogUnitNameTextController,
                  decoration: InputDecoration(
                    labelText: 'Assign to Storage Unit',
                    labelStyle: TextStyle(
                        fontFamily: kAppFontFamily, color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: _pulsePurple, width: 2.0)),
                    prefixIcon:
                        Icon(Icons.kitchen, color: _pulsePurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  initialValue: _model.dialogSensorTypeValue,
                  decoration: InputDecoration(
                    labelText: 'Sensor Model',
                    labelStyle: TextStyle(
                        fontFamily: kAppFontFamily, color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            BorderSide(color: _pulsePurple, width: 2.0)),
                    prefixIcon:
                        Icon(Icons.category, color: _pulsePurple, size: 20.0),
                  ),
                  items: [
                    'TempTale4',
                    'TempTale Direct',
                    'Libero Ti1',
                    'Berlinger ColdMark'
                  ]
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m,
                              style: TextStyle(
                                  fontFamily: kAppFontFamily, fontSize: 14.0))))
                      .toList(),
                  onChanged: (val) =>
                      setDialogState(() => _model.dialogSensorTypeValue = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_model.dialogSensorIdTextController?.text.isEmpty ?? true)
                  return;
                safeSetState(() {
                  _sensors.add(Sensor(
                    id: _model.dialogSensorIdTextController!.text,
                    assignedUnit:
                        _model.dialogUnitNameTextController?.text.isNotEmpty ==
                                true
                            ? _model.dialogUnitNameTextController!.text
                            : null,
                    model: _model.dialogSensorTypeValue ?? 'TempTale4',
                    calibrationDate: DateTime.now().add(Duration(days: 180)),
                    batteryLevel: 100,
                    isActive: true,
                  ));
                });
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _pulsePurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Register',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SPARKLINE PAINTER — Custom painter for 24h mini temperature charts
// ═══════════════════════════════════════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final double minRange;
  final double maxRange;
  final Color lineColor;
  final Color rangeColor;
  final Color outOfRangeColor;

  _SparklinePainter({
    required this.data,
    required this.minRange,
    required this.maxRange,
    required this.lineColor,
    required this.rangeColor,
    required this.outOfRangeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final dataMin = data.reduce((a, b) => a < b ? a : b);
    final dataMax = data.reduce((a, b) => a > b ? a : b);
    final range = (dataMax - dataMin).abs();
    final padding = range == 0 ? 1.0 : range * 0.15;
    final low = dataMin - padding;
    final high = dataMax + padding;
    final span = high - low;

    // Draw in-range band
    final rangeMinY = size.height - ((minRange - low) / span) * size.height;
    final rangeMaxY = size.height - ((maxRange - low) / span) * size.height;
    final clampedMinY = rangeMinY.clamp(0.0, size.height);
    final clampedMaxY = rangeMaxY.clamp(0.0, size.height);

    final rangePaint = Paint()..color = rangeColor;
    canvas.drawRect(
      Rect.fromLTWH(
          0, clampedMaxY, size.width, (clampedMinY - clampedMaxY).abs()),
      rangePaint,
    );

    // Build points
    final points = <Offset>[];
    final xDenominator = data.length > 1 ? data.length - 1 : 1;
    for (int i = 0; i < data.length; i++) {
      final x = (i / xDenominator) * size.width;
      final y = size.height - ((data[i] - low) / span) * size.height;
      points.add(Offset(x, y.clamp(0.0, size.height)));
    }

    // Draw out-of-range fill
    final outOfRangePath = Path();
    outOfRangePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      outOfRangePath.lineTo(points[i].dx, points[i].dy);
    }
    // Close to the range band edges
    for (int i = points.length - 1; i >= 0; i--) {
      final clampedToRange = points[i].dy.clamp(clampedMaxY, clampedMinY);
      outOfRangePath.lineTo(points[i].dx, clampedToRange);
    }
    outOfRangePath.close();
    canvas.drawPath(outOfRangePath, Paint()..color = outOfRangeColor);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw current value dot
    final last = points.last;
    canvas.drawCircle(last, 4.0, Paint()..color = lineColor);
    canvas.drawCircle(last, 2.0, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return data != oldDelegate.data ||
        lineColor != oldDelegate.lineColor ||
        minRange != oldDelegate.minRange ||
        maxRange != oldDelegate.maxRange;
  }
}
