# Infrastructure Layer Guidelines

The infrastructure layer contains all framework-specific code, I/O, and external integrations.

## Loading & Dependencies

**Critical:** Never use `require` or `require_relative` to load classes within the engine. The hexagonal architecture loader (`lib/cat_content/loader.rb`) handles loading all components in the correct order.

### Namespace Rules for ActiveRecord Models

**Important:** ActiveRecord models must be nested under `CatContent::Infrastructure::Persistence` to keep them out of the public API.

```ruby
# ✅ CORRECT - Nested under Infrastructure::Persistence
module CatContent
  module Infrastructure
    module Persistence
      class CatListingRecord < CatContent::Infrastructure::Persistence::BaseRecord
        # ...
      end
    end
  end
end
```

**File locations:**
- Base class: `app/infrastructure/cat_content/persistence/base_record.rb`
- Models: `app/infrastructure/cat_content/persistence/models/*.rb`

This ensures the architecture spec passes: "public API does not expose ActiveRecord models"

### Adding New Files

When adding new files, update `lib/cat_content/loader.rb`:

```ruby
def load_infrastructure_layer(root)
  infra = root.join("app/infrastructure/cat_content")
  
  # Base record must load before models
  load_files(infra.join("persistence"), %w[base_record])
  
  # Models
  load_files(infra.join("persistence/models"), %w[cat_listing_record your_new_record])
end
```

---

## Repositories

Repositories implement persistence ports, translating between domain and database.

**Rules:**
- Implement the port interface from `domain/ports/`
- Return domain objects (aggregates/entities), never ActiveRecord models
- Use mappers to translate between ActiveRecord and domain objects
- Keep query logic here, not in domain

```ruby
class SqlOrderRepository < OrderRepository
  def find(id)
    record = Infrastructure::Persistence::OrderRecord.find_by(id: id)
    return nil unless record
    OrderMapper.to_domain(record)
  end

  def save(order)
    record = Infrastructure::Persistence::OrderRecord.find_or_initialize_by(id: order.id)
    OrderMapper.to_record(order, record)
    record.save!
  end
end
```

## Mappers

Mappers translate between domain objects and ActiveRecord models.

**Rules:**
- Keep in `persistence/mappers/`
- `to_domain(record)` → domain object
- `to_record(domain, record)` → ActiveRecord model
- Handle nested value objects and associations

## Adapters

Adapters integrate with external services (APIs, queues, etc.).

**Rules:**
- Implement ports defined in domain layer
- Keep external API details isolated
- Return domain types, not raw API responses

## Controllers

Controllers are primary adapters that handle HTTP requests.

**Rules:**
- Call application services, not domain objects directly
- Handle serialization/deserialization
- Keep thin—no business logic
- Return appropriate HTTP status codes based on Result

## Wiring (Dependency Injection)

Container configuration wires ports to their adapters.

**Rules:**
- Keep in `wiring/container.rb`
- Register all port implementations
- Use constructor injection in services

