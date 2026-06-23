import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/offline/offline_connectivity_service.dart';

/// A slim banner that slides in from the top of the screen whenever the
/// device loses network connectivity, and slides out when it's restored.
///
/// Also overlays the [OfflineStatusChip] (bottom-right floating sync
/// indicator) so users always know their sync status.
///
/// Wrap the app's body in this widget to get app-wide offline awareness:
///
///   OfflineIndicatorBanner(
///     child: MaterialApp.router(...),
///   )
class OfflineIndicatorBanner extends StatefulWidget {
  const OfflineIndicatorBanner({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<OfflineIndicatorBanner> createState() => _OfflineIndicatorBannerState();
}

class _OfflineIndicatorBannerState extends State<OfflineIndicatorBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  final OfflineConnectivityService _connectivity =
      OfflineConnectivityService();

  @override
  void initState() {
    super.initState();
    _connectivity.initialize();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _heightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _connectivity.addListener(_onConnectivityChanged);

    // Initial state
    if (_connectivity.isOffline) {
      _controller.value = 1.0;
    }
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    if (_connectivity.isOffline) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final theme = Theme.of(context);
        final expandedHeight = 40.0;
        final height = _heightAnimation.value * expandedHeight;
        final opacity = _opacityAnimation.value;

        return Stack(
          children: [
            // Main app
            Positioned.fill(child: widget.child),
            // NOTE: OfflineStatusChip temporarily removed to fix
            // stack overflow crash. Will re-add after fixing the
            // infinite rebuild loop in the chip's AnimatedBuilder.
            // Offline banner (overlays the top)
            if (height > 0.5)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: height,
                child: Opacity(
                  opacity: opacity,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFF59E0B), // Amber 500
                            const Color(0xFFD97706), // Amber 600
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            children: [
                              // Pulsing icon
                              _PulsingDot(
                                color: Colors.white,
                                size: _heightAnimation.value * 8.0,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  'You\'re offline — changes will sync automatically when you\'re back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.cloud_off_rounded,
                                color: Colors.white.withAlpha(220),
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A small pulsing dot — gives a subtle "live" feel to the offline banner.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.7 + 0.3 * _controller.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withAlpha(
                      (100 + 100 * _controller.value).round()),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
