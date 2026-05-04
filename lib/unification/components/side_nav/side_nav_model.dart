import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/sidebar_link/sidebar_link_widget.dart';
import 'side_nav_widget.dart' show SideNavWidget;
import 'package:flutter/material.dart';

class SideNavModel extends FlutterFlowModel<SideNavWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel1;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel2;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel3;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel4;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel5;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel6;
  // Model for SidebarLink component.
  late SidebarLinkModel sidebarLinkModel7;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue;

  @override
  void initState(BuildContext context) {
    sidebarLinkModel1 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel2 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel3 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel4 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel5 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel6 = createModel(context, () => SidebarLinkModel());
    sidebarLinkModel7 = createModel(context, () => SidebarLinkModel());
  }

  @override
  void dispose() {
    sidebarLinkModel1.dispose();
    sidebarLinkModel2.dispose();
    sidebarLinkModel3.dispose();
    sidebarLinkModel4.dispose();
    sidebarLinkModel5.dispose();
    sidebarLinkModel6.dispose();
    sidebarLinkModel7.dispose();
  }
}
