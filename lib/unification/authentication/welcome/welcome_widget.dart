import '/auth/firebase_auth/auth_util.dart';
import '/rbac/rbac.dart';
import '/backend/backend.dart';
import '/components/loading_spinner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = '/welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late WelcomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Welcome'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('WELCOME_PAGE_Welcome_ON_INIT_STATE');
      final userReference = currentUserReference;
      if (userReference == null) return;

      // Resolve the user document before applying portal rules. Auth and
      // Firestore streams can complete on different frames.
      if (currentUserDocument?.reference.path != userReference.path) {
        currentUserDocument = await UserRecord.getDocumentOnce(userReference);
      }
      if (!mounted) return;

      if (AccessControl.isPulseUser(context)) {
        context.goNamedAuth(
          PulsePharmaciesWidget.routeName,
          context.mounted,
        );
        return;
      }

      if (!AccessControl.isOwner(context)) {
        if (currentUserDocument?.ownerRef == null) {
          logFirebaseEvent('Welcome_backend_call');
          // Orphaned account — no ownerRef.  Assign Owner role
          // so the user can create their first pharmacy, but also
          // set accountType to 'Pharmacy' for RBAC resolution.
          await currentUserReference!.update(createUserRecordData(
            role: 'Owner',
            accountType: 'Pharmacy',
          ));
          logFirebaseEvent('Welcome_auth');
          GoRouter.of(context).prepareAuthEvent();
          await authManager.signOut();
          GoRouter.of(context).clearRedirectLocation();

          logFirebaseEvent('Welcome_navigate_to');

          context.goNamedAuth(LoginUniWidget.routeName, context.mounted);

          return;
        } else {
          logFirebaseEvent('Welcome_navigate_to');
          context.goNamedAuth(HomeWidget.routeName, context.mounted);
          return;
        }
      } else {
        if (currentUserDisplayName == '') {
          logFirebaseEvent('Welcome_navigate_to');

          context.goNamedAuth(OnboardingUniWidget.routeName, context.mounted);

          return;
        }
        logFirebaseEvent('Welcome_firestore_query');
        _model.pharmacyCount = await queryPharmacyRecordCount(
          parent: currentUserReference,
        );
        if (_model.pharmacyCount == 0) {
          logFirebaseEvent('Welcome_navigate_to');

          context.pushNamedAuth(
              CreatePharmacyWidget.routeName, context.mounted);

          return;
        } else {
          logFirebaseEvent('Welcome_navigate_to');
          context.goNamedAuth(HomeWidget.routeName, context.mounted);
          return;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Title(
        title: 'Welcome',
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
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.loadingSpinnerModel,
                      updateCallback: () => safeSetState(() {}),
                      child: LoadingSpinnerWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
