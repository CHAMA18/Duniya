import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

/// Segmented List / Grid view toggle used across list pages
/// (Pharmacies, Suppliers, Goods Received, …).
///
/// [value] is the active mode ('list' or 'grid'); [onChanged] fires on
/// selection. Rendered with theme tokens so it adapts to dark mode.
class ListGridToggle extends StatelessWidget {
  const ListGridToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    Widget segment(String mode, IconData icon, String label, String tooltip) {
      final selected = value == mode;
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => onChanged(mode),
          borderRadius: BorderRadius.circular(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: selected ? theme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15.0,
                  color: selected ? Colors.white : theme.secondaryText,
                ),
                const SizedBox(width: 6.0),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : theme.secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: theme.alternate, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('list', Icons.view_list_rounded, 'List', 'List view'),
          segment('grid', Icons.grid_view_rounded, 'Grid', 'Grid view'),
        ],
      ),
    );
  }
}

/// Responsive grid of fixed-width cards. The column count adapts to the
/// available width so each card is at least [minCardWidth] wide — wide
/// screens show more columns, narrow screens degrade gracefully.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.minCardWidth = 240.0,
    this.gap = 14.0,
  });

  final List<Widget> children;
  final double minCardWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var columns =
            ((constraints.maxWidth + gap) / (minCardWidth + gap)).floor();
        if (columns < 1) columns = 1;
        final cardWidth =
            (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((child) => SizedBox(width: cardWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
