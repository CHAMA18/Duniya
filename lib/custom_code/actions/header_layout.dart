/// Header layout contract shared by the inventory pages.
///
/// The "top buttons always fit" rule: every page-header action bar must be
/// given BOUNDED width constraints so its Wrap can flow onto extra lines.
/// A Wrap that sits directly inside a Row receives unbounded width and can
/// never wrap — that was the bug that clipped the filter dropdowns
/// off-screen on Stock Movements (2026-08).
///
/// These thresholds decide when the action bar renders inline next to the
/// title versus flowing beneath it. They are pure functions so the layout
/// contract is unit-testable (see test/header_layout_test.dart).
library;

/// Stock Movements header action bar intrinsic width budget.
///
/// Record Movement (~185px) + Import (~110px) + Template (~135px) +
/// two 180px filter dropdowns + Wrap spacing ≈ 900px; the title block
/// (icon badge + 'Stock Movements' + subtitle) needs ≈ 420px.
const double kStockMovementsActionsWidth = 900;
const double kStockMovementsTitleWidth = 420;

/// Above this container width the actions sit inline with the title;
/// at or below it they stack beneath the title (still wrapping freely).
bool stockMovementsActionsInline(double maxWidth) => maxWidth > 1100;

/// Stock Balances hero: Export / Refresh / Import / Template / Add Balance
/// ≈ 760px intrinsic + badge & title block ≈ 390px.
const double kStockBalancesHeroActionsWidth = 760;
const double kStockBalancesHeroTitleWidth = 390;

bool stockBalancesHeroActionsInline(double maxWidth) =>
    maxWidth >= kStockBalancesHeroActionsWidth + kStockBalancesHeroTitleWidth;

/// Stock Counts hero: Export / Refresh / New Count ≈ 460px intrinsic +
/// badge & title block ≈ 380px.
const double kStockCountsHeroActionsWidth = 460;
const double kStockCountsHeroTitleWidth = 380;

bool stockCountsHeroActionsInline(double maxWidth) =>
    maxWidth >= kStockCountsHeroActionsWidth + kStockCountsHeroTitleWidth;
