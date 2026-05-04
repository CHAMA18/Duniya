import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'language_changer_model.dart';
export 'language_changer_model.dart';

class LanguageChangerWidget extends StatefulWidget {
  const LanguageChangerWidget({super.key});

  @override
  State<LanguageChangerWidget> createState() => _LanguageChangerWidgetState();
}

class _LanguageChangerWidgetState extends State<LanguageChangerWidget> {
  late LanguageChangerModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LanguageChangerModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
          child: Text(
            FFLocalizations.of(context).getText(
              '90dby9l7' /* Select application language */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).headlineMediumFamily,
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).headlineMediumIsCustom,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
          child: Container(
            width: 400.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_u24camys_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'af');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-south-africa.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'ewsnq01d' /* Afrikaans */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_q97onkvw_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'hi');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-india.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'w18jjsjh' /* Hindi */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_e7da2q2v_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'en');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-united-kingdom.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              '0g7h34nl' /* English */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_iibwrycm_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'es');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-spain.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'ez0dqjah' /* Espanyol  */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_rwjxs82j_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'it');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-italy.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'enw2h8yg' /* Italian */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        logFirebaseEvent(
                            'LANGUAGE_CHANGER_Row_9y2z3c6j_ON_TAP');
                        logFirebaseEvent('Row_set_app_language');
                        setAppLanguage(context, 'it');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/twemoji_flag-france.png',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'hnqzhl7j' /* French */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ].divide(SizedBox(width: 20.0)),
                      ),
                    ),
                  ].divide(SizedBox(height: 10.0)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
