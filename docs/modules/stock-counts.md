---
title: Stock Counts
description: Reconcile system stock against physical stock. Approve counts, post variances, and keep your inventory honest.
---

# Stock Counts

The **Stock Counts** page is where you reconcile what Duniya *thinks* you
have on the shelf against what you can *physically count*. Regular stock
counts are the single most important discipline for inventory accuracy.

---

## Why count stock

No matter how careful you are, the system's view of stock will drift from
reality:

- A sale gets voided but the stock decrement stays.
- A damaged unit gets thrown away without an adjustment.
- A supplier short-ships and nobody catches it.
- A customer returns a product that goes back on the shelf without being
  recorded.

A stock count catches all of these in one operation. The variance — the
gap between system and physical — is posted as an ADJUSTMENT movement so
the audit trail stays clean.

---

## The count lifecycle

```
        New count created
                │
                ▼
             DRAFT ────reject───► REJECTED
                │
                │ items counted, variances reviewed
                ▼
            APPROVED ────► variances posted as ADJUSTMENT movements
                              └──► stock updated
```

- **DRAFT** — count is in progress. You can add items, change counted
  quantities, and discard.
- **APPROVED** — count is finalised. Variances are posted as ADJUSTMENT
  movements, and stock records are updated to match the counted quantities.
- **REJECTED** — count is discarded. No changes are posted.

!!! warning "Approval is irreversible"
    Once you approve a count, the ADJUSTMENT movements are created and
    cannot be undone. Review variances carefully before approving.

---

## Page anatomy

1. **Header** with **Add** button.
2. **Status filter** — All / Draft / Approved / Rejected.
3. **Counts list** — cards, one per count.

---

## Creating a stock count

1. Click **Add**.
2. Duniya creates a new count with status DRAFT and takes you to the
   **Stock Count Detail** page.
3. On the detail page, you will see a table with one row per product:

| Column | Description |
|---|---|
| **Product** | Name and SKU. |
| **System Qty** | What Duniya thinks you have. |
| **Counted Qty** | What you physically counted. Editable. |
| **Variance** | Auto-computed: `Counted − System`. Positive = surplus, negative = shortfall. |
| **Explanation** | Free-text reason for any non-zero variance. Required for audit. |

4. Walk the shelves with a printed count sheet (or your phone). Enter the
   counted quantity for each product.
5. For any row with a non-zero variance, write an explanation.
6. Review the variances.
7. Click **Approve** to finalise, or **Reject** to discard.

---

## Variance best practices

A variance is not a failure — it is information. Use variances to improve
your processes:

| Variance pattern | Likely cause | Action |
|---|---|---|
| Consistent negative on one product | Theft, damage, or mis-scanned sales. | Investigate. Tighten controls. |
| Consistent positive on one product | Over-receiving from supplier, or sales not being recorded. | Audit the Goods Received process. |
| Random small variances everywhere | Normal operational drift. | Count more frequently. |
| Big variance on one product after a transfer | Transfer was not confirmed at destination. | Audit the transfer process. |

!!! tip "The 5% rule"
    If a product's variance exceeds 5% of its system quantity, investigate
    before approving. A 5% variance on a fast-moving product is a real
    loss.

---

## Counting cadence

Different products need different counting cadences:

| Product class | Suggested cadence |
|---|---|
| **Controlled substances** | Daily |
| **High-value items** | Weekly |
| **Fast-moving (top 20% by sales)** | Monthly |
| **Everything else** | Quarterly (full inventory) |

A **cycle count** — counting a small subset every day — is more accurate
than a once-a-year wall-to-wall count. Duniya's Stock Counts page supports
both: create a count for a single product or a whole outlet.

---

## Approving a count

When you click **Approve**:

1. Duniya validates that every non-zero variance has an explanation.
2. For each row with a variance, an ADJUSTMENT Stock Movement is created:
    - Quantity = Variance (signed)
    - Reason = the explanation you entered
    - Reference = the Stock Count ID
3. The Stock record's `Quantity` is updated to the counted value.
4. The count's status becomes APPROVED.
5. A success toast appears.

The count is now locked. To make further changes, create a new count.

---

## Frequently asked questions

??? question "What if I cannot finish a count in one sitting?"
    Save the count as DRAFT. You can come back to it any time — your
    counted quantities are preserved.

??? question "Can I count a single product?"
    Yes. Create a new count, then in the detail page filter to the product
    you want. Enter the counted quantity and approve. This is the
    recommended approach for cycle counts.

??? question "Do approved counts affect financial reports?"
    Yes. A negative variance reduces your Total Stock Value on the
    [Finances](finances.md) page. A positive variance increases it.

??? question "Can I print a count sheet?"
    A print-friendly count sheet is on the roadmap. For now, you can
    screenshot the detail page or export the system quantities to a
    spreadsheet manually.

??? question "What happens if a sale happens while I am counting?"
    The System Qty column reflects real-time stock — it will change if a
    sale is made mid-count. Best practice: count outside business hours,
    or freeze sales for the duration of the count.
