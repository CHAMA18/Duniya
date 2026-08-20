/// ─────────────────────────────────────────────────────────────────────
/// Pulse RBAC — Role Definitions
/// ─────────────────────────────────────────────────────────────────────
/// Defines every role in the system and normalizes the various
/// string representations found in Firestore (e.g. 'Owner', 'owner',
/// 'Pharmacist', 'pharmacist') into a single canonical enum.
///
/// When adding a new role:
///   1. Add the enum value here
///   2. Add the Firestore string mapping in fromFirestoreValue()
///   3. Assign permissions in role_config.dart
/// ─────────────────────────────────────────────────────────────────────
enum AppRole {
  /// Pharmacy owner — full administrative access to their pharmacy
  owner,

  /// Pharmacy manager — manages pharmacy operations and staff
  outletManager,

  /// Pharmacist — handles dispensing, POS, and inventory operations
  pharmacist,

  /// Pharmacy technician — assists with inventory and stock management
  pharmacyTechnician,

  /// Cashier — handles POS transactions, sales, and basic inventory views
  cashier,

  /// Sales assistant — handles POS and basic sales operations
  salesAssistant,

  /// Pulse network admin — oversees the entire Pulse network
  duniyaAdmin,

  /// Pulse staff — operational staff within the Pulse network
  duniyaStaff,

  /// Subscriber — external user with limited read access
  subscriber,

  /// Unknown / unassigned — default with minimal permissions
  unknown;

  /// Convert a Firestore `role` string to an AppRole enum.
  /// Handles the various case inconsistencies found in the codebase.
  static AppRole fromFirestoreValue(String? value) {
    if (value == null || value.isEmpty) return AppRole.unknown;
    switch (value.toLowerCase().replaceAll(' ', '_')) {
      case 'owner':
        return AppRole.owner;
      case 'outlet_manager':
      case 'outletmanager':
        return AppRole.outletManager;
      case 'pharmacist':
        return AppRole.pharmacist;
      case 'pharmacy_technician':
      case 'pharmacytechnician':
      case 'technician':
        return AppRole.pharmacyTechnician;
      case 'cashier':
        return AppRole.cashier;
      case 'sales_assistant':
      case 'salesassistant':
      case 'staff':
        return AppRole.salesAssistant;
      case 'manager':
        return AppRole.outletManager;
      case 'duniya_admin':
      case 'duniyaadmin':
      case 'duniya':
        return AppRole.duniyaAdmin;
      case 'duniya_staff':
      case 'duniyastaff':
        return AppRole.duniyaStaff;
      case 'subscriber':
      case 'subscription':
        return AppRole.subscriber;
      default:
        return AppRole.unknown;
    }
  }

  /// Convert a Firestore `accountType` string to determine if
  /// the user is a Pulse network user or a pharmacy user.
  /// Defaults to pharmacy (false) when null/empty for security —
  /// missing accountType should not grant network admin access.
  static bool isDuniyaAccountType(String? accountType) {
    if (accountType == null || accountType.isEmpty) return false;
    return accountType.toLowerCase() == 'duniya';
  }

  /// Human-readable display name for the role.
  String get displayName {
    switch (this) {
      case AppRole.owner:
        return 'Owner';
      case AppRole.outletManager:
        return 'Pharmacy Manager';
      case AppRole.pharmacist:
        return 'Pharmacist';
      case AppRole.pharmacyTechnician:
        return 'Pharmacy Technician';
      case AppRole.cashier:
        return 'Cashier';
      case AppRole.salesAssistant:
        return 'Sales Assistant';
      case AppRole.duniyaAdmin:
        return 'Pulse Admin';
      case AppRole.duniyaStaff:
        return 'Pulse Staff';
      case AppRole.subscriber:
        return 'Subscriber';
      case AppRole.unknown:
        return 'Unknown';
    }
  }

  /// Whether this role belongs to the Pulse network side.
  bool get isDuniyaRole =>
      this == AppRole.duniyaAdmin || this == AppRole.duniyaStaff;

  /// Whether this role belongs to the pharmacy side.
  bool get isPharmacyRole =>
      this == AppRole.owner ||
      this == AppRole.outletManager ||
      this == AppRole.pharmacist ||
      this == AppRole.pharmacyTechnician ||
      this == AppRole.cashier ||
      this == AppRole.salesAssistant;

  /// The canonical Firestore `role` string for this AppRole.
  /// Used when writing role values to Firestore documents.
  String get firestoreValue {
    switch (this) {
      case AppRole.owner:
        return 'Owner';
      case AppRole.outletManager:
        return 'Outlet Manager';
      case AppRole.pharmacist:
        return 'Pharmacist';
      case AppRole.pharmacyTechnician:
        return 'Pharmacy Technician';
      case AppRole.cashier:
        return 'Cashier';
      case AppRole.salesAssistant:
        return 'Sales Assistant';
      case AppRole.duniyaAdmin:
        return 'admin';
      case AppRole.duniyaStaff:
        return 'staff';
      case AppRole.subscriber:
        return 'subscriber';
      case AppRole.unknown:
        return '';
    }
  }

  /// The Firestore `accountType` string for this AppRole's side.
  String get accountTypeValue => isDuniyaRole ? 'Pulse' : 'Pharmacy';

  /// Whether this role has Owner-level admin privileges.
  bool get isOwnerLevel => this == AppRole.owner;

  /// Whether this role can manage other staff.
  bool get canManageStaff =>
      this == AppRole.owner || this == AppRole.outletManager;

  /// Check if an accountType string represents a Pharmacy account.
  /// Case-insensitive; treats null/empty as Pharmacy (safe default).
  static bool isPharmacyAccountType(String? accountType) {
    if (accountType == null || accountType.isEmpty) return true;
    return accountType.toLowerCase() == 'pharmacy';
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// Navigation items — used by sidebar & mobile navbar for RBAC gating
/// ─────────────────────────────────────────────────────────────────────
enum NavItem {
  home,
  myPharmacies,
  humanResource,
  finances,
  pendingApprovals,
  storeInventory,
  productCatalogue,
  stockBalances,
  stockMovements,
  stockCounts,
  goodsReceived,
  salesDispensing,
  batchesExpiry,
  lowStockAlerts,
  replenishment,
  pointOfSale,
  aiAssistant,
  bmiCalculator,
  duniyaPharmacies,
  duniyaStockBalances,
  duniyaOnboardingRequests,
  duniyaNetworkAnalytics,
  vmiDashboard,
  auditLogs,
  drugInteractions,
  expiryTracking,
  purchaseOrders,
  prescriptions,
  insurance,
  coldChain,
  patientRecords,
  settings,
}
