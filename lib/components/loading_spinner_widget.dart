import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'loading_spinner_model.dart';
export 'loading_spinner_model.dart';

class LoadingSpinnerWidget extends StatefulWidget {
  const LoadingSpinnerWidget({
    super.key,
    String? loadingMessage,
  }) : this.loadingMessage = loadingMessage ?? 'Loading';

  final String loadingMessage;

  @override
  State<LoadingSpinnerWidget> createState() => _LoadingSpinnerWidgetState();
}

class _LoadingSpinnerWidgetState extends State<LoadingSpinnerWidget>
    with TickerProviderStateMixin {
  late LoadingSpinnerModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingSpinnerModel());

    animationsMap.addAll({
      'iconOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.spinner,
            color: FlutterFlowTheme.of(context).primary,
            size: 45.0,
          ).animateOnPageLoad(animationsMap['iconOnPageLoadAnimation']!),
          Text(
            widget.loadingMessage,
            style: FlutterFlowTheme.of(context).headlineLarge.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineLargeFamily,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineLargeIsCustom,
                ),
          ),
        ],
      ),
    );
  }
}
