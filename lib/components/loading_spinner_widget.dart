import '/components/pulse_logo_widget.dart';
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

/// The full-page hand-off shown after the web shell has finished booting and
/// while Pulse resolves the authenticated session. Keeping it visually close
/// to the HTML shell avoids a jarring flash of an unrelated progress spinner.
class PulseAppLoadingScreen extends StatelessWidget {
  const PulseAppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final visualSize = (width * 0.25).clamp(96.0, 128.0);

    return Semantics(
      label: 'Pulse is preparing your secure workspace',
      child: ColoredBox(
        color: const Color(0xFF07070B),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: LoadingSpinnerWidget(
                        size: visualSize,
                        showLabel: false,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pulse',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                              ),
                            ),
                            TextSpan(
                              text: ' · Pharmacy Intelligence',
                              style: TextStyle(
                                color: Color(0xFF94949B),
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Preparing your secure workspace…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9C9CA5),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will only take a moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF65656E),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
                              child: PulseLogoWidget(
                                size: effectiveSize * 0.42,
                                showWordmark: false,
                                color: FlutterFlowTheme.of(context).primary,
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
                      child: PulseLogoWidget(
                        size: effectiveSize * 0.48,
                        showWordmark: false,
                        color: FlutterFlowTheme.of(context).primary,
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
      // Brand-aware full-screen loader: always render the "Pulse · Pharmacy
      // Intelligence" wordmark below the spinner so the brand identity is
      // unambiguous (previously the bare spinner on white caused users to
      // misread the dotted-ring pattern as "Duniya" — pareidolia).
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        color: (isDark ? Colors.black : Colors.white)
            .withValues(alpha: widget.overlayOpacity),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              spinner,
              SizedBox(height: effectiveSize * 0.28),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Pulse',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF07070B),
                          fontSize: effectiveSize * 0.32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                      TextSpan(
                        text: ' · Pharmacy Intelligence',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94949B)
                              : const Color(0xFF5B6478),
                          fontSize: effectiveSize * 0.32,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
