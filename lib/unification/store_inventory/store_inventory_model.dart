import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'store_inventory_widget.dart' show StoreInventoryWidget;
import 'package:flutter/material.dart';

class StoreInventoryModel extends FlutterFlowModel<StoreInventoryWidget> {
  /// State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for SideNav (drawer) component.
  late SideNavModel sideNavModel2;

  // Filter state
  String selectedCategory = 'All Categories';
  String sortBy = 'Stock Level (Low to High)';

  // Search state
  String searchQuery = '';

  // Pagination state
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    topNavModel.dispose();
    sideNavModel2.dispose();
  }
}
