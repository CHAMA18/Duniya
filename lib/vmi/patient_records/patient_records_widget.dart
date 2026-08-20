import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'patient_records_model.dart';
export 'patient_records_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// PATIENT MEDICATION RECORDS
// Track patient medication histories, adherence, and dispensing events
// ═══════════════════════════════════════════════════════════════════════

// ── Mock data models ──

class DispensingEvent {
  final DateTime date;
  final String medication;
  final String dose;
  final int quantity;
  final String prescriber;
  final String? notes;
  DispensingEvent({
    required this.date,
    required this.medication,
    required this.dose,
    required this.quantity,
    required this.prescriber,
    this.notes,
  });
}

class PatientRecord {
  final String name;
  final String patientId;
  final int age;
  final String? phone;
  final String? address;
  final String? medicalAid;
  final int activeMeds;
  final String lastVisit;
  final double adherencePercent;
  final List<DispensingEvent> dispensingHistory;
  PatientRecord({
    required this.name,
    required this.patientId,
    required this.age,
    this.phone,
    this.address,
    this.medicalAid,
    required this.activeMeds,
    required this.lastVisit,
    required this.adherencePercent,
    required this.dispensingHistory,
  });
}

class PatientRecordsWidget extends StatefulWidget {
  const PatientRecordsWidget({super.key});

  static String routeName = 'PatientRecords';
  static String routePath = '/patient-records';

  @override
  State<PatientRecordsWidget> createState() => _PatientRecordsWidgetState();
}

