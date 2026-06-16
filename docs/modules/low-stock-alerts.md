---
title: Low Stock Alerts
description: Get notified the moment a product drops below its reorder level. Acknowledge, order, and resolve — all in one place.
---

# Low Stock Alerts

The **Low Stock Alerts** page is your action queue for restocking. Every
time a product's on-hand quantity drops below its **Reorder Level**, Duniya
creates an alert. Your job is to walk each alert through to resolution.

---

## The alert lifecycle

```
        Stock drops below Reorder Level
                     │
                     ▼
                  ACTIVE ────acknowledge───► ACKNOWLEDGED ────mark ordered───► ORDERED
                     │                                                              │
                     │                                                              ▼
                     │                                                       (purchase order
                     │                                                        placed with
                     │                                                        supplier)
                     ▼
              Suggested Quantity displayed
              (Target Stock Level − Current Stock)
```

- **ACTIVE** — the alert just fired. Nobody has responded yet.
- **ACKNOWLEDGED** — a team member has seen it and is preparing an order.
- **ORDERED** — a purchase order has been placed with the supplier.

---

## Page anatomy

1. **Breadcrumb + hero header** with icon, title, and explainer subtitle.
2. **Four summary metric cards** — Active / Acknowledged / Ordered / Total.
3. **Status segmented control** — All / Active / Acknowledged / Ordered.
4. **Filter bar** — search, pharmacy filter, sort.
5. **Alerts list** — polished cards, one per alert.
6. **Empty state** — a world-class celebration when there is nothing to do.

---

## Summary metric cards

| Card | Status | What it means |
|---|---|---|
| **Active alerts** | ACTIVE | Awaiting acknowledgement. Take action now. |
| **Acknowledged** | ACKNOWLEDGED | Ready to be ordered. |
| **Ordered** | ORDERED | Purchase order placed. Resolution pending delivery. |
| **Total alerts** | (all) | Every alert in the system, regardless of status. |

Each card carries a contextual subtitle ("Awaiting acknowledgement", "Ready
to be ordered", "Purchase order placed", "Across all pharmacies") so the
meaning is unambiguous.

---

## Status segmented control

The four-tab segmented control lets you filter the alerts list by status:

| Tab | Filter |
|---|---|
| **All** | No filter — every alert. |
| **Active** | Status = ACTIVE |
| **Acknowledged** | Status = ACKNOWLEDGED |
| **Ordered** | Status = ORDERED |

Each tab displays a live count badge so you can see at a glance how many
alerts are in each state without clicking through.

---

## Filter bar

| Control | Purpose |
|---|---|
| **Search** | Free-text search by product name or pharmacy name. |
| **Pharmacy** | Filter to a single pharmacy (multi-pharmacy owners only). |
| **Sort** | Most critical (lowest stock first), Recently updated, Product name. |

The default sort is **Most critical** — the alerts with the biggest gap
between current stock and reorder level appear at the top.

---

## Alert rows

Each alert is rendered as a card with:

- **Icon tile** — purple-tinted medication icon.
- **Product name** and pharmacy name.
- **Stock-level progress bar** — red when below reorder, green when safe.
  Shows current stock and reorder level.
- **Suggested quantity** — the recommended order size, computed as
  `Target Stock Level − Current Stock`.
- **Status pill** — coloured to match the lifecycle state.
- **Action button** — context-aware:
    - ACTIVE → **Acknowledge**
    - ACKNOWLEDGED → **Mark Ordered**
    - ORDERED → **Resolved** (display only)

---

## Taking action

### Acknowledging an alert

When you see an ACTIVE alert and decide to act on it:

1. Click **Acknowledge** on the alert row.
2. The status changes to ACKNOWLEDGED.
3. The alert moves out of the Active tab and into the Acknowledged tab.

Acknowledging does not place an order — it simply marks that someone has
seen the alert and is handling it.

### Marking an alert as ordered

Once you have placed a purchase order with the supplier:

1. Switch to the **Acknowledged** tab.
2. Find the alert for the product you ordered.
3. Click **Mark Ordered**.
4. The status changes to ORDERED.

!!! tip "Use this moment to record the Goods Received"
    When the supplier's delivery arrives, head to
    [Goods Received](goods-received.md) and record the receipt. Once stock
    is replenished above the reorder level, the alert will not re-fire (the
    system checks current stock on each alert evaluation).

---

## Suggested order quantity

Every alert displays a **Suggested Quantity**. This is computed as:

```
SuggestedQuantity = TargetStockLevel − CurrentStock
```

It is the amount you need to order to bring stock back up to your target
level. The Target Stock Level is set per-product on the
[Product Catalogue](product-catalogue.md) page.

!!! info "Suggested vs. actual order"
    The suggested quantity is a recommendation, not a mandate. Adjust based
    on:

    - **Lead time** — if your supplier takes 2 weeks, order more.
    - **Demand spikes** — flu season? Order more paracetamol.
    - **Minimum order quantities** — suppliers may require MOQs that differ
      from the suggestion.

---

## Empty state

When there are no alerts to action, Duniya celebrates:

- A soft gradient halo around a circular checkmark icon.
- A friendly headline: *"No low stock alerts"* or *"Nothing to action here"*.
- Contextual supporting copy: *"All products are above their reorder
  levels. Nicely done."*

If you have filters applied and the list is empty, the empty state offers a
**Clear all filters** action so you can quickly verify whether the empty
list is real or just a filter artefact.

---

## How alerts are created

Duniya evaluates stock levels in real time. When the on-hand quantity of a
product crosses below its Reorder Level, the system:

1. Checks if an ACTIVE or ACKNOWLEDGED alert already exists for that
   product+pharmacy combination.
2. If yes, updates the existing alert's `CurrentStock` and `SuggestedQuantity`.
3. If no, creates a new alert with status `ACTIVE`.

This means you will never have duplicate alerts for the same product. Each
alert is a single, updateable record.

---

## Frequently asked questions

??? question "Why did my alert disappear?"
    Alerts do not disappear — they transition to ORDERED and then stay in
    that tab. If you cannot find one, switch to the **Ordered** tab or clear
    your filters.

??? question "Can I dismiss an alert without ordering?"
    No — Duniya intentionally does not offer a "dismiss" action. If a
    product is below reorder, you should either order more or accept the
    stockout. Marking it as ordered without placing an order would break
    the audit trail.

??? question "How often are alert quantities updated?"
    In real time. Every Stock Movement (sale, receipt, adjustment) triggers
    a re-evaluation of the affected product's alert.

??? question "Can I get email or SMS notifications?"
    Email and push notifications are on the roadmap. For now, check the
    page daily — the top-nav bell icon surfaces a count of unread alerts.
