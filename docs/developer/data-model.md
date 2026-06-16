---
title: Data Model
description: Complete reference for every Firestore collection and subcollection in Duniya.
---

# Data Model

This page documents every Firestore collection and subcollection used by
Duniya, with field types, defaults, and relationships.

---

## Top-level collections

### `User`

The top-level user account. One document per signed-up user.

| Field | Type | Default | Description |
|---|---|---|---|
| `email` | string | — | Sign-in email. |
| `display_name` | string | — | Full name. |
| `photo_url` | string | — | Avatar URL. |
| `uid` | string | — | Firebase Auth UID. |
| `created_time` | timestamp | — | Account creation time. |
| `phone_number` | string | — | Contact phone. |
| `role` | string | — | One of: Owner, Pharmacist, Pharmacy Technician, Outlet Manager, Cashier, Staff. |
| `OwnerRef` | reference | — | For non-Owner users, points to their Owner's User document. |
| `StripeId` | string | — | Stripe customer ID. |
| `pharmacy_name` | string | — | Legacy field — the user's primary pharmacy name. |
| `account_type` | string | — | `'Pharmacy'` or `'Duniya'`. |
| `approved_by_duniya` | bool | false | Whether a Duniya admin has approved this account. |

---

### `ProductMaster`

The shared product catalogue.

| Field | Type | Default | Description |
|---|---|---|---|
| `Name` | string | — | Display name. |
| `GenericName` | string | — | INN / generic name. |
| `BrandName` | string | — | Manufacturer's brand. |
| `Strength` | string | — | e.g. *500mg*. |
| `DosageForm` | string | — | Tablet, Capsule, Syrup, etc. |
| `PackSize` | string | — | Units per pack. |
| `UnitOfMeasure` | string | — | Tablet, mL, vial, etc. |
| `SKU` | string | — | Stock-keeping unit (unique). |
| `Category` | string | — | One of the 7 categories. |
| `Supplier` | string | — | Supplier reference. |
| `CostPrice` | number | 0 | Cost per unit (ZMK). |
| `SellingPrice` | number | 0 | Selling price per unit (ZMK). |
| `MinimumStockLevel` | number | 0 | Hard floor. |
| `ReorderLevel` | number | 0 | Soft floor — alert fires below this. |
| `TargetStockLevel` | number | 0 | Optimal stock level. |
| `IsActive` | bool | true | If false, hidden from new sales. |
| `CreatedAt` | timestamp | — | Creation time. |
| `UpdatedAt` | timestamp | — | Last update time. |

---

### `Batch`

Batch records — one per batch received.

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `PharmacyId` | reference | → `User/{id}/Pharmacy/{id}`. |
| `BatchNumber` | string | Supplier's batch number. |
| `ExpiryDate` | timestamp | Printed expiry date. |
| `Quantity` | number | Units currently on hand from this batch. |
| `FacilityLocation` | string | Outlet or warehouse. |
| `CreatedAt` | timestamp | Creation time. |
| `UpdatedAt` | timestamp | Last update time. |

---

### `LowStockAlert`

Alert records — one per product+pharmacy combination when below reorder.

| Field | Type | Description |
|---|---|---|
| `PharmacyId` | reference | → `User/{id}/Pharmacy/{id}`. |
| `ProductId` | reference | → `ProductMaster`. |
| `CurrentStock` | number | Live on-hand quantity. |
| `ReorderLevel` | number | The threshold that triggered the alert. |
| `SuggestedQuantity` | number | Recommended order quantity. |
| `Status` | string | `ACTIVE`, `ACKNOWLEDGED`, or `ORDERED`. |
| `CreatedAt` | timestamp | When the alert fired. |
| `UpdatedAt` | timestamp | Last status change. |

---

### `Replenishment`

Replenishment recommendations.

| Field | Type | Description |
|---|---|---|
| `PharmacyId` | reference | → `User/{id}/Pharmacy/{id}`. |
| `ProductId` | reference | → `ProductMaster`. |
| `AverageWeeklySales` | number | Computed sales velocity. |
| `CurrentStock` | number | Live on-hand quantity. |
| `TargetStockLevel` | number | From Product Master. |
| `SuggestedOrderQty` | number | Recommended order size. |
| `Period` | string | Time window for the calculation. |
| `CreatedAt` | timestamp | Creation time. |
| `UpdatedAt` | timestamp | Last update time. |

---

### `Subscription`

The subscription plan catalogue.

| Field | Type | Description |
|---|---|---|
| `Name` | string | Plan name (Free Trial, Monthly, Yearly). |
| `Description` | string | Plan description. |
| `Price` | number | Price in ZMK. |
| `Duration` | string | Billing period. |
| `Features` | array<string> | Feature list. |
| `payment_url` | string | DPO / Stripe payment URL. |

---

### `Usersubscription`

A user's active subscription.

