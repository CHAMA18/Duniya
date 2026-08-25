import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/rbac/rbac.dart';
import 'import_wizard_widget.dart';
import 'reconciliation_engine.dart';

/// A reusable "Import" button that:
///   1. Verifies the current user may import stock
///      ([AccessControl.isOwner]); hidden otherwise.
///   2. Opens the [ImportWizard] modal with the provided [config].
///
/// Drop into the header row of any section (Stock Balances / Movements /
/// Counts) and pass the matching config.
///
/// Styling: by default the outlined variant paints in [FlutterFlowTheme.primary]
/// — perfect on light surfaces but INVISIBLE on the purple gradient heroes.
/// When placing the button on a colored hero pass [foreground] (and optionally
/// [background] / [borderColor]) so it renders in the hero's glass style.
class ImportButton extends StatelessWidget {
  const ImportButton({
    super.key,
    required this.config,
    this.label = 'Import',
    this.icon = Icons.upload_file_rounded,
    this.variant = ImportButtonVariant.outlined,
    this.foreground,
    this.background,
    this.borderColor,
  });

  final ReconciliationConfig config;
  final String label;
  final IconData icon;
  final ImportButtonVariant variant;

  /// Overrides the icon + label color (e.g. Colors.white on purple heroes).
  final Color? foreground;

  /// Fills the button (e.g. Colors.white for a high-contrast primary look).
  final Color? background;

  /// Overrides the outline color for the outlined variant.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    // Hide entirely for non-owners — staff cannot import.
    if (!AccessControl.isOwner(context)) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);
    final isPrimary = variant == ImportButtonVariant.primary;
    final isOutlined = variant == ImportButtonVariant.outlined;

    final fg = foreground ?? (isPrimary ? Colors.white : theme.primary);
    final bg = background ?? (isPrimary ? theme.primary : Colors.transparent);
    final border = borderColor ?? (isPrimary ? null : theme.primary.withAlpha(140));

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10.0),
      elevation: 0.0,
      child: InkWell(
        onTap: () => ImportWizard.openDialog(context, config: config),
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 44.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: isOutlined && border != null
                ? Border.all(color: border, width: 1.0)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: fg,
              ),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: fg,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.titleSmallIsCustom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImportButtonVariant { primary, outlined }
