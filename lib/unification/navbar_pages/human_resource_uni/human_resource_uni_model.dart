import '/components/hr_table_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'human_resource_uni_widget.dart' show HumanResourceUniWidget;
import 'package:flutter/material.dart';

class HumanResourceUniModel extends FlutterFlowModel<HumanResourceUniWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for hrTable component.
  late HrTableModel hrTableModel;
  // Model for SideNav component.
  late SideNavModel sideNavModel2;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    hrTableModel = createModel(context, () => HrTableModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    topNavModel.dispose();
    hrTableModel.dispose();
    sideNavModel2.dispose();
  }
}
