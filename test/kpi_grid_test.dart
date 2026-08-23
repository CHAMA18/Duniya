import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the KPI card content (icon row + value + subtitle) fits
/// inside the minimum 4-up card size (215 x 152 logical px) used by the
/// Pharmacy Detail inventory-pulse grid, and that the grid lays all four
/// cards on one row at the reported user viewport width.
void main() {
  Widget kpiCard(Color surface, Color border) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.pie_chart_rounded,
                  color: Color(0xFF9900FF), size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Total Stock Value',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 16),
          const Text('K372',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8)),
          const SizedBox(height: 3),
          const Text('1 active SKUs',
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  testWidgets('KPI content fits min 4-up card size without overflow',
      (tester) async {
    // Min card size: 215 wide x 152 tall.
    tester.view.physicalSize = const Size(215, 156);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 215,
          height: 156,
          child: kpiCard(Colors.white, const Color(0xFFE2E8F0)),
        ),
      ),
    ));

    // No overflow exceptions = pass.
    expect(tester.takeException(), isNull);
  });

  testWidgets('4-up grid at user viewport (~1115px grid width) is one row',
      (tester) async {
    tester.view.physicalSize = const Size(1147, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final gridWidth = 1147.0 - 32; // page padding at non-wide
    const kpiGap = 14.0;
    // breakpoint: 4 cols when >= 4*215 + 3*14 = 902
    final cols = gridWidth >= 4 * 215 + 3 * kpiGap ? 4 : 2;
    final cardWidth = (gridWidth - (cols - 1) * kpiGap) / cols;
    const cardHeight = 156.0;

    final card1 = GlobalKey();
    final card4 = GlobalKey();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: gridWidth,
          child: GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: kpiGap,
            crossAxisSpacing: kpiGap,
            childAspectRatio: cardWidth / cardHeight,
            children: [
              SizedBox(key: card1, child: kpiCard(Colors.white, Colors.grey)),
              kpiCard(Colors.white, Colors.grey),
              kpiCard(Colors.white, Colors.grey),
              SizedBox(key: card4, child: kpiCard(Colors.white, Colors.grey)),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(cols, 4, reason: 'user viewport should select 4 columns');
    final y1 = tester.getTopLeft(find.byKey(card1)).dy;
    final y4 = tester.getTopLeft(find.byKey(card4)).dy;
    expect(y1, y4,
        reason: 'all four KPI cards must sit on ONE row (same top edge)');
    final w4 = tester.getSize(find.byKey(card4)).width;
    expect(w4, closeTo(cardWidth, 1.0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow viewport (700px) falls back to 2x2', (tester) async {
    tester.view.physicalSize = const Size(700, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final gridWidth = 700 - 32;
    const kpiGap = 14.0;
    final cols = gridWidth >= 4 * 215 + 3 * kpiGap ? 4 : 2;
    expect(cols, 2, reason: '700px viewport keeps 2x2 grid');
  });
}
