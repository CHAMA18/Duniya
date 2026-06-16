---
title: Multi-Pharmacy Setup
description: Onboard a multi-location pharmacy network — add pharmacies, configure outlets, invite team, switch contexts.
---

# Multi-Pharmacy Setup

This workflow walks you through setting up a multi-location pharmacy
network on Duniya — from your first pharmacy to a fully staffed,
multi-outlet operation.

---

## Prerequisites

- A Duniya Owner account (sign up at the Duniya URL).
- Your business details: pharmacy names, addresses, license numbers.
- A list of staff members with their roles and email addresses.

---

## Step 1 — Create your first pharmacy

If you have not yet created any pharmacy:

1. After signing up, Duniya will prompt you to **Create Your Pharmacy**.
2. Enter the pharmacy name and address.
3. Click **Create**.

You will land on the Home dashboard. Your first pharmacy is now live.

📖 **Detailed docs:** [Quickstart](../getting-started/quickstart.md)

---

## Step 2 — Add outlets to the pharmacy

Each pharmacy needs at least one outlet to enable dispensing.

1. Go to **My Pharmacies** in the sidebar.
2. Click **Manage** on your pharmacy card.
3. Open the **Outlets** tab.
4. Click **Add Outlet**.
5. Enter:
    - **Outlet Name** — e.g. *Main Branch*.
    - **Outlet Code** — e.g. *MAIN-01*.
    - **Address** — the physical location.
6. Click **Save**.

Repeat for every dispensing point in this pharmacy (kiosks, satellite
branches, delivery vehicles, etc.).

📖 **Detailed docs:** [My Pharmacies](../modules/my-pharmacies.md)

---

## Step 3 — Invite team members

1. Go to **Human Resource** in the sidebar.
2. Click **Add New Staff**.
3. Pick a **role** for the staff member (see
   [Roles & Permissions](../roles/overview.md) for guidance).
4. Enter their name, email, phone, and a temporary password.
5. Assign them to the relevant pharmacy.
6. Click **Save**.

Repeat for every team member. They will receive an invitation email and
can sign in at the same Duniya URL.

📖 **Detailed docs:** [Human Resource](../modules/human-resource.md)

---

## Step 4 — Add your second pharmacy

Once your first pharmacy is operational, add additional pharmacies the
same way:

1. Go to **My Pharmacies**.
2. Click **Add Pharmacy**.
3. The 3-step wizard launches:
    - **Pharmacy Details** — name, address, phone, email, license.
    - **Outlets** — add at least one outlet.
    - **Team & Roles** — invite staff (optional at this stage).
4. Click **Save**.

📖 **Detailed docs:** [My Pharmacies → Adding a pharmacy](../modules/my-pharmacies.md#adding-a-pharmacy)

---

## Step 5 — Populate inventory

For each pharmacy, you need to populate its inventory. Two options:

### Option A — Manual entry

1. Go to **Store Inventory**.
2. Click **Add Product**.
3. Fill in the product form.
4. Save.
5. Repeat for every product.

Best for pharmacies with small catalogues (<50 products).

### Option B — Bulk import

1. Go to **Store Inventory**.
2. Click **Template** to download the Excel template.
3. Fill in your products — one row per product.
4. Click **Import**, pick the file, preview, and confirm.
5. Duniya creates all stock records in batches of 400.

Best for pharmacies with large catalogues or migrations from another
system.

📖 **Detailed docs:** [Bulk Import](bulk-import.md)

---

## Step 6 — Set reorder levels

For every product, set the reorder level and target stock level. These
drive the entire replenishment cycle.

1. Go to **Product Catalogue**.
2. Click a product to open the detail drawer.
3. Set:
    - **Minimum Stock Level** — the hard floor (usually 0).
    - **Reorder Level** — when the alert fires.
    - **Target Stock Level** — where stock should sit after replenishment.
4. Save.

Use the formula in [Core Concepts → Product Master](../getting-started/concepts.md#products-vs-stock)
to compute sensible values.

📖 **Detailed docs:** [Product Catalogue → Setting smart reorder levels](../modules/product-catalogue.md#setting-smart-reorder-levels)

---

## Step 7 — Switch between pharmacies

When you have multiple pharmacies, you will need to switch context
frequently:

- **From My Pharmacies:** Click **Manage** on any pharmacy card to scope
  every page to that pharmacy.
- **From any VMI page:** Use the pharmacy filter dropdown in the filter
  bar.
- **From the URL:** The `pharmacy` query parameter scopes the current
  page.

📖 **Detailed docs:** [My Pharmacies → Switching pharmacy context](../modules/my-pharmacies.md#switching-pharmacy-context)

---

## Step 8 — Train your team

Once the system is set up, train your team on the workflows relevant to
their role:

| Role | Train on |
|---|---|
| **Pharmacist** | Sales / Dispensing, Low Stock Alerts, Batches & Expiry, Product Catalogue. |
| **Pharmacy Technician** | Goods Received, Stock Counts, Stock Movements. |
| **Outlet Manager** | Sales / Dispensing, Stock Balances, Replenishment (for their outlet). |
| **Cashier** | Point of Sale, Product Catalogue (read-only). |
| **Staff** | Notifications, Pharmacy Tools. |

Point them to the [Quickstart](../getting-started/quickstart.md) and the
[Roles Reference](../roles/reference.md) for self-service learning.

---

## Multi-pharmacy tips

!!! tip "Use consistent naming"
    Name your pharmacies and outlets consistently. *Health Pharmacy —
    Main*, *Health Pharmacy — Kiosk #1*, *Health Pharmacy — Delivery Hub*.
    This makes the Manage Pharmacy dropdowns and filter lists scannable.

!!! tip "Centralise the Product Catalogue"
    The Product Catalogue is shared across all pharmacies. Set prices and
    reorder levels centrally — per-pharmacy stock inherits them. This
    avoids the trap of each pharmacy maintaining its own price list.

!!! tip "Review Finances account-wide"
    The Finances page aggregates across all your pharmacies. Use it for
    monthly reviews — per-pharmacy drill-down is on the roadmap.

!!! tip "Standardise stock count cadence"
    Count the same products on the same day across all pharmacies. This
    makes variance comparison meaningful — if the main branch has a 2%
    variance and the kiosk has 8%, you know where to focus.

---

## Troubleshooting

??? question "My staff cannot see the pharmacies I created."
    Staff records have a `PharmId` field — if it is not set, they will
    not see pharmacy-scoped data. Edit the staff record and assign them
    to a pharmacy.

??? question "My cashier sees the Finances link but cannot access it."
    The Finances page is Owner-only. The sidebar link is visible to all
    roles by design — non-Owners see a restricted view when they click
    it. This is expected behaviour.

??? question "I accidentally created two pharmacies with the same name."
    Use **Manage Pharmacy → Edit** to rename one, or delete the duplicate
    from My Pharmacies. Deleting a pharmacy removes its stock, sales, and
    movements — be careful.

??? question "Can I transfer stock between two different pharmacies?"
    Not directly. The Stock Movements → Transfer flow is for outlet-to-
    outlet transfers within the same pharmacy. For cross-pharmacy
    transfers, record an ADJUSTMENT (negative) at the source and an
    ADJUSTMENT (positive) at the destination, with matching reasons.
