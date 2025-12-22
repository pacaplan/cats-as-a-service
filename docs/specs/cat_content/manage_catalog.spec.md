# ManageCatalog — Capability Spec

**Bounded Context:** Cat & Content
**Generated:** 2025-12-19T21:53:31.838Z
**Source:** `/Users/pcaplan/paul/cats-as-a-service/architecture/cat_content.json`

---

## Overview

**Actors:** Admin
**Entrypoints:** CatListingsController#create, CatListingsController#update, CatListingsController#publish, CatListingsController#archive
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


### Domain Events Emitted

#### CatListingPublished
> Emitted when a premade cat becomes publicly visible

**Payload Intent:**
- `listing_id`
- `name`
- `base_price`
- `published_at`

#### CatListingArchived
> Emitted when a premade cat is removed from public view

**Payload Intent:**
- `listing_id`
- `archived_at`


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
    Admin["Admin"]
    Admin -->|"/catalog"| Controller
    Controller["CatListingsController#create"]
    Controller -->|invokes| Service
    Service["CatListingService"]
    Service -->|uses port| Port0["CatListingRepository<br/>(port)"]
    Port0 -.->|impl| Adapter0["SqlCatListingRepository"]
    Adapter0 --> PostgreSQL[("PostgreSQL")]
    Service -->|orchestrates| Aggregate["CatListing Aggregate<br/>─────<br/>Invariants:<br/>• must have name<br/>• must have description<br/>• base_price must be positive"]
    Aggregate -->|emits| Event0["CatListingPublished<br/>─────<br/>listing_id<br/>name<br/>base_price<br/>published_at"]
    Event0 --> EventBus[Event Bus]
    Aggregate -->|emits| Event1["CatListingArchived<br/>─────<br/>listing_id<br/>archived_at"]
    Event1 --> EventBus[Event Bus]
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

**Events Emitted:**
- CatListingPublished
- CatListingArchived

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
