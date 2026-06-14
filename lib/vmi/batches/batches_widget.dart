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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:typed_data';
import 'batches_model.dart';
export 'batches_model.dart';

class BatchesWidget extends StatefulWidget {
  const BatchesWidget({super.key});

  static String routeName = 'Batches';
  static String routePath = '/batches';

  @override
  State<BatchesWidget> createState() => _BatchesWidgetState();
}

class _BatchesWidgetState extends State<BatchesWidget> {
  late BatchesModel _model;

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

  // Expiry alert colors
  static const Color _expiredBg = Color(0xFFFEE2E2);
  static const Color _expiredText = Color(0xFF991B1B);
  static const Color _expiredBadge = Color(0xFFDC2626);
  static const Color _threeMoBg = Color(0xFFFFEDD5);
  static const Color _threeMoText = Color(0xFF9A3412);
  static const Color _threeMoBadge = Color(0xFFEA580C);
  static const Color _sixMoBg = Color(0xFFFEF9C3);
  static const Color _sixMoText = Color(0xFF854D0E);
  static const Color _sixMoBadge = Color(0xFFCA8A04);
  static const Color _safeBg = Color(0xFFD1FAE5);
  static const Color _safeText = Color(0xFF065F46);
  static const Color _safeBadge = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BatchesModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Batches'});
    _model.searchTextController ??= TextEditingController();
    _model.searchFocusNode ??= FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Expiry classification ──
  String _getExpiryStatus(DateTime? expiryDate) {
    if (expiryDate == null) return 'Unknown';
    final now = DateTime.now();
    final diff = expiryDate.difference(now).inDays;
    if (diff < 0) return 'Expired';
    if (diff < 90) return '< 3 Months';
    if (diff < 180) return '< 6 Months';
    return 'Safe';
  }

  Color _getExpiryRowBg(DateTime? expiryDate) {
    if (expiryDate == null) return Color(0xFFF3F4F6);
    final diff = expiryDate.difference(DateTime.now()).inDays;
    if (diff < 0) return _expiredBg;
    if (diff < 90) return _threeMoBg;
    if (diff < 180) return _sixMoBg;
    return Colors.transparent;
  }

  Color _getExpiryTextColor(DateTime? expiryDate) {
    if (expiryDate == null) return _textPrimary;
    final diff = expiryDate.difference(DateTime.now()).inDays;
    if (diff < 0) return _expiredText;
    if (diff < 90) return _threeMoText;
    if (diff < 180) return _sixMoText;
    return _safeText;
  }

  Color _getExpiryBadgeBg(DateTime? expiryDate) {
    if (expiryDate == null) return Color(0xFFE5E7EB);
    final diff = expiryDate.difference(DateTime.now()).inDays;
    if (diff < 0) return _expiredBadge;
    if (diff < 90) return _threeMoBadge;
    if (diff < 180) return _sixMoBadge;
    return _safeBadge;
  }

  Color _getExpiryBadgeText(DateTime? expiryDate) {
    if (expiryDate == null) return _textSecondary;
    return Colors.white;
  }

  IconData _getExpiryIcon(DateTime? expiryDate) {
    if (expiryDate == null) return Icons.help_outline;
    final diff = expiryDate.difference(DateTime.now()).inDays;
    if (diff < 0) return Icons.dangerous;
    if (diff < 90) return Icons.warning_amber_rounded;
    if (diff < 180) return Icons.schedule;
    return Icons.check_circle;
  }

  // ── Alert counts ──
  Map<String, int> _getAlertCounts(List<BatchRecord> batches) {
    int expired = 0;
    int threeMo = 0;
    int sixMo = 0;
    for (final b in batches) {
      final status = _getExpiryStatus(b.expiryDate);
      if (status == 'Expired') expired++;
      if (status == '< 3 Months') threeMo++;
      if (status == '< 6 Months') sixMo++;
    }
    return {
      'expired': expired,
      'threeMo': threeMo,
      'sixMo': sixMo,
      'total': batches.length,
    };
  }

