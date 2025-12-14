# frozen_string_literal: true

module DomainEventHelpers
  # Captures domain events published during the execution of a block
  #
  # @example
  #   events = capture_domain_events do
  #     listing.publish!
  #   end
  #   expect(events).to include(an_instance_of(CatContent::Events::CatListingPublished))
  #
  def capture_domain_events
    events = []
    
    # Mock the event bus to capture events
    allow_any_instance_of(Rampart::Domain::AggregateRoot).to receive(:apply) do |instance, event|
      events << event
      # Still call the original apply method to update aggregate state
      instance.send(:on, event) if instance.respond_to?(:on, true)
    end
    
    yield
    
    events
  end

  # Asserts that a specific domain event was fired
  #
  # @example
  #   expect { listing.publish! }.to fire_domain_event(CatContent::Events::CatListingPublished)
  #
  RSpec::Matchers.define :fire_domain_event do |event_class|
    match do |block|
      events = []
      
      allow_any_instance_of(Rampart::Domain::AggregateRoot).to receive(:apply) do |instance, event|
        events << event
        instance.send(:on, event) if instance.respond_to?(:on, true)
      end
      
      block.call
      
      @fired_events = events
      events.any? { |e| e.is_a?(event_class) }
    end

    failure_message do
      "expected to fire #{event_class.name}, but fired: #{@fired_events.map(&:class).map(&:name).join(', ')}"
    end

    failure_message_when_negated do
      "expected not to fire #{event_class.name}"
    end
    
    supports_block_expectations
  end

  # Helper to get unpublished events from an aggregate
  #
  # @param aggregate [Rampart::Domain::AggregateRoot]
  # @return [Array<Rampart::Domain::DomainEvent>]
  #
  def unpublished_events_for(aggregate)
    return [] unless aggregate.respond_to?(:unpublished_events)
    aggregate.unpublished_events
  end
end

RSpec.configure do |config|
  config.include DomainEventHelpers
end

