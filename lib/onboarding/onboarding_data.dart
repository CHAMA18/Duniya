import 'package:flutter/material.dart';

/// A single step within an onboarding chapter.
class OnboardingStep {
  const OnboardingStep({
    required this.headline,
    required this.body,
    required this.bullets,
    this.icon = Icons.check_circle_outline,
  });

  /// Short, punchy headline (e.g. "Record a sale in seconds").
  final String headline;

  /// One-paragraph explanation of the feature.
  final String body;

  /// Concrete tips / sub-features. Rendered as a checklist.
  final List<String> bullets;

  /// Icon used in the illustration circle.
  final IconData icon;
}

/// A chapter = one major area of the app (Dashboard, Inventory, etc.).
class OnboardingChapter {
  const OnboardingChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.steps,
  });

  /// Stable identifier used to persist "seen" state.
  final String id;

  /// Chapter title shown in the chapter strip and on the chapter
  /// divider page (e.g. "Your Dashboard").
  final String title;

  /// One-line description shown under the title.
  final String subtitle;

  /// Two-color gradient for the chapter's illustration header.
  final List<Color> gradient;

  /// Icon representing the chapter.
  final IconData icon;

  /// Ordered steps within this chapter.
  final List<OnboardingStep> steps;

  /// Total number of content pages = steps + 1 (the chapter divider).
  int get pageCount => steps.length + 1;
}

