import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'prescriptions_model.dart';
export 'prescriptions_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// DIGITAL PRESCRIPTIONS
// Manage prescription lifecycle: create, verify, fulfill
// ═══════════════════════════════════════════════════════════════════════

class PrescriptionsWidget extends StatefulWidget {
  const PrescriptionsWidget({super.key});

  static String routeName = 'Prescriptions';
  static String routePath = '/prescriptions';

  @override
  State<PrescriptionsWidget> createState() => _PrescriptionsWidgetState();
}

// ── Prescription status enum ──
enum RxStatus { pending, verified, fulfilled, expired }

// ── Medication line model ──
class MedicationLine {
  String drug;
  String dose;
  String frequency;
  String duration;

  MedicationLine({
    required this.drug,
    required this.dose,
    required this.frequency,
    required this.duration,
  });

  String get summary => '$drug $dose $frequency $duration';
}

// ── Prescription data model ──
class Prescription {
  final String rxNumber;
  final String patientName;
  final String prescriber;
  final List<MedicationLine> medications;
  final RxStatus status;
  final DateTime date;
  final String? notes;
  final double value;

  Prescription({
    required this.rxNumber,
    required this.patientName,
    required this.prescriber,
    required this.medications,
    required this.status,
    required this.date,
    this.notes,
    required this.value,
  });

  String get statusLabel {
    switch (status) {
      case RxStatus.pending:
        return 'Pending Verification';
      case RxStatus.verified:
        return 'Verified';
      case RxStatus.fulfilled:
        return 'Fulfilled';
      case RxStatus.expired:
        return 'Expired';
    }
  }
}

