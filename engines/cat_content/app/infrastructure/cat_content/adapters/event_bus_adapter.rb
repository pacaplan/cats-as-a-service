# frozen_string_literal: true

module CatContent
  module Infrastructure
    module Adapters
      class EventBusAdapter < Ports::EventBusPort
        def publish(event:)
          Rails.logger.info("Event Published: #{event.class.name} - #{event.as_json}")
        end
      end
    end
  end
end
