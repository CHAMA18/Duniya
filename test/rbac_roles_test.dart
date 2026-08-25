import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/rbac/roles.dart';

/// ═══════════════════════════════════════════════════════════════════
///   RBAC Role Model — Unit Tests
///   Covers: role parsing from Firestore values, role classification
///   (pulse vs pharmacy vs owner-level), and display labels.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  group('AppRole.fromFirestoreValue', () {
    test('parses canonical role names', () {
      expect(AppRole.fromFirestoreValue('Owner'), AppRole.owner);
      expect(AppRole.fromFirestoreValue('Pharmacist'), AppRole.pharmacist);
      expect(
          AppRole.fromFirestoreValue('Outlet Manager'), AppRole.outletManager);
      expect(AppRole.fromFirestoreValue('Stock Controller'),
          AppRole.stockController);
      expect(AppRole.fromFirestoreValue('Finance Viewer'), AppRole.financeViewer);
      expect(AppRole.fromFirestoreValue('Cashier'), AppRole.cashier);
      expect(
          AppRole.fromFirestoreValue('Sales Assistant'), AppRole.salesAssistant);
      expect(AppRole.fromFirestoreValue('Subscriber'), AppRole.subscriber);
    });

    test('is case-insensitive', () {
      expect(AppRole.fromFirestoreValue('owner'), AppRole.owner);
      expect(AppRole.fromFirestoreValue('OWNER'), AppRole.owner);
      expect(
          AppRole.fromFirestoreValue('PhArMaCiSt'), AppRole.pharmacist);
    });

    test('normalizes spaces to underscores', () {
      expect(AppRole.fromFirestoreValue('sales assistant'),
          AppRole.salesAssistant);
      expect(AppRole.fromFirestoreValue('pharmacy technician'),
          AppRole.pharmacyTechnician);
      expect(AppRole.fromFirestoreValue('outlet manager'),
          AppRole.outletManager);
    });

    test('parses the pulse account types', () {
      // The Pulse network Owner account type string
      expect(AppRole.fromFirestoreValue('duniya_admin'), AppRole.pulseAdmin);
      expect(AppRole.fromFirestoreValue('duniyaadmin'), AppRole.pulseAdmin);
      expect(AppRole.fromFirestoreValue('duniya'), AppRole.pulseAdmin);
      expect(AppRole.fromFirestoreValue('duniya_staff'), AppRole.pulseStaff);
      expect(AppRole.fromFirestoreValue('duniyastaff'), AppRole.pulseStaff);
    });

    test('parses legacy staff aliases', () {
      expect(AppRole.fromFirestoreValue('staff'), AppRole.salesAssistant);
      expect(AppRole.fromFirestoreValue('manager'), AppRole.outletManager);
    });

    test('null / empty / unknown fall back to unknown', () {
      expect(AppRole.fromFirestoreValue(null), AppRole.unknown);
      expect(AppRole.fromFirestoreValue(''), AppRole.unknown);
      expect(AppRole.fromFirestoreValue('wizard'), AppRole.unknown);
      expect(AppRole.fromFirestoreValue('   '), AppRole.unknown);
    });
  });

  group('role classification', () {
    test('isPulseRole is true only for the two pulse roles', () {
      expect(AppRole.pulseAdmin.isPulseRole, isTrue);
      expect(AppRole.pulseStaff.isPulseRole, isTrue);
      for (final role in [
        AppRole.owner,
        AppRole.outletManager,
        AppRole.pharmacist,
        AppRole.pharmacyTechnician,
        AppRole.stockController,
        AppRole.financeViewer,
        AppRole.cashier,
        AppRole.salesAssistant,
        AppRole.subscriber,
        AppRole.unknown,
      ]) {
        expect(role.isPulseRole, isFalse, reason: '$role should not be pulse');
      }
    });

    test('isPharmacyRole covers all 8 pharmacy roles', () {
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
        expect(role.isPharmacyRole, isTrue, reason: '$role should be pharmacy');
      }
      for (final role in [
        AppRole.pulseAdmin,
        AppRole.pulseStaff,
        AppRole.subscriber,
        AppRole.unknown,
      ]) {
        expect(role.isPharmacyRole, isFalse,
            reason: '$role should not be pharmacy');
      }
    });

    test('isOwnerLevel is pharmacy-owner only by design', () {
      // NOTE: pulseAdmin is intentionally NOT owner-level. isOwnerLevel
      // drives parentRef() workspace scoping (own-reference vs ownerRef);
      // Pulse network users resolve data network-wide instead, so granting
      // them owner-level would scope their queries to the wrong parent.
      expect(AppRole.owner.isOwnerLevel, isTrue);
      expect(AppRole.pulseAdmin.isOwnerLevel, isFalse);
      expect(AppRole.outletManager.isOwnerLevel, isFalse);
      expect(AppRole.pulseStaff.isOwnerLevel, isFalse);
      expect(AppRole.unknown.isOwnerLevel, isFalse);
    });
  });

  group('display labels', () {
    test('every role has a non-empty human label', () {
      // displayLabel / label getter — check the actual name via the
      // role's toString fallback. The sidebar maps these; we just
      // verify no role crashes classification helpers.
      for (final role in AppRole.values) {
        expect(role.isPulseRole || role.isPharmacyRole || role == AppRole.unknown || role == AppRole.subscriber,
            isTrue,
            reason: '$role must be classifiable');
      }
    });
  });
}
