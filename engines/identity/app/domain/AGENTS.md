# Domain Layer Guidelines

The domain layer is the **Functional Core**—pure Ruby with no framework dependencies, no I/O, and no side effects.

## Aggregates

Aggregates are consistency boundaries that enforce business invariants.

**Rules:**
- Inherit from `Rampart::Domain::AggregateRoot`
- Keep immutable—methods return new instances, never mutate state
- All state changes go through the aggregate root
- Validate invariants in the constructor

```ruby
class Order < Rampart::Domain::AggregateRoot
  def ship(shipped_at:)
    raise DomainException, "Cannot ship unpaid order" unless paid?
    self.class.new(**attributes.merge(status: :shipped, shipped_at: shipped_at))
  end
end
```

## Entities

Entities have identity that persists over time.

**Rules:**
- Inherit from `Rampart::Domain::Entity`
- Identity is defined by an ID, not attributes
- Keep immutable when possible

## Value Objects

Value objects are immutable and defined by their attributes.

**Rules:**
- Inherit from `Rampart::Domain::ValueObject`
- No setters—completely immutable
- Equality based on attributes, not identity
- Self-validating in constructor

```ruby
class Money < Rampart::Domain::ValueObject
  attribute :amount_cents, Types::Integer
  attribute :currency, Types::String.default("USD")

  def add(other)
    raise "Currency mismatch" unless currency == other.currency
    self.class.new(amount_cents: amount_cents + other.amount_cents, currency: currency)
  end
end
```

## Domain Events

Domain events record facts that happened, named in past tense.

**Rules:**
- Inherit from `Rampart::Domain::DomainEvent`
- Name in past tense: `OrderShipped`, `CatListingPublished`
- Include `event_id`, `occurred_at`, `schema_version`
- Keep payloads minimal but sufficient for consumers

## Domain Services

Domain services contain logic that doesn't belong to a single aggregate.

**Rules:**
- Inherit from `Rampart::Domain::DomainService`
- Pure functions—no I/O, no persistence
- Coordinate multiple aggregates without bypassing their invariants

## Ports

Ports define interfaces for infrastructure dependencies.

**Rules:**
- Inherit from `Rampart::Ports::SecondaryPort`
- Define abstract methods only—no implementations
- Return domain objects, not infrastructure types


