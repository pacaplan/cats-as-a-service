# Cat & Content Bounded Context – Rampart Component Map

## 0. Scope of this BC

**In scope**
- Premade cat catalog (Cat‑alog)
- View premade cats
- View user-specific custom cats
- Delete/archive custom cats
- AI-authored descriptions & prompt templates

**Out of scope** (other BCs)
- Orders, payments, carts, pricing
- Order update emails & unsubscribe flows
- Authentication & user accounts

---

## 1. Domain Layer (DDD Core)

### 1.1 Aggregates
- **CatListing** — Premade, curated, globally visible cat in the Cat‑alog; root for catalog browsing.
- **CustomCat** — User-specific, AI-generated cat record; root for user's created cats.

### 1.2 Entities
- **CatProfile** — Core cat attributes (age, traits, temperament) with identity within the aggregate.

### 1.3 Value Objects
- **CatId** — Unique identifier for a CatListing.
- **CustomCatId** — Unique identifier for a CustomCat.
- **CatName** — Validated cat name with length and character constraints.
- **Slug** — URL-friendly identifier derived from name.
- **TagList** — Immutable collection of category tags (e.g., "fluffy", "playful").
- **TraitSet** — Immutable set of personality traits for filtering.
- **Visibility** — Enum: public, private, or archived.
- **ContentBlock** — Structured text content (description paragraph).
- **CatMedia** — Photo/video reference with URL and alt text.
- **CatPrompt** — The user's original prompt text that created a CustomCat.
- **CatStory** — AI-generated long-form description text.

### 1.4 Domain Services
- **CatDescriptionPolicy** — Enforces rules for tone, length, and allowed content in descriptions.
- **CatCopyGenerationService** — Pure-domain orchestration for copy generation; delegates to LLM port.
- **CatSearchSpecificationFactory** — Builds filter/specification objects for catalog queries.
- **VisibilityPolicy** — Rules governing when cats can be published, hidden, or archived.

### 1.5 Domain Events
- `CatListingPublished` — Emitted when a premade cat becomes publicly visible.
- `CatListingArchived` — Emitted when a premade cat is removed from public view.
- `CustomCatCreated` — Emitted when a user's custom cat is successfully generated.
- `CustomCatArchived` — Emitted when a user archives their custom cat.
- `CatDescriptionRegenerated` — Emitted when AI regenerates a cat's description.

### 1.6 Secondary Ports (Outbound Interfaces)

Interfaces defining what the domain/application needs from external systems. Implementations live in Infrastructure.

**Repositories**
- `CatListingRepository` — Persistence interface for CatListing aggregates.
- `CustomCatRepository` — Persistence interface for CustomCat aggregates.
- `PromptTemplateRepository` — Persistence interface for reusable AI prompt templates.

**External Services**
- `LanguageModelPort` — Interface for LLM text generation.
- `SearchIndexPort` — Interface for full-text search indexing.
- `MediaStoragePort` — Interface for image/video storage.
- `SlugGeneratorPort` — Interface for URL slug generation.
- `ClockPort` — Interface for current time (testability).
- `IdGeneratorPort` — Interface for unique ID generation.
- `TransactionPort` — Interface for database transaction management.

---

## 2. Application Layer (Use Cases)

### 2.1 Application Services

**CatListingService** — Manages all premade cat catalog operations.
- `list(query)` — Browse/filter Cat‑alog. [Consumer]
- `get(id)` — Retrieve single cat details. [Consumer]
- `create(command)` — Create a new premade cat. [Admin]
- `update(command)` — Update premade cat attributes. [Admin]
- `publish(id)` — Make cat publicly visible. [Admin]
- `archive(id)` — Remove cat from public view. [Admin]

**CustomCatService** — Manages user-created custom cats.
- `list(userId)` — List user's custom cats. [Consumer]
- `get(id)` — Retrieve single custom cat details. [Consumer]
- `generate(command)` — Create new custom cat via LLM. [Consumer]
- `regenerateDescription(id)` — Regenerate AI description. [Consumer]
- `archive(id)` — Archive a custom cat. [Consumer]
- `listAll(query)` — List all custom cats for moderation. [Admin]

### 2.2 Commands / Queries
- `CreateCatListingCommand` — DTO for creating a premade cat with name, description, image, price.
- `UpdateCatListingCommand` — DTO for updating premade cat attributes.
- `GenerateCustomCatCommand` — DTO containing user prompt and optional quiz results.
- `ArchiveCustomCatCommand` — DTO identifying which custom cat to archive.
- `RegenerateCatDescriptionCommand` — DTO requesting new AI description for existing cat.
- `ListCatListingsQuery` — DTO with filter/sort/pagination params for catalog.
- `GetCatDetailsQuery` — DTO with cat identifier for detail retrieval.
- `ListCustomCatsQuery` — DTO with user ID and optional filters.

### 2.3 Primary Ports (Inbound Interfaces)
- `CatCatalogUseCasePort` — Inbound interface for catalog browsing and admin operations.
- `CustomCatUseCasePort` — Inbound interface for custom cat creation and management.

---

## 3. Infrastructure Layer (Adapters)

### 3.1 Secondary Adapters (Outbound Implementations)
- `SqlCatListingRepository` — PostgreSQL implementation of CatListingRepository.
- `SqlCustomCatRepository` — PostgreSQL implementation of CustomCatRepository.
- `DbPromptTemplateRepository` — Database implementation of PromptTemplateRepository.
- `OpenAIApiLanguageModelAdapter` — OpenAI API implementation of LanguageModelPort.
- `ClaudeApiLanguageModelAdapter` — Anthropic Claude implementation of LanguageModelPort.
- `SearchIndexAdapter` — Algolia/OpenSearch implementation of SearchIndexPort.
- `S3MediaStorageAdapter` — AWS S3 implementation of MediaStoragePort.
- `SlugifyAdapter` — Slugify library implementation of SlugGeneratorPort.
- `SystemClockAdapter` — System clock implementation of ClockPort.
- `UuidIdGeneratorAdapter` — UUID library implementation of IdGeneratorPort.
- `DatabaseTransactionAdapter` — ActiveRecord/Sequel implementation of TransactionPort.

### 3.2 Primary Adapters (Inbound)
- **REST Controllers** — HTTP endpoints for `/catalog` and `/custom-cats`; see [REST API docs](./cat_content_api.md).
- **GraphQL Resolvers** — GraphQL query/mutation handlers (if GraphQL is used).
- **Background Job Handlers** — Async processors for LLM generation and indexing tasks.

---

## 4. Summary Structure

### Domain
- Aggregates: `CatListing`, `CustomCat`, `ContentPage`
- Entities: `CatProfile`, `CatMedia`, `CustomCatPrompt`, `CustomCatStory`
- Value Objects: `CatId`, `CustomCatId`, `Slug`, `TagList`, `TraitSet`, `SeoMetadata`, etc.
- Domain Services: Copy generation policies, description rules, search specs.
- Events: publish/archive/create/regenerate events.
- Repositories: interfaces only.

### Application
- Use cases for browsing, generating, archiving, and managing cats.
- DTO Commands/Queries.
- Primary Ports for inbound adapters.

### Infrastructure
- Secondary Ports & Adapters for DB, LLM, media, search, ID/clock.
- Primary Adapters: REST/GraphQL/UI integration.

---

This is the complete Rampart component map for the **Cat & Content bounded context only**, derived from the bounded context diagram, Rampart architecture, and functional spec.
