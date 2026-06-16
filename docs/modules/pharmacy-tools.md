---
title: Pharmacy Tools
description: Specialty tools — AI Assistant, BMI Calculator, Teledoctor, Point of Sale, and the Supply Chain marketplace.
---

# Pharmacy Tools

The **Pharmacy Tools** page is a hub for specialty tools that sit alongside
the core inventory and sales modules. Each tool is a self-contained feature
designed for a specific clinical or operational task.

---

## The tools hub

| Tool | Icon | Status | Description |
|---|---|---|---|
| **AI Assistant** | robot | Coming soon | Get helpful information from our AI. |
| **BMI Calculator** | calculator | Available | Calculate Body Mass Index from height and weight. |
| **Teledoctor** | video_call | Coming soon | Get in touch with your patients remotely. |
| **Point of Sale** | point_of_sale | Available | Quickly perform sales right in the app. |

---

## AI Assistant

!!! warning "Coming soon"
    The AI Assistant is currently in development. Clicking it shows an
    *"Coming soon"* dialog and returns you to the Pharmacy Tools page.

When released, the AI Assistant will provide:

- Natural-language queries about your inventory ("How much paracetamol do
  I have across all outlets?").
- Clinical decision support (drug interactions, dosage calculations).
- Operational insights ("Which products had the highest sales growth this
  month?").

The backend integration (OpenAI ChatGPT) is already wired in
`api_calls.dart`. The UI is the remaining work.

---

## BMI Calculator

The BMI Calculator is an in-house clinical tool for computing Body Mass
Index from height and weight.

### Using the calculator

1. Open **Pharmacy Tools → BMI Calculator**.
2. Toggle the **Gender** — Male or Female.
3. Enter **Height** in metres (e.g. *1.75*).
4. Enter **Weight** in kilograms (e.g. *70*).
5. Click **Calculate**.
6. The **BMI Result** page appears, showing:
    - Your BMI value (e.g. *22.9*).
    - A classification: Underweight / Normal / Overweight / Obese.
7. Click **Retry** to calculate another.

### BMI classification (WHO)

| BMI range | Classification |
|---|---|
| < 18.5 | Underweight |
| 18.5 – 24.9 | Normal weight |
| 25.0 – 29.9 | Overweight |
| ≥ 30.0 | Obese |

!!! info "Why include a BMI calculator?"
    Pharmacists routinely counsel patients on weight management —
    particularly for chronic disease management (diabetes, hypertension).
    Having the calculator in-app saves reaching for a separate tool.

---

## Teledoctor

!!! warning "Coming soon"
    Teledoctor is currently in development. It will enable remote
    consultations between pharmacists and patients, with integrated
    prescription dispensing through the Duniya sales flow.

---

## Point of Sale

The Point of Sale (POS) is the legacy sales interface — a cart-based flow
for quick over-the-counter sales. It uses `FFAppState().Cart` to manage
the cart state.

### Using POS

1. Open **Pharmacy Tools → Point of Sale**.
2. Browse or search for products.
3. Click **Buy** on a product to add it to the cart.
4. Click **Cart items** to view the cart.
5. Adjust quantities if needed.
6. Click **Pay** to checkout.
7. Duniya:
    - Creates a `SalesRecord` with the total.
    - Creates a `SaleitemRecord` for each line item.
    - Logs a `SOLD` Stock Movement for each product.
    - Decrements the outlet's Stock record.
    - Returns you to the Home page.

!!! info "POS vs. Sales / Dispensing"
    Use POS for walk-in retail sales with no patient reference. Use
    [Sales / Dispensing](sales.md) for prescription dispensing where a
    patient reference matters.

---

## Supply Chain marketplace

Beyond the four tool cards, Duniya includes a Supply Chain marketplace
flow:

```
Stores listing ──► Drug Details ──► Cart ──► Maps delivery ──► Confirm Delivery
```

| Step | Page | Description |
|---|---|---|
| 1 | **Stores** | Browse pharmacies (e.g. *Health Pharmacy*). Click **Order Drugs**. |
| 2 | **Drug Details** | Browse products at the selected store. Click **Buy** to add to cart. |
| 3 | **Cart** | Review items and total. Click **Pay**. |
| 4 | **Maps** | Google Maps integration showing delivery route from store to destination. Shows **Delivery Price**. |
| 5 | **Request** | Order summary with **Total Amount** (e.g. *k500.20*). Click **Confirm Delivery**. |

!!! info "Supply Chain is in beta"
    The Supply Chain marketplace is functional but not yet integrated with
    the core VMI flow. Treat it as a preview of forthcoming features.

---

## Frequently asked questions

??? question "When will the AI Assistant launch?"
    No firm date yet. The backend integration is complete; the UI is the
    remaining work. Watch the release notes.

??? question "Can I add my own tools to the Pharmacy Tools hub?"
    Not currently. The hub is a fixed set of tools curated by Duniya. If
    you have a tool you would like to see added, contact support.

??? question "Does the BMI Calculator save results?"
    No. The calculator stores the inputs in `FFAppState()` for the duration
    of the session (so you can retry without re-entering), but the results
    are not persisted to Firestore. Take a screenshot if you need a record.

??? question "Can I use POS without an outlet configured?"
    No. POS, like Sales / Dispensing, requires at least one outlet. Configure
    one from **My Pharmacies → Manage → Outlets**.
