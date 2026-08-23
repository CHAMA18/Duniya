import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/duniya/pharmacies/smart_reconciliation_parser.dart';

void main() {
  group('matchColumns', () {
    test('matches the canonical header exactly', () {
      final cols = SmartReconciliationParser.matchColumns([
        'Product Name', 'Description', 'Opening Stock', 'Stock Supplied',
        'Total Available', 'Physical Count', 'Units Dispensed',
        'Transfer Unit Price',
      ]);
      expect(cols, hasLength(8));
      expect(cols[SmartReconciliationParser.kProductName], 0);
      expect(cols[SmartReconciliationParser.kUnitPrice], 7);
    });

    test('matches common header variants and ignores extras', () {
      final cols = SmartReconciliationParser.matchColumns([
        '#', 'Product', 'Opening Balance', 'Received Qty', 'Total Stock',
        'Counted', 'Dispensed', 'Unit Price (ZMW)', 'Shelf', 'Notes',
      ]);
      expect(cols[SmartReconciliationParser.kProductName], 1);
      expect(cols[SmartReconciliationParser.kOpeningStock], 2);
      expect(cols[SmartReconciliationParser.kStockSupplied], 3);
      expect(cols[SmartReconciliationParser.kTotalAvailable], 4);
      expect(cols[SmartReconciliationParser.kPhysicalCount], 5);
      expect(cols[SmartReconciliationParser.kUnitsDispensed], 6);
      expect(cols[SmartReconciliationParser.kUnitPrice], 7);
      expect(cols.containsKey('shelf'), isFalse);
    });

    test('never maps grand total / subtotal headers to totals', () {
      final cols = SmartReconciliationParser.matchColumns([
        'Product', 'Opening', 'Supplied', 'Grand Total', 'Physical',
        'Dispensed',
      ]);
      expect(cols[SmartReconciliationParser.kTotalAvailable], isNull);
      expect(cols.containsKey(SmartReconciliationParser.kTotalAvailable),
          isFalse);
    });
  });

  group('parseSheet — smart row handling', () {
    List<List<String>> sheet(List<List<String>> rows) => rows;

    test('classic sheet imports all valid rows', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Description', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Paracetamol 500mg', 'Pain relief', '10', '20', '30', '8', '22',
           '2.50'],
          ['Panadol', '', '5', '5', '10', '10', '0', '3'],
        ]),
      );
      expect(result.records, hasLength(2));
      expect(result.skipped, isEmpty);
      expect(result.records.first['name'], 'Paracetamol 500mg');
      expect(result.records.first['openingStock'], 10);
      expect(result.records.first['unitCost'], 2.5);
      expect(result.records.last['unitsDispensed'], 0);
    });

    test('junk rows are skipped with reasons, valid rows import', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['', '', '', '', '', '', ''],           // blank
          ['SECTION A — COLD CHAIN', '', '', '', '', '', ''], // heading
          ['Paracetamol', '10', '20', '30', '8', '22', '2'],   // good
          ['TOTAL', '500', '900', '1400', '400', '1000', ''],  // summary row
          ['Broken Med', '10', '20', '99', '5', '5', '1'],     // bad totals
          ['No Numbers', '', '', '', '', '', ''],              // note row
          ['Panadol', '5', '5', '10', '10', '0', '3'],         // good
        ]),
      );
      expect(result.records, hasLength(2));
      expect(result.records.map((r) => r['name']),
          containsAll(['Paracetamol', 'Panadol']));

      final reasons = result.skipped.map((s) => s.reason).toList();
      expect(reasons, contains('summary row'));
      expect(reasons, contains('no stock figures (heading or note)'));
      expect(reasons, contains('totals do not reconcile'));
      // The totally blank row is ignored silently.
      expect(result.skipped.where((s) => s.rowNumber == 2), isEmpty);
    });

    test('missing linear totals are derived from the other two', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          // total + dispensed missing → derived (30, 22)
          ['Paracetamol', '10', '20', '', '8', '', '2'],
          // physical missing → derived (10 - 0 = 10)
          ['Panadol', '5', '5', '10', '', '0', '3'],
        ]),
      );
      expect(result.records, hasLength(2));
      expect(result.records.first['totalAvailable'], 30);
      expect(result.records.first['unitsDispensed'], 22);
      expect(result.records.last['physicalCount'], 10);
    });

    test('unreadable figures skip only that row', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Good Med', '1', '2', '3', '3', '0', '1'],
          ['Junk Med', 'TBC', '2', '3', '3', '0', '1'],
        ]),
      );
      expect(result.records, hasLength(1));
      expect(result.skipped.single.reason, 'unreadable figures');
    });

    test('missing unit price defaults to 0 and is reported', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Med A', '1', '2', '3', '3', '0', ''],
          ['Med B', '1', '2', '3', '3', '0', 'N/A'],
        ]),
      );
      expect(result.records, hasLength(2));
      expect(result.records.every((r) => r['unitCost'] == 0), isTrue);
      expect(result.priceDefaultedCount, 2);
    });

    test('same-row formulas are evaluated', () {
      // Columns: A name, B opening, C supplied, D total(=B+C),
      // E physical, F dispensed(=D-E), G price
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Paracetamol', '10', '20', '=B2+C2', '8', '=D2-E2', '2'],
        ]),
      );
      expect(result.records, hasLength(1));
      expect(result.records.first['totalAvailable'], 30);
      expect(result.records.first['unitsDispensed'], 22);
    });

    test('named row with figures but empty name is skipped', () {
      final result = SmartReconciliationParser.parseSheet(
        'Recon Final',
        0,
        sheet([
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['', '10', '20', '30', '8', '22', '2'],
        ]),
      );
      expect(result.records, isEmpty);
      expect(result.skipped.single.reason, 'missing product name');
    });
  });

  group('detectBestSheet', () {
    test('picks the data sheet over junk sheets, even when not first', () {
      final sheets = <String, List<List<String>>>{
        'Cover': [
          ['Monthly Report'],
          ['Generated by Pulse'],
        ],
        'Notes': [
          ['Random', 'Stuff'],
          ['a', 'b'],
        ],
        'Recon Final': [
          ['SOS Mpilo — August Reconciliation'],
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Paracetamol', '10', '20', '30', '8', '22', '2'],
        ],
      };
      final match = SmartReconciliationParser.detectBestSheet(sheets);
      expect(match, isNotNull);
      expect(match!.sheetName, 'Recon Final');
      expect(match.headerRowNumber, 2); // header on second row
      expect(match.parse.records, hasLength(1));
    });

    test('title rows above the header are tolerated', () {
      final sheets = <String, List<List<String>>>{
        'Sheet1': [
          ['Pharmacy Reconciliation'],
          ['Period: August 2026'],
          ['', '', '', '', '', '', ''],
          ['Product Name', 'Opening Stock', 'Stock Supplied',
           'Total Available', 'Physical Count', 'Units Dispensed',
           'Transfer Unit Price'],
          ['Paracetamol', '10', '20', '30', '8', '22', '2'],
        ],
      };
      final match = SmartReconciliationParser.detectBestSheet(sheets);
      expect(match, isNotNull);
      expect(match!.headerRowNumber, 4);
      expect(match.parse.records, hasLength(1));
    });

    test('returns null when nothing resembles a reconciliation', () {
      final sheets = <String, List<List<String>>>{
        'Sheet1': [
          ['Hello', 'World'],
          ['a', 'b', 'c'],
        ],
      };
      expect(SmartReconciliationParser.detectBestSheet(sheets), isNull);
    });
  });

  group('parseCsv', () {
    test('parses comma CSV with quoted fields and CRLF', () {
      final rows = SmartReconciliationParser.parseCsv(
          'Product,Opening,Supplied,Total,Physical,Dispensed,Price\r\n'
          '"Paracetamol, 500mg",10,20,30,8,22,2.5\r\n'
          'Panadol,5,5,10,10,0,3\r\n');
      expect(rows, hasLength(3));
      expect(rows[1][0], 'Paracetamol, 500mg');
      expect(rows[2][6], '3');
    });

    test('sniffs semicolon delimiters', () {
      final rows = SmartReconciliationParser.parseCsv(
          'Product;Opening;Supplied;Total;Physical;Dispensed;Price\n'
          'Panadol;5;5;10;10;0;3\n');
      expect(rows[1], hasLength(7));
      expect(rows[1][0], 'Panadol');
      expect(rows[1][3], '10');
    });

    test('strips a leading BOM', () {
      final rows = SmartReconciliationParser.parseCsv(
          '\uFEFFProduct,Opening\nPanadol,5\n');
      expect(rows[0][0], 'Product');
    });
  });

  group('CSV end-to-end smart import', () {
    test('CSV with junk rows imports only valid records', () {
      final rows = SmartReconciliationParser.parseCsv('''
Product,Opening Balance,Received,Total Stock,Counted,Dispensed,Unit Price
Paracetamol,10,20,30,8,22,2.5
,,,
CATEGORY: ANTIBIOTICS,,,,,,
Amoxil,4,6,10,9,1,4
GRAND TOTAL,500,900,1400,400,1000,
''');
      final match =
          SmartReconciliationParser.detectBestSheet({'CSV': rows});
      expect(match, isNotNull);
      final records = match!.parse.records;
      expect(records, hasLength(2));
      expect(records.map((r) => r['name']),
          containsAll(['Paracetamol', 'Amoxil']));
      expect(match.parse.skipped.map((s) => s.reason),
          contains('summary row'));
      // price defaulted only on rows that reached import (GRAND TOTAL
      // was skipped as a summary row before price handling).
      expect(match.parse.priceDefaultedCount, 0);
    });
  });
}
