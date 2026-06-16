---
title: Architecture
description: The technical architecture behind Duniya — Flutter web, Firebase, Firestore, and the supporting services.
---

# Architecture

This page documents the technical architecture of Duniya for developers
contributing to the codebase or integrating with the platform.

---

## High-level stack

```
┌─────────────────────────────────────────────────────────────────┐
│                       Client (Flutter Web)                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │
│  │   Pages    │  │ Components │  │   Models   │  │ Actions  │  │
│  │ (go_router)│  │ (shared)   │  │ (FF model) │  │ (custom) │  │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └────┬─────┘  │
│        └────────────────┴───────────────┴─────────────┘        │
│                              │                                  │
│                         flutter_flow                            │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
        ┌──────────┐    ┌──────────┐    ┌──────────┐
        │ Firebase │    │ Algolia  │    │RevenueCat│
        │  Auth    │    │ (search) │    │ (subs)   │
        └────┬─────┘    └──────────┘    └──────────┘
             │
             ▼
        ┌──────────┐
        │Firestore │
        │(database)│
        └────┬─────┘
             │
       ┌─────┴──────┐
       ▼            ▼
  ┌─────────┐  ┌─────────┐
  │  DPO    │  │ Stripe  │
  │ (ZM pmt)│  │(intl pmt)│
  └─────────┘  └─────────┘
```

---

## Client tier — Flutter Web

Duniya is a **Flutter Web** application built with FlutterFlow's code
generation framework. The codebase lives in `/lib/`.

### Project layout

```
lib/
├── main.dart                          # App entry, theme, route table
├── app_state.dart                    # FFAppState (global state)
├── auth/                             # Firebase auth providers
│   ├── firebase_auth/
│   └── firebase_user_provider.dart
├── backend/                          # Backend integration layer
│   ├── api_requests/api_calls.dart   # External API calls (DPO, Stripe, OpenAI)
│   ├── schema/                       # Firestore record classes
│   └── backend.dart                  # Firestore stream/query helpers
├── custom_code/actions/              # Custom business logic
├── flutter_flow/                     # FlutterFlow framework (theme, util, widgets)
├── index.dart                        # Route name → widget exports
├── unification/                      # Main app pages + components
│   ├── navbar_pages/                 # Sidebar-linked pages
│   ├── components/                   # Shared components (side_nav, top_nav, etc.)
│   ├── store_inventory/              # Store Inventory page
│   ├── pharmacy_tools/               # AI Assistant, BMI, POS, Supply Chain
│   ├── settings_mobile_pages/        # Settings sub-pages
│   └── legal_uni/                    # Legal pages (SLA, Refund Policy)
├── vmi/                              # VMI module (batches, alerts, etc.)
├── inventory/                        # Inventory module (add product, details)
├── pharmacy/                         # Pharmacy management (addstores, editstores)
├── staff/                            # Staff management (add_user, view_user)
└── registration/                     # Registration flows
```

### Key dependencies (`pubspec.yaml`)

| Package | Version | Purpose |
|---|---|---|
| `flutter` | 3.35.5 SDK | UI framework |
| `go_router` | 12.1.3 | Declarative routing |
| `cloud_firestore` | — | Firestore client |
| `firebase_auth` | — | Authentication |
| `firebase_storage` | — | File storage |
| `algolia` | — | Search |
| `revenue_cat` | — | Subscriptions |
| `file_picker` | — | Spreadsheet import |
| `excel` | 2.1.0 | Excel read/write |
| `csv` | — | CSV parsing |
| `pdf` | — | PDF report generation |
| `google_maps_flutter` | — | Supply Chain maps |
| `flutter_animate` | — | Animations |
| `flutter_spinkit` | — | Loading spinners |
| `webviewx_plus` | — | Embedded webviews |

### Material 2

Duniya uses `useMaterial3: false` in `main.dart`. The custom theme is
hand-tuned around the **Duniya Purple** (`#9900FF`).

!!! warning "Critical build rule"
    The purple theme is the source of truth for the entire UI. Never
    rebuild the project with FlutterFlow's theme generator without
    verifying that `#9900FF` is preserved as the primary color. The
    README documents this rule explicitly.

---

## Theme tokens

Defined in `lib/flutter_flow/flutter_flow_theme.dart`:

| Token | Value | Usage |
|---|---|---|
| `primary` | `#9900FF` | Primary buttons, active states, highlights |
| `secondary` | `#7C3AED` | Secondary accents |
| `tertiary` | `#A855F7` | Tertiary accents |
| `alternate` | `#E2D7FB` | Soft lavender borders |
| `primaryText` | `#111827` | Body text |
| `secondaryText` | `#6B7280` | Captions, metadata |
| `primaryBackground` | `#F8F5FF` | Page background |
| `secondaryBackground` | `#FFFFFF` | Card / surface background |
| `accent1` | `#9900FF` @ 30% | Accent backgrounds |
| `lineColor` | `#E9DCF9` | Dividers |
| `success` | `#10B981` | Success states |
| `warning` | `#F59E0B` | Warning states |
| `error` | `#EF4444` | Error states |
| `info` | `#7C3AED` | Info states |

Several widgets use page-local color constants for fine-tuned palettes
(e.g. `Color(0xFFA100FF)` for a brighter purple on the Import button).
These are intentional and should be preserved.

---

## Routing

Duniya uses `go_router` for declarative routing. The full route table is
in `lib/index.dart`.

### Route patterns

- **Static routes** — e.g. `/home`, `/storeInventory`, `/finances`.
- **Query-param routes** — e.g.
  `/stockBalances?pharmacy=<reference>`,
  `/managePharmacy?pharmacyName=...&pharmacyAddress=...&pharmacyRef=...`.
- **Protected routes** — most routes require authentication. The
  `WelcomeWidget` acts as a dispatcher, routing unauthenticated users to
  `LoginUniWidget`.

### Adding a new page

1. Create the widget file in `lib/<module>/<page_name>/<page_name>_widget.dart`.
2. Create the model file in the same directory (`<page_name>_model.dart`).
3. Add a route entry in `lib/index.dart`:
   ```dart
   GoRoute(
     name: 'MyPage',
     path: '/myPage',
     builder: (context, state) => MyPageWidget(),
   ),
   ```
4. Add the route to the sidebar / mobile navbar if it should be navigable.

---

## State management

Duniya uses FlutterFlow's `FlutterFlowModel` pattern for stateful pages.

### Per-page state

Each page has a corresponding model class that:

- Holds `TextEditingController`s, `FocusNode`s, and form state.
- Holds component models for shared widgets (`SideNavModel`,
  `TopNavModel`, `MobileNavbarModel`).
- Implements `initState` and `dispose`.

The model is created in the widget's `initState` via
`createModel(context, () => MyModel())` and disposed in `dispose`.

### Global state (`FFAppState`)

`lib/app_state.dart` defines `FFAppState` — a global state object
accessible from anywhere via `FFAppState()`. It holds:

| Field | Type | Purpose |
|---|---|---|
| `SelectedPage` | String | Active sidebar link |
| `SidebarCollapsed` | bool | Sidebar collapsed state |
| `Cart` | CartItemsStruct | POS shopping cart |
| `GraphData` | GraphDataStruct | Finances chart data |
| `Pharm` | String? | Currently selected pharmacy ID |
| `SelectedPharmacy` | String? | Pharmacy name (for display) |
| `SelectedOutlet` | String? | Outlet ID |
| `SubscriptionName` | String? | Current plan name |
| `EndDate` | DateTime? | Subscription end date |
| `BMI`, `Weight`, `Height`, `Gender` | various | BMI calculator state |

---

## Backend tier — Firebase

### Authentication

Firebase Authentication is the sole auth provider. Supported methods:

- Email + password
- Google Sign-In
- (Available but not exposed: Apple, GitHub, anonymous, JWT)

The current user is exposed via `currentUser` (the Firebase user) and
`currentUserDocument` (the `UserRecord` from Firestore).

### Firestore

Firestore is the primary database. The schema is defined in
`lib/backend/schema/`.

#### Top-level collections

- `User` — top-level user accounts
- `ProductMaster` — shared product catalogue
- `Batch` — batch records
- `LowStockAlert` — alert records
- `Replenishment` — replenishment recommendations
- `Subscription`, `Usersubscription`, `Subscriptionpayment` — billing
- `Staff` — staff records (cross-user)

#### Subcollections (under `User/{ownerId}/...`)

- `Pharmacy` — pharmacies owned by the user
- `Stock` — stock records
- `Sales`, `Saleitem` — sales records
- `Finance` — finance records
- `Outlet` — outlets
- `StockBalance`, `StockMovement`, `StockCount`, `StockCountItem` — VMI
- `GoodsReceived`, `GoodsReceivedItem` — VMI
- `SaleVMI`, `SaleItemVMI` — VMI sales
- `DamagedStock`, `PharmacyStaff`, `PharmacyUser` — auxiliary

### Parent reference pattern

Most subcollections are scoped under the **Owner**'s user document:

```dart
parent: valueOrDefault(currentUserDocument?.role, '') == 'Owner'
    ? currentUserReference
    : currentUserDocument?.ownerRef,
```

This ensures:

- Owners see their own data.
- Staff see their Owner's data (via the `OwnerRef` field on their User
  record).

### Security rules

`firebase/firestore.rules` enforces:

- `User/{doc}` — create/read public, write/delete only by owner uid.
- All `User/{parent}/...` subcollections — create/read public,
  write/delete only by parent uid.
- `Subscription`, `Usersubscription`, `Subscriptionpayment`, `Staff` —
  create/read public, write/delete denied (server-managed only).

!!! warning "Rules are permissive on read"
    The current rules allow public reads on most collections. This is
    acceptable for a multi-tenant SaaS where the parent path provides
    isolation, but tightening to "authenticated reads only" is on the
    roadmap.

---

## External integrations

### DPO (Direct Pay Online)

Used for Zambian payment processing. Configured in
`lib/backend/api_requests/api_calls.dart`:

- Base URL: `https://secure.3gdirectpay.com/API/v6/`
- Company token: hardcoded (see security note below)
- Currency: `zmk`
- Country: `ZM`
- City: `Lusaka`

Supports mobile money, bank transfers, and card payments.

### Stripe

Used for international card payments:

- Stripe Buy URL: `https://buy.stripe.com/6oEcOwfEu1sG3ja7ss`
- APIs: `GetStripeUserCall`, `DeleteStripeUserCall`,
  `SubscriptionstatusCall`, `UpdatesubscriptionsCall`,
  `CustomerRetrivalCall`, `PackageNameCall`

### RevenueCat

Initialized in `main.dart` with:

- Apple key: `appl_DiZrRubhavetCoHsHXPmUTMAIlk`
- Google key: `goog_OmJOGuYAMEmwKIREpYjyJkXpKVP`

`revenue_cat.login(user?.uid)` is called on auth state changes.

### Algolia

Used for full-text search on the Product Catalogue. The Algolia index is
populated by a Firestore → Algolia sync function (Cloud Function, not in
this repo).

### OpenAI

`OpenAIChatGPTGroup` and `SendFullPromptCall` are wired in
`api_calls.dart` for the AI Assistant feature (currently in preview).

### Airtable

`AirTableFinanceRecordsGroup` integrates with Airtable for finance
record-keeping (income and expenses). This is a backend integration —
not visible in the UI.

---

## Security considerations

!!! danger "Hardcoded API keys"
    The DPO company token and Stripe Buy URL are hardcoded in
    `api_calls.dart`. This is a security risk — anyone with access to the
    compiled JavaScript can extract them. The roadmap includes moving
    these to Firebase Remote Config or a Cloud Function proxy.

!!! danger "Permissive Firestore rules"
    Public read access on most collections is acceptable for the current
    multi-tenant model but should be tightened to "authenticated reads
    only" before scaling.

!!! info "No PII encryption at rest"
    Firestore encrypts data at rest by default, but Duniya does not
    apply additional field-level encryption for PII (patient names,
    phone numbers). For HIPAA-regulated workloads, consider client-side
    encryption for sensitive fields.

---

## Deployment

### Build

```bash
cd /home/z/my-project/Duniya
export PATH="/home/z/flutter/bin:$PATH"
flutter build web --release
```

Output is written to `build/web/`.

### Serve (local development)

```bash
node /home/z/my-project/serve.js
```

Listens on port 3000. Caddy (port 81) reverse-proxies to it.

### Production deployment

The repo includes:

- `Dockerfile` — containerises the build.
- `nginx.conf` — serves the static files.
- `render.yaml` — Render.com deployment config.

The `serve_web.dart` file is a Dart-based static file server used as a
fallback.

---

## Frequently asked questions

??? question "How do I add a new Firestore collection?"
    1. Create a record class in `lib/backend/schema/<name>_record.dart`.
    2. Add it to `lib/backend/schema/index.dart`.
    3. Add query helpers in `lib/backend/backend.dart` if needed.
    4. Update `firebase/firestore.rules` with appropriate permissions.

??? question "How do I add a new sidebar link?"
    Edit `lib/unification/components/side_nav/side_nav_widget.dart`. Add
    a `SidebarLinkModel` and the corresponding `SidebarLinkWidget` in the
    appropriate section (MAIN, INVENTORY, OPERATIONS).

??? question "How do I change the primary color?"
    Edit `lib/flutter_flow/flutter_flow_theme.dart` — change the `primary`
    constant. Then rebuild. **Do not use FlutterFlow's theme generator** —
    it will overwrite hand-tuned values.

??? question "How do I debug Firestore queries?"
    Use the Firebase console's Firestore data viewer. For client-side
    debugging, add `print()` statements in the model's `initState` or
    use Flutter's DevTools.
