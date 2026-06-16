---
title: Quickstart
description: Sign up, create your first pharmacy, and start managing inventory in under five minutes.
---

# Quickstart

Welcome to Duniya! This guide walks you through the fastest path from zero to
a fully configured pharmacy with live inventory.

---

## Step 1 — Create your account

1. Open the Duniya web app.
2. On the login screen, click **Don't have an account? Register**.
3. Choose an account type:
    - **Duniya** — a top-level account that can manage multiple pharmacies.
    - **Pharmacy** — a single-pharmacy account.
4. Enter your **email**, **password**, **first name**, and **last name**.
5. Click **Sign up** — or use **Sign up with Google** for one-click
   registration.

!!! info "What happens behind the scenes"
    Duniya creates a `User` record with the role **Owner** and triggers a
    welcome email. Owner-level accounts can manage pharmacies, team members,
    and billing.

---

## Step 2 — Complete your profile

After signing up, you will be redirected to the **Complete Registration**
page:

1. Confirm your **email address**.
2. Enter your **full name** (e.g. *John Banda*).
3. Enter your **phone number** — used for delivery notifications and
   two-factor recovery.
4. Click **Next**.

---

## Step 3 — Create your first pharmacy

You cannot manage inventory until you have at least one pharmacy.

1. On the **Create Your Pharmacy** form, enter:
    - **Pharmacy Name** *(required)* — e.g. *Health Pharmacy*.
    - **Address** *(required)* — used for delivery routing.
2. Click **Create**.

You will be redirected to the **Home** dashboard. Your pharmacy is now live
and ready to receive inventory.

!!! tip "Multi-pharmacy owners"
    Repeat Step 3 from **My Pharmacies → Add Pharmacy** to register as many
    pharmacies as you need. Each pharmacy can have multiple outlets.

---

## Step 4 — Add an outlet (optional but recommended)

Outlets are dispensing points within a pharmacy — for example, a main
branch, a kiosk, or a delivery hub.

1. Go to **My Pharmacies** in the sidebar.
2. Click **Manage** on your pharmacy card.
3. Open the **Outlets** tab.
4. Click **Add Outlet**.
5. Enter the **Outlet Name**, **Outlet Code**, and **Address**.
6. Click **Save**.

!!! warning "Why outlets matter"
    Several VMI features — Sales / Dispensing, Stock Balances, Stock Counts —
    operate **per outlet**. You need at least one outlet to enable
    dispensing.

---

## Step 5 — Add your first product

1. Go to **Store Inventory** in the sidebar.
2. Click **Add Product** in the top-right.
3. Fill in the product form:
    - **Name** *(required)* — e.g. *Paracetamol 500mg*.
    - **Category** — Medicine, Nutrition Supplements, Mother and Babycare,
      Veterinary Products, Beauty Care, Personal Care.
    - **Manufacturer** — e.g. *GSK*.
    - **Quantity** — current on-hand units.
    - **Price** (ZMK) — the selling price.
    - **Cost of Goods** (ZMK) — what you paid per unit.
    - **Batch Number** — e.g. *B-2024-001*.
    - **Expiry Date** — pick from the calendar.
    - **Limit Notice** — the low-stock threshold (alert triggers below this).
4. Click **Save**.

!!! tip "Bulk import"
    Have a spreadsheet of products? Click **Template** on the Store Inventory
    page to download `Duniya_Inventory_Template.xlsx`, fill it in, then click
    **Import** to upload hundreds of products in one go. See
    [Bulk Import](../workflows/bulk-import.md) for the full guide.

---

## Step 6 — Explore the dashboard

Your **Home** dashboard is the operational heartbeat of your pharmacy:

- **Total Stock Value** — the ZMK value of everything on your shelves.
- **Items Near Expiry** — SKUs expiring within 30 days.
- **Active Stock Items** — total unique SKUs with quantity > 0.
- **Low Stock Alerts** — items that have fallen below their reorder level.

Below the KPIs, the **Inventory Health** list shows products that need
attention, and **Movement Pulse** shows recent sales, receipts, and
adjustments.

!!! tip "Fast Actions"
    The Fast Actions grid on the Home page gives you one-click access to
    Point of Sale, Pharmacy Inventory, Goods Received, Batches & Expiry,
    Stock Movements, Low Stock Alerts, and Replenishment.

---

## Step 7 — Invite your team

As an Owner, you can invite team members with role-based access:

1. Go to **Human Resource** in the sidebar.
2. Click **Add New Staff**.
3. Pick a **role** — Cashier, Pharmacist, Manager, Technician, or Owner.
4. Enter the staff member's **name**, **email**, **phone**, and a
   **password**.
5. Click **Save**.

The new staff member can now sign in with their email and password at the
same Duniya URL. See [Roles & Permissions](../roles/overview.md) for what
each role can do.

---

## You're done!

Congratulations — you now have:

- ✅ A registered Duniya account
- ✅ A pharmacy with at least one outlet
- ✅ Your first product in inventory
- ✅ A live dashboard
- ✅ A team member invited (optional)

### Where to go next

- **[Run a sale](../modules/sales.md)** — dispense medication and generate
  receipts.
- **[Receive goods](../modules/goods-received.md)** — record supplier
  deliveries with line-item verification.
- **[Run a stock count](../modules/stock-counts.md)** — reconcile system
  vs. physical stock.
- **[Track batches](../modules/batches.md)** — never let a product expire
  on the shelf again.

---

!!! success "Need help?"
    If you get stuck at any point, the **Notifications** bell in the top bar
    surfaces low-stock and expiry alerts. The sidebar's **Settings** page has
    contact information for support.
