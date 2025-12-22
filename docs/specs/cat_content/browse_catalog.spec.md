# BrowseCatalog — Capability Spec

**Bounded Context:** Cat & Content
**Generated:** 2025-12-19T21:53:31.837Z
**Source:** `/Users/pcaplan/paul/cats-as-a-service/architecture/cat_content.json`

---

## Overview

**Actors:** Shopper, Guest
**Entrypoints:** CatListingsController#index, CatListingsController#show
**Outputs:** CatListing

---

## Acceptance Criteria

<!-- Use EARS notation for testable requirements -->
<!-- WHEN <trigger> THE SYSTEM SHALL <response> -->
<!-- WHILE <state> THE SYSTEM SHALL <response> -->
<!-- IF <condition> THEN THE SYSTEM SHALL <response> -->

- [ ] WHEN ... THE SYSTEM SHALL ...
- [ ] WHEN ... THE SYSTEM SHALL ...
- [ ] WHEN ... THE SYSTEM SHALL ...

---

## Error Handling

<!-- Define error scenarios using EARS IF/THEN notation -->

- [ ] IF ... THEN THE SYSTEM SHALL ...
- [ ] IF ... THEN THE SYSTEM SHALL ...

---

## Domain State & Data

### Aggregates involved

#### CatListing
> Premade, curated, globally visible cat in the Cat-alog; root for catalog browsing

**Key Attributes:**
- `id`
- `name`
- `description`
- `image_url`
- `base_price`

**Invariants:**
- must have name
- must have description
- base_price must be positive

**Lifecycle:** draft -> published -> archived


---

## Data Model

<!-- Map the Aggregate attributes above to a persistence schema -->
<!-- Note: Only model tables owned by this Bounded Context -->

| Table | Column | Type | Constraints |
|-------|--------|------|-------------|
| ...   | ...    | ...  | ...         |

---

## Request/Response Contracts

<!-- Define API payloads and Event DTOs -->
<!-- Tip: Use Task-Based naming (e.g. GenerateCustomCatRequest) -->

```json
// Request
{
  ...
}
```

---

## Architecture

### Capability Flow Diagram

```mermaid
flowchart TB
    Shopper["Shopper"]
    Guest["Guest"]
    Shopper -->|"/catalog"| Controller
    Controller["CatListingsController#index"]
    Controller -->|invokes| Service
    Service["CatListingService"]
    Service -->|uses port| Port0["CatListingRepository<br/>(port)"]
    Port0 -.->|impl| Adapter0["SqlCatListingRepository"]
    Adapter0 --> PostgreSQL[("PostgreSQL")]
    Service -->|orchestrates| Aggregate["CatListing Aggregate<br/>─────<br/>Invariants:<br/>• must have name<br/>• must have description<br/>• base_price must be positive"]
```

### Application Layer

**Services:**
- CatListingService

### Domain Layer

**Aggregate:** CatListing

**Invariants:**
- must have name
- must have description
- base_price must be positive

**Lifecycle:** draft → published → archived

### Infrastructure Layer

**Ports Used:**
- CatListingRepository

**Adapters:**
- SqlCatListingRepository → CatListingRepository

---

## Data Model

<!-- Fill in during planning -->

### Schema

### Relationships

### Indexes

---

## Request/Response Contracts

<!-- Fill in during planning -->

---

## Implementation Notes (Optional)

<!-- Add any implementation-specific notes, constraints, or considerations -->
