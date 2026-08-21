import '/flutter_flow/static_file_download.dart';

/// Downloads the prebuilt workbook accepted by the reconciliation importer.
Future<void> downloadReconciliationTemplate() async {
  await downloadStaticFile(
    path: '/downloads/Pulse_Reconciliation_Template.xlsx',
    fileName: 'Pulse_Reconciliation_Template.xlsx',
  );
}
