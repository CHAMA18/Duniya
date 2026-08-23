import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '/flutter_flow/platform_download.dart';
import 'expiry_tracking_model.dart';
export 'expiry_tracking_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// EXPIRY TRACKING DASHBOARD
// Bloomberg terminal × Pharmaceutical dashboard
// ═══════════════════════════════════════════════════════════════════════

class ExpiryTrackingWidget extends StatefulWidget {
  const ExpiryTrackingWidget({super.key});

  static String routeName = 'ExpiryTracking';
  static String routePath = '/expiry-tracking';

  @override
  State<ExpiryTrackingWidget> createState() => _ExpiryTrackingWidgetState();
}

// ── Mock batch data model for expiry tracking ──
class ExpiryBatch {
  final String productName;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final String facility;

  ExpiryBatch({
    required this.productName,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.facility,
  });

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;

  String get statusLabel {
    final d = daysLeft;
    if (d < 0) return 'Expired';
    if (d < 30) return '<30 Days';
    if (d < 60) return '30-60 Days';
    if (d < 90) return '60-90 Days';
    return '90+ Days';
  }
}

class _ExpiryTrackingWidgetState extends State<ExpiryTrackingWidget>
    with TickerProviderStateMixin {
  late ExpiryTrackingModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Pulse Purple design tokens ──
  static const Color _pulsePurple = Color(0xFF9900FF);

  /// Theme-aware palette — dark values mirror the app-wide Pulse dark
  /// theme (DarkModeTheme: #111827 bg, #1E1B2E surface, #F9FAFB text).
  bool _isDark = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDark = Theme.of(context).brightness == Brightness.dark;
  }

  Color get _pulsePurpleLight =>
      _isDark ? const Color(0xFF2A2140) : Color(0xFFF3F0FF);
  static const Color _pulsePurpleDark = Color(0xFF7C3AED);
  Color get _bgColor =>
      _isDark ? const Color(0xFF111827) : Color(0xFFF8F9FF);
  Color get _surfaceColor =>
      _isDark ? const Color(0xFF1E1B2E) : Colors.white;
  Color get _textPrimary =>
      _isDark ? const Color(0xFFF9FAFB) : Color(0xFF0B1C30);
  Color get _textSecondary =>
      _isDark ? const Color(0xFF9CA3AF) : Color(0xFF64748B);
  Color get _borderColor =>
      _isDark ? const Color(0xFF3B3B4F) : Color(0xFFE2E8F0);

  // ── Expiry severity colour system ──
  // EXPIRED
  Color get _expiredBg =>
      _isDark ? const Color(0xFFDC2626).withAlpha(30) : Color(0xFFFEE2E2);
  Color get _expiredText =>
      _isDark ? const Color(0xFFFCA5A5) : Color(0xFF991B1B);
  static const Color _expiredBadge = Color(0xFFDC2626);
  // < 30 days
  Color get _under30Bg =>
      _isDark ? const Color(0xFFEA580C).withAlpha(30) : Color(0xFFFFEDD5);
  Color get _under30Text =>
      _isDark ? const Color(0xFFFDBA74) : Color(0xFF9A3412);
  static const Color _under30Badge = Color(0xFFEA580C);
  // 30-60 days
  Color get _d30to60Bg =>
      _isDark ? const Color(0xFFCA8A04).withAlpha(30) : Color(0xFFFEF9C3);
  Color get _d30to60Text =>
      _isDark ? const Color(0xFFFDE047) : Color(0xFF854D0E);
  static const Color _d30to60Badge = Color(0xFFCA8A04);
  // 60-90 days
  Color get _d60to90Bg =>
      _isDark ? const Color(0xFF2563EB).withAlpha(30) : Color(0xFFE0F2FE);
  Color get _d60to90Text =>
      _isDark ? const Color(0xFF93C5FD) : Color(0xFF1E40AF);
  static const Color _d60to90Badge = Color(0xFF2563EB);
  // 90+ days (safe)
  Color get _safeBg =>
      _isDark ? const Color(0xFF059669).withAlpha(30) : Color(0xFFD1FAE5);
  Color get _safeText =>
      _isDark ? const Color(0xFF6EE7B7) : Color(0xFF065F46);
  static const Color _safeBadge = Color(0xFF059669);

  // ── Animation controllers for count-up numbers ──
  late AnimationController _countUpController;
  late Animation<double> _countUpAnimation;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExpiryTrackingModel());
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'ExpiryTracking'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();

    // Count-up animation (1.2s ease-out)
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
  // MOCK DATA — realistic pharmacy batch data
  // ═══════════════════════════════════════════════════════════════════
  List<ExpiryBatch> get _mockBatches {
    return <ExpiryBatch>[];
    final now = DateTime.now();
    return [
      ExpiryBatch(
        productName: 'Paracetamol 500mg',
        batchNumber: 'B-2024-001',
        expiryDate: now.subtract(const Duration(days: 5)),
        quantity: 250,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Amoxicillin 250mg',
        batchNumber: 'B-2024-015',
        expiryDate: now.subtract(const Duration(days: 2)),
        quantity: 120,
        facility: 'Cold Storage',
      ),
      ExpiryBatch(
        productName: 'Ibuprofen 400mg',
        batchNumber: 'B-2024-023',
        expiryDate: now.add(const Duration(days: 8)),
        quantity: 300,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Metformin 500mg',
        batchNumber: 'B-2024-007',
        expiryDate: now.add(const Duration(days: 23)),
        quantity: 450,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Ciprofloxacin 500mg',
        batchNumber: 'B-2024-031',
        expiryDate: now.add(const Duration(days: 17)),
        quantity: 180,
        facility: 'Branch A',
      ),
      ExpiryBatch(
        productName: 'Omeprazole 20mg',
        batchNumber: 'B-2024-042',
        expiryDate: now.add(const Duration(days: 45)),
        quantity: 200,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Amlodipine 5mg',
        batchNumber: 'B-2024-019',
        expiryDate: now.add(const Duration(days: 52)),
        quantity: 340,
        facility: 'Branch B',
      ),
      ExpiryBatch(
        productName: 'Azithromycin 250mg',
        batchNumber: 'B-2024-055',
        expiryDate: now.add(const Duration(days: 38)),
        quantity: 90,
        facility: 'Cold Storage',
      ),
      ExpiryBatch(
        productName: 'Lisinopril 10mg',
        batchNumber: 'B-2024-068',
        expiryDate: now.add(const Duration(days: 72)),
        quantity: 275,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Salbutamol 100mcg',
        batchNumber: 'B-2024-073',
        expiryDate: now.add(const Duration(days: 85)),
        quantity: 150,
        facility: 'Branch A',
      ),
      ExpiryBatch(
        productName: 'Atorvastatin 20mg',
        batchNumber: 'B-2024-081',
        expiryDate: now.add(const Duration(days: 65)),
        quantity: 400,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Cetirizine 10mg',
        batchNumber: 'B-2024-092',
        expiryDate: now.add(const Duration(days: 120)),
        quantity: 500,
        facility: 'Main Store',
      ),
      ExpiryBatch(
        productName: 'Ranitidine 150mg',
        batchNumber: 'B-2024-098',
        expiryDate: now.add(const Duration(days: 200)),
        quantity: 350,
        facility: 'Branch B',
      ),
      ExpiryBatch(
        productName: 'Diazepam 5mg',
        batchNumber: 'B-2024-104',
        expiryDate: now.add(const Duration(days: 310)),
        quantity: 100,
        facility: 'Controlled Substance Vault',
      ),
      ExpiryBatch(
        productName: 'Diclofenac 50mg',
        batchNumber: 'B-2024-112',
        expiryDate: now.add(const Duration(days: 180)),
        quantity: 220,
        facility: 'Main Store',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUCKET CLASSIFICATION HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Map<String, int> _getBucketCounts(List<ExpiryBatch> batches) {
    int expired = 0, under30 = 0, d30to60 = 0, d60to90 = 0, safe = 0;
    for (final b in batches) {
      final d = b.daysLeft;
      if (d < 0)
        expired++;
      else if (d < 30)
        under30++;
      else if (d < 60)
        d30to60++;
      else if (d < 90)
        d60to90++;
      else
        safe++;
    }
    return {
      'expired': expired,
      'under30': under30,
      'd30to60': d30to60,
      'd60to90': d60to90,
      'safe': safe,
      'total': batches.length,
    };
  }

  Color _bucketBg(String bucket) {
    switch (bucket) {
      case 'Expired':
        return _expiredBg;
      case '<30 Days':
        return _under30Bg;
      case '30-60 Days':
        return _d30to60Bg;
      case '60-90 Days':
        return _d60to90Bg;
      case '90+ Days':
        return _safeBg;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _bucketText(String bucket) {
    switch (bucket) {
      case 'Expired':
        return _expiredText;
      case '<30 Days':
        return _under30Text;
      case '30-60 Days':
        return _d30to60Text;
      case '60-90 Days':
        return _d60to90Text;
      case '90+ Days':
        return _safeText;
      default:
        return _textPrimary;
    }
  }

  Color _bucketBadge(String bucket) {
    switch (bucket) {
      case 'Expired':
        return _expiredBadge;
      case '<30 Days':
        return _under30Badge;
      case '30-60 Days':
        return _d30to60Badge;
      case '60-90 Days':
        return _d60to90Badge;
      case '90+ Days':
        return _safeBadge;
      default:
        return Colors.grey;
    }
  }

  IconData _bucketIcon(String bucket) {
    switch (bucket) {
      case 'Expired':
        return Icons.dangerous;
      case '<30 Days':
        return Icons.warning_amber_rounded;
      case '30-60 Days':
        return Icons.schedule;
      case '60-90 Days':
        return Icons.info_outline;
      case '90+ Days':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PDF EXPORT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _generatePdfReport(List<ExpiryBatch> batches) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5);
    final counts = _getBucketCounts(batches);

    final tableHeaders = [
      'Product',
      'Batch #',
      'Expiry Date',
      'Days Left',
      'Qty',
      'Facility',
      'Status'
    ];
    final tableData = batches.map((b) {
      return [
        b.productName,
        b.batchNumber,
        '${b.expiryDate.day}/${b.expiryDate.month}/${b.expiryDate.year}',
        b.daysLeft.toString(),
        b.quantity.toString(),
        b.facility,
        b.statusLabel,
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Expiry Tracking Report',
                style:
                    pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
                'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('Expired: ${counts['expired']}',
                      style:
                          pw.TextStyle(fontSize: 9, color: PdfColors.red900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('<30d: ${counts['under30']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.orange900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('30-60d: ${counts['d30to60']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.yellow900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('60-90d: ${counts['d60to90']}',
                      style:
                          pw.TextStyle(fontSize: 9, color: PdfColors.blue900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text('90+d: ${counts['safe']}',
                      style:
                          pw.TextStyle(fontSize: 9, color: PdfColors.green900)),
                ),
              ],
            ),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#9900FF')),
            cellStyle: pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: pw.FixedColumnWidth(110),
              1: pw.FixedColumnWidth(80),
              2: pw.FixedColumnWidth(70),
              3: pw.FixedColumnWidth(60),
              4: pw.FixedColumnWidth(40),
              5: pw.FixedColumnWidth(90),
              6: pw.FixedColumnWidth(70),
            },
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await save(
      bytes: Uint8List.fromList(bytes),
      fileName:
          'expiry_tracking_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      mimeType: 'application/pdf',
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
      title: 'Expiry Tracking Dashboard',
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

                              // Render an explicit access state immediately instead of
                              // leaving the dashboard region blank while the user stream
                              // refreshes after navigation.
                              if (currentUserDocument == null)
                                _buildLoadingState()
                              else if (!AccessControl.hasPermission(
                                  context, Permission.expiryTrackingView))
                                _buildNoAccessState()
                              else
                                _buildDashboardContent(context),
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
                      color: _pulsePurpleLight,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(Icons.timer_off_outlined,
                        color: _pulsePurple, size: 24.0),
                  ),
                  const SizedBox(width: 14.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expiry Tracking Dashboard',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.02,
                          height: 1.2,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Visual timeline of expiring batches — 30 / 60 / 90 day outlook',
                        style: TextStyle(
                          fontFamily: kAppFontFamily,
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
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD CONTENT (post-RBAC check)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDashboardContent(BuildContext context) {
    final allBatches = _mockBatches;
    final counts = _getBucketCounts(allBatches);

    // Apply search filter
    final searchQuery = _model.searchTextController?.text.toLowerCase() ?? '';
    List<ExpiryBatch> filteredBatches = allBatches.where((b) {
      if (searchQuery.isNotEmpty) {
        return b.productName.toLowerCase().contains(searchQuery) ||
            b.batchNumber.toLowerCase().contains(searchQuery) ||
            b.facility.toLowerCase().contains(searchQuery);
      }
      return true;
    }).toList();

    // Apply bucket filter
    final bucketFilter = _model.expiryBucketValue;
    if (bucketFilter != null && bucketFilter != 'All') {
      filteredBatches =
          filteredBatches.where((b) => b.statusLabel == bucketFilter).toList();
    }

    // Sort based on active sort column
    filteredBatches.sort((a, b) {
      int cmp;
      switch (_model.sortColumn) {
        case 'batch#':
          cmp = a.batchNumber.compareTo(b.batchNumber);
          break;
        case 'expirydate':
          cmp = a.expiryDate.compareTo(b.expiryDate);
          break;
        case 'daysleft':
        default:
          cmp = a.daysLeft.compareTo(b.daysLeft);
          break;
      }
      return _model.sortAscending ? cmp : -cmp;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Summary Stats Row ──
        _buildSummaryStatsRow(counts),
        const SizedBox(height: 24.0),

        // ── 2. Expiry Timeline Visual ──
        _buildExpiryTimeline(counts),
        const SizedBox(height: 24.0),

        // ── 3. Search + Filter + Export Bar ──
        _buildSearchFilterBar(context, filteredBatches),
        const SizedBox(height: 20.0),

        // ── 4. Expiring Batches Table ──
        _buildBatchesTable(context, filteredBatches),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. SUMMARY STATS ROW — 4 severity cards with animated count-up
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSummaryStatsRow(Map<String, int> counts) {
    final cards = [
      _StatCardConfig(
        title: 'Already Expired',
        count: counts['expired'] ?? 0,
        icon: Icons.dangerous,
        bg: _expiredBg,
        text: _expiredText,
        badge: _expiredBadge,
        sparkData: [2, 5, 3, 7, counts['expired'] ?? 0],
      ),
      _StatCardConfig(
        title: 'Expiring <30 Days',
        count: counts['under30'] ?? 0,
        icon: Icons.warning_amber_rounded,
        bg: _under30Bg,
        text: _under30Text,
        badge: _under30Badge,
        sparkData: [4, 2, 6, 3, counts['under30'] ?? 0],
      ),
      _StatCardConfig(
        title: 'Expiring 30-60 Days',
        count: counts['d30to60'] ?? 0,
        icon: Icons.schedule,
        bg: _d30to60Bg,
        text: _d30to60Text,
        badge: _d30to60Badge,
        sparkData: [3, 5, 2, 4, counts['d30to60'] ?? 0],
      ),
      _StatCardConfig(
        title: 'Expiring 60-90 Days',
        count: counts['d60to90'] ?? 0,
        icon: Icons.info_outline,
        bg: _d60to90Bg,
        text: _d60to90Text,
        badge: _d60to90Badge,
        sparkData: [1, 3, 4, 2, counts['d60to90'] ?? 0],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;
        const double minCardWidth = 200.0;
        final cols = (constraints.maxWidth / (minCardWidth + spacing))
            .clamp(1, 4)
            .toInt();
        final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((c) => SizedBox(
                    width: cardWidth,
                    child: _buildAnimatedStatCard(c),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildAnimatedStatCard(_StatCardConfig config) {
    return AnimatedBuilder(
      animation: _countUpAnimation,
      builder: (context, child) {
        final animatedCount = (config.count * _countUpAnimation.value).round();
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: config.bg,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: config.badge.withValues(alpha: 0.2), width: 1.5),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon + count row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: config.badge.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(config.icon, size: 20.0, color: config.badge),
                  ),
                  const Spacer(),
                  // Animated count
                  Text(
                    animatedCount.toString(),
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 32.0,
                      fontWeight: FontWeight.w800,
                      color: config.text,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              // Title
              Text(
                config.title,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: config.text,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10.0),
              // Sparkline indicator
              _buildSparkline(config.sparkData, config.badge),
            ],
          ),
        );
      },
    );
  }

  // ── Mini sparkline (5-point line chart) ──
  Widget _buildSparkline(List<int> data, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxVal == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 24.0,
      child: CustomPaint(
        painter: _SparklinePainter(data: data, color: color, maxVal: maxVal),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2. EXPIRY TIMELINE — horizontal segmented bar chart
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildExpiryTimeline(Map<String, int> counts) {
    final total = counts['total'] ?? 1;
    final segments = [
      _TimelineSegment('Expired', counts['expired'] ?? 0, _expiredBadge),
      _TimelineSegment('<30d', counts['under30'] ?? 0, _under30Badge),
      _TimelineSegment('30-60d', counts['d30to60'] ?? 0, _d30to60Badge),
      _TimelineSegment('60-90d', counts['d60to90'] ?? 0, _d60to90Badge),
      _TimelineSegment('90+d', counts['safe'] ?? 0, _safeBadge),
    ];

    return Container(
      padding: const EdgeInsets.all(24.0),
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
          // Section title
          Row(
            children: [
              Icon(Icons.timeline, color: _pulsePurple, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                'Expiry Timeline',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$total batches total',
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          // Segmented horizontal bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: SizedBox(
              height: 40.0,
              child: Row(
                children: segments.map((seg) {
                  final fraction = seg.count / total;
                  if (fraction <= 0) return const SizedBox.shrink();
                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Container(
                      color: seg.color,
                      alignment: Alignment.center,
                      child: fraction > 0.06
                          ? Text(
                              '${seg.count}',
                              style: TextStyle(
                                fontFamily: kAppFontFamily,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          // Legend row
          Wrap(
            spacing: 20.0,
            runSpacing: 8.0,
            children: segments.map((seg) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: seg.color,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    '${seg.label} (${seg.count})',
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: _textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. SEARCH + FILTER + EXPORT BAR
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSearchFilterBar(
      BuildContext context, List<ExpiryBatch> filteredBatches) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final searchField = TextField(
            controller: _model.searchTextController,
            focusNode: _model.searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search product, batch, or facility...',
              hintStyle: TextStyle(
                  fontFamily: kAppFontFamily,
                  color: _textSecondary,
                  fontSize: 14.0),
              prefixIcon: Icon(Icons.search, color: _pulsePurple, size: 20.0),
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

          final filterDropdown = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: _pulsePurpleLight,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: FlutterFlowDropDown<String>(
              controller: _model.expiryBucketValueController,
              options: const [
                'All',
                'Expired',
                '<30 Days',
                '30-60 Days',
                '60-90 Days',
                '90+ Days'
              ],
              onChanged: (val) {
                safeSetState(() => _model.expiryBucketValue = val);
              },
              width: 160.0,
              height: 40.0,
              textStyle: TextStyle(
                fontFamily: kAppFontFamily,
                color: _pulsePurple,
                fontWeight: FontWeight.w500,
                fontSize: 13.0,
              ),
              icon: Icon(Icons.filter_list, color: _pulsePurple, size: 18.0),
              fillColor: Colors.transparent,
              elevation: 0,
              borderColor: Colors.transparent,
              borderWidth: 0.0,
              borderRadius: 10.0,
              margin: EdgeInsets.zero,
            ),
          );

          // Export button (RBAC-gated)
          final exportButton = AccessControl.hasPermission(
                  context, Permission.expiryTrackingExport)
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _generatePdfReport(filteredBatches),
                    icon: const Icon(Icons.picture_as_pdf, size: 18.0),
                    label: const Text('Export Report'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _surfaceColor,
                      side: BorderSide(color: _borderColor, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                  ),
                )
              : const SizedBox.shrink();

          if (isCompact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                searchField,
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    filterDropdown,
                    const Spacer(),
                    exportButton,
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 12.0),
              filterDropdown,
              exportButton,
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. EXPIRING BATCHES TABLE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBatchesTable(
      BuildContext context, List<ExpiryBatch> filteredBatches) {
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
          // Table header bar
          Container(
            padding: const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 18.0),
            decoration: BoxDecoration(
              color: _pulsePurple.withValues(alpha: 0.06),
              border: Border(
                bottom: BorderSide(color: _borderColor, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                _tableHeaderCell('Product Name', 1.5),
                _sortableHeaderCell('Batch #', 1.0),
                _sortableHeaderCell('Expiry Date', 1.0),
                _sortableHeaderCell('Days Left', 0.8),
                _tableHeaderCell('Quantity', 0.6),
                _tableHeaderCell('Status', 0.9),
                _tableHeaderCell('Actions', 1.2),
              ],
            ),
          ),
          // Table rows or empty state
          if (filteredBatches.isEmpty)
            _buildEmptyState()
          else
            ...filteredBatches.map((batch) => _buildBatchRow(context, batch)),
        ],
      ),
    );
  }

  Widget _buildBatchRow(BuildContext context, ExpiryBatch batch) {
    final status = batch.statusLabel;
    final rowBg = _bucketBg(status);
    final textColor = _bucketText(status);
    final badgeColor = _bucketBadge(status);
    final icon = _bucketIcon(status);
    final daysLeft = batch.daysLeft;

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
      decoration: BoxDecoration(
        color: rowBg.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
              color: _borderColor.withValues(alpha: 0.5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Product Name
          Expanded(
            flex: 15,
            child: Row(
              children: [
                Icon(icon, size: 16.0, color: badgeColor),
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    batch.productName,
                    style: TextStyle(
                      fontFamily: kAppFontFamily,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Batch #
          Expanded(
            flex: 10,
            child: Text(
              batch.batchNumber,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          // Expiry Date
          Expanded(
            flex: 10,
            child: Text(
              '${batch.expiryDate.day}/${batch.expiryDate.month}/${batch.expiryDate.year}',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13.0,
                color: textColor,
              ),
            ),
          ),
          // Days Left
          Expanded(
            flex: 8,
            child: Text(
              daysLeft < 0 ? '${daysLeft.abs()}d ago' : '${daysLeft}d',
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          // Quantity
          Expanded(
            flex: 6,
            child: Text(
              batch.quantity.toString(),
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          // Status badge
          Expanded(
            flex: 9,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(9999.0),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Action buttons
          Expanded(
            flex: 12,
            child: Row(
              children: [
                // Mark as Disposed
                _actionChip(
                  label: 'Disposed',
                  icon: Icons.delete_forever_outlined,
                  bgColor: _expiredBg,
                  fgColor: _expiredBadge,
                  onTap: () => _showActionDialog(
                    context,
                    batch,
                    'Mark as Disposed',
                    'Are you sure you want to mark ${batch.productName} (${batch.batchNumber}) as disposed? This will remove it from active inventory.',
                  ),
                ),
                const SizedBox(width: 6.0),
                // Return to Supplier
                _actionChip(
                  label: 'Return',
                  icon: Icons.assignment_return_outlined,
                  bgColor: _d60to90Bg,
                  fgColor: _d60to90Badge,
                  onTap: () => _showActionDialog(
                    context,
                    batch,
                    'Return to Supplier',
                    'Initiate a return request for ${batch.productName} (${batch.batchNumber}) to the supplier? Quantity: ${batch.quantity} units.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: fgColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: fgColor),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(
    BuildContext context,
    ExpiryBatch batch,
    String actionTitle,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _pulsePurpleLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: _pulsePurple, size: 22.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                actionTitle,
                style: TextStyle(
                  fontFamily: kAppFontFamily,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 14.0,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: _pulsePurpleLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _pulsePurple, size: 16.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'This action will be logged in the audit trail.',
                      style: TextStyle(
                        fontFamily: kAppFontFamily,
                        fontSize: 12.0,
                        color: _pulsePurpleDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$actionTitle for ${batch.batchNumber} — recorded.',
                    style: TextStyle(fontFamily: kAppFontFamily),
                  ),
                  backgroundColor: _pulsePurple,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _pulsePurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: Text('Confirm',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0)),
          ),
        ],
      ),
    );
  }

  // ── Sortable header cell ──
  Widget _sortableHeaderCell(String text, double flex) {
    final isActive =
        _model.sortColumn == text.toLowerCase().replaceAll(' ', '');
    return Expanded(
      flex: (flex * 10).round(),
      child: InkWell(
        onTap: () {
          safeSetState(() {
            final colKey = text.toLowerCase().replaceAll(' ', '');
            if (_model.sortColumn == colKey) {
              _model.sortAscending = !_model.sortAscending;
            } else {
              _model.sortColumn = colKey;
              _model.sortAscending = true;
            }
          });
        },
        borderRadius: BorderRadius.circular(4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: kAppFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.08,
                color: isActive ? _pulsePurple : _pulsePurpleDark,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4.0),
              Icon(
                _model.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 14.0,
                color: _pulsePurple,
              ),
            ],
          ],
        ),
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
          color: _pulsePurpleDark,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATES: Empty, Loading, Error, No-Access
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(60.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.timer_off_outlined,
                size: 56.0, color: _textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 16.0),
            Text('No expiring batches found',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary)),
            const SizedBox(height: 8.0),
            Text('All inventory is within safe expiry windows.',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 13.0,
                    color: _textSecondary.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitRing(color: _pulsePurple, size: 48.0),
            const SizedBox(height: 16.0),
            Text('Loading expiry data...',
                style: TextStyle(
                    fontFamily: kAppFontFamily,
                    fontSize: 14.0,
                    color: _textSecondary)),
          ],
        ),
      ),
    );
  }

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
                'You don\'t have permission to view expiry tracking.\nContact your administrator for access.',
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
}

// ═══════════════════════════════════════════════════════════════════════
// HELPER CLASSES
// ═══════════════════════════════════════════════════════════════════════

class _StatCardConfig {
  final String title;
  final int count;
  final IconData icon;
  final Color bg;
  final Color text;
  final Color badge;
  final List<int> sparkData;

  _StatCardConfig({
    required this.title,
    required this.count,
    required this.icon,
    required this.bg,
    required this.text,
    required this.badge,
    required this.sparkData,
  });
}

class _TimelineSegment {
  final String label;
  final int count;
  final Color color;

  _TimelineSegment(this.label, this.count, this.color);
}

// ═══════════════════════════════════════════════════════════════════════
// SPARKLINE PAINTER — custom mini line chart
// ═══════════════════════════════════════════════════════════════════════

class _SparklinePainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final double maxVal;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final stepX = size.width / (data.length - 1);
    final padding = 4.0;
    final usableHeight = size.height - padding * 2;

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - padding - (data[i] / maxVal) * usableHeight;
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      // Smooth curve
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, paint);

    // Dot on last point
    canvas.drawCircle(points.last, 3.0, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      data != old.data || color != old.color || maxVal != old.maxVal;
}
