import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'duniya_pharmacies_widget.dart' show DuniyaPharmaciesWidget;
import 'package:flutter/material.dart';

/// Model for the Duniya Pharmacies listing page.
///
/// Holds the [SideNavModel], [TopNavModel], and [MobileNavbarModel] used by the
/// page chrome, plus the search field state used to filter the pharmacy list.
class DuniyaPharmaciesModel extends FlutterFlowModel<DuniyaPharmaciesWidget> {
  late SideNavModel sideNavModel;
  late TopNavModel topNavModel;
  late MobileNavbarModel mobileNavbarModel;

  /// Current search query (kept in sync with [searchTextController]).
  String? searchValue;

  /// Focus node for the search text field.
  FocusNode? searchFocusNode;

  /// Controller backing the search text field.
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
