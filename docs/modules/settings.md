---
title: Settings
description: Manage your account, change your password, switch language, view terms, and manage your subscription.
---

# Settings

The **Settings** page is your personal configuration hub. From here you can
edit your profile, reset your password, switch the UI language, view legal
documents, and manage your subscription.

!!! info "How to get here"
    Click the **Settings** link at the bottom of the sidebar, or use the
    mobile bottom-sheet **Choose a setting** menu.

---

## Page anatomy

The Settings page uses a `TabController` with four tabs (three visible):

1. **Account**
2. **Language**
3. **Terms & Conditions**
4. *(hidden)* **Current Plan** — gated behind `if (false)` in the current
   release.

---

## Account tab

| Field | Description |
|---|---|
| **Display Name** | Your full name, shown in the top-nav avatar and on records you create. |
| **Email Address** | Your sign-in email. Read-only — to change it, contact Duniya support. |
| **Phone Number** | Used for delivery notifications and 2FA recovery. |

### Actions

- **Reset Password** — opens the Reset Password page, which sends a
  password-reset link to your email.
- **Delete Account** (red) — permanently deletes your account. Requires
  confirmation.

!!! danger "Account deletion is permanent"
    Deleting your account removes your User record and signs you out. Your
    historical sales, movements, and stock records remain (attributed to
    your now-deleted user) for audit purposes. This action cannot be
    undone.

### Mobile-specific

On mobile, the Account tab shows an **Edit** button that opens a
bottom-sheet form for editing your profile fields.

---

## Language tab

Duniya supports 10 UI locales. Pick one to instantly switch the entire
interface:

| Language | Locale code |
|---|---|
| English | `en` |
| Afrikaans | `af` |
| Hindi | `hi` |
| Spanish | `es` |
| Italian | `it` |
| Swahili | `sw` |
| French | `fr` |
| Nyanja | `nd` |
| Arabic | `ar` |
| Portuguese | `pt` |

The language switch is immediate — no reload required. Your choice is
persisted to your user profile.

!!! info "Currency is not affected"
    Switching language does not change the currency. All monetary values
    remain in ZMK.

---

## Terms & Conditions tab

Three documents are linked from this tab:

| Document | Description |
|---|---|
| **End-User License Agreement (EULA)** | The legal agreement between you and Duniya. |
| **Refund Policy** | Duniya's refund policy for subscriptions. |
| **Service Level Agreement** | Uptime guarantees and support response times. |

Click any link to read the full document.

---

## Subscriptions

!!! info "Currently hidden"
    The Current Plan section is hidden behind `if (false)` in the current
    release. It will be re-enabled when the subscription management UI is
    finalised. Until then, manage your subscription from the
    [Subscription](#subscription-page) page directly.

### Subscription page

The Subscription page (reachable from the sidebar for Owners) shows three
plans:

| Plan | Duration | Features |
|---|---|---|
| **Free Trial** | 2 weeks | Inventory Management, Analytics and reporting, User authentication. |
| **Monthly** | per month | Everything in Free, plus premium support. |
| **Yearly** | per year | Everything in Free, plus premium support. **Save 20%**. |

Click **Activate** on any plan to launch the payment URL. Payments are
processed via:

- **DPO** (Direct Pay Online) — for Zambian customers. Supports mobile
  money, bank transfers, and cards.
- **Stripe** — for international customers. Card-only.

After payment, you will be redirected to:

- **Subscription Success** — if the payment completed.
- **Subscription Failed** — if the payment failed.
- **Awaiting Payment** — if the payment is pending (e.g. mobile money
  confirmation).

### Update subscription

The Update Subscription page handles upgrades and downgrades:

- **Upgrade** — prorated charge for the remainder of the billing period.
- **Downgrade** — takes effect at the end of the current billing period.

Both require a confirmation dialog before applying.

---

## Mobile bottom-sheet

On mobile, tapping the Settings link opens a bottom-sheet with four
options:

| Option | Destination |
|---|---|
| **Profile** | Profile page (edit display name, email, phone). |
| **Terms and Conditions** | Mobile-friendly T&Cs view. |
| **Languages** | Language picker. |
| **Logout** | Signs you out and returns to the login page. |

---

## Profile page

The Profile page (separate from Settings → Account on mobile) lets you
edit:

- **Name**
- **Email Address**
- **Phone Number**

It also includes the **Logout** button and an avatar upload widget.

---

## Frequently asked questions

??? question "How do I change my password?"
    Go to **Settings → Account → Reset Password**. A reset link will be
    emailed to you. Click it to set a new password.

??? question "How do I change my email?"
    Email changes require Duniya support — the email is your sign-in
    identifier and cannot be self-served. Contact support with proof of
    identity.

??? question "How do I cancel my subscription?"
    The Cancel button (when visible) takes you to the Update Subscription
    page. Confirm the cancellation — your subscription remains active until
    the end of the current billing period, then downgrades to Free.

??? question "How do I switch back to English after picking another language?"
    Go to **Settings → Language → English**. The switch is immediate.

??? question "Where is dark mode?"
    Dark mode is a sidebar toggle, not a Settings item. The switch is at
    the bottom of the sidebar, above Logout.
