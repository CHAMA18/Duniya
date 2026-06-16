---
title: Notifications
description: A unified inbox for low-stock and expiry alerts, classified by severity.
---

# Notifications

The **Notifications** page is your unified inbox for inventory alerts. It
pulls together low-stock warnings and expiry warnings into a single view,
classified by severity so the most urgent items bubble to the top.

!!! info "How to get here"
    Click the **bell icon** in the top navigation bar. The bell shows a
    count of unread alerts.

---

## Page anatomy

1. **Header** with title and severity summary cards.
2. **Tabs** — Low Stock / Expiring Soon / All.
3. **Sort** — Severity (default).
4. **Search** — "Search by name or category...".
5. **Notifications list**.

---

## Severity classification

Every notification is classified into one of four severity levels based on
how urgent it is:

| Severity | Trigger | Colour | Icon |
|---|---|---|---|
| **Out of Stock** | `quantity ≤ 0` | red `#DC2626` | error |
| **Critical** | `quantity ≤ 2` | orange `#EA580C` | warning |
| **Low Stock** | `quantity ≤ LimitNotice` | amber `#D97706` | info |
| **Warning** | Expiring within 30 days | blue `#2563EB` | schedule |

The default sort is **Severity** — Out of Stock items appear first,
followed by Critical, Low, and Warning.

---

## Summary cards

Four cards at the top give you an instant count of each severity:

| Card | Description |
|---|---|
| **Out of Stock** | Count of products with zero on-hand units. |
| **Critical** | Count of products with 1–2 units left. |
| **Low Stock** | Count of products below their reorder level. |
| **Expiring Soon** | Count of batches expiring within 30 days. |

Each card is also a filter — click it to filter the list to that severity.

---

## Tabs

| Tab | Filter |
|---|---|
| **Low Stock** | Only low-stock and out-of-stock notifications. |
| **Expiring Soon** | Only expiry notifications. |
| **All** | Every notification. |

The **All** tab is the default and is the recommended starting point — it
gives you the complete picture.

---

## Notification rows

Each notification shows:

- **Product name** and category icon.
- **Pharmacy** and outlet.
- **Severity badge** — colour-coded with the icon.
- **Details** — current quantity, reorder level, or expiry date.
- **Action button** — quick link to the relevant module (Store Inventory,
  Batches & Expiry, or Low Stock Alerts).

---

## Taking action

The Notifications page is a launchpad, not an endpoint. For each alert:

1. Click the action button to drill into the relevant module.
2. Take the appropriate action:
    - For **Out of Stock**: place an order via
      [Replenishment](replenishment.md).
    - For **Critical / Low Stock**: acknowledge via
      [Low Stock Alerts](low-stock-alerts.md).
    - For **Expiring Soon**: dispense first (FEFO), discount, or write off
      via [Batches & Expiry](batches.md).
3. The notification clears once the underlying condition is resolved.

---

## Frequently asked questions

??? question "Why does the bell icon count not match the Notifications page?"
    The bell icon count is cached briefly (a few seconds). The
    Notifications page reflects real-time data. If they differ, refresh the
    page.

??? question "Can I mark a notification as read without acting on it?"
    Not currently. Notifications clear automatically when the underlying
    condition is resolved. This is intentional — every alert deserves a
    response.

??? question "Can I get email or push notifications?"
    Email and push notifications are on the roadmap. For now, check the
    bell icon daily.

??? question "What is the difference between Low Stock Alerts and Notifications?"
    [Low Stock Alerts](low-stock-alerts.md) is the action queue for
    restocking — it tracks the ACTIVE → ACKNOWLEDGED → ORDERED lifecycle.
    Notifications is the unified inbox — it includes low-stock alerts but
    also expiry warnings, with severity classification. Use Low Stock
    Alerts when you are actively restocking; use Notifications for your
    morning review.
