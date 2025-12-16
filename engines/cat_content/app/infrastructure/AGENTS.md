# Infrastructure Layer Guidelines

The infrastructure layer contains all framework-specific code, I/O, and external integrations.

## Repositories

Repositories implement persistence ports, translating between domain and database.

**Rules:**
- Implement the port interface from `domain/ports/`
- Return domain objects (aggregates/entities), never ActiveRecord models
- Use mappers to translate between ActiveRecord and domain objects
- Keep query logic here, not in domain

```ruby
class SqlOrderRepository
  include OrderRepository # The port interface

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

