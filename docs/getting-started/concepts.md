---
title: Core Concepts
description: The mental model behind Duniya — pharmacies, outlets, products, batches, and how they fit together.
---

# Core Concepts

Before diving into individual modules, it helps to understand the mental model
that underpins Duniya. Five concepts — **Owner**, **Pharmacy**, **Outlet**,
**Product**, and **Batch** — explain 90% of what you will see in the
interface.

---

## The ownership hierarchy

```
Owner (you, the Duniya user)
 └── Pharmacy (e.g. "Health Pharmacy")
      ├── Outlet (e.g. "Main Branch", "Kiosk #1")
      │    └── Stock (items physically sitting on that outlet's shelf)
      └── Outlet (e.g. "Delivery Hub")
           └── Stock
```

### Owner

The **Owner** is the top-level account. A single email address signs in as
one Owner. Owners can:

- Create unlimited pharmacies.
- Invite team members with role-based access.
- View financial data across every pharmacy they own.
- Manage their subscription and billing.

!!! info "Duniya vs Pharmacy accounts"
    During registration you can pick a **Duniya** account (multi-pharmacy) or
    a **Pharmacy** account (single-pharmacy). Both create an Owner — the
    difference is whether the multi-pharmacy features are surfaced in the UI.

### Pharmacy

A **Pharmacy** is a legal entity — for example, *Health Pharmacy Ltd*. Each
pharmacy has its own:

- Name, address, and contact details
- Set of outlets
- Stock, sales, batches, and alerts
- Staff assignments

### Outlet

An **Outlet** is a physical dispensing point inside a pharmacy. Examples:

- The main counter of your pharmacy
- A kiosk in a shopping mall
- A delivery vehicle
- A satellite branch in another town

Most VMI records — Stock Balances, Stock Movements, Goods Received, Sales,
Stock Counts — are scoped to a specific outlet.

!!! warning "You need at least one outlet"
    Duniya will warn you if you try to dispense or receive goods without an
    outlet configured. Create one from **My Pharmacies → Manage → Outlets**.

---

## Products vs. Stock

This is the most important distinction in Duniya.

### Product (Product Master)

A **Product** is the *catalogue entry* for an item — the abstract idea of a
medicine. It is defined once and reused across every pharmacy and outlet.
Fields include:

- **Name**, **Generic Name**, **Brand Name**
- **Strength** (e.g. *500mg*), **Dosage Form** (e.g. *Tablet*), **Pack Size**
- **SKU** — your internal stock-keeping unit
- **Category** — Medicine, Nutrition Supplements, etc.
- **Supplier**
- **Cost Price** and **Selling Price** (ZMK)
- **Minimum Stock Level**, **Reorder Level**, **Target Stock Level**

The Product Master is shared across your entire Duniya account. Update a
price here and it updates everywhere.

### Stock (Stock Record)

A **Stock** record is a *physical instance* of a product on a specific
outlet's shelf. It carries:

- A reference to the Product Master
- A **Quantity** (current on-hand units)
- A **Batch Number** (links to a specific Batch record)
- An **Expiry Date**
- A **Limit Notice** (low-stock threshold — may differ per outlet)
- A **Damaged Goods** count

You can have many Stock records for the same Product — one per batch, per
outlet.

