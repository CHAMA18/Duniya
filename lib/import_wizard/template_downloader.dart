/// Template generator + downloader for the Import Wizard.
///
/// Each section (Stock Balances / Movements / Counts) exposes a
/// [ReconciliationConfig] with a canonical list of [expectedColumns].
/// This service turns that list into a ready-to-fill template file
/// (.xlsx or .csv) and pushes it to the user's browser via
/// [PlatformDownload.save].
///
/// The .xlsx variant ships with a second "Instructions" sheet that
/// documents every column. The .csv variant is plain — header row
/// plus one sample row.
///
/// Usage (button widget):
///   TemplateButton(config: StockBalanceImportConfig())
///
/// Usage (direct call):
///   await TemplateDownloader.download(
///     config: StockBalanceImportConfig(),
///     format: TemplateFormat.xlsx,
///   );
library;

import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/platform_download.dart';
import '/rbac/rbac.dart';
import 'reconciliation_engine.dart';

/// File format for the generated template.
enum TemplateFormat {
  /// Excel .xlsx — two sheets: Template + Instructions.
  xlsx,

  /// Plain CSV — header row + one sample row.
  csv,
}

/// Static service that builds + downloads template files for any
/// [ReconciliationConfig].
class TemplateDownloader {
  const TemplateDownloader._();

  /// Build the bytes for a template file of [format] containing the
  /// expected columns for [config].
  static Uint8List buildBytes({
    required ReconciliationConfig config,
    required TemplateFormat format,
  }) {
    switch (format) {
      case TemplateFormat.xlsx:
        return _buildXlsxBytes(config);
      case TemplateFormat.csv:
        return _buildCsvBytes(config);
    }
  }

  /// Default file name for a [config] + [format] combo.
  /// e.g. ("Stock Balances", xlsx) → "stock_balances_template.xlsx"
  static String fileName({
    required ReconciliationConfig config,
    required TemplateFormat format,
  }) {
    final snake = _snakeCase(config.displayName);
    final ext = format == TemplateFormat.xlsx ? 'xlsx' : 'csv';
    return '${snake}_template.$ext';
  }

  /// Build the file and trigger a browser download.
  /// No-op if the encode step returns null (e.g. Excel internal failure).
  static Future<void> download({
    required ReconciliationConfig config,
    required TemplateFormat format,
  }) async {
    final bytes = buildBytes(config: config, format: format);
    await save(
      bytes: bytes,
      fileName: fileName(config: config, format: format),
      mimeType: format == TemplateFormat.xlsx
          ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          : 'text/csv',
    );
  }

  // --------------------------------------------------------------------------
  // XLSX builder
  // --------------------------------------------------------------------------

  static Uint8List _buildXlsxBytes(ReconciliationConfig config) {
    final excel = Excel.createExcel();
    // The Excel package cannot safely rename the default sheet on web.
    // The importer reads the first worksheet, so we keep the default
    // sheet name and just populate it.
    final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

    final displayHeaders =
        config.expectedColumns.map(_titleCaseColumn).toList();

    // Row 0: header row
    for (var i = 0; i < displayHeaders.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = displayHeaders[i];
    }

    // Row 1: one sample row (so users see what data looks like per column)
    final samples =
        config.expectedColumns.map(_sampleValueFor).toList();
    for (var i = 0; i < samples.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
      cell.value = samples[i];
    }

    // Column widths — give every column some breathing room
    for (var i = 0; i < displayHeaders.length; i++) {
      sheet.setColWidth(i, 24.0);
    }

    // Second sheet: per-column instructions
    const instructionsSheetName = 'Instructions';
    excel[instructionsSheetName]; // auto-creates
    final instructionsSheet = excel[instructionsSheetName];

    final instructions = _buildInstructions(config);
    for (var r = 0; r < instructions.length; r++) {
      for (var c = 0; c < instructions[r].length; c++) {
        final cell = instructionsSheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
        cell.value = instructions[r][c];
      }
    }

    instructionsSheet.setColWidth(0, 22.0); // Column
    instructionsSheet.setColWidth(1, 18.0); // Required
    instructionsSheet.setColWidth(2, 24.0); // Format
    instructionsSheet.setColWidth(3, 50.0); // Description
    instructionsSheet.setColWidth(4, 22.0); // Example

    final encoded = excel.encode();
    if (encoded == null) {
      return Uint8List(0);
    }
    return Uint8List.fromList(encoded);
  }

  // --------------------------------------------------------------------------
  // CSV builder
  // --------------------------------------------------------------------------

  static Uint8List _buildCsvBytes(ReconciliationConfig config) {
    final displayHeaders =
        config.expectedColumns.map(_titleCaseColumn).toList();
    final samples = config.expectedColumns.map(_sampleValueFor).toList();

    // Quote every cell so commas inside values don't break the parse.
    final rows = <List<String>>[
      displayHeaders,
      samples,
    ];
    final csvString = const ListToCsvConverter().convert(rows);
    final bytes = Uint8List.fromList(csvString.codeUnits);
    return bytes;
  }

