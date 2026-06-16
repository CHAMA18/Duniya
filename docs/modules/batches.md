---
title: Batches & Expiry
description: Track every batch by expiry date, get early warnings, and export PDF reports for compliance.
---

# Batches & Expiry

The **Batches & Expiry** page is your early-warning system for expiring
stock. Every batch you receive is tracked here, classified by how urgent its
expiry is, and surfaced in summary cards that make it impossible to miss.

---

## Why batch tracking matters

Pharmacies lose real money to expired stock. Batch tracking is how you:

- Apply **FEFO** (First-Expired-First-Out) when dispensing.
- Get warnings **months in advance** of expiry — not the day before.
- Generate compliance reports for regulators.
- Recall a specific batch if a supplier issues a safety recall.

---

## Expiry classification

Duniya classifies every batch into one of four buckets based on the number
of days until expiry:

| Status | Days until expiry | Colour | What to do |
|---|---|---|---|
| **Expired** | < 0 | red | Remove from shelves immediately. Write off. |
| **Expiring < 3 Months** | 0–89 | orange | Dispense first (FEFO). Consider discounting. |
| **Expiring < 6 Months** | 90–179 | gold | Monitor. Push in sales. |
| **Safe** | ≥ 180 | green | No action needed. |

---

## Page anatomy

1. **Header** with **Export PDF** and **Add Batch** buttons.
2. **Summary cards** — Expired / Expiring < 3 Months / Expiring < 6 Months /
   Total Batches.
3. **Search** and **status filter pills**.
4. **Batch table** — every batch with expiry status.

---

## Summary cards

| Card | What it shows |
|---|---|
| **Expired** | Count of batches past their expiry date. These should be removed from shelves. |
| **Expiring < 3 Months** | Count of batches expiring within 90 days. Act now. |
| **Expiring < 6 Months** | Count of batches expiring within 180 days. Plan ahead. |
| **Total Batches** | Count of all batch records in the system. |

Each card is also a filter — click it to filter the table to that status.

---

## Adding a batch manually

Most batches are created automatically when you confirm a
[Goods Received](goods-received.md) receipt. You only need to add a batch
manually if:

- You received stock outside the normal Goods Received flow (rare).
- You are migrating from another system and need to record existing batches.

### To add a batch manually

1. Click **Add Batch**.
2. In the dialog, enter:
    - **Batch Number** *(required)* — e.g. *B-2024-001*.
    - **Expiry Date** *(required)* — pick from the calendar.
    - **Quantity** — units in this batch.
    - **Facility Location** — which outlet or warehouse holds this batch.
3. Click **Save**.

---

## The batch table

| Column | Description |
|---|---|
| **Batch #** | The batch number from the supplier. |
| **Quantity** | Units currently on hand from this batch. |
| **Expiry Date** | The printed expiry date. |
| **Days Left** | Computed: days until expiry (negative if expired). |
| **Location** | The facility / outlet holding the batch. |
| **Status** | Expired / < 3 Months / < 6 Months / Safe — colour-coded. |

The table row is tinted to match the status — red for expired, orange for
< 3 months, gold for < 6 months. This makes scanning a long list
instantaneous.

---

## Exporting a PDF report

The **Export PDF** button generates an A4-landscape PDF titled
**"Batch & Expiry Tracking Report"**. The report includes:

- Every batch with its status, quantity, expiry date, and days left.
- A summary section with counts per status.
- The pharmacy name and generation timestamp.

The PDF is downloaded directly to your browser — useful for:

- Printing for a regulatory inspection.
- Emailing to a supplier during a recall.
- Archiving for quarterly reviews.

---

## FEFO — First-Expired-First-Out

When you dispense a product that has multiple batches on the shelf, Duniya
recommends the batch with the earliest expiry date first. This is FEFO, and
it is the global standard for pharmaceutical dispensing.

!!! tip "Make FEFO a habit"
    Even without automated dispensing, train your staff to always reach for
    the batch with the earliest expiry date. A simple shelf label with the
    expiry date in large print helps enormously.

---

## Disposing of expired stock

When a batch crosses into **Expired** status:

1. Physically remove the stock from the shelves.
2. Record the disposal as an **ADJUSTMENT** movement on the
   [Stock Movements](stock-movements.md) page — quantity negative, reason
   *"Expired — disposed"*.
3. (Optional) Update the batch's quantity to 0 to keep the record for
   historical reporting.

!!! danger "Legal compliance"
    Many jurisdictions require specific disposal procedures for expired
    medicines — particularly controlled substances. Follow your local
    pharmacy council's guidelines. Duniya records the disposal; it does not
    dictate the method.

---

## Frequently asked questions

??? question "Can I have the same batch number on different products?"
    Technically yes — the batch number is unique per product, not globally.
    In practice, suppliers usually use unique batch numbers, so collisions
    are rare.

??? question "What if a batch's expiry date was entered incorrectly?"
    Edit the batch record (from the batch table row menu) and correct the
    date. The status will recompute automatically.

??? question "How does Duniya know a batch exists?"
    Batches are created in three ways: (1) confirming a Goods Received
    receipt, (2) the Add Batch dialog on this page, (3) the Bulk Import
    wizard when the spreadsheet includes a Batch Number column.

??? question "Can I see batches for a specific outlet only?"
    Use the **Facility Location** column — sort or scan to find the outlet
    you care about. A per-outlet filter is on the roadmap.
