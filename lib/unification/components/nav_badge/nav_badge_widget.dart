import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// NavBadge — small circular count badge for sidebar nav items.
/// Wraps a Firestore count stream and shows nothing when count == 0.
class NavBadge extends StatelessWidget {
  final Stream<int> countStream;
  final Color color;

  const NavBadge({
    super.key,
    required this.countStream,
    this.color = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primaryBackground,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        );
      },
    );
  }
}