| Field | Type | Description |
|---|---|---|
| `StartDate` | timestamp | When the subscription started. |
| `EndDate` | timestamp | When the subscription ends. |
| `Status` | string | Active, Expired, Cancelled. |
| `Payment_method` | string | DPO, Stripe, etc. |
| `SubscriptionID` | string | Reference to `Subscription`. |
| `UserID` | reference | → `User`. |

---

### `Subscriptionpayment`

Individual payment records.

| Field | Type | Description |
|---|---|---|
| `Date` | timestamp | Payment date. |
| `Amount` | number | Payment amount (ZMK). |
| `Status` | string | Completed, Pending, Failed. |
| `SubcriptionID` | string | Reference to the subscription. |
| `UserId` | reference | → `User`. |

---

### `Staff`

Cross-user staff records.

| Field | Type | Description |
|---|---|---|
| `OwnerRef` | reference | → `User` (the Owner). |
| `Name` | string | Staff member's name. |
| `Role` | string | Their role. |
| `Email` | string | Sign-in email. |
| `Phone` | string | Contact phone. |
| `UserRef` | reference | → `User` (linked user account). |
| `PharmId` | reference | → `User/{id}/Pharmacy/{id}`. |
| `Password` | string | (Legacy — plaintext. To be deprecated.) |
| `deleted` | bool | Soft-delete flag. |

---

## Subcollections (under `User/{ownerId}/...`)

### `Pharmacy`

| Field | Type | Description |
|---|---|---|
| `Name` | string | Pharmacy name. |
| `Address` | string | Physical address. |
| `UserID` | reference | → `User` (the Owner). |
| `deleted` | bool | Soft-delete flag. |

---

### `Stock`

| Field | Type | Description |
|---|---|---|
| `Name` | string | Product name (snapshot from Product Master). |
| `Description` | string | Free-text description. |
| `Quantity` | number | Current on-hand units. |
| `ExpiryDate` | timestamp | Nearest expiry date across batches. |
| `Category` | string | One of the 7 categories. |
| `Manufacturer` | string | Manufacturer name. |
| `Price` | number | Selling price per unit (ZMK). |
| `CostOfGoods` | number | Cost per unit (ZMK). |
| `Pharmacy` | reference | → `Pharmacy`. |
| `UserId` | reference | → `User` (the Owner). |
| `BatchNumber` | string | Current batch number. |
| `DamagedGoods` | number | Count of damaged units. |
| `InitialQuantity` | number | Quantity when the stock record was created. |
| `LimitNotice` | number | Low-stock threshold. |

---

### `Sales`

| Field | Type | Description |
|---|---|---|
| `Date` | timestamp | Sale date. |
| `Total_amount` | number | Grand total (ZMK). |
| `NumberOfItems` | number | Line item count. |
| `UserID` | reference | → `User` (the Owner). |
| `PharmaID` | reference | → `Pharmacy`. |
| `OwnerRef` | reference | → `User` (the Owner). |

---

### `Saleitem`

| Field | Type | Description |
|---|---|---|
| `Quantity` | number | Units sold. |
| `Unit_price` | number | Price per unit (ZMK). |
| `Total_price` | number | Line total (ZMK). |
| `StockID` | reference | → `Stock`. |
| `SaleID` | reference | → `Sales`. |
| `Discount` | number | Discount applied (ZMK). |
| `Final_price` | number | Total after discount (ZMK). |

---

### `Finance`

| Field | Type | Description |
|---|---|---|
| `Revenue` | number | Total revenue (ZMK). |
| `GrossProfit` | number | Revenue − COGS (ZMK). |
| `NetProfit` | number | GrossProfit − Operating Expenses (ZMK). |
| `UserId` | reference | → `User`. |
| `CostOfGoods` | number | Total COGS (ZMK). |

---

### `DamagedStock`

| Field | Type | Description |
|---|---|---|
| `StockId` | reference | → `Stock`. |
| `Quantity` | number | Damaged units. |
| `Description` | string | What happened. |

---

### `PharmacyStaff`

Links staff to pharmacies.

| Field | Type | Description |
|---|---|---|
| `PharmacyId` | reference | → `Pharmacy`. |
| `StaffId` | reference | → `Staff`. |

---

### `Outlet`

| Field | Type | Description |
|---|---|---|
| `Name` | string | Outlet name. |
| `Code` | string | Outlet code (e.g. *MAIN-01*). |
| `Address` | string | Physical address. |
| `IsActive` | bool | Whether the outlet is active. |
| `CreatedAt` | timestamp | Creation time. |
| `UpdatedAt` | timestamp | Last update time. |

---

### `StockBalance`

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `OutletId` | reference | → `Outlet`. |
| `OpeningStock` | number | Units at the start of the period. |
| `StockReceived` | number | Units received during the period. |
| `StockDispensed` | number | Units sold during the period. |
| `StockTransferred` | number | Net units transferred. |
| `StockAdjusted` | number | Net units adjusted. |
| `ClosingStock` | number | Units at the end of the period. |
| `StockValue` | number | Closing × Cost of Goods (ZMK). |
| `DaysOfStockRemaining` | number | DOS at current sales velocity. |
| `Period` | string | Time window (e.g. *2024-09*). |
| `UpdatedAt` | timestamp | Last update time. |
| `CreatedAt` | timestamp | Creation time. |

