---
title: The Inventory Cycle
description: The end-to-end operational loop every pharmacy runs through — from product setup to replenishment.
---

# The Inventory Cycle

Every pharmacy on Duniya runs through the same operational loop, again and
again. This page walks through the full cycle end-to-end, linking each
stage to the relevant module documentation.

---

## The cycle at a glance

```
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │   1. Define products      ──►  Product Catalogue            │
   │                                                             │
   │   2. Receive goods        ──►  Goods Received               │
   │                                                             │
   │   3. Track batches        ──►  Batches & Expiry             │
   │                                                             │
   │   4. Sell / dispense      ──►  Sales / Dispensing           │
   │                                                             │
   │   5. Move stock           ──►  Stock Movements              │
   │                                                             │
   │   6. Count stock          ──►  Stock Counts                 │
   │                                                             │
   │   7. Watch alerts         ──►  Low Stock Alerts             │
   │                                                             │
   │   8. Replenish            ──►  Replenishment                │
   │                                                             │
   └─────────────────────────────┬───────────────────────────────┘
                                 │
                                 ▼
                          (back to step 2)
```

Each stage feeds the next. Replenishment (step 8) loops back to Receiving
Goods (step 2) when the supplier delivery arrives.

---

## Stage 1 — Define products

Before you can receive or sell anything, you need a product catalogue.

**Owner / Pharmacist action:**

1. Go to **Product Catalogue** in the sidebar.
2. Click **Add Product**.
3. Fill in the product details — name, SKU, strength, dosage form,
   prices, and reorder levels.
4. Save.

For bulk setup, use the [Bulk Import](bulk-import.md) workflow to upload
a spreadsheet of products at once.

!!! tip "Set reorder levels thoughtfully"
    The **Reorder Level** and **Target Stock Level** you set here drive
    the entire replenishment cycle. Get them right and Duniya will keep
    you stocked automatically. Get them wrong and you will be drowning in
    false alerts.

📖 **Detailed docs:** [Product Catalogue](../modules/product-catalogue.md)

---

## Stage 2 — Receive goods

When a supplier delivery arrives, record it as a Goods Received receipt.

**Pharmacy Technician / Pharmacist action:**

1. Go to **Goods Received** in the sidebar.
2. Click **New Receipt**.
3. Enter the delivery note number and date.
4. Add a line item for each product in the delivery — quantity delivered,
   quantity received, batch number, expiry date.
5. Investigate any discrepancies (short shipments, damages).
6. Click **Confirm** to finalise the receipt.

Confirming the receipt automatically:

- Updates Stock records (or creates new ones).
- Creates Batch records in Batches & Expiry.
- Logs a `RECEIVED` Stock Movement.

📖 **Detailed docs:** [Goods Received](../modules/goods-received.md)

---

## Stage 3 — Track batches

Every batch you receive is tracked by expiry date. The Batches & Expiry
page classifies each batch into one of four urgency buckets.

**Pharmacist / Technician action:**

1. Go to **Batch & Expiry** in the sidebar.
2. Review the summary cards — anything in **Expired** or
   **Expiring < 3 Months** needs attention.
3. For expired batches: remove from shelves, record disposal as an
   ADJUSTMENT movement.
4. For soon-to-expire batches: apply FEFO (dispense first), discount, or
   return to supplier.
5. Use **Export PDF** for compliance reporting.

📖 **Detailed docs:** [Batches & Expiry](../modules/batches.md)

---

## Stage 4 — Sell / dispense

Every sale decrements stock and creates a financial transaction.

**Cashier / Pharmacist / Outlet Manager action:**

1. Go to **Sales / Dispensing** (prescription) or **Point of Sale**
   (walk-in).
2. Add line items — product, quantity.
3. For prescriptions, link a patient reference.
4. Confirm the sale.

Each sale:

- Creates a Sales record with line items.
- Logs a `SOLD` Stock Movement.
- Decrements the outlet's Stock record.
- May trigger a Low Stock Alert if the product drops below reorder.

