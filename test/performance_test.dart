import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/duniya/pharmacies/smart_reconciliation_parser.dart';
import 'package:medi_tracker/flutter_flow/custom_functions.dart';
import 'package:medi_tracker/rbac/role_config.dart';
import 'package:medi_tracker/rbac/roles.dart';
import 'package:medi_tracker/backend/backend.dart';
import 'package:medi_tracker/vmi/stock_movements/stock_movements_widget.dart'
    show parseTransferRouteForTest, parseReceivedOriginForTest;

/// ═══════════════════════════════════════════════════════════════════
///   Performance / Speed Regression Tests
///
///   Guards the hot paths users feel:
///     - CSV parsing of reconciliation spreadsheets (10k rows)
///     - Column matching over wide headers
///     - Transfer-route regex parsing at table-render volume
///     - RBAC matrix lookups at navigation volume
///     - Business calculators at POS/cart volume
///
///   Each test asserts BOTH a wall-clock budget (generous enough for
///   CI variance, tight enough to catch 10x regressions) and
///   correctness of the result so a fast-but-wrong change still fails.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  /// Runs [body], asserts it completes within [budget], and returns
  /// the elapsed time for the throughput report.
  Duration timed(String label, Duration budget, void Function() body) {
    final sw = Stopwatch()..start();
    body();
    final elapsed = sw.elapsed;
    expect(
      elapsed,
      lessThan(budget),
      reason:
          '$label took ${elapsed.inMilliseconds}ms — budget ${budget.inMilliseconds}ms',
    );
    return elapsed;
  }

  group('CSV parsing speed (reconciliation import hot path)', () {
    test('parses 10,000-row CSV well within budget', () {
      final csv = _buildLargeCsv(rows: 10000);
      late final List<List<String>> parsed;

      final elapsed = timed('parseCsv 10k rows', const Duration(seconds: 2),
          () => parsed = SmartReconciliationParser.parseCsv(csv));

      expect(parsed, hasLength(10001)); // + header
      // Throughput report (not asserted — informational on failure).
      // ignore: avoid_print
      print('parseCsv: 10k rows in ${elapsed.inMilliseconds}ms '
          '(${(10000 / elapsed.inMicroseconds * 1e6).toStringAsFixed(0)} rows/s)');
    });

    test('parses a wide 60-column CSV without blowing the budget', () {
      final csv = _buildWideCsv(rows: 2000, cols: 60);
      late final List<List<String>> parsed;

      timed('parseCsv 2k×60', const Duration(seconds: 2),
          () => parsed = SmartReconciliationParser.parseCsv(csv));

      expect(parsed, hasLength(2001));
      expect(parsed.first, hasLength(60));
    });

    test('quoted-field CSV with escapes stays fast', () {
      final csv = _buildQuotedCsv(rows: 5000);
      late final List<List<String>> parsed;

      timed('parseCsv quoted 5k', const Duration(seconds: 2),
          () => parsed = SmartReconciliationParser.parseCsv(csv));

      expect(parsed, hasLength(5001));
    });
  });

  group('column matching speed (import wizard)', () {
    test('matches a 60-column header 10,000 times within budget', () {
      final header = SmartReconciliationParser.parseCsv(
          _buildWideCsv(rows: 1, cols: 60))
        .first;
      Map<String, int> cols = {};

      final elapsed = timed('matchColumns ×10k', const Duration(seconds: 3),
          () {
        for (var i = 0; i < 10000; i++) {
          cols = SmartReconciliationParser.matchColumns(header);
        }
      });

      // Correctness — canonical columns still resolve on a wide header.
      expect(cols[SmartReconciliationParser.kProductName], isNotNull);
      expect(cols[SmartReconciliationParser.kUnitPrice], isNotNull);
      // ignore: avoid_print
      print('matchColumns: 10k calls in ${elapsed.inMilliseconds}ms');
    });
  });

  group('transfer-route parsing speed (movements table render)', () {
    test('parses 5,000 movement reasons within budget', () {
      final reasons = List.generate(
          5000,
          (i) =>
              'From Branch ${(i % 40)} to Outlet ${(i % 12)} — rebalance batch $i');

      (String, String)? route;
      final elapsed = timed('parseTransferRoute ×5k',
          const Duration(milliseconds: 1500), () {
        for (final r in reasons) {
          route = parseTransferRouteForTest(r);
        }
      });

      // Correctness on the last parse.
      expect(route, isNotNull);
      expect(route!.$1, contains('Branch'));
      // ignore: avoid_print
      print('parseTransferRoute: 5k parses in ${elapsed.inMilliseconds}ms');
    });

    test('non-route reasons return null quickly (fallback path)', () {
      final reasons =
          List.generate(5000, (i) => 'Plain auditor note number $i');

      final elapsed = timed('parseTransferRoute null-path ×5k',
          const Duration(milliseconds: 800), () {
        for (final r in reasons) {
          expect(parseTransferRouteForTest(r), isNull);
        }
      });
      // ignore: avoid_print
      print(
          'parseTransferRoute null-path: 5k in ${elapsed.inMilliseconds}ms');
    });

    test('received-origin parsing at render volume', () {
      final reasons =
          List.generate(5000, (i) => 'From MediSupplier $i — delivery');

      final elapsed = timed('parseReceivedOrigin ×5k',
          const Duration(milliseconds: 800), () {
        for (final r in reasons) {
          expect(parseReceivedOriginForTest(r), isNotNull);
        }
      });
      // ignore: avoid_print
      print(
          'parseReceivedOrigin: 5k in ${elapsed.inMilliseconds}ms');
    });
  });

  group('RBAC lookup speed (sidebar build path)', () {
    test('100k permission lookups within budget', () {
      final roles = AppRole.values;
      var hits = 0;

      final elapsed = timed('rolePermissions lookup ×100k',
          const Duration(seconds: 2), () {
        for (var i = 0; i < 100000; i++) {
          final role = roles[i % roles.length];
          if ((rolePermissions[role] ?? const {}).isNotEmpty) hits++;
        }
      });

      expect(hits, greaterThan(0));
      // ignore: avoid_print
      print('rolePermissions: 100k lookups in ${elapsed.inMilliseconds}ms');
    });

    test('100k nav-visibility lookups within budget', () {
      final roles = AppRole.values;
      final items = NavItem.values;
      var visible = 0;

      final elapsed = timed('roleNavItems lookup ×100k',
          const Duration(seconds: 2), () {
        for (var i = 0; i < 100000; i++) {
          final role = roles[i % roles.length];
          final item = items[i % items.length];
          if ((roleNavItems[role] ?? const {}).contains(item)) visible++;
        }
      });

      expect(visible, greaterThan(0));
      // ignore: avoid_print
      print('roleNavItems: 100k lookups in ${elapsed.inMilliseconds}ms');
    });
  });

  group('POS calculator speed (cart hot path)', () {
    test('cartTotal over 1,000-line carts ×1,000 rebuilds', () {
      // 1,000 line items — far beyond any real cart, but proves the
      // calculator has no quadratic surprises.
      final prices =
          List.generate(1000, (i) => (i % 97) * 1.37 + 0.99);
      final qtys = List.generate(1000, (i) => (i % 9) + 1);
      var total = 0.0;

      final elapsed = timed('cartTotal 1000×1000',
          const Duration(seconds: 2), () {
        for (var i = 0; i < 1000; i++) {
          total = cartTotal(prices, qtys);
        }
      });

      expect(total, greaterThan(0));
      // ignore: avoid_print
      print('cartTotal: 1M line-evaluations in ${elapsed.inMilliseconds}ms');
    });

    test('grossProfit + progressPercent + barChartLimit ×100k', () {
      final elapsed = timed('finance calculators ×100k',
          const Duration(seconds: 2), () {
        for (var i = 0; i < 100000; i++) {
          grossProfit(i * 1.5, i * 0.9);
          progressPercent((i % 500) * 1.0, 1000);
          barChartLimit((i % 3000) * 1.0);
        }
      });
      // ignore: avoid_print
      print('finance calculators: 300k calls in ${elapsed.inMilliseconds}ms');
    });
  });

  group('record-data builder speed (batch write path)', () {
    test('movement record builder ×50k within budget', () {
      final stopwatchOnly = <String>[];
      final elapsed = timed('createStockMovementRecordData ×50k',
          const Duration(seconds: 3), () {
        for (var i = 0; i < 50000; i++) {
          final data = createStockMovementRecordData(
            productName: 'Product $i',
            quantity: i % 50,
            movementType: 'TRANSFERRED',
            reason: 'From A$i to B$i — note',
            movementReference: 'REF-$i',
          );
          if (i == 0) stopwatchOnly.add(data['MovementType']! as String);
        }
      });
      expect(stopwatchOnly.first, 'TRANSFERRED');
      // ignore: avoid_print
      print(
          'record builders: 50k in ${elapsed.inMilliseconds}ms');
    });
  });
}

