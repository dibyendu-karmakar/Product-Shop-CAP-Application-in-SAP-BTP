# SAP CAP Product Shop Service Application

This repository contains the data model, service definitions, custom business logic handlers, and SAP Fiori UI annotations for the **Product Shop** application, built using the SAP Cloud Application Programming Model (CAP).

## 📂 Project Structure

```text
├── db/
│   └── schema.cds          # Core data models, aspects, and relationships
├── srv/
│   ├── cat-service.cds     # OData Service layer exposing entities, actions, and functions
│   └── cat-service.js      # Custom business logic implementation (handlers)
└── app/
    └── labels.cds          # SAP Fiori UI Layout Annotations & Data Fields
```

---

## 🏗️ Data Model (`db/schema.cds`)

The database layer defines a `sap.cap.productshop` namespace with reuse aspects and two primary transactional entities.

### Reuse Components
* **`managed`**: Inherited from `@sap/cds/common` to track creation/modification timestamps and users.
* **`MaterialPrice` (Aspect)**: Adds reusable currency/pricing attributes (`Price`, `PriceUoM`).

### Entities
* **`Material`**: Represents shop inventory items. 
  * Features a strict, localized inventory layout via an inline **Composition** (`Location`) to track bin positions and stock levels.
  * Links to a vendor using a `to-one` Association.
* **`Vendor`**: Represents product suppliers.
  * Contains contact/address fields and a unique business `ID`.
  * Exposes a `to-many` Association back to all supplied materials.

---

## 🌐 Service Layer (`srv/cat-service.cds`)

The service layer exposes the `ProductShop` OData v4 service endpoint.

### Exposed Entities
* **`MaterialEntity`**: Direct projection of `Schema.Material`.
  * **Draft Mode Enabled**: Decorated with `@odata.draft.enabled` for transactional safety and UI-driven draft handling.
* **`VendorEntity`**: Projection of `Schema.Vendor`.
  * Explicitly marked with `@cds.redirection.target` to force target routing during Fiori navigation.

### ⚡ Bound Actions (Context-Aware)
These operations execute on a **specific selected instance** of `MaterialEntity`:
* `setPrice`: Updates the price of the current material.
* `changeDescription`: Changes the material's textual details.
* `addVendor`: Registers a new vendor and automatically assigns it to the current material. Uses `@Common.SideEffects` to instantly refresh the linked vendor data on the UI.
* `addExistingVendor`: Assigns a vendor by ID to the current material. Triggers side effects for structural data updates.

### ⚙️ Unbound Operations (Service-Root Level)
Global service actions that execute independently of any singular material record:
* `getProductDescByNumber` (Function): Queries and returns a description via an input material `Number`.
* `getPrice` (Action): Fetching the precise decimal pricing for an item based on its ID.

---

## 🧠 Business Logic (`srv/cat-service.js`)

The service implementation file uses CAP's event-driven architecture to execute validation, data enrichment, and custom processing.

### Custom Handlers & Hooks Breakdown

#### 🛠️ Functions and Actions (`.on` Handlers)
* **`getProductDescByNumber`**: Queries `MaterialEntity` using the fluent `SELECT.one` API to return only the text description. Throws a `404` error if not found.
* **`getPrice`**: Unbound action that retrieves the isolated `Price` column based on an input material `Number`.
* **`setPrice` & `changeDescription`**: Context-aware bound actions. They isolate instance parameters via `req.params`, perform safety/empty checks, and run targeted `UPDATE` operations.

#### 🛡️ Input Validation (`.before` Handlers)
* **`CREATE MaterialEntity`**: Sanitizes entry payloads prior to database commits. Ensures descriptions are present, prices are not negative, and ratings stay strictly within a `1-5` scale.

#### 🔀 Response Modification (`.after` Handlers)
* **`READ MaterialEntity`**: Loops through the payload arrays or objects to dynamically combine `Price` and `PriceUoM` into a single UI-friendly string format (e.g., `"45.99 USD"`), then strips away the raw `PriceUoM` field from the final JSON payload.

#### 💾 Database Lifecycle Operations (`.on` Handlers)
* **`READ MaterialEntity`**: Directly executes incoming queries using `db.run(req.query)` to maintain full support for standard OData behaviors like `$expand`, `$filter`, and paging.
* **`CREATE MaterialEntity`**: Automatically evaluates the input `Rating` value to programmatically assign UI `Criticality` codes (`1` for poor, `2` for average, `3` for good) and defaults `MaxRating` to `5` before triggering a contextual `INSERT`.

---

## 🎨 User Interface Layer (`app/labels.cds`)

The application layer contains vocabularies driving low-code layout rendering for standard SAP Fiori Elements templates (e.g., List Report / Object Page).

### Layout Configuration

* **`UI.SelectionFields`**: Defines filter bars for the List Report UI using `Description` and `Number`.
* **`UI.LineItem`**: Dictates the table columnar structure. It embeds actions directly inside the table grid, displaying an inline button for `setPrice`, a toolbar button for `changeDescription`, and a calculated visual **Progress Indicator** representation for the item's `Rating`.
* **`UI.Facets`**: Arranges the structural layout sections of the Fiori Object Page layout view:
  * **General Information**: Renders raw data text properties through `#GeneratedGroup`.
  * **Administration**: Group block `#Administration1` map displaying creation/modification fields natively inherited from the core `managed` aspect.
  * **Vendor Details**: Exposes fields representing the associated table schema vendor entries, rendering action buttons directly within the block form context layout.
  * **Bin Data**: Direct navigational redirection routing data out toward a custom nested local item breakdown (`Location`).
* **`UI.HeaderFacets`**: Renders glanceable header visual items at the top of the entity Object Page layout context. This draws dynamic **Rating Indicators** (Stars), Donut microcharts representing product evaluation weights, and data indicators evaluating material quantity storage distributions.
* **`UI.Identification`**: Maps complex multi-method command execution clusters inside the UI header buttons layout grouped directly under a single parent dropdown action element labelled `"More Methods"`.

---

## 🚀 Getting Started

### Prerequisites
* [Node.js](https://nodejs.org) (v18 or v20 recommended)
* SAP CAP CLI installed globally:
  ```bash
  npm i -g @sap/cds-dk
  ```

### Installation
Install project dependencies from the root directory:
```bash
npm install
```

### Running the App Local
Start the embedded mock-database runtime server:
```bash
cds watch
```
Open your browser and navigate to `http://localhost:4004` to view the OData metadata definitions, mock endpoints, and test operations.