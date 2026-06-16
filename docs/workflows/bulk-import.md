---
title: Bulk Import Inventory
description: Upload hundreds of products in one go via a spreadsheet. Template, validation, and the four-step import wizard.
---

# Bulk Import Inventory

The **Bulk Import** workflow lets you add hundreds of products to your
inventory in one go by uploading a spreadsheet. It is the fastest way to
populate Duniya when you are migrating from another system or starting
with a large catalogue.

---

## The four-step wizard

```
   Step 1                Step 2                  Step 3                Step 4
   Upload ──────────► Preview & Validate ──► Importing ──────────► Summary
   File                 (per-row status)      (progress bar)         (counts)
```

---

## Step 1 — Upload File

1. Go to **Store Inventory** in the sidebar.
2. Click **Import** (purple button) in the top-right.
3. The Import dialog opens.
4. Click **Choose File** and pick your spreadsheet.
5. Duniya accepts `.xlsx`, `.xls`, and `.csv` files.

!!! tip "Use the official template"
    Click **Template** (next to the Import button) to download
    `Duniya_Inventory_Template.xlsx`. The template has the correct column
    headers, an example row, and an Instructions sheet. Using it
    guarantees every field is recognised.

---

## Step 2 — Preview & Validate

After you pick a file, Duniya parses it and shows a preview table:

| Column | Description |
|---|---|
| **Row #** | The spreadsheet row number. |
| **Status** | ✅ Valid / ❌ Invalid. |
| **Product Name** | The parsed name. |
| **Category** | The parsed category. |
| **Quantity** | The parsed quantity. |
| **Price** | The parsed price (ZMK). |
| **Reason** | For invalid rows, the reason (e.g. *"Missing product name"*, *"Invalid date format"*). |

Review the preview. If there are invalid rows, you have two options:

- **Cancel** the import, fix the spreadsheet in Excel, and re-upload.
- **Continue** with the import — only the valid rows will be imported.

### Header matching

Duniya matches spreadsheet headers flexibly. The following aliases are
recognised (case-insensitive):

| Field | Accepted headers |
|---|---|
| **Name** | name, product name, productname, product, item name, item, drug name, medicine name, description name |
| **Category** | category, product category, type, product type |
| **Manufacturer** | manufacturer, brand, supplier, vendor, company, producer |
| **Quantity** | quantity, qty, stock, stock level, units, count, on hand, quantity in stock |
| **Price** | price, unit price, selling price, sale price, retail price, sell price, price per unit |
| **Cost of Goods** | cost, cost of goods, costofgoods, cogs, cost price, purchase price, unit cost, buy price |
| **Batch Number** | batch number, batchnumber, batch, batch no, batch #, lot, lot number, lot no |
| **Expiry Date** | expiry date, expirydate, expiry, expiration date, expiration, exp date, exp, expires, best before |
| **Limit Notice** | limit notice, limitnotice, reorder level, reorder, low stock threshold, low stock alert, min stock, minimum stock, alert at |

You can use any column order — Duniya will figure out which is which.

### Date formats

Duniya parses dates in these formats:

- ISO 8601: `2026-12-31`
- DD/MM/YYYY: `31/12/2026`
- D/M/YYYY: `31/12/2026`
- MM/DD/YYYY: `12/31/2026`
- M/D/YYYY: `12/31/2026`
- DD-MM-YYYY: `31-12-2026`
- YYYY/MM/DD: `2026/12/31`
- DD.MM.YYYY: `31.12.2026`

### Currency cleaning

Price fields can include currency symbols and thousands separators —
Duniya strips them automatically:

- `ZMK 15.00` → `15.00`
- `$1,234.56` → `1234.56`
- `15,000` → `15000`

### Defaults

Missing fields get sensible defaults:

| Field | Default |
|---|---|
| Category | `Medicine` |
| Quantity | `0` |
| Price | `0.0` |
| Cost of Goods | `0.0` |
| Limit Notice | `0` |

