import 'dart:async';

import '/rbac/rbac.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import '/index.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'duniya_pharmacies_model.dart';
export 'duniya_pharmacies_model.dart';

/// ═══════════════════════════════════════════════════════════════
///   PULSE — PHARMACIES (Network-Wide Listing)
///
///   Lists every pharmacy on the Pulse network (active, pending
///   approval, and rejected) with their owner email, registered
///   date, and network status. Network admins can search and filter
///   by status, and click into a pharmacy to view its details.
/// ═══════════════════════════════════════════════════════════════

class PulsePharmaciesWidget extends StatefulWidget {
  const PulsePharmaciesWidget({super.key});

  static String routeName = 'PulsePharmacies';
  static String routePath = '/pulsePharmacies';

  @override
  State<PulsePharmaciesWidget> createState() => _PulsePharmaciesWidgetState();
}

class _PulsePharmaciesWidgetState extends State<PulsePharmaciesWidget> {
  late PulsePharmaciesModel _model;
  late Stream<List<PharmacyRecord>> _pharmaciesStream;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Active status filter pill. One of: 'All', 'Active', 'Pending', 'Rejected'.
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PulsePharmaciesModel());
    _pharmaciesStream = _createPharmaciesStream();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'PulsePharmacies'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    // RBAC guard — only Pulse network users can access this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AccessControl.isPulseUser(context)) {
        context.goNamed(HomeWidget.routeName);
        return;
      }
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Keeps query errors visible to this page. The shared generated query helper
  /// logs and absorbs stream errors, which otherwise leaves a StreamBuilder in
  /// its loading state forever.
  Stream<List<PharmacyRecord>> _createPharmaciesStream() {
    return PharmacyRecord.collection()
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(PharmacyRecord.fromSnapshot)
            .toList(growable: false))
        .timeout(
      const Duration(seconds: 20),
      onTimeout: (sink) {
        sink.addError(TimeoutException(
          'The pharmacy list did not respond in time.',
        ));
        sink.close();
      },
    );
  }

  void _refreshPharmacies() {
    setState(() => _pharmaciesStream = _createPharmaciesStream());
  }

  // ─────────────────────────────────────────────────────────────
  //   HELPERS
  // ─────────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF10B981);
      case 'pending_approval':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFFD1FAE5);
      case 'pending_approval':
        return const Color(0xFFFEF3C7);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'pending_approval':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }

  DateTime _reconciliationDateFromFileName(String fileName) {
    const months = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12,
    };
    final match = RegExp(r'(\d{1,2})\s*([A-Z]{3,})', caseSensitive: false)
        .firstMatch(fileName);
    final month = match == null
        ? null
        : months[match.group(2)!.toUpperCase().substring(0, 3)];
    final day = match == null ? null : int.tryParse(match.group(1)!);
    if (month != null && day != null && day >= 1 && day <= 31) {
      return DateTime.utc(DateTime.now().year, month, day, 12);
    }
    return DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 12);
  }

  Future<void> _importSosMpiloReconciliation() async {
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;

      final file = selection.files.single;
      final reconciliationDate = _reconciliationDateFromFileName(file.name);
      final bytes = file.bytes;
      if (bytes == null)
        throw StateError('The selected workbook could not be read.');

      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook.tables['Recon Final'] ??
          (workbook.tables.isEmpty ? null : workbook.tables.values.first);
      if (sheet == null || sheet.rows.isEmpty) {
        throw StateError('The reconciliation worksheet is empty.');
      }

      String cellValue(dynamic cell) => cell?.value?.toString().trim() ?? '';
      String headerKey(dynamic cell) =>
          cellValue(cell).toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
      final header = sheet.rows.first;
      final columns = <String, int>{};
      for (var index = 0; index < header.length; index++) {
        final key = headerKey(header[index]);
        if (key.isNotEmpty) columns[key] = index;
      }
      const required = [
        'product name',
        'description',
        'opening stock',
        'stock supplied',
        'total available',
        'physical count',
        'units dispensed',
        'transfer unit price',
      ];
      if (required.any((key) => !columns.containsKey(key))) {
        throw StateError(
            'Use the Recon Final sheet with the approved reconciliation columns.');
      }

      String valueAt(List<dynamic> row, String key) {
        final index = columns[key]!;
        return index < row.length ? cellValue(row[index]) : '';
      }

      /// Convert Excel column letters (A, B, ..., Z, AA, AB, ...) to
      /// a 0-based column index. Declared BEFORE the functions that
      /// use it (Dart requires local functions to be declared before use).
      int? _excelColToIndex(String letters) {
        int result = 0;
        for (final c in letters.toUpperCase().codeUnits) {
          if (c < 65 || c > 90) return null;
          result = result * 26 + (c - 64);
        }
        return result - 1;
      }

      /// Resolve simple Excel formulas (=CELL op CELL) by looking up
      /// the referenced cells in the same row. Handles +, -, *, /.
      /// Returns null if the formula can't be evaluated.
      num? _evalFormula(String formula, List<dynamic> row,
          {required bool isInt}) {
        final expr = formula.substring(1).trim();
        // Match: CELLREF op CELLREF (e.g., F2-G2, J2*H2)
        final m = RegExp(r'^([A-Za-z]+)\d+\s*([+\-*/])\s*([A-Za-z]+)\d+$')
            .firstMatch(expr);
        if (m == null) return null;
        final leftColIdx = _excelColToIndex(m.group(1)!);
        final rightColIdx = _excelColToIndex(m.group(3)!);
        final op = m.group(2)!;
        if (leftColIdx == null || rightColIdx == null) return null;
        if (leftColIdx >= row.length || rightColIdx >= row.length) return null;
        final leftStr = cellValue(row[leftColIdx]);
        final rightStr = cellValue(row[rightColIdx]);
        final left = isInt
            ? int.tryParse(leftStr.replaceAll(RegExp(r'[^0-9-]'), ''))
            : double.tryParse(leftStr.replaceAll(RegExp(r'[^0-9.-]'), ''));
        final right = isInt
            ? int.tryParse(rightStr.replaceAll(RegExp(r'[^0-9-]'), ''))
            : double.tryParse(rightStr.replaceAll(RegExp(r'[^0-9.-]'), ''));
        if (left == null || right == null) return null;
        num result;
        switch (op) {
          case '+':
            result = left + right;
            break;
          case '-':
            result = left - right;
            break;
          case '*':
            result = left * right;
            break;
          case '/':
            if (right == 0) return null;
            result = left / right;
            break;
          default:
            return null;
        }
        return isInt ? result.toInt() : result;
      }

      int integerAt(List<dynamic> row, String key) {
        final raw = valueAt(row, key);
        if (raw.isEmpty) return -1;
        // If the cell contains a formula (e.g., '=F2-G2'), compute it
        // from the referenced cells in the same row. This handles the
        // common recon template formulas:
        //   =F{row}-G{row}  → Total Available - Physical Count
        //   =E{row}+D{row}  → Stock Supplied + Opening Stock
        // Without this, the formula string '=F2-G2' would be regex-
        // stripped to '2-2', int.tryParse fails → returns -1 → fails
        // the '< 0' check → 'Invalid totals' error.
        if (raw.startsWith('=')) {
          final computed = _evalFormula(raw, row, isInt: true);
          if (computed != null) return computed.toInt();
        }
        return int.tryParse(raw.replaceAll(RegExp(r'[^0-9-]'), '')) ?? -1;
      }

      double decimalAt(List<dynamic> row, String key) {
        final raw = valueAt(row, key);
        if (raw.isEmpty) return -1;
        if (raw.startsWith('=')) {
          final computed = _evalFormula(raw, row, isInt: false);
          if (computed != null) return computed.toDouble();
        }
        return double.tryParse(raw.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? -1;
      }

      final records = <Map<String, dynamic>>[];
      for (final row in sheet.rows.skip(1)) {
        final name = valueAt(row, 'product name');
        if (name.isEmpty) continue;
        final openingStock = integerAt(row, 'opening stock');
        final stockSupplied = integerAt(row, 'stock supplied');
        final totalAvailable = integerAt(row, 'total available');
        final physicalCount = integerAt(row, 'physical count');
        final unitsDispensed = integerAt(row, 'units dispensed');
        final unitCost = decimalAt(row, 'transfer unit price');
        if ([
              openingStock,
              stockSupplied,
              totalAvailable,
              physicalCount,
              unitsDispensed
            ].any((value) => value < 0) ||
            unitCost < 0 ||
            totalAvailable != openingStock + stockSupplied ||
            unitsDispensed != totalAvailable - physicalCount) {
          throw StateError(
              'Invalid totals in product "$name". Fix the workbook before import.');
        }
        records.add({
          'name': name,
          'description': valueAt(row, 'description'),
          'openingStock': openingStock,
          'stockSupplied': stockSupplied,
          'totalAvailable': totalAvailable,
          'physicalCount': physicalCount,
          'unitsDispensed': unitsDispensed,
          'unitCost': unitCost,
        });
      }
      if (records.isEmpty)
        throw StateError('No reconciliation records were found.');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.fact_check_rounded, color: Color(0xFF9900FF)),
          title: const Text('Import SOS Mpilo reconciliation?'),
          content: Text(
            '${records.length} product lines will create or update SOS Mpilo Pharmacy, its product catalogue, stock balances, movements, and a dated stock-count record for ${_formatDate(reconciliationDate)}. Re-importing this source updates the same historical records.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Import reconciliation')),
          ],
        ),
      );
      if (confirmed != true) return;

      final response = await FirebaseFunctions.instance
          .httpsCallable('importHistoricalReconciliation')
          .call({
        'pharmacyName': 'SOS Mpilo Pharmacy',
        'reconciliationDate': reconciliationDate.millisecondsSinceEpoch,
        'sourceFileName': file.name,
        'records': records,
      });
      final count = (response.data as Map?)?['productLines'] ?? records.length;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'SOS Mpilo Pharmacy imported with $count reconciliation lines.'),
            behavior: SnackBarBehavior.floating),
      );
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.message ?? 'The reconciliation import failed.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  /// Fetches a map of `ownerRef.path → UserRecord` for all unique owner refs
  /// across the supplied pharmacies. Failures are swallowed so a single bad
  /// user doc won't break the whole listing.
  Future<Map<String, UserRecord>> _fetchOwnerMap(
      List<PharmacyRecord> pharmacies) async {
    final refs = pharmacies
        .map((p) => p.userID)
        .whereType<DocumentReference>()
        .toSet()
        .toList();
    final map = <String, UserRecord>{};
    await Future.wait(refs.map((r) async {
      try {
        final snap = await r.get();
        if (snap.exists) {
          map[r.path] = UserRecord.fromSnapshot(snap);
        }
      } catch (_) {
        // Swallow — owner record may be deleted/inaccessible.
      }
    }));
    return map;
  }

  List<PharmacyRecord> _applyFilters(
      List<PharmacyRecord> all, Map<String, UserRecord> ownerMap) {
    final search = _model.searchTextController?.text.toLowerCase().trim() ?? '';
    return all.where((p) {
      // Status filter
      if (_statusFilter == 'Active' && p.networkStatus != 'active') {
        return false;
      }
      if (_statusFilter == 'Pending' && p.networkStatus != 'pending_approval') {
        return false;
      }
      if (_statusFilter == 'Rejected' && p.networkStatus != 'rejected') {
        return false;
      }
      // Search filter
      if (search.isEmpty) return true;
      final owner = p.userID != null ? ownerMap[p.userID!.path] : null;
      final ownerEmail = owner?.email.toLowerCase() ?? '';
      final ownerName = owner?.displayName.toLowerCase() ?? '';
      return p.name.toLowerCase().contains(search) ||
          p.address.toLowerCase().contains(search) ||
          ownerEmail.contains(search) ||
          ownerName.contains(search);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  // ─────────────────────────────────────────────────────────────
  //   BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Title(
      title: 'Pulse Pharmacies',
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
              child: const SideNavWidget(),
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
                    child: const SideNavWidget(),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0.0, -1.0),
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24.0, 8.0, 24.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroHeader(),
                              const SizedBox(height: 24.0),
                              _buildPharmacyContent(),
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   HERO HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroHeader() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(28.0, 24.0, 28.0, 24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, theme.secondary],
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withAlpha(40),
            blurRadius: 24.0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.white.withAlpha(180), size: 14),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Pulse Network',
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withAlpha(120), size: 14),
              Text(
                'Pharmacies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.white.withAlpha(60),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.local_pharmacy_rounded,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pulse Pharmacies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Browse every pharmacy on the Pulse network — active, pending approval, and rejected. Click any pharmacy to view its details.',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
              )) ...[
                _heroAction(Icons.download_rounded, 'Template',
                    downloadReconciliationTemplate),
                const SizedBox(width: 10.0),
                _heroAction(Icons.upload_file_rounded, 'Import reconciliation',
                    _importSosMpiloReconciliation),
                const SizedBox(width: 10.0),
                _heroAction(
                    Icons.refresh_rounded, 'Refresh', _refreshPharmacies),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroAction(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.white.withAlpha(50), width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   MAIN CONTENT (StreamBuilder → KPIs + Filters + List)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyContent() {
    return StreamBuilder<List<PharmacyRecord>>(
      stream: _pharmaciesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildLoadErrorState();
        }
        if (!snapshot.hasData) {
          return _buildLoadingState();
        }
        final allPharmacies = snapshot.data!.where((p) => !p.deleted).toList();
        if (allPharmacies.isEmpty) {
          return _buildEmptyState();
        }
        return FutureBuilder<Map<String, UserRecord>>(
          future: _fetchOwnerMap(allPharmacies),
          builder: (context, ownerSnap) {
            final ownerMap = ownerSnap.data ?? {};
            final filtered = _applyFilters(allPharmacies, ownerMap);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiRow(allPharmacies),
                const SizedBox(height: 20.0),
                _buildFilterBar(),
                const SizedBox(height: 16.0),
                _buildStatusPills(allPharmacies),
                const SizedBox(height: 16.0),
                if (filtered.isEmpty)
                  _buildNoMatchState()
                else
                  _buildPharmacyList(filtered, ownerMap),
              ],
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   KPI ROW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildKpiRow(List<PharmacyRecord> pharmacies) {
    final total = pharmacies.length;
    final active = pharmacies.where((p) => p.networkStatus == 'active').length;
    final pending =
        pharmacies.where((p) => p.networkStatus == 'pending_approval').length;
    final rejected =
        pharmacies.where((p) => p.networkStatus == 'rejected').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final crossAxisCount = wide ? 4 : 2;
        return Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Total Pharmacies',
                value: '$total',
                icon: Icons.storefront_rounded,
                color: FlutterFlowTheme.of(context).primary,
                bgColor: FlutterFlowTheme.of(context).primary.withAlpha(20),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Active',
                value: '$active',
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFD1FAE5),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Pending Approval',
                value: '$pending',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - (crossAxisCount - 1) * 12.0) /
                  crossAxisCount,
              child: _kpiCard(
                title: 'Rejected',
                value: '$rejected',
                icon: Icons.cancel_rounded,
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEE2E2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   FILTER BAR (search + reset)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFilterBar() {
    final theme = FlutterFlowTheme.of(context);
    final hasActiveFilters =
        (_model.searchTextController?.text ?? '').isNotEmpty ||
            _statusFilter != 'All';
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 320.0,
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: theme.alternate, width: 1.0),
            ),
            child: TextField(
              controller: _model.searchTextController,
              focusNode: _model.searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search by name, address, or owner email…',
                hintStyle: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.secondaryText, size: 20.0),
                suffixIcon: (_model.searchTextController?.text ?? '').isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: theme.secondaryText, size: 18.0),
                        onPressed: () {
                          _model.searchTextController?.clear();
                          safeSetState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                    12.0, 12.0, 12.0, 12.0),
              ),
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
              onChanged: (value) => safeSetState(() {}),
            ),
          ),
          if (hasActiveFilters)
            TextButton.icon(
              onPressed: () {
                _model.searchTextController?.clear();
                setState(() => _statusFilter = 'All');
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 16.0),
              label: Text(
                'Reset',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATUS PILLS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatusPills(List<PharmacyRecord> pharmacies) {
    final theme = FlutterFlowTheme.of(context);
    final all = pharmacies.length;
    final active = pharmacies.where((p) => p.networkStatus == 'active').length;
    final pending =
        pharmacies.where((p) => p.networkStatus == 'pending_approval').length;
    final rejected =
        pharmacies.where((p) => p.networkStatus == 'rejected').length;

    final pills = <(String, int, Color)>[
      ('All', all, theme.primary),
      ('Active', active, const Color(0xFF10B981)),
      ('Pending', pending, const Color(0xFFF59E0B)),
      ('Rejected', rejected, const Color(0xFFEF4444)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pills.map((p) {
          final (label, count, color) = p;
          final selected = _statusFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => safeSetState(() => _statusFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: selected ? color : theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                      color: selected ? color : theme.alternate, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? Colors.white : theme.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withAlpha(40)
                            : theme.primaryBackground,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: selected ? Colors.white : theme.secondaryText,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   PHARMACY LIST
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPharmacyList(
      List<PharmacyRecord> pharmacies, Map<String, UserRecord> ownerMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            '${pharmacies.length} ${pharmacies.length == 1 ? 'pharmacy' : 'pharmacies'}',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          children:
              pharmacies.map((p) => _buildPharmacyCard(p, ownerMap)).toList(),
        ),
      ],
    );
  }

  Widget _buildPharmacyCard(
      PharmacyRecord pharmacy, Map<String, UserRecord> ownerMap) {
    final theme = FlutterFlowTheme.of(context);
    final status = pharmacy.networkStatus;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);
    final owner =
        pharmacy.userID != null ? ownerMap[pharmacy.userID!.path] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withAlpha(8),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            context.pushNamed(
              PharmacyDetailWidget.routeName,
              queryParameters: {
                'pharmacyName': serializeParam(pharmacy.name, ParamType.String),
              }.withoutNulls,
            );
          },
          child: Padding(
            padding:
                const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.primary, theme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: const Icon(Icons.local_pharmacy_rounded,
                      color: Colors.white, size: 24.0),
                ),
                const SizedBox(width: 14.0),
                // Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pharmacy.name,
                              style: theme.titleMedium.override(
                                fontFamily: theme.titleMediumFamily,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                useGoogleFonts: !theme.titleMediumIsCustom,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: statusColor.withAlpha(60), width: 1.0),
                            ),
                            child: Text(
                              _statusLabel(status).toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (pharmacy.address.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13.0, color: theme.secondaryText),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                pharmacy.address,
                                style: theme.bodySmall.override(
                                  fontFamily: theme.bodySmallFamily,
                                  color: theme.secondaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.bodySmallIsCustom,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6.0),
                      Wrap(
                        spacing: 14.0,
                        runSpacing: 4.0,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 13.0, color: theme.secondaryText),
                              const SizedBox(width: 4.0),
                              Text(
                                'Registered ${_formatDate(pharmacy.registeredAt)}',
                                style: TextStyle(
                                  color: theme.secondaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 13.0, color: theme.secondaryText),
                              const SizedBox(width: 4.0),
                              Text(
                                owner == null
                                    ? 'Owner not linked'
                                    : (owner.email.isNotEmpty
                                        ? owner.email
                                        : (owner.displayName.isNotEmpty
                                            ? owner.displayName
                                            : 'Unknown owner')),
                                style: TextStyle(
                                  color: owner == null
                                      ? theme.secondaryText
                                      : theme.primaryText,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(Icons.chevron_right_rounded,
                    color: theme.secondaryText, size: 22.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //   STATES (loading / empty / no-match)
  // ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 60.0, 0.0, 60.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(color: theme.primary, size: 48.0, lineWidth: 3.0),
          const SizedBox(height: 20.0),
          Text(
            'Loading network pharmacies…',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Fetching pharmacies and their owners across the network',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadErrorState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 56.0, 32.0, 56.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: theme.secondaryText, size: 44),
          const SizedBox(height: 16.0),
          Text(
            'Unable to load network pharmacies',
            style: theme.titleLarge.override(
              fontFamily: theme.titleLargeFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              useGoogleFonts: !theme.titleLargeIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Check your connection and try again. If the problem continues, verify that this account can access the Pulse network.',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          FFButtonWidget(
            onPressed: _refreshPharmacies,
            text: 'Try again',
            icon: const Icon(Icons.refresh_rounded, size: 18.0),
            options: FFButtonOptions(
              height: 42.0,
              padding:
                  const EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 18.0, 0.0),
              color: theme.primary,
              textStyle: theme.labelLarge.override(
                fontFamily: theme.labelLargeFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.labelLargeIsCustom,
              ),
              elevation: 0.0,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 56.0, 32.0, 56.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.primary, theme.secondary],
              ),
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: const Icon(Icons.local_pharmacy_rounded,
                color: Colors.white, size: 40.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'No pharmacies on the network yet',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Once a pharmacy registers on Pulse, it will appear here for you to review and manage.',
            textAlign: TextAlign.center,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMatchState() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 40.0, 32.0, 40.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              color: theme.secondaryText, size: 40.0),
          const SizedBox(height: 12.0),
          Text(
            'No pharmacies match your filters',
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Try clearing your search or selecting a different status.',
            textAlign: TextAlign.center,
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}
