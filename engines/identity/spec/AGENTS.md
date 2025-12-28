# RSpec Guidelines for Rampart Engines

## Test Organization

Organize specs to mirror the layer structure:

```
spec/
├── domain/           # Pure Ruby, no Rails
│   ├── aggregates/
│   ├── value_objects/
│   └── services/
├── application/      # Pure Ruby, minimal mocking
│   └── services/
├── infrastructure/   # Rails required, integration tests
│   ├── repositories/
│   └── adapters/
├── requests/         # Full API integration tests
└── support/
    └── rampart_matchers.rb
```

## Domain Specs (Pure Ruby)

Domain specs should be fast and have no Rails dependencies.

```ruby
RSpec.describe Order do
  describe "#ship" do
    it "returns a shipped order" do
      order = Order.new(id: "123", status: :paid)
      shipped = order.ship(shipped_at: Time.now)
      expect(shipped.status).to eq(:shipped)
    end

    it "raises when order is unpaid" do
      order = Order.new(id: "123", status: :pending)
      expect { order.ship(shipped_at: Time.now) }.to raise_error(DomainException)
    end
  end
end
```

## Application Specs

Test use cases with stubbed ports—focus on orchestration logic.

```ruby
RSpec.describe ShipOrderService do
  let(:order_repository) { instance_double(OrderRepository) }
  let(:event_bus) { instance_double(EventBus) }
  let(:service) { described_class.new(order_repository:, event_bus:) }

  it "ships the order and publishes event" do
    order = Order.new(id: "123", status: :paid)
    allow(order_repository).to receive(:find).and_return(order)
    allow(order_repository).to receive(:save)
    allow(event_bus).to receive(:publish)

    result = service.call(order_id: "123", shipped_at: Time.now)

    expect(result).to be_success
    expect(event_bus).to have_received(:publish).with(instance_of(OrderShipped))
  end
end
```

## Infrastructure Specs

Integration tests that touch the database—use `rails_helper`.

```ruby
RSpec.describe SqlOrderRepository, type: :repository do
  it "persists and retrieves domain objects" do
    order = Order.new(id: SecureRandom.uuid, status: :pending)
    subject.save(order)
    found = subject.find(order.id)
    expect(found.status).to eq(:pending)
  end
end
```

## Architecture Fitness Specs

Verify architectural rules are followed.

```ruby
RSpec.describe "Architecture Fitness" do
  it "domain layer has no Rails dependencies" do
    domain_files = Dir["app/domain/**/*.rb"]
    domain_files.each do |file|
      content = File.read(file)
      expect(content).not_to match(/ActiveRecord|Rails|ActionController/)
    end
  end
end
```

## Best Practices

- **Fast feedback**: Domain/application specs should run in < 1 second
- **No database in domain specs**: Use factories that build domain objects directly
- **Test behavior, not implementation**: Focus on what, not how
- **One assertion per test**: Keep tests focused and readable