---

## Step 3 — Importing

Click **Import N rows** to start the import. Duniya:

1. Creates a Firestore batch (max 400 operations per batch).
2. Iterates through every valid row.
3. For each row, creates a Stock record (and a Product Master entry if
   the product name does not already exist).
4. Commits the batch.
5. Repeats until all rows are processed.

A progress ring shows the live percentage. For large imports (1000+
rows), this can take 30–60 seconds.

!!! info "Per-row fallback"
    If a batch fails (e.g. a single row violates a Firestore rule), Duniya
    falls back to writing each row individually so that one bad row does
    not block the rest.

---

## Step 4 — Summary

When the import completes, Duniya shows a summary:

- **Imported count** — how many rows were successfully written.
- **Failed count** — how many rows failed (with reasons).
- **Total processed** — the sum.

Click **Done** to close the dialog. The newly imported products appear in
your Store Inventory table immediately.

---

## The template file

The `Duniya_Inventory_Template.xlsx` file has two sheets:

### Sheet 1 — Inventory Template

| Name | Category | Manufacturer | Quantity | Price | CostOfGoods | BatchNumber | ExpiryDate | LimitNotice |
|---|---|---|---|---|---|---|---|---|
| Paracetamol 500mg | Medicine | GSK | 100 | 15.00 | 8.50 | B-2024-001 | 2026-12-31 | 20 |

### Sheet 2 — Instructions

| Field | Description | Required | Example |
|---|---|---|---|
| Name | The product name | Yes | Paracetamol 500mg |
| Category | One of the 7 categories | No (defaults to Medicine) | Medicine |
| Manufacturer | The manufacturer or brand | No | GSK |
| Quantity | Current on-hand units | No (defaults to 0) | 100 |
| Price | Selling price per unit (ZMK) | No (defaults to 0) | 15.00 |
| CostOfGoods | Cost per unit (ZMK) | No (defaults to 0) | 8.50 |
| BatchNumber | The supplier's batch number | No | B-2024-001 |
| ExpiryDate | The printed expiry date | No | 2026-12-31 |
| LimitNotice | Low-stock threshold | No (defaults to 0) | 20 |

---

## Common issues and fixes

??? question "All my rows show as invalid — what went wrong?"
    Check that your spreadsheet's first row contains headers (not data).
    Duniya uses the first row to map columns. If your data starts on row
    1, every row will be invalid because the "headers" are not recognised.

??? question "My dates are showing as invalid."
    Make sure your dates are in one of the supported formats. The most
    reliable format is ISO 8601 (`YYYY-MM-DD`). Avoid locale-specific
    formats like `Dec 31, 2026`.

??? question "My prices are showing as 0."
    Check that your price column contains numbers, not text. Excel
    sometimes stores numbers as text if the column was formatted as text.
    Select the column, format as Number, and re-save.

??? question "The import is taking forever."
    Large imports (5000+ rows) can take several minutes. Leave the dialog
    open — closing it will not cancel the import, but you will lose the
    progress indicator.

??? question "Can I re-import to update existing products?"
    Yes. If a product with the same name already exists, Duniya will
    update its quantity, price, and other fields. Be careful — this
    overwrites the existing values.

---

## Best practices

!!! tip "Clean your data before importing"
    Spend 10 minutes cleaning your spreadsheet before uploading. Remove
    empty rows, fix date formats, ensure prices are numeric. This saves
    you from chasing down invalid rows after the import.

!!! tip "Start with a small batch"
    If you have 5000 products, import 50 first. Verify they came through
    correctly, then import the rest. This catches mapping issues early.

!!! tip "Set reorder levels in the spreadsheet"
    The LimitNotice column sets the low-stock threshold. Setting it
    during import saves you from editing each product individually later.

!!! tip "Backup before bulk updates"
    If you are re-importing to update existing products, export your
    current inventory first (via the Template download or a manual
    export). This gives you a rollback point.
