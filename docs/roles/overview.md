---
title: Roles & Permissions Overview
description: Duniya's six built-in roles and what each one can do.
---

# Roles & Permissions Overview

Duniya uses **role-based access control (RBAC)** to determine what each
user can see and do. Six built-in roles cover every common pharmacy team
position, from the Owner down to a junior Staff member.

---

## The six roles

| Role | Colour | Icon | One-liner |
|---|---|---|---|
| **Owner** | purple | admin_panel_settings | Full access to everything. |
| **Pharmacist** | green | medication | Dispenses medication, manages inventory. |
| **Pharmacy Technician** | blue | science | Performs stock counts, receives goods. |
| **Outlet Manager** | amber | store | Manages a single outlet. |
| **Cashier** | violet | point_of_sale | Processes sales and payments. |
| **Staff** | gray | badge | Views the catalogue, assists with counts. |

---

## Permission matrix

| Capability | Owner | Pharmacist | Technician | Outlet Manager | Cashier | Staff |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **View Home dashboard** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **View Store Inventory** | ✅ | ✅ | ✅ | ✅ | ✅ (read) | ✅ (read) |
| **Add / edit products** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Import spreadsheet** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **View Product Catalogue** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Edit Product Catalogue** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **View Stock Balances** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **View Stock Movements** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **Record Stock Movement** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **View Stock Counts** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **Create / approve Stock Count** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **View Goods Received** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **Create / confirm receipt** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **View Batches & Expiry** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Export Batch PDF** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **View Low Stock Alerts** | ✅ | ✅ | ✅ | ✅ (own outlet) | ❌ | ❌ |
| **Acknowledge / order** | ✅ | ✅ | ❌ | ✅ (own outlet) | ❌ | ❌ |
| **View Replenishment** | ✅ | ✅ | ❌ | ✅ (own outlet) | ❌ | ❌ |
| **Place order** | ✅ | ✅ | ❌ | ✅ (own outlet) | ❌ | ❌ |
| **View Sales / Dispensing** | ✅ | ✅ | ❌ | ✅ (own outlet) | ✅ (own outlet) | ❌ |
| **Record sale** | ✅ | ✅ | ❌ | ✅ (own outlet) | ✅ (own outlet) | ❌ |
| **Use Point of Sale** | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ |
| **View Finances** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **View My Pharmacies** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Add pharmacy / outlet** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **View Human Resource** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Invite staff** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **View Pending Approvals** | ✅ (admin) | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Manage subscription** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **View Notifications** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Use Pharmacy Tools** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Edit own profile** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Switch language** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Toggle dark mode** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Sidebar visibility

The sidebar shows different sections based on role:

- **Owner** sees everything: MAIN (Home, My Pharmacies, Human Resource,
  Finances, Pending Approvals) + INVENTORY + OPERATIONS.
- **All other roles** see: MAIN (Home, Finances — read-only if accessible)
  + INVENTORY + OPERATIONS. My Pharmacies and Human Resource are hidden.

The mobile bottom navbar shows the same items regardless of role — but
tapping a restricted item (e.g. My Pharmacies as a Cashier) shows an
empty state.

---

## Assigning roles

Owners assign roles when inviting staff from
[Human Resource → Add New Staff](../modules/human-resource.md#adding-a-staff-member).
The role picker in the Add User form presents each role with its icon and
a one-line description.

!!! warning "Role changes require a new Staff record"
    Duniya does not currently support in-place role changes. To change a
    staff member's role, delete their Staff record and create a new one
    with the correct role. Their historical data remains attributed to
    the deleted record.

---

## Principle of least privilege

When in doubt, pick the most restrictive role that lets the person do
their job:

- A cashier only needs to record sales — give them **Cashier**, not
  Pharmacist.
- A stock-taker only needs to count — give them **Pharmacy Technician**,
  not Pharmacist.
- A new employee shadowing the team — give them **Staff** until they are
  trained.

You can always upgrade a role later by creating a new Staff record.

---

## Frequently asked questions

??? question "Can I create custom roles?"
    Not currently. Duniya ships with six fixed roles. If your pharmacy
    needs a custom role (e.g. *Delivery Driver*), use the closest match
    (Staff) and manage the difference through training and SOPs.

??? question "Can a user have multiple roles?"
    No. Each Staff record has a single role. To give someone access to
    multiple roles' capabilities, pick the more permissive role.

??? question "What happens when an Owner leaves the pharmacy?"
    The pharmacy needs at least one Owner. Before removing an Owner,
    promote another staff member to Owner first. Then delete the original
    Owner's account.

??? question "Can a Staff member see financial data?"
    No. The Finances page is Owner-only. Staff see the Finances link in
    the sidebar but the page shows a restricted view (or empty state).

??? question "How do I revoke access for a departed staff member?"
    Go to **Human Resource**, find the staff member, and click **Delete**.
    Their account is immediately disabled — they can no longer sign in.
    Their historical records remain for audit.
