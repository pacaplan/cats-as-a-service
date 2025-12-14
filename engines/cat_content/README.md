# Cat & Content Bounded Context Engine

Rails engine implementing the Cat & Content bounded context using Rampart patterns with schema isolation.

## Overview

This engine manages:
- **Cat Listings** - Premade, curated cats in the catalog
- **Custom Cats** - User-generated, AI-created cat records

## Architecture Patterns

This engine implements five architectural approaches from the [Rampart Vision](../../docs/rampart/rampart_vision.md):

| Pattern | Implementation |
|---------|----------------|
| **3.1 DDD** | Aggregates (`CatListing`, `CustomCat`), Value Objects, Domain Events, Ports |
| **3.2 Hexagonal** | Ports in `domain/ports/`, Adapters in `infrastructure/` |
| **3.3 Clean Architecture** | Dependency rule, framework-independent domain, use cases as Application Services |
| **3.4 Modular Monolith** | Engine isolation, schema isolation, vertical slice at BC level |
| **3.5 CQRS** | Commands for writes (`CreateCatListing`), Queries for reads (`ListCatListingsQuery`) |
| **3.6 Domain Events** | Application services publish domain events through an Event Bus port |
| **3.7 Fitness Functions** | RSpec pattern verification (Packwerk deferred) |
| **3.8 Functional Core / Imperative Shell** | Immutable aggregates; domain layer remains pure, events published from application services |

### Why Layer-First (Not Feature-First)

The engine uses layer-first organization (`domain/`, `application/`, `infrastructure/`) rather than feature-first ("Screaming Architecture") because:

1. **The engine name IS the scream** - `cat_content` clearly identifies the bounded context
2. **Shared domain objects** - Aggregates and ports are used across multiple use cases
3. **Predictable navigation** - Consistent structure across all bounded context engines
4. **AI-friendly** - Tools can predict file locations without knowing feature names

Application Services (`CatListingService`, `CustomCatService`) serve as Clean Architecture "use cases", orchestrating domain logic while maintaining the dependency rule.

## Architecture

### Layer Separation

```
app/
├── domain/cat_content/           # Pure Ruby - No Rails
│   ├── aggregates/              # CatListing, CustomCat
│   ├── entities/                # CatProfile
│   ├── value_objects/           # CatId, CatName, Slug, Visibility, Money, etc.
│   ├── events/                  # Domain events
│   ├── services/                # Domain services
│   └── ports/                   # Repository interfaces
│
├── application/cat_content/      # Pure Ruby - No Rails
│   ├── services/                # Application services (use cases)
│   ├── commands/                # Command DTOs
│   └── queries/                 # Query DTOs
│
└── infrastructure/cat_content/   # Rails-specific code
    ├── persistence/
    │   ├── models/              # ActiveRecord models
    │   ├── mappers/             # Domain ↔ ActiveRecord mapping
    │   └── repositories/        # Repository implementations
    ├── adapters/                # External service adapters
    ├── http/
    │   ├── controllers/         # REST controllers
    │   └── serializers/         # JSON serializers
    └── wiring/                  # Dependency injection container
```

### Schema Isolation

This engine uses its own PostgreSQL schema (`cat_content`) completely isolated from other engines:

- **Database Connection**: Dedicated connection with `search_path: "cat_content"`
- **BaseRecord**: All models inherit from `CatContent::Infrastructure::Persistence::BaseRecord`
- **Schema Management**: Handled by Supabase migrations (not Rails migrations)
- **Tables**: Only visible to this engine's connection

```ruby
# All models inherit from this
class BaseRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: { writing: :cat_content, reading: :cat_content }
end
```

## Database Tables

Tables are created by Supabase migrations in `supabase/migrations/`.

### cat_listings
Premade, curated cats for the catalog.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | string | Cat name |
| description | text | Description |
| slug | string | URL-friendly identifier |
| price_cents | integer | Price in cents |
| currency | string | Currency code (default: USD) |
| visibility | string | public/private/archived |
| image_url | string | Main image URL |
| image_alt | string | Image alt text |
| tags | jsonb | Category tags array |

### custom_cats
User-generated custom cats created via AI.

| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| user_id | string | Owner user ID |
| name | string | Cat name |
| prompt_text | text | Original user prompt |
| quiz_results | jsonb | Quiz results used for generation |
| story_text | text | AI-generated story |
| visibility | string | private/archived |
| image_url | string | Generated image URL |

## Setup

This engine uses tables created by Supabase. Just run `supabase start` from the project root.

```bash
# From project root
supabase start
```

To recreate schemas:
```bash
supabase db reset
```

## API Endpoints

Mounted at `/catalog` in the host application:

- `GET /catalog/listings` - Browse public cat listings
- `GET /catalog/listings/:id` - Get cat details
- `GET /catalog/custom-cats` - User's custom cats
- `POST /catalog/custom-cats` - Generate new custom cat

See [API Documentation](../../docs/cat_app/cat_content_api.md) for complete endpoint reference.

## Domain Model

### Aggregates
- **CatListing** - Root for catalog browsing
- **CustomCat** - Root for user's created cats

### Key Value Objects
- **CatId** / **CustomCatId** - Unique identifiers
- **CatName** - Validated cat name (1-100 chars)
- **Slug** - URL-friendly identifier
- **Visibility** - Enum: public, private, archived
- **Money** - Price with currency
- **CatPrompt** - Original prompt text
- **CatStory** - AI-generated description

### Domain Events
- `CatListingPublished` - Cat made publicly visible
- `CatListingArchived` - Cat removed from public view
- `CustomCatCreated` - User's custom cat generated
- `CustomCatArchived` - User archived their cat
- `CatDescriptionRegenerated` - AI regenerated description

## Next Steps

1. **Implement Domain Layer**
   - Complete value object implementations
   - Implement aggregates with business logic
   - Define domain events

2. **Implement Application Layer**
   - CatListingService (create, publish, archive)
   - CustomCatService (generate, regenerate, archive)
   - Command/Query DTOs

3. **Implement Infrastructure Layer**
   - ActiveRecord models (CatListingRecord, CustomCatRecord)
   - Mappers (domain ↔ persistence translation)
   - Repositories (SqlCatListingRepository, SqlCustomCatRepository)
   - Controllers (REST endpoints)
   - LLM adapter (OpenAI/Claude for cat generation)

4. **Add Tests**
   - Domain specs (pure Ruby, no Rails)
   - Application specs (pure Ruby, no Rails)
   - Integration specs (with test database)

## References

- [Architecture Documentation](../../docs/cat_app/cat_content_architecture.md)
- [Implementation Spec](../../docs/cat_app/cat_content_implementation.md)
- [API Documentation](../../docs/cat_app/cat_content_api.md)
