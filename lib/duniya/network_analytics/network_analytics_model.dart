import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'network_analytics_widget.dart' show NetworkAnalyticsWidget;
import 'package:flutter/material.dart';

/// Model for the Duniya Network Analytics dashboard.
///
/// Holds the [SideNavModel], [TopNavModel], and [MobileNavbarModel] used by the
/// page chrome. All aggregate KPIs are computed reactively inside the widget's
/// build method via StreamBuilder / FutureBuilder chains, so the model only
/// manages the navigation components.
class NetworkAnalyticsModel extends FlutterFlowModel<NetworkAnalyticsWidget> {
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
