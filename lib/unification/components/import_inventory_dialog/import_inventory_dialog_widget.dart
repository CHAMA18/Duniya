import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'import_inventory_dialog_model.dart';
export 'import_inventory_dialog_model.dart';

/// A world-class multi-step import dialog.
/// Steps: Upload → Preview & Validate → Importing → Summary
class ImportInventoryDialogWidget extends StatefulWidget {
  const ImportInventoryDialogWidget({
    super.key,
    required this.onComplete,
  });

  /// Called with the number of successfully imported rows.
  final void Function(int importedCount) onComplete;

  @override
  State<ImportInventoryDialogWidget> createState() =>
      _ImportInventoryDialogWidgetState();
}

class _ImportInventoryDialogWidgetState
    extends State<ImportInventoryDialogWidget> {
  late ImportInventoryDialogModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImportInventoryDialogModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Get the parent ref (Owner → self, Staff → ownerRef)
  DocumentReference? _getParentRef() {
    final role = valueOrDefault(currentUserDocument?.role, '');
    if (role == 'Owner') {
      return currentUserReference;
    }
    return currentUserDocument?.ownerRef;
  }

  Future<void> _pickAndParseFile() async {
    safeSetState(() => _model.isParsing = true);
    try {
      final result = await parseInventorySpreadsheet();
      if (result == null) {
        // User cancelled the picker
        if (mounted) safeSetState(() => _model.isParsing = false);
        return;
      }
      if (!result.success) {
        if (mounted) {
          safeSetState(() {
            _model.isParsing = false;
          });
          _showInlineError(result.errorMessage ?? 'Failed to parse file.');
        }
        return;
      }
      if (result.rows.isEmpty) {
        if (mounted) {
          safeSetState(() => _model.isParsing = false);
          _showInlineError(
              'The spreadsheet has no data rows. Please add at least one row below the header.');
        }
        return;
      }
      if (mounted) {
        safeSetState(() {
          _model.parseResult = result;
          _model.isParsing = false;
          _model.currentStep = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        safeSetState(() => _model.isParsing = false);
        _showInlineError('Unexpected error: ${e.toString()}');
      }
    }
  }

  void _showInlineError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Future<void> _runImport() async {
    final result = _model.parseResult as SpreadsheetParseResult;
    final parentRef = _getParentRef();
    if (parentRef == null) {
      _showInlineError('Could not determine your pharmacy. Please re-login.');
      return;
    }

    final validRows =
        result.rows.where((r) => r.isValid).cast<ParsedInventoryRow>().toList();
    _model.totalCount = validRows.length;
    _model.importedCount = 0;
    _model.failedCount = 0;
    _model.importErrors.clear();
    _model.importProgress = 0.0;

    safeSetState(() {
      _model.currentStep = 2;
      _model.isImporting = true;
    });

    // Use a WriteBatch for performance — Firestore batches support up to 500 ops.
    // We chunk into groups of 400 to stay safely under the limit.
    const chunkSize = 400;
    for (var i = 0; i < validRows.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, validRows.length);
      final chunk = validRows.sublist(i, end);
      final batch = FirebaseFirestore.instance.batch();

      for (final row in chunk) {
        final docRef = StockRecord.createDoc(parentRef);
        final data = createStockRecordData(
          name: row.name,
          category: row.category,
          manufacturer: row.manufacturer,
          quantity: row.quantity ?? 0,
          price: row.price ?? 0.0,
          costOfGoods: row.costOfGoods ?? 0.0,
          batchNumber: row.batchNumber,
          expiryDate: row.expiryDate,
          limitNotice: row.limitNotice ?? 0,
          initialQuantity: (row.quantity ?? 0).toDouble().toDouble(),
          userId: currentUserReference,
        );
        batch.set(docRef, data);
      }

      try {
        await batch.commit();
        _model.importedCount += chunk.length;
      } catch (e) {
        // Fallback: try one-by-one so we can attribute failures to specific rows
        for (var j = 0; j < chunk.length; j++) {
          final row = chunk[j];
          final rowIdx = i + j;
          try {
            final docRef = StockRecord.createDoc(parentRef);
            await docRef.set(createStockRecordData(
              name: row.name,
              category: row.category,
              manufacturer: row.manufacturer,
              quantity: row.quantity ?? 0,
              price: row.price ?? 0.0,
              costOfGoods: row.costOfGoods ?? 0.0,
              batchNumber: row.batchNumber,
              expiryDate: row.expiryDate,
              limitNotice: row.limitNotice ?? 0,
              initialQuantity: (row.quantity ?? 0).toDouble().toDouble(),
              userId: currentUserReference,
            ));
            _model.importedCount++;
          } catch (rowErr) {
            _model.failedCount++;
            _model.importErrors[rowIdx] = rowErr.toString();
          }
        }
      }

      _model.importProgress = (_model.importedCount + _model.failedCount) /
          _model.totalCount.clamp(1, 999999);
      if (mounted) safeSetState(() {});
    }

    if (mounted) {
      safeSetState(() {
        _model.isImporting = false;
        _model.currentStep = 3;
      });
    }
  }

  void _reset() {
    safeSetState(() {
      _model.currentStep = 0;
      _model.parseResult = null;
      _model.isParsing = false;
      _model.isImporting = false;
      _model.importProgress = 0.0;
      _model.importedCount = 0;
      _model.failedCount = 0;
      _model.totalCount = 0;
      _model.importErrors.clear();
      _model.previewAccepted = false;
    });
  }

  void _close() {
    widget.onComplete(_model.importedCount);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryBlue = theme.primary;
    final primaryContainer = theme.primary.withValues(alpha: 0.08);
    final surfaceBg = theme.secondaryBackground;
    final onSurface = theme.primaryText;
    final onSurfaceVariant =
        isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);
    final outline = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final surfaceContainerLow =
        isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final surfaceContainerHighest =
        isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 40.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 920,
          maxHeight: 820,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceBg,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(onSurface, onSurfaceVariant, outline),
                Expanded(
                  child: switch (_model.currentStep) {
                    0 => _buildUploadStep(
                        primaryBlue,
                        primaryContainer,
                        onSurface,
                        onSurfaceVariant,
                        outline,
                        surfaceContainerLow,
                      ),
                    1 => _buildPreviewStep(
                        primaryBlue,
                        primaryContainer,
                        onSurface,
                        onSurfaceVariant,
                        outline,
                        surfaceContainerLow,
                        surfaceContainerHighest,
                      ),
                    2 => _buildImportingStep(
                        primaryBlue,
                        primaryContainer,
                        onSurface,
                        onSurfaceVariant,
                      ),
                    _ => _buildSummaryStep(
                        primaryBlue,
                        primaryContainer,
                        onSurface,
                        onSurfaceVariant,
                        outline,
                        surfaceContainerLow,
                      ),
                  },
                ),
                _buildFooter(
                  primaryBlue,
                  onSurface,
                  onSurfaceVariant,
                  outline,
                  surfaceContainerLow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _buildHeader(
      Color onSurface, Color onSurfaceVariant, Color outline) {
    final stepTitles = ['Upload File', 'Preview & Validate', 'Importing', 'Summary'];
    final title = stepTitles[_model.currentStep.clamp(0, 3)];
    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFA100FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  color: Color(0xFFA100FF),
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Inventory',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: onSurfaceVariant, size: 20.0),
                splashRadius: 18.0,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildStepIndicator(onSurface, onSurfaceVariant, outline),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
      Color onSurface, Color onSurfaceVariant, Color outline) {
    final steps = ['Upload', 'Preview', 'Import', 'Done'];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _buildStepDot(i, steps[i], onSurface, onSurfaceVariant, outline),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: i < _model.currentStep
                      ? const Color(0xFFA100FF)
                      : outline,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildStepDot(
    int index,
    String label,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
  ) {
    final isDone = index < _model.currentStep;
    final isCurrent = index == _model.currentStep;
    final color = isDone || isCurrent
        ? const Color(0xFFA100FF)
        : outline;
    final bgColor = isDone || isCurrent
        ? const Color(0xFFA100FF)
        : (outline.withValues(alpha: 0.3));
    final textColor = isDone || isCurrent ? Colors.white : onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isCurrent ? onSurface : onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ===== STEP 0: UPLOAD =====
  Widget _buildUploadStep(
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color surfaceContainerLow,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big drop area
          InkWell(
            onTap: _model.isParsing ? null : _pickAndParseFile,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 32.0, vertical: 48.0),
              decoration: BoxDecoration(
                color: surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color(0xFFA100FF).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA100FF).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: _model.isParsing
                        ? const SpinKitRing(
                            color: Color(0xFFA100FF),
                            size: 28.0,
                            lineWidth: 3.0,
                          )
                        : const Icon(
                            Icons.cloud_upload_outlined,
                            color: Color(0xFFA100FF),
                            size: 30.0,
                          ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    _model.isParsing
                        ? 'Parsing your spreadsheet...'
                        : 'Drop your spreadsheet here, or click to browse',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Supports .xlsx, .xls, and .csv up to 10 MB',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Quick info cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.table_chart_outlined,
                  title: 'Required Columns',
                  body:
                      'At minimum include a "Name" column. Optional columns are auto-detected.',
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  outline: outline,
                  surfaceContainerLow: surfaceContainerLow,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.download_outlined,
                  title: 'Need a Template?',
                  body:
                      'Download a pre-formatted Excel template with example rows and instructions.',
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                  outline: outline,
                  surfaceContainerLow: surfaceContainerLow,
                  actionLabel: 'Download template',
                  onAction: () => downloadInventoryTemplate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Supported fields list
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt_outlined,
                        color: onSurface, size: 18.0),
                    const SizedBox(width: 8.0),
                    Text(
                      'Recognized Column Headers',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: [
                    _fieldChip('Name', required: true),
                    _fieldChip('Category'),
                    _fieldChip('Manufacturer'),
                    _fieldChip('Quantity'),
                    _fieldChip('Price'),
                    _fieldChip('CostOfGoods'),
                    _fieldChip('BatchNumber'),
                    _fieldChip('ExpiryDate'),
                    _fieldChip('LimitNotice'),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Aliases are accepted — e.g. "Qty" → Quantity, "Unit Price" → Price, "Expiry" → ExpiryDate.',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12.0,
                    color: onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldChip(String label, {bool required = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: required
            ? const Color(0xFFA100FF).withValues(alpha: 0.10)
            : const Color(0xFFF3F4F6).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: required
              ? const Color(0xFFA100FF).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: required
                  ? const Color(0xFF6A00D9)
                  : const Color(0xFF374151),
            ),
          ),
          if (required) ...[
            const SizedBox(width: 6.0),
            const Text(
              '· required',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A00D9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String body,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color surfaceContainerLow,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: onSurface, size: 18.0),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            body,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12.0,
              color: onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10.0),
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(4.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA100FF),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFA100FF),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== STEP 1: PREVIEW =====
  Widget _buildPreviewStep(
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color surfaceContainerLow,
    Color surfaceContainerHighest,
  ) {
    final result = _model.parseResult as SpreadsheetParseResult;
    final validCount = result.validCount;
    final invalidCount = result.invalidCount;
    final hasErrors = invalidCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.fromLTRB(28.0, 20.0, 28.0, 16.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: outline)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatPill(
                  label: 'File',
                  value: result.fileName ?? 'spreadsheet.xlsx',
                  icon: Icons.description_outlined,
                  color: onSurfaceVariant,
                  onSurface: onSurface,
                ),
              ),
              const SizedBox(width: 12.0),
              _buildStatPill(
                label: 'Valid',
                value: '$validCount rows',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF059669),
                onSurface: onSurface,
              ),
              const SizedBox(width: 12.0),
              if (hasErrors)
                _buildStatPill(
                  label: 'Issues',
                  value: '$invalidCount rows',
                  icon: Icons.error_outline,
                  color: const Color(0xFFDC2626),
                  onSurface: onSurface,
                ),
            ],
          ),
        ),

        // Warning banner if errors
        if (hasErrors)
          Container(
            margin: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 0),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFD97706), size: 20.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    '$invalidCount row(s) have issues and will be skipped. Only valid rows will be imported.',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12.5,
                      color: onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Table preview
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28.0, 20.0, 28.0, 20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: outline),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 120,
                  ),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(surfaceContainerHighest),
                    dataRowMinHeight: 44,
                    dataRowMaxHeight: 60,
                    columnSpacing: 18,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(
                        label: Text('#',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Status',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Name',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Category',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Qty',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Price',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Batch',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Expiry',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      DataColumn(
                        label: Text('Notes',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < result.rows.length; i++)
                        _buildPreviewRow(i + 1, result.rows[i], onSurface,
                            onSurfaceVariant, outline),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildPreviewRow(
    int rowNum,
    ParsedInventoryRow row,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
  ) {
    final status = row.isValid;
    return DataRow(
      color: WidgetStateProperty.all(
          row.isValid ? Colors.transparent : const Color(0xFFFEF2F2).withValues(alpha: 0.4)),
      cells: [
        DataCell(Text(
          '$rowNum',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        )),
        DataCell(Row(
          children: [
            Icon(
              status ? Icons.check_circle : Icons.cancel,
              color: status ? const Color(0xFF059669) : const Color(0xFFDC2626),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              status ? 'OK' : 'Skip',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: status
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
            ),
          ],
        )),
        DataCell(Text(
          row.name ?? '—',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurface,
          ),
        )),
        DataCell(Text(
          row.category ?? '—',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        )),
        DataCell(Text(
          '${row.quantity ?? 0}',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurface,
          ),
        )),
        DataCell(Text(
          row.price != null ? 'ZMK ${row.price!.toStringAsFixed(2)}' : '—',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurface,
          ),
        )),
        DataCell(Text(
          row.batchNumber ?? '—',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        )),
        DataCell(Text(
          row.expiryDate != null
              ? '${row.expiryDate!.year}-${row.expiryDate!.month.toString().padLeft(2, '0')}-${row.expiryDate!.day.toString().padLeft(2, '0')}'
              : '—',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: onSurfaceVariant,
          ),
        )),
        DataCell(Text(
          row.errorReason ?? '',
          style: TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: const Color(0xFFDC2626),
            fontStyle: FontStyle.italic,
          ),
        )),
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color onSurface,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  color: onSurface.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== STEP 2: IMPORTING =====
  Widget _buildImportingStep(
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    final percent = (_model.importProgress * 100).clamp(0, 100).toInt();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated progress ring
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _model.importProgress,
                      strokeWidth: 8.0,
                      backgroundColor:
                          const Color(0xFFA100FF).withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Color(0xFFA100FF)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_model.importedCount + _model.failedCount} / ${_model.totalCount}',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 11,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Importing inventory items...',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Writing ${_model.totalCount} item${_model.totalCount == 1 ? '' : 's'} to your pharmacy inventory. Please keep this window open.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (_model.failedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFD97706), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${_model.failedCount} failed · continuing',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: onSurface,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 3: SUMMARY =====
  Widget _buildSummaryStep(
    Color primaryBlue,
    Color primaryContainer,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color surfaceContainerLow,
  ) {
    final result = _model.parseResult as SpreadsheetParseResult;
    final success = _model.failedCount == 0;
    final partial = _model.failedCount > 0 && _model.importedCount > 0;

    final IconData icon;
    final Color iconColor;
    final String title;
    final String subtitle;

    if (success) {
      icon = Icons.check_circle_rounded;
      iconColor = const Color(0xFF059669);
      title = 'Import complete';
      subtitle =
          'All ${_model.importedCount} item${_model.importedCount == 1 ? '' : 's'} were added to your inventory.';
    } else if (partial) {
      icon = Icons.warning_amber_rounded;
      iconColor = const Color(0xFFD97706);
      title = 'Import completed with issues';
      subtitle =
          '${_model.importedCount} item${_model.importedCount == 1 ? '' : 's'} imported successfully. ${_model.failedCount} failed.';
    } else {
      icon = Icons.cancel_rounded;
      iconColor = const Color(0xFFDC2626);
      title = 'Import failed';
      subtitle =
          'None of the ${result.totalCount} rows could be imported. Please check your data and try again.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              color: onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          // Stat row
          Row(
            children: [
              Expanded(
                child: _buildSummaryStat(
                  label: 'Total rows',
                  value: '${result.totalCount}',
                  color: onSurfaceVariant,
                  onSurface: onSurface,
                  outline: outline,
                  surfaceContainerLow: surfaceContainerLow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  label: 'Imported',
                  value: '${_model.importedCount}',
                  color: const Color(0xFF059669),
                  onSurface: onSurface,
                  outline: outline,
                  surfaceContainerLow: surfaceContainerLow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryStat(
                  label: 'Failed',
                  value: '${_model.failedCount}',
                  color: _model.failedCount > 0
                      ? const Color(0xFFDC2626)
                      : onSurfaceVariant,
                  onSurface: onSurface,
                  outline: outline,
                  surfaceContainerLow: surfaceContainerLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_model.importErrors.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFDC2626), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Error details',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._model.importErrors.entries.take(8).map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Row ${e.key + 1}: ${e.value}',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ),
                  if (_model.importErrors.length > 8)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '...and ${_model.importErrors.length - 8} more',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required Color color,
    required Color onSurface,
    required Color outline,
    required Color surfaceContainerLow,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: outline),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              color: onSurface.withValues(alpha: 0.7),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ===== FOOTER =====
  Widget _buildFooter(
    Color primaryBlue,
    Color onSurface,
    Color onSurfaceVariant,
    Color outline,
    Color surfaceContainerLow,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28.0, 16.0, 28.0, 20.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: outline)),
        color: surfaceContainerLow.withValues(alpha: 0.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side — context actions
              if (_model.currentStep == 0)
                Text(
                  'Step 1 of 4 · Choose a file to begin',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: onSurfaceVariant,
                  ),
                )
              else if (_model.currentStep == 1)
                InkWell(
                  onTap: _reset,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back,
                          size: 16, color: onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        'Choose different file',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_model.currentStep == 3)
                InkWell(
                  onTap: _reset,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh,
                          size: 16, color: Color(0xFFA100FF)),
                      const SizedBox(width: 6),
                      const Text(
                        'Import another file',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA100FF),
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),

              // Right side — primary action
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_model.currentStep == 0 || _model.currentStep == 1) ...[
                    if (!isCompact)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (!isCompact) const SizedBox(width: 8),
                    if (_model.currentStep == 1)
                      _primaryButton(
                        label: 'Import ${(_model.parseResult as SpreadsheetParseResult).validCount} item${(_model.parseResult as SpreadsheetParseResult).validCount == 1 ? '' : 's'}',
                        icon: Icons.cloud_upload_outlined,
                        onPressed: (_model.parseResult
                                    as SpreadsheetParseResult)
                                .validCount >
                            0
                            ? _runImport
                            : null,
                      ),
                  ] else if (_model.currentStep == 2) ...[
                    _primaryButton(
                      label: 'Please wait...',
                      icon: Icons.hourglass_top,
                      onPressed: null,
                    ),
                  ] else if (_model.currentStep == 3) ...[
                    _primaryButton(
                      label: 'Done',
                      icon: Icons.check,
                      onPressed: _close,
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    return Material(
      color: isDisabled
          ? const Color(0xFFA100FF).withValues(alpha: 0.35)
          : const Color(0xFFA100FF),
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onPressed,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 11.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
