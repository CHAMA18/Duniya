/// ─────────────────────────────────────────────────────────────────────
/// Pulse RBAC — Role Configuration (Permission Matrix)
/// ─────────────────────────────────────────────────────────────────────
/// This is the CENTRAL permission matrix. Every role-permission mapping
/// is defined here. No other file should hardcode role-permission logic.
///
/// STRICT RBAC RULES:
///   - Pharmacy users see Store Inventory (never Product Catalogue)
///   - Pulse users see Product Catalogue (never Store Inventory)
///   - Store Inventory and Product Catalogue NEVER appear simultaneously
///   - Hiding a nav item is NOT sufficient security — enforce in widgets
///   - Principle of least privilege: roles start with minimal permissions
///
/// Last updated: 2026-08-19 — strict compliance with Pulse RBAC spec.
/// ─────────────────────────────────────────────────────────────────────
library;

import 'permissions.dart';
import 'roles.dart';

/// Maps each AppRole to its set of granted permissions.
/// This is the single source of truth for the entire RBAC system.
final Map<AppRole, Set<Permission>> rolePermissions = {
  // ═══════════════════════════════════════════════════════════════════
  // PHARMACY OWNER — Full administrative access
  // Main: Home, My Pharmacies, Human Resource, Finances, Pending Approvals
  // ═══════════════════════════════════════════════════════════════════
  AppRole.owner: {
    // ── Main ──
    Permission.pharmaciesView,
    Permission.pharmaciesCreate,
    Permission.pharmaciesEdit,
    Permission.pharmaciesDelete,
    Permission.hrView,
    Permission.hrCreateStaff,
    Permission.hrEditStaff,
    Permission.hrDeleteStaff,
    Permission.hrAssignRoles,
    Permission.hrViewStaffDetails,
    Permission.financesView,
    Permission.financesViewReports,
    Permission.financesManageSubscriptions,
    Permission.financesViewBilling,
    Permission.pendingApprovalsView,
    Permission.pendingApprovalsApprove,
    Permission.pendingApprovalsReject,

    // ── Inventory ──
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,
    Permission.inventoryDelete,
    Permission.inventoryImport,
    Permission.inventoryExport,

    // ── Stock ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,
    Permission.stockCountsApprove,
    Permission.stockCountsDelete,

    // ── Operations ──
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.goodsReceivedEdit,
    Permission.goodsReceivedDelete,
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,
    Permission.salesDelete,
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posDeleteSale,
    Permission.posApplyDiscount,
    Permission.posVoidTransaction,

    // ── Monitoring ──
    Permission.batchesView,
    Permission.batchesEdit,
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,
    Permission.replenishmentView,
    Permission.replenishmentCreate,
    Permission.replenishmentApprove,
    Permission.coldChainView,
    Permission.coldChainManageSensors,
    Permission.coldChainViewAlerts,
    Permission.expiryTrackingView,
    Permission.expiryTrackingExport,

    // ── Clinical ──
    Permission.prescriptionsView,
    Permission.prescriptionsCreate,
    Permission.prescriptionsVerify,
    Permission.prescriptionsFulfill,
    Permission.insuranceView,
    Permission.insuranceSubmitClaim,
    Permission.insuranceVerifyMember,
    Permission.patientRecordsView,
    Permission.patientRecordsCreate,
    Permission.patientRecordsEdit,
    Permission.patientRecordsViewHistory,
    Permission.drugInteractionsView,
    Permission.drugInteractionsCheck,
    Permission.drugInteractionsManageRules,

    // ── Procurement ──
    Permission.purchaseOrdersView,
    Permission.purchaseOrdersCreate,
    Permission.purchaseOrdersEdit,
    Permission.purchaseOrdersApprove,
    Permission.purchaseOrdersDelete,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.auditLogsView,
    Permission.auditLogsExport,
    Permission.settingsView,
    Permission.settingsManage,

    // ── Dashboard ──
    Permission.dashboardViewOwnerMetrics,
    Permission.dashboardViewFinanceNetwork,
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,

    // ── Damaged Stock ──
    Permission.damagedStockView,
    Permission.damagedStockCreate,
    Permission.damagedStockEdit,
    Permission.damagedStockDelete,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PHARMACY MANAGER — Manages pharmacy operations & staff
  // Main: Home, Human Resource, Finances
  // NO: My Pharmacies, Pending Approvals
  // ═══════════════════════════════════════════════════════════════════
  AppRole.outletManager: {
    // ── Main ──
    Permission.hrView,
    Permission.hrCreateStaff,
    Permission.hrEditStaff,
    Permission.hrViewStaffDetails,
    Permission.financesView,
    Permission.financesViewReports,

    // ── Inventory ──
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,

    // ── Stock (all stock items) ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,
    Permission.stockCountsApprove,

    // ── Operations ──
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.goodsReceivedEdit,
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posDeleteSale,
    Permission.posApplyDiscount,
    Permission.posVoidTransaction,

    // ── Monitoring (all) ──
    Permission.batchesView,
    Permission.batchesEdit,
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,
    Permission.replenishmentView,
    Permission.replenishmentCreate,
    Permission.replenishmentApprove,
    Permission.coldChainView,
    Permission.coldChainManageSensors,
    Permission.coldChainViewAlerts,
    Permission.expiryTrackingView,
    Permission.expiryTrackingExport,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.auditLogsView,
    Permission.settingsView,

    // ── Dashboard ──
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,

    // ── Damaged Stock ──
    Permission.damagedStockView,
    Permission.damagedStockCreate,
    Permission.damagedStockEdit,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PHARMACIST — Clinical, dispensing, inventory, prescriptions
  // Main: Home only
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pharmacist: {
    // ── Inventory ──
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,

    // ── Stock (Balances, Movements, Counts) ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,

    // ── Operations ──
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posApplyDiscount,

    // ── Monitoring (Batches, Low Stock, Replenishment, Cold Chain) ──
    Permission.batchesView,
    Permission.lowStockAlertsView,
    Permission.replenishmentView,
    Permission.coldChainView,
    Permission.coldChainViewAlerts,
    Permission.expiryTrackingView,

    // ── Clinical (all clinical areas) ──
    Permission.prescriptionsView,
    Permission.prescriptionsCreate,
    Permission.prescriptionsVerify,
    Permission.prescriptionsFulfill,
    Permission.insuranceView,
    Permission.insuranceVerifyMember,
    Permission.patientRecordsView,
    Permission.patientRecordsCreate,
    Permission.patientRecordsEdit,
    Permission.patientRecordsViewHistory,
    Permission.drugInteractionsView,
    Permission.drugInteractionsCheck,

    // ── Procurement ──
    Permission.purchaseOrdersView,
    Permission.purchaseOrdersCreate,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.settingsView,

    // ── Dashboard ──
    Permission.dashboardViewSalesAnalytics,

    // ── Damaged Stock ──
    Permission.damagedStockView,
    Permission.damagedStockCreate,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PHARMACY TECHNICIAN — Inventory, receiving, stock, expiry
  // Main: Home only
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pharmacyTechnician: {
    // ── Inventory ──
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,

    // ── Stock (Balances, Movements, Counts) ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,

    // ── Operations ──
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,

    // ── Monitoring (all inventory monitoring, Cold Chain) ──
    Permission.batchesView,
    Permission.batchesEdit,
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,
    Permission.replenishmentView,
    Permission.replenishmentCreate,
    Permission.coldChainView,
    Permission.coldChainManageSensors,
    Permission.coldChainViewAlerts,
    Permission.expiryTrackingView,

    // ── Clinical (Patient Records read-only) ──
    Permission.patientRecordsView,

    // ── Procurement ──
    Permission.purchaseOrdersView,
    Permission.purchaseOrdersCreate,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.settingsView,

    // ── Damaged Stock ──
    Permission.damagedStockView,
    Permission.damagedStockCreate,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // CASHIER — POS, sales, basic inventory views
  // Main: Home only
  // ═══════════════════════════════════════════════════════════════════
  AppRole.cashier: {
    // ── Inventory (view only) ──
    Permission.inventoryView,

    // ── Stock (Balances, Movements — no Counts) ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,

    // ── Operations ──
    Permission.salesView,
    Permission.salesCreate,
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,

    // ── Monitoring (Batches, Low Stock — no Replenishment/Cold Chain) ──
    Permission.batchesView,
    Permission.lowStockAlertsView,

    // ── Clinical (Insurance verification, Drug Interactions read-only) ──
    Permission.insuranceView,
    Permission.insuranceVerifyMember,
    Permission.drugInteractionsView,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.settingsView,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // SALES ASSISTANT — POS, sales, read-only inventory
  // Main: Home only
  // ═══════════════════════════════════════════════════════════════════
  AppRole.salesAssistant: {
    // ── Inventory (view only) ──
    Permission.inventoryView,

    // ── Stock (Balances, Movements — no Counts) ──
    Permission.stockBalancesView,
    Permission.stockMovementsView,

    // ── Operations ──
    Permission.goodsReceivedView,
    Permission.salesView,
    Permission.salesCreate,
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,

    // ── Monitoring (Batches, Low Stock — no Replenishment/Cold Chain) ──
    Permission.batchesView,
    Permission.lowStockAlertsView,

    // ── Clinical (Insurance verification, Drug Interactions read-only) ──
    Permission.insuranceView,
    Permission.insuranceVerifyMember,
    Permission.drugInteractionsView,

    // ── Tools ──
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // ── Administration ──
    Permission.settingsView,

    // ── Notifications ──
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PULSE ADMIN — Full network administrative access
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pulseAdmin: {
    Permission.catalogueView,
    Permission.catalogueCreate,
    Permission.catalogueEdit,
    Permission.catalogueDelete,
    Permission.pulsePharmaciesView,
    Permission.pulseStockBalancesView,
    Permission.pulseOnboardingView,
    Permission.pulseNetworkAnalyticsView,
    Permission.pulseApprovePharmacies,
    Permission.pendingApprovalsView,
    Permission.pendingApprovalsApprove,
    Permission.pendingApprovalsReject,
    Permission.financesView,
    Permission.financesViewReports,
    Permission.financesManageSubscriptions,
    Permission.financesViewBilling,
    Permission.auditLogsView,
    Permission.auditLogsExport,
    Permission.userManagementView,
    Permission.userManagementManage,
    Permission.settingsView,
    Permission.settingsManage,
    Permission.notificationsView,
    Permission.dashboardViewOwnerMetrics,
    Permission.dashboardViewFinanceNetwork,
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.stockMovementsView,
    Permission.batchesView,
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,
    Permission.replenishmentView,
    Permission.replenishmentCreate,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PULSE STAFF — Operational staff within the Pulse network
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pulseStaff: {
    Permission.catalogueView,
    Permission.pulsePharmaciesView,
    Permission.pulseStockBalancesView,
    Permission.pulseOnboardingView,
    Permission.pendingApprovalsView,
    Permission.financesView,
    Permission.auditLogsView,
    Permission.settingsView,
    Permission.notificationsView,
    Permission.dashboardViewSalesAnalytics,
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.stockMovementsView,
    Permission.batchesView,
    Permission.lowStockAlertsView,
    Permission.replenishmentView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIBER — External user with limited read access
  // ═══════════════════════════════════════════════════════════════════
  AppRole.subscriber: {
    Permission.financesView,
    Permission.financesViewBilling,
    Permission.settingsView,
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // UNKNOWN — Minimal permissions (safety net)
  // ═══════════════════════════════════════════════════════════════════
  AppRole.unknown: {
    Permission.settingsView,
    Permission.notificationsView,
  },
};

/// ─────────────────────────────────────────────────────────────────────
/// Navigation visibility matrix — which NavItems each role can see
///
/// RULES:
///   - Pharmacy roles: Store Inventory ONLY (never Product Catalogue)
///   - Pulse roles: Product Catalogue ONLY (never Store Inventory)
///   - These are mutually exclusive by design
/// ─────────────────────────────────────────────────────────────────────
final Map<AppRole, Set<NavItem>> roleNavItems = {
  // ═══ Owner ═══
  // Main: Home, My Pharmacies, Human Resource, Finances, Pending Approvals
  // Inventory: Store Inventory
  // Stock: Balances, Movements, Counts
  // Operations: Goods Received, Sales/Dispensing, POS
  // Monitoring: Batches & Expiry, Low Stock, Replenishment, Cold Chain
  // Clinical: Prescriptions, Insurance, Patient Records, Drug Interactions
  // Procurement: Purchase Orders
  // Tools: AI Assistant, BMI Calculator
  // Admin: Audit Logs, Settings
  AppRole.owner: {
    NavItem.home,
    NavItem.myPharmacies,
    NavItem.humanResource,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.expiryTracking,
    NavItem.prescriptions,
    NavItem.insurance,
    NavItem.patientRecords,
    NavItem.drugInteractions,
    NavItem.purchaseOrders,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.auditLogs,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Pharmacy Manager ═══
  // Main: Home, Human Resource, Finances
  // Inventory: Store Inventory
  // Stock: All stock items
  // Operations: Goods Received, Sales/Dispensing, POS
  // Monitoring: All monitoring
  // Tools: AI Assistant, BMI Calculator
  // Admin: Audit Logs, Settings
  AppRole.outletManager: {
    NavItem.home,
    NavItem.humanResource,
    NavItem.finances,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.expiryTracking,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.auditLogs,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Pharmacist ═══
  // Main: Home
  // Inventory: Store Inventory
  // Stock: Balances, Movements, Counts
  // Operations: Goods Received, Sales/Dispensing, POS
  // Monitoring: Batches, Low Stock, Replenishment, Cold Chain
  // Clinical: All clinical areas
  // Procurement: Purchase Orders
  // Tools: AI Assistant, BMI Calculator
  AppRole.pharmacist: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.expiryTracking,
    NavItem.prescriptions,
    NavItem.insurance,
    NavItem.patientRecords,
    NavItem.drugInteractions,
    NavItem.purchaseOrders,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Pharmacy Technician ═══
  // Main: Home
  // Inventory: Store Inventory
  // Stock: Balances, Movements, Counts
  // Operations: Goods Received
  // Monitoring: All inventory monitoring, Cold Chain
  // Clinical: Patient Records read-only
  // Procurement: Purchase Orders
  // Tools: BMI Calculator
  AppRole.pharmacyTechnician: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.expiryTracking,
    NavItem.patientRecords,
    NavItem.purchaseOrders,
    NavItem.bmiCalculator,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Cashier ═══
  // Main: Home
  // Inventory: Store Inventory
  // Stock: Balances, Movements
  // Operations: Sales/Dispensing, POS
  // Monitoring: Batches, Low Stock
  // Clinical: Insurance verification, Drug Interactions read-only
  // Tools: BMI Calculator
  AppRole.cashier: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.insurance,
    NavItem.drugInteractions,
    NavItem.bmiCalculator,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Sales Assistant ═══
  // Main: Home
  // Inventory: Store Inventory
  // Stock: Balances, Movements
  // Operations: Sales/Dispensing, POS
  // Monitoring: Batches, Low Stock
  // Clinical: Insurance verification, Drug Interactions read-only
  // Tools: BMI Calculator
  AppRole.salesAssistant: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.insurance,
    NavItem.drugInteractions,
    NavItem.bmiCalculator,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Pulse Admin ═══
  // Full network visibility including cold chain, expiry tracking,
  // and AI assistant — added in the Week 1 sidebar expansion.
  AppRole.pulseAdmin: {
    NavItem.home,
    NavItem.productCatalogue,
    NavItem.goodsReceived,
    NavItem.stockMovements,
    NavItem.batchesExpiry,
    NavItem.expiryTracking,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.pulsePharmacies,
    NavItem.pulseStockBalances,
    NavItem.pulseOnboardingRequests,
    NavItem.pulseNetworkAnalytics,
    NavItem.pulseSupplierManagement,
    NavItem.auditLogs,
    NavItem.userManagement,
    NavItem.aiAssistant,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Pulse Staff ═══
  // Expanded with cold chain, expiry tracking, and AI assistant.
  AppRole.pulseStaff: {
    NavItem.home,
    NavItem.productCatalogue,
    NavItem.goodsReceived,
    NavItem.stockMovements,
    NavItem.batchesExpiry,
    NavItem.expiryTracking,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.coldChain,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.pulsePharmacies,
    NavItem.pulseStockBalances,
    NavItem.pulseOnboardingRequests,
    NavItem.pulseSupplierManagement,
    NavItem.auditLogs,
    NavItem.aiAssistant,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Subscriber ═══
  AppRole.subscriber: {
    NavItem.home,
    NavItem.finances,
    NavItem.salesAnalytics,
    NavItem.settings,
  },

  // ═══ Unknown ═══
  AppRole.unknown: {
    NavItem.home,
    NavItem.salesAnalytics,
    NavItem.settings,
  },
};