class _PrescriptionsWidgetState extends State<PrescriptionsWidget>
    with TickerProviderStateMixin {
  late PrescriptionsModel _model;

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

  // ── Status colour system ──
  // Pending — Amber
  static const Color _pendingBg = Color(0xFFFEF3C7);
  static const Color _pendingText = Color(0xFF92400E);
  static const Color _pendingBadge = Color(0xFFF59E0B);
  // Verified — Blue
  static const Color _verifiedBg = Color(0xFFE0F2FE);
  static const Color _verifiedText = Color(0xFF1E40AF);
  static const Color _verifiedBadge = Color(0xFF2563EB);
  // Fulfilled — Green
  static const Color _fulfilledBg = Color(0xFFD1FAE5);
  static const Color _fulfilledText = Color(0xFF065F46);
  static const Color _fulfilledBadge = Color(0xFF10B981);
  // Expired — Red
  static const Color _expiredBg = Color(0xFFFEE2E2);
  static const Color _expiredText = Color(0xFF991B1B);
  static const Color _expiredBadge = Color(0xFFEF4444);

  // ── Local state ──
  int _selectedTab = 0; // 0=All, 1=Pending, 2=Verified, 3=Fulfilled, 4=Expired
  List<Prescription> _prescriptions = [];
  List<MedicationLine> _formMedLines = [];
  bool _showForm = false;

  // ── Animation controllers ──
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrescriptionsModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'Prescriptions'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    _prescriptions = <Prescription>[];
    _formMedLines = [
      MedicationLine(drug: '', dose: '', frequency: '', duration: '')
    ];

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
  // MOCK DATA — 12+ realistic prescriptions
  // ═══════════════════════════════════════════════════════════════════

  List<Prescription> get _mockPrescriptions {
    final now = DateTime.now();
    return [
      Prescription(
        rxNumber: 'RX-2024-0156',
        patientName: 'John Mwanza',
        prescriber: 'Dr. Chanda',
        medications: [
          MedicationLine(
              drug: 'Amoxicillin',
              dose: '500mg',
              frequency: '3x daily',
              duration: '7 days')
        ],
        status: RxStatus.pending,
        date: now.subtract(const Duration(hours: 2)),
        notes: 'Outpatient — upper respiratory infection',
        value: 45.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0157',
        patientName: 'Grace Banda',
        prescriber: 'Dr. Phiri',
        medications: [
          MedicationLine(
              drug: 'Metformin',
              dose: '850mg',
              frequency: '2x daily',
              duration: '30 days')
        ],
        status: RxStatus.verified,
        date: now.subtract(const Duration(hours: 5)),
        notes: 'Diabetes management — chronic',
        value: 120.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0158',
        patientName: 'Peter Tembo',
        prescriber: 'Dr. Chanda',
        medications: [
          MedicationLine(
              drug: 'Lisinopril',
              dose: '10mg',
              frequency: '1x daily',
              duration: '30 days'),
          MedicationLine(
              drug: 'Amlodipine',
              dose: '5mg',
              frequency: '1x daily',
              duration: '30 days'),
        ],
        status: RxStatus.fulfilled,
        date: now.subtract(const Duration(days: 1)),
        notes: 'Hypertension — dual therapy',
        value: 85.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0159',
        patientName: 'Mary Sakala',
        prescriber: 'Dr. Moyo',
        medications: [
          MedicationLine(
              drug: 'Ciprofloxacin',
              dose: '500mg',
              frequency: '2x daily',
              duration: '5 days')
        ],
        status: RxStatus.pending,
        date: now.subtract(const Duration(hours: 1)),
        notes: 'UTI — acute treatment',
        value: 38.50,
      ),
      Prescription(
        rxNumber: 'RX-2024-0160',
        patientName: 'Joseph Phiri',
        prescriber: 'Dr. Nkosi',
        medications: [
          MedicationLine(
              drug: 'Omeprazole',
              dose: '20mg',
              frequency: '1x daily',
              duration: '14 days')
        ],
        status: RxStatus.expired,
        date: now.subtract(const Duration(days: 30)),
        notes: 'GERD — prescription not collected within 7 days',
        value: 32.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0161',
        patientName: 'Esther Zulu',
        prescriber: 'Dr. Phiri',
        medications: [
          MedicationLine(
              drug: 'Artemether/Lumefantrine',
              dose: '20/120mg',
              frequency: '2x daily',
              duration: '3 days'),
        ],
        status: RxStatus.verified,
        date: now.subtract(const Duration(hours: 8)),
        notes: 'Uncomplicated malaria — ACT',
        value: 56.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0162',
        patientName: 'David Kamanga',
        prescriber: 'Dr. Moyo',
        medications: [
          MedicationLine(
              drug: 'Ibuprofen',
              dose: '400mg',
              frequency: '3x daily',
              duration: '5 days')
        ],
        status: RxStatus.fulfilled,
        date: now.subtract(const Duration(days: 2)),
        notes: 'Post-operative pain management',
        value: 18.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0163',
        patientName: 'Agnes Chiluba',
        prescriber: 'Dr. Chanda',
        medications: [
          MedicationLine(
              drug: 'Azithromycin',
              dose: '500mg',
              frequency: '1x daily',
              duration: '3 days')
        ],
        status: RxStatus.pending,
        date: now.subtract(const Duration(minutes: 30)),
        value: 62.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0164',
        patientName: 'Robert Sichone',
        prescriber: 'Dr. Nkosi',
        medications: [
          MedicationLine(
              drug: 'Warfarin',
              dose: '5mg',
              frequency: '1x daily',
              duration: '30 days'),
          MedicationLine(
              drug: 'Aspirin',
              dose: '75mg',
              frequency: '1x daily',
              duration: '30 days'),
        ],
        status: RxStatus.pending,
        date: now.subtract(const Duration(hours: 3)),
        notes: '⚠ Drug interaction alert — Warfarin + Aspirin',
        value: 95.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0165',
        patientName: 'Florence Mwale',
        prescriber: 'Dr. Phiri',
        medications: [
          MedicationLine(
              drug: 'Cetirizine',
              dose: '10mg',
              frequency: '1x daily',
              duration: '14 days')
        ],
        status: RxStatus.fulfilled,
        date: now.subtract(const Duration(days: 3)),
        notes: 'Allergic rhinitis',
        value: 22.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0166',
        patientName: 'Harrison Bwalya',
        prescriber: 'Dr. Moyo',
        medications: [
          MedicationLine(
              drug: 'Paracetamol',
              dose: '1g',
              frequency: '4x daily',
              duration: '3 days')
        ],
        status: RxStatus.verified,
        date: now.subtract(const Duration(hours: 12)),
        notes: 'Pyrexia of unknown origin — symptomatic',
        value: 12.50,
      ),
      Prescription(
        rxNumber: 'RX-2024-0167',
        patientName: 'Chimwemwe Ngoma',
        prescriber: 'Dr. Nkosi',
        medications: [
          MedicationLine(
              drug: 'Co-trimoxazole',
              dose: '960mg',
              frequency: '2x daily',
              duration: '7 days'),
          MedicationLine(
              drug: 'Multivitamin',
              dose: '1 tab',
              frequency: '1x daily',
              duration: '30 days'),
        ],
        status: RxStatus.expired,
        date: now.subtract(const Duration(days: 14)),
        notes: 'HIV prophylaxis — expired, requires renewal',
        value: 78.00,
      ),
      Prescription(
        rxNumber: 'RX-2024-0168',
        patientName: 'Bwana Mutale',
        prescriber: 'Dr. Chanda',
        medications: [
          MedicationLine(
              drug: 'Salbutamol Inhaler',
              dose: '100mcg',
              frequency: 'PRN',
              duration: '90 days')
        ],
        status: RxStatus.pending,
        date: now.subtract(const Duration(minutes: 45)),
        notes: 'Bronchial asthma — rescue inhaler',
        value: 55.00,
      ),
    ];
  }

  // ── Status colour helpers ──
  Color _statusBg(RxStatus s) {
    switch (s) {
      case RxStatus.pending:
        return _pendingBg;
      case RxStatus.verified:
        return _verifiedBg;
      case RxStatus.fulfilled:
        return _fulfilledBg;
      case RxStatus.expired:
        return _expiredBg;
    }
  }

  Color _statusText(RxStatus s) {
    switch (s) {
      case RxStatus.pending:
        return _pendingText;
      case RxStatus.verified:
        return _verifiedText;
      case RxStatus.fulfilled:
        return _fulfilledText;
      case RxStatus.expired:
        return _expiredText;
    }
  }

  Color _statusBadge(RxStatus s) {
    switch (s) {
      case RxStatus.pending:
        return _pendingBadge;
      case RxStatus.verified:
        return _verifiedBadge;
      case RxStatus.fulfilled:
        return _fulfilledBadge;
      case RxStatus.expired:
        return _expiredBadge;
    }
  }

  IconData _statusIcon(RxStatus s) {
    switch (s) {
      case RxStatus.pending:
        return Icons.schedule;
      case RxStatus.verified:
        return Icons.verified_outlined;
      case RxStatus.fulfilled:
        return Icons.check_circle;
      case RxStatus.expired:
        return Icons.event_busy;
    }
  }

  // ── Summary stats ──
  int get _pendingCount =>
      _prescriptions.where((p) => p.status == RxStatus.pending).length;
  int get _verifiedCount =>
      _prescriptions.where((p) => p.status == RxStatus.verified).length;
  int get _fulfilledTodayCount => _prescriptions
      .where((p) =>
          p.status == RxStatus.fulfilled &&
          p.date.year == DateTime.now().year &&
          p.date.month == DateTime.now().month &&
          p.date.day == DateTime.now().day)
      .length;
  double get _totalRxValue =>
      _prescriptions.fold(0.0, (sum, p) => sum + p.value);

  // ── Filtered prescriptions ──
  List<Prescription> get _filteredPrescriptions {
    final searchQuery = _model.searchTextController?.text.toLowerCase() ?? '';
    List<Prescription> result = _prescriptions;

    // Filter by tab
    if (_selectedTab == 1)
      result = result.where((p) => p.status == RxStatus.pending).toList();
    if (_selectedTab == 2)
      result = result.where((p) => p.status == RxStatus.verified).toList();
    if (_selectedTab == 3)
      result = result.where((p) => p.status == RxStatus.fulfilled).toList();
    if (_selectedTab == 4)
      result = result.where((p) => p.status == RxStatus.expired).toList();

    // Filter by search
    if (searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.patientName.toLowerCase().contains(searchQuery) ||
              p.rxNumber.toLowerCase().contains(searchQuery))
          .toList();
    }

    return result;
  }

  // ── Summary Stat Card ──
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

  // ── Status Filter Tabs ──
  Widget _buildFilterTabs() {
    final tabs = ['All', 'Pending', 'Verified', 'Fulfilled', 'Expired'];
    final counts = [
      _prescriptions.length,
      _pendingCount,
      _verifiedCount,
      _prescriptions.where((p) => p.status == RxStatus.fulfilled).length,
      _prescriptions.where((p) => p.status == RxStatus.expired).length,
    ];

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor, width: 1.0),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => safeSetState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: isSelected ? _pulsePurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : _textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (counts[i] > 0) ...[
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : _borderColor,
                          borderRadius: BorderRadius.circular(9999.0),
                        ),
                        child: Text(
                          counts[i].toString(),
                          style: TextStyle(
                            fontFamily: kAppFontFamily,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : _textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Prescription Card ──
  Widget _buildPrescriptionCard(Prescription rx) {
    final canVerify =
        AccessControl.hasPermission(context, Permission.prescriptionsVerify);
    final canFulfill =
        AccessControl.hasPermission(context, Permission.prescriptionsFulfill);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Rx number + status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _pulsePurpleLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child:
                    Icon(Icons.receipt_long, size: 18.0, color: _pulsePurple),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rx.rxNumber,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      '${rx.patientName}  •  ${rx.prescriber}',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 13.0,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: _statusBg(rx.status),
                  borderRadius: BorderRadius.circular(9999.0),
                  border: Border.all(
                      color: _statusBadge(rx.status).withValues(alpha: 0.3),
                      width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(rx.status),
                        size: 14.0, color: _statusBadge(rx.status)),
                    const SizedBox(width: 6.0),
                    Text(
                      rx.statusLabel,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: _statusText(rx.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Medication lines
          ...rx.medications.map((med) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.medication, size: 14.0, color: _pulsePurple),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        med.summary,
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          // Notes (if any)
          if (rx.notes != null && rx.notes!.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14.0, color: _textSecondary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      rx.notes!,
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        color: _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14.0),

          // Footer: date + value + actions
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13.0, color: _textSecondary),
              const SizedBox(width: 6.0),
              Text(
                '${rx.date.day}/${rx.date.month}/${rx.date.year}',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 12.0,
                    color: _textSecondary),
              ),
              const SizedBox(width: 16.0),
              Icon(Icons.attach_money, size: 13.0, color: _textSecondary),
              Text(
                rx.value.toStringAsFixed(2),
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              // Action: Verify
              if (rx.status == RxStatus.pending && canVerify)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _actionChip(
                    label: 'Verify',
                    icon: Icons.verified_outlined,
                    color: _verifiedBadge,
                    onTap: () => safeSetState(() {
                      final idx = _prescriptions
                          .indexWhere((p) => p.rxNumber == rx.rxNumber);
                      if (idx >= 0) {
                        _prescriptions[idx] = Prescription(
                          rxNumber: rx.rxNumber,
                          patientName: rx.patientName,
                          prescriber: rx.prescriber,
                          medications: rx.medications,
                          status: RxStatus.verified,
                          date: rx.date,
                          notes: rx.notes,
                          value: rx.value,
                        );
                      }
                    }),
                  ),
                ),
              // Action: Fulfill
              if (rx.status == RxStatus.verified && canFulfill)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _actionChip(
                    label: 'Fulfill',
                    icon: Icons.local_pharmacy,
                    color: _fulfilledBadge,
                    onTap: () => safeSetState(() {
                      final idx = _prescriptions
                          .indexWhere((p) => p.rxNumber == rx.rxNumber);
                      if (idx >= 0) {
                        _prescriptions[idx] = Prescription(
                          rxNumber: rx.rxNumber,
                          patientName: rx.patientName,
                          prescriber: rx.prescriber,
                          medications: rx.medications,
                          status: RxStatus.fulfilled,
                          date: rx.date,
                          notes: rx.notes,
                          value: rx.value,
                        );
                      }
                    }),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: color),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── New Prescription Form ──
  void _showNewPrescriptionDialog(BuildContext context) {
    _model.patientNameTextController ??= TextEditingController();
    _model.prescriberTextController ??= TextEditingController();
    _model.notesTextController ??= TextEditingController();
    _model.patientNameTextController?.clear();
    _model.prescriberTextController?.clear();
    _model.notesTextController?.clear();
    _formMedLines = [
      MedicationLine(drug: '', dose: '', frequency: '', duration: '')
    ];

    String? validationError;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 760.0, maxHeight: 780.0),
            child: Material(
              color: Colors.white,
              elevation: 24.0,
              shadowColor: Colors.black.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(28.0),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 24.0, 20.0, 20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 52.0,
                          height: 52.0,
                          decoration: BoxDecoration(
                            color: _pulsePurpleLight,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child:
                              Icon(Icons.add, color: _pulsePurple, size: 28.0),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('New Prescription',
                                  style: TextStyle(
                                      fontFamily: kAppFontFamily,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary)),
                              const SizedBox(height: 3.0),
                              Text(
                                  'Record medication instructions for a patient.',
                                  style: TextStyle(
                                      fontFamily: kAppFontFamily,
                                      fontSize: 13.0,
                                      color: _textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close, color: _textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.0, color: _borderColor),
                  Flexible(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Patient name
                          _formField(
                            controller: _model.patientNameTextController,
                            focusNode: _model.patientNameFocusNode,
                            label: 'Patient Name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 14.0),
                          // Prescriber
                          _formField(
                            controller: _model.prescriberTextController,
                            focusNode: _model.prescriberFocusNode,
                            label: 'Prescriber',
                            icon: Icons.local_hospital,
                          ),
                          const SizedBox(height: 14.0),
                          // Date display
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16.0, color: _pulsePurple),
                              const SizedBox(width: 8.0),
                              Text(
                                'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: TextStyle(
                                    fontFamily: kAppFontFamily,
                                    fontSize: 13.0,
                                    color: _textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18.0),

                          // Medication lines header
                          Row(
                            children: [
                              Text('Medications',
                                  style: TextStyle(
                                    fontFamily: kAppFontFamily,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                    color: _textPrimary,
                                  )),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 3.0),
                                decoration: BoxDecoration(
                                  color: _pulsePurpleLight,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                    '${_formMedLines.length} line${_formMedLines.length == 1 ? '' : 's'}',
                                    style: TextStyle(
                                        fontFamily: kAppFontFamily,
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                        color: _pulsePurple)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                              'Add the medicine and directions exactly as prescribed.',
                              style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontSize: 12.0,
                                  color: _textSecondary)),
                          const SizedBox(height: 8.0),

                          // Medication lines
                          ..._formMedLines.asMap().entries.map((entry) {
                            final i = entry.key;
                            final line = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: _bgColor.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(14.0),
                                border:
                                    Border.all(color: _borderColor, width: 1.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Line ${i + 1}',
                                          style: TextStyle(
                                              fontFamily: kAppFontFamily,
                                              fontSize: 11.0,
                                              fontWeight: FontWeight.w600,
                                              color: _pulsePurple)),
                                      const Spacer(),
                                      if (_formMedLines.length > 1)
                                        IconButton(
                                          tooltip: 'Remove medication line',
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => setDialogState(
                                              () => _formMedLines.removeAt(i)),
                                          icon: Icon(Icons.close,
                                              size: 18.0, color: _expiredBadge),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isCompact =
                                          constraints.maxWidth < 500.0;
                                      final drugField = TextField(
                                        decoration: _medInputDec('Drug'),
                                        onChanged: (v) => line.drug = v,
                                      );
                                      final doseField = TextField(
                                        decoration: _medInputDec('Dose'),
                                        onChanged: (v) => line.dose = v,
                                      );
                                      final frequencyField = TextField(
                                        decoration: _medInputDec('Frequency'),
                                        onChanged: (v) => line.frequency = v,
                                      );
                                      final durationField = TextField(
                                        decoration: _medInputDec('Duration'),
                                        onChanged: (v) => line.duration = v,
                                      );
                                      if (isCompact) {
                                        return Column(
                                          children: [
                                            drugField,
                                            const SizedBox(height: 8.0),
                                            doseField,
                                            const SizedBox(height: 8.0),
                                            frequencyField,
                                            const SizedBox(height: 8.0),
                                            durationField,
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          Row(children: [
                                            Expanded(flex: 3, child: drugField),
                                            const SizedBox(width: 8.0),
                                            Expanded(flex: 2, child: doseField),
                                          ]),
                                          const SizedBox(height: 8.0),
                                          Row(children: [
                                            Expanded(child: frequencyField),
                                            const SizedBox(width: 8.0),
                                            Expanded(child: durationField),
                                          ]),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Add medication line
                          OutlinedButton.icon(
                            onPressed: () => setDialogState(
                              () => _formMedLines.add(MedicationLine(
                                  drug: '',
                                  dose: '',
                                  frequency: '',
                                  duration: '')),
                            ),
                            icon: Icon(Icons.add, size: 16.0),
                            label: Text('Add Medication'),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: _pulsePurple, width: 1.0),
                              foregroundColor: _pulsePurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // Notes
                          TextField(
                            controller: _model.notesTextController,
                            focusNode: _model.notesFocusNode,
                            minLines: 2,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Notes',
                              labelStyle: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  color: _textSecondary),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                    color: _pulsePurple, width: 2.0),
                              ),
                              prefixIcon: Icon(Icons.notes,
                                  color: _pulsePurple, size: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (validationError != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(28.0, 0.0, 28.0, 12.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _expiredBadge.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(children: [
                        Icon(Icons.info_outline,
                            size: 18.0, color: _expiredBadge),
                        const SizedBox(width: 8.0),
                        Expanded(
                            child: Text(validationError!,
                                style: TextStyle(
                                    fontFamily: kAppFontFamily,
                                    fontSize: 12.0,
                                    color: _expiredBadge))),
                      ]),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 20.0),
                    decoration: BoxDecoration(
                      color: _bgColor.withValues(alpha: 0.5),
                      border: Border(top: BorderSide(color: _borderColor)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('Cancel',
                              style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  color: _textSecondary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final patient =
                                _model.patientNameTextController?.text.trim() ??
                                    '';
                            final prescriber =
                                _model.prescriberTextController?.text.trim() ??
                                    '';
                            if (patient.isEmpty || prescriber.isEmpty) {
                              setDialogState(() => validationError =
                                  'Enter the patient name and prescriber before submitting.');
                              return;
                            }
                            final validMeds = _formMedLines
                                .where((m) => m.drug.isNotEmpty)
                                .toList();
                            if (validMeds.isEmpty) {
                              setDialogState(() => validationError =
                                  'Add at least one medication before submitting.');
                              return;
                            }

                            final newRx = Prescription(
                              rxNumber:
                                  'RX-2024-${(156 + _prescriptions.length + 1).toString().padLeft(4, '0')}',
                              patientName: patient,
                              prescriber: prescriber,
                              medications: validMeds,
                              status: RxStatus.pending,
                              date: DateTime.now(),
                              notes: _model.notesTextController?.text.trim(),
                              value: validMeds.length * 35.0,
                            );

                            safeSetState(() => _prescriptions.insert(0, newRx));
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(Icons.check_circle_outline,
                              size: 18.0),
                          label: Text('Save & Submit',
                              style: TextStyle(
                                  fontFamily: kAppFontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pulsePurple,
                            foregroundColor: Colors.white,
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 14.0),
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
      ),
    );
  }

  Widget _formField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(fontFamily: kAppFontFamily, color: _textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: _pulsePurple, width: 2.0),
        ),
        prefixIcon: Icon(icon, color: _pulsePurple, size: 20.0),
      ),
    );
  }

  InputDecoration _medInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontFamily: kAppFontFamily, fontSize: 12.0, color: _textSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _pulsePurple, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
    );
  }

  // ── Loading state widget ──
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitRing(color: _pulsePurple, size: 48.0),
            const SizedBox(height: 16.0),
            Text('Loading prescriptions...',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Digital Prescriptions',
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
                              // ── Header ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Digital Prescriptions',
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
                                          'Manage prescription lifecycle — create, verify, and fulfill prescriptions.',
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
                                  // New Prescription button (if has permission)
                                  if (AccessControl.hasPermission(
                                      context, Permission.prescriptionsCreate))
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _showNewPrescriptionDialog(context),
                                      icon: Icon(Icons.add, size: 18.0),
                                      label: Text('New Prescription'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _pulsePurple,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(9999.0),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0, vertical: 12.0),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 28.0),

                              // ── RBAC Gate ──
                              AuthUserStreamWidget(
                                builder: (context) {
                                  if (!AccessControl.hasPermission(
                                      context, Permission.prescriptionsView)) {
                                    return _buildNoAccessState();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ── Section 1: Summary Stats ──
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          double cardSpacing = 16.0;
                                          double minCardWidth = 180.0;
                                          int cols = (constraints.maxWidth ~/
                                                  (minCardWidth + cardSpacing))
                                              .clamp(1, 4);
                                          return Wrap(
                                            spacing: cardSpacing,
                                            runSpacing: cardSpacing,
                                            children: [
                                              SizedBox(
                                                width: (constraints.maxWidth -
                                                        cardSpacing *
                                                            (cols - 1)) /
                                                    cols,
                                                child: _buildStatCard(
                                                  title: 'Pending Verification',
                                                  value:
                                                      _pendingCount.toString(),
                                                  icon: Icons.schedule,
                                                  bgColor: _pulsePurpleLight,
                                                  iconColor: _pulsePurple,
                                                  textColor: _pulsePurpleDark,
                                                ),
                                              ),
                                              SizedBox(
                                                width: (constraints.maxWidth -
                                                        cardSpacing *
                                                            (cols - 1)) /
                                                    cols,
                                                child: _buildStatCard(
                                                  title: 'Ready to Fulfill',
                                                  value:
                                                      _verifiedCount.toString(),
                                                  icon: Icons.verified_outlined,
                                                  bgColor: _pulsePurpleLight,
                                                  iconColor: _pulsePurple,
                                                  textColor: _pulsePurpleDark,
                                                ),
                                              ),
                                              SizedBox(
                                                width: (constraints.maxWidth -
                                                        cardSpacing *
                                                            (cols - 1)) /
                                                    cols,
                                                child: _buildStatCard(
                                                  title: 'Fulfilled Today',
                                                  value: _fulfilledTodayCount
                                                      .toString(),
                                                  icon: Icons.check_circle,
                                                  bgColor: _pulsePurpleLight,
                                                  iconColor: _pulsePurple,
                                                  textColor: _pulsePurpleDark,
                                                ),
                                              ),
                                              SizedBox(
                                                width: (constraints.maxWidth -
                                                        cardSpacing *
                                                            (cols - 1)) /
                                                    cols,
                                                child: _buildStatCard(
                                                  title: 'Total Rx Value',
                                                  value:
                                                      'K${_totalRxValue.toStringAsFixed(0)}',
                                                  icon: Icons.attach_money,
                                                  bgColor: _pulsePurpleLight,
                                                  iconColor: _pulsePurple,
                                                  textColor: _pulsePurpleDark,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 28.0),

                                      // ── Search Bar ──
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          border: Border.all(
                                              color: _borderColor, width: 1.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.04),
                                              blurRadius: 20.0,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.search,
                                                color: _pulsePurple,
                                                size: 20.0),
                                            const SizedBox(width: 12.0),
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _model.searchTextController,
                                                focusNode:
                                                    _model.searchFocusNode,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Search by patient name or Rx number...',
                                                  hintStyle: TextStyle(
                                                      fontFamily:
                                                          kAppFontFamily,
                                                      color: _textSecondary,
                                                      fontSize: 14.0),
                                                  border: InputBorder.none,
                                                ),
                                                style: TextStyle(
                                                    fontFamily: kAppFontFamily,
                                                    fontSize: 14.0,
                                                    color: _textPrimary),
                                                onChanged: (val) =>
                                                    safeSetState(() {}),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20.0),

                                      // ── Section 3: Status Filter Tabs ──
                                      _buildFilterTabs(),

                                      const SizedBox(height: 20.0),

                                      // ── Prescription List ──
                                      if (_filteredPrescriptions.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(60.0),
                                          decoration: BoxDecoration(
                                            color: _surfaceColor,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            border: Border.all(
                                                color: _borderColor,
                                                width: 1.0),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                    Icons.receipt_long_outlined,
                                                    size: 56.0,
                                                    color: _textSecondary
                                                        .withValues(
                                                            alpha: 0.4)),
                                                const SizedBox(height: 16.0),
                                                Text('No prescriptions found',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            kAppFontFamily,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: _textSecondary)),
                                                const SizedBox(height: 8.0),
                                                Text(
                                                    'Click "New Prescription" to create one',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            kAppFontFamily,
                                                        fontSize: 13.0,
                                                        color: _textSecondary
                                                            .withValues(
                                                                alpha: 0.7))),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        ..._filteredPrescriptions.map(
                                            (rx) => _buildPrescriptionCard(rx)),
                                    ],
                                  );
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

  // ── No-access state ──
  Widget _buildNoAccessState() {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(
                color: _expiredBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, color: _expiredBadge, size: 32.0),
            ),
            const SizedBox(height: 16.0),
            Text('Access Denied',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
            const SizedBox(height: 8.0),
            Text('You do not have permission to view prescriptions.',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary)),
          ],
        ),
      ),
    );
  }
}