  // --------------------------------------------------------------------------
  // Per-column metadata
  // --------------------------------------------------------------------------

  static List<List<String>> _buildInstructions(ReconciliationConfig config) {
    final rows = <List<String>>[
      ['Column', 'Required', 'Format', 'Description', 'Example'],
    ];
    for (final col in config.expectedColumns) {
      final meta = _columnMeta(col);
      rows.add([
        _titleCaseColumn(col),
        meta.required ? 'Yes' : 'No',
        meta.format,
        meta.description,
        meta.example,
      ]);
    }
    return rows;
  }

  static _ColumnMeta _columnMeta(String camelKey) {
    final k = camelKey.toLowerCase();

    // Generic ID field (productId, etc.)
    if (k == 'productid') {
      return const _ColumnMeta(
        required: true,
        format: 'Text',
        description: 'Product reference. Accepts the product\'s Firestore ID, '
            'name, or SKU — smart detection matches any of these against '
            'the master catalogue. Must resolve to an existing product.',
        example: 'ABC123 or "Paracetamol 500mg"',
      );
    }

    if (k == 'period') {
      return const _ColumnMeta(
        required: true,
        format: 'YYYY-MM',
        description: 'Reporting period. Must be within the last 12 months '
            '(inclusive of the current month). Future periods are rejected.',
        example: '2026-08',
      );
    }

    if (k == 'productname') {
      return const _ColumnMeta(
        required: true,
        format: 'Text',
        description: 'Product name as it appears in the master catalogue. '
            'Used together with batchNumber to resolve the source stock '
            'record for the movement.',
        example: 'Paracetamol 500mg',
      );
    }

    if (k == 'batchnumber') {
      return const _ColumnMeta(
        required: false,
        format: 'Text',
        description: 'Batch / lot identifier. Combined with productName to '
            'resolve the source stock record for a movement.',
        example: 'BATCH-2026-001',
      );
    }

    if (k == 'movementtype') {
      return const _ColumnMeta(
        required: true,
        format: 'Enum',
        description: 'One of: RECEIVED, SOLD, RETURNED, TRANSFERRED, '
            'DAMAGED, EXPIRED, ADJUSTMENT, COUNT_CORRECTION. Synonyms are '
            'accepted (e.g. "in", "received", "inflow" all map to RECEIVED).',
        example: 'RECEIVED',
      );
    }

    if (k == 'quantity') {
      return const _ColumnMeta(
        required: true,
        format: 'Integer ≥ 1',
        description: 'Whole units moved. Must be greater than zero.',
        example: '50',
      );
    }

    if (k == 'countedquantity') {
      return const _ColumnMeta(
        required: true,
        format: 'Integer ≥ 0',
        description: 'The physical count result. Must be 0 or positive. '
            'Variance is computed as (countedQuantity − systemQuantity).',
        example: '98',
      );
    }

    if (k == 'systemquantity') {
      return const _ColumnMeta(
        required: false,
        format: 'Integer ≥ 0',
        description: 'The system\'s recorded quantity for this product. '
            'If omitted, the current stock value is used at import time.',
        example: '100',
      );
    }

    if (k == 'reason' || k == 'explanation') {
      return const _ColumnMeta(
        required: false,
        format: 'Text',
        description: 'Free-text note. Strongly recommended for movements '
            'with large variances or unusual types (DAMAGED / ADJUSTMENT).',
        example: 'Damaged in transit — see delivery note DN-2026-042',
      );
    }

    if (k == 'movementreference') {
      return const _ColumnMeta(
        required: false,
        format: 'Text',
        description: 'External reference number (delivery note, invoice #, '
            'etc.). Used for deduplication — repeated references in the '
            'same import are flagged as warnings.',
        example: 'REF-2026-001',
      );
    }

    if (k == 'movementdate') {
      return const _ColumnMeta(
        required: false,
        format: 'YYYY-MM-DD or DD/MM/YYYY',
        description: 'When the movement occurred. Cannot be in the future '
            '(beyond tomorrow). If omitted, the import timestamp is used.',
        example: '2026-08-24',
      );
    }

    // Stock balance quantity columns
    if (k.startsWith('stock') || k == 'openingstock' || k == 'closingstock') {
      return const _ColumnMeta(
        required: false,
        format: 'Integer ≥ 0',
        description: 'Whole-unit quantity for the period. Must be 0 or '
            'positive. If closingStock is omitted, it is calculated from '
            'opening + received − dispensed − transferred + adjusted.',
        example: '100',
      );
    }

    // Fallback for any other column
    return _ColumnMeta(
      required: false,
      format: 'Text',
      description: 'Column "$camelKey". See the import wizard\'s preview '
          'step for validation messages specific to your data.',
      example: '',
    );
  }