/// The full onboarding curriculum, ordered to mirror the natural
/// first-day workflow of a pharmacy user:
///   1. Dashboard orientation
///   2. Inventory & products
///   3. Goods received
///   4. Sales & dispensing
///   5. Stock intelligence
///   6. Get help & next steps
final List<OnboardingChapter> kOnboardingChapters = [
  OnboardingChapter(
    id: 'dashboard',
    title: 'Your Dashboard',
    subtitle: 'The command centre for every pharmacy you manage.',
    gradient: const [Color(0xFF6D28D9), Color(0xFF9900FF)],
    icon: Icons.dashboard_rounded,
    steps: [
      OnboardingStep(
        headline: 'Welcome to Duniya',
        body:
            'Your dashboard is the first thing you see after logging in. '
            'It gives you an at-a-glance view of stock value, today\'s sales, '
            'low-stock alerts, and near-expiry items across every pharmacy '
            'you manage — so you can spot problems before they become problems.',
        bullets: [
          'KPI cards show revenue, items sold, and inventory value in real time',
          'Switch between pharmacies with the selector at the top of the page',
          'The period filter (Today / 7D / 30D) recalculates every metric instantly',
        ],
        icon: Icons.waving_hand_rounded,
      ),
      OnboardingStep(
        headline: 'Read your KPI cards',
        body:
            'Each card answers one question: How much did I sell? What\'s my '
            'stock worth? How many items are about to run out? Tap any card '
            'to jump straight to the underlying list — for example, tapping '
            '"Low Stock Alerts" opens the alerts page pre-filtered to items '
            'that need reordering.',
        bullets: [
          'Total stock value — the current retail value of everything on your shelves',
          'Today\'s sales — revenue and units sold since midnight',
          'Near expiry — items within 60 days of their expiry date',
        ],
        icon: Icons.insights_rounded,
      ),
      OnboardingStep(
        headline: 'Switch pharmacies & periods',
        body:
            'If you manage more than one pharmacy, use the pharmacy selector '
            'in the top bar to switch scope. Every page — sales, inventory, '
            'goods received — respects the selected pharmacy. The period '
            'filter on the dashboard lets you compare today against the last '
            'week or month without leaving the page.',
        bullets: [
          'Pharmacy selector remembers your last choice for the session',
          'Period filter applies to dashboard KPIs only — list pages always show everything',
          'Owner accounts see all their pharmacies; staff see only their assigned pharmacy',
        ],
        icon: Icons.swap_horiz_rounded,
      ),
    ],
  ),
  OnboardingChapter(
    id: 'inventory',
    title: 'Inventory & Products',
    subtitle: 'Add products, track stock levels, and keep your catalogue tidy.',
    gradient: const [Color(0xFF7C3AED), Color(0xFFA855F7)],
    icon: Icons.inventory_2_rounded,
    steps: [
      OnboardingStep(
        headline: 'Add a product',
        body:
            'Open "Add Product" from the sidebar. Fill in the product name, '
            'select a category, set the selling price and reorder threshold, '
            'and save. The product immediately appears in your catalogue and '
            'can be added to stock, sales, and goods received.',
        bullets: [
          'Category is required — it drives the catalogue filters and the category page',
          'The reorder threshold triggers a low-stock alert when quantity falls below it',
          'Set a batch number and expiry date so the system can warn you before expiry',
        ],
        icon: Icons.add_box_rounded,
      ),
      OnboardingStep(
        headline: 'Browse the product catalogue',
        body:
            'The Product Catalogue page lists every product in your master '
            'list. Search by name or SKU, filter by category, and use the '
            '"Import Excel" button to bulk-upload products. Tap "Download '
            'Template" first to get a pre-formatted spreadsheet with the '
            'exact column headers and an example row.',
        bullets: [
          'Download Template gives you a .xlsx with headers + instructions',
          'Import Excel accepts .xlsx, .xls, and .csv — column aliases like "Qty" are recognised',
          'Each product can be edited inline from the catalogue',
        ],
        icon: Icons.library_books_rounded,
      ),
      OnboardingStep(
        headline: 'View stock by category',
        body:
            'Tap any category chip on the inventory page to see only products '
            'in that category. This is the fastest way to find every medicine, '
            'every personal-care item, or every veterinary product on your '
            'shelves — useful for cycle counts and category-specific audits.',
        bullets: [
          'Categories match the ones in the Add Product dropdown',
          'The category view shows live quantity, price, and expiry for each item',
          'Tap an item to edit its details, update stock, or set a new reorder level',
        ],
        icon: Icons.category_rounded,
      ),
    ],
  ),
  OnboardingChapter(
    id: 'goods_received',
    title: 'Goods Received',
    subtitle: 'Record incoming stock so your inventory stays accurate.',
    gradient: const [Color(0xFF2563EB), Color(0xFF6D28D9)],
    icon: Icons.local_shipping_rounded,
    steps: [
      OnboardingStep(
        headline: 'Record a goods receipt',
        body:
            'When a supplier delivers stock, open Goods Received and tap '
            '"Add Receipt". Select the supplier, add each product line with '
            'the quantity received and the batch number, and save. The system '
            'automatically updates stock balances and creates a stock movement '
            'record for the audit trail.',
        bullets: [
          'Each receipt can contain multiple line items (products)',
          'Batch numbers link receipts to specific deliveries — essential for recalls',
          'The receipt date defaults to today but can be backdated if needed',
        ],
        icon: Icons.add_shopping_cart_rounded,
      ),
      OnboardingStep(
        headline: 'Track what came in',
        body:
            'The Goods Received list shows every receipt, newest first. Tap '
            'any receipt to see the full breakdown of products, quantities, '
            'and batch numbers. This is your receiving log — use it to '
            'reconcile supplier invoices and to trace any batch back to the '
            'day it arrived.',
        bullets: [
          'Each receipt links to the supplier and the staff member who received it',
          'Stock balances update instantly — no need to manually adjust quantities',
          'Receipts are immutable once saved; corrections are made via a new receipt',
        ],
        icon: Icons.receipt_long_rounded,
      ),
    ],
  ),
  OnboardingChapter(
    id: 'sales',
    title: 'Sales & Dispensing',
    subtitle: 'Record sales, dispense medicines, and review transaction history.',
    gradient: const [Color(0xFF059669), Color(0xFF10B981)],
    icon: Icons.point_of_sale_rounded,
    steps: [
      OnboardingStep(
        headline: 'Record a sale',
        body:
            'Open Sales / Dispensing and tap "New Sale". Select the pharmacy, '
            'optionally enter a patient reference, then add line items. Pick a '
            'product — the selling price auto-fills from the product master — '
            'enter the quantity dispensed, and tap +. Add as many line items '
            'as you need, then tap "Record Sale" to save.',
        bullets: [
          'Selling price auto-populates from ProductMaster — just enter the quantity',
          'Patient reference is optional but recommended for prescription medicines',
          'Stock levels and stock movements update automatically when the sale is saved',
        ],
        icon: Icons.add_shopping_cart_rounded,
      ),
      OnboardingStep(
        headline: 'Review recent sales',
        body:
            'The Recent Sales list on the Sales / Dispensing page shows every '
            'transaction, newest first. Each card shows the date, patient '
            'reference, total amount, and a live line-item summary. Tap any '
            'sale to open the full detail page — products dispensed, '
            'quantities, prices, and the staff member who recorded it.',
        bullets: [
          'KPI cards at the top show total revenue, today\'s sales, and average sale value',
          'Each sale card shows "N items · M units total" so you can identify it at a glance',
          'Tap "View Details" on any card to see the full line-item breakdown',
        ],
        icon: Icons.receipt_long_rounded,
      ),
      OnboardingStep(
        headline: 'Point of Sale',
        body:
            'For faster dispensing at the counter, use the Point of Sale page. '
            'Browse products by category, search by name, and tap the +/− '
            'counter on each product card to build a cart. When you\'re ready, '
            'open the cart drawer and check out — the sale is recorded and '
            'stock is decremented in one step.',
        bullets: [
          'POS is optimised for touch — large tap targets, no keyboard needed',
          'The cart persists across page navigations until you check out or clear it',
          'Low-stock and near-exppiry badges appear directly on product cards',
        ],
        icon: Icons.shopping_bag_rounded,
      ),
    ],
  ),
  OnboardingChapter(
    id: 'intelligence',
    title: 'Stock Intelligence',
    subtitle: 'Let the system flag what needs your attention.',
    gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
    icon: Icons.auto_awesome_rounded,
    steps: [
      OnboardingStep(
        headline: 'Low stock alerts',
        body:
            'When any product\'s quantity falls below its reorder threshold, '
            'it automatically appears on the Low Stock Alerts page. Use this '
            'as your daily reorder checklist — tap an alert to see the product '
            'details, then place an order with your supplier and record it as '
            'a goods receipt when it arrives.',
        bullets: [
          'Alerts are calculated in real time — no need to refresh',
          'Each alert shows current quantity vs. reorder threshold',
          'Tap an alert to jump to the product and adjust the threshold if needed',
        ],
        icon: Icons.warning_amber_rounded,
      ),
      OnboardingStep(
        headline: 'Batch & expiry tracking',
        body:
            'The Batch & Expiry page lists every batch in your inventory, '
            'sorted by expiry date. Items within 60 days of expiry are '
            'flagged so you can prioritise selling them before they expire. '
            'This is critical for compliance and for avoiding write-offs.',
        bullets: [
          'Each batch links back to the goods receipt that brought it in',
          'The expiry badge turns red within 30 days and amber within 60 days',
          'Stock movements record which batch was dispensed in each sale',
        ],
        icon: Icons.event_rounded,
      ),
      OnboardingStep(
        headline: 'Stock movements & counts',
        body:
            'Every time stock changes — a sale, a goods receipt, a manual '
            'adjustment, a damaged-stock write-off — a stock movement is '
            'recorded. The Stock Movements page is your complete audit log. '
            'Use Stock Counts to perform periodic cycle counts: the system '
            'shows the expected quantity, you enter the counted quantity, '
            'and any variance is recorded as an adjustment.',
        bullets: [
          'Stock Movements filters by date range, product, and movement type',
          'Stock Counts supports partial counts — count one category at a time',
          'Variances are logged with the staff member who performed the count',
        ],
        icon: Icons.swap_vert_rounded,
      ),
    ],
  ),
  OnboardingChapter(
    id: 'help',
    title: 'You\'re all set',
    subtitle: 'Replay this tour anytime, and reach out when you need help.',
    gradient: const [Color(0xFF9900FF), Color(0xFF6D28D9)],
    icon: Icons.celebration_rounded,
    steps: [
      OnboardingStep(
        headline: 'Replay the tour anytime',
        body:
            'Forgot where something is? Tap "Take Tour" at the bottom of the '
            'sidebar to relaunch this walkthrough. You can skip chapters '
            'you\'re already familiar with, or reset the tour to see it from '
            'the beginning.',
        bullets: [
          'Take Tour is always available in the sidebar, even after you\'ve completed the tour',
          'Use the chapter strip at the top to jump to any chapter directly',
          'Tap Skip to exit at any time — your progress is saved',
        ],
        icon: Icons.replay_rounded,
      ),
      OnboardingStep(
        headline: 'What to do next',
        body:
            'You\'re ready to start using Duniya. We recommend this order for '
            'your first day: (1) add a few products to your catalogue, '
            '(2) record a goods receipt for your current shelf stock, '
            '(3) record a test sale to see how stock updates. If you get '
            'stuck, tap Take Tour again or contact your account admin.',
        bullets: [
          'Start with Add Product → build your catalogue',
          'Then Goods Received → enter your opening stock levels',
          'Then Sales / Dispensing → record your first sale',
        ],
        icon: Icons.rocket_launch_rounded,
      ),
    ],
  ),
];

/// Flattened list of all steps across all chapters, with chapter metadata.
/// Used by the overlay's PageView to render one continuous flow.
class OnboardingPage {
  const OnboardingPage({
    required this.chapter,
    required this.isDivider,
    this.step,
  });

  final OnboardingChapter chapter;
  final bool isDivider;
  final OnboardingStep? step;
}

List<OnboardingPage> kOnboardingFlattenedPages() {
  final pages = <OnboardingPage>[];
  for (final chapter in kOnboardingChapters) {
    pages.add(OnboardingPage(chapter: chapter, isDivider: true));
    for (final step in chapter.steps) {
      pages.add(OnboardingPage(chapter: chapter, isDivider: false, step: step));
    }
  }
  return pages;
}
