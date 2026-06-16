---
title: Stock Balances
description: Period-by-period snapshots of opening, received, dispensed, and closing stock per outlet.
---

# Stock Balances

The **Stock Balances** page gives you a period-by-period view of how stock
has moved for every product, on every outlet. Think of it as a general
ledger for inventory — every row is a reconciliation of opening stock,
inflows, outflows, and closing stock for a specific period.

---

## Why stock balances matter

Stock Balances answer questions that no other module can:

- *"How much Paracetamol did we actually dispense last month?"*
- *"Did the Kiosk #1 outlet receive what we transferred to it?"*
- *"What is the days-of-stock remaining for our top 20 products?"*
- *"Why is our inventory value up but our sales flat?"*

If Stock Movements are the journal entries, Stock Balances are the trial
balance.

---

## The balance record

Each row in the Stock Balances table represents one product on one outlet
for one period. It carries:

| Field | Description |
|---|---|
| **Opening Stock** | Units on hand at the start of the period. |
| **Stock Received** | Units received from suppliers during the period. |
| **Stock Dispensed** | Units sold / dispensed during the period. |
| **Stock Transferred** | Net units transferred in (positive) or out (negative). |
| **Stock Adjusted** | Net units from ADJUSTMENT movements (damage, loss, recounts). |
| **Closing Stock** | Units on hand at the end of the period. Should equal `Opening + Received − Dispensed + Transferred + Adjusted`. |
| **Stock Value** | `Closing Stock × Cost of Goods` — the ZMK value on the shelf. |
| **Days of Stock Remaining** | `Closing Stock / (Dispensed / Period Days)` — how many days until you run out at current sales velocity. |
| **Period** | The time window (e.g. *2024-Q3*, *2024-09*). |
| **Outlet** | Which outlet this balance belongs to. |
| **Product** | Which product this balance is for. |

---

## Page anatomy

1. **Header** with **Period** filter.
2. **Search** by product name.
3. **Balances table** with the columns above.

---

## Reading the table

The most useful columns for day-to-day management are:

### Days of Stock Remaining (DOS)

DOS tells you how many days of demand your current stock will cover. A DOS
of 7 means you will run out in a week at current sales velocity. Use DOS
to:

- **Prioritise replenishment** — products with DOS < lead time are
  urgent.
- **Spot overstock** — a DOS of 180+ on a slow-moving product means
  capital is tied up unnecessarily.
- **Compare outlets** — if the main branch has DOS 30 and the kiosk has
  DOS 5, transfer stock.

### Closing Stock vs. Opening Stock

If Closing > Opening consistently across periods, you are over-ordering. If
Closing < Opening consistently, you are running stock down — possibly
intentionally (clearance) or unintentionally (stockout risk).

### Stock Adjusted

A high absolute value in the Adjusted column suggests process issues —
damage, theft, or inaccurate receiving. Investigate any product where
Adjusted exceeds 5% of Dispensed.

---

## Period filter

Use the **Period** dropdown to switch between:

- Monthly views (e.g. *2024-09*)
- Quarterly views (e.g. *2024-Q3*)
- Yearly views (e.g. *2024*)

The period determines which Stock Movements are aggregated into each
balance row.

---

## How balances are computed

Stock Balances are computed from the immutable Stock Movement ledger:

1. Take the opening stock at the start of the period.
2. Sum all `RECEIVED` movements for the period → `Stock Received`.
3. Sum all `SOLD` movements → `Stock Dispensed`.
4. Sum all `TRANSFERRED` movements (signed) → `Stock Transferred`.
5. Sum all `ADJUSTMENT` movements (signed) → `Stock Adjusted`.
6. Closing = Opening + Received − Dispensed + Transferred + Adjusted.
7. DOS = Closing / (Dispensed / days_in_period).

Because movements are immutable, balances can be recomputed at any time and
will always reconcile.

---

## Frequently asked questions

??? question "Why is my Closing Stock different from what Store Inventory shows?"
    Stock Balances shows the closing stock **at the end of the selected
    period**. Store Inventory shows the **current** on-hand quantity. If
    the period is not the current month, they will differ — that is
    expected.

??? question "Can I edit a balance?"
    No. Balances are computed, not entered. To change a balance, record a
    Stock Movement (which will flow through to the next period's balance).

??? question "How far back can I see balances?"
    As far back as you have Stock Movements. Balances are computed on
    demand from the movement ledger — there is no archival cutoff.

??? question "What if Days of Stock Remaining is `∞`?"
    That means the product had zero sales in the period. DOS is undefined
    when the denominator is zero. Treat it as "very high" — you have
    plenty of stock for current demand.
