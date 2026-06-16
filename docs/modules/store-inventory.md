---
title: Store Inventory
description: Manage the stock on your shelves — add products, import spreadsheets, filter by category, and act on low-stock items.
---

# Store Inventory

The **Store Inventory** page is where you manage the physical stock sitting
on your shelves. It is the most-visited page in Duniya and the source of
truth for what you actually have on hand.

---

## Page anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│ Store Inventory                              [Add Product]      │
│ Manage and track your primary pharmacy stock. [Import] [Template]│
├─────────────────────────────────────────────────────────────────┤
│ ┌─ Total Stock Value ─┐ ┌─ Items Near Expiry ─┐ ┌─ Active ─┐   │
│ │   ZMK 248,500       │ │       7 SKUs        │ │   142    │   │
│ └─────────────────────┘ └─────────────────────┘ └──────────┘   │
├─────────────────────────────────────────────────────────────────┤
│ 🔎 Search inventory, SKU, or batch...                            │
│ [All Categories] [Medicine] [Nutrition] [Mother&Baby] [Vet]...   │
│                                          [Filters]  Sort by: ▾   │
├─────────────────────────────────────────────────────────────────┤
│ Product        │ Category  │ Qty │ Price │ Batch   │ Status      │
│ Paracetamol…  │ Medicine  │ 100 │ 15.00 │ B-2024… │ In Stock    │
│ Amoxicillin…  │ Medicine  │   3 │ 35.00 │ B-2024… │ Low Stock   │
│ ...                                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Header actions

| Button | Purpose |
|---|---|
| **Add Product** | Opens the Add Product form, scoped to the Medicine category by default. |
| **Import** | Opens the [Bulk Import wizard](../workflows/bulk-import.md) — upload an Excel/CSV file of products. |
| **Template** | Downloads `Duniya_Inventory_Template.xlsx` with the correct column headers and an Instructions sheet. |

!!! tip "Always start with the Template"
    If you plan to bulk-import, click **Template** first. The Import wizard
    accepts any column order (it matches headers flexibly), but using the
    official template guarantees every field is recognised.

---

## Summary cards

The three summary cards at the top give you an instant read on inventory
health:

| Card | What it shows |
|---|---|
| **Total Stock Value** | Sum of `price × quantity` across all stock. |
| **Items Near Expiry** | SKUs expiring within 30 days. |
| **Active Stock Items** | SKUs with quantity > 0. |

---

## Search

The search box filters the table in real time across four fields:

- **Product name**
- **Batch number**
- **Manufacturer**
- **Category**

Type at least one character — the table filters as you type.

---

## Category filters

The horizontal row of category pills lets you filter the table by product
category:

| Pill | Icon | Description |
|---|---|---|
| All Categories | list_alt | No filter — show every product. |
| Medicine | medication | Prescription and OTC medicines. |
| Nutrition Supplements | fitness_center | Vitamins, minerals, protein. |
| Mother and Babycare | child_friendly | Infant formula, diapers, baby toiletries. |
| Veterinary Products | pets | Animal-health products. |
| Beauty Care | face | Cosmetics and skincare. |
| Personal Care | spa | Soaps, shampoos, oral care. |

Click a pill to filter. Click it again (or click **All Categories**) to
clear the filter.

---

## Sort

The **Sort by** dropdown supports three orderings:

| Option | Sorts by |
|---|---|
| Stock Level (Low to High) | `quantity` ascending — items closest to out-of-stock first. |
| Product Name (A-Z) | `name` alphabetical. |
| Value (High to Low) | `price × quantity` descending — your most valuable stock first. |

The default is **Stock Level (Low to High)** so the items most at risk
appear at the top.

---

## The stock table

| Column | Description |
|---|---|
| **Product** | Name and small category icon. |
| **Category** | One of the seven categories. |
| **Qty** | Current on-hand units. Coloured red if below the reorder level. |
| **Price** | Selling price per unit (ZMK). |
| **Batch** | The batch number currently on the shelf. |
| **Status** | `Out of Stock` (qty = 0), `Low Stock` (qty < Limit Notice), or `In Stock`. |

Click any row to drill into the [Inventory Details](#item-details) page for
that stock item.

---

## Item details

The Inventory Details page shows a single stock record in full:

- Identity: product name, category, manufacturer
- Stock: quantity, batch number, expiry date
- Pricing: selling price, cost of goods, current value
- Thresholds: limit notice, days until expiry
- Actions: **Save changes**, **Delete item**

!!! warning "Deleting a stock item"
    Deleting a stock item is permanent. If the item has sales or movements
    linked to it, those records remain — only the stock record is removed.
    Prefer setting quantity to 0 over deleting.

---

## Adding a single product

1. Click **Add Product** in the top-right.
2. The Add Product form appears. Fill in:
    - **Name** *(required)*
    - **Category** — defaults to Medicine
    - **Manufacturer**
    - **Quantity**
    - **Price** (ZMK)
    - **Cost of Goods** (ZMK)
    - **Batch Number**
    - **Expiry Date**
    - **Limit Notice** (low-stock threshold)
3. Click **Save**.

The new stock record appears at the top of the table (because the default
sort is by quantity ascending, and new items usually have high quantity —
scroll to see it).

---

## Importing many products at once

See the dedicated **[Bulk Import](../workflows/bulk-import.md)** guide for
the full walkthrough. The short version:

1. Click **Template** to download the Excel template.
2. Fill in your products — one row per product.
3. Click **Import**, pick the file, preview the parsed rows, and confirm.
4. Duniya creates all stock records in batches of 400.

---

## Frequently asked questions

??? question "How do I change a product's price?"
    Click the row to open Inventory Details, edit the Price field, and click
    **Save changes**. The new price takes effect immediately for all future
    sales.

??? question "How do I mark an item as damaged?"
    Use the [Damaged Stock](stock-movements.md#damaged-stock) component —
    accessible from the item's row menu in some views, or from the Stock
    Movements page. Damaged units are subtracted from the on-hand quantity
    and recorded separately.

??? question "Why does my imported spreadsheet show 'invalid rows'?"
    The Import wizard validates every row. Common reasons for invalid rows:
    missing product name, unparseable date format, or non-numeric quantity.
    The Preview step shows the exact reason per row.

??? question "Can I have the same product on multiple outlets?"
    Yes. Each outlet has its own Stock record for that product. Use
    [Stock Movements → Transfer](stock-movements.md) to move units between
    outlets.

??? question "How do I set different reorder levels per outlet?"
    The **Limit Notice** field on each Stock record is per-outlet. Set it
    independently for each row in the Inventory Details view.
