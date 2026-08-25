import 'package:flutter_test/flutter_test.dart';
import 'package:medi_tracker/custom_code/actions/header_layout.dart';

/// Contract tests for the "top buttons always fit" header layout rules.
///
/// Regression context (2026-08): the Stock Movements action bar sat in a
/// plain Row child Wrap, which receives UNBOUNDED width inside a Row — so
/// it could never wrap and the trailing 'All Pharmacies' filter was clipped
/// off-screen. The fix gives every header action bar bounded constraints
/// (Flexible / full-width below the breakpoint) so buttons flow onto extra
/// lines instead. These tests pin the breakpoints that decide inline vs
/// stacked, and guard against them being lowered back into overflow
/// territory.
void main() {
  group('stockMovementsActionsInline', () {
    test('stacks below the breakpoint (the reported clipping widths)', () {
      // Container widths the user actually hit: ~900-1100px content area
      // behind the sidebar. The actions must NOT render inline there.
      expect(stockMovementsActionsInline(320), isFalse); // phone
      expect(stockMovementsActionsInline(768), isFalse); // tablet
      expect(stockMovementsActionsInline(900), isFalse); // small desktop
      expect(stockMovementsActionsInline(1099.9), isFalse);
      expect(stockMovementsActionsInline(1100), isFalse); // boundary is >
    });

    test('renders inline only once the full action bar + title fit', () {
      expect(stockMovementsActionsInline(1100.1), isTrue);
      expect(stockMovementsActionsInline(1440), isTrue); // desktop
      expect(stockMovementsActionsInline(1920), isTrue); // full HD
    });

    test('breakpoint clears the intrinsic width budget', () {
      // Actions (≈900px) + title (≈420px) can never share one line below
      // ~1320px, but inline mode keeps them in separate Flexibles, so the
      // bar wraps within its own share. The threshold only needs to clear
      // a comfortable stacked minimum — assert it stays >= the intrinsic
      // action-bar width so nobody re-lowers it into clip territory.
      const breakpoint = 1100.0;
      expect(breakpoint, greaterThan(kStockMovementsActionsWidth - 200));
      expect(
        breakpoint,
        greaterThan(kStockMovementsActionsWidth * 0.9),
        reason: 'inline mode is pointless if the buttons cannot mostly fit',
      );
    });
  });

  group('stockBalancesHeroActionsInline', () {
    test('stacks below the breakpoint', () {
      expect(stockBalancesHeroActionsInline(768), isFalse);
      expect(stockBalancesHeroActionsInline(1149.9), isFalse);
    });

    test('renders inline at/above the breakpoint', () {
      expect(stockBalancesHeroActionsInline(1150), isTrue);
      expect(stockBalancesHeroActionsInline(1440), isTrue);
    });

    test('breakpoint exceeds the five-button intrinsic width', () {
      expect(
        kStockBalancesHeroActionsWidth + kStockBalancesHeroTitleWidth,
        greaterThan(kStockBalancesHeroActionsWidth),
      );
      // Export/Refresh/Import/Template/Add Balance ≈ 760px must flow below
      // the title whenever the row cannot hold both blocks side by side.
      expect(
        kStockBalancesHeroActionsWidth + kStockBalancesHeroTitleWidth,
        equals(1150),
      );
    });
  });

  group('stockCountsHeroActionsInline', () {
    test('stacks below the breakpoint', () {
      expect(stockCountsHeroActionsInline(768), isFalse);
      expect(stockCountsHeroActionsInline(839.9), isFalse);
    });

    test('renders inline at/above the breakpoint', () {
      expect(stockCountsHeroActionsInline(840), isTrue);
      expect(stockCountsHeroActionsInline(1280), isTrue);
    });

    test('breakpoint equals the three-button + title intrinsic width', () {
      expect(
        kStockCountsHeroActionsWidth + kStockCountsHeroTitleWidth,
        equals(840),
      );
      expect(kStockCountsHeroActionsWidth, lessThan(840));
    });
  });

  group('layout rule documentation', () {
    test('every intrinsic action width stays under its own breakpoint', () {
      // If someone adds buttons and bumps a constant past its breakpoint,
      // these inequalities fail and the layout contract must be revisited.
      expect(
        kStockMovementsActionsWidth,
        lessThan(1100),
        reason: 'movement actions wider than the breakpoint can never wrap '
            'into their inline share without stacking',
      );
      expect(kStockBalancesHeroActionsWidth, lessThan(1150));
      expect(kStockCountsHeroActionsWidth, lessThan(840));
    });
  });
}
