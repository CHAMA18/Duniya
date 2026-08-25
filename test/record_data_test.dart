import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/backend/backend.dart';

/// ═══════════════════════════════════════════════════════════════════
///   Firestore Record Data Builders — Unit Tests
///
///   These builders are the LAST line of defence before a write hits
///   Firestore: wrong keys mean silently missing fields. The tests
///   lock the schema keys and the payment-capture contract used by
///   the POS.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  group('createSaleRecordVMIData', () {
    test('maps the payment capture to the schema keys', () {
      final data = createSaleRecordVMIData(
        totalAmount: 500.0,
        paymentMethod: 'Mobile Money',
        mobileMoneyProvider: 'Zamtel Money',
      );

      expect(data['PaymentMethod'], 'Mobile Money');
      expect(data['MobileMoneyProvider'], 'Zamtel Money');
      expect(data['TotalAmount'], 500.0);
    });

    test('omits null optional fields (withoutNulls contract)', () {
      final data = createSaleRecordVMIData(
        totalAmount: 100.0,
        paymentMethod: 'Cash',
        mobileMoneyProvider: null,
      );

      expect(data.containsKey('PaymentMethod'), isTrue);
      expect(data.containsKey('MobileMoneyProvider'), isFalse,
          reason: 'null provider must be dropped, not written as null');
      expect(data.containsKey('PatientRef'), isFalse);
    });

    test('all payment methods round-trip', () {
      for (final pm in ['Cash', 'Card', 'Mobile Money']) {
        final data = createSaleRecordVMIData(
          paymentMethod: pm,
          totalAmount: 1.0,
        );
        expect(data['PaymentMethod'], pm);
      }
    });
  });

  group('createStockMovementRecordData', () {
    test('writes the audit-trail fields under their schema keys', () {
      final data = createStockMovementRecordData(
        productName: 'Paracetamol 500mg',
        quantity: 4,
        movementType: 'SALE_RETURN',
        reason: 'Reversal of sale abc123',
        movementReference: 'abc123',
      );

      expect(data['ProductName'], 'Paracetamol 500mg');
      expect(data['Quantity'], 4);
      expect(data['MovementType'], 'SALE_RETURN');
      expect(data['Reason'], 'Reversal of sale abc123');
      expect(data['MovementReference'], 'abc123');
    });
  });

  group('createProductMasterRecordData', () {
    test('carries the inventory policy trio', () {
      final data = createProductMasterRecordData(
        name: 'Amoxicillin',
        sku: 'AMX-500',
        targetStockLevel: 200, // Quantity
        minimumStockLevel: 40, // Min Stock Level
        reorderLevel: 80, // Reorder Level
      );

      expect(data['Name'], 'Amoxicillin');
      expect(data['SKU'], 'AMX-500');
      expect(data['TargetStockLevel'], 200);
      expect(data['MinimumStockLevel'], 40);
      expect(data['ReorderLevel'], 80);
    });

    test('drops null fields instead of writing Firestore nulls', () {
      final data = createProductMasterRecordData(name: 'Test');
      expect(data.containsKey('Name'), isTrue);
      expect(data.containsKey('SKU'), isFalse);
      expect(data.containsKey('CostPrice'), isFalse);
    });
  });

  group('createSaleitemRecordData', () {
    test('writes the sale line fields under their schema keys', () {
      final data = createSaleitemRecordData(
        quantity: 2,
        unitPrice: 24.99,
        totalPrice: 49.98,
      );

      // NOTE: the legacy Saleitem schema uses snake_case keys.
      expect(data['Quantity'], 2);
      expect(data['Unit_price'], 24.99);
      expect(data['Total_price'], 49.98);
    });
  });
}
