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
    this.size = 40.0,
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
    final spinner = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showRing)
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DottedCirclePainter(
                    dotCount: 40,
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                    dotRadius: widget.size * 0.015,
                  ),
                  child: CustomPaint(
                    painter: _StaticMidRingPainter(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                      strokeWidth: widget.size * 0.02,
                    ),
                    child: CustomPaint(
                      painter: _SegmentedProgressPainter(
                        progress: _progressController.value,
                        color: FlutterFlowTheme.of(context).primary,
                        strokeWidth: widget.size * 0.035,
                        gapAngle: 0.15,
                      ),
                      child: Center(
                        child: Container(
                          width: widget.size * 0.45,
                          height: widget.size * 0.45,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1A1A2E)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/duniya_logo.png',
                                width: widget.size * 0.35,
                                height: widget.size * 0.35,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.local_pharmacy,
                                  size: widget.size * 0.2,
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
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        if (widget.showLabel) ...[
          SizedBox(height: widget.size * 0.2),
          AnimatedBuilder(
            animation: _dotsController,
            builder: (context, child) {
              final dotCount = (_dotsController.value * 3).floor() % 4;
              final dots = '.' * dotCount;
              return Text(
                '${widget.loadingMessage}$dots',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: widget.size * 0.22,
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
            .withOpacity(widget.overlayOpacity),
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
