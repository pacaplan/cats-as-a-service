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
│       ├── engine.rb     # Rails engine configuration
│       └── loader.rb     # Hexagonal architecture loader
└── {engine_name}.gemspec
```

## Hexagonal Architecture Loader

Each engine uses a **Loader** module (`lib/{engine}/loader.rb`) to load hexagonal components in the correct order. This is necessary because the directory structure (`app/{layer}/{engine}/`) doesn't match Ruby namespace conventions.

### Key Points

- **Never use `require` or `require_relative`** to load classes within the engine
- The loader handles dependency ordering automatically
- When adding new files, update the loader to include them

### Adding New Components

Update `lib/{engine}/loader.rb` when adding new domain, application, or infrastructure files:

```ruby
def load_domain_layer(root)
  domain = root.join("app/domain/{engine}")
  load_files(domain.join("aggregates"), %w[existing_aggregate new_aggregate])
end
```

See `app/infrastructure/AGENTS.md` for detailed examples.

## Conventions

1. **Pure Domain**: Keep domain logic free of framework code
2. **Repository Pattern**: Access persistence through repository interfaces
3. **Service Objects**: Encapsulate use cases in application services
4. **Events**: Use domain events for cross-context communication
5. **No Manual Requires**: Let the loader handle class loading
