import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/cart/cart_widget.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/index.dart';
import 'point_of_sales_widget.dart' show PointOfSalesWidget;
import 'package:flutter/material.dart';

class PointOfSalesModel extends FlutterFlowModel<PointOfSalesWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in PointOfSales widget.
  PharmacyRecord? pharmCopy2;
  // State field(s) for PharmacyDropDown widget.
  String? pharmacyDropDownValue;
  FormFieldController<String>? pharmacyDropDownValueController;
  List<PharmacyRecord>? pharmacyDropDownPreviousSnapshot;
  // Stores action output result for [Firestore Query - Query a collection] action in PharmacyDropDown widget.
  PharmacyRecord? pharm;
  // Stores action output result for [Firestore Query - Query a collection] action in PharmacyDropDown widget.
  PharmacyRecord? pharmCopy;
  // Model for Cart component.
  late CartModel cartModel;
  // Model for SideNav component.
  late SideNavModel sideNavModel;

  @override
  void initState(BuildContext context) {
    cartModel = createModel(context, () => CartModel());
    sideNavModel = createModel(context, () => SideNavModel());
  }

  @override
  void dispose() {
    cartModel.dispose();
    sideNavModel.dispose();
  }
}
