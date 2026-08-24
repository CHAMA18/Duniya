import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'import_audit_record.dart';

/// Side sheet that lists the most recent imports for a given section.
/// Shown by the "Import History" icon button in each section's header.
Future<void> showImportHistorySheet(
  BuildContext context, {
  required String targetCollection,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ImportHistorySheet(
      targetCollection: targetCollection,
    ),
  );
}

class _ImportHistorySheet extends StatelessWidget {
  const _ImportHistorySheet({required this.targetCollection});

  final String targetCollection;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 12.0, 12.0),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: theme.primary, size: 18.0),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Recent imports — $targetCollection',
                        style: theme.titleSmall.override(
                          fontFamily: theme.titleSmallFamily,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleSmallIsCustom,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded,
                          color: theme.secondaryText, size: 18.0),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1.0),
              // List
              Expanded(
                child: StreamBuilder<List<ImportAuditRecord>>(
                  stream: _streamAudits(targetCollection),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SpinKitRing(
                          color: theme.primary,
                          size: 32.0,
                          lineWidth: 2.0,
                        ),
                      );
                    }
                    final list = snapshot.data!;
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 36.0,
                                  color: theme.secondaryText
                                      .withAlpha(140)),
                              const SizedBox(height: 10.0),
                              Text(
                                'No imports yet',
                                style: theme.titleSmall.override(
                                  fontFamily: theme.titleSmallFamily,
                                  color: theme.primaryText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !theme.titleSmallIsCustom,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Completed imports for this section will appear here.',
                                textAlign: TextAlign.center,
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
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1.0, color: theme.alternate),
                      itemBuilder: (context, i) {
                        final a = list[i];
                        return _auditTile(theme, a);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<List<ImportAuditRecord>> _streamAudits(String collection) {
    final snap = ImportAuditRecord.collection
        .where('target_collection', isEqualTo: collection)
        .orderBy('signed_at', descending: true)
        .limit(20)
        .snapshots();
    return snap.map((qs) => qs.docs
        .map((d) => ImportAuditRecord.fromSnapshot(d))
        .toList());
  }

  Widget _auditTile(FlutterFlowTheme theme, ImportAuditRecord a) {
    final ok = a.status == 'completed';
    final color = ok ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bg = ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              ok ? Icons.check_rounded : Icons.error_outline_rounded,
              color: color,
              size: 16.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  a.sourceFile,
                  style: theme.bodyMedium.override(
                    fontFamily: theme.bodyMediumFamily,
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodyMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${a.rowCount} rows • '
                  '${a.rowsOk} ok • ${a.rowsWarned} warn • '
                  '${a.rowsFailed} fail • '
                  '${_fmtDate(a.signedAt)}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Signed by ${a.signedOffByName}',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(Icons.chevron_right_rounded,
              color: theme.secondaryText, size: 18.0),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hh:$mm';
  }
}
