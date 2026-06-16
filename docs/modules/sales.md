---
title: Sales & Dispensing
description: Record sales, dispense medication, and generate receipts — the VMI sales flow with patient references.
---

# Sales & Dispensing

The **Sales / Dispensing** page is where pharmacy staff record every sale
and dispense medication. Each sale captures the patient, the line items,
the prices, and the total — feeding the Finances module and decrementing
stock in real time.

!!! info "Two sales flows"
    Duniya has two sales interfaces:

    - **Sales / Dispensing** (VMI flow) — documented here. Records each
      sale against an outlet with an optional patient reference.
    - **Point of Sale** (legacy flow) — a cart-based interface for quick
      over-the-counter sales. See [Pharmacy Tools → Point of Sale](pharmacy-tools.md#point-of-sale).

    Both decrement stock and create Sales records. Use Sales / Dispensing
    for prescription dispensing; use Point of Sale for walk-in retail.

---

## Page anatomy

1. **Header** with **New Sale** button.
2. **KPI cards** — Total Revenue, Total Sales, Today's Revenue, Average
   Sale.
3. **Sales list** — cards, one per sale.

---

## KPI cards

| Card | Computation |
|---|---|
| **Total Revenue** | Sum of `TotalAmount` across all sales in the selected period. |
| **Total Sales** | Count of sales in the period. |
| **Today's Revenue** | Sum of `TotalAmount` for sales made today. |
| **Average Sale** | `Total Revenue / Total Sales`. |

These KPIs help you spot trends — for example, a drop in Average Sale may
indicate staff are discounting too aggressively.

---

## Creating a sale

1. Click **New Sale**.
2. In the form, fill in:
    - **Patient Reference** — optional. Links the sale to a patient record
      for clinical history.
    - **Outlet** — defaults to your current outlet.
    - **Sale Date** — defaults to today.
3. Add line items:
    - **Product** — pick from the catalogue.
    - **Quantity** — units being dispensed.
    - **Selling Price** — auto-filled from the catalogue; editable.
    - **Total** — auto-computed as `Quantity × Selling Price`.
4. Click **Save**. Duniya:
    - Creates a `SaleVMI` record with the total.
    - Creates a `SaleItemVMI` record for each line item.
    - Logs a `SOLD` Stock Movement for each product.
    - Decrements the outlet's Stock record.
5. A success toast appears: *"Sale recorded successfully"*.

!!! warning "Out-of-stock protection"
    Duniya does not currently hard-block sales that would drive stock
    negative — but a stockout will immediately trigger a Low Stock Alert
    and the next sale of that product will show a 0 on-hand quantity. Train
    staff to check the on-hand quantity before dispensing.

---

## The sale record

Every sale stores:

- **Sale Date** — when the sale was made.
- **Outlet** — which outlet made the sale.
- **Sold By** — the user who recorded it.
- **Patient Reference** — optional link to a patient.
- **Line Items** — product, quantity, price, total per item.
- **Total Amount** — sum of all line items.
- **Created At** — timestamp.

Click any sale card to drill into its full detail on the Sales Items page.

---

## Sales Items detail

The Sales Items page shows a single sale as a receipt:

- Sale ID and date
- Patient reference (if any)
- Line items: product, quantity, unit price, total
- Discount (per line item, if any)
- Final price (after discount)
- Grand total

You can delete a sale item from this page — Duniya decrements the parent
sale's `Total_amount` accordingly. Use this only to correct mistakes; for
returns, prefer recording a separate ADJUSTMENT movement so the audit trail
stays clean.

---

## Frequently asked questions

??? question "Can I apply a discount?"
    Yes — edit the Selling Price on a line item when creating the sale. The
    discount is implicit (the difference between catalogue price and sold
    price). A future release will add explicit discount reasons.

??? question "How do I refund a sale?"
    Duniya does not yet have a dedicated refund flow. The current practice
    is to record an ADJUSTMENT movement with a positive quantity and a
    reason like *"Refund — Sale #1234"*. The stock goes back on the shelf;
    the financial impact is recorded in the movement reason.

??? question "Does a sale create a Low Stock Alert?"
    If the sale drives a product's on-hand quantity below its Reorder
    Level, yes — an ACTIVE alert is created (or the existing alert's
    quantities are updated).

??? question "Can I see a customer's purchase history?"
    If you set the Patient Reference, you can filter the sales list by that
    reference. A dedicated patient history page is on the roadmap.
