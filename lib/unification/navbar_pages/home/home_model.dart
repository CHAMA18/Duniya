import '/backend/backend.dart';
import '/components/hr_table_widget.dart';
import '/components/pharma_table_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  String currentPageLink = '';
  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Stores action output result for [Firestore Query - Query a collection] action in Column widget.
  StaffRecord? staff;
  // Stores action output result for [Backend Call - Read Document] action in Column widget.
  PharmacyRecord? pharm;
  // Model for hrTable component.
  late HrTableModel hrTableModel;
  // Model for pharmaTable component.
  late PharmaTableModel pharmaTableModel;
  // Model for SideNav component.
  late SideNavModel sideNavModel2;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    hrTableModel = createModel(context, () => HrTableModel());
    pharmaTableModel = createModel(context, () => PharmaTableModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    topNavModel.dispose();
    hrTableModel.dispose();
    pharmaTableModel.dispose();
    sideNavModel2.dispose();
  }
}
