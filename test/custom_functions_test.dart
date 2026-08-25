import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/flutter_flow/custom_functions.dart';

/// ═══════════════════════════════════════════════════════════════════
///   Custom (FlutterFlow) Business Logic — Unit Tests
///   Pure calculators used across POS, finance and analytics.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  group('bMICalculator', () {
    test('computes BMI = weight / height²', () {
      expect(bMICalculator(70, 1.75), closeTo(22.86, 0.01));
      expect(bMICalculator(50, 1.6), closeTo(19.53, 0.01));
      expect(bMICalculator(100, 2.0), closeTo(25.0, 0.001));
    });
  });

  group('bmidata classification', () {
    test('classifies the WHO bands', () {
      expect(bmidata(17.0), 'Underweight');
      expect(bmidata(18.5), 'Normal');
      expect(bmidata(22.0), 'Normal');
      expect(bmidata(24.9), 'Normal');
      expect(bmidata(25.0), 'Overweight');
      expect(bmidata(29.9), 'Overweight');
      expect(bmidata(30.0), 'Obese');
      expect(bmidata(40.0), 'Obese');
    });

    test('null in → null out', () {
      expect(bmidata(null), isNull);
    });
  });

  group('cartTotal', () {
    test('sums price × quantity across line items', () {
      expect(cartTotal([10.0, 20.0, 30.5], [2, 1, 3]), closeTo(131.5, 0.0001));
    });

    test('empty cart is zero', () {
      expect(cartTotal([], []), 0);
    });
  });

  group('incomeSum', () {
    test('sums revenue values', () {
      expect(incomeSum([100.0, 250.5, 49.5]), closeTo(400.0, 0.0001));
      expect(incomeSum([]), 0);
      expect(incomeSum([-50.0, 50.0]), 0);
    });
  });

  group('grossProfit', () {
    test('revenue minus COGS', () {
      expect(grossProfit(1000.0, 600.0), closeTo(400.0, 0.0001));
    });

    test('null revenue with COGS returns negative COGS', () {
      expect(grossProfit(null, 600.0), closeTo(-600.0, 0.0001));
    });

    test('both null returns zero', () {
      expect(grossProfit(null, null), 0);
    });

    test('null COGS returns full revenue', () {
      expect(grossProfit(750.0, null), closeTo(750.0, 0.0001));
    });
  });

  group('progressPercent', () {
    test('revenue over goal', () {
      expect(progressPercent(250.0, 1000.0), closeTo(0.25, 0.0001));
    });

    test('zero or null revenue returns 0', () {
      expect(progressPercent(null, 1000.0), 0);
      expect(progressPercent(0, 1000.0), 0);
    });
  });

  group('barChartLimit', () {
    test('always returns a power of ten above the value', () {
      expect(barChartLimit(5), 10);
      expect(barChartLimit(10), 100);
      expect(barChartLimit(999), 1000);
      expect(barChartLimit(1500), 10000);
    });

    test('non-positive input clamps to the minimum of 10', () {
      expect(barChartLimit(0), 10);
      expect(barChartLimit(-42), 10);
    });
  });

  group('totalPrice', () {
    test('quantity × price (integer truncation)', () {
      expect(totalPrice(3, 24.99), 74);
      expect(totalPrice(0, 100.0), 0);
    });
  });

  group('drugstally', () {
    test('counts comma-separated entries', () {
      expect(drugstally('Paracetamol,Amoxicillin,Ibuprofen'), 3);
      expect(drugstally('Paracetamol'), 1);
      expect(drugstally(''), 1); // single empty entry — documented behavior
    });

    test('null returns null', () {
      expect(drugstally(null), isNull);
    });
  });

  group('firstLetter', () {
    test('uppercases the first letter', () {
      expect(firstLetter('chungu'), 'C');
      expect(firstLetter('A'), 'A');
    });

    test('empty name returns the avatar placeholder', () {
      expect(firstLetter(''), 'U');
    });
  });

  group('paymentOneMonth', () {
    test('extends subscription by 30 days', () {
      final base = DateTime(2026, 1, 1);
      final extended = paymentOneMonth(base);
      expect(extended, isNotNull);
      expect(extended!.difference(base).inDays, 30);
    });

    test('null passes through', () {
      expect(paymentOneMonth(null), isNull);
    });
  });

  group('newDate', () {
    test('adds days to a date', () {
      expect(newDate(7, DateTime(2026, 8, 1)), DateTime(2026, 8, 8));
      expect(newDate(0, DateTime(2026, 8, 1)), DateTime(2026, 8, 1));
    });
  });

  group('resetCounter', () {
    test('zeroes counters older than 24h', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      expect(resetCounter(99.0, twoDaysAgo), 0);
    });

    test('keeps recent counters', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      expect(resetCounter(99.0, oneHourAgo), 99.0);
    });

    test('null time returns null', () {
      expect(resetCounter(99.0, null), isNull);
    });
  });
}
