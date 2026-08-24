import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'expiry_tracking_widget.dart' show ExpiryTrackingWidget;
import 'package:flutter/material.dart';

class ExpiryTrackingModel extends FlutterFlowModel<ExpiryTrackingWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component (desktop/tablet).
  late SideNavModel sideNavModel1;
  // Model for SideNav component (drawer/mobile).
  late SideNavModel sideNavModel2;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for SearchBar widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? searchValue;

  // State field(s) for Expiry Bucket dropdown filter.
  String? expiryBucketValue;
  FormFieldController<String>? expiryBucketValueController;

  // Sort column for the table.
  // NOTE: lowercase form is mandatory — the header cell generator does
  // `text.toLowerCase().replaceAll(' ', '')`, so 'Days Left' becomes
  // 'daysleft' (NOT 'daysLeft'). The switch case in the widget's sort
  // method must use the same lowercase form, otherwise the sort falls
  // through to the default branch and the active-sort highlight is
  // never shown for the Days Left column.
  String sortColumn = 'daysleft';
  // Sort direction: true = ascending (most urgent first).
  bool sortAscending = true;

  // Animated counter values for summary stat cards.
  // These are driven by AnimationController in the widget.
  int animatedExpired = 0;
  int animatedUnder30 = 0;
  int animated30to60 = 0;
  int animated60to90 = 0;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    expiryBucketValueController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchFocusNode?.dispose();
    searchTextController?.dispose();
  }
}
