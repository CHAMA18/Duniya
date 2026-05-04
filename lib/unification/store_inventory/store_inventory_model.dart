import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/tool_button/tool_button_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/index.dart';
import 'store_inventory_widget.dart' show StoreInventoryWidget;
import 'package:flutter/material.dart';

class StoreInventoryModel extends FlutterFlowModel<StoreInventoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel1;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Firestore Query - Query a collection] action in DropDown widget.
  StockRecord? drug;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel1;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff1;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm1;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel2;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff2;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm2;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel3;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff3;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm3;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel4;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff4;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm4;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel5;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff5;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm5;
  // Model for ToolButton component.
  late ToolButtonModel toolButtonModel6;
  // Stores action output result for [Firestore Query - Query a collection] action in ToolButton widget.
  StaffRecord? staff;
  // Stores action output result for [Backend Call - Read Document] action in ToolButton widget.
  PharmacyRecord? pharm;
  // Model for SideNav component.
  late SideNavModel sideNavModel2;

  @override
  void initState(BuildContext context) {
    sideNavModel1 = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    toolButtonModel1 = createModel(context, () => ToolButtonModel());
    toolButtonModel2 = createModel(context, () => ToolButtonModel());
    toolButtonModel3 = createModel(context, () => ToolButtonModel());
    toolButtonModel4 = createModel(context, () => ToolButtonModel());
    toolButtonModel5 = createModel(context, () => ToolButtonModel());
    toolButtonModel6 = createModel(context, () => ToolButtonModel());
    sideNavModel2 = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    sideNavModel1.dispose();
    topNavModel.dispose();
    toolButtonModel1.dispose();
    toolButtonModel2.dispose();
    toolButtonModel3.dispose();
    toolButtonModel4.dispose();
    toolButtonModel5.dispose();
    toolButtonModel6.dispose();
    sideNavModel2.dispose();
  }
}
