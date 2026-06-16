---
title: Workflows
description: End-to-end recipes for common Duniya tasks — the inventory cycle, bulk import, multi-pharmacy setup.
---

# Workflows

This section contains end-to-end recipes for common tasks that span
multiple modules. While the [Modules](../modules/store-inventory.md)
section documents each page in isolation, the Workflows section shows
how the modules fit together.

## Workflows

| Workflow | What you'll learn |
|---|---|
| **[The Inventory Cycle](inventory-cycle.md)** | The 8-stage operational loop every pharmacy runs through — from product setup to replenishment. |
| **[Bulk Import Inventory](bulk-import.md)** | Upload hundreds of products in one go via a spreadsheet. Template, validation, and the 4-step wizard. |
| **[Multi-Pharmacy Setup](multi-pharmacy-setup.md)** | Onboard a multi-location pharmacy network — add pharmacies, configure outlets, invite team, switch contexts. |

## How these workflows connect

```
   Multi-Pharmacy Setup (one-time)
              │
              ▼
   Bulk Import Inventory (initial population)
              │
              ▼
   ┌──── The Inventory Cycle ────┐
   │  (repeats daily / weekly)   │
   │                             │
   │  Receive → Track → Sell →   │
   │  Move → Count → Alert →     │
   │  Replenish → (back to Receive) │
   └─────────────────────────────┘
```

## When to use which workflow

- **Just signed up?** Start with [Multi-Pharmacy Setup](multi-pharmacy-setup.md).
- **Need to load your existing products?** Use [Bulk Import](bulk-import.md).
- **Daily operations?** Follow [The Inventory Cycle](inventory-cycle.md).

## Tips

!!! tip "Bookmark the Inventory Cycle"
    The Inventory Cycle page is the most-referenced workflow. Bookmark it
    and share it with new staff during onboarding.

!!! tip "Custom workflows"
    Duniya is flexible — you do not have to follow the workflows in this
    section exactly. Adapt them to your pharmacy's specific needs. The
    modules are designed to work in any order.