  /// Sample (placeholder) value for a column, used in the example row.
  static String _sampleValueFor(String camelKey) {
    final k = camelKey.toLowerCase();
    if (k == 'productid') return 'ABC123';
    if (k == 'period') {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
    if (k == 'productname') return 'Paracetamol 500mg';
    if (k == 'batchnumber') return 'BATCH-2026-001';
    if (k == 'movementtype') return 'RECEIVED';
    if (k == 'quantity') return '50';
    if (k == 'countedquantity') return '98';
    if (k == 'systemquantity') return '100';
    if (k == 'reason' || k == 'explanation') {
      return 'Sample note — replace with your own';
    }
    if (k == 'movementreference') return 'REF-2026-001';
    if (k == 'movementdate') {
      return DateTime.now().toIso8601String().substring(0, 10);
    }
    if (k.startsWith('stock') ||
        k == 'openingstock' ||
        k == 'closingstock') {
      return '0';
    }
    return '';
  }

  /// Convert "productId" → "Product ID", "movementType" → "Movement Type".
  /// Special-cases "Id" so it renders as "ID" (uppercase, no trailing letter).
  static String _titleCaseColumn(String camel) {
    if (camel.isEmpty) return camel;
    final words = <String>[];
    final buf = StringBuffer();
    for (var i = 0; i < camel.length; i++) {
      final ch = camel[i];
      final isUpper = ch.toUpperCase() == ch && ch.toLowerCase() != ch;
      if (isUpper && buf.isNotEmpty) {
        words.add(buf.toString());
        buf.clear();
        buf.write(ch);
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) words.add(buf.toString());

    return words.map((w) {
      if (w.toLowerCase() == 'id') return 'ID';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }

  static String _snakeCase(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceFirst(RegExp(r'^_+'), '')
        .replaceFirst(RegExp(r'_+$'), '');
  }
}

class _ColumnMeta {
  const _ColumnMeta({
    required this.required,
    required this.format,
    required this.description,
    required this.example,
  });

  final bool required;
  final String format;
  final String description;
  final String example;
}

// --------------------------------------------------------------------------
// Reusable button widget
// --------------------------------------------------------------------------

/// Owner-only "Template" button. Drops in next to [ImportButton] on any
/// section header. On tap, shows a small popup menu with two options:
///
///   Excel (.xlsx) — two-sheet workbook (Template + Instructions)
///   CSV (.csv)    — single-sheet plain text
///
/// Selecting either triggers a browser download of the template file
/// pre-populated with the correct column headers for that section.
///
/// Hidden entirely for non-owners — consistent with [ImportButton].
class TemplateButton extends StatelessWidget {
  const TemplateButton({
    super.key,
    required this.config,
    this.label = 'Template',
    this.icon = Icons.download_rounded,
    this.variant = TemplateButtonVariant.outlined,
  });

  final ReconciliationConfig config;
  final String label;
  final IconData icon;
  final TemplateButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    // Hide entirely for non-owners — staff cannot import, so a template
    // download would be wasted effort.
    if (!AccessControl.isOwner(context)) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);
    final isPrimary = variant == TemplateButtonVariant.primary;
    final isOutlined = variant == TemplateButtonVariant.outlined;

    return Material(
      color: isPrimary ? theme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: () => _showFormatMenu(context),
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 44.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: isOutlined
                ? Border.all(
                    color: theme.secondaryText.withAlpha(140), width: 1.0)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: isPrimary ? Colors.white : theme.secondaryText,
              ),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: isPrimary ? Colors.white : theme.secondaryText,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
              const SizedBox(width: 4.0),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18.0,
                color: isPrimary
                    ? Colors.white.withAlpha(180)
                    : theme.secondaryText.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFormatMenu(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(
          renderBox.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final choice = await showMenu<TemplateFormat>(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(
          value: TemplateFormat.xlsx,
          child: Row(
            children: [
              Icon(Icons.table_chart_rounded, size: 18.0),
              SizedBox(width: 10.0),
              Text('Excel (.xlsx)'),
              SizedBox(width: 6.0),
              Text(
                'with Instructions sheet',
                style: TextStyle(fontSize: 11.0, color: Colors.black54),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: TemplateFormat.csv,
          child: Row(
            children: [
              Icon(Icons.text_snippet_rounded, size: 18.0),
              SizedBox(width: 10.0),
              Text('CSV (.csv)'),
              SizedBox(width: 6.0),
              Text(
                'plain text',
                style: TextStyle(fontSize: 11.0, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );

    if (choice == null) return;
    if (!context.mounted) return;

    // Show a brief snackbar so the user sees the download triggered
    // even if their browser hides the download bar.
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          'Downloading ${config.displayName} template '
          '(${choice == TemplateFormat.xlsx ? ".xlsx" : ".csv"})…',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      await TemplateDownloader.download(config: config, format: choice);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Template download failed: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

enum TemplateButtonVariant { primary, outlined }
