---
title: Pending Approvals
description: The Duniya admin workflow for approving new pharmacies, staff, outlets, and subscription changes.
---

# Pending Approvals

The **Pending Approvals** page is where Duniya admins review and act on
access requests. Every new pharmacy, staff member, outlet, and subscription
change flows through here before the requester can use the platform.

!!! info "Who uses this page"
    Pending Approvals is primarily for **Duniya admins** — the people who
    run the Duniya platform itself, not individual pharmacy owners. A
    pharmacy owner sees their own pending staff in the
    [Finances → Pending Approvals](finances.md#pending-approvals-embedded)
    section.

---

## Approval categories

Duniya auto-detects four categories of pending request based on the user
record's fields:

| Category | Detection rule | Colour | Description |
|---|---|---|---|
| **Pharmacy Registration** | `accountType == 'pharmacy'` | purple | New pharmacies applying to join. |
| **Staff Approval** | `role == 'staff'` / `'Staff'` | blue | Staff awaiting access. |
| **Outlet Setup** | `role == 'outlet_manager'` / `'OutletManager'` | green | New store branches pending. |
| **Subscription** | `role == 'subscription'` or `accountType == 'subscription'` | amber | Plan changes to verify. |

---

## Page anatomy

1. **Header** with search and pill tabs.
2. **Summary cards** — one per category, with counts and subtitles.
3. **Search bar** — "Search by name, email, pharmacy, or role...".
4. **Pill tabs** — All / Pharmacy / Staff (and more).
5. **Sort** — newest / oldest / name.
6. **Request list** — cards, one per pending user.

---

## Summary cards

Each summary card carries:

- **Count** — how many requests are in this category.
- **Title** — the category name.
- **Subtitle** — a one-line explanation (e.g. *"New pharmacies applying to
  join"*).

Click a card to filter the list to that category.

---

## The approval workflow

The page surfaces a three-step guidance banner:

1. **Verify the pharmacy** — confirm the pharmacy's license and identity.
2. **Approve staff only after pharmacy is verified** — staff cannot
   function without a verified parent pharmacy.
3. **Verify outlet setup** — confirm the outlet's physical address and
   operating hours.

This sequencing prevents partial approvals that would leave staff unable
to work.

---

## Acting on a request

Each request row offers two actions:

### Approve

1. Click **Approve**.
2. A confirmation dialog appears: *"Approve <name>?"*
3. Confirm. Duniya sets `approved_by_duniya = true` on the user record.
4. The user can now sign in and access the platform.
5. The request disappears from the pending list.

### Reject

1. Click **Reject**.
2. A confirmation dialog appears: *"Reject <name>? This will permanently
   delete the user."*
3. Confirm. Duniya deletes the `UserRecord`.
4. The request disappears from the pending list.

!!! danger "Rejection is permanent"
    Rejecting deletes the user record. The requester will need to start
    the registration process again. Use Reject only for clear cases of
    fraud, duplicate accounts, or ineligible applicants.

---

## Search and filter

| Control | Purpose |
|---|---|
| **Search** | Free-text search across name, email, pharmacy, and role. |
| **Pill tabs** | Quick filter by category. |
| **Sort** | Newest first (default), oldest first, or alphabetical by name. |

---

## Best practices

!!! tip "Approve promptly"
    Every pending request is a customer waiting. Aim to approve or reject
    within one business day. Delays harm Duniya's reputation.

!!! tip "Verify before approving"
    For pharmacy registrations, check the pharmacy's operating license
    number against your local pharmacy council's registry before
    approving. For staff, confirm with the parent pharmacy's Owner that
    the staff member is legitimate.

!!! tip "Use Reject sparingly"
    Most requests are legitimate. If something looks off (duplicate email,
    suspicious pharmacy name), contact the requester for clarification
    before rejecting. A rejected customer is hard to win back.

---

## Frequently asked questions

??? question "Why is a request stuck in pending?"
    Either no admin has acted on it yet, or it is waiting for the parent
    pharmacy to be approved first (per the three-step workflow). Check the
    Pharmacy Registration tab — if the parent pharmacy is still pending,
    approve that first.

??? question "Can I undo an approval?"
    No. Once approved, the user can sign in. To revoke access, delete
    their account from the Human Resource page or contact Duniya support
    to disable the underlying Firebase Auth user.

??? question "Can I undo a rejection?"
    No. Rejection deletes the user record. The requester must register
    again.

??? question "How are subscription changes detected?"
    When a user upgrades, downgrades, or cancels their subscription, the
    RevenueCat webhook updates the user's `accountType` to
    `'subscription'`. The change appears in the Subscription tab until an
    admin verifies it.
