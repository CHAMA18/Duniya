import '/flutter_flow/flutter_flow_util.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'purchase_orders_widget.dart' show PurchaseOrdersWidget;
import 'package:flutter/material.dart';

class PurchaseOrdersModel extends FlutterFlowModel<PurchaseOrdersWidget> {
  /// State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // Search field
  TextEditingController? searchTextController;
  FocusNode? searchFocusNode;

  // Create PO form fields
  TextEditingController? poSupplierController;
  FocusNode? poSupplierFocusNode;
  TextEditingController? poNotesController;
  FocusNode? poNotesFocusNode;

  // Line item quantity / price controllers (managed dynamically)
  List<TextEditingController> lineQtyControllers = [];
  List<TextEditingController> linePriceControllers = [];

  @override
  void initState(BuildContext context) {
    sideNavModel = createModel(context, () => SideNavModel());
    topNavModel = createModel(context, () => TopNavModel());
    mobileNavbarModel = createModel(context, () => MobileNavbarModel());
    searchTextController ??= TextEditingController();
    searchFocusNode ??= FocusNode();
    poSupplierController ??= TextEditingController();
    poSupplierFocusNode ??= FocusNode();
    poNotesController ??= TextEditingController();
    poNotesFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    sideNavModel.dispose();
    topNavModel.dispose();
    mobileNavbarModel.dispose();
    searchTextController?.dispose();
    searchFocusNode?.dispose();
    poSupplierController?.dispose();
    poSupplierFocusNode?.dispose();
    poNotesController?.dispose();
    poNotesFocusNode?.dispose();
    for (final c in lineQtyControllers) {
      c.dispose();
    }
    for (final c in linePriceControllers) {
      c.dispose();
    }
    lineQtyControllers.clear();
    linePriceControllers.clear();
  }
}
