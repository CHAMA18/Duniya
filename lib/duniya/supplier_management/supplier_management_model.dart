import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'supplier_management_widget.dart'
    show SupplierManagementWidget, SupplierDisplay;

/// ═══════════════════════════════════════════════════════════════
///   SupplierManagementModel
///
///   Page-level model — instantiates the side-nav model and any
///   shared state. Dialog-level form state is encapsulated in the
///   `forDialog()` factory below.
/// ═══════════════════════════════════════════════════════════════

class SupplierManagementModel
    extends FlutterFlowModel<SupplierManagementWidget> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Construct a model for use inside the Add / Edit dialog.
  /// If `existing` is null, all fields start empty (Add mode).
  /// Otherwise the controllers are prefilled from the existing
  /// `SupplierDisplay` (Edit mode).
  factory SupplierManagementModel.forDialog({
    SupplierDisplay? existing,
  }) {
    final m = SupplierManagementModel._();
    m.nameController =
        TextEditingController(text: existing?.name ?? '');
    m.contactNameController =
        TextEditingController(text: existing?.contactName ?? '');
    m.emailController =
        TextEditingController(text: existing?.email ?? '');
    m.phoneController =
        TextEditingController(text: existing?.phone ?? '');
    m.addressController =
        TextEditingController(text: existing?.address ?? '');
    m.cityController =
        TextEditingController(text: existing?.city ?? '');
    m.countryController =
        TextEditingController(text: existing?.country ?? '');
    m.taxIdController =
        TextEditingController(text: existing?.taxId ?? '');
    m.websiteController =
        TextEditingController(text: existing?.website ?? '');
    m.bankController =
        TextEditingController(text: existing?.bankAccount ?? '');
    m.notesController =
        TextEditingController(text: existing?.notes ?? '');
    m.leadTimeController = TextEditingController(
        text: existing == null
            ? ''
            : (existing.leadTimeDays > 0
                ? existing.leadTimeDays.toString()
                : ''));
    m.categoryValue = existing?.category;
    m.paymentTermsValue = existing?.paymentTerms;
    m.statusValue = existing?.status ?? 'active';
    m.existing = existing;
    return m;
  }

  SupplierManagementModel._();

  // Form controllers (only used inside the dialog, but kept here
  // so the dialog state can live outside `setState` of the dialog
  // widget if needed).
  late TextEditingController nameController;
  late TextEditingController contactNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController countryController;
  late TextEditingController taxIdController;
  late TextEditingController websiteController;
  late TextEditingController bankController;
  late TextEditingController notesController;
  late TextEditingController leadTimeController;

  String? categoryValue;
  String? paymentTermsValue;
  String statusValue = 'active';
  SupplierDisplay? existing;

  void disposeDialog() {
    nameController.dispose();
    contactNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    taxIdController.dispose();
    websiteController.dispose();
    bankController.dispose();
    notesController.dispose();
    leadTimeController.dispose();
  }
}
