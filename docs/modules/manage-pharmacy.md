---
title: Manage Pharmacy
description: A tabbed operational view of a single pharmacy — inventory, balances, movements, batches, replenishment, alerts, outlets.
---

# Manage Pharmacy

The **Manage Pharmacy** page is a tabbed, operational deep-dive into a
single pharmacy. It pulls together seven views that would otherwise require
navigating between separate sidebar pages.

!!! info "How to get here"
    Go to **My Pharmacies → Manage** on any pharmacy card. The URL carries
    the `pharmacyName`, `pharmacyAddress`, and `pharmacyRef` query
    parameters.

---

## The seven tabs

| # | Tab | Content |
|---|---|---|
| 1 | Store Inventory | Per-product table: Product, Category, Qty, Price, Batch, Status. |
| 2 | Stock Balances | Per-product, per-period: Opening, Received, Dispensed, Closing, Value, DOS. |
| 3 | Stock Movements | Per-movement: Date, Type, Quantity, Reference, Reason, Status. |
| 4 | Batch & Expiry | Per-batch: Batch No., Quantity, Expiry, Days Left, Location, Status. |
| 5 | Replenishment | Suggested reorder queue for this pharmacy. |
| 6 | Low Stock Alerts | Items currently below reorder level. |
| 7 | Outlets | Per-outlet: Name, Code, Address, Status, Created, Actions. |

Each tab is functionally identical to the standalone page of the same name
— the only difference is that the data is pre-scoped to the selected
pharmacy.

---

## Metric cards

Above the tabs, five metric cards give you an instant snapshot:

| Card | Description |
|---|---|
| **Total Items** | Unique SKUs in this pharmacy. |
| **Stock Qty** | Total units across all products. |
| **Stock Value** | ZMK value of all stock. |
| **Low Stock** | Count of items below reorder level. |
| **Expiring Soon** | Count of batches expiring within 30 days. |

These cards update as you switch tabs — they always reflect the current
pharmacy.

---

## The Outlets tab

The Outlets tab is the most distinct from its standalone equivalent. It
shows a table of every outlet in the pharmacy:

| Column | Description |
|---|---|
| **Outlet Name** | Display name. |
| **Code** | The outlet code (e.g. *MAIN-01*). |
| **Address** | Physical location. |
| **Status** | Active / Inactive. |
| **Created** | When the outlet was added. |
| **Actions** | Edit, delete. |

Click **Add Outlet** to launch the Add Outlet dialog (Outlet Name *,
Outlet Code *, Address).

---

## Why use Manage Pharmacy instead of the standalone pages?

- **Scoped view** — every tab is pre-filtered to one pharmacy. No risk of
  accidentally viewing another pharmacy's data.
- **Faster navigation** — switch between inventory, batches, and movements
  without reloading.
- **Single source of truth** — the metric cards at the top give you a
  consistent snapshot regardless of which tab you are on.

For cross-pharmacy views (e.g. total stock value across all pharmacies),
use the standalone [Finances](finances.md) page or the
[Home](home.md) dashboard.

---

## Tips

!!! tip "Use the URL to deep-link"
    The Manage Pharmacy URL carries the `pharmacyRef` parameter. Bookmark
    it or share it with a colleague to take them straight to a specific
    pharmacy's detail view.

!!! tip "The Outlets tab is the fastest way to add an outlet"
    Even though outlets can be added from the My Pharmacies page, the
    Outlets tab here gives you a cleaner table view of all outlets in the
    current pharmacy.

!!! warning "Deactivating an outlet from here affects all VMI pages"
    If you toggle an outlet to inactive, every VMI page that references
    that outlet (Sales, Goods Received, Stock Counts) will stop showing it
    in dropdowns. Existing data is preserved.
