---
title: Goods Received
description: Verify supplier deliveries line-by-line before they hit your shelves. Catch short shipments, overages, and discrepancies at the dock.
---

# Goods Received

The **Goods Received** page is where you verify supplier deliveries before
they hit your shelves. Every delivery becomes a Goods Received record with
a status lifecycle: `PENDING → CONFIRMED` or `PENDING → DISCREPANCY`.

---

## Why verification matters

When a delivery arrives, the supplier's delivery note says one thing —
the boxes on the dock may say another. Goods Received is your chance to:

- Confirm each line item's quantity matches the delivery note.
- Catch short shipments before you pay for them.
- Catch overages before they distort your inventory.
- Capture damaged or expired stock at receipt.
- Record batch numbers and expiry dates for FEFO tracking.

A confirmed receipt automatically creates a `RECEIVED` Stock Movement and
updates the relevant Stock records.

---

## Page anatomy

1. **Header** with breadcrumb, summary metrics, and **New Receipt** button.
2. **Summary cards** — Confirmed / Pending / Discrepancy counts.
3. **Filter bar** — search, pharmacy filter, sort.
4. **Status segmented control** — All / Pending / Confirmed / Discrepancy.
5. **Receipts list** — polished cards, one per delivery.

---

## The receipt lifecycle

```
        New receipt created
                │
                ▼
            PENDING ────discrepancy found───► DISCREPANCY
                │
                │ quantities verified
                ▼
            CONFIRMED
                │
                ▼
        Stock updated + RECEIVED movement logged
```

- **PENDING** — receipt recorded, awaiting verification.
- **CONFIRMED** — every line item matches; stock has been updated.
- **DISCREPANCY** — at least one line item did not match; investigate before
  confirming.

!!! warning "Discrepancies block stock updates"
    A receipt with status DISCREPANCY does **not** update stock. You must
    resolve the discrepancy (edit the line items, contact the supplier, or
    confirm anyway) before stock is affected.

---

## Creating a new receipt

1. Click **New Receipt**.
2. In the dialog, enter:
    - **Delivery Note Number** *(required)* — from the supplier's paperwork.
    - **Delivery Date** — when the shipment arrived.
    - **Received By** — defaults to the current user.
3. Click **Save**. The receipt is created in PENDING status.

You are taken to the **Goods Received Detail** page where you can add line
items.

---

## Adding line items

On the Goods Received Detail page:

1. Click **Add Item**.
2. In the **Add Line Item** dialog, fill in:
    - **Product** — pick from the Product Catalogue.
    - **Quantity Delivered** — what the delivery note says.
    - **Quantity Received** — what you actually counted on the dock.
    - **Batch Number** — from the supplier's packaging.
    - **Expiry Date** — printed on the packaging.
    - **Discrepancy** — auto-computed as `Delivered − Received`, or enter a
      reason manually if there is a qualitative issue (damage, wrong
      product, etc.).
3. Click **Save**. Repeat for every line item in the delivery.

!!! tip "Count twice, record once"
    For high-value or controlled substances, count the delivered quantity
    twice — once alone, once with a second person. The 30 seconds you spend
    double-checking saves hours of reconciliation later.

---

## Confirming a receipt

Once every line item is entered and the quantities match:

1. Click **Confirm** at the top of the detail page.
2. Duniya:
    - Sets the receipt status to `CONFIRMED`.
    - Creates or updates Stock records for each product/batch/outlet.
    - Logs a `RECEIVED` Stock Movement with the verified quantity.
    - Creates Batch records for each new batch number.
3. A success toast appears: *"Goods receipt confirmed successfully"*.

---

## Handling discrepancies

If any line item has a mismatch between Delivered and Received (or a
non-empty Discrepancy note), the receipt's status flips to `DISCREPANCY`
when you save it.

To resolve:

1. Investigate the cause — recount, check the delivery note, contact the
   supplier.
2. Edit the line item to correct the quantities or add a clearer
   discrepancy note.
3. Once resolved, click **Confirm** to finalise the receipt.

!!! info "Discrepancies are valuable data"
    Don't just resolve and move on. Patterns of discrepancy (same supplier,
    same product, same time of month) point to systemic issues. Review your
    DISCREPANCY receipts quarterly and raise them with suppliers.

---

## Summary cards

| Card | Description |
|---|---|
| **Confirmed** | Count of receipts in CONFIRMED status — these have hit your shelves. |
| **Pending** | Count of receipts awaiting verification — these have NOT hit your shelves yet. |
| **Discrepancy** | Count of receipts with at least one mismatched line item. |

Keep **Pending** as low as possible — every pending receipt is inventory you
have physically received but not yet booked into the system.

---

## Frequently asked questions

??? question "Can I edit a receipt after confirming it?"
    No — a confirmed receipt is locked because it has already updated stock.
    If you discover an error, record an ADJUSTMENT movement with the
    difference and a clear reason.

??? question "What if the supplier sends the wrong product?"
    Add a line item with Quantity Delivered = 0 and Quantity Received = 0,
    then put "Wrong product supplied — expected X, received Y" in the
    Discrepancy field. The receipt will be in DISCREPANCY status, and you
    can resolve it after contacting the supplier.

??? question "How do batches get created?"
    When you confirm a receipt, every line item with a Batch Number creates
    (or updates) a Batch record in the [Batches & Expiry](batches.md)
    module. The batch's expiry date comes from the line item.

??? question "Does Goods Received update my financial reports?"
    Yes — confirming a receipt increases your inventory value by
    `quantity × cost_of_goods` for each line item. This flows into the
    Total Stock Value KPI on [Finances](finances.md).
