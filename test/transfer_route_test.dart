import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/vmi/stock_movements/stock_movements_widget.dart' show parseTransferRouteForTest, parseReceivedOriginForTest;

/// ═══════════════════════════════════════════════════════════════════
///   Transfer Route Parsing — Unit Tests
///
///   The movement dialog stores transfer routes in the reason field
///   ("From X to Y — note") and the table's Source / Destination
///   column parses them back for display. These tests lock the
///   format contract between writer and reader.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  group('parseTransferRoute', () {
    test('parses a full "From X to Y" route', () {
      final route = parseTransferRouteForTest(
          'From Main branch to North ridge');
      expect(route, isNotNull);
      expect(route!.$1, 'Main branch');
      expect(route.$2, 'North ridge');
    });

    test('parses a route with a trailing note', () {
      final route = parseTransferRouteForTest(
          'From Main branch to North ridge — quarterly rebalance');
      expect(route, isNotNull);
      expect(route!.$1, 'Main branch');
      expect(route.$2, 'North ridge');
    });

    test('parses a route with a hyphenated note', () {
      final route = parseTransferRouteForTest(
          'From Store A to Store B - urgent order');
      expect(route, isNotNull);
      expect(route!.$1, 'Store A');
      expect(route.$2, 'Store B');
    });

    test('partial route "From X" maps to unspecified destination', () {
      final route =
          parseTransferRouteForTest('From Main branch');
      expect(route, isNotNull);
      expect(route!.$1, 'Main branch');
      expect(route.$2, 'unspecified');
    });

    test('case-insensitive "from/to" keywords', () {
      final route = parseTransferRouteForTest(
          'from Warehouse to Outlet 3');
      expect(route, isNotNull);
      expect(route!.$1, 'Warehouse');
      expect(route.$2, 'Outlet 3');
    });

    test('returns null for reasons without route info', () {
      expect(parseTransferRouteForTest(''), isNull);
      expect(parseTransferRouteForTest('Quarterly count'),
          isNull);
      expect(
          parseTransferRouteForTest('GRN-0042 received'),
          isNull);
    });
  });

  group('parseReceivedOrigin', () {
    test('parses "From X" supplier origin', () {
      expect(
          parseReceivedOriginForTest(
              'From MediSupply Ltd'),
          'MediSupply Ltd');
    });

    test('parses origin with a trailing note', () {
      expect(
          parseReceivedOriginForTest(
              'From MediSupply Ltd — March delivery'),
          'MediSupply Ltd');
    });

    test('returns null when no origin recorded', () {
      expect(parseReceivedOriginForTest(''), isNull);
      expect(parseReceivedOriginForTest('Restock'),
          isNull);
    });
  });
}
