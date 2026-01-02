# Backend Agent Guidelines (Rails Engines)

## Architecture Principles

### Hexagonal Architecture (Ports & Adapters)

When working on bounded context engines, maintain strict layer separation:

```
Domain Layer (Pure Ruby)
├── Aggregates, Entities, Value Objects
├── Domain Events
└── Repository Interfaces (Ports)

Application Layer (Pure Ruby)
├── Application Services / Use Cases
├── Command/Query handlers
└── Orchestrates domain logic

Infrastructure Layer (Rails-specific)
├── Controllers (Primary Adapters)
├── ActiveRecord models (Secondary Adapters)
└── Repository Implementations
```

**Rules:**
- Domain and Application layers must be pure Ruby—no Rails dependencies
- Only Infrastructure layer touches Rails, ActiveRecord, HTTP, etc.
- Dependencies point inward: Infrastructure → Application → Domain

### Bounded Contexts

Each bounded context is a self-contained Rails engine:
- Has its own domain model and ubiquitous language
- Communicates with other contexts via events or explicit interfaces
- Never shares ActiveRecord models across context boundaries

## Engine Structure

Each engine under `engines/` follows this layout:

```
engines/cat_content/
├── app/
│   ├── controllers/      # Controllers (Rails convention)
│   ├── models/           # ActiveRecord models (Rails convention)
│   ├── domain/           # Aggregates, entities, value objects
│   ├── application/      # Services, use cases
│   └── infrastructure/   # Repos, adapters, other infrastructure
├── lib/
│   └── {engine_name}/
│       └── engine.rb     # Rails engine configuration
└── {engine_name}.gemspec
```

## Auto-Loading with Rampart

Each engine uses `Rampart::EngineLoader` to auto-discover and load all hexagonal architecture components. The loader handles the directory structure mismatch between organizational subdirectories and Ruby namespaces.

### Adding New Components

Simply create the file in the appropriate directory - no configuration needed:

```bash
# Create a new value object
touch app/domain/cat_content/value_objects/cat_color.rb

# Create a new aggregate
touch app/domain/cat_content/aggregates/cat_order.rb
```

The loader auto-discovers all `.rb` files and loads them in the correct order.

## Conventions

1. **Pure Domain**: Keep domain logic free of framework code
2. **Repository Pattern**: Access persistence through repository interfaces
3. **Service Objects**: Encapsulate use cases in application services
4. **Events**: Use domain events for cross-context communication
5. **No Manual Requires**: `Rampart::EngineLoader` handles class loading automatically
6. **Flat Namespace**: All classes use `{Context}::{ClassName}` (e.g., `CatContent::CatListing`, `CatContent::Container`)

## Namespace Convention

All classes within an engine use a flat namespace under the context module:
- ✅ CORRECT - CatContent::CatListingRecord
- ❌ WRONG - CatContent::Infrastructure::Persistence::CatListingRecord
