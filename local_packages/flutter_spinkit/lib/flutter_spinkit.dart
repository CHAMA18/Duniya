library flutter_spinkit;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpinKitRing extends StatefulWidget {
  const SpinKitRing({
    super.key,
    required this.color,
    this.size = 50.0,
    this.lineWidth = 3.5,
    this.duration = const Duration(milliseconds: 1400),
  });

  final Color color;
  final double size;
  final double lineWidth;
  final Duration duration;

  @override
  State<SpinKitRing> createState() => _SpinKitRingState();
}

class _SpinKitRingState extends State<SpinKitRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant SpinKitRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.size;
    final logoSize = diameter * 0.34;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final spin = t * 2 * math.pi;
          final pulse = 0.9 + (math.sin(t * 2 * math.pi) * 0.06);

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(diameter, diameter),
                painter: _OrbitPainter(
                  color: widget.color.withValues(alpha: 0.18),
                  activeColor: widget.color,
                  progress: t,
                  strokeWidth: widget.lineWidth,
                ),
              ),
              Transform.rotate(
                angle: spin,
                child: Container(
                  width: diameter * 0.58,
                  height: diameter * 0.58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        widget.color.withValues(alpha: 0.06),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.scale(
                scale: pulse,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/duniya_logo.png',
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_pharmacy_rounded,
                      size: logoSize,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.color,
    required this.activeColor,
    required this.progress,
    required this.strokeWidth,
  });

  final Color color;
  final Color activeColor;
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, basePaint);

    final orbitPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.15
      ..strokeCap = StrokeCap.round;
    final sweep = math.pi * 1.15;
    final start = progress * 2 * math.pi - math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      orbitPaint,
    );

    final dotPaint = Paint()..color = activeColor;
    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * 2 * math.pi + progress * 2 * math.pi;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(dotCenter, strokeWidth * 0.7, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
