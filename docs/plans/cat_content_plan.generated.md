# Implementation Plan: Cat & Content

Generated: 2025-01-27
Architecture: architecture/cat_content.json
Mode: Incremental

## Summary

### Already Implemented
- **CatListing Aggregate** (`app/domain/cat_content/aggregates/cat_listing.rb`) - Immutable aggregate inheriting `Rampart::Domain::AggregateRoot` with `create`, `publish`, `archive` methods; enforces invariants via domain exceptions
- **CatListingService** (`app/application/cat_content/services/cat_listing_service.rb`) - Consumer operations only (`list`, `get_by_slug`); inherits `Rampart::Application::Service`
- **CatListingRepository Port** (`app/domain/cat_content/ports/cat_listing_repository.rb`) - Abstract port inheriting `Rampart::Ports::SecondaryPort` with methods: `add`, `find`, `find_by_slug`, `list_public`, `update`, `remove`
- **SqlCatListingRepository** (`app/infrastructure/cat_content/persistence/repositories/sql_cat_listing_repository.rb`) - Implements port using ActiveRecord; maps domain objects
- **CatalogController** (`app/controllers/cat_content/catalog_controller.rb`) - Consumer endpoints: `GET /catalog`, `GET /catalog/:slug`; invokes CatListingService via Container
- **ListCatListingsQuery** (`app/application/cat_content/queries/list_cat_listings_query.rb`) - Query object inheriting `Rampart::Application::Query` with tags, page, per_page attributes
- **Value Objects**: All 11 value objects exist and inherit `Rampart::Domain::ValueObject` (CatId, CatName, Slug, Visibility, Money, ContentBlock, CatProfile, CatMedia, TagList, PaginatedResult, TraitSet)
- **CatListingMapper** (`app/infrastructure/cat_content/persistence/mappers/cat_listing_mapper.rb`) - Maps between domain aggregate and ActiveRecord record
- **CatListingSerializer** (`app/infrastructure/cat_content/http/serializers/cat_listing_serializer.rb`) - HTTP serialization with `as_json` and `as_json_full` methods
- **Container Wiring** (`app/infrastructure/cat_content/wiring/container.rb`) - Dry::Container setup with `cat_listing_repo` and `cat_listing_service` registrations
- **CatListingRecord** (`app/models/cat_listing_record.rb`) - ActiveRecord model inheriting `BaseRecord` for persistence
- **HealthController** (`app/controllers/cat_content/health_controller.rb`) - Health check endpoint (not in blueprint, follows engine convention)

### Drift / Unmodeled Code (Blueprint Missing These)
- **ListCatListingsQuery** - Exists in code but not explicitly mentioned in blueprint JSON (acceptable - follows CQRS pattern, should be added to blueprint)
- **HealthController** - Exists but not in blueprint (follows engine convention from AGENTS.md, not architectural drift)
- **CatProfile as ValueObject** - Blueprint lists CatProfile as "entity" under CatListing aggregate, but it's implemented as a value object. This is architecturally sound (profile is immutable data without independent identity), but the blueprint should be updated to reflect this design decision
- **CatListingService.get_by_slug** - Blueprint says "get" but implementation uses more specific `get_by_slug` method (acceptable - more explicit naming, blueprint could be updated for clarity)

### Files to Create
- 5 domain events (CatListingPublished, CatListingArchived, CustomCatCreated, CustomCatArchived, CatDescriptionRegenerated)
- CustomCat aggregate
- CustomCatRepository port
- 4 external ports (LanguageModelPort, ClockPort, IdGeneratorPort, TransactionPort)
- CustomCatService application service
- 4 admin commands for CatListing operations (CreateCatListingCommand, UpdateCatListingCommand, PublishCatListingCommand, ArchiveCatListingCommand)
- 2 CustomCat commands (GenerateCustomCatCommand, RegenerateDescriptionCommand)
- CustomCatsController
- SqlCustomCatRepository adapter
- 5 external adapters (OpenAIApiLanguageModelAdapter, ClaudeApiLanguageModelAdapter, SystemClockAdapter, UuidIdGeneratorAdapter, DatabaseTransactionAdapter)
- CustomCatRecord ActiveRecord model
- CustomCatMapper
- CustomCatSerializer
- Event bus port/adapter (if not provided by Rampart framework)

