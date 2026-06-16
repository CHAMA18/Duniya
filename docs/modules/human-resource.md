---
title: Human Resource
description: Manage your team — invite staff, assign roles, view staff details, and revoke access.
---

# Human Resource

The **Human Resource** page is where Owners manage their team. From here
you can invite staff, assign roles, view individual staff details, and
revoke access when someone leaves.

!!! info "Owner-only"
    The Human Resource page is visible only to users with the **Owner**
    role.

---

## Page anatomy

1. **Header** with **Add New Staff** button.
2. **Metric cards** — Active Staff, Linked Staff, Pharmacies, Outlets.
3. **Search bar** — "Search staff by name, role, phone, or email...".
4. **Staff table** — embedded `HrTableWidget` component.

---

## Metric cards

| Card | What it shows |
|---|---|
| **Active Staff** | Count of staff records not marked as deleted. |
| **Linked Staff** | Count of staff assigned to a specific pharmacy (`PharmId` is set). |
| **Pharmacies** | Count of pharmacies you own. |
| **Outlets** | Count of outlets across all your pharmacies. |

---

## Adding a staff member

1. Click **Add New Staff**.
2. The Add Staff Member form appears with two sections:

### Role & Pharmacy

- **Role picker** — choose from Cashier, Pharmacist, Manager, Technician,
  or Owner. Each role has a description and recommended use case.
- **Pharmacy assignment** — which pharmacy this staff member belongs to.

### Security

- **Name** *(required)*
- **Email** *(required)* — used for sign-in.
- **Phone**
- **Password** — a temporary password the staff member will change on
  first login.
- **Confirm Password**

3. Click **Save**. Duniya:
    - Creates a `StaffRecord` with the selected role.
    - Sets `OwnerRef` to the current user.
    - Navigates back to the Human Resource page.
    - Shows a success toast: *"Staff member added"*.

!!! tip "Role descriptions"
    See [Roles & Permissions → Role Reference](../roles/reference.md) for
    a detailed breakdown of what each role can do.

---

## The staff table

| Column | Description |
|---|---|
| **Name** | Staff member's full name. |
| **Role** | Badge with the role and its colour. |
| **Email** | Used for sign-in. |
| **Phone** | Contact number. |
| **Pharmacy** | The pharmacy they are assigned to. |
| **Actions** | View, Edit, Delete. |

Click any row to open the [Staff Details](#staff-details) page.

---

## Staff details

The Staff Details page shows a single staff member in full:

- Personal information: name, email, phone.
- Role and pharmacy assignment.
- Activity summary: sales recorded, goods received, stock counts.
- **Edit** button — opens the edit form. Save shows *"User information
  updated"*.
- **Delete** button — confirms with a dialog, then deletes. Shows *"Staff
  successfully deleted"*.

!!! warning "Deleting a staff member"
    Deletion marks the `StaffRecord` as `deleted = true` but does not
    remove the record. Historical data (sales, movements) remains
    attributed to the deleted user for audit purposes. The user can no
    longer sign in.

---

## Best practices

!!! tip "Use the principle of least privilege"
    Give each staff member the most restrictive role that lets them do
    their job. A cashier does not need Owner access. A pharmacy technician
    does not need to see financial data.

!!! tip "Rotate passwords"
    Have staff change their passwords quarterly. Duniya does not enforce
    password rotation yet — it is your responsibility.

!!! tip "Remove access promptly"
    When a staff member leaves, delete their account the same day. Every
    active account is a potential attack surface.

---

## Frequently asked questions

??? question "Can a staff member belong to multiple pharmacies?"
    Not currently. Each Staff record has a single `PharmId`. To give
    someone access to multiple pharmacies, create a separate Staff record
    per pharmacy (with a different email) — or upgrade them to an Owner
    role on your account.

??? question "What happens if I make a staff member an Owner?"
    They get full Owner access — they can create pharmacies, invite staff,
    see financial data, and manage billing. Be careful.

??? question "Can staff sign in on mobile?"
    Yes. The Duniya web app is responsive and works on mobile browsers.
    There is no native mobile app — staff use the same URL on every
    device.

??? question "How do I reset a staff member's password?"
    Owners cannot reset staff passwords directly. The staff member should
    use the **Forgot Password** link on the login page, which sends a
    reset email. If they have lost access to their email, contact Duniya
    support.