class _PatientRecordsWidgetState extends State<PatientRecordsWidget>
    with TickerProviderStateMixin {
  late PatientRecordsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Pulse Purple design tokens ──
  static const Color _duniyaPurple = Color(0xFF9900FF);
  static const Color _duniyaPurpleLight = Color(0xFFF3F0FF);
  static const Color _duniyaPurpleDark = Color(0xFF7C3AED);
  static const Color _bgColor = Color(0xFFF8F9FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF0B1C30);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _successBg = Color(0xFFD1FAE5);
  static const Color _successText = Color(0xFF065F46);
  static const Color _warningBg = Color(0xFFFEF9C3);
  static const Color _warningText = Color(0xFF854D0E);
  static const Color _dangerBg = Color(0xFFFEE2E2);
  static const Color _dangerText = Color(0xFF991B1B);

  // ── Mock Patient Data (15+ patients) ──
  late List<PatientRecord> _patients;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientRecordsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PatientRecords'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    _patients = <PatientRecord>[];
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOCK DATA
  // ═══════════════════════════════════════════════════════════════════════

  List<PatientRecord> _buildMockPatients() {
    return [
      PatientRecord(
        name: 'Mwanza, John',
        patientId: 'PATG-0892',
        age: 45,
        phone: '+263 77 123 4567',
        address: '12 Kwame Nkrumah, Harare',
        medicalAid: 'CIMAS 44001',
        activeMeds: 3,
        lastVisit: '12 Aug',
        adherencePercent: 87,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 12),
              medication: 'Metformin 500mg',
              dose: '1 tab BD',
              quantity: 60,
              prescriber: 'Dr. Ncube',
              notes: 'Regular refill'),
          DispensingEvent(
              date: DateTime(2024, 7, 15),
              medication: 'Amlodipine 5mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Ncube',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 6, 20),
              medication: 'Lisinopril 10mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Moyo',
              notes: 'BP review'),
        ],
      ),
      PatientRecord(
        name: 'Dube, Sibusiso',
        patientId: 'PATG-1034',
        age: 32,
        phone: '+263 71 555 2233',
        address: '5 Robert Mugabe Way, Bulawayo',
        medicalAid: 'PPO 22010',
        activeMeds: 1,
        lastVisit: '28 Jul',
        adherencePercent: 95,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 7, 28),
              medication: 'Ciprofloxacin 500mg',
              dose: '1 tab BD',
              quantity: 14,
              prescriber: 'Dr. Gumbo',
              notes: 'UTI treatment'),
        ],
      ),
      PatientRecord(
        name: 'Chidamba, Tariro',
        patientId: 'PATG-0567',
        age: 28,
        phone: '+263 78 900 1122',
        address: '8 Jason Moyo, Gweru',
        medicalAid: null,
        activeMeds: 2,
        lastVisit: '3 Aug',
        adherencePercent: 72,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 3),
              medication: 'Azithromycin 250mg',
              dose: '1 tab OD',
              quantity: 6,
              prescriber: 'Dr. Zhuwao',
              notes: 'Respiratory infection'),
          DispensingEvent(
              date: DateTime(2024, 7, 1),
              medication: 'Paracetamol 500mg',
              dose: '2 tabs QID',
              quantity: 40,
              prescriber: 'Dr. Zhuwao',
              notes: null),
        ],
      ),
      PatientRecord(
        name: 'Nkomo, Bongani',
        patientId: 'PATG-1200',
        age: 60,
        phone: '+263 77 444 8899',
        address: '22 Leopold Takawira, Mutare',
        medicalAid: 'DMM 78543',
        activeMeds: 5,
        lastVisit: '15 Aug',
        adherencePercent: 63,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 15),
              medication: 'Insulin Glargine',
              dose: '20 units OD',
              quantity: 3,
              prescriber: 'Dr. Sibanda',
              notes: 'DM Type 2'),
          DispensingEvent(
              date: DateTime(2024, 8, 15),
              medication: 'Metformin 850mg',
              dose: '1 tab BD',
              quantity: 60,
              prescriber: 'Dr. Sibanda',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 7, 20),
              medication: 'Atorvastatin 20mg',
              dose: '1 tab ON',
              quantity: 30,
              prescriber: 'Dr. Sibanda',
              notes: 'Cholesterol'),
          DispensingEvent(
              date: DateTime(2024, 7, 20),
              medication: 'Enalapril 10mg',
              dose: '1 tab BD',
              quantity: 60,
              prescriber: 'Dr. Sibanda',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 6, 15),
              medication: 'Aspirin 75mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Sibanda',
              notes: 'CV prophylaxis'),
        ],
      ),
      PatientRecord(
        name: 'Mhlanga, Grace',
        patientId: 'PATG-0445',
        age: 38,
        phone: '+263 73 211 7700',
        address: '14 Samora Machel, Harare',
        medicalAid: 'CIMAS 55290',
        activeMeds: 2,
        lastVisit: '9 Aug',
        adherencePercent: 91,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 9),
              medication: 'Omeprazole 20mg',
              dose: '1 cap OD',
              quantity: 30,
              prescriber: 'Dr. Chikwaka',
              notes: 'Gastritis'),
          DispensingEvent(
              date: DateTime(2024, 7, 12),
              medication: 'Domperidone 10mg',
              dose: '1 tab TID',
              quantity: 90,
              prescriber: 'Dr. Chikwaka',
              notes: null),
        ],
      ),
      PatientRecord(
        name: 'Zvobgo, Tendai',
        patientId: 'PATG-0781',
        age: 55,
        phone: '+263 77 666 3344',
        address: '9 Josiah Tongogara, Masvingo',
        medicalAid: 'PPO 33050',
        activeMeds: 4,
        lastVisit: '1 Aug',
        adherencePercent: 78,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 1),
              medication: 'Carbamazepine 200mg',
              dose: '1 tab BD',
              quantity: 60,
              prescriber: 'Dr. Maposa',
              notes: 'Epilepsy'),
          DispensingEvent(
              date: DateTime(2024, 7, 5),
              medication: 'Phenytoin 100mg',
              dose: '1 cap TID',
              quantity: 90,
              prescriber: 'Dr. Maposa',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 6, 10),
              medication: 'Folic Acid 5mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Maposa',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 5, 15),
              medication: 'Phenobarbitone 30mg',
              dose: '1 tab ON',
              quantity: 30,
              prescriber: 'Dr. Maposa',
              notes: 'Adjunct'),
        ],
      ),
      PatientRecord(
        name: 'Kasukuwere, Ruva',
        patientId: 'PATG-1562',
        age: 24,
        phone: '+263 71 888 0011',
        address: '3 Julius Nyerere, Kadoma',
        medicalAid: null,
        activeMeds: 1,
        lastVisit: '20 Jul',
        adherencePercent: 100,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 7, 20),
              medication: 'Fluconazole 150mg',
              dose: '1 cap stat',
              quantity: 1,
              prescriber: 'Dr. Nhema',
              notes: 'Single dose'),
        ],
      ),
      PatientRecord(
        name: 'Shumba, Paidamoyo',
        patientId: 'PATG-0312',
        age: 47,
        phone: '+263 78 333 5566',
        address: '18 Herbert Chitepo, Chinhoyi',
        medicalAid: 'CIMAS 66710',
        activeMeds: 3,
        lastVisit: '14 Aug',
        adherencePercent: 82,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 14),
              medication: 'Losartan 50mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Hove',
              notes: 'HTN'),
          DispensingEvent(
              date: DateTime(2024, 7, 18),
              medication: 'Hydrochlorothiazide 25mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Hove',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 6, 22),
              medication: 'Simvastatin 20mg',
              dose: '1 tab ON',
              quantity: 30,
              prescriber: 'Dr. Hove',
              notes: 'Lipids'),
        ],
      ),
      PatientRecord(
        name: 'Gumbo, Tapfuma',
        patientId: 'PATG-1890',
        age: 70,
        phone: '+263 77 222 1100',
        address: '6 First Street, Gwanda',
        medicalAid: 'DMM 12003',
        activeMeds: 6,
        lastVisit: '10 Aug',
        adherencePercent: 55,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 10),
              medication: 'Metformin 500mg',
              dose: '1 tab TID',
              quantity: 90,
              prescriber: 'Dr. Ncube',
              notes: 'DM Type 2'),
          DispensingEvent(
              date: DateTime(2024, 8, 10),
              medication: 'Gliclazide 80mg',
              dose: '1 tab BD',
              quantity: 60,
              prescriber: 'Dr. Ncube',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 7, 12),
              medication: 'Ramipril 5mg',
              dose: '1 cap OD',
              quantity: 30,
              prescriber: 'Dr. Ncube',
              notes: 'Renal protection'),
          DispensingEvent(
              date: DateTime(2024, 7, 12),
              medication: 'Aspirin 75mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Ncube',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 6, 14),
              medication: 'Atorvastatin 40mg',
              dose: '1 tab ON',
              quantity: 30,
              prescriber: 'Dr. Ncube',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 5, 20),
              medication: 'Pantoprazole 40mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Ncube',
              notes: 'GI protection'),
        ],
      ),
      PatientRecord(
        name: 'Chinamora, Rumbidzai',
        patientId: 'PATG-0234',
        age: 35,
        phone: '+263 73 999 4455',
        address: '11 Joshua Nkomo, Marondera',
        medicalAid: 'PPO 44100',
        activeMeds: 2,
        lastVisit: '7 Aug',
        adherencePercent: 96,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 7),
              medication: 'Salbutamol Inhaler',
              dose: '2 puffs PRN',
              quantity: 2,
              prescriber: 'Dr. Munyoro',
              notes: 'Asthma'),
          DispensingEvent(
              date: DateTime(2024, 7, 10),
              medication: 'Budesonide Inhaler',
              dose: '2 puffs BD',
              quantity: 2,
              prescriber: 'Dr. Munyoro',
              notes: 'Preventer'),
        ],
      ),
      PatientRecord(
        name: 'Mujuru, Kudakwashe',
        patientId: 'PATG-2100',
        age: 42,
        phone: '+263 71 777 8899',
        address: '7 Rekayi Tangwena, Chipinge',
        medicalAid: null,
        activeMeds: 2,
        lastVisit: '30 Jul',
        adherencePercent: 68,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 7, 30),
              medication: 'Isoniazid 300mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Nzira',
              notes: 'TB prophylaxis'),
          DispensingEvent(
              date: DateTime(2024, 6, 30),
              medication: 'Pyridoxine 25mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Nzira',
              notes: 'INH adjunct'),
        ],
      ),
      PatientRecord(
        name: 'Chigwedere, Munashe',
        patientId: 'PATG-0678',
        age: 19,
        phone: '+263 78 111 2233',
        address: '2 Nelson Mandela, Bindura',
        medicalAid: 'CIMAS 88340',
        activeMeds: 1,
        lastVisit: '5 Aug',
        adherencePercent: 100,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 5),
              medication: 'Doxycycline 100mg',
              dose: '1 cap BD',
              quantity: 14,
              prescriber: 'Dr. Biriwasha',
              notes: 'Acne'),
        ],
      ),
      PatientRecord(
        name: 'Sibanda, Nomathemba',
        patientId: 'PATG-1345',
        age: 50,
        phone: '+263 77 444 5566',
        address: '15 Lobengula, Plumtree',
        medicalAid: 'DMM 44005',
        activeMeds: 4,
        lastVisit: '11 Aug',
        adherencePercent: 74,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 11),
              medication: 'Amlodipine 10mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Tshuma',
              notes: 'HTN'),
          DispensingEvent(
              date: DateTime(2024, 8, 11),
              medication: 'Bisoprolol 5mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Tshuma',
              notes: null),
          DispensingEvent(
              date: DateTime(2024, 7, 14),
              medication: 'Furosemide 40mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Tshuma',
              notes: 'Fluid overload'),
          DispensingEvent(
              date: DateTime(2024, 6, 18),
              medication: 'Spironolactone 25mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Tshuma',
              notes: null),
        ],
      ),
      PatientRecord(
        name: 'Rusere, Anesu',
        patientId: 'PATG-2456',
        age: 29,
        phone: '+263 73 555 6677',
        address: '4 Livingstone, Victoria Falls',
        medicalAid: null,
        activeMeds: 1,
        lastVisit: '22 Jul',
        adherencePercent: 88,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 7, 22),
              medication: 'Artemether/Lumefantrine',
              dose: '4 tabs stat, then 4 tabs 8h',
              quantity: 24,
              prescriber: 'Dr. Makhula',
              notes: 'Malaria treatment'),
        ],
      ),
      PatientRecord(
        name: 'Makoni, Farai',
        patientId: 'PATG-0901',
        age: 63,
        phone: '+263 71 333 4455',
        address: '20 Churchill, Rusape',
        medicalAid: 'PPO 11090',
        activeMeds: 3,
        lastVisit: '8 Aug',
        adherencePercent: 81,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 8),
              medication: 'Warfarin 5mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Chifamba',
              notes: 'INR 2.5'),
          DispensingEvent(
              date: DateTime(2024, 7, 11),
              medication: 'Digoxin 0.25mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Chifamba',
              notes: 'Atrial fib'),
          DispensingEvent(
              date: DateTime(2024, 6, 15),
              medication: 'Amiodarone 200mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Chifamba',
              notes: null),
        ],
      ),
      PatientRecord(
        name: 'Hwenda, Chengetai',
        patientId: 'PATG-1763',
        age: 41,
        phone: '+263 78 222 3344',
        address: '16 Tongogara, Kwekwe',
        medicalAid: 'CIMAS 33100',
        activeMeds: 2,
        lastVisit: '2 Aug',
        adherencePercent: 93,
        dispensingHistory: [
          DispensingEvent(
              date: DateTime(2024, 8, 2),
              medication: 'Citalopram 20mg',
              dose: '1 tab OD',
              quantity: 30,
              prescriber: 'Dr. Mudzviti',
              notes: 'Depression'),
          DispensingEvent(
              date: DateTime(2024, 7, 5),
              medication: 'Zolpidem 5mg',
              dose: '1 tab ON',
              quantity: 14,
              prescriber: 'Dr. Mudzviti',
              notes: 'Insomnia PRN'),
        ],
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Color _adherenceColor(double pct) {
    if (pct >= 80) return _successText;
    if (pct >= 60) return _warningText;
    return _dangerText;
  }

  Color _adherenceBgColor(double pct) {
    if (pct >= 80) return _successBg;
    if (pct >= 60) return _warningBg;
    return _dangerBg;
  }

  Color _adherenceBadgeBg(double pct) {
    if (pct >= 80) return Color(0xFF16A34A);
    if (pct >= 60) return Color(0xFFCA8A04);
    return Color(0xFFDC2626);
  }

  IconData _adherenceIcon(double pct) {
    if (pct >= 80) return Icons.check_circle;
    if (pct >= 60) return Icons.warning_amber_rounded;
    return Icons.error;
  }

  int get _totalPatients => _patients.length;
  int get _activeMedications =>
      _patients.fold(0, (sum, p) => sum + p.activeMeds);
  int get _refillsDueThisWeek => 8; // mock
  double get _avgAdherence {
    if (_patients.isEmpty) return 0;
    return _patients.map((p) => p.adherencePercent).reduce((a, b) => a + b) /
        _patients.length;
  }

  List<PatientRecord> get _filteredPatients {
    final q = _model.searchTextController?.text.toLowerCase() ?? '';
    if (q.isEmpty) return _patients;
    return _patients.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.patientId.toLowerCase().contains(q) ||
          (p.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Patient Medication Records',
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
                              // ── Header ──
                              _buildPageHeader(),
                              const SizedBox(height: 28.0),

                              // ── RBAC Guard ──
                              AuthUserStreamWidget(
                                builder: (context) {
                                  if (!AccessControl.hasPermission(
                                      context, Permission.patientRecordsView)) {
                                    return _buildNoAccessState();
                                  }
                                  return _buildContent(context);
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

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE HEADER
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Medication Records',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                  height: 1.2,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Track patient medication histories, adherence rates, and dispensing events.',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NO ACCESS STATE
  // ═══════════════════════════════════════════════════════════════════════

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
              child: Icon(Icons.lock_outline, color: _duniyaPurple, size: 36.0),
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
                'You don\'t have permission to view patient records.\nContact your administrator for access.',
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

  // ═══════════════════════════════════════════════════════════════════════
  // MAIN CONTENT
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context) {
    final canCreate =
        AccessControl.hasPermission(context, Permission.patientRecordsCreate);
    final canEdit =
        AccessControl.hasPermission(context, Permission.patientRecordsEdit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section 1: Summary Stats ──
        _buildSummaryStats(),
        const SizedBox(height: 28.0),

        // ── Section 2: Patient Search ──
        _buildSearchBar(canCreate),
        const SizedBox(height: 20.0),

        // ── Section 3: Patient Directory ──
        _buildPatientDirectory(context, canEdit),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 1: SUMMARY STATS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSummaryStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardSpacing = 16.0;
        double minCardWidth = 180.0;
        int cols = (constraints.maxWidth / (minCardWidth + cardSpacing))
            .clamp(1, 4)
            .toInt();
        final cardWidth =
            (constraints.maxWidth - cardSpacing * (cols - 1)) / cols;

        return Wrap(
          spacing: cardSpacing,
          runSpacing: cardSpacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Total Patients',
                value: _totalPatients.toString(),
                icon: Icons.people,
                bgColor: _duniyaPurpleLight,
                iconColor: _duniyaPurple,
                textColor: _duniyaPurpleDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Active Medications',
                value: _activeMedications.toString(),
                icon: Icons.medication,
                bgColor: _successBg,
                iconColor: Color(0xFF16A34A),
                textColor: _successText,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Refills Due This Week',
                value: _refillsDueThisWeek.toString(),
                icon: Icons.event_available,
                bgColor: _warningBg,
                iconColor: Color(0xFFCA8A04),
                textColor: _warningText,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                title: 'Adherence Rate',
                value: '${_avgAdherence.toStringAsFixed(0)}%',
                icon: Icons.trending_up,
                bgColor: _duniyaPurpleLight,
                iconColor: _duniyaPurple,
                textColor: _duniyaPurpleDark,
              ),
            ),
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
        borderRadius: BorderRadius.circular(16.0),
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
  // SECTION 2: PATIENT SEARCH
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildSearchBar(bool canCreate) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;
          final searchField = TextField(
            controller: _model.searchTextController,
            focusNode: _model.searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or phone...',
              hintStyle: TextStyle(
                  fontFamily: kAppFontFamily,
                  color: _textSecondary,
                  fontSize: 14.0),
              prefixIcon: Icon(Icons.search, color: _duniyaPurple, size: 20.0),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            ),
            style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 14.0,
                color: _textPrimary),
            onChanged: (val) => safeSetState(() {}),
          );

          final addButton = ElevatedButton.icon(
            onPressed: canCreate ? () => _showAddPatientDialog(context) : null,
            icon: Icon(Icons.person_add, size: 18.0),
            label: Text('Add Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _duniyaPurple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _borderColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
          );

          if (isCompact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                searchField,
                const SizedBox(height: 12.0),
                Align(alignment: Alignment.centerRight, child: addButton),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12.0),
              addButton,
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 3: PATIENT DIRECTORY
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPatientDirectory(BuildContext context, bool canEdit) {
    final patients = _filteredPatients;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
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
          // Table header
          Container(
            padding: const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 18.0),
            decoration: BoxDecoration(
              color: _duniyaPurple.withValues(alpha: 0.06),
              border: Border(
                bottom: BorderSide(color: _borderColor, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                _tableHeaderCell('Patient', 1.8),
                _tableHeaderCell('ID', 0.8),
                _tableHeaderCell('Age', 0.5),
                _tableHeaderCell('Active Meds', 0.8),
                _tableHeaderCell('Last Visit', 0.8),
                _tableHeaderCell('Adherence', 0.9),
                if (canEdit) _tableHeaderCell('Actions', 0.6),
              ],
            ),
          ),
          // Rows or empty state
          if (patients.isEmpty)
            Container(
              padding: const EdgeInsets.all(60.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person_search_outlined,
                        size: 56.0,
                        color: _textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: 16.0),
                    Text('No patients found',
                        style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: _textSecondary)),
                    const SizedBox(height: 8.0),
                    Text('Try a different search term',
                        style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 13.0,
                            color: _textSecondary.withValues(alpha: 0.7))),
                  ],
                ),
              ),
            )
          else
            ...patients.map((patient) {
              final idx = _patients.indexOf(patient);
              final isExpanded = _model.expandedPatientIndex == idx;
              return _buildPatientRow(
                  context, patient, idx, isExpanded, canEdit);
            }),
        ],
      ),
    );
  }

  Widget _buildPatientRow(
    BuildContext context,
    PatientRecord patient,
    int index,
    bool isExpanded,
    bool canEdit,
  ) {
    final canViewHistory = AccessControl.hasPermission(
        context, Permission.patientRecordsViewHistory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            safeSetState(() {
              _model.expandedPatientIndex = isExpanded ? null : index;
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 14.0),
            decoration: BoxDecoration(
              color: isExpanded ? Color(0xFFF8F5FF) : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                    color: _borderColor.withValues(alpha: 0.5), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Patient name with expand, icon
                Expanded(
                  flex: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: _duniyaPurpleLight,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            patient.name.substring(0, 1),
                            style: TextStyle(
                              fontFamily: kAppFontFamily,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: _duniyaPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(patient.name,
                            style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                // Patient ID
                Expanded(
                  flex: 8,
                  child: Text(patient.patientId,
                      style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          color: _textSecondary,
                          fontWeight: FontWeight.w500)),
                ),
                // Age
                Expanded(
                  flex: 5,
                  child: Text('${patient.age}',
                      style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          color: _textPrimary)),
                ),
                // Active meds
                Expanded(
                  flex: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _duniyaPurpleLight,
                      borderRadius: BorderRadius.circular(9999.0),
                    ),
                    child: Text('${patient.activeMeds} meds',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: _duniyaPurple)),
                  ),
                ),
                // Last visit
                Expanded(
                  flex: 8,
                  child: Text(patient.lastVisit,
                      style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          color: _textSecondary)),
                ),
                // Adherence
                Expanded(
                  flex: 9,
                  child: Row(
                    children: [
                      Icon(_adherenceIcon(patient.adherencePercent),
                          size: 16.0,
                          color: _adherenceBadgeBg(patient.adherencePercent)),
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: _adherenceBgColor(patient.adherencePercent),
                          borderRadius: BorderRadius.circular(9999.0),
                        ),
                        child: Text('${patient.adherencePercent}%',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w600,
                                color:
                                    _adherenceColor(patient.adherencePercent))),
                      ),
                    ],
                  ),
                ),
                // Edit action
                if (canEdit)
                  Expanded(
                    flex: 6,
                    child: InkWell(
                      onTap: () => _showEditPatientDialog(context, patient),
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                            color: _duniyaPurpleLight,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Icon(Icons.edit_outlined,
                            size: 16.0, color: _duniyaPurple),
                      ),
                    ),
                  ),
                // Expand chevron
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18.0,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Section 4: Medication History (expanded) ──
        if (isExpanded && canViewHistory) _buildMedicationHistory(patient),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 4: MEDICATION HISTORY TIMELINE
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildMedicationHistory(PatientRecord patient) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border:
            Border.all(color: _duniyaPurple.withValues(alpha: 0.2), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(Icons.history, size: 18.0, color: _duniyaPurple),
              ),
              const SizedBox(width: 10.0),
              Text('Medication History',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary)),
              const SizedBox(width: 8.0),
              Text('(${patient.dispensingHistory.length} events)',
                  style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.0,
                      color: _textSecondary)),
            ],
          ),
          const SizedBox(height: 16.0),
          if (patient.dispensingHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text('No dispensing history available',
                    style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        color: _textSecondary)),
              ),
            )
          else
            ...patient.dispensingHistory.map((event) {
              return _buildTimelineEntry(event);
            }),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(DispensingEvent event) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          Column(
            children: [
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: _duniyaPurple,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2.0,
                  color: _duniyaPurple.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14.0),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: _borderColor, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${event.date.day} ${_monthAbbr(event.date.month)} ${event.date.year}',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: _duniyaPurple,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Qty: ${event.quantity}',
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 11.0,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      event.medication,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.medication,
                            size: 14.0, color: _textSecondary),
                        const SizedBox(width: 4.0),
                        Text(event.dose,
                            style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12.0,
                                color: _textSecondary)),
                        const SizedBox(width: 16.0),
                        Icon(Icons.person_outline,
                            size: 14.0, color: _textSecondary),
                        const SizedBox(width: 4.0),
                        Text(event.prescriber,
                            style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12.0,
                                color: _textSecondary)),
                      ],
                    ),
                    if (event.notes != null) ...[
                      const SizedBox(height: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: _duniyaPurpleLight,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(event.notes!,
                            style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 11.0,
                                color: _duniyaPurpleDark)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 5: ADD PATIENT DIALOG
  // ═══════════════════════════════════════════════════════════════════════

  void _showAddPatientDialog(BuildContext context) {
    _model.nameTextController ??= TextEditingController();
    _model.phoneTextController ??= TextEditingController();
    _model.addressTextController ??= TextEditingController();
    _model.medicalAidTextController ??= TextEditingController();
    _model.nameTextController!.clear();
    _model.phoneTextController!.clear();
    _model.addressTextController!.clear();
    _model.medicalAidTextController!.clear();
    _model.dobDate = null;

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
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.person_add, color: _duniyaPurple, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Text('Add New Patient',
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
                _dialogTextField(
                  controller: _model.nameTextController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1990),
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: _duniyaPurple,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() => _model.dobDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: TextStyle(
                          fontFamily: kAppFontFamily, color: _textSecondary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      prefixIcon: Icon(Icons.calendar_today,
                          color: _duniyaPurple, size: 20.0),
                    ),
                    child: Text(
                      _model.dobDate != null
                          ? '${_model.dobDate!.day}/${_model.dobDate!.month}/${_model.dobDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        color: _model.dobDate != null
                            ? _textPrimary
                            : _textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.phoneTextController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.addressTextController,
                  label: 'Address',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.medicalAidTextController,
                  label: 'Medical Aid (optional)',
                  icon: Icons.health_and_safety,
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
                // Mock: add patient to list
                final name = _model.nameTextController?.text.trim() ?? '';
                if (name.isEmpty) return;
                final now = DateTime.now();
                final age = _model.dobDate != null
                    ? now.year - _model.dobDate!.year
                    : 0;
                final newPatient = PatientRecord(
                  name: name,
                  patientId:
                      'PATG-${(1000 + _patients.length).toString().padLeft(4, '0')}',
                  age: age,
                  phone: _model.phoneTextController?.text.trim(),
                  address: _model.addressTextController?.text.trim(),
                  medicalAid: _model.medicalAidTextController?.text.trim(),
                  activeMeds: 0,
                  lastVisit: 'Today',
                  adherencePercent: 100,
                  dispensingHistory: [],
                );
                safeSetState(() => _patients.insert(0, newPatient));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _duniyaPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Save',
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

  // ═══════════════════════════════════════════════════════════════════════
  // SECTION 6: EDIT PATIENT DIALOG
  // ═══════════════════════════════════════════════════════════════════════

  void _showEditPatientDialog(BuildContext context, PatientRecord patient) {
    _model.nameTextController ??= TextEditingController();
    _model.phoneTextController ??= TextEditingController();
    _model.addressTextController ??= TextEditingController();
    _model.medicalAidTextController ??= TextEditingController();
    _model.nameTextController!.text = patient.name;
    _model.phoneTextController!.text = patient.phone ?? '';
    _model.addressTextController!.text = patient.address ?? '';
    _model.medicalAidTextController!.text = patient.medicalAid ?? '';
    _model.dobDate = null;

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
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.edit, color: _duniyaPurple, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Text('Edit Patient',
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
                _dialogTextField(
                  controller: _model.nameTextController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.phoneTextController,
                  label: 'Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.addressTextController,
                  label: 'Address',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16.0),
                _dialogTextField(
                  controller: _model.medicalAidTextController,
                  label: 'Medical Aid',
                  icon: Icons.health_and_safety,
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
                // Mock: update patient in list
                final idx = _patients.indexOf(patient);
                if (idx == -1) return;
                final updated = PatientRecord(
                  name: _model.nameTextController?.text.trim() ?? patient.name,
                  patientId: patient.patientId,
                  age: patient.age,
                  phone: _model.phoneTextController?.text.trim(),
                  address: _model.addressTextController?.text.trim(),
                  medicalAid: _model.medicalAidTextController?.text.trim(),
                  activeMeds: patient.activeMeds,
                  lastVisit: patient.lastVisit,
                  adherencePercent: patient.adherencePercent,
                  dispensingHistory: patient.dispensingHistory,
                );
                safeSetState(() => _patients[idx] = updated);
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _duniyaPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Save Changes',
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

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _dialogTextField({
    required TextEditingController? controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontFamily: kAppFontFamily, color: _textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
        prefixIcon: Icon(icon, color: _duniyaPurple, size: 20.0),
      ),
    );
  }

  Widget _tableHeaderCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: kAppFontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08,
          color: _duniyaPurpleDark,
        ),
      ),
    );
  }
}
