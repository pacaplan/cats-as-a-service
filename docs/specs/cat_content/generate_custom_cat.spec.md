# GenerateCustomCat — Capability Spec

**Bounded Context:** Cat & Content
**Generated:** 2025-12-19T19:43:53.696Z
**Source:** `/Users/pcaplan/paul/cats-as-a-service/architecture/cat_content.json`

---

## Overview

**Actors:** Shopper
**Entrypoints:** CustomCatsController#generate
**Outputs:** CustomCat

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

## Architecture

### Capability Flow Diagram

```mermaid
flowchart TB
    Shopper["Shopper"]
    Shopper -->|"/custom-cats"| Controller
    Controller["CustomCatsController#generate"]
    Controller -->|invokes| Service
    Service["CustomCatService"]
    Service -->|uses port| Port0["LanguageModelPort<br/>(port)"]
    Port0 -.->|impl| Adapter0["OpenAIApiLanguageModelAdapter"]
    Adapter0 --> LanguageModels["Language Models"]
    Service -->|uses port| Port1["CustomCatRepository<br/>(port)"]
    Port1 -.->|impl| Adapter1["SqlCustomCatRepository"]
    Adapter1 --> PostgreSQL[("PostgreSQL")]
    Service -->|orchestrates| Aggregate["CustomCat Aggregate<br/>─────<br/>Invariants:<br/>• must have creator_user_id<br/>• must have name"]
    Aggregate -->|emits| Event0["CustomCatCreated<br/>─────<br/>custom_cat_id<br/>creator_user_id<br/>name<br/>created_at"]
    Event0 --> EventBus[Event Bus]
```

### Application Layer

**Services:**
- CustomCatService

### Domain Layer

**Aggregate:** CustomCat

**Invariants:**
- must have creator_user_id
- must have name

**Lifecycle:** generating → active → archived

**Events Emitted:**
- CustomCatCreated

### Infrastructure Layer

**Ports Used:**
- LanguageModelPort
- CustomCatRepository

**Adapters:**
- OpenAIApiLanguageModelAdapter → LanguageModelPort
- SqlCustomCatRepository → CustomCatRepository

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