### Files to Modify
- **CatListingService** - Add admin operations (`create`, `update`, `publish`, `archive`) and event publishing dependencies (clock_port, id_generator_port, transaction_port, event_bus_port)
- **Container** - Register new services, repositories, adapters, and external ports
- **Routes** - Add custom-cats endpoints (`/custom-cats`) and admin catalog endpoints
- **CatalogController** - Add admin actions (`create`, `update`, `publish`, `archive`)

### Missing Implementations
- **CustomCat aggregate** - Not implemented
- **All domain events** - None exist yet (5 events needed: CatListingPublished, CatListingArchived, CustomCatCreated, CustomCatArchived, CatDescriptionRegenerated)
- **CustomCatRepository port** - Not implemented
- **External ports** - None implemented (LanguageModelPort, ClockPort, IdGeneratorPort, TransactionPort)
- **CustomCatService** - Not implemented
- **Admin operations in CatListingService** - Only consumer operations exist (`list`, `get_by_slug`); missing `create`, `update`, `publish`, `archive`
- **Event bus port** - Not implemented (needed for publishing events to other contexts, may be framework-provided)
- **All external adapters** - None implemented

### Open Questions
1. **Event Bus Port**: Is this provided by Rampart framework? If so, what's the interface? If not, should we implement `EventBusPort` extending `Rampart::Ports::SecondaryPort`?
2. **Event Payloads**: What attributes should each domain event carry?
   - `CatListingPublished`: cat_id, occurred_at, schema_version, slug?
   - `CatListingArchived`: cat_id, occurred_at, schema_version?
   - `CustomCatCreated`: custom_cat_id, user_id, occurred_at, schema_version, name?
   - `CustomCatArchived`: custom_cat_id, user_id, occurred_at, schema_version?
   - `CatDescriptionRegenerated`: cat_id (or custom_cat_id?), occurred_at, schema_version, description_text?
3. **CustomCat Attributes**: What are the exact attributes for CustomCat aggregate?
   - Required: id (CatId), user_id (String/Integer?), name (CatName), description (ContentBlock), visibility (Visibility)
   - Optional: prompt_text (String?), story_text (ContentBlock?), media (CatMedia?), tags (TagList?), created_at (Time via ClockPort?)
4. **LanguageModelPort Interface**: What methods should it expose?
   - `generate_description(prompt: String) -> String`?
   - `generate_story(prompt: String) -> String`?
   - `generate_text(prompt: String, context: Hash) -> String`?
5. **TransactionPort Interface**: Should it wrap ActiveRecord transactions?
   - `transaction { block } -> result`?
   - Or more generic interface?
6. **Admin Authentication**: How are admin operations authenticated? (Assumed handled by host app middleware, but should be documented)
7. **User Context**: How is user_id obtained for CustomCat operations? (From request context, JWT token, session?)
8. **CustomCat Generation Flow**: What's the exact flow for `generate` operation?
   - Does it call LanguageModelPort synchronously or asynchronously?
   - What happens if LLM call fails?
9. **CatListing Entity Reference**: Blueprint mentions "CatProfile" as entity under CatListing, but it's implemented as value object. Should blueprint be updated, or should CatProfile be refactored to entity?

---

## Phase 1: Domain Layer

### 1.1 Domain Events
**Files**: 
- `app/domain/cat_content/events/cat_listing_published.rb`
- `app/domain/cat_content/events/cat_listing_archived.rb`
- `app/domain/cat_content/events/custom_cat_created.rb`
- `app/domain/cat_content/events/custom_cat_archived.rb`
- `app/domain/cat_content/events/cat_description_regenerated.rb`

**Status**: Create

**Inherits**: `Rampart::Domain::DomainEvent`

**Responsibilities**:
- Represent domain facts that occurred (past tense)
- Include event_id, occurred_at, schema_version (Rampart conventions)
- Carry aggregate identifiers and relevant domain data
- Immutable value objects

**Key Methods**:
- Constructor with aggregate_id and domain-specific attributes
- Inherited: `event_id`, `occurred_at`, `schema_version` (from Rampart base)

