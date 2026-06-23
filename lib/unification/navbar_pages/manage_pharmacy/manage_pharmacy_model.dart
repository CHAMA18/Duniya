import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_model.dart';
import '/unification/components/side_nav/side_nav_model.dart';
import '/unification/components/top_nav/top_nav_model.dart';

class ManagePharmacyModel extends FlutterFlowModel {
  /// State fields for the ManagePharmacy page
  late SideNavModel sideNavModel1;
  late SideNavModel sideNavModel2;
  late TopNavModel topNavModel;

  /// Active tab index (0-5)
  int activeTabIndex = 0;

  /// Search query
  String searchQuery = '';

  /// Sort field
  String sortBy = 'newest';

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
  }
}
