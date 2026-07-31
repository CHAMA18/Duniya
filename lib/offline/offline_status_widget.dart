import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/offline/offline_connectivity_service.dart';
import '/offline/offline_sync_service.dart';
import '/offline/cache_warmer_service.dart';

/// A compact floating chip that shows the app's sync status at all times.
///
/// Displayed in the bottom-right corner of the screen, it shows:
/// - ✅ "All synced" (green) when online and no pending writes
/// - 🔄 "Syncing…" (blue, animated) when writes are being flushed
/// - ⏳ "3 pending" (amber) when offline with queued writes
/// - 📡 "Offline" (gray) when offline with no pending writes
///
/// Tapping the chip opens a detailed status panel with:
/// - Last synced timestamp
/// - Records cached count
/// - A "Warm Offline Cache" button to preload data
///
/// The chip auto-hides after 4 seconds when status is "All synced" to
/// avoid clutter, and reappears when status changes.
class OfflineStatusChip extends StatefulWidget {
  const OfflineStatusChip({super.key});

  @override
  State<OfflineStatusChip> createState() => _OfflineStatusChipState();
}

class _OfflineStatusChipState extends State<OfflineStatusChip>
    with TickerProviderStateMixin {
  final OfflineConnectivityService _connectivity =
      OfflineConnectivityService();
  final OfflineSyncService _sync = OfflineSyncService();
  final CacheWarmerService _warmer = CacheWarmerService();

  late AnimationController _hideController;
  bool _panelOpen = false;

  @override
  void initState() {
    super.initState();
    _connectivity.initialize();
    _sync.initialize();

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _connectivity.addListener(_onChanged);
    _sync.addListener(_onChanged);
    _warmer.addListener(_onChanged);

    // Initial visibility
    _scheduleAutoHide();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleAutoHide();
  }

  void _scheduleAutoHide() {
    // Auto-hide when fully synced and online (after a delay)
    if (_connectivity.isOnline &&
        !_sync.hasPendingWrites &&
        !_sync.isSyncing &&
        !_warmer.isWarming &&
        !_panelOpen) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted &&
            _connectivity.isOnline &&
            !_sync.hasPendingWrites &&
            !_sync.isSyncing &&
            !_warmer.isWarming &&
            !_panelOpen) {
          _hideController.forward();
        }
      });
    } else {
      _hideController.reverse();
    }
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onChanged);
    _sync.removeListener(_onChanged);
    _warmer.removeListener(_onChanged);
    _hideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.0,
      right: 20.0,
      child: AnimatedBuilder(
        animation: Listenable.merge([_hideController, _sync, _warmer]),
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Detailed panel (expands above the chip)
              if (_panelOpen) _buildDetailPanel(context),
              if (_panelOpen) const SizedBox(height: 8.0),
              // The chip itself
              _buildChip(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isOnline = _connectivity.isOnline;
    final isWarming = _warmer.isWarming;
    final isSyncing = _sync.isSyncing;
    final pending = _sync.pendingWriteCount;

    Color bgColor;
    Color fgColor;
    IconData icon;
    String label;

    if (isWarming) {
      bgColor = const Color(0xFF6366F1); // Indigo
      fgColor = Colors.white;
      icon = Icons.downloading_rounded;
      label = 'Caching…';
    } else if (!isOnline && pending > 0) {
      bgColor = const Color(0xFFF59E0B); // Amber
      fgColor = Colors.white;
      icon = Icons.cloud_upload_rounded;
      label = '$pending pending';
    } else if (!isOnline) {
      bgColor = const Color(0xFF6B7280); // Gray
      fgColor = Colors.white;
      icon = Icons.cloud_off_rounded;
      label = 'Offline';
    } else if (isSyncing || pending > 0) {
      bgColor = const Color(0xFF2563EB); // Blue
      fgColor = Colors.white;
      icon = Icons.sync_rounded;
      label = isSyncing ? 'Syncing…' : '$pending pending';
    } else {
      bgColor = const Color(0xFF10B981); // Green
      fgColor = Colors.white;
      icon = Icons.check_circle_rounded;
      label = 'Synced';
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_hideController),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.85).animate(_hideController),
        alignment: Alignment.bottomRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => _panelOpen = !_panelOpen);
              if (_panelOpen) {
                _hideController.reverse();
              } else {
                _scheduleAutoHide();
              }
            },
            borderRadius: BorderRadius.circular(24.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withAlpha(80),
                    blurRadius: 12.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSyncing || isWarming)
                    SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  else
                    Icon(icon, color: fgColor, size: 14.0),
                  const SizedBox(width: 6.0),
                  Text(
                    label,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    _panelOpen
                        ? Icons.expand_more_rounded
                        : Icons.expand_less_rounded,
                    color: fgColor.withAlpha(200),
                    size: 14.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isOnline = _connectivity.isOnline;
    final isWarming = _warmer.isWarming;
    final pending = _sync.pendingWriteCount;
    final lastSynced = _sync.lastSyncedAt;
    final lastWarmed = _warmer.lastWarmedAt;
    final recordsCached = _warmer.recordsCached;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320.0,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: theme.alternate, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111827).withAlpha(40),
              blurRadius: 20.0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.cloud_done_rounded,
                    color: theme.primary, size: 18.0),
                const SizedBox(width: 8.0),
                Text(
                  'Sync Status',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _panelOpen = false),
                  child: Icon(Icons.close_rounded,
                      color: theme.secondaryText, size: 16.0),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Status rows
            _statusRow(
              'Connection',
              isOnline ? 'Online' : 'Offline',
              isOnline ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              theme,
            ),
            const SizedBox(height: 10.0),
            _statusRow(
              'Pending writes',
              pending == 0 ? 'None' : '$pending queued',
              pending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              theme,
            ),
            const SizedBox(height: 10.0),
            _statusRow(
              'Last synced',
              lastSynced != null
                  ? '${lastSynced.hour.toString().padLeft(2, '0')}:${lastSynced.minute.toString().padLeft(2, '0')}:${lastSynced.second.toString().padLeft(2, '0')}'
                  : 'Never',
              theme.secondaryText,
              theme,
            ),
            const SizedBox(height: 10.0),
            _statusRow(
              'Records cached',
              recordsCached > 0 ? '$recordsCached' : '—',
              theme.primaryText,
              theme,
            ),
            if (lastWarmed != null) ...[
              const SizedBox(height: 10.0),
              _statusRow(
                'Cache warmed',
                '${lastWarmed.day}/${lastWarmed.month} ${lastWarmed.hour.toString().padLeft(2, '0')}:${lastWarmed.minute.toString().padLeft(2, '0')}',
                theme.secondaryText,
                theme,
              ),
            ],

            const SizedBox(height: 18.0),

            // Warm cache button
            if (isWarming) ...[
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: LinearProgressIndicator(
                  value: _warmer.progress,
                  minHeight: 6.0,
                  backgroundColor: theme.alternate,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.primary),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _warmer.currentStep,
                style: theme.bodySmall.override(
                  fontFamily: theme.bodySmallFamily,
                  color: theme.secondaryText,
                  fontSize: 11.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodySmallIsCustom,
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FFButtonWidget(
                  onPressed: () async {
                    final count = await _warmer.warmCache();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 18.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(count > 0
                                    ? 'Offline cache warmed — $count records ready'
                                    : 'No records to cache'),
                              ),
                            ],
                          ),
                          backgroundColor: theme.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.all(16.0),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  text: 'Warm Offline Cache',
                  icon: const Icon(Icons.download_for_offline_rounded,
                      size: 16.0),
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    color: theme.primary,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0.0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

            const SizedBox(height: 12.0),
            // Help text
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 12.0, color: theme.secondaryText),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    'Warming preloads critical data so the app works fully offline',
                    style: theme.bodySmall.override(
                      fontFamily: theme.bodySmallFamily,
                      color: theme.secondaryText,
                      fontSize: 10.0,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.bodySmallIsCustom,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(
      String label, String value, Color valueColor, FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.bodySmall.override(
            fontFamily: theme.bodySmallFamily,
            color: theme.secondaryText,
            fontSize: 12.0,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.bodySmallIsCustom,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