**Attributes** (TBD - see Open Questions):
- `CatListingPublished`: cat_id (CatId), slug (String, optional)
- `CatListingArchived`: cat_id (CatId)
- `CustomCatCreated`: custom_cat_id (CatId), user_id (String/Integer), name (String)
- `CustomCatArchived`: custom_cat_id (CatId), user_id (String/Integer)
- `CatDescriptionRegenerated`: cat_id (CatId, or custom_cat_id?), description_text (String)

---

### 1.2 CustomCat Aggregate
**File**: `app/domain/cat_content/aggregates/custom_cat.rb`

**Status**: Create

**Inherits**: `Rampart::Domain::AggregateRoot`

**Responsibilities**:
- Root aggregate for user-specific, AI-generated cat records
- Enforces invariants (e.g., must have name, description)
- Immutable state transitions (returns new instances)

**Attributes** (TBD - see Open Questions):
- `id`: ValueObjects::CatId
- `user_id`: String or Integer (TBD)
- `name`: ValueObjects::CatName
- `description`: ValueObjects::ContentBlock
- `visibility`: ValueObjects::Visibility
- `prompt_text`: String (optional, TBD)
- `story_text`: ValueObjects::ContentBlock (optional, TBD)
- `media`: ValueObjects::CatMedia (optional)
- `tags`: ValueObjects::TagList (optional)
- `created_at`: Time (via ClockPort, TBD)

**Key Methods**:
- `self.create(id:, user_id:, name:, description:, visibility:, **opts)` -> CustomCat (factory method)
- `regenerate_description(new_description:)` -> CustomCat (returns new instance)
- `archive` -> CustomCat (returns new instance with archived visibility)
- `public?` -> Boolean (delegated to visibility)
- `private?` -> Boolean (delegated to visibility)
- `archived?` -> Boolean (delegated to visibility)

**Domain Exceptions**:
- `CustomCat::InvariantViolation < Rampart::Domain::DomainException`
- Specific violations as needed

---

### 1.3 CustomCatRepository Port
**File**: `app/domain/cat_content/ports/custom_cat_repository.rb`

**Status**: Create

**Inherits**: `Rampart::Ports::SecondaryPort`

**Responsibilities**:
- Define interface for CustomCat persistence
- Abstract methods for CRUD and query operations

**Key Methods** (abstract):
- `add(aggregate: CustomCat) -> CustomCat`
- `find(id: CatId) -> CustomCat | nil`
- `find_by_user_and_id(user_id:, id:) -> CustomCat | nil`
- `list_by_user(user_id:, page:, per_page:) -> PaginatedResult`
- `list_all(page:, per_page:) -> PaginatedResult` (admin operation)
- `update(aggregate: CustomCat) -> CustomCat`
- `remove(id: CatId) -> void`

---

### 1.4 External Ports
**Files**:
- `app/domain/cat_content/ports/language_model_port.rb`
- `app/domain/cat_content/ports/clock_port.rb`
- `app/domain/cat_content/ports/id_generator_port.rb`
- `app/domain/cat_content/ports/transaction_port.rb`

**Status**: Create

**Inherits**: `Rampart::Ports::SecondaryPort`

**Responsibilities**:
- Define interfaces for external dependencies (testability, dependency inversion)
- Abstract methods for LLM text generation, time, ID generation, transactions

**Key Methods** (abstract, TBD - see Open Questions):

**LanguageModelPort**:
- `generate_description(prompt: String) -> String` (or more generic interface)
- `generate_story(prompt: String) -> String` (or more generic interface)

**ClockPort**:
- `now -> Time` (current timestamp)

**IdGeneratorPort**:
- `generate -> String` (unique identifier, e.g., UUID)

**TransactionPort**:
- `transaction { block } -> result` (wrap block in transaction)

---

### 1.5 Event Bus Port (if needed)
**File**: `app/domain/cat_content/ports/event_bus_port.rb`

**Status**: Create (if not provided by Rampart)

**Inherits**: `Rampart::Ports::SecondaryPort` or `Rampart::Ports::EventBusPort` (if framework provides)

**Responsibilities**:
- Interface for publishing domain events to other bounded contexts
- Abstract publishing mechanism

**Key Methods** (abstract):
- `publish(event: DomainEvent) -> void`

**Note**: Check if Rampart framework provides this port before implementing.

---

## Phase 2: Application Layer

### 2.1 CatListingService - Admin Operations
**File**: `app/application/cat_content/services/cat_listing_service.rb`

