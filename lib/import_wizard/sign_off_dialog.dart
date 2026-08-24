import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'virtual_signature.dart';

/// Modal dialog that captures the owner's virtual signature.
///
/// Behavior:
///   - Owner must type their full name. It must match the current user's
///     display name (case-insensitive, trimmed) to enable the Sign-Off
///     button.
///   - Owner must tick the "I confirm…" checkbox.
///   - On submit, builds and returns a [VirtualSignature].
///   - On cancel, returns null (the wizard discards the in-memory rows).
///
/// Shows a summary of the import (file name, row count, status breakdown)
/// so the owner can see what they are about to sign off on.
Future<VirtualSignature?> showSignOffDialog(
  BuildContext context, {
  required String sourceFile,
  required int rowCount,
  required int rowsOk,
  required int rowsWarned,
  required int rowsFailed,
  required String targetCollection,
  required String ownerUid,
  required String ownerDisplayName,
}) {
  return showDialog<VirtualSignature>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _SignOffDialog(
      sourceFile: sourceFile,
      rowCount: rowCount,
      rowsOk: rowsOk,
      rowsWarned: rowsWarned,
      rowsFailed: rowsFailed,
      targetCollection: targetCollection,
      ownerUid: ownerUid,
      ownerDisplayName: ownerDisplayName,
    ),
  );
}

class _SignOffDialog extends StatefulWidget {
  const _SignOffDialog({
    required this.sourceFile,
    required this.rowCount,
    required this.rowsOk,
    required this.rowsWarned,
    required this.rowsFailed,
    required this.targetCollection,
    required this.ownerUid,
    required this.ownerDisplayName,
  });

  final String sourceFile;
  final int rowCount;
  final int rowsOk;
  final int rowsWarned;
  final int rowsFailed;
  final String targetCollection;
  final String ownerUid;
  final String ownerDisplayName;

  @override
  State<_SignOffDialog> createState() => _SignOffDialogState();
}

class _SignOffDialogState extends State<_SignOffDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _nameMatches {
    final typed = _controller.text.trim();
    if (typed.isEmpty) return false;
    return typed.toLowerCase() == widget.ownerDisplayName.toLowerCase();
  }

  bool get _canSubmit => _nameMatches && _confirmed && !_submitting;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      child: Container(
        width: 520.0,
        constraints: const BoxConstraints(maxWidth: 520.0),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 22.0),
                  const SizedBox(width: 10.0),
                  Text(
                    'Owner Sign-off Required',
                    style: theme.titleMedium.override(
                      fontFamily: theme.titleMediumFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleMediumIsCustom,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You are about to commit ${widget.rowCount} record'
                    '${widget.rowCount == 1 ? '' : 's'} to the '
                    '${widget.targetCollection} collection. '
                    'A virtual signature will be appended to each record '
                    'and to the Import Audit log.',
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _summaryTile(
                    context,
                    label: 'Source file',
                    value: widget.sourceFile,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 8.0),
                  _summaryTile(
                    context,
                    label: 'Status breakdown',
                    value:
                        '${widget.rowsOk} OK • ${widget.rowsWarned} warning'
                        '${widget.rowsWarned == 1 ? '' : 's'} • '
                        '${widget.rowsFailed} error'
                        '${widget.rowsFailed == 1 ? '' : 's'}',
                    icon: Icons.fact_check_outlined,
                  ),
                  const SizedBox(height: 8.0),
                  _summaryTile(
                    context,
                    label: 'Signing as',
                    value: widget.ownerDisplayName,
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    'Type your full name to sign',
                    style: theme.labelMedium.override(
                      fontFamily: theme.labelMediumFamily,
                      color: theme.secondaryText,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelMediumIsCustom,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: widget.ownerDisplayName,
                      hintStyle: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText.withAlpha(120),
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: _controller.text.isEmpty
                              ? theme.alternate
                              : (_nameMatches
                                  ? const Color(0xFF16A34A)
                                  : theme.error),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: _nameMatches
                              ? const Color(0xFF16A34A)
                              : theme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                    ),
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_controller.text.isNotEmpty && !_nameMatches)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Name does not match your account display name '
                        '("${widget.ownerDisplayName}")',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.error,
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14.0),
                  InkWell(
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18.0,
                          height: 18.0,
                          margin: const EdgeInsets.only(top: 2.0),
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? theme.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: _confirmed
                                  ? theme.primary
                                  : theme.alternate,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: _confirmed
                              ? const Icon(Icons.check_rounded,
                                  size: 14.0, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'I confirm these records have been reconciled '
                            'with existing system records and I authorize '
                            'this import.',
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.primaryText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(null),
                        child: Text(
                          'Cancel',
                          style: theme.titleSmall.override(
                            fontFamily: theme.titleSmallFamily,
                            color: theme.secondaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.titleSmallIsCustom,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 16.0,
                                height: 16.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.draw_rounded, size: 16.0),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Sign & Commit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.0, color: theme.primary),
          const SizedBox(width: 10.0),
          Text(
            '$label: ',
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              color: theme.secondaryText,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.labelMedium.override(
                fontFamily: theme.labelMediumFamily,
                color: theme.primaryText,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.labelMediumIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final signature = VirtualSignature.build(
      ownerUid: widget.ownerUid,
      ownerName: widget.ownerDisplayName,
      sourceFile: widget.sourceFile,
      rowCount: widget.rowCount,
      targetCollection: widget.targetCollection,
    );
    // Tiny delay so the spinner is visible (the signature is computed
    // synchronously — instant would feel jarring).
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pop(signature);
  }
}
