/// ─────────────────────────────────────────────────────────────────────
/// Duniya RBAC — Role Configuration (Permission Matrix)
/// ─────────────────────────────────────────────────────────────────────
/// This is the CENTRAL permission matrix. Every role-permission mapping
/// is defined here. No other file should hardcode role-permission logic.
///
/// Design principles:
///   - Principle of least privilege: roles start with minimal permissions
///   - Owner has full pharmacy access; Duniya Admin has full network access
///   - Staff roles are scoped to their operational responsibilities
///   - Read permissions are generally granted more broadly than write
///   - Financial/HR permissions are restricted to Owner & Outlet Manager
///
/// To modify permissions for a role, edit ONLY this file.
/// ─────────────────────────────────────────────────────────────────────
library;

import 'permissions.dart';
import 'roles.dart';

/// Maps each AppRole to its set of granted permissions.
/// This is the single source of truth for the entire RBAC system.
final Map<AppRole, Set<Permission>> rolePermissions = {
  // ═══════════════════════════════════════════════════════════════════
  // PHARMACY OWNER — Full administrative access to their pharmacy
  // ═══════════════════════════════════════════════════════════════════
  AppRole.owner: {
    // POS — full access
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posDeleteSale,
    Permission.posApplyDiscount,
    Permission.posVoidTransaction,

    // Inventory — full access
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,
    Permission.inventoryDelete,
    Permission.inventoryImport,
    Permission.inventoryExport,

    // Product Catalogue — full access
    Permission.catalogueView,
    Permission.catalogueCreate,
    Permission.catalogueEdit,
    Permission.catalogueDelete,

    // Stock Management — full access
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,
    Permission.stockCountsApprove,
    Permission.stockCountsDelete,

    // Goods Received — full access
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.goodsReceivedEdit,
    Permission.goodsReceivedDelete,

    // Batch & Expiry
    Permission.batchesView,
    Permission.batchesEdit,

    // Low Stock Alerts
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,

    // Replenishment
    Permission.replenishmentView,
    Permission.replenishmentCreate,
    Permission.replenishmentApprove,

    // Outlets
    Permission.outletsView,
    Permission.outletsCreate,
    Permission.outletsEdit,
    Permission.outletsDelete,

    // HR — full access
    Permission.hrView,
    Permission.hrCreateStaff,
    Permission.hrEditStaff,
    Permission.hrDeleteStaff,
    Permission.hrAssignRoles,
    Permission.hrViewStaffDetails,

    // Finances — full access
    Permission.financesView,
    Permission.financesViewReports,
    Permission.financesManageSubscriptions,
    Permission.financesViewBilling,

    // My Pharmacies — full access
    Permission.pharmaciesView,
    Permission.pharmaciesCreate,
    Permission.pharmaciesEdit,
    Permission.pharmaciesDelete,

    // Pending Approvals
    Permission.pendingApprovalsView,
    Permission.pendingApprovalsApprove,
    Permission.pendingApprovalsReject,

    // Sales / Dispensing
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,
    Permission.salesDelete,

    // Pharmacy Tools
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,
    Permission.settingsManage,

    // Dashboard — full metrics
    Permission.dashboardViewOwnerMetrics,
    Permission.dashboardViewFinanceNetwork,
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,

    // Damaged Stock
    Permission.damagedStockView,
    Permission.damagedStockCreate,
    Permission.damagedStockEdit,
    Permission.damagedStockDelete,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // OUTLET MANAGER — Manages a specific outlet, can manage staff
  // ═══════════════════════════════════════════════════════════════════
  AppRole.outletManager: {
    // POS — full access
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posDeleteSale,
    Permission.posApplyDiscount,
    Permission.posVoidTransaction,

    // Inventory — view & edit, no delete/import/export
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,
    Permission.inventoryDelete,
    Permission.inventoryImport,

    // Product Catalogue — view & edit
    Permission.catalogueView,
    Permission.catalogueCreate,
    Permission.catalogueEdit,

    // Stock Management — view & create
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,
    Permission.stockCountsApprove,

    // Goods Received
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,
    Permission.goodsReceivedEdit,

    // Batch & Expiry
    Permission.batchesView,
    Permission.batchesEdit,

    // Low Stock Alerts
    Permission.lowStockAlertsView,
    Permission.lowStockAlertsManage,

    // Replenishment
    Permission.replenishmentView,
    Permission.replenishmentCreate,
    Permission.replenishmentApprove,

    // Outlets — view only
    Permission.outletsView,

    // HR — can view & manage staff (but not assign Owner role)
    Permission.hrView,
    Permission.hrCreateStaff,
    Permission.hrEditStaff,
    Permission.hrViewStaffDetails,

    // Finances — view only
    Permission.financesView,
    Permission.financesViewReports,

    // My Pharmacies — view only
    Permission.pharmaciesView,

    // Pending Approvals — view only
    Permission.pendingApprovalsView,

    // Sales / Dispensing
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,

    // Pharmacy Tools
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,

    // Dashboard
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,

    // Damaged Stock
    Permission.damagedStockView,
    Permission.damagedStockCreate,
    Permission.damagedStockEdit,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PHARMACIST — Handles dispensing, POS, and clinical tools
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pharmacist: {
    // POS — full access (core responsibility)
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,
    Permission.posApplyDiscount,

    // Inventory — view & edit
    Permission.inventoryView,
    Permission.inventoryEdit,

    // Product Catalogue — view & edit
    Permission.catalogueView,
    Permission.catalogueEdit,

    // Stock Management — view & create counts
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,

    // Goods Received — view & create
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,

    // Batch & Expiry — view
    Permission.batchesView,

    // Low Stock Alerts — view
    Permission.lowStockAlertsView,

    // Replenishment — view
    Permission.replenishmentView,

    // Outlets — view
    Permission.outletsView,

    // HR — no access

    // Finances — view only
    Permission.financesView,

    // My Pharmacies — view
    Permission.pharmaciesView,

    // Pending Approvals — no access

    // Sales / Dispensing
    Permission.salesView,
    Permission.salesCreate,
    Permission.salesEdit,

    // Pharmacy Tools — full access (core clinical tools)
    Permission.pharmacyToolsView,
    Permission.aiAssistantUse,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,

    // Dashboard — limited metrics
    Permission.dashboardViewSalesAnalytics,

    // Damaged Stock — view & report
    Permission.damagedStockView,
    Permission.damagedStockCreate,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // PHARMACY TECHNICIAN — Inventory & stock management focus
  // ═══════════════════════════════════════════════════════════════════
  AppRole.pharmacyTechnician: {
    // POS — view only (can assist but not create)
    Permission.posView,

    // Inventory — view & create
    Permission.inventoryView,
    Permission.inventoryCreate,
    Permission.inventoryEdit,

    // Product Catalogue — view
    Permission.catalogueView,

    // Stock Management — view & create counts
    Permission.stockBalancesView,
    Permission.stockMovementsView,
    Permission.stockCountsView,
    Permission.stockCountsCreate,
    Permission.stockCountsEdit,

    // Goods Received — view & create
    Permission.goodsReceivedView,
    Permission.goodsReceivedCreate,

    // Batch & Expiry — view
    Permission.batchesView,

    // Low Stock Alerts — view
    Permission.lowStockAlertsView,

    // Replenishment — view & create
    Permission.replenishmentView,
    Permission.replenishmentCreate,

    // Outlets — view
    Permission.outletsView,

    // Sales / Dispensing — view
    Permission.salesView,

    // Pharmacy Tools — limited
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,

    // Damaged Stock — view & report
    Permission.damagedStockView,
    Permission.damagedStockCreate,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // CASHIER — POS transactions, sales, and basic inventory views
  // ═══════════════════════════════════════════════════════════════════
  AppRole.cashier: {
    // POS — core access (primary responsibility)
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,

    // Inventory — view only
    Permission.inventoryView,

    // Product Catalogue — view
    Permission.catalogueView,

    // Stock Management — view balances & movements
    Permission.stockBalancesView,
    Permission.stockMovementsView,

    // Batch & Expiry — view
    Permission.batchesView,

    // Low Stock Alerts — view
    Permission.lowStockAlertsView,

    // Sales / Dispensing — view & create
    Permission.salesView,
    Permission.salesCreate,

    // Pharmacy Tools — limited
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // SALES ASSISTANT — POS and basic sales operations
  // ═══════════════════════════════════════════════════════════════════
  AppRole.salesAssistant: {
    // POS — core access
    Permission.posView,
    Permission.posCreateSale,
    Permission.posEditSale,

    // Inventory — view only
    Permission.inventoryView,

    // Product Catalogue — view
    Permission.catalogueView,

    // Stock Management — view balances
    Permission.stockBalancesView,
    Permission.stockMovementsView,

    // Goods Received — view
    Permission.goodsReceivedView,

    // Batch & Expiry — view
    Permission.batchesView,

    // Low Stock Alerts — view
    Permission.lowStockAlertsView,

    // Sales / Dispensing — view & create
    Permission.salesView,
    Permission.salesCreate,

    // Pharmacy Tools — limited
    Permission.pharmacyToolsView,
    Permission.bmiCalculatorUse,

    // Settings
    Permission.settingsView,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // DUNIYA ADMIN — Full network administrative access
  // ═══════════════════════════════════════════════════════════════════
  AppRole.duniyaAdmin: {
    // Duniya Network — full access
    Permission.duniyaPharmaciesView,
    Permission.duniyaStockBalancesView,
    Permission.duniyaOnboardingView,
    Permission.duniyaNetworkAnalyticsView,
    Permission.duniyaApprovePharmacies,

    // Pending Approvals — full access
    Permission.pendingApprovalsView,
    Permission.pendingApprovalsApprove,
    Permission.pendingApprovalsReject,

    // Finances — full access
    Permission.financesView,
    Permission.financesViewReports,
    Permission.financesManageSubscriptions,
    Permission.financesViewBilling,

    // Dashboard — full network metrics
    Permission.dashboardViewOwnerMetrics,
    Permission.dashboardViewFinanceNetwork,
    Permission.dashboardViewSalesAnalytics,
    Permission.dashboardViewInventoryMix,

    // Settings
    Permission.settingsView,
    Permission.settingsManage,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // DUNIYA STAFF — Operational staff within the Duniya network
  // ═══════════════════════════════════════════════════════════════════
  AppRole.duniyaStaff: {
    // Duniya Network — view access
    Permission.duniyaPharmaciesView,
    Permission.duniyaStockBalancesView,
    Permission.duniyaOnboardingView,

    // Pending Approvals — view only
    Permission.pendingApprovalsView,

    // Finances — view only
    Permission.financesView,

    // Dashboard — limited
    Permission.dashboardViewSalesAnalytics,

    // Settings
    Permission.settingsView,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // SUBSCRIBER — External user with limited read access
  // ═══════════════════════════════════════════════════════════════════
  AppRole.subscriber: {
    // Finances — view own billing
    Permission.financesView,
    Permission.financesViewBilling,

    // Settings
    Permission.settingsView,

    // Notifications
    Permission.notificationsView,
  },

  // ═══════════════════════════════════════════════════════════════════
  // UNKNOWN — Minimal permissions (safety net)
  // ═══════════════════════════════════════════════════════════════════
  AppRole.unknown: {
    // Settings — view only
    Permission.settingsView,

    // Notifications
    Permission.notificationsView,
  },
};

/// ─────────────────────────────────────────────────────────────────────
/// Navigation visibility matrix — which NavItems each role can see
/// ─────────────────────────────────────────────────────────────────────
final Map<AppRole, Set<NavItem>> roleNavItems = {
  AppRole.owner: {
    NavItem.home,
    NavItem.myPharmacies,
    NavItem.humanResource,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.pointOfSale,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.vmiDashboard,
    NavItem.settings,
  },
  AppRole.outletManager: {
    NavItem.home,
    NavItem.finances,
    NavItem.humanResource,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.pointOfSale,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.vmiDashboard,
    NavItem.settings,
  },
  AppRole.pharmacist: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.pointOfSale,
    NavItem.aiAssistant,
    NavItem.bmiCalculator,
    NavItem.vmiDashboard,
    NavItem.settings,
  },
  AppRole.pharmacyTechnician: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.stockCounts,
    NavItem.goodsReceived,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.replenishment,
    NavItem.bmiCalculator,
    NavItem.vmiDashboard,
    NavItem.settings,
  },
  AppRole.cashier: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.pointOfSale,
    NavItem.bmiCalculator,
    NavItem.settings,
  },
  AppRole.salesAssistant: {
    NavItem.home,
    NavItem.storeInventory,
    NavItem.productCatalogue,
    NavItem.stockBalances,
    NavItem.stockMovements,
    NavItem.salesDispensing,
    NavItem.batchesExpiry,
    NavItem.lowStockAlerts,
    NavItem.pointOfSale,
    NavItem.bmiCalculator,
    NavItem.vmiDashboard,
    NavItem.settings,
  },
  AppRole.duniyaAdmin: {
    NavItem.home,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.duniyaPharmacies,
    NavItem.duniyaStockBalances,
    NavItem.duniyaOnboardingRequests,
    NavItem.duniyaNetworkAnalytics,
    NavItem.settings,
  },
  AppRole.duniyaStaff: {
    NavItem.home,
    NavItem.finances,
    NavItem.pendingApprovals,
    NavItem.duniyaPharmacies,
    NavItem.duniyaStockBalances,
    NavItem.duniyaOnboardingRequests,
    NavItem.settings,
  },
  AppRole.subscriber: {
    NavItem.home,
    NavItem.finances,
    NavItem.settings,
  },
  AppRole.unknown: {
    NavItem.home,
    NavItem.settings,
  },
};
