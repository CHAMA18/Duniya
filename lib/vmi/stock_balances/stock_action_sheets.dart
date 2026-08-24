// =========================================================================
// Stock Balances — per-row action sheets
// =========================================================================
// Modal pop-ups invoked from the per-row History / Transfer / Adjust
// icon buttons in the Stock Balances table.
//
//   • StockMovementHistorySheet  — streams the 50 most recent
//     StockMovement docs for the row's product, shown as a scrollable
//     ledger with type pills, signed quantities, timestamps and reasons.
//
//   • StockAdjustSheet           — lets the user record a stock-take:
//     shows the current closing balance, accepts a new counted quantity
//     + a reason + optional note, and writes a single StockMovement with
//     movementType 'Adjustment' and a signed delta quantity. The
//     StockBalance is NOT mutated directly — movements are the source
//     of truth, the balance is derived.
//
// The Transfer button does NOT need a sheet in this file — it reuses
// the existing SwitchPharmStockWidget at
// /unification/components/switch_pharm_stock/switch_pharm_stock_widget.dart
//
// Conventions matched:
//   • Dialog > WebViewAware > GestureDetector (FlutterFlow pattern)
//   • AccessControl.networkWideQueryParent(context) for the query parent
//   • StockMovementRecord.createDoc(scopeRef).set(createStockMovementRecordData(...))
//   • theme.primary / theme.secondary / theme.alternate / theme.error
//   • theme.titleSmall / theme.bodyMedium / theme.labelSmall overrides
// =========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/rbac/rbac.dart';

// =========================================================================
// 1. HISTORY SHEET
// =========================================================================

class StockMovementHistorySheet extends StatefulWidget {
  const StockMovementHistorySheet({
    super.key,
    required this.balance,
    required this.product,
  });

  final StockBalanceRecord balance;
  final ProductMasterRecord product;

  @override
  State<StockMovementHistorySheet> createState() =>
      _StockMovementHistorySheetState();
}

