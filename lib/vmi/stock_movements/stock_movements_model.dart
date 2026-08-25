import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'stock_movements_widget.dart' show StockMovementsWidget;
import 'package:flutter/material.dart';

class StockMovementsModel extends FlutterFlowModel<StockMovementsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for MovementType dropdown.
  String? movementTypeValue;
  FormFieldController<String>? movementTypeValueController;

  // State field(s) for Pharmacy dropdown.
  String? pharmacyValue;
  FormFieldController<String>? pharmacyValueController;

  // State field(s) for DateRange filter.
  DateTime? startDate;
  DateTime? endDate;

  // State field(s) for pagination.
  int? currentPage;

  // State field(s) for Add Movement dialog.
  String? dialogProductValue;
  FormFieldController<String>? dialogProductValueController;
  FocusNode? dialogQtyFocusNode;
  TextEditingController? dialogQtyTextController;
  String? dialogMovementTypeValue;
  FormFieldController<String>? dialogMovementTypeValueController;
  FocusNode? dialogReasonFocusNode;
  TextEditingController? dialogReasonTextController;
  FocusNode? dialogReferenceFocusNode;
  TextEditingController? dialogReferenceTextController;
  // Transfer route — where the stock came FROM and where it went.
  // Populated when the movement type is TRANSFERRED (from + to) or
  // RECEIVED (supplier origin), stored into the movement reason as
  // "From X to Y" / "From X" so the ledger answers routing questions.
  FocusNode? dialogFromFocusNode;
  TextEditingController? dialogFromTextController;
  FocusNode? dialogToFocusNode;
  TextEditingController? dialogToTextController;

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
    dialogQtyFocusNode?.dispose();
    dialogQtyTextController?.dispose();
    dialogReasonFocusNode?.dispose();
    dialogReasonTextController?.dispose();
    dialogReferenceFocusNode?.dispose();
    dialogReferenceTextController?.dispose();
    dialogFromFocusNode?.dispose();
    dialogFromTextController?.dispose();
    dialogToFocusNode?.dispose();
    dialogToTextController?.dispose();
  }
}
