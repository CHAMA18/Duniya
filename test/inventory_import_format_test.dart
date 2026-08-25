import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/custom_code/actions/parse_inventory_spreadsheet.dart';

/// Contract tests for the Store Inventory spreadsheet import accepting the
/// Product Catalogue format (Pulse_Product_Catalogue_Import__VMI).
///
/// The uploaded catalogue sheet uses these 14 columns:
///   Name, GenericName, BrandName, Strength, DosageForm, PackSize,
///   UnitOfMeasure, SKU, Category, Supplier, CostPrice, SellingPrice,
///   MinimumStockLevel, ReorderLevel
///
/// and must import into Stock records as:
///   Name → Name, Supplier → Manufacturer (BrandName fallback),
///   SellingPrice → Price, CostPrice → CostOfGoods,
///   ReorderLevel (preferred) / MinimumStockLevel → LimitNotice,
///   remaining attributes → composed Description, Quantity → 0 default.
void main() {
  /// The exact header row of the user's uploaded catalogue file.
  const catalogueHeaders = [
    'Name',
    'GenericName',
    'BrandName',
    'Strength',
    'DosageForm',
    'PackSize',
    'UnitOfMeasure',
    'SKU',
    'Category',
    'Supplier',
    'CostPrice',
    'SellingPrice',
    'MinimumStockLevel',
    'ReorderLevel',
  ];

  group('mapSpreadsheetHeaders — Product Catalogue format', () {
    test('every catalogue column maps to a canonical Stock field', () {
      final mapping = mapSpreadsheetHeaders(catalogueHeaders);

      expect(mapping['Name'], 'name');
      expect(mapping['GenericName'], 'genericName');
      expect(mapping['BrandName'], 'brandName');
      expect(mapping['Strength'], 'strength');
      expect(mapping['DosageForm'], 'dosageForm');
      expect(mapping['PackSize'], 'packSize');
      expect(mapping['UnitOfMeasure'], 'unitOfMeasure');
      expect(mapping['SKU'], 'sku');
      expect(mapping['Category'], 'category');
      expect(mapping['Supplier'], 'manufacturer');
      expect(mapping['CostPrice'], 'costOfGoods');
      expect(mapping['SellingPrice'], 'price');
      expect(mapping['MinimumStockLevel'], 'minimumStockLevel');
      expect(mapping['ReorderLevel'], 'reorderLevel');
      // All 14 columns resolved — nothing silently dropped.
      expect(mapping.length, catalogueHeaders.length);
    });

    test('classic stock-sheet format still maps unchanged', () {
      final mapping = mapSpreadsheetHeaders([
        'Name',
        'Category',
        'Manufacturer',
        'Quantity',
        'Price',
        'CostOfGoods',
        'BatchNumber',
        'ExpiryDate',
        'LimitNotice',
      ]);
      expect(mapping['Name'], 'name');
      expect(mapping['Manufacturer'], 'manufacturer');
      expect(mapping['Quantity'], 'quantity');
      expect(mapping['Price'], 'price');
      expect(mapping['CostOfGoods'], 'costOfGoods');
      expect(mapping['BatchNumber'], 'batchNumber');
      expect(mapping['ExpiryDate'], 'expiryDate');
      expect(mapping['LimitNotice'], 'limitNotice');
    });

    test('friendly aliases keep working alongside the new camelCase ones', () {
      final mapping = mapSpreadsheetHeaders([
        'Product Name',
        'Qty',
        'Unit Price',
        'SellingPrice',
        'CostPrice',
        'ReorderLevel',
        'MinimumStockLevel',
        'UOM',
        'Item Code',
        'Generic Name',
      ]);
      expect(mapping['Product Name'], 'name');
      expect(mapping['Qty'], 'quantity');
      expect(mapping['Unit Price'], 'price');
      expect(mapping['SellingPrice'], 'price');
      expect(mapping['CostPrice'], 'costOfGoods');
      expect(mapping['ReorderLevel'], 'reorderLevel');
      expect(mapping['MinimumStockLevel'], 'minimumStockLevel');
      expect(mapping['UOM'], 'unitOfMeasure');
      expect(mapping['Item Code'], 'sku');
      expect(mapping['Generic Name'], 'genericName');
    });

    test('unrecognized headers are ignored, not mis-mapped', () {
      final mapping = mapSpreadsheetHeaders(['Name', 'Color', 'Shelf']);
      expect(mapping.keys, ['Name']);
      expect(mapping['Name'], 'name');
    });
  });

  group('isProductCatalogueSheet', () {
    test('detects the catalogue format from its header row', () {
      expect(isProductCatalogueSheet(catalogueHeaders), isTrue);
    });

    test('classic stock sheet is NOT flagged as catalogue', () {
      expect(
        isProductCatalogueSheet([
          'Name',
          'Category',
          'Manufacturer',
          'Quantity',
          'Price',
          'CostOfGoods',
          'BatchNumber',
          'ExpiryDate',
          'LimitNotice',
        ]),
        isFalse,
      );
    });
  });

  group('resolveLimitNotice', () {
    test('ReorderLevel wins when both catalogue levels are present', () {
      // The demo file's pattern: MinimumStockLevel 5, ReorderLevel 10 —
      // the actionable reorder trigger (10) must become the alert level.
      expect(
        resolveLimitNotice(reorderLevel: 10, minimumStockLevel: 5),
        10,
      );
    });

    test('falls back to MinimumStockLevel then classic LimitNotice', () {
      expect(resolveLimitNotice(minimumStockLevel: 42), 42);
      expect(resolveLimitNotice(limitNotice: 7), 7);
      expect(resolveLimitNotice(), 0);
    });
  });

  group('composeStockDescription', () {
    test('joins catalogue attributes with bullets and appends the SKU', () {
      final description = composeStockDescription(
        genericName: 'Acyclovir',
        brandName: 'Halyvir',
        strength: '200 mg',
        dosageForm: 'Tablet',
        packSize: '100 tablets',
        unitOfMeasure: 'Each',
        sku: 'ACY-0002',
      );
      expect(
        description,
        'Acyclovir • Halyvir • 200 mg • Tablet • 100 tablets • Each • '
        'SKU: ACY-0002',
      );
    });

    test("drops 'Nil' and empty attributes (demo file uses Nil strengths)", () {
      final description = composeStockDescription(
        genericName: 'Acyclovir',
        brandName: 'herpizyg',
        strength: 'Nil',
        dosageForm: 'Cream',
        packSize: '1 tube',
        unitOfMeasure: 'Tubes',
        sku: 'ACY-0001',
      );
      expect(
        description,
        'Acyclovir • herpizyg • Cream • 1 tube • Tubes • SKU: ACY-0001',
      );
    });

    test('SKU-only rows read cleanly without a leading bullet', () {
      expect(
        composeStockDescription(strength: 'Nil', sku: 'ACY-0001'),
        'SKU: ACY-0001',
      );
    });

    test('returns null when there is nothing meaningful to store', () {
      expect(composeStockDescription(), isNull);
      expect(composeStockDescription(strength: 'Nil'), isNull);
    });
  });

  group('import semantics (documented expectations)', () {
    test('catalogue row fields land on the right Stock record keys', () {
      // Mirrors the first data row of the uploaded demo file:
      // Acyclovir cream (herpizyg) 10g | Acyclovir | herpizyg | Nil |
      // Cream | 1 tube | Tubes | ACY-0001 | Antivirals |
      // Must Pharmaceuticals | 10.76 | 17.22 | 5 | 10
      final mapping = mapSpreadsheetHeaders(catalogueHeaders);
      // The fields the import writer consumes:
      expect(mapping['Name'], 'name'); // → Name
      expect(mapping['Supplier'], 'manufacturer'); // → Manufacturer
      expect(mapping['SellingPrice'], 'price'); // → Price (17.22)
      expect(mapping['CostPrice'], 'costOfGoods'); // → CostOfGoods (10.76)
      expect(mapping['ReorderLevel'], 'reorderLevel'); // → alert (10)
      expect(mapping['Category'], 'category'); // → Category (Antivirals)
      // No Quantity column in the catalogue format — imports default to 0.
      expect(mapping.containsKey('Quantity'), isFalse);
      expect(mapping.values.contains('quantity'), isFalse);
    });
  });
}
