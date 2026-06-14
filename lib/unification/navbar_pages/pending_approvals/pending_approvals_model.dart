import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_model.dart';
import '/unification/components/top_nav/top_nav_model.dart';
import 'pending_approvals_widget.dart' show PendingApprovalsWidget;
import 'package:flutter/material.dart';

class PendingApprovalsModel extends FlutterFlowModel<PendingApprovalsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
  }
}