**Status**: Modify

**Inherits**: `Rampart::Application::Service` (already inherits)

**Responsibilities**:
- Add admin operations: `create`, `update`, `publish`, `archive`
- Publish domain events after state transitions
- Coordinate with ports (repository, clock, id_generator, transaction, event_bus)

**Dependencies to Add**:
- `clock_port:` (for event timestamps)
- `id_generator_port:` (if needed for event IDs)
- `transaction_port:` (for transaction boundaries)
- `event_bus_port:` (for publishing events)

**Key Methods to Add**:
- `create(command: CreateCatListingCommand) -> CatListing` (publishes `CatListingPublished` if created as public)
- `update(id:, command: UpdateCatListingCommand) -> CatListing`
- `publish(id:) -> CatListing` (publishes `CatListingPublished` event)
- `archive(id:) -> CatListing` (publishes `CatListingArchived` event)

**Existing Methods** (keep):
- `list(query: ListCatListingsQuery) -> PaginatedResult`
- `get_by_slug(slug:) -> CatListing | nil`

---

### 2.2 CustomCatService
**File**: `app/application/cat_content/services/custom_cat_service.rb`

**Status**: Create

**Inherits**: `Rampart::Application::Service`

**Responsibilities**:
- Orchestrate CustomCat aggregate operations
- Coordinate with LanguageModelPort for AI generation
- Publish domain events after state transitions
- Handle transaction boundaries

**Dependencies**:
- `custom_cat_repo:` (CustomCatRepository)
- `language_model_port:` (LanguageModelPort)
- `clock_port:` (ClockPort)
- `id_generator_port:` (IdGeneratorPort)
- `transaction_port:` (TransactionPort)
- `event_bus_port:` (EventBusPort, optional)

**Key Methods**:
- `list(user_id:, page:, per_page:) -> PaginatedResult` (consumer)
- `get(user_id:, id:) -> CustomCat | nil` (consumer)
- `generate(user_id:, command: GenerateCustomCatCommand) -> CustomCat` (publishes `CustomCatCreated` event)
- `regenerate_description(user_id:, id:, command: RegenerateDescriptionCommand) -> CustomCat` (publishes `CatDescriptionRegenerated` event)
- `archive(user_id:, id:) -> CustomCat` (publishes `CustomCatArchived` event)
- `list_all(page:, per_page:) -> PaginatedResult` (admin)

---

### 2.3 Admin Commands for CatListing
**Files**:
- `app/application/cat_content/commands/create_cat_listing_command.rb`
- `app/application/cat_content/commands/update_cat_listing_command.rb`
- `app/application/cat_content/commands/publish_cat_listing_command.rb`
- `app/application/cat_content/commands/archive_cat_listing_command.rb`

**Status**: Create

**Inherits**: `Rampart::Application::Command`

**Responsibilities**:
- Encapsulate input data for admin operations
- Validate command attributes

**Key Attributes** (TBD):

**CreateCatListingCommand**:
- `name: String`
- `description: String`
- `price_cents: Integer`
- `currency: String` (default: "USD")
- `slug: String`
- `tags: Array[String]` (optional)
- `profile: Hash` (optional: age_months, traits, temperament)
- `media: Hash` (optional: url, alt_text)
- `publish: Boolean` (default: false)

**UpdateCatListingCommand**:
- `name: String` (optional)
- `description: String` (optional)
- `price_cents: Integer` (optional)
- `tags: Array[String]` (optional)
- `profile: Hash` (optional)
- `media: Hash` (optional)

**PublishCatListingCommand**:
- (no attributes, just id)

**ArchiveCatListingCommand**:
- (no attributes, just id)

---

### 2.4 CustomCat Commands
**Files**:
- `app/application/cat_content/commands/generate_custom_cat_command.rb`
- `app/application/cat_content/commands/regenerate_description_command.rb`

**Status**: Create

**Inherits**: `Rampart::Application::Command`

**Responsibilities**:
- Encapsulate input data for CustomCat operations

**Key Attributes** (TBD):

