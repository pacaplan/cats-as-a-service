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
└── cat_content.gemspec
```

## Conventions

1. **Pure Domain**: Keep domain logic free of framework code
2. **Repository Pattern**: Access persistence through repository interfaces
3. **Service Objects**: Encapsulate use cases in application services
4. **Events**: Use domain events for cross-context communication

## Naming Conventions

- **Ruby**: snake_case for methods/variables, PascalCase for classes

## Adding a New Use Case

1. Define domain entities/value objects if needed
2. Create application service for the use case
3. Implement repository in infrastructure layer
4. Expose via controller endpoint
5. Write tests at each layer

## Creating a New Bounded Context

1. Generate new Rails engine under `engines/`
2. Set up domain/application/infrastructure directories
3. Mount engine in `apps/api/config/routes.rb`
4. Document context in `docs/cat_app/`

## Health Check Endpoint

Each engine should implement a health check endpoint for troubleshooting:

**Location:** `app/controllers/health_controller.rb`

**Route:** `GET /mount_path/health` (e.g., `/catalog/health` for cat_content)

**Purpose:** Verify database connectivity to the engine's isolated schema
