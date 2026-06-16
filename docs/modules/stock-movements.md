---
title: Stock Movements
description: Every in, out, transfer, and adjustment is a Stock Movement — the immutable ledger of your inventory.
---

# Stock Movements

Every time stock enters, leaves, moves between outlets, or gets manually
corrected, Duniya records a **Stock Movement**. The Stock Movements page is
the immutable ledger of everything that has ever happened to your inventory.

---

## Movement types

| Type | Direction | Icon | Typical reason |
|---|---|---|---|
| **RECEIVED** | In | login | Supplier delivery recorded via [Goods Received](goods-received.md). |
| **SOLD** | Out | logout | Sale dispensed via [Point of Sale](pharmacy-tools.md) or [Sales / Dispensing](sales.md). |
| **TRANSFERRED** | Between outlets | sync_alt | Stock moved from one outlet to another. |
| **ADJUSTMENT** | In or Out | tune | Manual correction — damage, loss, recount, theft. |

Each movement carries:

- **Date** — when the movement was recorded.
- **Product** — reference to the Product Master.
- **Quantity** — positive for in, negative for out.
- **Movement Type** — one of the four above.
- **Reason** — free-text explanation (e.g. *"Broken in transit"*).
- **Movement Reference** — optional link to the source document (Sale ID,
  Goods Received ID, Stock Count ID).
- **Recorded By** — the user who logged the movement.
- **Status** — `COMPLETED` for RECEIVED/SOLD/ADJUSTMENT, `IN TRANSIT` for
  TRANSFERRED until confirmed at the destination.

---

## Page anatomy

1. **Header** with **Add Movement** button.
2. **Movement Analytics** — counts by type for the selected period.
3. **Movement Ledger** — the table of every movement, newest first.
4. **Type filter** — All / RECEIVED / SOLD / TRANSFERRED / ADJUSTMENT.

---

## Adding a movement manually

Most movements are created automatically by other modules:

- A **Sale** creates a SOLD movement.
- A **Goods Received** confirmation creates a RECEIVED movement.
- A **Stock Count** approval creates ADJUSTMENT movements for each variance.

You only need to add a movement manually for **transfers** and **ad-hoc
adjustments** (damage, loss, recounts).

### To record a transfer

1. Click **Add Movement**.
2. In the dialog, set:
    - **Date** — defaults to today.
    - **Movement Type** — *TRANSFERRED*.
    - **From Outlet** — the source outlet.
    - **To Outlet** — the destination outlet.
    - **Product** — what is being moved.
    - **Quantity** — how many units.
    - **Reason** — e.g. *"Restocking Kiosk #1"*.
3. Click **Save**.

The movement appears in the ledger with status `IN TRANSIT`. When the
destination outlet confirms receipt, the status becomes `COMPLETED` and
their stock increases.

### To record a damage / loss adjustment

1. Click **Add Movement**.
2. Set **Movement Type** to *ADJUSTMENT*.
3. Pick the **Outlet** and **Product**.
4. Enter a negative **Quantity** (e.g. `-5` for five damaged units).
5. Add a clear **Reason** — this is required for audit purposes.
6. Click **Save**.

The outlet's on-hand quantity decreases by the absolute value, and the
movement is permanently recorded in the ledger.

!!! tip "Use the Damaged Stock component"
    For damaged stock, prefer the dedicated **Damaged Stock** dialog over a
    raw adjustment. It captures the standard fields (Quantity, Description)
    in a structured way and links them to the original Stock record.

---

## Damaged stock

The **Damaged Stock** component is a specialised dialog for recording
damage:

1. Open it from the item's row menu (or from the Damaged Stock link on
   certain pages).
2. Enter the **Quantity** of damaged units.
3. Write a **Description** — e.g. *"Box crushed in transit, 5 strips
   unusable"*.
4. Click **Submit**.

The component:

- Subtracts the quantity from the Stock record's `Quantity` field.
- Adds the quantity to the Stock record's `DamagedGoods` counter.
- Logs an ADJUSTMENT movement with the reason.

---

## The ledger table

| Column | Description |
|---|---|
| **Date** | When the movement was recorded. |
| **Product** | Name of the product moved. |
| **Type** | RECEIVED / SOLD / TRANSFERRED / ADJUSTMENT, with a coloured badge. |
| **Qty** | Units moved. Positive for in, negative for out. |
| **Reason** | Free-text reason, if provided. |
| **Status** | COMPLETED or IN TRANSIT. |

The table is sortable by date and filterable by type. Use the search box to
filter by product name or reason text.

---

## Why movements matter

Stock Movements are the **audit trail** of your inventory. They are:

- **Immutable** — once recorded, a movement cannot be edited or deleted.
  If you made a mistake, record a correcting movement.
- **Attributable** — every movement carries the user who recorded it.
- **Referenceable** — movements link back to the originating Sale, Goods
  Received, or Stock Count document.

This is what allows Duniya to:

- Reconstruct stock on-hand at any historical point in time.
- Explain discrepancies found during a stock count.
- Provide defensible records for regulators and auditors.

---

## Frequently asked questions

??? question "Can I edit or delete a movement?"
    No. Movements are immutable. If you recorded the wrong quantity, create
    a new ADJUSTMENT movement with the corrected difference and a clear
    reason referencing the original.

??? question "Why is my transfer stuck at IN TRANSIT?"
    The destination outlet needs to confirm receipt. Open the movement and
    click **Confirm Receipt** at the destination outlet.

??? question "How do I see all movements for a single product?"
    Use the search box — type the product name. The ledger filters in real
    time.

??? question "Do adjustments affect my financial reports?"
    Yes. An ADJUSTMENT that reduces stock also reduces your Total Stock
    Value on the [Finances](finances.md) page. Damage and loss are real
    costs.
