import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'loading_spinner_model.dart';
export 'loading_spinner_model.dart';

class LoadingSpinnerWidget extends StatefulWidget {
  const LoadingSpinnerWidget({
    super.key,
    String? loadingMessage,
    this.size = 72.0,
    this.showRing = true,
    this.showLabel = true,
    this.fullScreen = false,
    this.overlayOpacity = 0.5,
  }) : loadingMessage = loadingMessage ?? 'Loading';

  final String loadingMessage;
  final double size;
  final bool showRing;
  final bool showLabel;
  final bool fullScreen;
  final double overlayOpacity;

  @override
  State<LoadingSpinnerWidget> createState() => _LoadingSpinnerWidgetState();
}

class _LoadingSpinnerWidgetState extends State<LoadingSpinnerWidget>
    with TickerProviderStateMixin {
  late LoadingSpinnerModel _model;
  late AnimationController _progressController;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingSpinnerModel());

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _dotsController.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.fullScreen
        ? math.max(
            widget.size,
            (MediaQuery.sizeOf(context).shortestSide * 0.14).clamp(72.0, 132.0),
          )
        : widget.size;

    final spinner = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showRing)
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DottedCirclePainter(
                    dotCount: 40,
                    color: FlutterFlowTheme.of(context)
                        .primary
                        .withValues(alpha: 0.2),
                    dotRadius: effectiveSize * 0.015,
                  ),
                  child: CustomPaint(
                    painter: _StaticMidRingPainter(
                      color: FlutterFlowTheme.of(context)
                          .primary
                          .withValues(alpha: 0.15),
                      strokeWidth: effectiveSize * 0.02,
                    ),
                    child: CustomPaint(
                      painter: _SegmentedProgressPainter(
                        progress: _progressController.value,
                        color: FlutterFlowTheme.of(context).primary,
                        strokeWidth: effectiveSize * 0.035,
                        gapAngle: 0.15,
                      ),
                      child: Center(
                        child: Container(
                          width: effectiveSize * 0.52,
                          height: effectiveSize * 0.52,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/duniya_logo.png',
                                width: effectiveSize * 0.42,
                                height: effectiveSize * 0.42,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.local_pharmacy,
                                  size: effectiveSize * 0.28,
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: Center(
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  final scale = 0.92 +
                      (math.sin(_progressController.value * 2 * math.pi) *
                          0.05);
                  return Transform.scale(
                    scale: scale,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/duniya_logo.png',
                        width: effectiveSize * 0.48,
                        height: effectiveSize * 0.48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.local_pharmacy,
                          size: effectiveSize * 0.32,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (widget.showLabel) ...[
          SizedBox(height: effectiveSize * 0.16),
          AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              final dotCount = (_dotsController.value * 3).floor() % 4;
              final dots = '.' * dotCount;
              return Text(
                '${widget.loadingMessage}$dots',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: effectiveSize * 0.2,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              );
            },
          ),
        ],
      ],
    );

    if (widget.fullScreen) {
      return Container(
        color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white)
            .withValues(alpha: widget.overlayOpacity),
        child: Center(child: spinner),
      );
    }

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: spinner,
    );
  }
}

/// Dotted orbital border painter
class _DottedCirclePainter extends CustomPainter {
  final int dotCount;
  final Color color;
  final double dotRadius;

  _DottedCirclePainter({
    required this.dotCount,
    required this.color,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - dotRadius * 4) / 2;
    final paint = Paint()..color = color;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Static mid-ring painter (lavender ring)
class _StaticMidRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _StaticMidRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 4) / 2 - strokeWidth * 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated segmented progress arc painter
class _SegmentedProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double gapAngle;

  _SegmentedProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.gapAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 4) / 2 - strokeWidth * 2;

    final startAngle = progress * 2 * math.pi;
    final sweepAngle = math.pi * 0.75;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SegmentedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
