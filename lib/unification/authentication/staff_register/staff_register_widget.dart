import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'staff_register_model.dart';
export 'staff_register_model.dart';

class StaffRegisterWidget extends StatefulWidget {
  const StaffRegisterWidget({
    super.key,
    required this.staffId,
  });

  final DocumentReference? staffId;

  static String routeName = 'StaffRegister';
  static String routePath = '/staffRegister';

  @override
  State<StaffRegisterWidget> createState() => _StaffRegisterWidgetState();
}

class _StaffRegisterWidgetState extends State<StaffRegisterWidget> {
  late StaffRegisterModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StaffRegisterModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'StaffRegister'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('STAFF_REGISTER_StaffRegister_ON_INIT_STA');
      logFirebaseEvent('StaffRegister_backend_call');
      _model.staff = await StaffRecord.getDocumentOnce(widget.staffId!);
      logFirebaseEvent('StaffRegister_set_form_field');
      safeSetState(() {
        _model.emailTextController?.text = _model.staff!.email;
      });
      logFirebaseEvent('StaffRegister_set_form_field');
      safeSetState(() {
        _model.passwordTextController?.text = _model.staff!.password;
      });
      logFirebaseEvent('StaffRegister_auth');
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.createAccountWithEmail(
        context,
        _model.emailTextController.text,
        _model.passwordTextController.text,
      );
      if (user == null) {
        return;
      }

      await UserRecord.collection.doc(user.uid).update(createUserRecordData(
            createdTime: getCurrentTimestamp,
            role: 'Owner',
          ));

      if (!loggedIn) {
        logFirebaseEvent('StaffRegister_alert_dialog');
        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: AlertDialog(
                title: Text('Error Try Again'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext),
                    child: Text('Ok'),
                  ),
                ],
              ),
            );
          },
        );
        logFirebaseEvent('StaffRegister_navigate_to');

        context.goNamedAuth(LoginUniWidget.routeName, context.mounted);

        return;
      }
      logFirebaseEvent('StaffRegister_backend_call');

      await currentUserReference!.update(createUserRecordData(
        displayName: _model.staff?.name,
        email: _model.staff?.email,
        phoneNumber: _model.staff?.phone,
        role: _model.staff?.role,
        ownerRef: _model.staff?.ownerRef,
      ));
      await authManager.sendEmailVerification();
      await _showEmailVerificationSentDialog(_model.emailTextController.text);
      await authManager.signOut();
      if (!context.mounted) {
        return;
      }
      context.goNamed(LoginUniWidget.routeName);
    });

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _showEmailVerificationSentDialog(String email) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return WebViewAware(
          child: AlertDialog(
            title: const Text('Verify your email'),
            content: Text(
              'We sent a verification email to $email. Please verify your inbox before logging in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Title(
        title: 'StaffRegistration',
        color: FlutterFlowTheme.of(context).primary.withAlpha(0XFF),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            body: SafeArea(
              top: true,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200.0,
                        child: Visibility(
                          visible: widget.staffId == null,
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: TextFormField(
                              controller: _model.emailTextController,
                              focusNode: _model.emailFocusNode,
                              autofocus: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: FFLocalizations.of(context).getText(
                                  'wbt5ruz5' /* Label here... */,
                                ),
                                labelStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelMediumIsCustom,
                                    ),
                                hintStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelMediumIsCustom,
                                    ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedErrorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodyMediumFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodyMediumIsCustom,
                                  ),
                              validator: _model.emailTextControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: wrapWithModel(
                          model: _model.loadingSpinnerModel,
                          updateCallback: () => safeSetState(() {}),
                          child: LoadingSpinnerWidget(),
                        ),
                      ),
                    ],
                  ),
                  if (widget.staffId == null)
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                        child: TextFormField(
                          controller: _model.passwordTextController,
                          focusNode: _model.passwordFocusNode,
                          autofocus: true,
                          obscureText: !_model.passwordVisibility,
                          decoration: InputDecoration(
                            labelText: FFLocalizations.of(context).getText(
                              'vsa0k43n' /* Label here... */,
                            ),
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelMediumIsCustom,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .labelMediumFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .labelMediumIsCustom,
                                ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            suffixIcon: InkWell(
                              onTap: () async {
                                safeSetState(() => _model.passwordVisibility =
                                    !_model.passwordVisibility);
                              },
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 22,
                              ),
                            ),
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                          validator: _model.passwordTextControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
