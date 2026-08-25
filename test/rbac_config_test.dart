import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/rbac/permissions.dart';
import 'package:medi_tracker/rbac/role_config.dart';
import 'package:medi_tracker/rbac/roles.dart';

/// ═══════════════════════════════════════════════════════════════════
///   RBAC Permission & Navigation Matrix — Invariant Tests
///
///   These tests lock in the product's account-side rules so a future
///   config edit cannot silently regress them:
///     - Pharmacy roles: Store Inventory ONLY (never Product Catalogue)
///     - Pulse roles: Product Catalogue ONLY (never Store Inventory)
///     - Pulse roles never see the pharmacy-side Stock Balances page
///     - Drug Interactions is retired from every nav
///     - unknown role is deny-by-default
/// ═══════════════════════════════════════════════════════════════════
void main() {
  final pharmacyRoles = <AppRole>[
    AppRole.owner,
    AppRole.outletManager,
    AppRole.pharmacist,
    AppRole.pharmacyTechnician,
    AppRole.stockController,
    AppRole.financeViewer,
    AppRole.cashier,
    AppRole.salesAssistant,
  ];

  final pulseRoles = <AppRole>[AppRole.pulseAdmin, AppRole.pulseStaff];

  group('matrix completeness', () {
    test('every AppRole has an entry in both matrices', () {
      for (final role in AppRole.values) {
        expect(rolePermissions.containsKey(role), isTrue,
            reason: '$role missing from rolePermissions');
        expect(roleNavItems.containsKey(role), isTrue,
            reason: '$role missing from roleNavItems');
      }
    });

    test('every NavItem is reachable by at least one role', () {
      final union = <NavItem>{};
      for (final items in roleNavItems.values) {
        union.addAll(items);
      }
      final unreachable = NavItem.values.where((i) => !union.contains(i));
      expect(unreachable, isEmpty,
          reason:
              'Unreachable nav items (no role can see them): $unreachable');
    });
  });

  group('inventory destination is portal-specific', () {
    test('pharmacy roles see Store Inventory, never Product Catalogue', () {
      for (final role in pharmacyRoles) {
        final items = roleNavItems[role]!;
        expect(items.contains(NavItem.storeInventory),
            items.contains(NavItem.productCatalogue) ? isTrue : isTrue,
            reason: '$role should see Store Inventory');
        expect(items.contains(NavItem.productCatalogue), isFalse,
            reason:
                '$role must NOT see Product Catalogue (Pulse-side page)');
      }
    });

    test('pharmacy stock-operations roles see Store Inventory', () {
      // Every pharmacy role that can touch stock sees the inventory page.
      for (final role in [
        AppRole.owner,
        AppRole.outletManager,
        AppRole.pharmacist,
        AppRole.pharmacyTechnician,
        AppRole.stockController,
        AppRole.cashier,
        AppRole.salesAssistant,
      ]) {
        expect(roleNavItems[role]!.contains(NavItem.storeInventory), isTrue,
            reason: '$role should see Store Inventory');
      }
    });

    test('pulse roles see Product Catalogue, never Store Inventory', () {
      for (final role in pulseRoles) {
        final items = roleNavItems[role]!;
        expect(items.contains(NavItem.productCatalogue), isTrue,
            reason: '$role should see Product Catalogue');
        expect(items.contains(NavItem.storeInventory), isFalse,
            reason: '$role must NOT see Store Inventory (pharmacy page)');
      }
    });
  });

  group('stock balances are pharmacy-side', () {
    test('pulse roles never see the pharmacy-side Stock Balances page', () {
      for (final role in pulseRoles) {
        expect(roleNavItems[role]!.contains(NavItem.stockBalances), isFalse,
            reason:
                '$role must NOT see Stock Balances (network users get the '
                'Stock Balance Visibility page instead)');
      }
    });

    test('pulse roles keep their network-wide stock visibility page', () {
      for (final role in pulseRoles) {
        expect(
            roleNavItems[role]!.contains(NavItem.pulseStockBalances), isTrue,
            reason: '$role should see Stock Balance Visibility');
      }
    });

    test('stock-controlling pharmacy roles see Stock Balances', () {
      for (final role in [
        AppRole.owner,
        AppRole.outletManager,
        AppRole.pharmacist,
        AppRole.pharmacyTechnician,
        AppRole.stockController,
        AppRole.financeViewer,
        AppRole.cashier,
        AppRole.salesAssistant,
      ]) {
        expect(roleNavItems[role]!.contains(NavItem.stockBalances), isTrue,
            reason: '$role should see Stock Balances');
      }
    });
  });

  group('drug interactions page is retired', () {
    test('the NavItem value itself is removed from the enum', () {
      // The page was retired (2026-08): the enum value was deleted so no
      // config edit can silently re-grant it. If this test fails, someone
      // reintroduced NavItem.drugInteractions — make sure that is
      // intentional before shipping.
      final names =
          NavItem.values.map((i) => i.name).toList(growable: false);
      expect(names.contains('drugInteractions'), isFalse);
    });
  });

  group('unknown role is deny-by-default', () {
    test('unknown role has empty permissions', () {
      expect(rolePermissions[AppRole.unknown], isEmpty);
    });

    test('unknown role nav is minimal', () {
      // AppRole.unknown intentionally was reduced to a minimal set
      // (default-allow was a security bug once).
      final items = roleNavItems[AppRole.unknown]!;
      expect(items.length, lessThanOrEqualTo(4),
          reason: 'Unknown role should expose almost nothing');
      expect(items.contains(NavItem.userManagement), isFalse);
      expect(items.contains(NavItem.auditLogs), isFalse);
    });
  });

  group('common sense permissions', () {
    test('operational roles with nav items also have permissions', () {
      // unknown + subscriber are excluded deliberately: unknown is
      // deny-by-default (empty permissions while its minimal nav lets
      // users reach Home/Settings), and subscriber is a read-only
      // external account type.
      for (final role in [
        ...pharmacyRoles,
        ...pulseRoles,
      ]) {
        expect(rolePermissions[role]!.isNotEmpty, isTrue,
            reason: '$role has nav items but zero permissions');
      }
    });

    test('owner is the most privileged pharmacy role', () {
      final ownerPerms = rolePermissions[AppRole.owner]!;
      for (final role in pharmacyRoles.skip(1)) {
        expect(rolePermissions[role]!.length, lessThan(ownerPerms.length),
            reason: '$role should not out-rank Owner');
      }
    });

    test('pulse admin outranks pulse staff', () {
      expect(rolePermissions[AppRole.pulseStaff]!.length,
          lessThan(rolePermissions[AppRole.pulseAdmin]!.length));
    });

    test('only pulse admin manages users', () {
      expect(rolePermissions[AppRole.pulseAdmin]!
          .contains(Permission.userManagementManage), isTrue);
      expect(rolePermissions[AppRole.pulseStaff]!
          .contains(Permission.userManagementManage), isFalse);
    });

    test('finance viewer cannot manage stock', () {
      final perms = rolePermissions[AppRole.financeViewer]!;
      expect(perms.contains(Permission.stockCountsCreate), isFalse);
      expect(perms.contains(Permission.catalogueCreate), isFalse);
    });

    test('cashier and sales assistant cannot edit the catalogue', () {
      for (final role in [AppRole.cashier, AppRole.salesAssistant]) {
        expect(rolePermissions[role]!.contains(Permission.catalogueCreate),
            isFalse,
            reason: '$role must not create catalogue products');
        expect(rolePermissions[role]!.contains(Permission.catalogueEdit),
            isFalse);
        expect(rolePermissions[role]!.contains(Permission.catalogueDelete),
            isFalse);
      }
    });
  });
}
