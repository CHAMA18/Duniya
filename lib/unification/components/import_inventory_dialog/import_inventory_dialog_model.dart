import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import 'import_inventory_dialog_widget.dart';

class ImportInventoryDialogModel
    extends FlutterFlowModel<ImportInventoryDialogWidget> {
  /// 0 = upload, 1 = preview, 2 = importing, 3 = summary
  int currentStep = 0;

  /// Parsed spreadsheet result (null until a file is parsed).
  dynamic parseResult;

  /// Whether a parse is in progress.
  bool isParsing = false;

  /// Whether the import is in progress.
  bool isImporting = false;

  /// Progress 0.0 - 1.0 during the importing step.
  double importProgress = 0.0;

  /// Counters populated during the importing step.
  int importedCount = 0;
  int failedCount = 0;
  int totalCount = 0;

  /// Per-row error messages during import (keyed by row index).
  Map<int, String> importErrors = {};

  /// Whether the user accepted the preview (only valid rows will be imported).
  bool previewAccepted = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