---

### `StockMovement`

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `OutletId` | reference | → `Outlet`. |
| `Quantity` | number | Signed: positive for in, negative for out. |
| `MovementType` | string | `RECEIVED`, `SOLD`, `TRANSFERRED`, `ADJUSTMENT`. |
| `Reason` | string | Free-text reason. |
| `MovementReference` | string | Reference to source document (Sale ID, etc.). |
| `RecordedById` | reference | → `User` (who logged it). |
| `CreatedAt` | timestamp | When the movement was recorded. |

---

### `GoodsReceived`

| Field | Type | Description |
|---|---|---|
| `DeliveryNoteNumber` | string | Supplier's delivery note number. |
| `OutletId` | reference | → `Outlet`. |
| `ReceivedById` | reference | → `User`. |
| `DeliveryDate` | timestamp | When the shipment arrived. |
| `ReceivedDate` | timestamp | When the receipt was confirmed. |
| `Discrepancies` | string | Notes on any discrepancies. |
| `Status` | string | `PENDING`, `CONFIRMED`, `DISCREPANCY`. |
| `CreatedAt` | timestamp | Creation time. |
| `UpdatedAt` | timestamp | Last update time. |

---

### `GoodsReceivedItem`

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `QuantityDelivered` | number | What the delivery note says. |
| `QuantityReceived` | number | What was actually counted. |
| `BatchNumber` | string | Batch number. |
| `ExpiryDate` | timestamp | Expiry date. |
| `Discrepancy` | string | Discrepancy reason. |

---

### `SaleVMI`

| Field | Type | Description |
|---|---|---|
| `OutletId` | reference | → `Outlet`. |
| `SoldById` | reference | → `User`. |
| `SaleDate` | timestamp | Sale date. |
| `PatientRef` | reference | → patient record (optional). |
| `TotalAmount` | number | Grand total (ZMK). |
| `CreatedAt` | timestamp | Creation time. |

---

### `SaleItemVMI`

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `Quantity` | number | Units sold. |
| `SellingPrice` | number | Price per unit (ZMK). |
| `Total` | number | Line total (ZMK). |

---

### `StockCount`

| Field | Type | Description |
|---|---|---|
| `OutletId` | reference | → `Outlet`. |
| `CountedById` | reference | → `User`. |
| `CountDate` | timestamp | When the count was conducted. |
| `Status` | string | `DRAFT`, `APPROVED`, `REJECTED`. |
| `Notes` | string | Free-text notes. |
| `CreatedAt` | timestamp | Creation time. |
| `UpdatedAt` | timestamp | Last update time. |

---

### `StockCountItem`

| Field | Type | Description |
|---|---|---|
| `ProductId` | reference | → `ProductMaster`. |
| `SystemQuantity` | number | What Duniya thought you had. |
| `CountedQuantity` | number | What you physically counted. |
| `Variance` | number | `Counted − System`. |
| `Explanation` | string | Reason for the variance. |

---

### `PharmacyUser`

| Field | Type | Description |
|---|---|---|
| `UserId` | reference | → `User`. |
| `PharmacyId` | reference | → `Pharmacy`. |
| `OutletIds` | array<reference> | Outlets this user can access. |
| `Role` | string | Role within this pharmacy. |
| `CreatedAt` | timestamp | Creation time. |

---

## Structs

### `CartItemsStruct`

Used by `FFAppState().Cart` for the POS cart.

| Field | Type | Description |
|---|---|---|
| `Display_Name` | array<string> | Product names. |
| `Quantity` | array<number> | Quantities. |
| `PharmId` | string | Pharmacy ID. |
| `PharmName` | string | Pharmacy name. |
| `Price` | array<number> | Unit prices. |

### `GraphDataStruct`

Used by `FFAppState().GraphData` for the Finances chart.

| Field | Type | Description |
|---|---|---|
| `Months` | array<string> | X-axis labels. |
| `Totals` | array<number> | Y-axis values. |

---

## Relationships at a glance

```
User ────┬── Pharmacy ────┬── Outlet
         │                 ├── Stock
         │                 ├── Sales ──── Saleitem
         │                 ├── Finance
         │                 ├── DamagedStock
         │                 ├── PharmacyStaff ──── Staff
         │                 ├── StockBalance
         │                 ├── StockMovement
         │                 ├── GoodsReceived ──── GoodsReceivedItem
         │                 ├── SaleVMI ──── SaleItemVMI
         │                 ├── StockCount ──── StockCountItem
         │                 └── PharmacyUser
         │
         ├── ProductMaster (top-level, shared)
         ├── Batch (top-level)
         ├── LowStockAlert (top-level)
         └── Replenishment (top-level)
```

The `ProductMaster`, `Batch`, `LowStockAlert`, and `Replenishment`
collections are top-level so they can be shared across pharmacies. All
operational data (stock, sales, movements) lives under the Owner's
`User/{id}/...` subcollection tree.
