# Infrastructure Layer Guidelines

The infrastructure layer contains all framework-specific code, I/O, and external integrations.

## Loading & Dependencies

**Critical:** Never use `require` or `require_relative` to load classes within the engine. The hexagonal architecture loader (`lib/identity/loader.rb`) handles loading all components in the correct order.

### Why No Manual Requires?

The directory structure (`app/{layer}/identity/`) doesn't match Ruby namespace conventions, so Zeitwerk can't auto-resolve. Instead, we use a structured loader that:

1. Loads domain layer first (aggregates, ports)
2. Loads application layer (services)
3. Loads infrastructure layer (models, mappers, repositories, wiring)

### Adding New Files

When adding new files, update `lib/identity/loader.rb`:

```ruby
def load_domain_layer(root)
  domain = root.join("app/domain/identity")
  load_files(domain.join("aggregates"), %w[shopper_identity your_new_aggregate])
  load_files(domain.join("ports"), %w[shopper_identity_repository your_new_port])
end
```

### What NOT to Do

```ruby
# ❌ WRONG - Don't use require_relative
class MyRepository < SomePort
  def initialize
    require_relative "../models/some_model"  # NO!
  end
end

# ❌ WRONG - Don't use require_relative in class body
class MyMapper
  require_relative "../../domain/some_aggregate"  # NO!
end
```

### Correct Pattern

```ruby
# ✅ CORRECT - Just reference the class directly
class MyRepository < SomePort
  def find(id)
    record = SomeRecord.find_by(id: id)
    SomeMapper.to_domain(record)
  end
end
```

The loader ensures all dependencies are available before your class is loaded.

---

## Controllers (Primary Adapters)

See `app/controllers/AGENTS.md` for detailed controller guidelines.

**Key rule:** Controllers must ONLY call application services—never repositories or domain objects directly.

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
    record = OrderRecord.find_by(id: id)
    return nil unless record
    OrderMapper.to_domain(record)
  end

  def save(order)
    record = OrderRecord.find_or_initialize_by(id: order.id)
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

## Wiring (Dependency Injection)

Container configuration wires ports to their adapters.

**Rules:**
- Keep in `wiring/container.rb`
- Register all port implementations
- Use constructor injection in services
- Reference classes directly (no requires needed)

```ruby
# ✅ CORRECT - Classes are already loaded by the loader
register(:shopper_identity_repo) { DeviseShopperIdentityRepository.new }

register(:shopper_auth_service) do
  ShopperAuthService.new(shopper_identity_repo: resolve(:shopper_identity_repo))
end
```


