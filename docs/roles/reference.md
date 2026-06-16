---
title: Role Reference
description: Detailed breakdown of each role — who they are, what they do, and which pages they use.
---

# Role Reference

This page gives a detailed breakdown of each of Duniya's six roles: who
typically holds the role, what they do day-to-day, and which Duniya pages
they spend most of their time on.

---

## Owner

**Colour:** purple  
**Icon:** `admin_panel_settings`  
**Who:** The pharmacy owner, managing director, or principal pharmacist.

The Owner is the top of the hierarchy. There is typically one Owner per
Duniya account, though an account can have multiple Owners if needed.

### Day-to-day

- Reviews the [Home dashboard](../modules/home.md) each morning.
- Checks [Finances](../modules/finances.md) for revenue and profit trends.
- Approves new staff via [Human Resource](../modules/human-resource.md).
- Approves new pharmacies and accounts via
  [Pending Approvals](../modules/pending-approvals.md).
- Manages [subscriptions and billing](../modules/settings.md#subscriptions).
- Adds new pharmacies via [My Pharmacies](../modules/my-pharmacies.md).

### Owner-only pages

- **My Pharmacies** — hidden from all other roles.
- **Human Resource** — hidden from all other roles.
- **Finances** — visible in sidebar but read-only/restricted for
  non-Owners.
- **Pending Approvals** — Duniya-admin scoped.
- **Subscription management** — the Subscription page is set to 50%
  opacity for non-Owners (clickable but warns on action).

---

## Pharmacist

**Colour:** green  
**Icon:** `medication`  
**Who:** A licensed pharmacist responsible for dispensing medication and
overseeing clinical operations.

The Pharmacist is the most permissive non-Owner role. They can do almost
everything except manage billing and team membership.

### Day-to-day

- Dispenses medication via [Sales / Dispensing](../modules/sales.md).
- Reviews and acknowledges [Low Stock Alerts](../modules/low-stock-alerts.md).
- Manages the [Product Catalogue](../modules/product-catalogue.md) —
  adding products, setting prices and reorder levels.
- Reviews [Batches & Expiry](../modules/batches.md) for FEFO compliance.
- Confirms [Goods Received](../modules/goods-received.md) when the
  technician is unavailable.
- Approves [Stock Counts](../modules/stock-counts.md).

### Not accessible

- My Pharmacies, Human Resource, Pending Approvals, Subscription
  management.
- Finances page (read-only restricted).

---

## Pharmacy Technician

**Colour:** blue  
**Icon:** `science`  
**Who:** A technician who supports the pharmacist by handling the physical
inventory — receiving deliveries, counting stock, moving product.

The Technician role is optimised for the operational side of inventory
management. They do not dispense medication or manage finances.

### Day-to-day

- Records [Goods Received](../modules/goods-received.md) — verifying
  supplier deliveries line-by-line.
- Runs [Stock Counts](../modules/stock-counts.md) — counting shelves,
  entering variances, and submitting for approval.
- Logs [Stock Movements](../modules/stock-movements.md) — transfers
  between outlets, damage adjustments.
- Reviews [Batches & Expiry](../modules/batches.md) and rotates stock
  (FEFO).
- Updates the [Store Inventory](../modules/store-inventory.md) when new
  products arrive.

### Not accessible

- Sales / Dispensing, Point of Sale (no dispensing).
- Product Catalogue editing (read-only).
- Low Stock Alert acknowledgement (read-only — they can see but not act).
- Replenishment ordering (read-only).
- Finances, My Pharmacies, Human Resource, Pending Approvals,
  Subscription.

---

## Outlet Manager

**Colour:** amber  
**Icon:** `store`  
**Who:** The manager of a single outlet — responsible for that outlet's
operations and performance.

The Outlet Manager role is scoped to a single outlet. They can do
everything within their outlet but cannot see other outlets' data or
manage pharmacy-wide settings.

### Day-to-day

- Records sales at their outlet via [Sales / Dispensing](../modules/sales.md).
- Views their outlet's [Stock Balances](../modules/stock-balances.md) and
  [Stock Movements](../modules/stock-movements.md).
- Acknowledges [Low Stock Alerts](../modules/low-stock-alerts.md) for
  their outlet.
- Places orders via [Replenishment](../modules/replenishment.md) for their
  outlet.
- Runs [Stock Counts](../modules/stock-counts.md) for their outlet.

### Not accessible

- My Pharmacies, Human Resource, Pending Approvals, Subscription.
- Finances (pharmacy-wide).
- Goods Received confirmation (technician/owner scope).
- Product Catalogue editing.

---

## Cashier

**Colour:** violet  
**Icon:** `point_of_sale`  
**Who:** A front-counter cashier who processes walk-in sales and payments.

The Cashier role is the most restricted operational role. They exist to
process sales quickly and accurately.

### Day-to-day

- Uses the [Point of Sale](../modules/pharmacy-tools.md#point-of-sale) for
  walk-in sales.
- Uses [Sales / Dispensing](../modules/sales.md) for recorded sales.
- Views the [Product Catalogue](../modules/product-catalogue.md) to look
  up prices and availability.
- Views [Notifications](../modules/notifications.md) to know what is
  out of stock.

### Not accessible

- All inventory management (add/edit products, import, movements).
- All stock counts, goods received, batches.
- Low Stock Alerts (beyond viewing notifications).
- Replenishment.
- Finances, My Pharmacies, Human Resource, Pending Approvals,
  Subscription.

---

## Staff

**Colour:** gray  
**Icon:** `badge`  
**Who:** A general-purpose staff member — trainees, assistants, or
temporary help.

The Staff role is the default for new employees who do not yet have a
specific function. It is read-only across most of the platform.

### Day-to-day

- Views the [Product Catalogue](../modules/product-catalogue.md).
- Assists with [Stock Counts](../modules/stock-counts.md) — counting
  shelves under supervision.
- Views [Notifications](../modules/notifications.md).
- Uses [Pharmacy Tools](../modules/pharmacy-tools.md) (BMI calculator,
  etc.).

### Not accessible

- All write operations on inventory (add/edit products, import).
- Sales / Dispensing, Point of Sale.
- Goods Received, Stock Movements.
- Low Stock Alerts (acknowledge/order).
- Replenishment.
- Finances, My Pharmacies, Human Resource, Pending Approvals,
  Subscription.

---

## Choosing the right role

Use this decision tree when inviting a new staff member:

```
Does the person need to manage billing or team membership?
├── Yes → Owner
└── No
    │
    Does the person dispense medication?
    ├── Yes → Pharmacist
    └── No
        │
        Does the person receive deliveries or run stock counts?
        ├── Yes → Pharmacy Technician
        └── No
            │
            Does the person manage a single outlet?
            ├── Yes → Outlet Manager
            └── No
                │
                Does the person process walk-in sales?
                ├── Yes → Cashier
                └── No → Staff
```

When in doubt, start with **Staff** and upgrade as needed. It is much
safer to grant additional access later than to revoke access that was
granted too broadly.