!!! example "Concrete example"
    - **Product Master:** *Paracetamol 500mg*, SKU *PARA-500*, selling price
      *ZMK 15.00*.
    - **Stock (outlet Main Branch, batch B-2024-001):** 100 units, expires
      2026-12-31.
    - **Stock (outlet Main Branch, batch B-2024-002):** 50 units, expires
      2027-03-15.
    - **Stock (outlet Kiosk #1, batch B-2024-001):** 20 units, expires
      2026-12-31.

---

## Batches

A **Batch** is a specific shipment of a product from a supplier. Every batch
carries:

- A **Batch Number** (e.g. *B-2024-001*)
- An **Expiry Date**
- A **Quantity** (the original units received)
- A **Facility Location** (which outlet or warehouse it sits in)

Tracking batches separately is what allows Duniya to:

- Warn you about expiring stock before it becomes a loss.
- Recall a specific batch if a supplier issues a recall.
- Apply FEFO (First-Expired-First-Out) logic when dispensing.

See [Batches & Expiry](../modules/batches.md) for the full lifecycle.

---

## The VMI cycle

Vendor-Managed Inventory (VMI) is the operational backbone of Duniya. Every
pharmacy goes through the same loop, again and again:

```
        ┌──────────────────────────────────────┐
        │                                      │
        ▼                                      │
  Product Master ──► Stock Balances           │
        │                  │                   │
        │                  ▼                   │
        │           Stock Movements            │
        │            (RECEIVED / SOLD /        │
        │             TRANSFERRED /            │
        │             ADJUSTMENT)              │
        │                  │                   │
        │                  ▼                   │
        │           Goods Received ────────► Batches
        │                  │                   │
        │                  ▼                   │
        │           Stock Counts               │
        │            (DRAFT → APPROVED)        │
        │                  │                   │
        │                  ▼                   │
        │           Low Stock Alerts           │
        │            (ACTIVE → ACK → ORDERED)  │
        │                  │                   │
        └──────────────────┴───────────────────┘
                       Replenishment
```

| Stage | What happens | Where in Duniya |
|---|---|---|
| **Product Master** | Define the catalogue | Product Catalogue |
| **Stock Balances** | Snapshot opening/closing stock per period | Stock Balances |
| **Stock Movements** | Record every in/out/transfer/adjustment | Stock Movements |
| **Goods Received** | Verify supplier deliveries line-by-line | Goods Received |
| **Batches** | Track expiry per batch | Batch & Expiry |
| **Stock Counts** | Reconcile system vs. physical | Stock Counts |
| **Low Stock Alerts** | Notify when below reorder level | Low Stock Alerts |
| **Replenishment** | Suggest reorder quantities | Replenishment |

Each module is documented in detail in the [Modules](../modules/store-inventory.md)
section.

---

## Status workflows

Several Duniya records move through a defined status lifecycle. Knowing
these states makes the platform much easier to navigate.

### Low Stock Alert

```
ACTIVE ──acknowledge──► ACKNOWLEDGED ──mark ordered──► ORDERED
```

- **ACTIVE** — the alert just fired; nobody has responded yet.
- **ACKNOWLEDGED** — a team member has seen it and is preparing an order.
- **ORDERED** — a purchase order has been placed with the supplier.

### Goods Received

```
PENDING ──confirm──► CONFIRMED
   │
   └──discrepancy──► DISCREPANCY
```

- **PENDING** — delivery received, awaiting verification.
- **CONFIRMED** — quantities match the delivery note.
- **DISCREPANCY** — short shipped, over shipped, or damaged.

### Stock Count

```
DRAFT ──approve──► APPROVED
   │
   └──reject──► REJECTED
```

- **DRAFT** — count in progress.
- **APPROVED** — count finalised; variances posted as adjustments.
- **REJECTED** — count discarded; no changes posted.

### Stock Movement type

Not a status per se, but a classifier:

- **RECEIVED** — stock came in (from a supplier or another outlet).
- **SOLD** — stock went out (dispensed to a patient).
- **TRANSFERRED** — stock moved between outlets.
- **ADJUSTMENT** — manual correction (damage, loss, recount).

---

## Currency and locale

- **Currency:** ZMK (Zambian Kwacha). All monetary values in Duniya are in
  ZMK. Multi-currency support is on the roadmap.
- **Payment region:** Zambia. The DPO payment gateway handles local payment
  methods (mobile money, bank transfer). Stripe handles international cards.
- **UI languages:** 10 locales — English, Afrikaans, Hindi, Spanish, Italian,
  Swahili, French, Nyanja, Arabic, Portuguese. Switch from
  **Settings → Language**.

---

## What's next

Now that you have the mental model, head to the **[Module Reference](../modules/store-inventory.md)**
to see how each piece works in detail — or jump into the
**[Workflows](../workflows/inventory-cycle.md)** section for end-to-end
recipes.
