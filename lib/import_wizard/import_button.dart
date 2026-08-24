import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/rbac/rbac.dart';
import 'import_wizard_widget.dart';
import 'reconciliation_engine.dart';

/// A reusable "Import" button that:
///   1. Verifies the current user is a pharmacy owner
///      ([AccessControl.isOwner]); hidden for non-owners.
///   2. Opens the [ImportWizard] modal with the provided [config].
///
/// Drop into the header row of any section (Stock Balances / Movements /
/// Counts) and pass the matching config.
class ImportButton extends StatelessWidget {
  const ImportButton({
    super.key,
    required this.config,
    this.label = 'Import',
    this.icon = Icons.upload_file_rounded,
    this.variant = ImportButtonVariant.outlined,
  });

  final ReconciliationConfig config;
  final String label;
  final IconData icon;
  final ImportButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    // Hide entirely for non-owners — staff cannot import.
    if (!AccessControl.isOwner(context)) return const SizedBox.shrink();

    final theme = FlutterFlowTheme.of(context);
    final isPrimary = variant == ImportButtonVariant.primary;
    final isOutlined = variant == ImportButtonVariant.outlined;

    return Material(
      color: isPrimary ? theme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      elevation: isPrimary ? 0.0 : 0.0,
      child: InkWell(
        onTap: () => ImportWizard.openDialog(context, config: config),
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          height: 44.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: isOutlined
                ? Border.all(
                    color: theme.primary.withAlpha(140), width: 1.0)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16.0,
                color: isPrimary ? Colors.white : theme.primary,
              ),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: theme.titleSmall.override(
                  fontFamily: theme.titleSmallFamily,
                  color: isPrimary ? Colors.white : theme.primary,
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
