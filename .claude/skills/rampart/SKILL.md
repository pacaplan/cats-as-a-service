# Rampart Hexagonal Architecture Skill

Patterns for building Rails applications with hexagonal architecture. Layer boundaries and base class inheritance are enforced by Packwerk and RSpec—this skill covers naming conventions, design patterns, and best practices that aren't automated.

---

## Quick Reference

```
engines/{context}/
├── app/domain/{context}/           # Pure Ruby: aggregates, entities, value objects, events, ports
├── app/application/{context}/      # Pure Ruby: services, commands, queries
└── app/infrastructure/{context}/   # Rails: persistence, adapters, wiring, controllers
```

**Flat namespace:** `CatContent::CatListing` ✅ — not `CatContent::Domain::Aggregates::CatListing` ❌

---

## Naming Conventions

### Commands (Task-Based)
Name commands as imperative actions describing business intent:

| ✅ Good | ❌ Bad |
|---------|--------|
| `ShipOrder` | `UpdateOrder` |
| `ArchiveCat` | `ModifyCat` |
| `PublishListing` | `SaveListing` |

### Domain Events (Past Tense)
Events record facts that happened:

| ✅ Good | ❌ Bad |
|---------|--------|
| `OrderShipped` | `ShipOrder` |
| `CatListingPublished` | `PublishCatListing` |
| `UserRegistered` | `CreateUser` |

### Queries (Descriptive)
Name describes what is retrieved:

| ✅ Good | ❌ Bad |
|---------|--------|
| `ListActiveCats` | `GetCats` |
| `GetOrderDetails` | `FetchOrder` |
| `FindUserByEmail` | `UserQuery` |

---

## Design Patterns

### Application Services
- **One public method per service** (`call`) — single responsibility
- **Return `Result`** — `Success(value)` or `Failure(reason)`
- **Delegate business logic** — services orchestrate, domain objects decide
- **Publish events after persistence** — not before, not in domain

```ruby
class ShipOrderService < Rampart::Application::Service
  def call(order_id:, shipped_at:)
    order = order_repository.find(order_id)
    return Failure(:not_found) unless order

    shipped_order = order.ship(shipped_at: shipped_at)  # Domain decides
    order_repository.save(shipped_order)
    event_bus.publish(OrderShipped.new(...))            # After persistence

    Success(shipped_order)
  end
end
```

### Controllers (Primary Adapters)
- **Explicit namespace for base class** — prevents accidental dependency on host app
- **Delegate to application services** — controllers only orchestrate, never call domain/repos directly
- **Handle Result monads** — convert Success/Failure to HTTP responses

### Mappers
Translate between domain objects and ActiveRecord:

```ruby
class OrderMapper
  def self.to_domain(record)
    Order.new(id: record.id, status: record.status.to_sym, ...)
  end

  def self.to_record(order, record)
    record.status = order.status.to_s
    record
  end
end
```

### Domain Events
Keep payloads minimal but sufficient for consumers:

```ruby
class OrderShipped < Rampart::Domain::DomainEvent
  attribute :order_id, Types::String
  attribute :shipped_at, Types::DateTime
  # Include what consumers need, not the whole aggregate
end
```

### Aggregates (Immutability Pattern)
Methods return new instances, never mutate:

```ruby
class Order < Rampart::Domain::AggregateRoot
  def ship(shipped_at:)
    raise DomainException, "Cannot ship unpaid order" unless paid?
    # Return NEW instance, don't mutate self
    self.class.new(**attributes.merge(status: :shipped, shipped_at: shipped_at))
  end
end
```

---

## Testing Patterns

### Organization by Layer

```
spec/
├── domain/           # Pure Ruby, NO Rails, NO database
├── application/      # Stubbed ports, focus on orchestration
├── infrastructure/   # Database integration tests
└── requests/         # Full API tests
```

### Domain Specs (Fast, Pure Ruby)
```ruby
RSpec.describe Order do
  it "returns shipped order when paid" do
    order = Order.new(id: "123", status: :paid)
    shipped = order.ship(shipped_at: Time.now)
    expect(shipped.status).to eq(:shipped)
  end
end
```

### Application Specs (Stubbed Ports)
```ruby
RSpec.describe ShipOrderService do
  let(:order_repository) { instance_double(OrderRepository) }
  let(:service) { described_class.new(order_repository:, event_bus:) }

  it "publishes event after shipping" do
    allow(order_repository).to receive(:find).and_return(paid_order)
    allow(order_repository).to receive(:save)

    result = service.call(order_id: "123", shipped_at: Time.now)

    expect(event_bus).to have_received(:publish).with(instance_of(OrderShipped))
  end
end
```

### Best Practices
- **Fast feedback**: Domain/application specs < 1 second
- **No database in domain specs**: Build domain objects directly
- **Test behavior, not implementation**: Focus on what, not how

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correct Approach |
|--------------|----------------|------------------|
| `UpdateOrder` command | CRUD naming hides intent | Task-based: `ShipOrder`, `CancelOrder` |
| `ShipOrder` event | Sounds like command | Past tense: `OrderShipped` |
| Mutable aggregates | Hard to reason about state | Return new instances |
| Business logic in services | Anemic domain model | Put logic in domain objects |
| Events published before save | May never persist | Publish after successful save |
| Nested namespaces | Verbose, non-standard | Flat: `Context::ClassName` |
| Large event payloads | Tight coupling, bloat | Minimal: IDs + essential data |
