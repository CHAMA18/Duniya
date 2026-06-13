import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/unification/components/side_nav/side_nav_widget.dart';
import '/unification/components/top_nav/top_nav_widget.dart';
import '/unification/components/mobile_navbar/mobile_navbar_widget.dart';
import 'product_master_widget.dart' show ProductMasterWidget;
import 'package:flutter/material.dart';

class ProductMasterModel extends FlutterFlowModel<ProductMasterWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SideNav component.
  late SideNavModel sideNavModel;
  // Model for TopNav component.
  late TopNavModel topNavModel;
  // Model for MobileNavbar component.
  late MobileNavbarModel mobileNavbarModel;

  // State field(s) for SearchBar widget.
  FocusNode? searchFocusNode;
  TextEditingController? searchTextController;
  String? searchValue;
  String? Function(BuildContext, String?)? searchTextControllerValidator;

  // State field(s) for Category dropdown.
  String? categoryValue;
  FormFieldController<String>? categoryValueController;

  // Dialog form fields
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  FocusNode? genericNameFocusNode;
  TextEditingController? genericNameTextController;
  FocusNode? brandNameFocusNode;
  TextEditingController? brandNameTextController;
  FocusNode? strengthFocusNode;
  TextEditingController? strengthTextController;
  FocusNode? dosageFormFocusNode;
  TextEditingController? dosageFormTextController;
  FocusNode? packSizeFocusNode;
  TextEditingController? packSizeTextController;
  FocusNode? skuFocusNode;
  TextEditingController? skuTextController;
  String? dialogCategoryValue;
  FormFieldController<String>? dialogCategoryValueController;
  FocusNode? costPriceFocusNode;
  TextEditingController? costPriceTextController;
  FocusNode? sellingPriceFocusNode;
  TextEditingController? sellingPriceTextController;
  FocusNode? minStockFocusNode;
  TextEditingController? minStockTextController;
  FocusNode? reorderLevelFocusNode;
  TextEditingController? reorderLevelTextController;

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
    nameFocusNode?.dispose();
    nameTextController?.dispose();
    genericNameFocusNode?.dispose();
    genericNameTextController?.dispose();
    brandNameFocusNode?.dispose();
    brandNameTextController?.dispose();
    strengthFocusNode?.dispose();
    strengthTextController?.dispose();
    dosageFormFocusNode?.dispose();
    dosageFormTextController?.dispose();
    packSizeFocusNode?.dispose();
    packSizeTextController?.dispose();
    skuFocusNode?.dispose();
    skuTextController?.dispose();
    costPriceFocusNode?.dispose();
    costPriceTextController?.dispose();
    sellingPriceFocusNode?.dispose();
    sellingPriceTextController?.dispose();
    minStockFocusNode?.dispose();
    minStockTextController?.dispose();
    reorderLevelFocusNode?.dispose();
    reorderLevelTextController?.dispose();
  }
}
