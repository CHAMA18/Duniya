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
import 'smart_reconciliation_parser.dart';
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

  /// Pharmacy display mode: 'list' (full-width rows) or 'grid'
  /// (compact cards in a responsive grid).
  String _viewMode = 'list';

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

  /// Keeps query errors visible to this page. Wraps the Firestore stream
  /// with automatic retry (3 attempts, 2-second delay between retries)
  /// and a 30-second timeout per attempt. If all retries fail, the
  /// actual error is propagated to the StreamBuilder so the user can
  /// see what went wrong (not just a generic "unable to load" message).
  Stream<List<PharmacyRecord>> _createPharmaciesStream() {
    return _queryWithRetry(queryPharmacyRecord(), maxRetries: 3);
  }

  /// Wraps a Firestore stream with automatic retry logic. On each error,
  /// waits 2 seconds and retries (up to maxRetries times). The actual
  /// error from the final failed attempt is propagated to the caller.
  Stream<List<PharmacyRecord>> _queryWithRetry(
    Stream<List<PharmacyRecord>> source, {
    int maxRetries = 3,
  }) {
    int retries = 0;
    late StreamController<List<PharmacyRecord>> controller;
    StreamSubscription<List<PharmacyRecord>>? subscription;

    void subscribe() {
      subscription?.cancel();
      subscription = source.timeout(
        const Duration(seconds: 30),
        onTimeout: (sink) {
          sink.addError(TimeoutException(
            'The pharmacy list did not respond in 30 seconds.',
          ));
          sink.close();
        },
      ).listen(
        controller.add,
        onError: (error) {
          retries++;
          if (retries >= maxRetries) {
            // All retries exhausted — propagate the real error.
            controller.addError(error);
            controller.close();
          } else {
            // Wait 2 seconds, then retry.
            Future.delayed(const Duration(seconds: 2), subscribe);
          }
        },
        onDone: () {
          controller.close();
        },
      );
    }

    controller = StreamController<List<PharmacyRecord>>(
      onListen: subscribe,
      onCancel: () {
        subscription?.cancel();
      },
    );

    return controller.stream;
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
    final monthText = match?.group(2)?.toUpperCase();
    final month = monthText == null || monthText.length < 3
        ? null
        : months[monthText.substring(0, 3)];
    final day = int.tryParse(match?.group(1) ?? '');
    if (month != null && day != null && day >= 1 && day <= 31) {
      return DateTime.utc(DateTime.now().year, month, day, 12);
    }
    return DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 12);
  }

  /// Requires an explicit destination before a reconciliation can write any
  /// inventory data. A filename is not a trustworthy source of pharmacy
  /// identity, so the selected document reference is sent to the callable
  /// import instead.
  ///
  /// The dialog also surfaces the Smart Import summary: how many rows
  /// validated, how many were auto-skipped (with the top reasons), and
  /// whether unit prices were defaulted.
  Future<PharmacyRecord?> _confirmReconciliationTarget({
    required int lineCount,
    required DateTime reconciliationDate,
    required String sourceFileName,
    List<SmartSkippedRow> skipped = const [],
    int priceDefaultedCount = 0,
    String? detectedSheetName,
  }) async {
    final pharmacies = (await queryPharmacyRecordOnce())
        .where((pharmacy) =>
            !pharmacy.deleted &&
            pharmacy.networkStatus.toLowerCase() == 'active')
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (pharmacies.isEmpty) {
      throw StateError(
          'No approved pharmacies are available for this reconciliation.');
    }

    return showDialog<PharmacyRecord>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        PharmacyRecord? selected;
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF9900FF)],
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fact_check_rounded,
                            color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm reconciliation target',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Choose where the inventory count belongs.',
                                style: TextStyle(
                                  color: Color(0xFFE9D5FF),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$lineCount validated product lines · ${_formatDate(reconciliationDate)}\n$sourceFileName',
                            style: const TextStyle(
                              color: Color(0xFF5B21B6),
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // ── Smart Import summary ──
                        if (skipped.isNotEmpty ||
                            priceDefaultedCount > 0 ||
                            (detectedSheetName?.isNotEmpty ?? false)) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFDE68A), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.auto_awesome_rounded,
                                      size: 15, color: Color(0xFFB45309)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Smart Import',
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 6),
                                if (detectedSheetName?.isNotEmpty ?? false)
                                  Text(
                                    'Detected data on sheet “$detectedSheetName” — unrelated rows and columns were ignored.',
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 12,
                                      height: 1.45,
                                    ),
                                  ),
                                if (skipped.isNotEmpty) ...[
                                  Text(
                                    '${skipped.length} row${skipped.length == 1 ? '' : 's'} skipped:',
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 12,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ...skipped
                                      .take(3)
                                      .map((s) => Text(
                                            '• ${s.describe()}',
                                            style: const TextStyle(
                                              color: Color(0xFF92400E),
                                              fontSize: 11.5,
                                              height: 1.5,
                                            ),
                                          )),
                                  if (skipped.length > 3)
                                    Text(
                                      '• +${skipped.length - 3} more',
                                      style: const TextStyle(
                                        color: Color(0xFF92400E),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                ],
                                if (priceDefaultedCount > 0)
                                  Text(
                                    '• Unit price defaulted to 0 on $priceDefaultedCount row${priceDefaultedCount == 1 ? '' : 's'} (no readable price found).',
                                    style: const TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 11.5,
                                      height: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Text(
                          'Approved pharmacy',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selected?.reference.path,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText:
                                'Select the pharmacy for this reconciliation',
                            prefixIcon:
                                const Icon(Icons.local_pharmacy_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: pharmacies
                              .map(
                                (pharmacy) => DropdownMenuItem(
                                  value: pharmacy.reference.path,
                                  child: Text(
                                    pharmacy.address.isEmpty
                                        ? pharmacy.name
                                        : '${pharmacy.name} · ${pharmacy.address}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (path) => setDialogState(() {
                            selected = pharmacies.firstWhere(
                              (pharmacy) => pharmacy.reference.path == path,
                            );
                          }),
                        ),
                        if (selected != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Inventory, movements, and the audit count will be recorded in ${selected!.name}.',
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: selected == null
                              ? null
                              : () => Navigator.pop(dialogContext, selected),
                          icon: const Icon(Icons.upload_rounded, size: 18),
                          label: const Text('Import reconciliation'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Smart Import: picks an .xlsx or .csv reconciliation export and
  /// imports every row that matches the expected format — the sheet,
  /// the header row and the columns are auto-detected (with common
  /// header-name variants), irrelevant rows (blank lines, section
  /// headings, notes, grand totals) and broken rows are skipped with
  /// visible reasons instead of failing the whole import, and missing
  /// linear totals are derived where possible.
  Future<void> _importSosMpiloReconciliation() async {
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx', 'csv'],
        withData: true,
      );
      if (selection == null || selection.files.isEmpty) return;

      final file = selection.files.single;
      final reconciliationDate = _reconciliationDateFromFileName(file.name);
      final bytes = file.bytes;
      if (bytes == null)
        throw StateError('The selected file could not be read.');

      // File size guard — prevent browser freeze on very large workbooks.
      if (bytes.length > 10 * 1024 * 1024) {
        throw StateError(
            'The file is too large (${(bytes.length / 1024 / 1024).toStringAsFixed(1)}MB). '
                'Maximum file size is 10MB. Please split it and import in batches.');
      }

      // ── Read every sheet into plain string rows ──────────────────
      // CSV files become a single pseudo-sheet; XLSX workbooks expose
      // every worksheet so the detector can pick the data sheet itself.
      final Map<String, List<List<String>>> sheets;
      final isCsv = file.name.toLowerCase().endsWith('.csv');
      if (isCsv) {
        sheets = {
          'CSV import': SmartReconciliationParser.parseCsv(
              String.fromCharCodes(bytes)),
        };
      } else {
        final workbook = Excel.decodeBytes(bytes);
        sheets = {
          for (final entry in workbook.tables.entries)
            entry.key: [
              for (final row in entry.value.rows)
                [
                  for (var i = 0; i < row.length; i++)
                    row[i]?.value?.toString().trim() ?? ''
                ],
            ],
        };
      }
      if (sheets.isEmpty || sheets.values.every((rows) => rows.isEmpty)) {
        throw StateError('The file does not contain any readable rows.');
      }

      // ── Smart detection: best sheet + header row + columns ───────
      final match =
          SmartReconciliationParser.detectBestSheet(sheets);
      if (match == null) {
        throw StateError(
            'No reconciliation table was found. Smart Import looks for columns '
            'like Product Name, Opening Stock, Stock Supplied, Total Available, '
            'Physical Count, Units Dispensed and Unit Price — common variants '
            '(Product, Opening Balance, Received Qty, Counted, Dispensed…) are '
            'recognised automatically. Check the sheet and try again.');
      }
      final parse = match.parse;

      if (parse.records.isEmpty) {
        final top = parse.skipped.isNotEmpty
            ? ' ${parse.skipped.length} rows were read but skipped — for example: '
                '${parse.skipped.first.describe()}.'
            : '';
        throw StateError(
            'No importable product rows were found under the detected header '
            '(sheet “${parse.sheetName}”, row ${parse.headerRowNumber}).'
            '$top');
      }

      final pharmacy = await _confirmReconciliationTarget(
        lineCount: parse.records.length,
        reconciliationDate: reconciliationDate,
        sourceFileName: file.name,
        skipped: parse.skipped,
        priceDefaultedCount: parse.priceDefaultedCount,
        detectedSheetName: isCsv ? null : match.sheetName,
      );
      if (pharmacy == null) return;

      final response = await FirebaseFunctions.instance
          .httpsCallable('importHistoricalReconciliation')
          .call({
        'pharmacyPath': pharmacy.reference.path,
        'reconciliationDate': reconciliationDate.millisecondsSinceEpoch,
        'sourceFileName': file.name,
        'records': parse.records,
      });
      final count = (response.data as Map?)?['productLines'] ?? parse.records.length;
      if (!mounted) return;
      final skippedNote = parse.skipped.isNotEmpty
          ? ' (${parse.skipped.length} unrelated rows were skipped)'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${pharmacy.name} imported with $count reconciliation lines$skippedNote.'),
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
          return _buildLoadErrorState(snapshot.error);
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
                const SizedBox(height: 16.0),
                // Toolbar: Template + Import reconciliation + Refresh
                // (moved from the header banner into the content area
                // so it's always visible, not just on wide screens)
                _buildToolbar(context),
                const SizedBox(height: 16.0),
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
  //   TOOLBAR — Template / Import / Refresh
  // ═══════════════════════════════════════════════════════════════

  Widget _buildToolbar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _toolbarButton(
          theme,
          icon: Icons.download_rounded,
          label: 'Template',
          onTap: downloadReconciliationTemplate,
          accent: const Color(0xFF3B82F6),
        ),
        _toolbarButton(
          theme,
          icon: Icons.upload_file_rounded,
          label: 'Import reconciliation',
          onTap: _importSosMpiloReconciliation,
          accent: theme.primary,
        ),
        _toolbarButton(
          theme,
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          onTap: _refreshPharmacies,
          accent: const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _toolbarButton(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Material(
      color: theme.secondaryBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryText,
                  )),
            ],
          ),
        ),
      ),
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
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Search is the primary control on this page. It deliberately
            // occupies the complete available filter bar width instead of a
            // fixed desktop-sized field, so long pharmacy names and emails
            // remain easy to search on wide workspaces.
            Container(
              width: constraints.maxWidth,
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
                  suffixIcon:
                      (_model.searchTextController?.text ?? '').isNotEmpty
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
        // Count + view toggle row.
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${pharmacies.length} ${pharmacies.length == 1 ? 'pharmacy' : 'pharmacies'}',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildViewToggle(),
            ],
          ),
        ),
        if (_viewMode == 'list')
          Column(
            children:
                pharmacies.map((p) => _buildPharmacyCard(p, ownerMap)).toList(),
          )
        else
          _buildPharmacyGrid(pharmacies, ownerMap),
      ],
    );
  }

  /// Segmented list/grid toggle. Grid shows compact cards in a
  /// responsive grid; list keeps the detailed full-width rows.
  Widget _buildViewToggle() {
    final theme = FlutterFlowTheme.of(context);
    Widget segment(String mode, IconData icon, String label, String tooltip) {
      final selected = _viewMode == mode;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => safeSetState(() => _viewMode = mode),
          borderRadius: BorderRadius.circular(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: selected ? theme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15.0,
                  color: selected ? Colors.white : theme.secondaryText,
                ),
                const SizedBox(width: 6.0),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : theme.secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('list', Icons.view_list_rounded, 'List', 'List view'),
          segment('grid', Icons.grid_view_rounded, 'Grid', 'Grid view'),
        ],
      ),
    );
  }

  /// Responsive grid of compact pharmacy cards. Column count adapts
  /// to the available width (min card width 240px).
  Widget _buildPharmacyGrid(
      List<PharmacyRecord> pharmacies, Map<String, UserRecord> ownerMap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 14.0;
        const minCardWidth = 240.0;
        var columns =
            ((constraints.maxWidth + gap) / (minCardWidth + gap)).floor();
        if (columns < 1) columns = 1;
        final cardWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: pharmacies
              .map((p) => SizedBox(
                    width: cardWidth,
                    child: _buildPharmacyGridCard(p, ownerMap),
                  ))
              .toList(),
        );
      },
    );
  }

  /// Compact grid variant of the pharmacy card: larger avatar block on
  /// top, name, status badge, address and owner — same navigation as
  /// the list card.
  Widget _buildPharmacyGridCard(
      PharmacyRecord pharmacy, Map<String, UserRecord> ownerMap) {
    final theme = FlutterFlowTheme.of(context);
    final status = pharmacy.networkStatus;
    final statusColor = _statusColor(status);
    final statusBg = _statusBgColor(status);
    final owner =
        pharmacy.userID != null ? ownerMap[pharmacy.userID!.path] : null;

    return Container(
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
                'pharmacyName':
                    serializeParam(pharmacy.name, ParamType.String),
                'pharmacyReference': serializeParam(
                  pharmacy.reference,
                  ParamType.DocumentReference,
                ),
              }.withoutNulls,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + status badge
                Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [theme.primary, theme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(Icons.local_pharmacy_rounded,
                          color: Colors.white, size: 22.0),
                    ),
                    const Spacer(),
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
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                // Name
                Text(
                  pharmacy.name,
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    fontSize: 15.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (pharmacy.address.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            fontSize: 11.5,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.bodySmallIsCustom,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10.0),
                // Owner
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 13.0, color: theme.secondaryText),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                // Registered date
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 13.0, color: theme.secondaryText),
                    const SizedBox(width: 4.0),
                    Text(
                      'Registered ${_formatDate(pharmacy.registeredAt)}',
                      style: TextStyle(
                        color: theme.secondaryText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
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
                'pharmacyReference': serializeParam(
                  pharmacy.reference,
                  ParamType.DocumentReference,
                ),
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

  Widget _buildLoadErrorState([Object? error]) {
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
            'Check your connection and try again. If the problem continues, verify that this account can access the Pulse network.${error != null ? '\n\nTechnical detail: $error' : ''}',
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
