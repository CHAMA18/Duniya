import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'sale_details_model.dart';
export 'sale_details_model.dart';

/// A single row of the Recent Transactions table on the Product Detail page.
///
/// Visuals:
/// - Sales ID truncated to 10 chars + ellipsis, with the full ID shown in a
///   Tooltip on hover. Monospace font.
/// - Date column shows "22 Aug 2026, 09:58" instead of the raw ISO timestamp
///   with milliseconds.
/// - Optional [rowBg] for zebra striping (passed in by the parent).
/// - Subtle purple hover highlight on the row.
class SaleDetailsWidget extends StatefulWidget {
  const SaleDetailsWidget({
    super.key,
    this.parameter1,
    required this.parameter2,
    required this.saleId,
    required this.pharmacy,
    this.rowBg,
  });

  final String? parameter1;
  final String? parameter2;
  final String? saleId;
  final DocumentReference? pharmacy;
  final Color? rowBg;

  @override
  State<SaleDetailsWidget> createState() => _SaleDetailsWidgetState();
}

class _SaleDetailsWidgetState extends State<SaleDetailsWidget> {
  late SaleDetailsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SaleDetailsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _truncateId(String id) {
    if (id.length <= 10) return id;
    return '${id.substring(0, 10)}…';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final baseBg = widget.rowBg ?? theme.secondaryBackground;
    final hoverBg = theme.primary.withAlpha(15);

    return MouseRegion(
      opaque: true,
      cursor: SystemMouseCursors.click,
      onEnter: (_) => safeSetState(() => _model.mouseRegionHovered = true),
      onExit: (_) => safeSetState(() => _model.mouseRegionHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _model.mouseRegionHovered ? hoverBg : baseBg,
        ),
        padding:
            const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Sales ID — truncated + monospace + tooltip
            Expanded(
              flex: 2,
              child: Tooltip(
                message: widget.saleId ?? '',
                waitDuration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.0,
                  fontFamily: 'monospace',
                ),
                child: Text(
                  _truncateId(widget.saleId ?? ''),
                  style: theme.bodySmall.override(
                    fontFamily: 'monospace',
                    color: theme.primaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                    useGoogleFonts: false,
                  ),
                ),
              ),
            ),
            // Pharmacy (desktop only)
            if (responsiveVisibility(
              context: context,
              phone: false,
            ))
              Expanded(
                flex: 2,
                child: StreamBuilder<PharmacyRecord>(
                  stream: PharmacyRecord.getDocument(widget.pharmacy!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: SpinKitRing(
                          color: theme.primary,
                          size: 16.0,
                          lineWidth: 1.5,
                        ),
                      );
                    }
                    final pharma = snapshot.data!;
                    return Text(
                      pharma.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.primaryText,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    );
                  },
                ),
              ),
            // Items count (desktop only)
            if (responsiveVisibility(
              context: context,
              phone: false,
            ))
              Expanded(
                flex: 1,
                child: Text(
                  widget.parameter1 ?? '0',
                  textAlign: TextAlign.center,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.primaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ),
            // Date — formatted
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(widget.parameter2),
                textAlign: TextAlign.center,
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
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
}
