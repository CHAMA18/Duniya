import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'onboarding_requests_widget.dart' show OnboardingRequestsWidget;
import 'package:flutter/material.dart';

/// Model for the Duniya Onboarding Requests page.
///
/// Holds the [SideNavModel], [TopNavModel], and [MobileNavbarModel] used by the
/// page chrome. The page itself fetches pending pharmacies reactively, so the
/// model only needs to manage the navigation components.
class OnboardingRequestsModel extends FlutterFlowModel<OnboardingRequestsWidget> {
  late SideNavModel sideNavModel;
  late TopNavModel topNavModel;
  late MobileNavbarModel mobileNavbarModel;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
  }
}
