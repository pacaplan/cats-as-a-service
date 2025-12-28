# Application Layer Guidelines

The application layer orchestrates domain logic and coordinates infrastructure through ports.

## Application Services (Use Cases)

Application services implement business operations by orchestrating domain objects and ports.

**Rules:**
- Inherit from `Rampart::Application::Service`
- One public method per use case (single responsibility)
- Return `Rampart::Support::Result` (Success/Failure)
- Publish domain events after successful persistence
- No business logic—delegate to domain objects

```ruby
class ShipOrderService < Rampart::Application::Service
  def call(order_id:, shipped_at:)
    order = order_repository.find(order_id)
    return Failure(:not_found) unless order

    shipped_order = order.ship(shipped_at: shipped_at)
    order_repository.save(shipped_order)
    event_bus.publish(OrderShipped.new(order_id: order_id, shipped_at: shipped_at))

    Success(shipped_order)
  end
end
```

## Commands

Commands are DTOs representing intent to change state.

**Rules:**
- Inherit from `Rampart::Application::Command`
- Use task-based naming: `ShipOrder`, `ArchiveCat` (not `UpdateOrder`)
- Validate input in the command, not the service
- Immutable after construction

```ruby
class ShipOrder < Rampart::Application::Command
  attribute :order_id, Types::String
  attribute :shipped_at, Types::DateTime
end
```

## Queries

Queries are DTOs for read operations.

**Rules:**
- Inherit from `Rampart::Application::Query`
- Name describes what is being retrieved: `ListActiveOrders`, `GetOrderDetails`
- Can include pagination, filtering, sorting parameters

## Transactions

Wrap use case execution in transactions at the application layer edge.

**Rules:**
- Use `Rampart::Application::Transaction` for transactional boundaries
- Domain layer never starts transactions
- Keep transaction scope minimal