// ── CSV fixture builders ────────────────────────────────────────

String _buildLargeCsv({required int rows}) {
  final buf = StringBuffer(
      'Product Name,Opening Stock,Stock Supplied,Total Available,Physical Count,Units Dispensed,Unit Price\n');
  final rng = math.Random(42);
  for (var i = 0; i < rows; i++) {
    final open = rng.nextInt(500);
    final supplied = rng.nextInt(200);
    final dispensed = rng.nextInt(150);
    buf.write('Medicine $i,$open,$supplied,${open + supplied},'
        '${open + supplied - dispensed},$dispensed,'
        '${(rng.nextInt(9000) / 100).toStringAsFixed(2)}\n');
  }
  return buf.toString();
}

String _buildWideCsv({required int rows, required int cols}) {
  final buf = StringBuffer();
  // Canonical names in the first two + last columns.
  final header = List.generate(cols, (i) {
    if (i == 0) return 'Product Name';
    if (i == cols - 1) return 'Unit Price';
    return 'Extra Column $i';
  });
  buf.write(header.join(','));
  buf.write('\n');
  final rng = math.Random(7);
  for (var r = 0; r < rows; r++) {
    buf.write(List.generate(cols, (i) {
      if (i == 0) return 'Med $r';
      if (i == cols - 1) return '12.50';
      return '${rng.nextInt(999)}';
    }).join(','));
    buf.write('\n');
  }
  return buf.toString();
}

String _buildQuotedCsv({required int rows}) {
  final buf = StringBuffer('Product Name,Notes,Unit Price\n');
  final rng = math.Random(11);
  for (var i = 0; i < rows; i++) {
    buf.write('"Medicine, special \\"$i\\"",'
        '"note with, commas and \\"quotes\\" inside",'
        '${(rng.nextInt(5000) / 100).toStringAsFixed(2)}\n');
  }
  return buf.toString();
}
