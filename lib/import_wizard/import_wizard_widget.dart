import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/rbac/rbac.dart';
import 'csv_importer_service.dart';
import 'import_audit_record.dart';
import 'reconciliation_engine.dart';
import 'sign_off_dialog.dart';
import 'virtual_signature.dart';

/// The 4-step import wizard modal:
///   1. Upload — pick + parse the file
///   2. Preview & Reconcile — show every row with its status
///   3. Sign-off — owner virtual signature
///   4. Result — success / failure screen
///
/// Owner-only. The wizard itself does an [AccessControl.isOwner] check
/// at startup and refuses to open if the current user is not an owner.
class ImportWizard extends StatefulWidget {
  const ImportWizard({
    super.key,
    required this.config,
  });

  /// The per-collection config (rules, reference loader, writer).
  final ReconciliationConfig config;

  /// Convenience entry point — opens the wizard as a modal dialog.
  static Future<void> openDialog(
    BuildContext context, {
    required ReconciliationConfig config,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24.0),
        child: ImportWizard(config: config),
      ),
    );
  }

  @override
  State<ImportWizard> createState() => _ImportWizardState();
}

class _ImportWizardState extends State<ImportWizard> {
  _WizardStep _step = _WizardStep.upload;
  ImportedFile? _file;
  ReconciliationResult? _result;
  VirtualSignature? _signature;
  int? _writtenCount;
  String? _stepError;
  bool _busy = false;
  RowStatus? _filter; // null = all

