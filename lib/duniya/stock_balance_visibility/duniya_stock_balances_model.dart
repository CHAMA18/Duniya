import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'duniya_stock_balances_widget.dart' show DuniyaStockBalancesWidget;
import 'package:flutter/material.dart';

class DuniyaStockBalancesModel
    extends FlutterFlowModel<DuniyaStockBalancesWidget> {
  late SideNavModel sideNavModel;
  late TopNavModel topNavModel;
  late MobileNavbarModel mobileNavbarModel;

  String? pharmacyFilter;
  FormFieldController<String>? pharmacyFilterController;

  String? searchValue;
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;

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
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