  // ── PDF Report Generation ──
  Future<void> _generatePdfReport(List<BatchRecord> batches) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5);

    final alertCounts = _getAlertCounts(batches);

    // Pre-compute table data
    final tableHeaders = [
      'Batch #',
      'Product',
      'Expiry Date',
      'Qty',
      'Facility',
      'Status'
    ];
    final tableData = batches.map((b) {
      final status = _getExpiryStatus(b.expiryDate);
      return [
        b.batchNumber,
        b.hasProductId() ? b.productId!.id.substring(0, 8) : '-',
        b.expiryDate != null
            ? '${b.expiryDate!.day}/${b.expiryDate!.month}/${b.expiryDate!.year}'
            : '-',
        b.quantity.toString(),
        b.facilityLocation ?? '-',
        status,
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Batch & Expiry Tracking Report',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(
                'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Container(
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                      'Expired: ${alertCounts['expired']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.red900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                      '< 3 Mo: ${alertCounts['threeMo']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.orange900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                      '< 6 Mo: ${alertCounts['sixMo']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.yellow900)),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                      'Total: ${alertCounts['total']}',
                      style: pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey800)),
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
              0: pw.FixedColumnWidth(90),
              1: pw.FixedColumnWidth(90),
              2: pw.FixedColumnWidth(80),
              3: pw.FixedColumnWidth(50),
              4: pw.FixedColumnWidth(100),
              5: pw.FixedColumnWidth(70),
            },
            border: pw.TableBorder.all(
                color: PdfColors.grey300, width: 0.5),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.document.createElement('a')
      ..setAttribute('href', url)
      ..setAttribute('download',
          'batch_expiry_report_${DateTime.now().millisecondsSinceEpoch}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // ── Alert Summary Card ──
  Widget _buildAlertCard({
    required String title,
    required int count,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'Satoshi',
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
                fontFamily: 'Satoshi',
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Batch Dialog ──
  void _showAddBatchDialog(BuildContext context, DocumentReference parentRef) {
    _model.dialogBatchTextController?.clear();
    _model.dialogQtyTextController?.clear();
    _model.dialogFacilityTextController?.clear();
    _model.dialogExpiryDate = null;
    _model.dialogProductValue = null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _duniyaPurpleLight,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.add_circle, color: _duniyaPurple, size: 22.0),
              ),
              const SizedBox(width: 12.0),
              Text('Add New Batch',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
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
                  controller: _model.dialogBatchTextController,
                  decoration: InputDecoration(
                    labelText: 'Batch Number',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.tag, color: _duniyaPurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 180)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 3650)),
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
                      setDialogState(() => _model.dialogExpiryDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      prefixIcon: Icon(Icons.calendar_today, color: _duniyaPurple, size: 20.0),
                    ),
                    child: Text(
                      _model.dialogExpiryDate != null
                          ? '${_model.dialogExpiryDate!.day}/${_model.dialogExpiryDate!.month}/${_model.dialogExpiryDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: _model.dialogExpiryDate != null
                            ? _textPrimary
                            : _textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _model.dialogQtyTextController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.inventory_2, color: _duniyaPurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _model.dialogFacilityTextController,
                  decoration: InputDecoration(
                    labelText: 'Facility Location',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.location_on, color: _duniyaPurple, size: 20.0),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_model.dialogBatchTextController?.text.isEmpty ?? true) return;
                if (_model.dialogExpiryDate == null) return;

                final batchData = createBatchRecordData(
                  batchNumber: _model.dialogBatchTextController!.text,
                  expiryDate: _model.dialogExpiryDate,
                  quantity: int.tryParse(
                          _model.dialogQtyTextController?.text ?? '0') ??
                      0,
                  facilityLocation:
                      _model.dialogFacilityTextController?.text ?? '',
                  pharmacyId: parentRef,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await FirebaseFirestore.instance.collection('Batch').doc().set(batchData);

                Navigator.pop(dialogContext);
                safeSetState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _duniyaPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Add Batch',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Batch Dialog ──
  void _showEditBatchDialog(BuildContext context, BatchRecord batch) {
    _model.dialogBatchTextController?.text = batch.batchNumber;
    _model.dialogQtyTextController?.text = batch.quantity.toString();
    _model.dialogFacilityTextController?.text = batch.facilityLocation ?? '';
    _model.dialogExpiryDate = batch.expiryDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
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
              Text('Edit Batch',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
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
                  controller: _model.dialogBatchTextController,
                  decoration: InputDecoration(
                    labelText: 'Batch Number',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.tag, color: _duniyaPurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _model.dialogExpiryDate ??
                          DateTime.now().add(Duration(days: 180)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 3650)),
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
                      setDialogState(() => _model.dialogExpiryDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      prefixIcon: Icon(Icons.calendar_today, color: _duniyaPurple, size: 20.0),
                    ),
                    child: Text(
                      _model.dialogExpiryDate != null
                          ? '${_model.dialogExpiryDate!.day}/${_model.dialogExpiryDate!.month}/${_model.dialogExpiryDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        color: _model.dialogExpiryDate != null
                            ? _textPrimary
                            : _textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _model.dialogQtyTextController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.inventory_2, color: _duniyaPurple, size: 20.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _model.dialogFacilityTextController,
                  decoration: InputDecoration(
                    labelText: 'Facility Location',
                    labelStyle: TextStyle(fontFamily: 'Satoshi', color: _textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: _duniyaPurple, width: 2.0)),
                    prefixIcon: Icon(Icons.location_on, color: _duniyaPurple, size: 20.0),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      color: _textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updateData = createBatchRecordData(
                  batchNumber: _model.dialogBatchTextController?.text ?? batch.batchNumber,
                  expiryDate: _model.dialogExpiryDate ?? batch.expiryDate,
                  quantity: int.tryParse(
                          _model.dialogQtyTextController?.text ?? '0') ??
                      batch.quantity,
                  facilityLocation:
                      _model.dialogFacilityTextController?.text ?? batch.facilityLocation ?? '',
                  productId: batch.productId,
                  pharmacyId: batch.pharmacyId,
                  updatedAt: DateTime.now(),
                );
                await batch.reference.update(updateData);
                Navigator.pop(dialogContext);
                safeSetState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _duniyaPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              child: Text('Save Changes',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Confirm Dialog ──
  void _showDeleteConfirmDialog(BuildContext context, BatchRecord batch) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _expiredBg,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(Icons.delete_forever, color: _expiredBadge, size: 22.0),
            ),
            const SizedBox(width: 12.0),
            Text('Delete Batch',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                    color: _textPrimary)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete batch "${batch.batchNumber}"? This action cannot be undone.',
          style: TextStyle(
              fontFamily: 'Satoshi', fontSize: 15.0, color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    color: _textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () async {
              await batch.reference.delete();
              Navigator.pop(dialogContext);
              safeSetState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _expiredBadge,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            ),
            child: Text('Delete',
                style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return AuthUserStreamWidget(
      builder: (context) => StreamBuilder<List<BatchRecord>>(
        stream: queryBatchRecord(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: _bgColor,
              body: Center(
                child: SpinKitRing(color: _duniyaPurple, size: 48.0),
              ),
            );
          }

          List<BatchRecord> allBatches = snapshot.data!;

          // Filter by search
          final searchQuery =
              _model.searchTextController?.text.toLowerCase() ?? '';
          List<BatchRecord> filteredBatches = allBatches.where((b) {
            if (searchQuery.isNotEmpty) {
              return b.batchNumber.toLowerCase().contains(searchQuery) ||
                  (b.facilityLocation ?? '')
                      .toLowerCase()
                      .contains(searchQuery);
            }
            return true;
          }).toList();

          // Filter by expiry status
          final statusFilter = _model.expiryStatusValue;
          if (statusFilter != null && statusFilter != 'All') {
            filteredBatches = filteredBatches.where((b) {
              final status = _getExpiryStatus(b.expiryDate);
              if (statusFilter == 'Expired') return status == 'Expired';
              if (statusFilter == '< 3 Months') return status == '< 3 Months';
              if (statusFilter == '< 6 Months') return status == '< 6 Months';
              if (statusFilter == 'Safe') return status == 'Safe';
              return true;
            }).toList();
          }

          // Sort: expired first, then closest to expiry
          filteredBatches.sort((a, b) {
            if (a.expiryDate == null && b.expiryDate == null) return 0;
            if (a.expiryDate == null) return 1;
            if (b.expiryDate == null) return -1;
            return a.expiryDate!.compareTo(b.expiryDate!);
          });

          final alertCounts = _getAlertCounts(allBatches);
          final parentRef =
              valueOrDefault(currentUserDocument?.role, '') == 'Owner'
                  ? currentUserReference
                  : currentUserDocument?.ownerRef;

          return Title(
            title: 'Batch & Expiry Tracking',
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
                      // Main content
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
                            // Page content
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // ── Header ──
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Batch & Expiry Tracking',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 32.0,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.02,
                                                  height: 1.2,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Monitor batch lifecycles and expiry alerts across all facilities.',
                                                style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6,
                                                  color: _textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        Row(
                                          children: [
                                            // PDF Export
                                            OutlinedButton.icon(
                                              onPressed: () =>
                                                  _generatePdfReport(
                                                      filteredBatches),
                                              icon: Icon(Icons.picture_as_pdf,
                                                  size: 18.0),
                                              label: Text('Export PDF'),
                                              style:
                                                  OutlinedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                side: BorderSide(
                                                    color: _borderColor,
                                                    width: 1.0),
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          9999.0),
                                                ),
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 12.0),
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            // Add Batch
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _showAddBatchDialog(
                                                      context, parentRef!),
                                              icon: Icon(Icons.add, size: 18.0),
                                              label: Text('Add Batch'),
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    _duniyaPurple,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          9999.0),
                                                ),
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 12.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 28.0),

                                    // ── Alert Summary Cards ──
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        int cols = 4;
                                        if (constraints.maxWidth < 900)
                                          cols = 2;
                                        if (constraints.maxWidth < 500)
                                          cols = 1;
                                        return GridView.count(
                                          crossAxisCount: cols,
                                          crossAxisSpacing: 16.0,
                                          mainAxisSpacing: 16.0,
                                          childAspectRatio: cols == 1
                                              ? 3.0
                                              : 1.1,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            // Expired
                                            _buildAlertCard(
                                              title: 'Expired',
                                              count:
                                                  alertCounts['expired'] ?? 0,
                                              icon: Icons.dangerous,
                                              bgColor: _expiredBg,
                                              iconColor: _expiredBadge,
                                              textColor: _expiredText,
                                            ),
                                            // < 3 Months
                                            _buildAlertCard(
                                              title: 'Expiring < 3 Months',
                                              count: alertCounts['threeMo'] ??
                                                  0,
                                              icon:
                                                  Icons.warning_amber_rounded,
                                              bgColor: _threeMoBg,
                                              iconColor: _threeMoBadge,
                                              textColor: _threeMoText,
                                            ),
                                            // < 6 Months
                                            _buildAlertCard(
                                              title: 'Expiring < 6 Months',
                                              count:
                                                  alertCounts['sixMo'] ?? 0,
                                              icon: Icons.schedule,
                                              bgColor: _sixMoBg,
                                              iconColor: _sixMoBadge,
                                              textColor: _sixMoText,
                                            ),
                                            // Total Batches
                                            _buildAlertCard(
                                              title: 'Total Batches',
                                              count:
                                                  alertCounts['total'] ?? 0,
                                              icon: Icons.inventory_2_outlined,
                                              bgColor: _duniyaPurpleLight,
                                              iconColor: _duniyaPurple,
                                              textColor: _duniyaPurpleDark,
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 28.0),

                                    // ── Search + Filter Bar ──
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: _surfaceColor,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                                          // Search
                                          Expanded(
                                            child: TextField(
                                              controller:
                                                  _model.searchTextController,
                                              focusNode:
                                                  _model.searchFocusNode,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Search batches...',
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Satoshi',
                                                    color: _textSecondary,
                                                    fontSize: 14.0),
                                                prefixIcon: Icon(Icons.search,
                                                    color: _duniyaPurple,
                                                    size: 20.0),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 10.0),
                                              ),
                                              style: TextStyle(
                                                  fontFamily: 'Satoshi',
                                                  fontSize: 14.0,
                                                  color: _textPrimary),
                                              onChanged: (val) =>
                                                  safeSetState(() {}),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0),
                                          // Filter dropdown
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 12.0),
                                            decoration: BoxDecoration(
                                              color: _duniyaPurpleLight,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child:
                                                FlutterFlowDropDown<String>(
                                              controller: _model
                                                  .expiryStatusValueController,
                                              options: const [
                                                'All',
                                                'Expired',
                                                '< 3 Months',
                                                '< 6 Months',
                                                'Safe'
                                              ],
                                              onChanged: (val) {
                                                safeSetState(() =>
                                                    _model.expiryStatusValue =
                                                        val);
                                              },
                                              width: 160.0,
                                              height: 40.0,
                                              textStyle: TextStyle(
                                                fontFamily: 'Satoshi',
                                                color: _duniyaPurple,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13.0,
                                              ),
                                              icon: Icon(
                                                  Icons.filter_list,
                                                  color: _duniyaPurple,
                                                  size: 18.0),
                                              fillColor: Colors.transparent,
                                              elevation: 0,
                                              borderColor: Colors.transparent,
                                              borderWidth: 0.0,
                                              borderRadius: 10.0,
                                              margin: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20.0),

                                    // ── Batch Data Table ──
                                    Container(
                                      decoration: BoxDecoration(
                                        color: _surfaceColor,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Table header
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                24.0, 18.0, 24.0, 18.0),
                                            decoration: BoxDecoration(
                                              color: _duniyaPurple
                                                  .withValues(alpha: 0.06),
                                              border: Border(
                                                bottom: BorderSide(
                                                    color: _borderColor,
                                                    width: 1.0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                _tableHeaderCell(
                                                    'Batch #', 1.2),
                                                _tableHeaderCell(
                                                    'Expiry Date', 1.0),
                                                _tableHeaderCell(
                                                    'Quantity', 0.7),
                                                _tableHeaderCell(
                                                    'Facility', 1.3),
                                                _tableHeaderCell(
                                                    'Status', 0.9),
                                                _tableHeaderCell(
                                                    'Actions', 0.7),
                                              ],
                                            ),
                                          ),
                                          // Table rows
                                          if (filteredBatches.isEmpty)
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(60.0),
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .inventory_2_outlined,
                                                        size: 56.0,
                                                        color: _textSecondary
                                                            .withValues(
                                                                alpha: 0.4)),
                                                    const SizedBox(
                                                        height: 16.0),
                                                    Text(
                                                        'No batches found',
                                                        style: TextStyle(
                                                          fontFamily: 'Satoshi',
                                                          fontSize: 16.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _textSecondary,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            )
                                          else
                                            ...filteredBatches.map((batch) {
                                              final status = _getExpiryStatus(
                                                  batch.expiryDate);
                                              final rowBg = _getExpiryRowBg(
                                                  batch.expiryDate);
                                              return Container(
                                                padding: const EdgeInsets
                                                    .fromLTRB(
                                                    24.0, 14.0, 24.0, 14.0),
                                                decoration: BoxDecoration(
                                                  color: rowBg,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: _borderColor
                                                          .withValues(
                                                              alpha: 0.5),
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Batch #
                                                    Expanded(
                                                      flex: 12,
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              _getExpiryIcon(batch
                                                                  .expiryDate),
                                                              size: 16.0,
                                                              color: _getExpiryBadgeBg(
                                                                  batch
                                                                      .expiryDate)),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          Text(
                                                            batch.batchNumber,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Satoshi',
                                                              fontSize: 13.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: _getExpiryTextColor(
                                                                  batch
                                                                      .expiryDate),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Expiry Date
                                                    Expanded(
                                                      flex: 10,
                                                      child: Text(
                                                        batch.expiryDate !=
                                                                null
                                                            ? '${batch.expiryDate!.day}/${batch.expiryDate!.month}/${batch.expiryDate!.year}'
                                                            : '-',
                                                        style: TextStyle(
                                                          fontFamily: 'Satoshi',
                                                          fontSize: 13.0,
                                                          color: _getExpiryTextColor(
                                                              batch.expiryDate),
                                                        ),
                                                      ),
                                                    ),
                                                    // Quantity
                                                    Expanded(
                                                      flex: 7,
                                                      child: Text(
                                                        batch.quantity
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily: 'Satoshi',
                                                          fontSize: 13.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: _getExpiryTextColor(
                                                              batch.expiryDate),
                                                        ),
                                                      ),
                                                    ),
                                                    // Facility
                                                    Expanded(
                                                      flex: 13,
                                                      child: Text(
                                                        batch.facilityLocation ??
                                                            '-',
                                                        style: TextStyle(
                                                          fontFamily: 'Satoshi',
                                                          fontSize: 13.0,
                                                          color: _getExpiryTextColor(
                                                              batch.expiryDate),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    // Status badge
                                                    Expanded(
                                                      flex: 9,
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10.0,
                                                            vertical: 4.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              _getExpiryBadgeBg(
                                                                  batch
                                                                      .expiryDate),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      9999.0),
                                                        ),
                                                        child: Text(
                                                          status,
                                                          textAlign: TextAlign
                                                              .center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Satoshi',
                                                            fontSize: 11.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                            color: _getExpiryBadgeText(
                                                                batch
                                                                    .expiryDate),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Actions
                                                    Expanded(
                                                      flex: 7,
                                                      child: Row(
                                                        children: [
                                                          InkWell(
                                                            onTap: () =>
                                                                _showEditBatchDialog(
                                                                    context,
                                                                    batch),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6.0),
                                                              decoration: BoxDecoration(
                                                                  color: _duniyaPurpleLight,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          8.0)),
                                                              child: Icon(
                                                                  Icons
                                                                      .edit_outlined,
                                                                  size: 16.0,
                                                                  color:
                                                                      _duniyaPurple),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6.0),
                                                          InkWell(
                                                            onTap: () =>
                                                                _showDeleteConfirmDialog(
                                                                    context,
                                                                    batch),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6.0),
                                                              decoration: BoxDecoration(
                                                                  color:
                                                                      _expiredBg,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                              child: Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  size: 16.0,
                                                                  color:
                                                                      _expiredBadge),
                                                            ),
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
                                  updateCallback: () =>
                                      safeSetState(() {}),
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
        },
      ),
    );
  }

  Widget _tableHeaderCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).round(),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.08,
          color: _duniyaPurpleDark,
        ),
      ),
    );
  }
}
