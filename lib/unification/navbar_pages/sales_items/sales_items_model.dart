import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'sales_items_widget.dart' show SalesItemsWidget;
import 'package:flutter/material.dart';

class SalesItemsModel extends FlutterFlowModel<SalesItemsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<SaleitemRecord>? salesItems;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  FinanceRecord? finee;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  FinanceRecord? fineeCopy;
  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  SalesRecord? sale;
  // Model for SideNav component.
  late SideNavModel sideNavModel2;

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
