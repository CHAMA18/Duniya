/// ─────────────────────────────────────────────────────────────────────
/// Pulse RBAC — Permission Definitions
/// ─────────────────────────────────────────────────────────────────────
/// Every granular action in the system is represented as a Permission
/// enum value. This is the single source of truth for what actions exist.
///
/// Naming convention: <domain>.<action>
///   domain  — the feature area (pos, inventory, finance, hr, etc.)
///   action  — the operation (view, create, edit, delete, approve, etc.)
///
/// When adding a new feature, add its permissions here first, then
/// assign them to the appropriate roles in role_config.dart.
/// ─────────────────────────────────────────────────────────────────────
enum Permission {
  // ─── Point of Sale ────────────────────────────────────────────────
  posView,
  posCreateSale,
  posEditSale,
  posDeleteSale,
  posApplyDiscount,
  posVoidTransaction,

  // ─── Inventory Management ─────────────────────────────────────────
  inventoryView,
  inventoryCreate,
  inventoryEdit,
  inventoryDelete,
  inventoryImport,
  inventoryExport,

  // ─── Product Catalogue ────────────────────────────────────────────
  catalogueView,
  catalogueCreate,
  catalogueEdit,
  catalogueDelete,

  // ─── Stock Management ─────────────────────────────────────────────
  stockBalancesView,
  stockMovementsView,
  stockCountsView,
  stockCountsCreate,
  stockCountsEdit,
  stockCountsApprove,
  stockCountsDelete,

  // ─── Goods Received ───────────────────────────────────────────────
  goodsReceivedView,
  goodsReceivedCreate,
  goodsReceivedEdit,
  goodsReceivedDelete,

  // ─── Batch & Expiry ───────────────────────────────────────────────
  batchesView,
  batchesEdit,

  // ─── Low Stock Alerts ─────────────────────────────────────────────
  lowStockAlertsView,
  lowStockAlertsManage,

  // ─── Replenishment ────────────────────────────────────────────────
  replenishmentView,
  replenishmentCreate,
  replenishmentApprove,

  // ─── Human Resource ───────────────────────────────────────────────
  hrView,
  hrCreateStaff,
  hrEditStaff,
  hrDeleteStaff,
  hrAssignRoles,
  hrViewStaffDetails,

  // ─── Finances ─────────────────────────────────────────────────────
  financesView,
  financesViewReports,
  financesManageSubscriptions,
  financesViewBilling,

  // ─── My Pharmacies ────────────────────────────────────────────────
  pharmaciesView,
  pharmaciesCreate,
  pharmaciesEdit,
  pharmaciesDelete,

  // ─── Pending Approvals ────────────────────────────────────────────
  pendingApprovalsView,
  pendingApprovalsApprove,
  pendingApprovalsReject,

  // ─── Sales / Dispensing ───────────────────────────────────────────
  salesView,
  salesCreate,
  salesEdit,
  salesDelete,

  // ─── Pharmacy Tools ───────────────────────────────────────────────
  pharmacyToolsView,
  aiAssistantUse,
  bmiCalculatorUse,

  // ─── Settings ─────────────────────────────────────────────────────
  settingsView,
  settingsManage,

  // ─── Duniya Network ───────────────────────────────────────────────
  duniyaPharmaciesView,
  duniyaStockBalancesView,
  duniyaOnboardingView,
  duniyaNetworkAnalyticsView,
  duniyaApprovePharmacies,

  // ─── Dashboard ────────────────────────────────────────────────────
  dashboardViewOwnerMetrics,
  dashboardViewFinanceNetwork,
  dashboardViewSalesAnalytics,
  dashboardViewInventoryMix,

  // ─── Damaged Stock ────────────────────────────────────────────────
  damagedStockView,
  damagedStockCreate,
  damagedStockEdit,
  damagedStockDelete,

  // ─── Audit Logs ──────────────────────────────────────────────────
  auditLogsView,
  auditLogsExport,

  // ─── Notifications ────────────────────────────────────────────────
  notificationsView,

  // ─── Drug Interaction Alerts ──────────────────────────────────────
  drugInteractionsView,
  drugInteractionsCheck,
  drugInteractionsManageRules,

  // ─── Expiry Tracking ─────────────────────────────────────────────
  expiryTrackingView,
  expiryTrackingExport,

  // ─── Purchase Orders ─────────────────────────────────────────────
  purchaseOrdersView,
  purchaseOrdersCreate,
  purchaseOrdersEdit,
  purchaseOrdersApprove,
  purchaseOrdersDelete,

  // ─── Digital Prescriptions ────────────────────────────────────────
  prescriptionsView,
  prescriptionsCreate,
  prescriptionsVerify,
  prescriptionsFulfill,

  // ─── Insurance / Claims ───────────────────────────────────────────
  insuranceView,
  insuranceSubmitClaim,
  insuranceVerifyMember,

  // ─── Cold Chain Monitoring ────────────────────────────────────────
  coldChainView,
  coldChainManageSensors,
  coldChainViewAlerts,

  // ─── Patient Medication Records ───────────────────────────────────
  patientRecordsView,
  patientRecordsCreate,
  patientRecordsEdit,
  patientRecordsViewHistory,
}
