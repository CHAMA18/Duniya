---
title: Product Catalogue
description: The Product Master is the shared catalogue of every product you can stock — define it once, use it everywhere.
---

# Product Catalogue

The **Product Catalogue** (internally: *Product Master*) is the shared
catalogue of every product your pharmacy can stock. It is the source of truth
for product identity, pricing, and reorder thresholds.

!!! info "Catalogue vs. Stock"
    The Product Catalogue describes *what a product is*. The
    [Store Inventory](store-inventory.md) describes *how many units of it
    you currently have on a specific shelf*. A product exists once in the
    catalogue; it may exist many times in stock (one per batch, per outlet).

---

## Why a separate catalogue?

- **Consistency** — every sale, receipt, and movement references the same
  product definition. Rename "Paracetamol" once and it updates everywhere.
- **Pricing control** — set the selling price centrally. Per-outlet stock
  inherits it.
- **Reorder intelligence** — the catalogue carries `MinimumStockLevel`,
  `ReorderLevel`, and `TargetStockLevel`. These feed
  [Low Stock Alerts](low-stock-alerts.md) and
  [Replenishment](replenishment.md) calculations.
- **Supplier linkage** — products are linked to a Supplier, enabling
  purchase-order automation in future releases.

---

## Product Master fields

| Field | Required | Description |
|---|---|---|
| **Name** | ✅ | Display name (e.g. *Paracetamol 500mg*). |
| **SKU** | ✅ | Your internal stock-keeping unit (e.g. *PARA-500*). Must be unique. |
| **Generic Name** | | The generic / INN name (e.g. *Paracetamol*). |
| **Brand Name** | | The manufacturer's brand (e.g. *Panadol*). |
| **Strength** | | e.g. *500mg*, *250mg/5mL*. |
| **Dosage Form** | | Tablet, Capsule, Syrup, Injection, etc. |
| **Pack Size** | | Units per pack (e.g. *100 tablets*). |
| **Unit of Measure** | | Tablet, mL, vial, etc. |
| **Category** | | Medicine, Nutrition Supplements, Mother & Babycare, Veterinary, Beauty, Personal Care. |
| **Supplier** | | Reference to a supplier record. |
| **Cost Price** | | What you pay per unit (ZMK). |
| **Selling Price** | | What you charge per unit (ZMK). |
| **Minimum Stock Level** | | Hard floor — never let stock drop below this. |
| **Reorder Level** | | Soft floor — alert fires when stock crosses below this. |
| **Target Stock Level** | | The optimal stock level — used by Replenishment to compute suggested order quantity. |
| **Is Active** | | If false, the product is hidden from new sales but existing stock remains. |

---

## Adding a product

1. Open **Product Catalogue** from the sidebar.
2. Click **Add Product** in the top-right.
3. The Add Product dialog appears. Fill in at least the **Name** and **SKU**.
4. Click **Save**.

!!! warning "Name and SKU are required"
    Duniya will not let you save a product without both. The validation
    message is explicit: *"Product Name and SKU are required"*.

---

## The product detail drawer

Clicking a product in the catalogue opens a detail drawer on the right side
of the screen. The drawer shows every field of the Product Master and lets
you edit them inline.

The drawer is organised into sections:

- **Product Identity** — Name, SKU, Generic Name, Brand Name
- **Classification** — Category, Strength, Dosage Form, Pack Size, Unit of Measure
- **Commercial** — Supplier, Cost Price, Selling Price
- **Stock Policy** — Minimum Stock Level, Reorder Level, Target Stock Level
- **Lifecycle** — Is Active toggle, Created At, Updated At

---

## Setting smart reorder levels

The three stock-policy fields work together to drive Duniya's automated
replenishment:

```
0 ──── MinimumStockLevel ──── ReorderLevel ──── TargetStockLevel ──── ∞
                  │                  │                  │
                  ▼                  ▼                  ▼
        hard floor           alert fires        suggested order
        (never below)        (Low Stock Alert)  quantity targets this
```

- Set **Minimum Stock Level** to the absolute lowest you can tolerate —
  usually zero for most products, but higher for critical medicines.
- Set **Reorder Level** to the point at which you want a low-stock alert.
  A common rule of thumb: *average weekly sales × lead time in weeks + 20%
  safety buffer*.
- Set **Target Stock Level** to where you want stock to sit after a
  replenishment order arrives. Often *Reorder Level + 4–8 weeks of average
  sales*.

!!! example "Worked example"
    - You sell ~20 units of Paracetamol per week.
    - Your supplier delivers in 1 week.
    - **Minimum Stock Level:** 0 (you don't want to overspecify).
    - **Reorder Level:** 20 × 1 × 1.2 = **24 units** (alert fires here).
    - **Target Stock Level:** 24 + (20 × 6) = **144 units** (order up to here).

The [Replenishment](replenishment.md) module uses these values to compute
the suggested order quantity automatically.

---

## Deactivating vs. deleting

Duniya does not permanently delete products that have been sold or moved —
that would break historical reporting. Instead, you **deactivate** a product
by toggling **Is Active** to false.

| Action | Effect |
|---|---|
| **Deactivate** (`Is Active = false`) | Product hidden from new sales and from the default catalogue view. Existing stock, sales, and movements remain intact. |
| **Delete** | Not supported for products with history. Use Deactivate instead. |

---

## Linking products to stock

A product in the catalogue does not appear on your shelves until you create
a Stock record for it. This happens in three ways:

1. **Add Product from Store Inventory** — creates both a catalogue entry
   (if needed) and a Stock record on the selected outlet.
2. **Goods Received** — when you record a supplier delivery, Duniya creates
   a Stock record (or adds to an existing one) linked to the catalogue
   product.
3. **Bulk Import** — the spreadsheet import creates Stock records; if the
   product name does not exist in the catalogue, a new Product Master entry
   is created too.

---

## Frequently asked questions

??? question "Can I have the same product from different suppliers?"
    Yes. The Supplier field is a reference, not a unique constraint. You can
    receive the same Paracetamol from Supplier A and Supplier B — they share
    a single Product Master entry but you can track costs separately via the
    Stock record's Cost of Goods field.

??? question "How do I rename a product across the entire system?"
    Edit the Name field in the Product Catalogue. Every Sale, Stock
    Movement, and Goods Received record that references the product will
    immediately display the new name.

??? question "What happens if I change the Selling Price?"
    The new price applies to all future sales. Historical sales retain the
    price they were sold at — Duniya snapshots the price onto each Sale
    record.

??? question "My SKU is already in use — what do I do?"
    SKUs must be unique. Either reuse the existing product or pick a new SKU
    (e.g. *PARA-500-V2*).