class _StockMovementHistorySheetState
    extends State<StockMovementHistorySheet> {
  // Reason cache — we only need the parent once.
  DocumentReference? _scopeRef;
  bool _init = false;

  void _ensureScope(BuildContext context) {
    if (_init) return;
    _init = true;
    _scopeRef = AccessControl.networkWideQueryParent(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    _ensureScope(context);

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Material(
          color: Colors.transparent,
          elevation: 6.0,
          shadowColor: const Color(0xFF111827).withAlpha(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: 620.0,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, theme),
                Divider(height: 1.0, thickness: 1.0, color: theme.alternate),
                Flexible(child: _buildBody(context, theme)),
                _buildFooter(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            theme.primary,
            theme.primary.withAlpha(220),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(Icons.history_rounded,
                color: Colors.white, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Movement History',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.product.hasName() ? widget.product.name : 'Unknown product',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Colors.white.withAlpha(220),
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  // ─── Body (stream-driven list) ────────────────────────────────────

  Widget _buildBody(BuildContext context, FlutterFlowTheme theme) {
    if (_scopeRef == null) {
      return _buildEmptyState(
        theme,
        icon: Icons.lock_outline_rounded,
        title: 'No active scope',
        body:
            'We could not resolve the pharmacy scope for the current user. '
            'Please re-open the page while signed in as a pharmacy owner.',
      );
    }

    return StreamBuilder<List<StockMovementRecord>>(
      stream: queryStockMovementRecord(
        parent: _scopeRef,
        queryBuilder: (q) => q
            .where('ProductId', isEqualTo: widget.product.reference)
            .orderBy('CreatedAt', descending: true)
            .limit(50),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState(
            theme,
            icon: Icons.error_outline_rounded,
            title: 'Could not load history',
            body:
                'An error occurred while fetching the stock movements for '
                'this product. Please retry in a moment.',
          );
        }
        if (!snapshot.hasData) {
          return _buildLoading(theme);
        }
        final movements = snapshot.data!;
        if (movements.isEmpty) {
          return _buildEmptyState(
            theme,
            icon: Icons.history_toggle_off_rounded,
            title: 'No movements recorded yet',
            body:
                'When stock is received, dispensed, transferred or adjusted, '
                'those events will appear here as a chronological ledger.',
          );
        }
        return _buildList(context, theme, movements);
      },
    );
  }

  Widget _buildLoading(FlutterFlowTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRing(
            color: theme.primary,
            size: 28.0,
            lineWidth: 2.4,
          ),
          const SizedBox(height: 14.0),
          Text(
            'Loading recent movements…',
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    FlutterFlowTheme theme,
    List<StockMovementRecord> movements,
  ) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 10.0, 8.0, 10.0),
        itemCount: movements.length,
        separatorBuilder: (_, __) => Divider(
          height: 1.0,
          thickness: 1.0,
          color: theme.alternate.withAlpha(120),
        ),
        itemBuilder: (context, i) {
          final m = movements[i];
          return _MovementTile(movement: m, theme: theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(
    FlutterFlowTheme theme, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(32.0, 24.0, 32.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.secondaryText, size: 48.0),
            const SizedBox(height: 12.0),
            Text(
              title,
              style: theme.titleSmall.override(
                fontFamily: theme.titleSmallFamily,
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.titleSmallIsCustom,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 14.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        border: Border(
          top: BorderSide(color: theme.alternate, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: theme.secondaryText, size: 14.0),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              'Showing the 50 most recent movements. Older events live in the full Stock Movements ledger.',
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.secondaryText,
                fontSize: 11.0,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(foregroundColor: theme.primary),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ─── Movement tile (single row inside the history list) ────────────────

class _MovementTile extends StatelessWidget {
  const _MovementTile({required this.movement, required this.theme});

  final StockMovementRecord movement;
  final FlutterFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    final type = movement.movementType;
    final delta = _signedDelta(type, movement.quantity);
    final pill = _MovementPill.forType(type);
    final when = movement.createdAt;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: pill.bg,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: pill.fg.withAlpha(80), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(pill.icon, size: 12.0, color: pill.fg),
                const SizedBox(width: 4.0),
                Text(
                  pill.label,
                  style: theme.labelSmall.override(
                    fontFamily: theme.labelSmallFamily,
                    color: pill.fg,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    useGoogleFonts: !theme.labelSmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          // Quantity + reason
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${delta >= 0 ? '+' : ''}$delta',
                      style: theme.titleMedium.override(
                        fontFamily: theme.titleMediumFamily,
                        color: delta >= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.titleMediumIsCustom,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        'units',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (when != null)
                      Text(
                        _formatDateTime(when),
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                  ],
                ),
                if (movement.reason != null &&
                    movement.reason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    movement.reason!.trim(),
                    style: theme.bodyMedium.override(
                      fontFamily: theme.bodyMediumFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodyMediumIsCustom,
                    ),
                  ),
                ],
                if (movement.movementReference != null &&
                    movement.movementReference!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(
                    'Ref: ${movement.movementReference!.trim()}',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 11.0,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a signed delta for display. Receive/Adjustment-up are
  /// positive; Dispense/Transfer-out/Adjustment-down negative. The
  /// sign is inferred from the movementType + raw quantity.
  int _signedDelta(String type, int qty) {
    final raw = qty.abs();
    final t = type.toLowerCase();
    final negative = t.contains('dispense') ||
        t.contains('transfer') && !t.contains('receive') ||
        t.contains('issue') ||
        t.contains('out') ||
        t.contains('damaged') ||
        t.contains('expired');
    return negative ? -raw : raw;
  }

  String _formatDateTime(DateTime dt) {
    final d = DateTime.tryParse(dt.toIso8601String()) ?? dt;
    final local = d.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

// ─── Movement pill style (color/icon per type) ──────────────────────────

class _MovementPill {
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
  const _MovementPill({
    required this.label,
    required this.icon,
    required this.fg,
    required this.bg,
  });

  static _MovementPill forType(String type) {
    final t = (type).toLowerCase();
    if (t.contains('receive') || t.contains('inflow') || t.contains('in')) {
      return _MovementPill(
        label: 'RECEIVE',
        icon: Icons.south_west_rounded,
        fg: const Color(0xFF10B981),
        bg: const Color(0xFF10B981).withAlpha(20),
      );
    }
    if (t.contains('dispense') || t.contains('outflow') ||
        t.contains('issue') || t.contains('sale')) {
      return _MovementPill(
        label: 'DISPENSE',
        icon: Icons.north_east_rounded,
        fg: const Color(0xFFEF4444),
        bg: const Color(0xFFEF4444).withAlpha(20),
      );
    }
    if (t.contains('transfer')) {
      return _MovementPill(
        label: 'TRANSFER',
        icon: Icons.swap_horiz_rounded,
        fg: const Color(0xFF6366F1),
        bg: const Color(0xFF6366F1).withAlpha(20),
      );
    }
    if (t.contains('adjust')) {
      return _MovementPill(
        label: 'ADJUST',
        icon: Icons.tune_rounded,
        fg: const Color(0xFFF59E0B),
        bg: const Color(0xFFF59E0B).withAlpha(20),
      );
    }
    if (t.contains('damage') || t.contains('expire')) {
      return _MovementPill(
        label: 'LOSS',
        icon: Icons.warning_amber_rounded,
        fg: const Color(0xFFB91C1C),
        bg: const Color(0xFFB91C1C).withAlpha(20),
      );
    }
    return _MovementPill(
      label: 'MOVEMENT',
      icon: Icons.history_rounded,
      fg: const Color(0xFF6B7280),
      bg: const Color(0xFF6B7280).withAlpha(20),
    );
  }
}

// =========================================================================
// 2. ADJUST SHEET
// =========================================================================

class StockAdjustSheet extends StatefulWidget {
  const StockAdjustSheet({
    super.key,
    required this.balance,
    required this.product,
  });

  final StockBalanceRecord balance;
  final ProductMasterRecord product;

  @override
  State<StockAdjustSheet> createState() => _StockAdjustSheetState();
}

class _StockAdjustSheetState extends State<StockAdjustSheet> {
  late TextEditingController _countCtrl;
  late TextEditingController _noteCtrl;
  String? _reasonValue;
  bool _saving = false;
  String? _error;

  // Reason options — order matters for the dropdown.
  static const List<String> _reasons = [
    'Stock Take',
    'Damaged',
    'Expired',
    'Theft / Loss',
    'Returned to Supplier',
    'Found Stock',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(
      text: widget.balance.closingStock.toString(),
    );
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int get _current => widget.balance.closingStock;

  int? get _parsedCount => int.tryParse(_countCtrl.text.trim());

  int? get _delta {
    final c = _parsedCount;
    if (c == null) return null;
    return c - _current;
  }

  bool get _canSave {
    final d = _delta;
    return d != null && d != 0 && _reasonValue != null && !_saving;
  }

  Future<void> _save(BuildContext context) async {
    final d = _delta;
    if (d == null || d == 0 || _reasonValue == null) return;
    final user = currentUserReference;
    if (user == null) {
      safeSetState(() {
        _error = 'You must be signed in to record an adjustment.';
      });
      return;
    }
    safeSetState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Scope is derived from the StockBalance reference path. This
      // matches the convention in stock_movements_widget.dart — see
      // line ~537-543. We use the first 2 path segments (Users/{uid}).
      final segs = widget.balance.reference.path.split('/');
      final scopeRef = segs.length >= 2
          ? FirebaseFirestore.instance.doc(segs.sublist(0, 2).join('/'))
          : user;
      final note = _noteCtrl.text.trim();
      final reason = note.isEmpty ? _reasonValue! : '$_reasonValue — $note';

      await StockMovementRecord.createDoc(scopeRef).set(
        createStockMovementRecordData(
          productId: widget.product.reference,
          productName:
              widget.product.hasName() ? widget.product.name : null,
          outletId: widget.balance.outletId,
          quantity: d,
          movementType: 'Adjustment',
          reason: reason,
          movementReference: null,
          recordedById: user,
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Adjustment recorded for ${widget.product.name}: '
            '${d >= 0 ? '+' : ''}$d units ($_reasonValue).',
          ),
          backgroundColor: FlutterFlowTheme.of(context).primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      safeSetState(() {
        _saving = false;
        _error = 'Could not save the adjustment. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Material(
          color: Colors.transparent,
          elevation: 6.0,
          shadowColor: const Color(0xFF111827).withAlpha(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: 540.0,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(16.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme),
                  _buildSummary(theme),
                  _buildForm(context, theme),
                  if (_error != null) _buildError(theme),
                  _buildActions(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FlutterFlowTheme theme) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 18.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [theme.primary, theme.primary.withAlpha(220)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Colors.white, size: 22.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjust Stock',
                  style: theme.titleMedium.override(
                    fontFamily: theme.titleMediumFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleMediumIsCustom,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Record a physical count or correction',
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: Colors.white.withAlpha(220),
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(FlutterFlowTheme theme) {
    final d = _delta;
    final deltaColor = (d == null || d == 0)
        ? theme.secondaryText
        : (d > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20.0, 18.0, 20.0, 4.0),
      padding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCT',
                  style: theme.labelSmall.override(
                    fontFamily: theme.labelSmallFamily,
                    color: theme.secondaryText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    useGoogleFonts: !theme.labelSmallIsCustom,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  widget.product.hasName()
                      ? widget.product.name
                      : 'Unknown product',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    color: theme.primaryText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'CURRENT',
                style: theme.labelSmall.override(
                  fontFamily: theme.labelSmallFamily,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  useGoogleFonts: !theme.labelSmallIsCustom,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                '$_current ${widget.product.unitOfMeasure ?? 'units'}',
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DELTA',
                style: theme.labelSmall.override(
                  fontFamily: theme.labelSmallFamily,
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  useGoogleFonts: !theme.labelSmallIsCustom,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                d == null ? '—' : '${d >= 0 ? '+' : ''}$d',
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: deltaColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counted quantity
          _label(theme, 'New Counted Quantity *'),
          const SizedBox(height: 6.0),
          TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: _inputDecoration(
              theme,
              hint: 'Enter the physical count',
              suffix: widget.product.unitOfMeasure ?? 'units',
            ),
            onChanged: (_) => safeSetState(() {}),
          ),
          const SizedBox(height: 18.0),
          // Reason
          _label(theme, 'Reason *'),
          const SizedBox(height: 6.0),
          _buildReasonDropdown(theme),
          const SizedBox(height: 18.0),
          // Note
          _label(theme, 'Note (optional)'),
          const SizedBox(height: 6.0),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              theme,
              hint: 'Add context — batch number, expiry, who authorised…',
            ),
            onChanged: (_) => safeSetState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown(FlutterFlowTheme theme) {
    // Lightweight dropdown — uses Material DropdownButtonFormField for
    // visual consistency with the existing forms in the app without
    // pulling in the heavier FlutterFlowDropDown wrapper.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _reasonValue,
          hint: Text(
            'Choose a reason…',
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.secondaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: theme.secondaryText, size: 22.0),
          items: _reasons
              .map((r) => DropdownMenuItem<String>(
                    value: r,
                    child: Text(r,
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        )),
                  ))
              .toList(),
          onChanged: (v) => safeSetState(() {
            _reasonValue = v;
          }),
        ),
      ),
    );
  }

  Widget _buildError(FlutterFlowTheme theme) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(20.0, 4.0, 20.0, 0.0),
      padding:
          const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 12.0, 10.0),
      decoration: BoxDecoration(
        color: theme.error.withAlpha(20),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.error.withAlpha(80), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.error, size: 18.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _error!,
              style: theme.bodySmall.override(
                fontFamily: theme.bodySmallFamily,
                color: theme.error,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodySmallIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(foregroundColor: theme.secondaryText),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10.0),
          FilledButton.icon(
            onPressed: _canSave ? () => _save(context) : null,
            style: FilledButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            icon: _saving
                ? SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18.0),
            label: const Text(
              'Record Adjustment',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(FlutterFlowTheme theme, String text) {
    return Text(
      text,
      style: theme.labelSmall.override(
        fontFamily: theme.labelSmallFamily,
        color: theme.secondaryText,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        useGoogleFonts: !theme.labelSmallIsCustom,
      ),
    );
  }

  InputDecoration _inputDecoration(
    FlutterFlowTheme theme, {
    required String hint,
    String? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: theme.bodyMedium.override(
        fontFamily: theme.bodyMediumFamily,
        color: theme.secondaryText,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodyMediumIsCustom,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: theme.alternate, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: theme.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: theme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: theme.error, width: 1.6),
      ),
      filled: true,
      fillColor: theme.primaryBackground,
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(14.0, 12.0, 14.0, 12.0),
      suffixText: suffix,
      suffixStyle: theme.bodySmall.override(
        fontFamily: theme.bodySmallFamily,
        color: theme.secondaryText,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.bodySmallIsCustom,
      ),
    );
  }
}
