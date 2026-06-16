---
title: Home & Dashboard
description: The Home page is your operational command center — KPIs, inventory health, movement pulse, and fast actions.
---

# Home & Dashboard

The **Home** page is the first thing you see after signing in. It is your
operational command center: a single screen that tells you what is happening
across your pharmacy right now.

---

## Page anatomy

The Home page is organised into five regions, top to bottom:

1. **Page header** with period selector and **Add Product** action.
2. **Overview metric cards** — four KPIs that summarise the entire pharmacy.
3. **Two-panel layout** — Inventory Health (left) and Movement Pulse (right).
4. **Fast Actions grid** — one-click navigation to the most-used modules.
5. **Supply Watchlist** — items requiring restock soon.

---

## Overview metric cards

| Card | What it shows | Source |
|---|---|---|
| **Total Stock Value** | The ZMK value of every unit on your shelves (sum of `price × quantity` for all stock). | `StockRecord` |
| **Items Near Expiry** | Count of SKUs expiring within 30 days. | `StockRecord.expiryDate` |
| **Active Stock Items** | Total unique SKUs with `quantity > 0`. | `StockRecord` |
| **Low Stock Alerts** | Number of products that have dropped below their reorder level. | `LowStockAlertRecord` |

!!! tip "Period selector"
    The **Today / 7D / 30D** pills above the cards change the time window for
    the metrics that depend on time (e.g. Items Near Expiry). Total Stock
    Value is always a snapshot of *now*.

---

## Inventory Health

The **Inventory Health** panel lists the top six stock items that need
attention — items that are low, expiring soon, or out of stock.

Each row shows:

- Product name and category icon
- Current quantity and reorder level
- Status pill (Out of Stock / Low Stock / In Stock)
- Days until expiry (if applicable)

Click any row to drill into the [Inventory Details](store-inventory.md#item-details)
page.

---

## Movement Pulse

The **Movement Pulse** panel shows what has been happening in your pharmacy
recently:

- **Sales count** — number of sales in the selected period.
- **Goods received count** — number of supplier deliveries.
- **Stock movements count** — total in/out/transfer/adjustment events.

Below the counts, the four most recent movements appear as tiles with the
product name, movement type, and quantity.

---

## Fast Actions

The Fast Actions grid gives you one-click access to the modules you use
every day:

| Action | Destination |
|---|---|
| Point of Sale | [Point of Sale](pharmacy-tools.md#point-of-sale) |
| Pharmacy Inventory | [Store Inventory](store-inventory.md) |
| Goods Received | [Goods Received](goods-received.md) |
| Batches & Expiry | [Batches & Expiry](batches.md) |
| Stock Movements | [Stock Movements](stock-movements.md) |
| Low Stock Alerts | [Low Stock Alerts](low-stock-alerts.md) |
| Replenishment | [Replenishment](replenishment.md) |

---

## Quick tools

Below Fast Actions, the Quick Tools row surfaces specialty tools:

- **Point of Sale** — the legacy POS interface with a shopping cart.
- **HR Portal** — shortcut to Human Resource (Owner-only).
- **AI Assistant** — currently in preview; see [Pharmacy Tools](pharmacy-tools.md).
- **Calculators** — opens the in-house BMI calculator.

---

## The header actions

| Button | What it does |
|---|---|
| **Today / 7D / 30D** | Changes the time window for time-based metrics. |
| **Export** *(icon)* | Reserved for future CSV/PDF export of dashboard data. |
| **Add Product** | Navigates to the Add Product form, pre-scoped to the Medicine category. |

---

## What the Home page does *not* do

- It does not show financial P&L — that lives in [Finances](finances.md).
- It does not show staff performance — that lives in [Human Resource](human-resource.md).
- It does not show pending approvals — that lives in [Pending Approvals](pending-approvals.md).

The Home page is intentionally focused on **operational** health: stock,
movements, and alerts. For commercial and people metrics, use the dedicated
modules.

---

## Tips for getting the most out of Home

!!! tip "Pin frequently used actions"
    The Fast Actions grid is fixed in order. If you find yourself always
    going to Batches & Expiry, consider bookmarking its URL for even faster
    access.

!!! tip "Watch the Low Stock Alerts card"
    If the Low Stock Alerts count is greater than zero, click the card to go
    straight to the [Low Stock Alerts](low-stock-alerts.md) page and
    acknowledge or order the items.

!!! warning "Items Near Expiry is a leading indicator"
    A high Items Near Expiry count means you are about to lose money to
    expired stock. Click into the list and discount or dispense those items
    first.
