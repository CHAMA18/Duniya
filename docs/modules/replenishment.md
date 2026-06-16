---
title: Replenishment
description: Get data-driven reorder recommendations based on your actual sales velocity and target stock levels.
---

# Replenishment

The **Replenishment** page is your reorder command center. Duniya analyzes
your sales velocity, current stock, and target stock levels to recommend
exactly what to order, in what quantity, and when.

---

## How recommendations are computed

For every product, Duniya calculates:

```
SuggestedOrderQty = TargetStockLevel − CurrentStock + (AverageWeeklySales × LeadWeeks)
```

Where:

- **TargetStockLevel** comes from the [Product Catalogue](product-catalogue.md).
- **CurrentStock** is the live on-hand quantity across all outlets.
- **AverageWeeklySales** is computed from recent `SOLD` Stock Movements.
- **LeadWeeks** is the supplier's typical delivery lead time (defaults to 1
  week if not configured).

Products are then ranked by urgency — the biggest gap between target and
current stock first.

---

## Page anatomy

1. **Header** with **Refresh** action.
2. **Suggested Restock Queue** table.
3. Per-row **Place Order** action.

---

## The restock queue

| Column | Description |
|---|---|
| **Product** | Name and SKU. |
| **Average Weekly Sales** | The product's sales velocity. |
| **Current Stock** | On-hand units across all outlets. |
| **Target Stock Level** | The optimal stock level from the catalogue. |
| **Suggested Order Qty** | The recommended order size. |
| **Period** | The time window used for the sales velocity calculation. |
| **Status** | Whether the recommendation is new, ordered, or fulfilled. |

The table is sorted by Suggested Order Qty descending — the biggest
recommended orders appear at the top.

---

## Refreshing recommendations

Click **Refresh** to recompute the queue. Duniya:

1. Recomputes AverageWeeklySales from the latest SOLD movements.
2. Re-fetches CurrentStock for every product.
3. Recomputes SuggestedOrderQty.
4. Resorts the queue.

A toast confirms: *"Replenishment recommendations refreshed"*.

!!! tip "Refresh after stock counts"
    After you approve a [Stock Count](stock-counts.md), always refresh the
    replenishment queue — the count may have corrected on-hand quantities
    that change the recommendations.

---

## Placing an order

When you are ready to order a product:

1. Find it in the queue.
2. Click **Place Order**.
3. Duniya navigates you to the [Goods Received](goods-received.md) page so
   you can record the incoming delivery when it arrives.

!!! info "Why Goods Received and not a purchase order?"
    Duniya does not yet have a dedicated Purchase Order module. The current
    flow is:

    1. Click **Place Order** on the replenishment queue.
    2. (Outside Duniya) Place the actual order with your supplier by phone,
       email, or their portal.
    3. When the delivery arrives, record it as a Goods Received receipt.
    4. Confirm the receipt — stock updates, the
       [Low Stock Alert](low-stock-alerts.md) resolves, and the
       replenishment queue recomputes on next refresh.

    A full Purchase Order module is on the roadmap.

---

## Tips for using Replenishment effectively

!!! tip "Keep your Target Stock Levels realistic"
    If your Target Stock Levels are too high, the queue will recommend huge
    orders you don't need. If too low, you will stock out. Review targets
    quarterly based on actual sales.

!!! tip "Set realistic Lead Weeks"
    If your supplier takes 2 weeks to deliver, make sure that is reflected
    in your replenishment calculation. The default is 1 week — adjust per
    supplier in future releases.

!!! tip "Don't ignore the queue"
    The replenishment queue is your single most useful tool for preventing
    stockouts. Check it daily during your morning routine.

---

## Frequently asked questions

??? question "Why is a product not in the queue?"
    Products only appear when `CurrentStock < TargetStockLevel`. If a
    product is already at or above its target, it does not need
    replenishment.

??? question "Can I see the queue for a single outlet?"
    The current queue is account-wide. Per-outlet filtering is on the
    roadmap.

??? question "How often should I refresh?"
    Once a day is usually enough. Refresh more often during promotions,
    flu season, or other demand spikes.

??? question "Can I export the queue?"
    A CSV/PDF export is on the roadmap. For now, you can screenshot the
    table or copy the values manually.
