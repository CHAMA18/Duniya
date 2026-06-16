---
title: Finances
description: Real-time revenue, profit margins, accounts receivable, operating expenses, and transaction history.
---

# Finances

The **Finances** page is your financial command center. It aggregates
revenue, profit, receivables, and expenses across every pharmacy you own —
in real time, with drill-down to individual transactions.

!!! info "Owner-only"
    The Finances page is visible only to users with the **Owner** role.

---

## Page anatomy

1. **Header** with **Export Report** and **Point of Sale** buttons.
2. **KPI Grid** — Total Revenue, Profit Margin, Accounts Receivable,
   Operating Expenses.
3. **Revenue Analytics chart** with period toggle (1W / 1M / 1Y).
4. **Recent Transactions** table.
5. **Pending Approvals** section (embedded).

---

## KPI cards

| Card | Computation | Trend chip |
|---|---|---|
| **Total Revenue** | Sum of all `SalesRecord.Total_amount` in the period. | % change vs. previous period. |
| **Profit Margin** | `(Revenue − Cost of Goods) / Revenue × 100`. | % change vs. previous period. |
| **Accounts Receivable** | Outstanding invoices not yet paid. | % change vs. previous period. |
| **Operating Expenses** | Sum of expenses recorded in the period. | % change vs. previous period. |

The trend chip is colour-coded: green for positive change on revenue/profit
(good), red for negative; the colours flip for expenses (a rise is bad).

---

## Revenue analytics chart

The Revenue Analytics chart is a custom-painted bar chart (using
`CustomPaint` and a `_RevenueChartPainter`) that shows revenue over time.

### Period toggle

| Toggle | Time window | Granularity |
|---|---|---|
| **1W** | Last 7 days | Daily bars |
| **1M** | Last 30 days | Daily bars |
| **1Y** | Last 12 months | Monthly bars |

Hover over a bar to see the exact revenue figure for that period.

### How revenue is computed

Revenue is the sum of `TotalAmount` across all `SaleVMI` (and legacy
`Sales`) records whose `SaleDate` falls within the selected window. Refunds
and adjustments are not currently netted — they appear as separate
movements in the transaction table.

---

## Recent transactions

The transactions table lists every financial event, newest first:

| Column | Description |
|---|---|
| **Transaction ID** | Auto-generated (e.g. *#TXN-0001*). |
| **Date** | When the transaction occurred. |
| **Description** | Free-text or auto-generated (e.g. *"Sale to walk-in customer"*). |
| **Amount** | ZMK value. Positive for revenue, negative for expenses. |
| **Status** | Completed / Pending / Overdue. |

Click any row to drill into the [Sales Items](sales.md#sales-items-detail)
page for that transaction.

---

## Pending approvals (embedded)

The Finances page embeds a Pending Approvals section that lists users
awaiting Duniya admin approval:

- **Pharmacy registrations** — `accountType == 'pharmacy'` and
  `approved_by_duniya == false`.
- **Duniya user accounts** — `accountType == 'Duniya'` and
  `approved_by_duniya == false`.

For each pending user, click **Approve** to set `approved_by_duniya = true`
and grant them access. See [Pending Approvals](pending-approvals.md) for
the full workflow.

---

## Export report

The **Export Report** button (outlined) is reserved for future CSV/PDF
export of the financial summary. For now, you can:

- Screenshot the KPI cards.
- Print the page to PDF using your browser's *Print → Save as PDF*.
- Use the [Batches → Export PDF](batches.md#exporting-a-pdf-report) for
  inventory-specific reports.

---

## Point of Sale shortcut

The **Point of Sale** button (filled purple) is a shortcut to the legacy
POS interface — useful for recording a walk-in sale without leaving the
Finances context. See [Pharmacy Tools → Point of Sale](pharmacy-tools.md#point-of-sale).

---

## How financial data flows

```
Sale recorded ──► SalesRecord.Total_amount += sale total
                   │
                   ▼
              Finances: Total Revenue
                   │
                   ▼
              Profit Margin = (Revenue − COGS) / Revenue
                   │
                   ▼
              Recent Transactions table
```

Cost of Goods (COGS) is read from the Stock record at the time of sale.
If you edit a product's cost price after a sale, the historical sale's
profit is not recalculated — Duniya snapshots the COGS onto the Sale
record for accurate historical reporting.

---

## Frequently asked questions

??? question "Why does my profit margin look wrong?"
    Profit margin depends on accurate Cost of Goods values. If your stock
    records have `CostOfGoods = 0` (the default when not specified), the
    margin will appear artificially high. Audit your stock records'
    cost-of-goods field.

??? question "Can I see finances per pharmacy?"
    The current view is account-wide. Per-pharmacy financial breakdowns
    are on the roadmap. As a workaround, filter the Recent Transactions
    table by transaction ID prefix (each pharmacy has its own numbering).

??? question "Does Finances include pending (unconfirmed) Goods Received?"
    No. Only confirmed Goods Received hit the books. A pending receipt
    does not affect inventory value or operating expenses until it is
    confirmed.

??? question "How do I record an expense?"
    The current release does not have a dedicated expense entry form.
    Expenses are recorded via the Airtable integration
    (`AddExpensesCall`) which is configured at the backend. A UI for
    manual expense entry is on the roadmap.
