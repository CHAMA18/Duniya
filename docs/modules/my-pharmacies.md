---
title: My Pharmacies
description: Manage multiple pharmacies from one account. Add outlets, view performance, switch contexts.
---

# My Pharmacies

The **My Pharmacies** page is the headquarters for multi-pharmacy owners.
From here you can add new pharmacies, manage outlets, view performance
metrics, and drill into any pharmacy's full operational detail.

!!! info "Owner-only"
    The My Pharmacies page is visible only to users with the **Owner**
    role. Staff see the page in the mobile navbar but with limited actions.

---

## Page anatomy

1. **Header** with **Add Pharmacy** button.
2. **Search bar** — "Search locations, managers, or IDs...".
3. **Pharmacy Cards** — responsive grid (1/2/3 columns based on screen
   width), one card per pharmacy.
4. **Pharmacy Outlets** section — Wrap of outlet cards with toggle and
   delete actions.

---

## Pharmacy cards

Each pharmacy card shows:

- **Pharmacy ID** — auto-generated identifier (e.g. *PH-001*).
- **Active status** badge.
- **Pharmacy name**.
- **Lead pharmacist** — the primary contact.
- **Manage** button → navigates to the
  [Manage Pharmacy](manage-pharmacy.md) page.

Click **Manage** to see the full operational detail for that pharmacy:
inventory, stock balances, movements, batches, replenishment, alerts, and
outlets — all in tabbed view.

---

## Adding a pharmacy

1. Click **Add Pharmacy** in the top-right.
2. The Add Pharmacy wizard launches — a 3-step process:

### Step 1 — Pharmacy Details

- **Pharmacy Name** *(required)*
- **Address** *(required)*
- **Phone**
- **Email**
- **License** — the pharmacy's operating license number.

### Step 2 — Outlets

- Click **Add New Outlet** to add dispensing points.
- For each outlet, enter **Outlet Name**, **Outlet Code**, and **Address**.
- You can add multiple outlets now or come back later.

!!! warning "At least one outlet is required for dispensing"
    You can save the pharmacy with zero outlets, but you will not be able
    to record sales or receive goods until at least one outlet exists.

### Step 3 — Team & Roles

- Click **Add Member** to invite team members.
- Pick a role for each: Owner, Pharmacist, Pharmacy Technician, Outlet
  Manager, Cashier, or Staff.
- Enter their name, email, phone, and a temporary password.

3. Click **Save**. Duniya:

   - Creates the `PharmacyRecord`.
   - Creates the outlets you entered.
   - Sends invitation emails to the team members.
   - Navigates you back to the My Pharmacies page.

A success toast appears: *"Pharmacy '<name>' created successfully!"*

---

## Managing outlets

Below the pharmacy cards, the **Pharmacy Outlets** section lists every
outlet across all your pharmacies. Each outlet card shows:

- **Outlet name**
- **Outlet code** badge
- **Address**
- **Active toggle** — flip to enable/disable the outlet. Disabled outlets
  cannot make sales or receive goods.
- **Delete** button — removes the outlet (with confirmation dialog).

### Adding an outlet

1. In the Pharmacy Outlets section, click **Add Outlet**.
2. In the dialog, enter:
    - **Outlet Name** *(required)*
    - **Outlet Code** *(required)*
    - **Address**
3. Click **Save**. The new outlet appears immediately in the wrap.

---

## Switching pharmacy context

Several VMI pages accept a `pharmacy` query parameter that scopes their
data. When you click a Fast Action on the Home page or navigate from the
sidebar, Duniya uses your currently selected pharmacy (stored in
`FFAppState().Pharm`).

To change the selected pharmacy:

- Click **Manage** on a pharmacy card → the selected pharmacy updates.
- Use the **Switch Pharmacy** component (available on some pages) to pick a
  different pharmacy without leaving your current view.

---

## Performance metrics

Each pharmacy card surfaces a few high-level metrics:

- Active status
- Number of outlets
- Lead pharmacist name

For detailed performance — revenue, profit, stock value — drill into the
[Manage Pharmacy](manage-pharmacy.md) page or visit the
[Finances](finances.md) module which aggregates across pharmacies.

---

## Frequently asked questions

??? question "How many pharmacies can I have?"
    There is no hard limit on the number of pharmacies per Owner account.
    Your subscription tier may impose soft limits — see
    [Subscriptions](settings.md#subscriptions).

??? question "Can I transfer a pharmacy to another owner?"
    Not currently. To transfer ownership, contact Duniya support — they can
    reassign the `OwnerRef` field on the Pharmacy record.

??? question "What happens when I deactivate an outlet?"
    The outlet's stock remains, but no new sales, receipts, or movements
    can be recorded against it. Existing data is preserved.

??? question "Can two pharmacies share stock?"
    No. Each pharmacy has its own stock. To move stock between pharmacies,
    use the [Stock Movements → Transfer](stock-movements.md#to-record-a-transfer)
    flow — though this is intended for outlet-to-outlet transfers within
    the same pharmacy. Cross-pharmacy transfers require a manual
    adjustment.