**GenerateCustomCatCommand**:
- `prompt: String` (user's prompt for AI generation)
- `name: String` (optional, may be generated)
- `tags: Array[String]` (optional)

**RegenerateDescriptionCommand**:
- `prompt: String` (optional, for context)
- (or no attributes, just regenerate with existing prompt)

---

## Phase 3: Infrastructure Layer

### 3.1 Repository Adapters

#### 3.1.1 SqlCustomCatRepository
**File**: `app/infrastructure/cat_content/persistence/repositories/sql_custom_cat_repository.rb`

**Status**: Create

**Implements**: `Ports::CustomCatRepository`

**Responsibilities**:
- Implement CustomCat persistence using ActiveRecord
- Map between domain objects and ActiveRecord records
- Handle pagination

**Dependencies**:
- `mapper:` (CustomCatMapper)

**Key Methods**:
- `add(aggregate) -> CustomCat` (save via mapper)
- `find(id) -> CustomCat | nil` (find by id, map to domain)
- `find_by_user_and_id(user_id:, id:) -> CustomCat | nil`
- `list_by_user(user_id:, page:, per_page:) -> PaginatedResult`
- `list_all(page:, per_page:) -> PaginatedResult`
- `update(aggregate) -> CustomCat` (upsert via mapper)
- `remove(id) -> void` (delete record)

---

### 3.2 External Service Adapters

#### 3.2.1 LanguageModelPort Adapters
**Files**:
- `app/infrastructure/cat_content/adapters/open_ai_api_language_model_adapter.rb`
- `app/infrastructure/cat_content/adapters/claude_api_language_model_adapter.rb` (optional)

**Status**: Create

**Implements**: `Ports::LanguageModelPort`

**Technology**: OpenAI GPT-4 API / Anthropic Claude API

**Responsibilities**:
- Call external LLM APIs for text generation
- Handle API errors and retries
- Map API responses to domain strings

**Dependencies**:
- API client (OpenAI gem / Anthropic gem)
- API keys (from environment/config)

**Key Methods**:
- `generate_description(prompt:) -> String`
- `generate_story(prompt:) -> String` (or generic `generate_text`)

---

#### 3.2.2 SystemClockAdapter
**File**: `app/infrastructure/cat_content/adapters/system_clock_adapter.rb`

**Status**: Create

**Implements**: `Ports::ClockPort`

**Responsibilities**:
- Provide current time (delegates to `Time.now`)

**Key Methods**:
- `now -> Time`

---

#### 3.2.3 UuidIdGeneratorAdapter
**File**: `app/infrastructure/cat_content/adapters/uuid_id_generator_adapter.rb`

**Status**: Create

**Implements**: `Ports::IdGeneratorPort`

**Responsibilities**:
- Generate unique identifiers (UUIDs)

**Key Methods**:
- `generate -> String` (UUID v4)

---

#### 3.2.4 DatabaseTransactionAdapter
**File**: `app/infrastructure/cat_content/adapters/database_transaction_adapter.rb`

**Status**: Create

**Implements**: `Ports::TransactionPort`

**Technology**: ActiveRecord

**Responsibilities**:
- Wrap blocks in database transactions

**Key Methods**:
- `transaction { block } -> result` (delegates to `ActiveRecord::Base.transaction`)

---

#### 3.2.5 EventBusAdapter (if needed)
**File**: `app/infrastructure/cat_content/adapters/event_bus_adapter.rb`

**Status**: Create (if EventBusPort is implemented)

**Implements**: `Ports::EventBusPort`

**Responsibilities**:
- Publish domain events to host app's event bus
- Handle publishing failures

**Key Methods**:
- `publish(event:) -> void`

**Note**: Implementation depends on host app's event bus mechanism (ActiveSupport::Notifications, Wisper, custom, etc.)

---

### 3.3 Persistence Mappers

#### 3.3.1 CustomCatMapper
**File**: `app/infrastructure/cat_content/persistence/mappers/custom_cat_mapper.rb`

**Status**: Create

**Responsibilities**:
- Map between CustomCat domain aggregate and CustomCatRecord ActiveRecord model
- Handle optional attributes

**Key Methods**:
- `to_domain(record: CustomCatRecord) -> CustomCat`
- `to_record(aggregate: CustomCat) -> CustomCatRecord` (find_or_initialize_by)

---

### 3.4 ActiveRecord Models

#### 3.4.1 CustomCatRecord
**File**: `app/models/custom_cat_record.rb`

**Status**: Create

**Inherits**: `BaseRecord`

**Responsibilities**:
- ActiveRecord model for CustomCat persistence
- Table: `cat_content.custom_cats`

**Attributes** (TBD - match domain aggregate):
- `id: String` (UUID, primary key)
- `user_id: String` (or Integer, TBD)
- `name: String`
- `description: String` (text)
- `visibility: String` (enum: public, private, archived)
- `prompt_text: String` (text, optional)
- `story_text: String` (text, optional)
- `image_url: String` (optional)
- `image_alt: String` (optional)
- `tags: Array[String]` (PostgreSQL array)
- `created_at: DateTime`
- `updated_at: DateTime`

**Validations**:
- `name` presence
- `user_id` presence
- `visibility` inclusion in %w[public private archived]

---

### 3.5 HTTP Controllers

#### 3.5.1 CustomCatsController
**File**: `app/controllers/cat_content/custom_cats_controller.rb`

**Status**: Create

**Inherits**: `ActionController::API`

**Responsibilities**:
- Handle HTTP requests for CustomCat operations
- Invoke CustomCatService (not repositories directly)
- Serialize responses

**Routes** (to add to routes.rb):
- `GET /custom-cats` -> `index` (list user's custom cats)
- `GET /custom-cats/:id` -> `show` (get single custom cat)
- `POST /custom-cats` -> `create` (generate new custom cat)
- `POST /custom-cats/:id/regenerate-description` -> `regenerate_description`
- `DELETE /custom-cats/:id` -> `destroy` (archive)

**Admin Routes** (if needed):
- `GET /admin/custom-cats` -> `index_all` (list all custom cats)

**Key Methods**:
- `index` -> JSON paginated list
- `show` -> JSON single custom cat
- `create` -> JSON created custom cat (or error)
- `regenerate_description` -> JSON updated custom cat
- `destroy` -> JSON archived custom cat (or 204 No Content)

**Dependencies**:
- `custom_cat_service:` (from Container)
- `serializer:` (CustomCatSerializer)

**User Context**: Extract `user_id` from request (JWT, session, etc. - TBD)

---

#### 3.5.2 CatalogController - Admin Actions
**File**: `app/controllers/cat_content/catalog_controller.rb`

**Status**: Modify

**Responsibilities**:
- Add admin actions: `create`, `update`, `publish`, `archive`

**Routes to Add**:
- `POST /catalog` -> `create`
- `PATCH /catalog/:id` -> `update`
- `POST /catalog/:id/publish` -> `publish`
- `POST /catalog/:id/archive` -> `archive`

**Key Methods to Add**:
- `create` -> JSON created cat listing
- `update` -> JSON updated cat listing
- `publish` -> JSON published cat listing
- `archive` -> JSON archived cat listing

---

### 3.6 HTTP Serializers

#### 3.6.1 CustomCatSerializer
**File**: `app/infrastructure/cat_content/http/serializers/custom_cat_serializer.rb`

**Status**: Create

**Responsibilities**:
- Serialize CustomCat aggregate to JSON
- Handle optional attributes

**Key Methods**:
- `as_json -> Hash` (summary view)
- `as_json_full -> Hash` (full details)

---

### 3.7 Dependency Injection Wiring

#### 3.7.1 Container Updates
**File**: `app/infrastructure/cat_content/wiring/container.rb`

**Status**: Modify

**Responsibilities**:
- Register all new services, repositories, and adapters
- Wire dependencies

**Registrations to Add**:
- `:custom_cat_repo` -> SqlCustomCatRepository
- `:custom_cat_service` -> CustomCatService (with dependencies)
- `:language_model_port` -> OpenAIApiLanguageModelAdapter (or configurable)
- `:clock_port` -> SystemClockAdapter
- `:id_generator_port` -> UuidIdGeneratorAdapter
- `:transaction_port` -> DatabaseTransactionAdapter
- `:event_bus_port` -> EventBusAdapter (if implemented)

**Registrations to Modify**:
- `:cat_listing_service` -> Add new dependencies (clock_port, id_generator_port, transaction_port, event_bus_port)

---

### 3.8 Routes

#### 3.8.1 Routes Updates
**File**: `config/routes.rb`

**Status**: Modify

**Responsibilities**:
- Add custom-cats routes
- Add admin catalog routes

**Routes to Add**:
```ruby
# Custom cats endpoints
get "custom-cats", to: "custom_cats#index"
get "custom-cats/:id", to: "custom_cats#show"
post "custom-cats", to: "custom_cats#create"
post "custom-cats/:id/regenerate-description", to: "custom_cats#regenerate_description"
delete "custom-cats/:id", to: "custom_cats#destroy"

# Admin catalog endpoints
post "catalog", to: "catalog#create"
patch "catalog/:id", to: "catalog#update"
post "catalog/:id/publish", to: "catalog#publish"
post "catalog/:id/archive", to: "catalog#archive"
```

---

## Implementation Order

1. **Domain Layer Foundation** (no dependencies)
   - Create 5 domain events
   - Create CustomCat aggregate
   - Create CustomCatRepository port
   - Create 4 external ports (LanguageModelPort, ClockPort, IdGeneratorPort, TransactionPort)
   - Create EventBusPort (if needed, check Rampart first)

2. **Application Layer** (depends on domain)
   - Create admin commands for CatListing
   - Create CustomCat commands
   - Modify CatListingService (add admin operations, event publishing)
   - Create CustomCatService

3. **Infrastructure - Persistence** (depends on domain + application)
   - Create CustomCatRecord ActiveRecord model
   - Create CustomCatMapper
   - Create SqlCustomCatRepository

4. **Infrastructure - External Adapters** (depends on ports)
   - Create SystemClockAdapter
   - Create UuidIdGeneratorAdapter
   - Create DatabaseTransactionAdapter
   - Create OpenAIApiLanguageModelAdapter
   - Create ClaudeApiLanguageModelAdapter (optional)
   - Create EventBusAdapter (if EventBusPort exists)

5. **Infrastructure - HTTP** (depends on application services)
   - Create CustomCatSerializer
   - Create CustomCatsController
   - Modify CatalogController (add admin actions)
   - Update routes.rb

6. **Wiring** (depends on all layers)
   - Update Container with all registrations

7. **Testing** (parallel to implementation)
   - Add/extend architecture fitness tests
   - Add unit tests for domain objects
   - Add integration tests for repositories
   - Add request specs for controllers

---

## TODO Checklist

### Domain Layer
- [ ] Create 5 domain events (CatListingPublished, CatListingArchived, CustomCatCreated, CustomCatArchived, CatDescriptionRegenerated)
- [ ] Create CustomCat aggregate
- [ ] Create CustomCatRepository port
- [ ] Create 4 external ports (LanguageModelPort, ClockPort, IdGeneratorPort, TransactionPort)
- [ ] Create EventBusPort (if not provided by Rampart)

### Application Layer
- [ ] Create 4 admin commands for CatListing (CreateCatListingCommand, UpdateCatListingCommand, PublishCatListingCommand, ArchiveCatListingCommand)
- [ ] Create 2 CustomCat commands (GenerateCustomCatCommand, RegenerateDescriptionCommand)
- [ ] Modify CatListingService (add admin operations, event publishing, new dependencies)
- [ ] Create CustomCatService

### Infrastructure Layer
- [ ] Create CustomCatRecord ActiveRecord model
- [ ] Create CustomCatMapper
- [ ] Create SqlCustomCatRepository
- [ ] Create 5 external adapters (LanguageModelPort x2, ClockPort, IdGeneratorPort, TransactionPort)
- [ ] Create EventBusAdapter (if EventBusPort exists)
- [ ] Create CustomCatSerializer
- [ ] Create CustomCatsController
- [ ] Modify CatalogController (add admin actions)
- [ ] Update routes.rb
- [ ] Update Container wiring (register all new components)

### Testing
- [ ] Add/extend architecture fitness tests (inheritance, immutability, layer boundaries)
- [ ] Add unit tests for CustomCat aggregate
- [ ] Add unit tests for domain events
- [ ] Add integration tests for SqlCustomCatRepository
- [ ] Add request specs for CustomCatsController
- [ ] Add request specs for CatalogController admin actions

### Documentation
- [ ] Resolve Open Questions (event payloads, CustomCat attributes, port interfaces)
- [ ] Update architecture blueprint JSON if CatProfile should be value object (not entity)
- [ ] Document admin authentication approach
- [ ] Document user context extraction mechanism