  // Preview scroll
  final _previewScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Verify owner on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!AccessControl.isOwner(context)) {
        Navigator.of(context).pop();
        _showToast(
            'Only the pharmacy owner can import records.', isError: true);
      }
    });
  }

  @override
  void dispose() {
    _previewScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 920.0, maxHeight: 720.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 24.0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            children: [
              _buildHeader(theme),
              _buildStepper(theme),
              Expanded(
                child: _busy
                    ? _buildBusy(theme)
                    : _buildStepBody(theme),
              ),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: theme.primary,
      ),
      child: Row(
        children: [
          Icon(Icons.upload_file_rounded, color: Colors.white, size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'Import ${widget.config.displayName}',
              style: theme.titleMedium.override(
                fontFamily: theme.titleMediumFamily,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.titleMediumIsCustom,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(FlutterFlowTheme theme) {
    final steps = const [_WizardStep.upload, _WizardStep.preview,
        _WizardStep.signOff, _WizardStep.result];
    final labels = const ['Upload', 'Preview', 'Sign-off', 'Result'];
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          bottom: BorderSide(color: theme.alternate, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _stepDot(theme, i + 1, labels[i], steps[i] == _step,
                steps[i].index <= _step.index),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 1.0,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: steps[i].index < _step.index
                      ? theme.primary
                      : theme.alternate,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _stepDot(FlutterFlowTheme theme, int n, String label,
      bool active, bool done) {
    final color = active
        ? theme.primary
        : (done ? theme.primary.withAlpha(140) : theme.alternate);
    final fg = active
        ? Colors.white
        : (done ? theme.primary : theme.secondaryText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.0,
          height: 22.0,
          decoration: BoxDecoration(
            color: active ? theme.primary : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: done && !active
                ? Icon(Icons.check_rounded, size: 12.0, color: fg)
                : Text(
                    '$n',
                    style: theme.labelSmall.override(
                      fontFamily: theme.labelSmallFamily,
                      color: fg,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelSmallIsCustom,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: theme.labelMedium.override(
            fontFamily: theme.labelMediumFamily,
            color: active ? theme.primaryText : theme.secondaryText,
            fontSize: 12.0,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.labelMediumIsCustom,
          ),
        ),
      ],
    );
  }

  Widget _buildBusy(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(color: theme.primary, size: 48.0, lineWidth: 3.0),
          const SizedBox(height: 16.0),
          Text(
            _busyLabel(),
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

  String _busyLabel() {
    switch (_step) {
      case _WizardStep.upload:
        return 'Parsing file…';
      case _WizardStep.preview:
        return 'Reconciling rows…';
      case _WizardStep.signOff:
        return 'Committing records…';
      case _WizardStep.result:
        return 'Finalizing…';
    }
  }

  Widget _buildStepBody(FlutterFlowTheme theme) {
    switch (_step) {
      case _WizardStep.upload:
        return _buildUploadStep(theme);
      case _WizardStep.preview:
        return _result == null
            ? _buildUploadStep(theme)
            : _buildPreviewStep(theme);
      case _WizardStep.signOff:
        return _buildSignOffStep(theme);
      case _WizardStep.result:
        return _buildResultStep(theme);
    }
  }

  Widget _buildUploadStep(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1: Choose a file',
            style: theme.titleSmall.override(
              fontFamily: theme.titleSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.titleSmallIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Accepts .csv or .xlsx. The first row must be column headers. '
            'Smart column detection matches "Product ID", "product_id", '
            '"ProductId", etc.',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 20.0),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 32.0),
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: theme.primary.withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_upload_rounded,
                      size: 36.0, color: theme.primary),
                  const SizedBox(height: 10.0),
                  Text(
                    _file == null
                        ? 'Click to choose a file'
                        : 'Choose a different file',
                    style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                  ),
                  if (_file != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      '${_file!.fileName} • ${_file!.rowCount} rows • '
                      '${_file!.headerColumns.length} columns',
                      style: theme.labelMedium.override(
                        fontFamily: theme.labelMediumFamily,
                        color: theme.secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelMediumIsCustom,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_stepError != null) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.0),
                border:
                    Border.all(color: const Color(0xFFFCA5A5), width: 1.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16.0, color: Color(0xFFB91C1C)),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _stepError!,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: const Color(0xFFB91C1C),
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24.0),
          Text(
            'Expected columns:',
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              color: theme.secondaryText,
              fontWeight: FontWeight.w600,
              fontSize: 12.0,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: widget.config.expectedColumns
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: theme.primaryBackground,
                        borderRadius: BorderRadius.circular(999.0),
                        border:
                            Border.all(color: theme.alternate, width: 1.0),
                      ),
                      child: Text(
                        c,
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: theme.primaryText,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelSmallIsCustom,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(FlutterFlowTheme theme) {
    final result = _result!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${result.total} rows parsed',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
              ),
              _statusChip(theme, RowStatus.ok, result.okCount),
              const SizedBox(width: 6.0),
              _statusChip(theme, RowStatus.warning, result.warningCount),
              const SizedBox(width: 6.0),
              _statusChip(theme, RowStatus.error, result.errorCount),
            ],
          ),
          const SizedBox(height: 8.0),
          // Filter row
          Wrap(
            spacing: 6.0,
            children: [
              _filterChip(theme, null, 'All (${result.total})'),
              _filterChip(
                  theme, RowStatus.ok, 'OK (${result.okCount})'),
              _filterChip(theme, RowStatus.warning,
                  'Warnings (${result.warningCount})'),
              _filterChip(
                  theme, RowStatus.error, 'Errors (${result.errorCount})'),
            ],
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                borderRadius: BorderRadius.circular(8.0),
                border:
                    Border.all(color: theme.alternate, width: 1.0),
              ),
              child: _buildPreviewTable(theme, result),
            ),
          ),
          if (result.errorCount == result.total)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'All rows have errors. Resolve the file issues before '
                'continuing.',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.error,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${result.importableCount} of ${result.total} rows '
                'will be imported. Rows with errors will be skipped.',
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 12.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(FlutterFlowTheme theme, RowStatus? status, String label) {
    final active = _filter == status || (_filter == null && status == null);
    return InkWell(
      onTap: () => setState(() => _filter = status),
      borderRadius: BorderRadius.circular(999.0),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: active ? theme.primary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: active ? theme.primary : theme.alternate,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: theme.labelSmall.override(
            fontFamily: theme.labelSmallFamily,
            color: active ? Colors.white : theme.secondaryText,
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.labelSmallIsCustom,
          ),
        ),
      ),
    );
  }

  Widget _statusChip(
      FlutterFlowTheme theme, RowStatus status, int count) {
    final color = status == RowStatus.ok
        ? const Color(0xFF16A34A)
        : (status == RowStatus.warning
            ? const Color(0xFFF59E0B)
            : const Color(0xFFDC2626));
    final bg = status == RowStatus.ok
        ? const Color(0xFFDCFCE7)
        : (status == RowStatus.warning
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.0),
      ),
      child: Text(
        '${RowStatusX.label(status)}: $count',
        style: theme.labelSmall.override(
          fontFamily: theme.labelSmallFamily,
          color: color,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.labelSmallIsCustom,
        ),
      ),
    );
  }

  Widget _buildPreviewTable(FlutterFlowTheme theme, ReconciliationResult result) {
    final columns = widget.config.expectedColumns;
    final rows = result.rows.where((r) {
      if (_filter == null) return true;
      return r.status == _filter;
    }).toList();
    return Scrollbar(
      controller: _previewScroll,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _previewScroll,
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16.0,
            horizontalMargin: 12.0,
            headingRowHeight: 36.0,
            dataRowMinHeight: 36.0,
            dataRowMaxHeight: 56.0,
            columns: [
              DataColumn(
                label: Text('#',
                    style: _headerStyle(theme)),
              ),
              DataColumn(
                label: Text('Status',
                    style: _headerStyle(theme)),
              ),
              ...columns.map((c) => DataColumn(
                    label: Text(c, style: _headerStyle(theme)),
                  )),
              DataColumn(
                label: Text('Message', style: _headerStyle(theme)),
              ),
            ],
            rows: rows.map((r) {
              return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (r.status == RowStatus.error) {
                    return const Color(0xFFFFF1F1);
                  }
                  if (r.status == RowStatus.warning) {
                    return const Color(0xFFFFFBEB);
                  }
                  return null;
                }),
                cells: [
                  DataCell(Text('${r.sourceRowIndex}',
                      style: _cellStyle(theme, r))),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        r.status == RowStatus.ok
                            ? Icons.check_circle_rounded
                            : (r.status == RowStatus.warning
                                ? Icons.warning_amber_rounded
                                : Icons.error_outline_rounded),
                        size: 14.0,
                        color: r.status == RowStatus.ok
                            ? const Color(0xFF16A34A)
                            : (r.status == RowStatus.warning
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 4.0),
                      Text(RowStatusX.label(r.status),
                          style: _cellStyle(theme, r)),
                    ],
                  )),
                  ...columns.map((c) => DataCell(Text(
                      r.parsed[c] ?? '',
                      style: _cellStyle(theme, r),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1))),
                  DataCell(Text(r.message,
                      style: _cellStyle(theme, r),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  TextStyle _headerStyle(FlutterFlowTheme theme) => theme.labelSmall.override(
        fontFamily: theme.labelSmallFamily,
        color: theme.secondaryText,
        fontSize: 11.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        useGoogleFonts: !theme.labelSmallIsCustom,
      );

  TextStyle _cellStyle(FlutterFlowTheme theme, ReconciledRow row) =>
      theme.bodySmall.override(
        fontFamily: theme.bodySmallFamily,
        color: row.status == RowStatus.error
            ? const Color(0xFFB91C1C)
            : theme.primaryText,
        fontSize: 11.0,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodySmallIsCustom,
      );

  Widget _buildSignOffStep(FlutterFlowTheme theme) {
    // The sign-off step itself is the dialog from sign_off_dialog.dart.
    // Here we just show a summary and the "Open sign-off dialog" button.
    final result = _result!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Step 3: Sign-off',
            style: theme.titleSmall.override(
              fontFamily: theme.titleSmallFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.titleSmallIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Review the summary below, then open the sign-off dialog to '
            'commit. Your virtual signature (sha256 hash of your UID + '
            'name + timestamp + row count + source file) will be '
            'appended to every imported record and the ImportAudit log.',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          const SizedBox(height: 16.0),
          _summaryCard(theme, result),
          const SizedBox(height: 16.0),
          if (result.errorCount == result.total)
            Text(
              'Cannot sign off — every row has errors. Go back to the '
              'preview step and fix the file.',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.error,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(FlutterFlowTheme theme, ReconciliationResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(theme, 'Source file', _file?.fileName ?? ''),
          _summaryRow(theme, 'Total rows parsed', '${result.total}'),
          _summaryRow(
              theme, 'Will import', '${result.importableCount}'),
          _summaryRow(theme, 'OK', '${result.okCount}'),
          _summaryRow(theme, 'Warnings', '${result.warningCount}'),
          _summaryRow(theme, 'Errors (skipped)', '${result.errorCount}'),
          _summaryRow(theme, 'Target collection',
              widget.config.targetCollection),
        ],
      ),
    );
  }

  Widget _summaryRow(FlutterFlowTheme theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          Text(
            value,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep(FlutterFlowTheme theme) {
    final ok = _signature != null && _writtenCount != null && _writtenCount! > 0;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16.0),
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ok ? Icons.check_rounded : Icons.error_outline_rounded,
              size: 30.0,
              color: ok ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            ok
                ? '$_writtenCount record${_writtenCount == 1 ? '' : 's'} imported'
                : 'Import failed',
            style: theme.titleMedium.override(
              fontFamily: theme.titleMediumFamily,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.titleMediumIsCustom,
            ),
          ),
          if (_signature != null) ...[
            const SizedBox(height: 6.0),
            Text(
              _signature!.displayLine,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Signature: ${_signature!.signatureHash}',
              style: theme.bodySmall.override(
                fontFamily: 'monospace',
                color: theme.secondaryText,
                fontSize: 11.0,
                letterSpacing: 0.0,
                useGoogleFonts: false,
              ),
            ),
          ],
          if (!ok && _stepError != null) ...[
            const SizedBox(height: 12.0),
            Text(
              _stepError!,
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.error,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ],
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildFooter(FlutterFlowTheme theme) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border(
          top: BorderSide(color: theme.alternate, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_step != _WizardStep.result && _step != _WizardStep.upload)
            TextButton(
              onPressed: _back,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16.0),
                  const SizedBox(width: 6.0),
                  Text(
                    'Back',
                    style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(width: 0),
          _buildPrimaryButton(theme),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(FlutterFlowTheme theme) {
    String label;
    VoidCallback? onPressed;
    bool enabled = true;

    switch (_step) {
      case _WizardStep.upload:
        label = 'Parse & Reconcile';
        enabled = _file != null;
        onPressed = enabled ? _reconcile : null;
        break;
      case _WizardStep.preview:
        final canImport = _result?.canImport ?? false;
        label = canImport
            ? 'Continue to Sign-off (${_result!.importableCount} rows)'
            : 'No importable rows';
        enabled = canImport;
        onPressed = canImport
            ? () => setState(() => _step = _WizardStep.signOff)
            : null;
        break;
      case _WizardStep.signOff:
        label = 'Open Sign-off Dialog';
        enabled = _result != null && _result!.canImport;
        onPressed = enabled ? _openSignOff : null;
        break;
      case _WizardStep.result:
        label = 'Close';
        onPressed = () => Navigator.of(context).pop();
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        elevation: 0.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.0,
        ),
      ),
    );
  }

  // ===== Actions =====

  Future<void> _pickFile() async {
    setState(() {
      _busy = true;
      _stepError = null;
    });
    try {
      final file = await const CsvImporterService().pickAndParse();
      if (file == null) {
        // User cancelled
        setState(() => _busy = false);
        return;
      }
      setState(() {
        _file = file;
        _stepError = null;
      });
    } catch (e) {
      setState(() => _stepError = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reconcile() async {
    if (_file == null) return;
    setState(() {
      _busy = true;
      _step = _WizardStep.preview;
      _stepError = null;
    });
    try {
      final engine = ReconciliationEngine(widget.config);
      final result = await engine.reconcile(
        context: context,
        parsedRows: _file!.rows,
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() {
        _stepError = 'Reconciliation failed: $e';
        _step = _WizardStep.upload;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSignOff() async {
    if (_result == null) return;
    final user = currentUser;
    final uid = user?.uid ?? '';
    final name = currentUserDisplayName;
    if (uid.isEmpty || name.isEmpty) {
      _showToast('Could not resolve owner identity.', isError: true);
      return;
    }
    final sig = await showSignOffDialog(
      context,
      sourceFile: _file!.fileName,
      rowCount: _result!.importableCount,
      rowsOk: _result!.okCount,
      rowsWarned: _result!.warningCount,
      rowsFailed: _result!.errorCount,
      targetCollection: widget.config.targetCollection,
      ownerUid: uid,
      ownerDisplayName: name,
    );
    if (sig == null) return; // user cancelled
    await _commit(sig);
  }

  Future<void> _commit(VirtualSignature sig) async {
    setState(() {
      _busy = true;
      _step = _WizardStep.signOff;
      _stepError = null;
    });
    try {
      final written = await widget.config.writeRows(
        rows: _result!.rows.where((r) => !r.isBlocked).toList(),
        referenceData: _result!.referenceData,
        signatureFields: sig.toFirestore(),
      );
      _writtenCount = written;
      _signature = sig;

      // Write the ImportAudit log entry.
      final audit = ImportAuditRecord(
        reference: ImportAuditRecord.createDoc(),
        targetCollection: sig.targetCollection,
        sourceFile: sig.sourceFile,
        rowCount: written,
        rowsOk: _result!.okCount,
        rowsWarned: _result!.warningCount,
        rowsFailed: _result!.errorCount,
        signedOffByUid: sig.ownerUid,
        signedOffByName: sig.ownerName,
        signedAt: sig.signedAt,
        signatureHash: sig.signatureHash,
        status: written > 0 ? 'completed' : 'failed',
      );
      await audit.reference.set(audit.toFirestore());

      setState(() {
        _step = _WizardStep.result;
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _stepError = 'Commit failed: $e';
        _step = _WizardStep.result;
        _busy = false;
      });
    }
  }

  void _back() {
    setState(() {
      switch (_step) {
        case _WizardStep.preview:
          _step = _WizardStep.upload;
          _result = null;
          break;
        case _WizardStep.signOff:
          _step = _WizardStep.preview;
          break;
        case _WizardStep.result:
          _step = _WizardStep.preview;
          _signature = null;
          _writtenCount = null;
          break;
        case _WizardStep.upload:
          break;
      }
    });
  }

  void _showToast(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : FlutterFlowTheme.of(context).primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

enum _WizardStep { upload, preview, signOff, result }
