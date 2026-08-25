import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medi_tracker/components/pulse_logo_widget.dart';

/// ═══════════════════════════════════════════════════════════════════
///   Brand Widget Smoke Tests
///
///   The default FlutterFlow counter test pumped `MyApp`, which runs
///   `Firebase.initializeApp()` — impossible in a unit-test VM. This
///   replaces it with a meaningful smoke test of the pure brand widget
///   (no Firebase dependency) plus a paint sanity check.
/// ═══════════════════════════════════════════════════════════════════
void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('logo renders the Pulse wordmark by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(const PulseLogoWidget(size: 48)));

    expect(find.text('Pulse'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wordmark is hidden when showWordmark is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        wrap(const PulseLogoWidget(size: 48, showWordmark: false)));

    expect(find.text('Pulse'), findsNothing);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('logo paints without exceptions at several sizes',
      (WidgetTester tester) async {
    for (final size in [24.0, 48.0, 96.0]) {
      await tester.pumpWidget(wrap(PulseLogoWidget(size: size)));
      expect(tester.takeException(), isNull,
          reason: 'Logo at size $size threw during paint');
    }
  });
}