📖 **Detailed docs:** [Sales & Dispensing](../modules/sales.md) ·
[Pharmacy Tools](../modules/pharmacy-tools.md)

---

## Stage 5 — Move stock

Stock moves between outlets, gets damaged, or needs to be adjusted for
recounts.

**Pharmacist / Technician action:**

1. Go to **Stock Movements** in the sidebar.
2. Click **Add Movement**.
3. Pick the type (TRANSFERRED, ADJUSTMENT) and fill in the details.
4. Save.

For transfers, the destination outlet must confirm receipt before stock
updates.

📖 **Detailed docs:** [Stock Movements](../modules/stock-movements.md)

---

## Stage 6 — Count stock

Regular stock counts reconcile the system's view with reality.

**Pharmacy Technician / Pharmacist action:**

1. Go to **Stock Counts** in the sidebar.
2. Click **Add** to create a new count.
3. On the detail page, enter the counted quantity for each product.
4. For each non-zero variance, write an explanation.
5. Click **Approve** to finalise.

Approving the count:

- Posts variances as ADJUSTMENT Stock Movements.
- Updates Stock records to match the counted quantities.

📖 **Detailed docs:** [Stock Counts](../modules/stock-counts.md)

---

## Stage 7 — Watch alerts

When stock drops below the reorder level, Duniya creates a Low Stock
Alert.

**Pharmacist / Outlet Manager action:**

1. Go to **Low Stock Alerts** in the sidebar.
2. Review ACTIVE alerts.
3. Click **Acknowledge** on alerts you are handling.
4. Place an order with the supplier (outside Duniya).
5. Click **Mark Ordered** on the alert.

📖 **Detailed docs:** [Low Stock Alerts](../modules/low-stock-alerts.md)

---

## Stage 8 — Replenish

The Replenishment page recommends what to order based on sales velocity
and target stock levels.

**Pharmacist / Outlet Manager action:**

1. Go to **Replenishment** in the sidebar.
2. Click **Refresh** to recompute recommendations.
3. Review the suggested order quantities.
4. For each product you want to order, click **Place Order**.
5. Duniya navigates you to Goods Received to record the incoming
   delivery.

When the supplier delivery arrives, the cycle loops back to
[Stage 2](#stage-2-receive-goods).

📖 **Detailed docs:** [Replenishment](../modules/replenishment.md)

---

## Cadence recommendations

How often should you run each stage? Here is a recommended cadence for a
typical community pharmacy:

| Stage | Frequency | Owner |
|---|---|---|
| 1. Define products | As needed (new SKUs) | Pharmacist |
| 2. Receive goods | Every delivery | Technician |
| 3. Track batches | Daily review | Pharmacist |
| 4. Sell / dispense | Continuous | Cashier / Pharmacist |
| 5. Move stock | As needed | Technician |
| 6. Count stock | Daily cycle counts; quarterly wall-to-wall | Technician |
| 7. Watch alerts | Daily review | Pharmacist |
| 8. Replenish | Weekly review; orders as needed | Pharmacist |

---

## Tips for a healthy cycle

!!! tip "Morning routine"
    Start every day with: (1) check [Notifications](../modules/notifications.md),
    (2) review [Low Stock Alerts](../modules/low-stock-alerts.md),
    (3) review [Batches & Expiry](../modules/batches.md). Five minutes
    that prevent most stockouts and expiries.

!!! tip "Cycle counts beat annual counts"
    A 30-minute cycle count every day is more accurate than a 2-day
    wall-to-wall count once a year. Rotate through your top 20% of
    products weekly.

!!! tip "Confirm receipts promptly"
    Pending Goods Received receipts are inventory you have physically
    received but not yet booked. Confirm them the same day they arrive.

!!! tip "Keep variances honest"
    When a stock count reveals a variance, write the real reason in the
    explanation field. *"Don't know"* is acceptable — *"No variance"* when
    there is one is not.
