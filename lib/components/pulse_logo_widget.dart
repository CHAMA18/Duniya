import 'dart:math' as math;

import 'package:flutter/material.dart';

class PulseLogoWidget extends StatelessWidget {
  const PulseLogoWidget({
    super.key,
    this.size = 48.0,
    this.showWordmark = true,
    this.color = const Color(0xFF8A00FF),
  });

  final double size;
  final bool showWordmark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final circleSize = size;
    final wordmarkStyle = TextStyle(
      fontSize: size * 0.62,
      height: 0.9,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      color: color,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(circleSize, circleSize),
          painter: _PulseMarkPainter(color: color),
        ),
        if (showWordmark) ...[
          SizedBox(width: size * 0.28),
          Text('Pulse', style: wordmarkStyle),
        ],
      ],
    );
  }
}

class _PulseMarkPainter extends CustomPainter {
  _PulseMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.42;
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, circlePaint);

    final nodePaint = Paint()..color = color;
    for (final angle in <double>[
      -1.5708,
      -0.7854,
      0.0,
      0.7854,
      1.5708,
      2.3562,
      3.1416,
      -2.3562,
    ]) {
      final nodeCenter = Offset(
        center.dx + radius * 0.98 * math.cos(angle),
        center.dy + radius * 0.98 * math.sin(angle),
      );
      canvas.drawCircle(nodeCenter, size.shortestSide * 0.09, nodePaint);
    }

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.06
      ..strokeCap = StrokeCap.round
      ..color = color;

    final path = Path()
      ..moveTo(center.dx - radius * 0.78, center.dy)
      ..lineTo(center.dx - radius * 0.22, center.dy)
      ..lineTo(center.dx - radius * 0.08, center.dy - radius * 0.45)
      ..lineTo(center.dx + radius * 0.14, center.dy + radius * 0.52)
      ..lineTo(center.dx + radius * 0.34, center.dy - radius * 0.1)
      ..lineTo(center.dx + radius * 0.78, center.dy);
    canvas.drawPath(path, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _PulseMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
