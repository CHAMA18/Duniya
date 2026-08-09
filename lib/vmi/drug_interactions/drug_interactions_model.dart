import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'drug_interactions_widget.dart' show DrugInteractionsWidget;
import 'package:flutter/material.dart';

class DrugInteractionsModel extends FlutterFlowModel<DrugInteractionsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component (desktop/tablet).
  late SideNavModel sideNavModel1;
  // Model for SideNav component (drawer/mobile).
  late SideNavModel sideNavModel2;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for Drug A search.
  FocusNode? drugAFocusNode;
  TextEditingController? drugATextController;
  String? drugAValue;

  // State field(s) for Drug B search.
  FocusNode? drugBFocusNode;
  TextEditingController? drugBTextController;
  String? drugBValue;

  // State field(s) for Recent Alerts search/filter.
  FocusNode? alertSearchFocusNode;
  TextEditingController? alertSearchTextController;
  String? alertSearchValue;

  // Selected severity filter.
  String? severityFilterValue;
  FormFieldController<String>? severityFilterController;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    severityFilterController = FormFieldController<String>(null);
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    sideNavModel2.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    drugAFocusNode?.dispose();
    drugATextController?.dispose();
    drugBFocusNode?.dispose();
    drugBTextController?.dispose();
    alertSearchFocusNode?.dispose();
    alertSearchTextController?.dispose();
  }
}
