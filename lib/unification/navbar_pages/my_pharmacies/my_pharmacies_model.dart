import '/components/pharma_table_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'my_pharmacies_widget.dart' show MyPharmaciesWidget;
import 'package:flutter/material.dart';

class MyPharmaciesModel extends FlutterFlowModel<MyPharmaciesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for pharmaTable component.
  late PharmaTableModel pharmaTableModel;
  // Model for SideNav component.
  late SideNavModel sideNavModel2;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    pharmaTableModel = createModel(context, () => PharmaTableModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    topNavModel.dispose();
    pharmaTableModel.dispose();
    sideNavModel2.dispose();
  }
}
